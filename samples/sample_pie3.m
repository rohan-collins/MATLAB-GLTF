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
% pie3 sample from MATLAB Documentation.
x=[1,3,0.5,2.5,2];
explode=[0,1,0,0,0];
s=pie3(x,explode);
% Default colours are based on index using default colormap.
C=parula(numel(x));

% Create the GLTF object.
gltf=GLTF();
% Add the material for the edge colour.
edge_idx=gltf.addMaterial('baseColorFactor',s(1).EdgeColor);
% Add the material for the text colour.
text_idx=gltf.addMaterial('baseColorFactor',ones(1,3));
% Read fonts
fontFile=readFontFile("ARIALUNI_1.svg");
for i=1:numel(x)
    % Each slice of pie generates 4 objects. The first and third are patch
    % objects that have all the vertices we need. The second is a surface
    % plot of the side, and the fourth is a text object. We don't need to
    % use the former, and can't use the latter.
    p1=(i-1)*4+1;
    p2=(i-1)*4+3;
    % Get the number of vertices. The patch objects duplicate the tip
    % vertex as the first and last vertices, so we can disregard one of
    % them.
    N=size(s(p1).Vertices,1)-1;
    % Collect the two sets of vertices.
    V=[s(p1).Vertices(1:N,:);s(p2).Vertices(1:N,:)];
    % Rotate the vertices since we are more used to Z-axis being "up" and
    % Y-axis being "back".
    V=V*[0 0 1;1 0 0;0 1 0];
    % Generate the top and bottom triangles. We do this by taking the tip
    % (vertex 1) and sets of consecutive vertices. Repeat this for the
    % bottom, but change the order (to have the face normal point
    % outwards), and of course offset the vertex numbers by N.
    F1=[[ones(1,N-2);3:N;2:N-1]';[ones(1,N-2);2:N-1;3:N]'+N];
    % Generate the side as rectangles (for now). For this, we take sets of
    % consecutive vertices from the bottom face, and the corresponding
    % vertices from the top face.
    F2=[1:N;2:N 1;N+2:2*N N+1;N+1:2*N]';
    % Generate the edges. Note that we are only using 3 of the 4 edges of
    % each rectangle to prevent duplication.
    E=reshape(F2(:,[1 2 3 4 4 1])',2,3*N)';
    % Now convert the rectangles to triangles, and append the top and
    % bottom trianges.
    F=[F1;reshape(F2(:,[1 2 3 3 4 1])',3,2*N)'];
    % Add the material for the face colour.
    face_idx=gltf.addMaterial('baseColorFactor',C(i,:));
    % Add the mesh with faces, vertices, and the face material.
    mesh_idx=gltf.addMesh(V,'indices',F,'material',face_idx);
    % Our edges use the same faces as the other mesh. This is a good
    % opportunity to reuse the same data. To do this, we first duplicate
    % the mesh primitive.
    gltf.meshes{mesh_idx+1}.primitives=repmat(gltf.meshes{mesh_idx+1}.primitives,1,2);
    % Our indices have to be a list in column-major order.
    Etemp=reshape(E',[],1);
    % In GLTF, indices are zero-based.
    Etemp=Etemp-1;
    % We add the indices as a new binary data. Indices are "UNSIGNED_INT"s
    % and "SCALAR"s, and we don't need a minimum and maximum.
    edge_indices=gltf.addBinaryData(Etemp,"UNSIGNED_INT","SCALAR",false,"ELEMENT_ARRAY_BUFFER");
    % We set the indices accessor for the second primitive to be the one we
    % just added.
    gltf.meshes{mesh_idx+1}.primitives{2}.indices=edge_indices;
    % And add the mode to be "LINES", enumerated as 1 in GLTF or OpenGL.
    gltf.meshes{mesh_idx+1}.primitives{2}.mode=1;
    % Change the material to the edge material.
    gltf.meshes{mesh_idx+1}.primitives{2}.material=edge_idx;
    % Instantiate the mesh in a node.
    gltf.addNode('mesh',mesh_idx);
    % Find the midpoint of the sector
    v1=(s(p2).Vertices(2,:)-s(p2).Vertices(1,:)+s(p2).Vertices(N,:)-s(p2).Vertices(1,:))/2;
    % Get corresponding angle from -Y-axis
    theta=atan2(v1(1),-v1(2));
    % Convert that to rotation around 3D Y-axis
    q=[0 sin(theta/2) 0 cos(theta/2)];
    % Get the index of the text object
    p3=(i-1)*4+4;
    % Convert the text string to mesh
    [Ft,Vt]=text2FV(string(s(p3).String),fontFile);
    % Scale it so that the text height is 0.1 (times the pie radius, which
    % is always 1).
    Vt=Vt/(max(Vt(:,2))-min(Vt(:,2)))*0.1;
    % Centre the mesh to (0,0,0).
    Vt=Vt-(max(Vt)+min(Vt))/2;
    % Get how far the slice has exploded
    expl=norm(s(p2).Vertices(1,1:2));
    % Get the height of the pie slice
    z=s(p2).Vertices(1,3);
    % Move the mesh down Y-axis to 75% of pie radius (always 1), plus the
    % explosion distance. At the same time, move the mesh to the top of the
    % pie slice, plus a bit extra so that the top surface of the pie
    % doesn't interfere with the text.
    Vt=Vt+[0 -0.75-expl z+1e-3];
    % Rotate the vertices since we are more used to Z-axis being "up" and
    % Y-axis being "back".
    Vt=Vt*[0 0 1;1 0 0;0 1 0];
    % Add as a new mesh as a new node, with text material, and the rotation
    % previously calculated.
    gltf.addNode('mesh',gltf.addMesh(Vt,'indices',Ft,'material',text_idx),'rotation',q);
end
% Write the GLTF file.
gltf.writeGLTF("pie3.gltf");
