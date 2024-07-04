function valid=validateInteger(input,min,max)
    % Validate string inputs to functions.
    %
    % VALIDATEINTEGER(INPUT,POSSIBILITIES) returns TRUE if INPUT is an
    % integer and one of POSSIBILITIES, and returns an error if it isn't.
    %
    % VALIDATEINTEGER(INPUT,MIN,MAX) returns TRUE if INPUT is an integer
    % between MIN and MAX (inclusive), and returns an error if it isn't.
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
    valid=isnumeric(input);
    valid=valid && all(input==round(input));
    if(nargin>2)
        if(isfinite(min))
            valid=valid && all(input>=min);
        end
        if(isfinite(max))
            valid=valid && all(input<=max);
        end
        if(~valid)
            if(and(isfinite(min),isfinite(max)))
                error("Must be integer(s) from " + min + " to " + max + ".");
            elseif(isfinite(min))
                error("Must be integer(s) greater than or equal to " + min + ".");
            elseif(isfinite(max))
                error("Must be integer(s) less than or equal to " + max + ".");
            else
                error("Must be integer(s).");
            end
        end
    else
        valid=all(ismember(input,min));
        if(~valid)
            error("Must be integer(s) " + GLTF.joinString(string(min)) + ".");
        end
    end
end
