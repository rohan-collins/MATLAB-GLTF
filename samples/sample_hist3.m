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
% hist3 sample from MATLAB Documentation.
load carbig;
X=[MPG,Weight];
hist3(X,{0:10:50 2000:500:5000},'CDataMode','auto','FaceColor','interp');
xlabel('MPG');
ylabel('Weight');
ax=gca;
ax.XColor=ones(1,3);
ax.YColor=ones(1,3);
ax.ZColor=ones(1,3);
ax.GridColor=ones(1,3)/2;
ax.Color=zeros(1,3);
ax.GridAlpha=1;
grid on;

% We will need to construct the vertices for each bar ourselves. For this,
% get the arrays of X and Y as bin centres in the respective dimension, and
% the height of each bar.
[N,c]=hist3(X,{0:10:50 2000:500:5000});
% We will need the X and Y widths as well.
binWidth=cellfun(@(x) mean(diff(x)),c);

% To get vertices of each bar, we start with a cube, then move it in X and
% Y dimensions appropriately, and scale it in the Z dimension.

% These are the vertices.
V_cube=[0 0 0;1 0 0;1 1 0;0 1 0;0 0 1;1 0 1;1 1 1;0 1 1]-[0.5 0.5 0];
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

% Set minimum height
N(N==min(N,[],'all'))=(max(N,[],'all')-min(N,[],'all'))*1e-4+min(N,[],'all');
% Initialise colour map
Cmap=parula(256);
% We initialise the full set of vertices, and their colours.
V=nan(numel(N)*size(V_cube,1),3);
C=nan(numel(N)*size(V_cube,1),3);
% Keep a count of the bars handled
idx=0;
% Loop over first index
for i=1:size(N,1)
    % Loop over second index
    for j=1:size(N,2)
        % Increment the count of bars handled.
        idx=idx+1;
        % Set the section of V for this bar by scaling and translating
        % the cube.
        V((idx-1)*size(V_cube,1)+(1:size(V_cube,1)),:)=V_cube.*[binWidth N(i,j)]+[c{1}(i) c{2}(j) 0];
        C((idx-1)*size(V_cube,1)+(1:size(V_cube,1)),:)=(V_cube(:,3)>0).*interp1(linspace(0,1,size(Cmap,1)),Cmap,(N(i,j)-min(N,[],'all'))./(max(N,[],'all')-min(N,[],'all')))+(V_cube(:,3)<=0).*Cmap(1,:);
    end
end

% For all faces, we need to duplicate the cube faces for every bar, but
% offset the indices by the number of vertices of the previous bars
F=reshape(F_cube'+permute(0:numel(N)-1,[1 3 2])*size(V_cube,1),size(F_cube,2),size(F_cube,1)*numel(N))';
% Same for edges
E=reshape(E_cube'+permute(0:numel(N)-1,[1 3 2])*size(V_cube,1),size(E_cube,2),size(E_cube,1)*numel(N))';

% We are duplicating a lot of vertices, especially the ones on the bottom
% of adjoining bars. We can reuse them by considering only unique vertices.
[V,ia,ic]=uniquetol(V,'ByRows',true);
% Of course, we need to only choose the corresponding colours.
C=C(ia,:);
% And we need to renumber the indices in faces.
F=ic(F);
% As well as in edges.
E=ic(E);

% Choose only non-degenerate faces.
F=F(vecnorm(cross(V(F(:,3),:)-V(F(:,2),:),V(F(:,1),:)-V(F(:,2),:),2),2,2)>0,:);
% Choose only non-degenerate edges.
E=E(vecnorm(V(E(:,2),:)-V(E(:,1),:),2,2)>0,:);

% Scale vertices based on data aspect ratio and plot aspect ratio to make
% the 3D Object look as much like the MATLAB plot as possible.
V=V./daspect.*pbaspect;
% Rotate the vertices since we are more used to Z-axis being "up" and
% Y-axis being "back".
V=V*[0 0 1;1 0 0;0 1 0];

% Get the base colour for the bars.
C1=ones(1,3);
% Get the default colour for the edges.
C2=zeros(1,3);

% Create the GLTF object.
gltf=GLTF();
% Add the material for the face colour.
face_idx=gltf.addMaterial('baseColorFactor',C1);
% Add the material for the edge colour.
edge_idx=gltf.addMaterial('baseColorFactor',C2);
% Add the mesh with faces, vertices, and the face material.
mesh_idx=gltf.addMesh(V,'indices',F,'COLOR',C,'material',face_idx);
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
gltf=addAxes(gltf,'baseRotation',[0 0 1;1 0 0;0 1 0],'axis',ax,'axisIds',["x00";"0y0";"01z"],'gridIds',["xy0","x1z","1yz"],'backPlanes',["xy0","x1z","1yz"],'scaleFactor',50,'fontFile',"ARIALUNI_1.svg",'plotAspect',true,'dataAspect',true);
% Write the GLTF file.
gltf.writeGLTF("hist3.gltf");
