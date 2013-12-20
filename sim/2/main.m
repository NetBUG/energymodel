%uses tgcr to solve the system for power flows
addpath('../');
[NodeCoordinates, Ktrans, Qgen, Qcons, TransX, TransY] = load_data();

img = imread('../china_full_small.png');
f_im = figure('Name', 'China modelwhos', 'Color', 'white', 'Position', [0 0 2000 1500]);
set(f_im, 'PaperPosition', [0 0 60 45]);
imagesc(TransX, TransY, img);
hold on

nodeSize = (Qgen(1, :) - Qcons(1, :)) * 0.008;

[A,b]=ConMatrix(100);
B=size(Ktrans,2); %define number of branches
N=size(NodeCoordinates,1); %define number of nodes
[x] = tgcr(A,b,0.01,100);%x is a column of voltage angles
Pflow=zeros(B,1); %define pflow column
for i=1:B
Kres=Ktrans(1,i); %define the resistance of the current branch
Ksrc=Ktrans(2,i); %define source node for the current branch
Kdes=Ktrans(3,i); %define destination node for the current branch  

Pflow(i)=Kres*(x(Ksrc)-x(Kdes));%calculate power flows from resistance of the branch and voltage angle difference
end

NodeCoordinatesNetB = NodeCoordinates;%[0 7; 5 8; -3 13]; 
NodalValuesNetB     = b*0.005;%[0.5;  1;   0.5];

EdgeConnectionsNetB = transpose(Ktrans(2:3,:));%[1 2; 1 3];
FlowValuesNetB      = abs(Pflow);%[4;   3]

color  = 'r';
height = 1;

VisualizeNetwork(NodeCoordinatesNetB,NodalValuesNetB,EdgeConnectionsNetB,FlowValuesNetB,color,height, nodeSize);
axis equal;
print -dpng -r96 '../china_model.png';
exit