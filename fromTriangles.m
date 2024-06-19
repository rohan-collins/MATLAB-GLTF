function F=fromTriangles(F)
    % Converts data from an indices accessor to triangles. FromTriangles
    % should be used when the mode for the mesh primitives is "TRIANGLES"
    % (4) or unspecified.
    %
    % FROMTRIANGLES(GLTF,ACCESSOR_IDX) Converts data from an indices
    % accessor to triangles.
    %
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
    n=floor(numel(F)/3);
    if(n>0)
        F=reshape(F(1:3*n),3,[])'+1;
    else
        F=F(:)'+1;
    end
end
