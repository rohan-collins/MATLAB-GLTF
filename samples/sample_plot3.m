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
% plot3 sample from MATLAB Documentation.
t=linspace(-10,10,1000);
xt=exp(-t./10).*sin(5*t);
yt=exp(-t./10).*cos(5*t);
p=plot3(xt,yt,t);
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
% Save vertices as 3 column matrix of X, Y, and Z.
V=[xt;yt;t]';
% Scale vertices based on data aspect ratio and plot aspect ratio to make
% the 3D Object look as much like the MATLAB plot as possible.
V=gltf.utilities.transformForAxes(V,'axis',p.Parent);
% Rotate the transforms since we are more used to Z-axis being "up", X-axis
% being "right", and Y-axis being "back".
base_rot=[1 0 0;0 0 -1;0 1 0];
V=V*base_rot;
% Each edge is just one vertex, 1 through N-1, connected to the next
% vertex, 2 through N.
E=[1:size(xt,2)-1;2:size(xt,2)]';
% Get the colour of the line.
C=p.Color;

% Create the GLTF object.
obj=gltf.GLTF();
% Add the material of the line color.
material_idx=obj.addMaterial('baseColorFactor',C);
% Add a mesh with the vertices and edges. Use mode "LINES" and material.
mesh_idx=obj.addMesh(V,'indices',E,'mode',"LINES",'material',material_idx);
% Instantiate the mesh in a node
obj.addNode('mesh',mesh_idx);
% Add axes as seen in the figure.
obj=gltf.utilities.addAxes(obj,'baseRotation',base_rot,'axisIds',["x00";"0y0";"01z"],'gridIds',["xy0","x1z","1yz"],'backPlanes',["xy0","x1z","1yz"],'axis',p.Parent,'fontFile',"ARIALUNI_1.svg");
% Write the GLTF file.
obj.writeGLTF("plot3.gltf");
