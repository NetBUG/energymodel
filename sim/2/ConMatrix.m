%defines conductance matrix for power flow dc approximation
function [A,b]=conmatrix(Rl)
[NodeCoordinates, Ktrans, Qgen, Qcons, TransX, TransY] = load_data();
B=size(Ktrans,2) %define number of branches
N=size(NodeCoordinates,1) %define number of nodes
A=zeros(N); %define connectivity matrix


for i=1:B
Kres=Ktrans(1,i); %define the resistance of the current branch
Ksrc=Ktrans(2,i); %define source node for the current branch
Kdes=Ktrans(3,i); %define destination node for the current branch


A(Ksrc,Ksrc)=A(Ksrc,Ksrc)+1/Kres; %fill the connectivity matrix
A(Ksrc,Kdes)=A(Ksrc,Kdes)-1/Kres;
A(Kdes,Kdes)=A(Kdes,Kdes)+1/Kres;
A(Kdes,Ksrc)=A(Kdes,Ksrc)-1/Kres;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Add leakage resistance to every node, if needed%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:N
    A(i,i)=A(i,i)+1/Rl;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Construct right-hand side for nodal source currents%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
P=Qgen-Qcons;
b=-transpose((P(1,:)));