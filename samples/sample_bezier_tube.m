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
% Generate a bezier curve
points=[0 0 0;1 0 0;1 1 0;1 1 1];
[curve,first,second,third]=bezier(points');
curve=curve';
first=first';
second=second';
third=third';
% Generate the ribbon. Use Resolution 18 for a smooth tube.
[F,V,~,N]=tubeplot(curve,'Radius',0.05,'Resolution',18,'FirstDerivative',first,'SecondDerivative',second,'ThirdDerivative',third);
% Get the edges.
E=unique(sort(reshape(F(:,[1 2 2 3 3 1])',2,[]),1)','rows');

% Create the GLTF object.
gltf=GLTF();
% Add the mesh with faces, vertices, normals, and a new material.
mesh_idx=gltf.addMesh(V*[0 0 1;1 0 0;0 1 0],'indices',F,'NORMAL',N,'material',gltf.addMaterial('baseColorFactor',[0 1 0]));
% Instantiate the mesh in a new node.
gltf.addNode('mesh',mesh_idx);
% Duplicate the mesh to add edges.
gltf.meshes=repmat(gltf.meshes,2,1);
% Remove the normal field, it is unused for edges.
gltf.meshes{mesh_idx+2}.primitives{1}.attributes=rmfield(gltf.meshes{mesh_idx+2}.primitives{1}.attributes,'NORMAL');
% Add the edge indices as new binary data.
gltf.meshes{mesh_idx+2}.primitives{1}.indices=gltf.addBinaryData(reshape(E',[],1)-1,"UNSIGNED_INT","SCALAR",false,"ELEMENT_ARRAY_BUFFER");
% Set the mode to lines.
gltf.meshes{mesh_idx+2}.primitives{1}.mode=1;
% Use black material.
gltf.meshes{mesh_idx+2}.primitives{1}.material=gltf.addMaterial('baseColorFactor',zeros(1,3));
% Instantiate the mesh in a new node.
gltf.addNode('mesh',mesh_idx+1);
% Write the GLTF file.
gltf.writeGLTF("bezier_tube.gltf");
