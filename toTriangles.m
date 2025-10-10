function F=toTriangles(F)
    % Converts polygons to triangles, so that each polygon is converted to a
    % triangle fan.
    %
    % TOTRIANGLES(F) Converts polygons in F to triangles, so that each
    % polygon is converted to a triangle fan.
    %
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
    F=reshape(F(:,reshape([ones(1,size(F,2)-2);2:size(F,2)-1;3:size(F,2)],3*(size(F,2)-2),1)')',3,[])';
    F=F(~any(isnan(F),2),:);        
end
