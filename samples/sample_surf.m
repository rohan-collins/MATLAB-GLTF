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
% surf sample from MATLAB Documentation.
[X,Y,Z]=peaks(25);
CO(:,:,1)=zeros(25);
CO(:,:,2)=ones(25).*linspace(0.5,0.6,25); 
CO(:,:,3)=ones(25).*linspace(0,1,25);
s=surf(X,Y,Z,CO);
ax=gca;
ax.XColor=ones(1,3);
ax.YColor=ones(1,3);
ax.ZColor=ones(1,3);
ax.GridColor=ones(1,3)/2;
ax.Color=zeros(1,3);
ax.GridAlpha=1;
grid on;

% Get the faces, vertices, and the corresponding colours.
% Use triangles as GLTF only supports triangular faces.
[F,V,C]=surf2patch(X,Y,Z,CO,'triangles');
% Get the rectangular faces that MATLAB would use. We will use these to
% create edges.
[E,~]=surf2patch(X,Y,Z);
% Create the list of edges. For example, for Face 1 2 3 4, edges are 1-2,
% 2-3, 3-4, and 4-1.
E=reshape(E(:,[1 2 2 3 3 4 4 1])',2,[])';
% Since the direction of the edge doesn't matter, we sort it so the
% lower-indexed vertex is first.
E=sort(E,2); %#ok<UDIM>
% This enables us to discard duplicate edges.
E=unique(E,'rows');
% Scale vertices based on data aspect ratio and plot aspect ratio to make
% the 3D Object look as much like the MATLAB plot as possible.
V=V./daspect.*pbaspect;
% Rotate the vertices since we are more used to Z-axis being "up" and
% Y-axis being "back".
V=V*[0 0 1;1 0 0;0 1 0];

% Create the GLTF object.
gltf=GLTF();
% Add a white material which will act as the "base coat" over which the
% vertex colours will be painted. There is no real need to do this, except
% that we want the material to be visible from both sides.
white_idx=gltf.addMaterial('baseColorFactor',ones(1,3),'doubleSided',true);
% Add a mesh with the vertices, faces, and colours. Use the white material.
mesh_idx=gltf.addMesh(V,'indices',F,'COLOR',C,'material',white_idx);
% Get the edge colour.
C=s.EdgeColor;
% Add the material which we will use to display edges.
edge_colour_idx=gltf.addMaterial('baseColorFactor',C);
% Add a second primitive to the same mesh with vertices and edges. Use mode
% "LINES" and the edge colour material.
gltf.addPrimitiveToMesh(mesh_idx,V,'indices',E,'mode',"LINES",'material',edge_colour_idx);
% Instantiate the mesh in a node.
gltf.addNode('mesh',mesh_idx);
% Add axes as seen in the figure.
gltf=addAxes(gltf,'baseRotation',[0 0 1;1 0 0;0 1 0],'axisIds',["x00";"0y0";"01z"],'gridIds',["xy0","x1z","1yz"],'backPlanes',["xy0","x1z","1yz"],'scaleFactor',7.5,'axis',s.Parent,'fontFile',"ARIALUNI_1.svg",'plotAspect',true,'dataAspect',true);
% Write the GLTF file.
gltf.writeGLTF("surf.gltf");
