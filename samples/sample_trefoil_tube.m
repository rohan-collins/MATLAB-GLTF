% © Copyright 2014-2024 Rohan Chabukswar.
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
% Generate trefoil curve.
dtheta=1;
t=(0:dtheta:360)'*pi/180;
curve =[ sin(t)- 2*sin(2*t)  cos(t)+ 2*cos(2*t)    -sin(3*t)];
first =[ cos(t)- 4*cos(2*t) -sin(t)- 4*sin(2*t)  -3*cos(3*t)]*dtheta*pi/180;
second=[-sin(t)+ 8*sin(2*t) -cos(t)- 8*cos(2*t)   9*sin(3*t)]*(dtheta*pi/180)^2;
third =[-cos(t)+16*cos(2*t)  sin(t)+16*sin(2*t)  27*cos(3*t)]*(dtheta*pi/180)^3;
% Generate the ribbon. Use Resolution 36 for a smooth tube.
R=0.607154708718215;
[F,V,~,N]=tubeplot(curve,'Radius',R,'Resolution',36,'FirstDerivative',first,'SecondDerivative',second,'ThirdDerivative',third,'Ends',false);
% Create the GLTF object.
gltf=GLTF();
% Add the mesh with faces, vertices, normals, and a new material.
gltf.addNode('mesh',gltf.addMesh(V*[0 0 1;1 0 0;0 1 0],'indices',F,'NORMAL',N*[0 0 1;1 0 0;0 1 0],'material',gltf.addMaterial('baseColorFactor',[0 0 1])));
% Write the GLTF file.
gltf.writeGLTF("trefoil_tube.gltf");
