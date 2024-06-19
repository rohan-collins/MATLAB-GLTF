function varargout=polytope(varargin)
    % [V,E,...]=POLYTOPE(P,Q,...) or [V,E,...]=POLYTOPE([P Q ...]) returns
    % the vertices, plus edges, faces, volumes, and higher dimensional
    % constructs (when available) for the regular polytope defined by the
    % Schläfli symbol {p,q,...}.
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

    if(nargin>1)
        schlafli=cell2mat(cellfun(@(x) reshape(x,1,[]),varargin,'UniformOutput',false));
    elseif(nargin==1)
        schlafli=varargin{1};
    else
        schlafli=[];
    end
    dim=numel(schlafli)+1;
    switch(dim)
        case 1
            allfigures=tesseract(1);
            allfigures{1}=allfigures{1};
            for i=1:nargout
                if(i<=numel(allfigures))
                    varargout{i}=allfigures{i}; %#ok<AGROW>
                else
                    varargout{i}=[]; %#ok<AGROW>
                end
            end
        case 2
            if(schlafli==3)
                allfigures=simplex(2);
                allfigures{1}=allfigures{1};
                for i=1:nargout
                    if(i<=numel(allfigures))
                        varargout{i}=allfigures{i}; %#ok<AGROW>
                    else
                        varargout{i}=[]; %#ok<AGROW>
                    end
                end
            elseif(schlafli==4)
                allfigures=tesseract(2);
                allfigures{1}=allfigures{1};
                for i=1:nargout
                    if(i<=numel(allfigures))
                        varargout{i}=allfigures{i}; %#ok<AGROW>
                    else
                        varargout{i}=[]; %#ok<AGROW>
                    end
                end
            elseif(mod(schlafli(1),1)==0)
                p=schlafli(1);
                V=[cos((0:p-1)'*2*pi/p) sin((0:p-1)'*2*pi/p)];
                E=[(1:p)' [2:p 1]'];
                [~,ia]=unique(sort(E,2),'rows');
                E=E(ia,:);
                F=1:p;
                varargout={V,E,F};
                for i=4:nargout
                    varargout{i}=[];
                end
            else
                varargout=cell(1,nargout);
            end
        case 3
            if(all(schlafli==[3 3]))
                allfigures=simplex(3);
                allfigures{1}=allfigures{1};
                for i=1:nargout
                    if(i<=numel(allfigures))
                        varargout{i}=allfigures{i}; %#ok<AGROW>
                    else
                        varargout{i}=[]; %#ok<AGROW>
                    end
                end
            elseif(all(schlafli==[4 3]))
                allfigures=tesseract(3);
                allfigures{1}=allfigures{1};
                for i=1:nargout
                    if(i<=numel(allfigures))
                        varargout{i}=allfigures{i}; %#ok<AGROW>
                    else
                        varargout{i}=[];%#ok<AGROW>
                    end
                end
            elseif(all(schlafli==[3 4]))
                allfigures=orthoplex(3);
                allfigures{1}=allfigures{1};
                for i=1:nargout
                    if(i<=numel(allfigures))
                        varargout{i}=allfigures{i};%#ok<AGROW>
                    else
                        varargout{i}=[];%#ok<AGROW>
                    end
                end
            elseif(all(schlafli==[5 3]))
                phi=(1+sqrt(5))/2;
                V=[1-(dec2bin((0:7)')-48)*2;0 1/phi phi;0 1/phi -phi;0 -1/phi phi;0 -1/phi -phi;1/phi phi 0;1/phi -phi 0;-1/phi phi 0;-1/phi -phi 0;phi 0 1/phi;-phi 0 1/phi;phi 0 -1/phi;-phi 0 -1/phi]/sqrt(3);
                F=[1 17 19 2 13;2 19 4 12 10;5 9 1 13 15;7 11 9 5 18;8 12 4 14 16;16 7 18 20 8;10 12 8 20 6;11 3 17 1 9;14 4 19 17 3;15 13 2 10 6;16 14 3 11 7;5 15 6 20 18];
                E(:,:,1)=F;
                E(:,:,2)=F(:,[2:end 1]);
                E=unique(sort(reshape(permute(E,[3 2 1]),2,[]),1)','rows');
                C=1:size(V,1);
                varargout={V,E,F,C};
                for i=5:nargout
                    varargout{i}=[];
                end
            elseif(all(schlafli==[3 5]))
                phi=(1+sqrt(5))/2;
                V=[0 1 phi;0 1 -phi;0 -1 phi;0 -1 -phi;1 phi 0;1 -phi 0;-1 phi 0;-1 -phi 0;phi 0 1;-phi 0 1;phi 0 -1;-phi 0 -1]/sqrt(10+2*sqrt(5))*2;
                F=[1 3 9;5 7 1;7 10 1;9 5 1;10 3 1;2 4 12;5 11 2;7 5 2;11 4 2;12 7 2;3 6 9;8 6 3;10 8 3;4 6 8;8 12 4;11 6 4;5 9 11;6 11 9;7 12 10;8 10 12];
                E(:,:,1)=F;
                E(:,:,2)=F(:,[2:end 1]);
                E=unique(sort(reshape(permute(E,[3 2 1]),2,[]),1)','rows');
                C=1:size(V,1);
                varargout={V,E,F,C};
                for i=5:nargout
                    varargout{i}=[];
                end
            else
                varargout=cell(1,nargout);
            end
        case 4
            if(all(schlafli==[3 3 3]))
                allfigures=simplex(4);
                allfigures{1}=allfigures{1};
                for i=1:nargout
                    if(i<=numel(allfigures))
                        varargout{i}=allfigures{i};%#ok<AGROW>
                    else
                        varargout{i}=[];%#ok<AGROW>
                    end
                end
            elseif(all(schlafli==[4 3 3]))
                allfigures=tesseract(4);
                for i=1:nargout
                    if(i<=numel(allfigures))
                        varargout{i}=allfigures{i};%#ok<AGROW>
                    else
                        varargout{i}=[];%#ok<AGROW>
                    end
                end
            elseif(all(schlafli==[3 3 4]))
                allfigures=orthoplex(4);
                allfigures{1}=allfigures{1};
                for i=1:nargout
                    if(i<=numel(allfigures))
                        varargout{i}=allfigures{i};%#ok<AGROW>
                    else
                        varargout{i}=[];%#ok<AGROW>
                    end
                end
            elseif(all(schlafli==[3 4 3]))
                V=[reshape(permute(cat(3,eye(4),-eye(4)),[1 3 2]),8,4);(1-(dec2bin((0:15)')-48)*2)/2];
                e=1;
                [C,F,E]=createPolytope(V,e,3);
                K=1:size(V,1);
                varargout={V,E,F,C,K};
                for i=6:nargout
                    varargout{i}=[];
                end
            elseif(all(schlafli==[5 3 3]))
                phi=(1+sqrt(5))/2;
                Vall=cell(4,1);
                Veven=cell(3,1);
                Vall{1}=[zeros(4,2) (dec2bin((0:3)')*2-97)]/sqrt(2);
                Vall{2}=(dec2bin((0:15)')*2-97).*[1 1 1 sqrt(5)]/sqrt(8);
                Vall{3}=(dec2bin((0:15)')*2-97).*[1./phi.^2 phi phi phi]/sqrt(8);
                Vall{4}=(dec2bin((0:15)')*2-97).*[1./phi 1./phi 1./phi phi.^2]/sqrt(8);
                Veven{1}=[zeros(8,1) (dec2bin((0:7)')*2-97).*[1/phi.^2 1 phi.^2]/sqrt(8)];
                Veven{2}=[zeros(8,1) (dec2bin((0:7)')*2-97).*[1./phi phi sqrt(5)]/sqrt(8)];
                Veven{3}=(dec2bin((0:15)')*2-97).*[1./phi 1 phi 2]/sqrt(8);
                Vall_new=cell(4,1);
                Veven_new=cell(3,1);
                for i=1:numel(Vall)
                    Vall_new{i}=cell(size(Vall{i},1),1);
                    for j=1:size(Vall{i},1)
                        Vall_new{i}{j}=uniquetol(perms(Vall{i}(j,:)),'ByRows',true);
                    end
                    Vall{i}=uniquetol(cell2mat(Vall_new{i}),'ByRows',true);
                end
                for i=1:numel(Veven)
                    Veven_new{i}=cell(size(Veven{i},1),1);
                    for j=1:size(Veven{i},1)
                        Veven_new{i}{j}=uniquetol(evenperms(Veven{i}(j,:)),'ByRows',true);
                    end
                    Veven{i}=uniquetol(cell2mat(Veven_new{i}),'ByRows',true);
                end
                V=[cell2mat(Vall);cell2mat(Veven)];
                e=2/phi.^2/sqrt(8);
                [C,F,E]=createPolytope(V,e);
                K=1:size(V,1);
                varargout={V,E,F,C,K};
                for i=6:nargout
                    varargout{i}=[];
                end
            elseif(all(schlafli==[3 3 5]))
                phi=(1+sqrt(5))/2;
                V1=(1-(dec2bin((0:15)')-48)*2)/2;
                V2=reshape(permute(cat(3,eye(4),-eye(4)),[1 3 2]),8,4);
                Veven=[(dec2bin((0:7)')*2-97).*[phi 1 1./phi]/2 zeros(8,1)];
                Veven_new=cell(size(Veven,1),1);
                for i=1:size(Veven,1)
                    Veven_new{i}=uniquetol(evenperms(Veven(i,:)),'ByRows',true);
                end
                Veven=uniquetol(cell2mat(Veven_new),'ByRows',true);
                V=[V1;V2;Veven];
                e=1/phi;
                [C,F,E]=createPolytope(V,e);
                K=1:size(V,1);
                varargout={V,E,F,C,K};
                for i=6:nargout
                    varargout{i}=[];
                end
            else
                varargout=cell(1,nargout);
            end
        otherwise
            if(dim>4)
                if(all(schlafli==3))
                    allfigures=simplex(dim);
                    for i=1:nargout
                        if(i<=numel(allfigures))
                            varargout{i}=allfigures{i};%#ok<AGROW>
                        else
                            varargout{i}=[];%#ok<AGROW>
                        end
                    end
                elseif(and(schlafli(1)==4,all(schlafli(2:end)==3)))
                    allfigures=tesseract(dim);
                    for i=1:nargout
                        if(i<=numel(allfigures))
                            varargout{i}=allfigures{i};%#ok<AGROW>
                        else
                            varargout{i}=[];%#ok<AGROW>
                        end
                    end
                elseif(and(schlafli(end)==4,all(schlafli(1:end-1)==3)))
                    allfigures=orthoplex(dim);
                    for i=1:nargout
                        if(i<=numel(allfigures))
                            varargout{i}=allfigures{i};%#ok<AGROW>
                        else
                            varargout{i}=[];%#ok<AGROW>
                        end
                    end
                else
                    varargout=cell(1,nargout);
                end
            else
                varargout=cell(1,nargout);
            end
    end
end

function allfigures=simplex(dim)
    % [V,E,...]=SIMPLEX(D) returns the vertices, plus edges, faces,
    % volumes, and higher dimensional constructs (when available) for the
    % regular simplex of given dimension.
    %
    if(dim==2)
        V=[cos((0:2)'*2*pi/3) sin((0:2)'*2*pi/3)];
        p=3;
        E=[(1:p-1)' (2:p)'];
        F=1:p;
        allfigures={V,E,F};
    elseif(dim==3)
        V=[1 1 1;-1 -1 1;1 -1 -1;-1 1 -1]/sqrt(3);
        F=[1 2 3;3 4 1;4 2 1;2 4 3];
        E(:,:,1)=F;
        E(:,:,2)=F(:,[2:end 1]);
        E=unique(sort(reshape(permute(E,[3 2 1]),2,[]),1)','rows');
        C=1:size(V,1);
        allfigures={V,E,F,C};
    else
        V_old=simplex(dim-1);
        V_old=V_old{1};
        V=[1 zeros(1,size(V_old,2));-ones(size(V_old,1),1)/dim V_old.*sqrt((1-1/dim^2)./sum(V_old.^2,2))];
        allfigures=cell(1,dim+1);
        allfigures{1}=V;
        for i=1:dim
            allfigures{i+1}=nchoosek(1:dim+1,i+1);
        end
    end
end

function allfigures=tesseract(dim)
    % [V,E,...]=TESSERACT(D) returns the vertices, plus edges, faces,
    % volumes, and higher dimensional constructs (when available) for the
    % regular tesseract of given dimension.
    %
    if(dim==1)
        allfigures={[1;-1],[1 2]};
    else
        last=tesseract(dim-1);
        V=last{1}*sqrt(dim-1)/sqrt(dim);
        n=size(V,1);
        if(dim==3)
            V=[V ones(n,1)/sqrt(dim);V -ones(n,1)/sqrt(dim)];
            F=[1 2 4 3;5 7 8 6;6 2 1 5;2 6 8 4;4 8 7 3;3 7 5 1];
            E(:,:,1)=F;
            E(:,:,2)=F(:,[2:end 1]);
            E=unique(sort(reshape(permute(E,[3 2 1]),2,[]),1)','rows');
            C=[last{dim} last{dim}(:,end:-1:1)+n];
            allfigures={V,E,F,C};
        else
            new=cell(dim+1,1);
            new{1}=[V ones(n,1)/sqrt(dim);V -ones(n,1)/sqrt(dim)];
            new{2}=[1:n;n+1:2*n]';
            allfigures=cell(1,dim+1);
            allfigures{1}=new{1};
            allfigures{2}=[last{2};last{2}(:,end:-1:1)+n;new{2}];
            for i=3:numel(last)+1
                new{i}=[last{i-1} last{i-1}(:,end:-1:1)+n];
            end
            for i=3:numel(last)
                allfigures{i}=[last{i};last{i}(:,end:-1:1)+n;new{i}];
            end
            allfigures{dim+1}=new{dim+1};
        end
    end
end

function allfigures=orthoplex(dim)
    % [V,E,...]=ORTHOPLEX(D) returns the vertices, plus edges, faces,
    % volumes, and higher dimensional constructs (when available) for the
    % regular orthoplex of given dimension.
    %
    V=[eye(dim);-eye(dim)];
    A=triu(abs(V*V')<sqrt(eps));
    [I,J]=find(A);
    E=[I J];
    allfigures{1}=V;
    allfigures{2}=E;
    if(dim==3)
        allfigures{dim}=convhull(V);
        allfigures{dim+1}=1:size(V,1);
    else
        for i=2:dim-1
            allfigures{i+1}=[];
            for j=1:size(allfigures{i},1)
                temp=find(all(A(allfigures{i}(j,:),:),1));
                allfigures{i+1}=[allfigures{i+1};repmat(allfigures{i}(j,:),nnz(temp>max(allfigures{i}(j,:))),1) temp(temp>max(allfigures{i}(j,:)))'];
            end
        end
        allfigures{dim+1}=1:size(V,1);
    end
end

function p=evenperms(v)
    % P=EVENPERMS(V) returns all the even permutations of the elements of
    % the given vector.
    %
    n=numel(v);
    I=speye(n);
    p=perms(1:n);
    sign=nan(size(p,1),1);
    for i=1:size(p,1)
        sign(i)=det(I(:,p(i,:)));
    end
    p=v(p(sign==1,:));
end

function [K,F,E]=createPolytope(V,e,fn)
    if(nargin<3)
        fn=nan;
    end
    K=convhulln(V);
    for i=1:size(K,1)
        if(abs(det(V(K(i,:),:)))<eps)
            K(i,:)=nan;
        elseif(det(V(K(i,:),:))<0)
            K(i,:)=K(i,[1:end-2 end end-1]);
        end
    end
    K=K(any(~isnan(K),2),:);
    N=nan(size(K,1),size(V,2));
    for i=1:size(K,1)
        [~,~,C]=svd([V(K(i,:),:) ones(size(K,2),1)]);
        n=C(1:end-1,end)';
        n=n/norm(n);
        N(i,:)=n;
    end
    [~,~,ic]=uniquetol(N,'ByRows',true);
    if(min(histcounts(ic,0.5:max(ic)+0.5))>1)
        newK=nan(max(ic),max(histcounts(ic,0.5:max(ic)+0.5)));
        for i=1:max(ic)
            temp=unique(K(ic==i,:))';
            newK(i,1:numel(temp))=temp;
        end
        K=newK;
        K=K(:,~all(isnan(K),1));
    end

    p=nchoosek(1:size(K,2),3);
    F=cell(size(K,1),1);
    for i=1:size(K,1)
        F{i}=nan(size(p,1),size(K,2));
        for j=1:size(p,1)
            if(~any(isnan(K(i,p(j,:)))))
                [~,~,C]=svd([V(K(i,p(j,:)),:) ones(3,1)]);
                idx=K(i,sqrt(sum(([V(K(i,1:nnz(~isnan(K(i,:)))),:) ones(nnz(~isnan(K(i,:))),1)]*C(:,[4 5])).^2,2))<=sqrt(eps),:);
                if(or(isnan(fn),numel(idx)==fn))
                    Vtemp=V(idx,:);
                    Dtemp=sqrt(sum((permute(Vtemp,[1 3 2])-permute(Vtemp,[3 1 2])).^2,3));
                    Dtemp=Dtemp+diag(inf(size(Dtemp,1),1));
                    if(min(Dtemp)>e+sqrt(eps))
                        continue;
                    else
                        A=abs(Dtemp-e)<=sqrt(eps);
                        c=getCycle(A);
                        F{i}(j,1:numel(c))=idx(c);
                    end
                end
            end
        end
    end
    F=cell2mat(F);
    F=F(all(~isnan(F(:,any(~isnan(F),1))),2),any(~isnan(F),1));
    [~,ia,~]=unique(sort(F,2),'rows');
    F=F(ia,:);
    E=unique(sort(reshape(permute(cat(3,F,F(:,[2:end 1])),[3 2 1]),2,[]),1)','rows');
end

function c=getCycle(A)
    c=[1 nan(1,nnz(A)/2-1)];
    for i=2:numel(c)
        if(i>2)
            if(numel(setdiff(find(A(c(i-1),:)),c(1:i-1)))~=1)
                c=[];
                break;
            else
                c(i)=setdiff(find(A(c(i-1),:)),c(1:i-1));
            end
        else
            if(nnz(A(c(i-1),:))<1)
                c=[];
                break;
            else
                c(i)=find(A(c(i-1),:),1);
            end
        end
    end
end
