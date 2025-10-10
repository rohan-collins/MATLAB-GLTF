% © Copyright 2014-2025 Rohan Chabukswar.
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
% scatter3 sample from MATLAB Documentation.
z=linspace(0,4*pi,250);
x=2*cos(z)+rand(1,250);
y=2*sin(z)+rand(1,250);
s=scatter3(x,y,z,'filled');
ax=gca;
ax.XColor=ones(1,3);
ax.YColor=ones(1,3);
ax.ZColor=ones(1,3);
ax.GridColor=ones(1,3)/2;
ax.Color=zeros(1,3);
ax.GridAlpha=1;
grid on;

% Generate a sphere to use for each point.
[F,V]=sphere3d('Resolution',5);
% Scale the spheres
V=0.05*V;
% Get the color of the plot
C=s.CData;
% Calculate the position of each point in the plot
T=[x;y;z]';
% Scale positions based on data aspect ratio and plot aspect ratio to make
% the 3D Object look as much like the MATLAB plot as possible.
T=T./daspect.*pbaspect;
% Rotate the positions since we are more used to Z-axis being "up" and
% Y-axis being "back".
T=T*[0 0 1;1 0 0;0 1 0];

% Create the GLTF object.
gltf=GLTF();
% Add the material of the line color.
material_idx=gltf.addMaterial('baseColorFactor',C);
% Add a mesh with the vertices and faces.
mesh_idx=gltf.addMesh(V,'indices',F,'material',material_idx);
% For each point in the plot.
% Use EXT_mesh_gpu_instancing to instantiate multiple copies of the
% spheres. We could add one node per sphere, but that increases the file
% size (due to requiring translation and rotation matrices to be specified
% in text per node. It also improves rendering efficiency.
gltf.addNode('mesh',mesh_idx,'instancingTranslation',T);
% Add axes as seen in the figure.
gltf=addAxes(gltf,'baseRotation',[0 0 1;1 0 0;0 1 0],'axisIds',["x00";"0y0";"01z"],'gridIds',["xy0","x1z","1yz"],'backPlanes',["xy0","x1z","1yz"],'scaleFactor',5,'axis',s.Parent,'fontFile',"ARIALUNI_1.svg",'plotAspect',true,'dataAspect',true);
% Write the GLTF file.
gltf.writeGLTF("scatter3.gltf");
