<?php
$matfile = 'sim/load_data.m';

if (!function_exists("json_decode")) die("Error: JSON for PHP not installed!");

//------------------------------------------------------------------------------

function err($message)
{
	$code = '400';
	$protocol = (isset($_SERVER['SERVER_PROTOCOL']) ? $_SERVER['SERVER_PROTOCOL'] : 'HTTP/1.0');
    header($protocol . ' ' . $code . ' ' . $message);
    die('Error: '.$message);
}	//~ err

function endsWith($haystack, $needle)
{
    return $needle === "" || substr($haystack, -strlen($needle)) === $needle;
}

function read_data() {
	global $matfile;
	$fh = fopen($matfile, 'r');
	if (!$fh) die('File error!');
	$data = array();
	while ($line = strtolower(trim(fgets($fh)))) {
		while (strpos($line, '...') > strlen($line) - 5) $line =  str_replace('...', '', $line).strtolower(trim(fgets($fh)));
		if (0 < strpos($line, '%'))
			$line = trim(substr($line, 0, strpos($line, '%')));
		if (endsWith($line, ';')) $line = substr($line, 0, -1);
		@$parts = split('=', $line);
		if (sizeof($parts) < 2 || -1 < strpos($line, 'function')) continue;
		$rawdata = trim($parts[1]);
		if (strpos($rawdata, ';') > 0)
			$rawdata = str_replace("[", "[[", str_replace("]", "]]", $rawdata));
		$rawdata = str_replace('[, ', '[', str_replace(";", "], [", str_replace(" ", ", ", $rawdata)));
		//if (0 === strpos($parts[0], 'NodeCoordinates'))
		$data[trim($parts[0])] = json_decode($rawdata);
		//print($rawdata."<br>");
	}
	fclose($fh);
	return $data;
}	//~ read_data

function write_data($data) {
	global $matfile;
	$fh = fopen($matfile, 'w');
	fputs($fh, "function [nodecoordinates, ktrans, qgen, qcons, transx, transy] = load_data()\n");
	foreach($data as $key => $val)
	{
		$line = '[';
		foreach($val as $v)
		{
			if (is_array($v))
			{
				foreach($v as $elem)
					$line .= $elem.' ';
				$line .= ';';
			} else $line .= $v.' ';
		}
		$line .= '];';
		$line = str_replace(" ;", "; ", $line);
		$line = str_replace(" ]", "]", $line);
		$line = str_replace(";]", "]", $line);
		fputs($fh, "\t$key = $line\n");
	}
	fputs($fh, "end");
	return 0;
}	//~ write_data

//------------------------------------------------------------------------------

$data = read_data();

if (isset($_POST['action']))
{
	$action = $_POST['action'];
	$nodes_count = sizeof($data['nodecoordinates']);
	//~ $max_node = ..;.
	$node_id = isset($_POST['id']) ? $_POST['id'] : -1;
	$node2 = isset($_POST['id2']) ? $_POST['id2'] : -1;
	$value = isset($_POST['value']) ? $_POST['value'] : -1;
	switch($_POST['action'])
	{
		case 'addnode':
			$lon = isset($_POST['lon']) ? $_POST['lon'] : -1;
			$lat = isset($_POST['lat']) ? $_POST['lat'] : -1;
			$gen = isset($_POST['gen']) ? $_POST['gen'] : -1;
			$cons = isset($_POST['cons']) ? $_POST['cons'] : -1;
			if ($lat < 0 || $lon < 0 || $gen < 0 || $cons < 0)
				err("One of mandatory variables: longitude, latitude, generation or consumption is negative or missing!");
			$data['nodecoordinates'][] = array($lon, $lat);
			$data['qgen'][0][] = $gen;
			$data['qcons'][0][] = $cons;
			$data['qcons'][2][] = $data['qgen'][1][] = 0;
			$data['qcons'][2][] = $data['qgen'][2][] = max($data['qgen'][2]) + 1;
			break;
		case 'delnode':
			unset($data['nodecoordinates'][$node_id]);
			unset($data['qgen'][0][$node_id]);
			unset($data['qgen'][1][$node_id]);
			unset($data['qgen'][2][$node_id]);
			unset($data['qcons'][0][$node_id]);
			unset($data['qcons'][1][$node_id]);
			unset($data['qcons'][2][$node_id]);
			break;
		case 'gen':
		case 'cons':
			$data['q'.$action][0][$node_id] = $value;
			break;
		case 'link':
			if ($value < 0 || $node2 < 0 || $node_id < 0)
				err("One of mandatory variables: id, id2, value is missing or negative!");
			if ($value > 1)
				err("Transmission coefficient must not be equal to 0!");
			 if ($node2 > $nodes_count || $node_id > $nodes_count)
			 	err("Could find the nodes requested!");
			$data['ktrans'][0][] = $value;
			$data['ktrans'][1][] = $node_id;
			$data['ktrans'][2][] = $node2;
			break;
		case 'unlink':
			foreach($data['ktrans'][1] as $key => $src)
				if (($src.'' == $node_id && $data['ktrans'][2][$key].'' == $node2) || ($src.'' == $node2 && $data['ktrans'][2][$key].'' == $node_id))
					for ($i = 0; $i < 3; $i++)
						unset($data['ktrans'][$i][$key]);
			break;
		case 'edit':
			$data['ktrans'][0][$node_id] = $value;
			break;
		//~ Restoring original (working) load_data.m
		case 'reset':
			copy(str_replace(".m", ".bak", $matfile), $matfile); 
			break;
	}

}

write_data($data);

print(json_encode($data));

?>