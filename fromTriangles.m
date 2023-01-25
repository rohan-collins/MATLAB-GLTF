function F=fromTriangles(F)
    % Converts triangles to polygons, assuming the implicit convention that
    % the identifying vertex of each polygon is different from that of the
    % previous polygon.
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
    startIndex=0;
    maxN=0;
    newF=cell(size(F,1),1);
    count=0;
    for t=1:size(F,1)
        if(F(t,1)~=startIndex)
            if(count>0)
                maxN=max(maxN,numel(newF{count}));
            end
            count=count+1;
            newF{count}=F(t,:);
            startIndex=F(t,1);
        else
            newF{count}=[newF{count} F(t,3)];
        end
    end
    newF=newF(~cellfun(@isempty,newF));
    F=cell2mat(cellfun(@(x) [x nan(1,maxN-numel(x))],newF,'UniformOutput',false));
end
