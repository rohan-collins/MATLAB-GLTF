% © Copyright 2014-2023 Rohan Chabukswar
%
% This file is part of MATLAB GLTF.
%
% MATLAB GLTF is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or (at
% your option) any later version.
%
% MATLAB GLTF is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
% General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with MATLAB GLTF. If not, see <https://www.gnu.org/licenses/>.
%
% Generate ball valve mesh
L=4;
t=0.1;
r=0.1;
h=2;
dtheta=5;
theta=(45:dtheta:135)*pi/180;
phi=(0:dtheta:360)'*pi/180;
phi=phi(1:end-1);
M=numel(theta);
N=numel(phi);

V_ball=[
    reshape(cos(phi)*sin(theta),[],1) reshape(sin(phi)*sin(theta),[],1) reshape(ones(size(phi))*cos(theta),[],1)
    reshape(cos(phi)*sin(theta([end 1])),[],1) reshape(sin(phi)*sin(theta([end 1])),[],1) reshape(ones(size(phi))*cos(theta([end 1])),[],1)
    ]*[1 0 0;0 0 -1;0 1 0]*[0 1 0;-1 0 0;0 0 1];
V_ball=V_ball*[0 0 1;1 0 0;0 1 0];
F_ball=[reshape([1:N;N+1:2*N;N+2:2*N N+1;2:N 1]+N*reshape((0:M-2),1,1,[]),4,[]) [1:N;N+1:2*N;N+2:2*N N+1;2:N 1]+M*N]';
F_ball=reshape(F_ball(:,[1 2 3 3 4 1])',3,[])';

V_tube=[
        [
        reshape(cos(phi)*sin(repmat(theta(1),1,2)),[],1) reshape(sin(phi)*sin(repmat(theta(1),1,2)),[],1) reshape(ones(size(phi))*[L cos(theta(1))],[],1);
        reshape(cos(phi)*sin(theta),[],1) reshape(sin(phi)*sin(theta),[],1) reshape(ones(size(phi))*cos(theta),[],1);
        reshape(cos(phi)*sin(repmat(theta(end),1,2)),[],1) reshape(sin(phi)*sin(repmat(theta(end),1,2)),[],1) reshape(ones(size(phi))*[cos(theta(end)) -L],[],1);
        ].*[1+t 1+t 1];
        [reshape(cos(phi)*sin(theta(end)),[],1) reshape(sin(phi)*sin(theta(end)),[],1) -ones(size(phi))*L].*[1+t 1+t 1];
        [reshape(cos(phi)*sin(theta(end)),[],1) reshape(sin(phi)*sin(theta(end)),[],1) -ones(size(phi))*L];
        [
        reshape(cos(phi)*sin(repmat(theta(end),1,2)),[],1) reshape(sin(phi)*sin(repmat(theta(end),1,2)),[],1) reshape(ones(size(phi))*[-L cos(theta(end))],[],1);
        reshape(cos(phi)*sin(flip(theta)),[],1) reshape(sin(phi)*sin(flip(theta)),[],1) reshape(ones(size(phi))*cos(flip(theta)),[],1);
        reshape(cos(phi)*sin(repmat(theta(1),1,2)),[],1) reshape(sin(phi)*sin(repmat(theta(1),1,2)),[],1) reshape(ones(size(phi))*[cos(theta(1)) L],[],1);
        ]
        reshape(cos(phi)*sin(theta(1)),[],1) reshape(sin(phi)*sin(theta(1)),[],1) ones(size(phi))*L;
        [reshape(cos(phi)*sin(theta(1)),[],1) reshape(sin(phi)*sin(theta(1)),[],1) ones(size(phi))*L].*[1+t 1+t 1];
    ]*[1 0 0;0 0 -1;0 1 0];
V_tube=V_tube*[0 0 1;1 0 0;0 1 0];
F_tube=(reshape([1:N;N+1:2*N;N+2:2*N N+1;2:N 1]+N*reshape([0 2:M M+2 M+4 M+6 M+8:2*M+6 2*M+8 2*M+10],1,1,[]),4,[]))';
F_tube=reshape(F_tube(:,[1 2 3 3 4 1])',3,[])';

V_shaft=[r*sin(phi) r*cos(phi) ones(N,1);r*sin(phi) r*cos(phi) h*ones(N,1)];
V_shaft=V_shaft*[0 0 1;1 0 0;0 1 0];
F_shaft=[1:N;N+1:2*N;N+2:2*N N+1;2:N 1]';
F_shaft=reshape(F_shaft(:,[1 2 3 3 4 1])',3,[])';

V_handle=[-4/sqrt(2) -1/sqrt(2)/2 h;-4/sqrt(2) 1/sqrt(2)/2 h;1/sqrt(2)/2 -1/sqrt(2)/2 h;1/sqrt(2)/2 1/sqrt(2)/2 h;-4/sqrt(2) -1/sqrt(2)/2 h+2*r;-4/sqrt(2) 1/sqrt(2)/2 h+2*r;1/sqrt(2)/2 -1/sqrt(2)/2 h+2*r;1/sqrt(2)/2 1/sqrt(2)/2 h+2*r];
F_handle=[1 2 4 3;5 7 8 6;1 5 6 2;2 6 8 4;4 8 7 3;3 7 5 1];
V_handle=V_handle(F_handle',:);
F_handle=(1:4)+(0:5)'*4;
V_handle=V_handle*[0 0 1;1 0 0;0 1 0];
F_handle=reshape(F_handle(:,[1 2 3 3 4 1])',3,[])';

clear L M N dtheta h phi r t theta;

% Create the GLTF object.
gltf=GLTF();
% Add all the materials first.
mat(1)=gltf.addMaterial('baseColorFactor',[0.000 0.447 0.741 0.5]);
mat(2)=gltf.addMaterial('baseColorFactor',[0.466 0.674 0.188]);
mat(3)=gltf.addMaterial('baseColorFactor',[0.929 0.694 0.125]);
mat(4)=gltf.addMaterial('baseColorFactor',[0.635 0.078 0.184]);
% Add the tube mesh and corresponding node.
tube_mesh=gltf.addMesh(V_tube,'indices',F_tube,'material',mat(1),'normals',true);
tube_node=gltf.addNode('mesh',tube_mesh);
% We need an extra node, and we need to say how vertices depend on that
% node. This says that all vertices depend only on one node indexed 0 with
% weight 1.
j_ball=zeros(size(V_ball,1),4);                                 % Comment for non-skeletal animation
w_ball=[ones(size(V_ball,1),1) zeros(size(V_ball,1),3)];        % Comment for non-skeletal animation
% And similar for shaft and handle.
j_shaft=zeros(size(V_shaft,1),4);                               % Comment for non-skeletal animation
w_shaft=[ones(size(V_shaft,1),1) zeros(size(V_shaft,1),3)];     % Comment for non-skeletal animation
j_handle=zeros(size(V_handle,1),4);                             % Comment for non-skeletal animation
w_handle=[ones(size(V_handle,1),1) zeros(size(V_handle,1),3)];  % Comment for non-skeletal animation
% We need an inverse transformation matrix for that node (in this case,
% identity).
ibm=eye(4);  % Comment for non-skeletal animation
% Add the ball mesh.
% ball_mesh=gltf.addMesh(V_ball,'indices',F_ball,'material',mat(2),'normals',true);                                     % Uncomment for non-skeletal animation
ball_mesh=gltf.addMesh(V_ball,'indices',F_ball,'material',mat(2),'normals',true,'WEIGHTS',w_ball,'JOINTS',j_ball);  % Comment for non-skeletal animation
% We want the shaft and handle to be considered to be part of the same
% structure, but with different materials. We can do that by adding them as
% more primitives to the same mesh.
% gltf.addPrimitiveToMesh(ball_mesh,V_shaft,'indices',F_shaft,'material',mat(3),'normals',true);                                            % Uncomment for non-skeletal animation
% gltf.addPrimitiveToMesh(ball_mesh,V_handle,'indices',F_handle,'material',mat(4),'normals',true);                                          % Uncomment for non-skeletal animation
gltf.addPrimitiveToMesh(ball_mesh,V_shaft,'indices',F_shaft,'material',mat(3),'normals',true,'WEIGHTS',w_shaft,'JOINTS',j_shaft);       % Comment for non-skeletal animation
gltf.addPrimitiveToMesh(ball_mesh,V_handle,'indices',F_handle,'material',mat(4),'normals',true,'WEIGHTS',w_handle,'JOINTS',j_handle);   % Comment for non-skeletal animation
% Add the extra node and the skin (with the inverse bind matrix).
base_node=gltf.addNode();                 % Comment for non-skeletal animation
skin_idx=gltf.addSkin(base_node,'inverseBindMatrices',ibm); % Comment for non-skeletal animation
% Now add the node containing this compound mesh.
% ball_node=gltf.addNode('mesh',ball_mesh);                                     % Uncomment for non-skeletal animation
ball_node=gltf.addNode('mesh',ball_mesh,'skin',skin_idx);  % Comment for non-skeletal animation
% Create the array of times (in seconds).
t=0:4;
% Create the array of rotations.
q0=[0 0 0 1];
q90=[0 sin(90*pi/180/2) 0 cos(90*pi/180/2)];
q=[q0;q0;q90;q90;q0];
% Create input and output samplers (this tells OpenGL how to interpret the
% data).
inputSampler=gltf.addBinaryData(t,"FLOAT","SCALAR",true,"ARRAY_BUFFER");
outputSampler=gltf.addBinaryData(q,"FLOAT","VEC4",true,"ARRAY_BUFFER");
% Create the sampler (this tells OpenGL how to interpolate (default is
% linear)).
sampler=gltf.addAnimationSampler(inputSampler,outputSampler);
% Create the channel (this tells OpenGL which sampler to use, for which
% node, and what to animate).
% channel=gltf.addAnimationChannel(0,ball_node,"rotation"); % Uncomment for non-skeletal animation
channel=gltf.addAnimationChannel(0,base_node,"rotation");   % Comment for non-skeletal animation
% Add the animation specifying sampler and channels (each animation can
% have multiple of each).
gltf.addAnimation(sampler,channel);
% Write the GLTF file.
gltf.writeGLTF("ballvalve.gltf");
