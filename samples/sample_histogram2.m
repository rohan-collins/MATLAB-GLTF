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
% histogram2 sample from MATLAB Documentation.
x=randn(10000,1);
y=randn(10000,1);
h=histogram2(x,y);
% We will need to construct the vertices for each bar ourselves. For this,
% get the arrays of X and Y.
X=h.XBinEdges;
Y=h.YBinEdges;
% And the height of each bar.
Z=h.BinCounts;
% We will need the X and Y widths as well.
binWidth=h.BinWidth;
ax=gca;
ax.XColor=ones(1,3);
ax.YColor=ones(1,3);
ax.ZColor=ones(1,3);
ax.GridColor=ones(1,3)/2;
ax.Color=zeros(1,3);
ax.GridAlpha=1;
grid on;

% To get vertices of each bar, we start with a cube, then move it in X and
% Y dimensions appropriately, and scale it in the Z dimension.

% These are the vertices.
V_cube=[0 0 0;1 0 0;1 1 0;0 1 0;0 0 1;1 0 1;1 1 1;0 1 1];
% And the square faces.
F_cube=[1 4 3 2;1 2 6 5;2 3 7 6;3 4 8 7;4 1 5 8;5 6 7 8];
% Duplicate vertices for flat shading.
V_cube=V_cube(F_cube',:);
F_cube=reshape(1:numel(F_cube),size(F_cube,2),[])';
% We get collect the edges of each face.
E_cube=reshape(F_cube(:,[1 2 2 3 3 4 4 1])',2,[])';
% Since the direction of the edge doesn't matter, we sort it so the
% lower-indexed vertex is first.
E_cube=sort(E_cube,2); %#ok<UDIM>
% This enables us to discard duplicate edges.
E_cube=unique(E_cube,'rows');
% Now we divide each square face into triangles.
F_cube=reshape(F_cube(:,[1 2 3 3 4 1])',3,[])';

% We initialise the full set of vertices. Since we won't be showing the
% bars with zero count, we only consider non-zero elements of Z.
V=nan(nnz(Z)*size(V_cube,1),3);
% Keep a count of the bars handled
idx=0;
% Loop over first index
for i=1:size(Z,1)
    % Loop over second index
    for j=1:size(Z,2)
        % Since we are not showing empty bins, only proceed if Z(i,j) is
        % non-zero
        if(Z(i,j)>0)
            % Increment the count of bars handled.
            idx=idx+1;
            % Set the section of V for this bar by scaling and translating
            % the cube.
            V((idx-1)*size(V_cube,1)+(1:size(V_cube,1)),:)=V_cube.*[binWidth Z(i,j)]+[X(i) Y(j) 0];
        end
    end
end

% For all faces, we need to duplicate the cube faces for every bar, but
% offset the indices by the number of vertices of the previous bars
F=reshape(F_cube'+permute(0:nnz(Z)-1,[1 3 2])*size(V_cube,1),size(F_cube,2),size(F_cube,1)*nnz(Z))';
% Same for edges
E=reshape(E_cube'+permute(0:nnz(Z)-1,[1 3 2])*size(V_cube,1),size(E_cube,2),size(E_cube,1)*nnz(Z))';

% We are duplicating a lot of vertices, especially the ones on the bottom
% of adjoining bars. We can reuse them by considering only unique vertices.
[V,~,ic]=uniquetol(V,'ByRows',true);
% Of course, we need to renumber the indices in faces.
F=ic(F);
% As well as in edges.
E=ic(E);

% Scale vertices based on data aspect ratio and plot aspect ratio to make
% the 3D Object look as much like the MATLAB plot as possible.
V=V./daspect.*pbaspect;
% Rotate the vertices since we are more used to Z-axis being "up" and
% Y-axis being "back".
V=V*[0 0 1;1 0 0;0 1 0];

% Get the default colour for the bars.
C1=lines(1);
% Get the default colour for the edges.
C2=h.EdgeColor;

% Create the GLTF object.
gltf=GLTF();
% Add the material for the face colour.
face_idx=gltf.addMaterial('baseColorFactor',C1);
% Add the material for the edge colour.
edge_idx=gltf.addMaterial('baseColorFactor',C2);
% Add the mesh with faces, vertices, and the face material.
mesh_idx=gltf.addMesh(V,'indices',F,'material',face_idx);
% Our edges use the same faces as the other mesh. This is a good
% opportunity to reuse the same data. To do this, we first duplicate the
% mesh primitive.
gltf.meshes{mesh_idx+1}.primitives=repmat(gltf.meshes{mesh_idx+1}.primitives,1,2);
% Our indices have to be a list in column-major order.
Etemp=reshape(E',[],1);
% In GLTF, indices are zero-based.
Etemp=Etemp-1;
% We add the indices as a new binary data. Indices are "UNSIGNED_INT"s and
% "SCALAR"s, and we don't need a minimum and maximum.
edge_indices=gltf.addBinaryData(Etemp,"UNSIGNED_INT","SCALAR",false,"ELEMENT_ARRAY_BUFFER");
% We set the indices accessor for the second primitive to be the one we
% just added.
gltf.meshes{mesh_idx+1}.primitives{2}.indices=edge_indices;
% And add the mode to be "LINES", enumerated as 1 in GLTF or OpenGL.
gltf.meshes{mesh_idx+1}.primitives{2}.mode=1;
% Change the material to edge colour.
gltf.meshes{mesh_idx+1}.primitives{2}.material=edge_idx;
% Instantiate the mesh in a node.
gltf.addNode('mesh',mesh_idx);
% Add axes as seen in the figure.
gltf=addAxes(gltf,'baseRotation',[0 0 1;1 0 0;0 1 0],'axisIds',["x00";"0y0";"01z"],'gridIds',["xy0","x1z","1yz"],'backPlanes',["xy0","x1z","1yz"],'scaleFactor',5,'axis',h.Parent,'fontFile',"ARIALUNI_1.svg",'plotAspect',true,'dataAspect',true);
% Write the GLTF file.
gltf.writeGLTF("histogram2.gltf");
