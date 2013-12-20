clc; clear all; close all;
addpath('../');
format short

[NodeCoordinates, Ktr, Qgen, Qcons, TransX, TransY] = load_data();

Ktr = Ktr';
%NodeCoordinates(:, 1) = -NodeCoordinates(:, 1);
%NodeCoordinates(:,[1,2])=NodeCoordinates(:,[2,1]);
Qgen_con = [Qgen(3, :)', Qgen(1, :)', Qcons(1, :)'];
Qgc = Qgen_con(:,2) - Qgen_con(:,3);

img = imread('china_full_small.png');
f_im = figure('Name', 'China modelwhos', 'Color', 'white', 'Position', [0 0 2000 1500]);
set(f_im, 'PaperPosition', [0 0 60 45]);
imagesc(TransX, TransY, img);
hold on

% data import from Excel tables
%[Qgen_con, ~, alldata1] = xlsread('China_power.xlsx','Sheet 1','D1:F101');
% Qgen_con - difference between generation and consumption in each node
%disp(alldata1);

%[Ktrans, ~, alldata2]  = xlsread('China_power.xlsx','Sheet 2','A1:C101');
% Ktr - coefficient of losses during transmisson
%disp(alldata2);

% [GeoCoordinates, ~, alldata3]  = xlsread('China_power.xls','Sheet 1','K1:L33');
% disp(alldata3);

%[NCoordinates, ~, alldata3] = xlsread('China_power.xlsx','Sheet 3');
% coordinates of nodes
%disp(alldata3);


% saving data to .mat file
save China_energy_data.mat Qgen_con Ktr NodeCoordinates



Num_lines=max(size(Ktr)); % - number of transmisson lines
Num_nodes=max(size(Qgen_con)); % number of nodes
E = zeros(Num_nodes,Num_lines);


%% Visualization

% NodeCoordinates = [2 4; 6 6; 10 6; 12 7; 10 2; 18 8; 20 6; 16 0; 6 6; 6 6; 10 6]; %you can make these up or get them from Amy's students
NodalValues     = 0.005*Qgc; %this is the solution of your nodal analysis problem

EdgeConnections = Ktr(:,2:3); %you can derive this from your nodal matrix
N = max(size(Ktr)); % - number of transmisson lines
B = max(size(Qgen_con)); % number of nodes
E = zeros(B,N);

%% E matrix and b vector construction
for i=1:B   % strings
    for j = 1:N  % columns
        if Ktr(j,2)==i % if power flows out node
        E(i,j) = E(i,j)+1; 
        end       
        if Ktr(j,3)==i % if flows into node
        E(i,j) = E(i,j)-(1-Ktr(j,1));
        end
    end
end
 
Qb = zeros(1,B)';
for k=1:B
    for n=1:B
        if Qgen_con(n,1)==k 
        Qb(k)=Qb(k)+ Qgen_con(n,2);
        end
%         if Qgen_con(n,1)==k
%         Qb(k)=Qb(k)-Qgen_con(n,2);
%         end
    end
end

b=Qb; 

x=E\b;x=abs(x(1:100));

for i=1:size(x, 1)
    if x(i)==0
        x(i)=x(i)+1000;
    end
end
FlowValues      =  0.002*x; %you can compute this using the consitutite equations
%FlowValues      = ones(1,size(Ktr, 1))';  %you can compute this using the consitutite equations

VisualizeNetwork(NodeCoordinates,NodalValues,EdgeConnections,FlowValues);
axis equal %this makes circle look like circles rather than ovals
%drawnow    %this is important if you are trying to do animations

%I = getframe(gcf);
%imwrite(I.cdata, 'china_model.png');
print -dpng -r96 '../china_model.png';
exit