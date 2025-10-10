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
% stem3 sample from MATLAB Documentation.
X=linspace(-5,5,60);
Y=cos(X);
Z=X.^2;
s=stem3(X,Y,Z);
ax=gca;
ax.XColor=ones(1,3);
ax.YColor=ones(1,3);
ax.ZColor=ones(1,3);
ax.GridColor=ones(1,3)/2;
ax.Color=zeros(1,3);
ax.GridAlpha=1;
grid on;

% Generate a sphere to use for each point.
[F,V]=sphere3d('Resolution',5);
% Get the color of the plot
C=s.Color;
% Calculate the position of each point in the plot
T=[X;Y;Z]';
% Scale positions based on data aspect ratio and plot aspect ratio to make
% the 3D Object look as much like the MATLAB plot as possible.
T=T./daspect.*pbaspect;
% Rotate the positions since we are more used to Z-axis being "up" and
% Y-axis being "back".
T=T*[0 0 1;1 0 0;0 1 0];

% Create the GLTF object.
gltf=GLTF();
% Add the material of the line color.
material_idx=gltf.addMaterial('baseColorFactor',C);
% Add a mesh with the vertices and faces.
mesh_idx=gltf.addMesh(V,'indices',F,'material',material_idx);
% For each point in the plot.
for i=1:numel(Z)
    % Instantiate the mesh in a node with the translation.
    gltf.addNode('mesh',mesh_idx,'translation',T(i,:),'scale',0.03*ones(1,3));
    % To draw the stem, we need a line from the XZ plane to the point.
    % First duplicate the vertex.
    Vstem=repmat(T(i,:),2,1);
    % Then set the Y-coordinate of the first vertex to 0. This gives us the
    % closest point on the XZ-plane.
    Vstem(1,2)=0;
    % Edge is always from first to second point. Add the node with the new
    % mesh. Use the same material.
    gltf.addNode('mesh',gltf.addMesh(Vstem,'mode',"LINES",'material',material_idx));
end
% Add axes as seen in the figure.
gltf=addAxes(gltf,'baseRotation',[0 0 1;1 0 0;0 1 0],'axisIds',["x00";"0y0";"01z"],'gridIds',["xy0","x1z","1yz"],'backPlanes',["xy0","x1z","1yz"],'scaleFactor',1.5,'axis',s.Parent,'fontFile',"ARIALUNI_1.svg",'plotAspect',true,'dataAspect',true);
% Write the GLTF file.
gltf.writeGLTF("stem3.gltf");
