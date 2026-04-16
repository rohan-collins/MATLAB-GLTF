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
% Generate a bezier curve
points=[0 0 0;1 0 0;1 1 0;1 1 1];
[curve,first,second,third]=gltf.utilities.bezier(points');
curve=curve';
first=first';
second=second';
third=third';
% Generate the ribbon. Use Resolution 18 for a smooth tube.
[F,V,~,N]=gltf.utilities.tubeplot(curve,'Radius',0.05,'Resolution',18,'FirstDerivative',first,'SecondDerivative',second,'ThirdDerivative',third);
% Get the edges.
E=unique(sort(reshape(F(:,[1 2 2 3 3 1])',2,[]),1)','rows');

% Create the GLTF object.
obj=gltf.GLTF();
% Add the mesh with faces, vertices, normals, and a new material.
mesh_idx=obj.addMesh(V*[0 0 1;1 0 0;0 1 0],'indices',F,'NORMAL',N,'material',obj.addMaterial('baseColorFactor',[0 1 0]));
% Instantiate the mesh in a new node.
obj.addNode('mesh',mesh_idx);
% Duplicate the mesh to add edges.
obj.meshes=repmat(obj.meshes,2,1);
% Remove the normal field, it is unused for edges.
obj.meshes{mesh_idx+2}.primitives{1}.attributes=rmfield(obj.meshes{mesh_idx+2}.primitives{1}.attributes,'NORMAL');
% Add the edge indices as new binary data.
obj.meshes{mesh_idx+2}.primitives{1}.indices=obj.addBinaryData(reshape(E',[],1)-1,"UNSIGNED_INT","SCALAR",false,"ELEMENT_ARRAY_BUFFER");
% Set the mode to lines.
obj.meshes{mesh_idx+2}.primitives{1}.mode=1;
% Use black material.
obj.meshes{mesh_idx+2}.primitives{1}.material=obj.addMaterial('baseColorFactor',zeros(1,3));
% Instantiate the mesh in a new node.
obj.addNode('mesh',mesh_idx+1);
% Write the GLTF file.
obj.writeGLTF("bezier_tube.gltf");
