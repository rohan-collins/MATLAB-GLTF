function addExtension(obj,extension,required)
    % Add an extension to be used.
    %
    % WRITEDAE(OBJ,EXTENSION) adds an extension to the GLTF object, if it
    % has not already been added. It does not add the extension to the list
    % of required extensions.
    %
    % WRITEDAE(OBJ,EXTENSION,TRUE) adds an extension to the GLTF object,
    % if it has not already been added, and adds it to the list of required
    % extensions as well.
    %
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
    if(~isprop(obj,'extensionsUsed'))
        obj.addprop("extensionsUsed");
    end
    extension=string(extension);
    if(isempty(obj.extensionsUsed) || ~ismember(extension,obj.extensionsUsed))
        obj.extensionsUsed=[obj.extensionsUsed {char(extension)}];
    end
    if(nargin<3)
        required=false;
    end
    if(required)
        if(~isprop(obj,'extensionsRequired'))
            obj.addprop("extensionsRequired");
        end
        if(isempty(obj.extensionsRequired) || ~ismember(extension,obj.extensionsRequired))
            obj.extensionsRequired=[obj.extensionsRequired {char(extension)}];
        end
    end
end
