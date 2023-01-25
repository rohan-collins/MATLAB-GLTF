function addExtension(gltf,extension)
    % Add an extension to be used.
    %
    % WRITEDAE(GLTF,EXTENSION) adds an extension to the GLTF object, if it
    % has not already been added.
    %
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
    if(~isprop(gltf,'extensionsUsed'))
        gltf.addprop("extensionsUsed");
    end
    extension=string(extension);
    if(isempty(gltf.extensionsUsed) || ~ismember(extension,gltf.extensionsUsed))
        gltf.extensionsUsed=[gltf.extensionsUsed {char(extension)}];
    end
end
