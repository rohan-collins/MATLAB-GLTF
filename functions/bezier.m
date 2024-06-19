function [curve,varargout]=bezier(points,varargin)
    % CURVE=BEZIER(POINTS) returns the bezier curve defined by MxNx...
    % points. The dimension of the curve is the dimension of the points
    % (M), and the degree of the bezier curve is one less than the number
    % of points provided in each of the remaining dimension. 101 points for
    % each dimension are generated.
    %
    % CURVE=BEZIER(POINTS,T) uses the parametric variable T to generate the
    % points.
    %
    % CURVE=BEZIER(POINTS,T,U,...) uses the parametric variables T, U, ...
    % to generate the points.
    %
    % [CURVE,FIRST,SECOND,...]=BEZIER(...) returns the first, second, etc.
    % derivatives of the curve.
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

    n_inputs=nargin-1;
    dims=ndims(points)-1;
    n=size(points);
    n=n(2:end);
    degree=n-1;
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
    curve=beziern_base(points,t);
    D=size(points,1);
    K=nargout-1;
    varargout=cell(1,K);
    NN=[D cellfun(@numel,t)];
    NNN=prod(NN);
    for k=1:K
        I=dims^k;
        Delta=nan(dims^k,dims);
        J=nan(dims^k,k);
        for i=1:I
            temp=floor((i-1)./[1 dims.^(1:k-1)]);
            J(i,:)=flip(temp-[temp(:,2:end).*repmat(dims,1,k-1) 0]+1,2);
            Delta(i,:)=histcounts(J(i,:),(0:dims)+0.5);
        end
        [Delta,ia,ic]=unique(Delta,'stable','rows');
        J=J(ia,:);
        I=size(Delta,1);
        dmanifold=zeros([NNN I]);
        for i=1:I
            j=J(i,:);
            delta=Delta(i,:);
            if(all(degree-delta>=0))
                coeff=prod(factorial(degree)./factorial(degree-delta));
                dpoints=points;
                for dk=1:k
                    dpoints=diff(dpoints,1,j(dk)+1);
                end
                dmanifold(:,i)=coeff*reshape(beziern_base(dpoints,t),NNN,1);
            end
        end
        dmanifold=reshape(dmanifold(:,ic),[NN repmat(dims,1,k)]);
        varargout{k}=dmanifold;
    end
end

function out=beziern_base(points,t)
    dims=max(ndims(points)-1,numel(t));
    n=size(points);
    D=n(1);
    n=n(2:end);
    n=[n ones(1,numel(t)-numel(n))];
    N=prod(n);
    degree=n-1;
    out=zeros([D prod(cellfun(@numel,t))]);
    for lin_idx=0:N-1
        point_idx=lin_idx*D;
        temp=floor(lin_idx./[1 cumprod(n(1:end-1))]);
        i=temp-[temp(:,2:end).*n(1:end-1) 0];
        term=1;
        for j=1:dims
            mutiplicand=nchoosek(degree(j),i(j)).*(t{j}.^i(j)).*((1-t{j}).^(degree(j)-i(j)));
            term=term.*mutiplicand;
        end
        for d=1:D
            out(d,:)=out(d,:)+term(:)'*points(point_idx+d);
        end
    end
    out=reshape(out,[D cellfun(@numel,t)]);
end
