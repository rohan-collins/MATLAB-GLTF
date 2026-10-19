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
% mesh sample from MATLAB Documentation.
[X,Y]=meshgrid(-8:.5:8);
R=sqrt(X.^2+Y.^2)+eps;
Z=sin(R)./R;
m=mesh(X,Y,Z);
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
% see-through by adding a double-sided white surface.
[F,~,~]=surf2patch(X,Y,Z,'triangles');
% Get the normals. This will make the white surface render smoothly.
[Nx,Ny,Nz]=surfnorm(X,Y,Z);
N=[Nx(:) Ny(:) Nz(:)];
% The colours are based on the height, i.e., the Z value. So we first scale
% the Z value to be between 0 and 1.
C0=(V(:,3)-min(V(:,3)))./(max(V(:,3))-min(V(:,3)));
% Get the colourmap
cmap=colormap;
% And use interpolation to get the colour values per vertex.
C=interp1(linspace(0,1,size(cmap,1))',cmap,C0);
% Scale vertices based on data aspect ratio and plot aspect ratio to make
% the 3D Object look as much like the MATLAB plot as possible.
[V,N]=gltf.utilities.transformForAxes(V,N,'axis',m.Parent);
% Rotate the transforms since we are more used to Z-axis being "up", X-axis
% being "right", and Y-axis being "back".
base_rot=[1 0 0;0 0 -1;0 1 0];
V=V*base_rot;
N=N*base_rot;

% Create the GLTF object.
obj=gltf.GLTF();
% Add a white material which will prevent the mesh from being see-through.
white_idx=obj.addMaterial('baseColorFactor',ones(1,3),'doubleSided',true);
% Add a mesh with the vertices and faces. Use the black material.
mesh_idx=obj.addMesh(V,'indices',F,'NORMAL',N,'material',white_idx);
% Add a second primitive to the same mesh with vertices, edges, and
% colours. Use mode "LINES".
obj.addPrimitiveToMesh(mesh_idx,V,'indices',E,'COLOR',C,'mode',"LINES");
% Instantiate the mesh in a node.
obj.addNode('mesh',mesh_idx);
% Add axes as seen in the figure.
obj=gltf.utilities.addAxes(obj,'baseRotation',base_rot,'axisIds',["x00";"0y0";"01z"],'gridIds',["xy0","x1z","1yz"],'backPlanes',["xy0","x1z","1yz"],'axis',m.Parent,'fontFile',"ARIALUNI_1.svg");
% Write the GLTF file.
obj.writeGLTF("mesh.gltf");
