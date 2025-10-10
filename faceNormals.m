function Nf=faceNormals(F,V)
    % Calculate face normals for a mesh.
    %
    % FACENORMALS(F,V) calculates the normals for each face of the mesh of
    % vertices V and faces F.
    %
    % MATLAB GLTF is free software: you can redistribute it and/or modify
    % it under the terms of the GNU General Public License as published by
    % the Free Software Foundation, either version 3 of the License, or (at
    % your option) any later version.
    %
    % © Copyright 2014-2025 Rohan Chabukswar.
    %
    % This file is part of MATLAB GLTF.
    %
    % MATLAB GLTF is distributed in the hope that it will be useful, but
    % WITHOUT ANY WARRANTY; without even the implied warranty of
    % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
    % General Public License for more details.
    %
    % You should have received a copy of the GNU General Public License
    % along with MATLAB GLTF. If not, see <https://www.gnu.org/licenses/>.
    %
    Nf=zeros(size(F,1),size(V,2));
    f=F;
    for i=find(any(isnan(F(:,1:3)),2))
        f(i,:)=F(i,~isnan(F(i,:)));
    end
    f=f(:,1:3);
    degen=any(isnan(f),2);
    f=f(~degen,:);
    Nf2=cross(V(f(:,1),:),V(f(:,2),:),2)+cross(V(f(:,2),:),V(f(:,3),:),2)+cross(V(f(:,3),:),V(f(:,1),:),2);
    normnorm=vecnorm(Nf2,2,2);
    Nf2(normnorm>eps,:)=Nf2(normnorm>eps,:)./normnorm(normnorm>eps,:);
    Nf(~degen,:)=Nf2;
end
