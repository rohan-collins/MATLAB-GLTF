function [Tv,Bv,F,idx]=vertexTangents(F,V,UV)
    % Calculate vertex tangents and bitangents for a mesh.
    %
    % VERTEXTANGENTS(F,V,UV) calculates the vertex tangents and bitangents
    % for each vertex of the mesh of vertices V, faces F, and texture
    % coordinates UV.
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
    [Nv,F,idx]=vertexNormals(F,V);
    V=V(idx,:);
    Tv=zeros(size(V));
    Bv=zeros(size(V));
    Tf=GLTF.faceTangents(F,V,UV);
    normtan=vecnorm(Tf,2,2);
    Tf(normtan<=eps,:)=nan;
    for i=1:size(F,1)
        f=F(i,~isnan(F(i,:)));
        t=Tf(f,:);
        t=t(~any(isnan(t),2),:);
        Tv(f,:)=Tv(f,:)+t;
    end
    normtan=vecnorm(Tv,2,2);
    Tv(normtan==0,:)=Nv(normtan==0,:);
    Tv=Tv./vecnorm(Tv,2,2);
    if(nargout>1)
        Bv=cross(Nv,Tv,2);
    end
    Tv=[Tv ones(size(V,1),1)];
end
