function E=fromLineLoop(E)
    % Converts data from an indices accessor to lines. FromLineLoop should
    % be used when the mode for the mesh primitives is "LINE_LOOP" (2).
    %
    % FROMLINELOOP(GLTF,ACCESSOR_IDX) Converts data from an indices
    % accessor to lines.
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
    E=[E circshift(E,-1,1)]+1;
end
