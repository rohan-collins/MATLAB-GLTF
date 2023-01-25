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
% quiver3 sample from MATLAB Documentation.
x=-3:0.5:3;
y=-3:0.5:3;
[X,Y]=meshgrid(x,y);
Z=Y.^2-X.^2;
[U,V,W]=surfnorm(Z);
s=quiver3(Z,U,V,W);
ax=gca;
ax.XColor=ones(1,3);
ax.YColor=ones(1,3);
ax.ZColor=ones(1,3);
ax.GridColor=ones(1,3)/2;
ax.Color=zeros(1,3);
ax.GridAlpha=1;
grid on;

% Get the X and Y data from the plot, since we didn't use it as input.
x=s.XData;
y=s.YData;
% Construct the mesh points.
[X,Y]=meshgrid(x,y);

% Create the GLTF object.
gltf=GLTF();
% Add the material of the line color.
material_idx=gltf.addMaterial('baseColorFactor',s.Color);
% We will create a single line mesh of an arrow pointing in the +Y
% direction, and initialise it for every vector, translating and scaling
% appropriately.
% Create the vertices for the arrow.
headsize=4;
V_arrow=[0 0 0;0 0 1;-0.0165*headsize 0.0165*headsize 1-(1-0.934)*headsize;0.0165*headsize -0.0165*headsize 1-(1-0.934)*headsize];
% Create the lines for the arrow.
E_arrow=[1 2;3 2;4 2];
% Scale vertices based on data aspect ratio and plot aspect ratio to make
% the 3D Object look as much like the MATLAB plot as possible.
V_arrow=V_arrow./daspect.*pbaspect;
% Rotate the vertices since we are more used to Z-axis being "up" and
% Y-axis being "back".
V_arrow=V_arrow*[0 0 1;1 0 0;0 1 0];
% Add the arrow mesh with the line colour material.
mesh_idx=gltf.addMesh(V_arrow,'indices',E_arrow,'mode',"LINES",'material',material_idx);
% Get the translations for each vector.
T=[X(:) Y(:) Z(:)];
% Get the direction of each vector.
S=[U(:) V(:) W(:)];
% Scale transforms based on data aspect ratio and plot aspect ratio to make
% the 3D Object look as much like the MATLAB plot as possible.
T=T./daspect.*pbaspect;
S=S./daspect.*pbaspect;
% Rotate the transforms since we are more used to Z-axis being "up" and
% Y-axis being "back".
T=T*[0 0 1;1 0 0;0 1 0];
S=S*[0 0 1;1 0 0;0 1 0];
% Find the axis of rotation between the default arrow direction (+Y) and
% the vector direction.
rotation_axis=cross(repmat([0 1 0],numel(Z),1),S./vecnorm(S,2,2),2);
% We need to make sure that if the cross product is very small, we don't
% blow up the rotation. So figure out all the points for which the rotation
% is less than minimum double value (eps).
zero_axis=vecnorm(rotation_axis,2,2)<=eps;
% For each of them, set the axis to be X-axis. It won't be used as the
% rotation angle will be zero.
rotation_axis(zero_axis,:)=repmat([1 0 0],nnz(zero_axis),1);
% Make sure all the axis have unit lengths.
rotation_axis=rotation_axis./vecnorm(rotation_axis,2,2);
% Find the rotation angle between the default arrow direction (+Y) and the
% vector direction.
rotation_angle=acos(dot(repmat([0 1 0],numel(Z),1),S./vecnorm(S,2,2),2));
% For the small rotation values, force the rotation angle to be zero for
% consistency.
rotation_angle(zero_axis)=0;
% Construct the XYZW quaternions.
rotation=[sin(rotation_angle/2).*rotation_axis cos(rotation_angle/2)];
% Use EXT_mesh_gpu_instancing to instantiate multiple copies of the arrows.
% We could add one node per arrow, but that increases the file size (due to
% requiring translation and rotation matrices to be specified in text per
% node. It also improves rendering efficiency.
gltf.addNode('mesh',mesh_idx,'instancingTranslation',T,'instancingRotation',rotation,'scale',s.AutoScaleFactor*ones(1,3));
% Add axes as seen in the figure.
gltf=addAxes(gltf,'baseRotation',[0 0 1;1 0 0;0 1 0],'axisIds',["x00";"0y0";"01z"],'gridIds',["xy0","x1z","1yz"],'backPlanes',["xy0","x1z","1yz"],'scaleFactor',10,'axis',s.Parent,'fontFile',"ARIALUNI_1.svg",'plotAspect',true,'dataAspect',true);
% Write the GLTF file.
gltf.writeGLTF("quiver3.gltf");
