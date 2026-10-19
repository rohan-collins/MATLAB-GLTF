% © Copyright 2014-2026 Rohan Chabukswar.
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
daspect(daspect);
pbaspect(pbaspect);
xlabel("X");
ylabel("Y");
zlabel("Z");
ax=gca;
ax.XColor=ones(1,3);
ax.YColor=ones(1,3);
ax.ZColor=ones(1,3);
ax.GridColor=ones(1,3)/2;
ax.Color=zeros(1,3);
ax.GridAlpha=1;
grid on;

% Generate a sphere to use for each point.
[F,V]=gltf.utilities.sphere3d('Resolution',5);
% Get the color of the plot
C=s.CData;
% Calculate the position of each point in the plot
T=[x;y;z]';
% Scale positions based on data aspect ratio and plot aspect ratio to make
% the 3D Object look as much like the MATLAB plot as possible.
T=gltf.utilities.transformForAxes(T,'axis',s.Parent);
% Rotate the transforms since we are more used to Z-axis being "up", X-axis
% being "right", and Y-axis being "back".
base_rot=[1 0 0;0 0 -1;0 1 0];
T=T*base_rot;
if(isscalar(s.SizeData))
    S=repmat(s.SizeData/36*0.01,size(T));
else
    S=repmat(reshape(s.SizeData,[],1)/36*0.01,1,3);
end

% Create the GLTF object.
obj=gltf.GLTF();
% Add the material of the line color.
material_idx=obj.addMaterial('baseColorFactor',C);
% Add a mesh with the vertices and faces.
mesh_idx=obj.addMesh(V,'indices',F,'material',material_idx);
% For each point in the plot.
% Use EXT_mesh_gpu_instancing to instantiate multiple copies of the
% spheres. We could add one node per sphere, but that increases the file
% size (due to requiring translation and rotation matrices to be specified
% in text per node. It also improves rendering efficiency.
obj.addNode('mesh',mesh_idx,'instancingTranslation',T,'instancingScale',S);
% Add axes as seen in the figure.
obj=gltf.utilities.addAxes(obj,'baseRotation',base_rot,'axisIds',["x00";"0y0";"01z"],'gridIds',["xy0","x1z","1yz"],'backPlanes',["xy0","x1z","1yz"],'axis',s.Parent,'fontFile',"ARIALUNI_1.svg");
% Write the GLTF file.
obj.writeGLTF("scatter3.gltf");
