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
% Generate Rubik cube mesh
% Vertices
V=[1 -1 -1;1 -1 1;1 1 1;1 -1 1;-1 -1 1;-1 1 1;-1 -1 1;1 -1 1;1 -1 -1;-1 -1 -1;-1 1 -1;-1 -1 -1;1 -1 -1;1 1 -1];
% Faces
F=[1 3 2;3 1 14;3 5 4;5 3 6;11 7 6;7 11 10;9 7 10;7 9 8;11 13 12;13 11 14;11 3 14;3 11 6];
% Texture coordinates
UV=[0 1;0 2;1 2;1 3;2 3;2 2;3 2;4 2;4 1;3 1;2 1;2 0;1 0;1 1]./4;

% Create the GLTF object.
gltf=GLTF();
% Add the material using the texture image.
material_idx=gltf.addMaterial('baseColorTexture',"rubik.png");
% Add the mesh with faces, vertices, texture coordinates, and the texture
% material.
mesh_idx=gltf.addMesh(V,'indices',F,'TEXCOORD',UV,'material',material_idx,'flatShading',true);
% Instantiate the mesh in a node.
gltf.addNode('mesh',mesh_idx);
% Write the GLTF file.
gltf.writeGLTF("rubik.gltf");
