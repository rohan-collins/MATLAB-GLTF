function [Nv,F,idx]=vertexNormals(F,V)
    % Calculate vertex normals for a mesh.
    %
    % VERTEXNORMALS(F,V) calculates the vertex normals for each vertex of
    % the mesh of vertices V and faces F.
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
    Nv=zeros(size(V));
    Nf=GLTF.faceNormals(F,V);
    normnorm=vecnorm(Nf,2,2);
    Nf(normnorm<=eps,:)=nan;
    for i=1:size(F,1)
        f=F(i,~isnan(F(i,:)));
        n=Nf(i,:);
        if(~any(isnan(n)))
            Nv(f,:)=Nv(f,:)+n;
        end
    end
    zeroNormals=find(vecnorm(Nv,2,2)==0);
    n=size(V,1);
    idx=(1:n)';
    for i=zeroNormals(:)'
        faces=find(any(F==i,2));
        if(~isempty(faces))
            f=F(faces(1),:);
            Nf=cross(diff(V(f([2 3]),:)),diff(V(f([2 1]),:)))/norm(cross(diff(V(f([2 3]),:)),diff(V(f([2 1]),:))));
            Nv(i,:)=Nf;
            for j=2:numel(faces)
                idx=[idx;i]; %#ok<AGROW>
                n=n+1;
                f=F(faces(j),:);
                Nf=cross(diff(V(f([2 3]),:)),diff(V(f([2 1]),:)))/norm(cross(diff(V(f([2 3]),:)),diff(V(f([2 1]),:))));
                F(faces(j),F(faces(j),:)==i)=n;
                Nv=[Nv;Nf]; %#ok<AGROW>
                V=[V;V(i,:)]; %#ok<AGROW>
            end
        end
    end
    Nv=Nv./vecnorm(Nv,2,2);
end
