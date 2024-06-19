function valid=validateStringWithIndex(input,possibilities,placeholder)
    % Validate string inputs to functions.
    %
    % VALIDATESTRING(INPUT,POSSIBILITIES,PLACEHOLDER) returns TRUE if INPUT
    % is a member of POSSIBILITIES, with any numerical index in place of
    % PLACEHOLDER, and returns an error if it isn't.
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
    possibilities2=strrep(possibilities,placeholder,"\d+");
    valid=ismissing(input);
    if(~valid)
        for i=1:numel(possibilities2)
            valid=or(valid,~isempty(regexpi(input,possibilities2(i),'once')));
        end
    end
    if(~valid)
        error("It must be " + GLTF.joinString(possibilities) + ".");
    end
end
