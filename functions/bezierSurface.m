function [F,V,UV,N,T,B]=bezierSurface(points,varargin)
    % [F,V,UV,N,T,B]=BEZIERSURFACE(POINTS) returns the bezier surface
    % defined by MxNx... points as faces and vertices, UVcoordinates,
    % vertex normals, vertex tangents, and vertex bitangents. The dimension
    % of the curve is the dimension of the points (M), and the degree of
    % the bezier curve is one less than the number of points provided in
    % each of the remaining dimension. 101 points for each dimension are
    % generated.
    %
    % [F,V,UV,N,T,B]=BEZIERSURFACE(POINTS,U) uses the parametric variable U
    % to generate the points.
    %
    % [F,V,UV,N,T,B]=BEZIERSURFACE(POINTS,U,V) uses the parametric
    % variables U and V to generate the points.
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

    n_inputs=nargin-1;
    dims=ndims(points)-1;
    t=cell(1,dims);
    if(n_inputs<1)
        t=repmat({linspace(0,1,101)'},1,dims);
    end
    last=linspace(0,1,101)';
    for d=1:dims
        if(d<=n_inputs)
            last=varargin{d}(:);
            t{d}=last;
        end
        if(d>1)
            permdims=zeros(1,dims);
            permdims(d)=1;
            permdims([1:d-1 d+1:dims])=2:dims;
            t{d}=permute(last,permdims);
        end
    end
    t=t(1:2);
    
    if(any(isnan(points),'all'))
        if(nargin<2)
            [curve,first]=bezierT(points);
        else
            [curve,first]=bezierT(points,varargin{1});
        end
    else
        [curve,first]=bezier(points,varargin{:});
    end
    P=size(curve);
    M=P(2);
    P=P(3);
    F=reshape([M+1:2*M-1;1:M-1;2:M;2:M;M+2:2*M;M+1:2*M-1]+M*permute(0:P-2,[1 3 2]),3,2*(M-1)*(P-1))';
    V=reshape(curve,3,M*P)';
    UV=reshape([repmat(permute(t{1},[2 1 3]),1,1,numel(t{2}));repmat(permute(t{2},[1 3 2]),1,numel(t{1}),1)],2,M*P)';
    idx=all(~isnan(V),2);
    V=V(idx,:);
    UV=UV(idx,:);
    T=reshape(first(:,:,:,1),3,M*P)';
    T=T(idx,:);
    T=T./sqrt(sum(T.^2,2));
    B=reshape(first(:,:,:,2),3,M*P)';
    B=B(idx,:);
    B=B./sqrt(sum(B.^2,2));
    N=cross(T,B,2);
    N=N./sqrt(sum(N.^2,2));
    B=cross(N,T,2);
    B=B./sqrt(sum(B.^2,2));
	[Lia,locB]=ismember(F,find(idx));
    Fidx=all(Lia,2);
    F=locB(Fidx,:);
end
