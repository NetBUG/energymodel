<?php
	header('Content-type: image/png');

	//~ update the image with model

	chdir('sim');
	$model = isset($_GET['model']) ? $_GET['model'] : '1';
	chdir($model);
	$last_line = system('matlab -nodesktop -nosplash -nodisplay -r main', $retval);
	chdir('..');
	sleep(5);
	//readfile('china_model.png');	
	$dst_x = 0;   // X-coordinate of destination point. 
	$dst_y = 0;   // Y --coordinate of destination point. 
	$src_x = 298; // Crop Start X position in original image
	$src_y = 298; // Crop Srart Y position in original image
	$src_w = 1764; // $src_x + $dst_w Crop end X position in original image
	$src_h = 1046; // $src_y + $dst_h Crop end Y position in original image
	$dst_w = $src_w - $src_x; // Thumb width
	$dst_h = $src_h - $src_y; // Thumb height

	// Creating an image with true colors having thumb dimensions.( to merge with the original image )
	$dst_image = imagecreatetruecolor($dst_w,$dst_h);
	// Get original image
	$src_image = imagecreatefrompng("china_model.png");
	// Cropping 
	imagecopyresampled($dst_image, $src_image, $dst_x, $dst_y, $src_x, $src_y, $dst_w, $dst_h, $src_w, $src_h);
	// Saving 
	imagepng($dst_image, "crop.png");
	readfile('crop.png');	
?>