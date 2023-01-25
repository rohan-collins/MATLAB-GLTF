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
% bar3 sample from MATLAB Documentation.
load count.dat
Z=count(1:10,:);
s=bar3(Z);
% Default colours are based on index using default colormap.
C=parula(size(Z,2));
ax=gca;
ax.XColor=ones(1,3);
ax.YColor=ones(1,3);
ax.ZColor=ones(1,3);
ax.GridColor=ones(1,3)/2;
ax.Color=zeros(1,3);
ax.GridAlpha=1;
grid on;

% Create the GLTF object.
gltf=GLTF();
% Get the edge colour.
edge_colour=s(1).EdgeColor;
% Add a common material for the edges.
edge_material=gltf.addMaterial('baseColorFactor',edge_colour);
% For each surface in the plot
for i=1:3
    % Get the faces, vertices, and the corresponding colours.
    [F,V]=surf2patch(s(i).XData,s(i).YData,s(i).ZData,'triangles');
    % V contains NaNs which are not used to display, however it makes GLTF
    % choke. We need to remove any vertex that has even a single NaN. So
    % first make an array where each element corresponds to a vertex, and
    % is true only if all coordinates of that vertex are non-NaNs.
    temp1=all(~isnan(V),2);
    % Only use the vertices that are non-NaN.
    V=V(temp1,:);
    % We now need to assign a new index to each non-NaN vertex. To do this,
    % first duplicate the boolean array as integer.
    temp2=uint16(temp1);
    % Then create an array of numbers from 1 to number of vertices and
    % assign these to only those elements that were originally true.
    temp2(temp1)=(1:nnz(temp1))';
    % Now renumber the faces using this array.
    Ftemp=temp2(F);
    % But some faces will have 0, if they referenced a NaN vertex. We need
    % to remove those faces where even one element is 0.
    F=Ftemp(~any(Ftemp==0,2),:);
    % Get the rectangular faces that MATLAB would use. We will use these to
    % create edges.
    [E,~]=surf2patch(s(i).XData,s(i).YData,s(i).ZData);
    % Create the list of edges. For example, for Face 1 2 3 4, edges are
    % 1-2, 2-3, 3-4, and 4-1.
    E=reshape(E(:,[1 2 2 3 3 4 4 1])',2,[])';
    % Now renumber the edges like we did the faces.
    Etemp=temp2(E);
    % And similarly remove those edges where even one element is 0.
    E2=Etemp(~any(Etemp==0,2),:);
    % Since the direction of the edge doesn't matter, we sort it so the
    % lower-indexed vertex is first.
    E2=sort(E2,2);
    % This enables us to discard duplicate edges.
    E2=unique(E2,'rows');
    % Scale vertices based on data aspect ratio make the 3D Object look as
    % much like the MATLAB plot as possible.
    V=V./daspect;
    % Rotate the vertices so that, as for bar plots in MATLAB, Y-axis is to
    % the right and X axis is to the back.
    V=V*[1 0 0;0 0 1;0 1 0];
    % Since the axis system is left handed, we need to flip the triangles
    % so that they face outwards again.
    F=F(:,[1 3 2]);
    % Add a material with the face colour.
    face_material(i)=gltf.addMaterial('baseColorFactor',C(i,:)); %#ok<SAGROW>
    % Add a mesh with the vertices, faces, and colours. Use the face colour
    % material.
    mesh_idx=gltf.addMesh(V,'indices',F,'material',face_material(i));
    % Add a second primitive to the same mesh with vertices and edges. Use
    % mode "LINES" and the edge colour material.
    gltf.addPrimitiveToMesh(mesh_idx,V,'indices',E2,'mode',"LINES",'material',edge_material);
    % Instantiate the mesh in a node.
    gltf.addNode('mesh',mesh_idx);
end
% Add axes as seen in the figure.
% gltf=addAxes(gltf,'baseRotation',[1 0 0;0 0 1;0 1 0],'axisIds',["x10";"0y0";"00z"],'scaleFactor',5,'axis',s(1).Parent,'fontFile',"ARIALUNI_1.svg",'plotAspect',false,'dataAspect',true);
gltf=addAxes(gltf,'baseRotation',[1 0 0;0 0 1;0 1 0],'axis',s(1).Parent,'axisIds',["x10";"0y0";"00z"],'gridIds',["xy0","x0z","1yz"],'backPlanes',["xy0","x0z","1yz"],'scaleFactor',5,'fontFile',"ARIALUNI_1.svg",'plotAspect',false,'dataAspect',true);
% Write the GLTF file.
gltf.writeGLTF("bar3.gltf");
