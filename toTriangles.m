function F=toTriangles(F)
    % Converts polygons to triangles, so that each polygon is converted to
    % a triangle fan with an identifying vertex that is different from the
    % previous polygon's.
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
    validF=true(size(F,1),1);
    for f=1:size(F,1)
        if(nnz(~isnan(F(f,:)))<3)
            validF(f)=false;
        else
            while(isnan(F(f,1)))
                F(f,:)=circshift(F(f,:),-1);
            end
            if(f>1)
                if(all(ismember(F(f,~isnan(F(f,:))),F(f-1,:))))
                    validF(f)=false;
                else
                    while(or(isnan(F(f,1)),F(f,1)==F(f-1,1)))
                        F(f,:)=circshift(F(f,:),-1);
                    end
                end
            end
        end
    end
    F=F(validF,:);
    F=reshape(F(:,reshape([ones(1,size(F,2)-2);2:size(F,2)-1;3:size(F,2)],3*(size(F,2)-2),1)')',3,[])';
    F=F(~any(isnan(F),2),:);        
end
