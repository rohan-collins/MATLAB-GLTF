function [Tf,Bf]=faceTangents(F,V,UV)
    % Calculate face tangents and bitangents for a mesh.
    %
    % FACETANGENTS(F,V,UV) calculates the tangents and bitangents for each
    % face of the mesh of vertices V, faces F, and texture coordinates UV.
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
    Tf=zeros(size(F,1),size(V,2));
    Tf2=zeros(size(F,1),size(V,2));
    Bf=zeros(size(F,1),size(V,2));
    f=F;
    for i=find(any(isnan(F(:,1:3)),2))
        f(i,:)=[F(i,~isnan(F(i,:))) nan(1,nnz(isnan(F(i,:))))];
    end
    f=f(:,1:3);
    degen=any(isnan(f),2);
    f=f(~degen,:);
    num=(UV(f(:,2),2)-UV(f(:,3),2)).*V(f(:,1),:)+(UV(f(:,3),2)-UV(f(:,1),2)).*V(f(:,2),:)+(UV(f(:,1),2)-UV(f(:,2),2)).*V(f(:,3),:);
    detM=UV(f(:,1),1).*UV(f(:,2),2)-UV(f(:,1),2).*UV(f(:,2),1)+UV(f(:,2),1).*UV(f(:,3),2)-UV(f(:,2),2).*UV(f(:,3),1)+UV(f(:,3),1).*UV(f(:,1),2)-UV(f(:,3),2).*UV(f(:,1),1);
    Tf2(abs(detM)>eps,:)=num(abs(detM)>eps,:)./detM(abs(detM)>eps,:);
    normtan=vecnorm(Tf2,2,2);
    Tf2(normtan>eps,:)=Tf2(normtan>eps,:)./normtan(normtan>eps,:);
    Nf=GLTF.faceNormals(F,V);
    Bf2=cross(Nf,Tf2,2);
    normbitan=vecnorm(Bf2,2,2);
    Bf2(normbitan>eps,:)=Bf2(normbitan>eps,:)./normbitan(normbitan>eps,:);
    Tf(~degen,:)=Tf2;
    Bf(~degen,:)=Bf2;
end
