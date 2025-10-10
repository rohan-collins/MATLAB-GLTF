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
% contour3 sample from MATLAB Documentation.
[X,Y]=meshgrid(-5:0.25:5);
Z=X.^2+Y.^2;
[M,s]=contour3(X,Y,Z,50);
ax=gca;
ax.XColor=ones(1,3);
ax.YColor=ones(1,3);
ax.ZColor=ones(1,3);
ax.GridColor=ones(1,3)/2;
ax.Color=zeros(1,3);
ax.GridAlpha=1;
grid on;
% Get the list of levels, we will pre-add the materials for each colour.
clist=s.LevelList;
% Default colours are given by the default colour map.
C=parula(numel(clist));

% Create the GLTF object.
gltf=GLTF();
% For each contour level
for i=1:numel(clist)
    % Add the material of the line color.
    mat(i)=gltf.addMaterial('baseColorFactor',C(i,:)); %#ok<SAGROW>
end
% The way the contour matrix is structured, we need to go through it
% contour-by-contour. Refer to CONTOUR3 for details.
while(size(M,2)>0)
    % Get the level of the contour. This is the first element of the
    % matrix.
    z=M(1,1);
    % Figure out the index of the material for the contour.
    [~,cidx]=ismember(z,clist);
    % Get the number of vertices in the contour. This is the second element
    % of the matrix.
    N=M(2,1);
    % Get the X and Y coordinates of the contour. These are given by the
    % subsequent N columns of the matrix.
    V=M(:,2:N+1)';
    % Use the level height as the
    % Z-coordinate.
    V=[V ones(N,1)*z]; %#ok<AGROW>
    % Scale vertices based on data aspect ratio and plot aspect ratio to
    % make the 3D Object look as much like the MATLAB plot as possible.
    V=V./daspect.*pbaspect;
    % Rotate the vertices since we are more used to Z-axis being "up" and
    % Y-axis being "back".
    V=V*[0 0 1;1 0 0;0 1 0];
    % Each edge is just one vertex, 1 through N-1, connected to the next
    % vertex, 2 through N.
    E=[1:N-1;2:N]';
    % Add the node with the vertices and edges as lines. Use the material
    % with the index determined above.
    gltf.addNode('mesh',gltf.addMesh(V,'indices',E,'mode',"LINES",'material',mat(cidx)));
    % Remove the used vertices from the contour matrix.
    M=M(:,N+2:end);
end
% Add axes as seen in the figure.
gltf=addAxes(gltf,'baseRotation',[0 0 1;1 0 0;0 1 0],'axisIds',["x00";"0y0";"01z"],'gridIds',["xy0";"x1z";"1yz";"xyz"],'backPlanes',["xy0";"x1z";"1yz"],'scaleFactor',7.5,'axis',s.Parent,'fontFile',"ARIALUNI_1.svg",'plotAspect',true,'dataAspect',true);
% Write the GLTF file.
gltf.writeGLTF("contour3.gltf");
