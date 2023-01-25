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
% mesh sample from MATLAB Documentation.
[X,Y]=meshgrid(-8:.5:8);
R=sqrt(X.^2 + Y.^2) + eps;
Z=sin(R)./R;
m=mesh(X,Y,Z);
ax=gca;
ax.XColor=ones(1,3);
ax.YColor=ones(1,3);
ax.ZColor=ones(1,3);
ax.GridColor=ones(1,3)/2;
ax.Color=zeros(1,3);
ax.GridAlpha=1;
grid on;
% Get the rectangular faces that MATLAB would use. We will use these to
% create edges.
[E,V]=surf2patch(X,Y,Z);
E=reshape(E(:,[1 2 2 3 3 4 4 1])',2,[])';
% Since the direction of the edge doesn't matter, we sort it so the
% lower-indexed vertex is first.
E=sort(E,2); %#ok<UDIM>
% This enables us to discard duplicate edges.
E=unique(E,'rows');
% Get the triangular faces. We will use this to prevent the mesh from being
% see-through by adding a double-sided black surface.
[F,~,~]=surf2patch(X,Y,Z,'triangles');
% The colours are based on the height, i.e., the Z value. So we first scale
% the Z value to be between 0 and 1.
C0=(V(:,3)-min(V(:,3)))./(max(V(:,3))-min(V(:,3)));
% Get the colourmap
cmap=colormap;
% And use interpolation to get the colour values per vertex.
C=interp1(linspace(0,1,size(cmap,1))',cmap,C0);
% Scale vertices based on data aspect ratio and plot aspect ratio to make
% the 3D Object look as much like the MATLAB plot as possible.
V=V./daspect.*pbaspect;
% Rotate the vertices since we are more used to Z-axis being "up" and
% Y-axis being "back".
V=V*[0 0 1;1 0 0;0 1 0];

% Create the GLTF object.
gltf=GLTF();
% Add a white material which will prevent the mesh from being see-through.
white_idx=gltf.addMaterial('baseColorFactor',ones(1,3),'doubleSided',true);
% Add a mesh with the vertices and faces. Use the black material.
mesh_idx=gltf.addMesh(V,'indices',F,'material',white_idx);
% Add a second primitive to the same mesh with vertices, edges, and
% colours. Use mode "LINES".
gltf.addPrimitiveToMesh(mesh_idx,V,'indices',E,'COLOR',C,'mode',"LINES");
% Instantiate the mesh in a node.
gltf.addNode('mesh',mesh_idx);
% Add axes as seen in the figure.
gltf=addAxes(gltf,'baseRotation',[0 0 1;1 0 0;0 1 0],'axisIds',["x00";"0y0";"01z"],'gridIds',["xy0","x1z","1yz"],'backPlanes',["xy0","x1z","1yz"],'scaleFactor',1,'axis',m.Parent,'fontFile',"ARIALUNI_1.svg",'plotAspect',true,'dataAspect',true);
% Write the GLTF file.
gltf.writeGLTF("mesh.gltf");
