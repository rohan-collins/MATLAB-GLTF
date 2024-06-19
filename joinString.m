function out=joinString(strings)
    % Join strings in a grammatically correct manner.
    %
    % JOINSTRING(STRINGS) joins STRINGS in a grammatically correct manner
    % by adding Oxford commas.
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
    if(numel(strings)<2)
        out=strings;
    elseif(numel(strings)==2)
        out="either " + join("""" + strings + """", "or ");
    else
        strings2="""" + strings + """";
        strings2(end)="or " + strings2(end);
        out="one of " + join(strings2, ", ");
    end
end
