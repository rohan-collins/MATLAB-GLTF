function [Fnew,Vnew]=subDivideFaces(F,V,varargin)
    % Uniformly subdivide edges, triangles, and quadrilaterals of a
    % polyhedron. All other faces are returned as-is.
    %
    % [Fnew,Vnew]=SUBDIVIDEFACES(F,V) subdivides a polyhedron specified by
    % faces F and vertices V by linearly subdividing each face of the
    % polyhedron into 4 parts.
    %
    % [Fnew,Vnew]=SUBDIVIDEFACES(F,V,'resolution',N) subdivides a
    % polyhedron specified by faces F and vertices V by linearly
    % subdividing each face of the polyhedron into N^2 parts.
    %
    % [Fnew,Vnew]=SUBDIVIDEFACES(F,V,'spherical',TRUE) subdivides a
    % unit sphere specified by faces F and vertices V uniformly. This
    % subdivides each edge using spherical linear interpolation, to
    % minimise distortion in area of subdivided faces.
    % 
    % © Copyright 2014-2026 Rohan Chabukswar.
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
    ips=inputParser;
    ips.addParameter('resolution',2,@isnumeric);
    ips.addParameter('spherical',false,@islogical);
    ips.parse(varargin{:});
    parameters=ips.Results;
    spherical=parameters.spherical;
    n=parameters.resolution;

    if(spherical)
        V=V./vecnorm(V,2,2);
    end

    Fcell=cell(3,1);
    used=false(size(F,1),3);
    for f=1:3
        used(:,f)=sum(~isnan(F),2)==f+1;
        Fcell{f}=F(used(:,f),:);
        Fcell{f}=reshape(Fcell{f}(~isnan(Fcell{f})),[],f+1);
    end
    Fnonposs=F(~any(used,2),:);
    Fcell2=cell(3,1);
    Fe=cellfun(@(x)reshape(permute(cat(3,x,circshift(x,-1,2)),[3 2 1]),2,numel(x))',Fcell,'UniformOutput',false);
    E=unique(sort(cell2mat(Fe),2),"rows");
    Fef=cell(3,1);
    Fer=cell(3,1);
    for i=1:3
        [~,Fef{i}]=ismember(Fe{i},E,"rows");
        [~,Fer{i}]=ismember(Fe{i},flip(E,2),"rows");
    end
    Fe=cellfun(@(x,y,z)reshape(x-y,size(z'))',Fef,Fer,Fcell,'UniformOutput',false);
    N=size(V,1);
    if(n==1)
        Fnew=F;
        Vnew=V;
    elseif(n==2)
        V2=permute(mean(reshape(V(E',:)',size(V,2),2,[]),2),[3 1 2]);
        V3=permute(mean(reshape(V(Fcell{3}',:)',[size(V,2) size(Fcell{3}')]),2),[3 1 2]);
        N2=size(E,1);
        base{1}=[1 3;3 2];
        base{2}=[1 4 6;4 2 5;6 5 3;5 6 4];
        base{3}=[1 5 9 8;5 2 6 9;9 6 3 7;8 9 7 4];
        for f=1:numel(Fe)
            switch(f)
                case 2
                    for i=1:size(Fe{f},1)
                        Ftemp=[Fcell{f}(i,:) N+abs(Fe{f}(i,:))];
                        Fcell2{f}((i-1)*4+1:i*4,:)=Ftemp(base{f});
                    end
                case 3
                    for i=1:size(Fe{f},1)
                        Ftemp=[Fcell{f}(i,:) N+abs(Fe{f}(i,:)) N+N2+i];
                        Fcell2{f}((i-1)*4+1:i*4,:)=Ftemp(base{f});
                    end
                otherwise
                    for i=1:size(Fe{f},1)
                        Ftemp=[Fcell{f}(i,:) N+abs(Fe{f}(i,1))];
                        Fcell2{f}((i-1)*2+1:i*2,:)=Ftemp(base{f});
                    end
            end
        end
        if(spherical)
            V2=V2./vecnorm(V2,2,2);
            V3=V3./vecnorm(V3,2,2);
        end
        Vnew=[V;V2;V3];
        Fcell2=[Fcell2;Fnonposs];
        Fcell2=Fcell2(~cellfun(@isempty,Fcell2));
        Fnew=cell2mat(cellfun(@(x)[x nan(size(x,1),max(cellfun(@(x)size(x,2),Fcell2))-size(x,2))],Fcell2,'UniformOutput',false));
    else
        alpha=(1:n-1)/n;
        if(spherical)
            ax=cross(permute(V(E(:,1),:),[2 3 1]),permute(V(E(:,2),:),[2 3 1]),1);
            th=atan2(vecnorm(ax,2,1),dot(permute(V(E(:,1),:),[2 3 1]),permute(V(E(:,2),:),[2 3 1]),1)).*alpha;
            ax=ax./vecnorm(ax,2,1);
            u=ax.*permute(ax,[2 1 3]);
            ucross=[zeros(1,1,size(E,1)) -ax(3,:,:) ax(2,:,:);ax(3,:,:) zeros(1,1,size(E,1)) -ax(1,:,:);-ax(2,:,:) ax(1,:,:) zeros(1,1,size(E,1))];
            Ve=nan(size(V,2),n-1,size(E,1));
            for i=1:size(E,1)
                for j=1:n-1
                    R=cos(th(1,j,i))*eye(size(V,2))+sin(th(1,j,i))*ucross(:,:,i)+(1-cos(th(1,j,i)))*u(:,:,i);
                    Ve(:,j,i)=R*permute(V(E(i,1),:),[2 3 1]);
                end
            end
        else
            Ve=permute(V(E(:,1),:),[2 3 1]).*(1-alpha)+permute(V(E(:,2),:),[2 3 1]).*alpha;
        end
        N2=size(E,1)*(n-1);
        V2=reshape(Ve,size(V,2),N2)';
        Vnew=[V;V2];
        N3=0;
        for f=1:numel(Fe)
            switch(f)
                case 2
                    [lambda1,lambda2]=meshgrid(0:n);
                    lambda=[lambda1(:) lambda2(:) n-lambda1(:)-lambda2(:)];
                    lambda=lambda(all(and(lambda>0,lambda<n),2),[3 2 1])/n;
                    if(spherical)
                        p1=permute(V(Fcell{f}(:,1),:),[2 3 1]);
                        p2=permute(V(Fcell{f}(:,2),:),[2 3 1]);
                        p3=permute(V(Fcell{f}(:,3),:),[2 3 1]);
                        S=2*atan(dot(p1,cross(p2,p3,1),1)./(1+dot(p1,p2,1)+dot(p2,p3,1)+dot(p3,p1,1)));
                        S(:,:,1+dot(p1,p2,1)+dot(p2,p3,1)+dot(p3,p1,1)<eps)=pi;
                        V3=nan(size(V,2),size(lambda,1),size(Fcell{f},1));
                        for i=1:size(Fcell{f},1)
                            for j=1:size(lambda,1)
                                A=[cross(p2(:,1,i),p3(:,1,i),1)-tan(S(:,:,i).*lambda(j,1)/2)*(p2(:,1,i)+p3(:,1,i)) cross(p3(:,1,i),p1(:,1,i),1)-tan(S(:,:,i).*lambda(j,2)/2)*(p3(:,1,i)+p1(:,1,i)) cross(p1(:,1,i),p2(:,1,i),1)-tan(S(:,:,i).*lambda(j,3)/2)*(p1(:,1,i)+p2(:,1,i))]';
                                k=[tan(S(:,:,i).*lambda(j,1)/2)*(1+dot(p2(:,1,i),p3(:,1,i),1));tan(S(:,:,i).*lambda(j,2)/2)*(1+dot(p3(:,1,i),p1(:,1,i),1));tan(S(:,:,i).*lambda(j,3)/2)*(1+dot(p1(:,1,i),p2(:,1,i),1))];
                                V3(:,j,i)=A\k;
                            end
                        end
                    else
                        p=reshape(V(Fcell{f}',:)',[size(V,2) size(Fcell{f}')]);
                        V3=permute(sum(p.*permute(lambda,[3 2 4 1]),2),[1 4 3 2]);
                    end
                    V3=reshape(V3,size(V,2),size(lambda,1)*size(Fcell{f},1))';
                    Fun=@(n)cell2mat(cellfun(@(i)[1:i 2:i;2:i+1 i+3:2*i+1;i+2:2*i+1 i+2:2*i]+(n+i+3)*(n-i)/2,num2cell(n:-1:1),'UniformOutput',false));
                    Fbase=Fun(n)';
                    Fref=zeros(1,(n-2)*(n-1)/2);
                    for m=1:n-2
                        Fref((m-1)*n-(m-1)*(m+2)/2+1:m*n-m*(m+3)/2)=m*(n+1)-m*(m-1)/2+(2:n-m);
                    end
                    Fcell2{f}=zeros(size(Fcell{f},1)*n^2,3);
                    Ftemp=zeros(1,(n+1)*(n+2)/2);
                    for i=1:size(Fe{f},1)
                        Ftemp([1 n+1 (n+1)*(n+2)/2])=Fcell{f}(i,:);
                        if(Fe{f}(i,1)>0)
                            Ftemp(2:n)=N+((Fe{f}(i,1)-1)*(n-1)+1:Fe{f}(i,1)*(n-1));
                        else
                            Ftemp(2:n)=N+(-Fe{f}(i,1)*(n-1):-1:(-Fe{f}(i,1)-1)*(n-1)+1);
                        end
                        if(Fe{f}(i,2)>0)
                            Ftemp((2:n).*(2*n-(2:n)+3)/2)=N+((Fe{f}(i,2)-1)*(n-1)+1:Fe{f}(i,2)*(n-1));
                        else
                            Ftemp((2:n).*(2*n-(2:n)+3)/2)=N+(-Fe{f}(i,2)*(n-1):-1:(-Fe{f}(i,2)-1)*(n-1)+1);
                        end
                        if(Fe{f}(i,3)>0)
                            Ftemp((1:n-1)*n-((2:n).^2-5*(2:n)+2)/2)=N+(Fe{f}(i,3)*(n-1):-1:(Fe{f}(i,3)-1)*(n-1)+1);
                        else
                            Ftemp((1:n-1)*n-((2:n).^2-5*(2:n)+2)/2)=N+((-Fe{f}(i,3)-1)*(n-1)+1:-Fe{f}(i,3)*(n-1));
                        end
                        Ftemp(Fref)=N+N2+N3+((i-1)*(n-1)*(n-2)/2+1:i*(n-1)*(n-2)/2);
                        Fcell2{f}((i-1)*n^2+1:i*n^2,:)=Ftemp(Fbase);
                    end
                    Vnew=[Vnew;V3]; %#ok<AGROW>
                    N3=N3+size(V3,1);
                case 3
                    V3=nan(3,n-1,n-1,size(Fcell{f},1));
                    if(spherical)
                        for k=1:size(Fcell{f},1)
                            for j=1:n-1
                                if(Fe{f}(k,4)<0)
                                    v21=Ve(:,j,-Fe{f}(k,4));
                                else
                                    v21=Ve(:,n-j,Fe{f}(k,4));
                                end
                                if(Fe{f}(k,2)<0)
                                    v22=Ve(:,n-j,-Fe{f}(k,2));
                                else
                                    v22=Ve(:,j,Fe{f}(k,2));
                                end
                                n2=cross(v21,v22,1);
                                n2=n2/vecnorm(n2,2,1);
                                for i=1:n-1
                                    if(Fe{f}(k,1)<0)
                                        v11=Ve(:,n-i,-Fe{f}(k,1));
                                    else
                                        v11=Ve(:,i,Fe{f}(k,1));
                                    end
                                    if(Fe{f}(k,3)<0)
                                        v12=Ve(:,i,-Fe{f}(k,3));
                                    else
                                        v12=Ve(:,n-i,Fe{f}(k,3));
                                    end
                                    n1=cross(v11,v12,1);
                                    n1=n1/vecnorm(n1,2,1);
                                    nt=cross(n1,n2,1);
                                    nt=nt/vecnorm(nt,2,1);
                                    if(any(dot(repmat(nt,1,2),[v11 v21],1)<dot([v12 v22],[v11 v21],1)))
                                        nt=-nt;
                                    end
                                    V3(:,i,j,k)=nt;
                                end
                            end
                        end
                    else
                        [lambda1,lambda2]=ndgrid(1:n-1,1:n-1);
                        lambda=cat(3,(n-lambda1).*(n-lambda2),lambda1.*(n-lambda2),lambda1.*lambda2,(n-lambda1).*lambda2)/n^2;
                        p=reshape(V(Fcell{f}',:)',[size(V,2) size(Fcell{f}')]);
                        V3=permute(sum(permute(p,[1 4 5 2 3]).*permute(lambda,[4 1 2 3]),4),[1 2 3 5 4]);
                    end
                    V3=reshape(V3,size(V,2),(n-1)^2*size(Fcell{f},1))';
                    Fbase=reshape([1:n;2:n+1;n+3:2*n+2;n+2:2*n+1]+(n+1)*permute(0:n-1,[1 3 2]),4,n^2)';
                    Fref=reshape((2:n)'+(n+1)*(1:n-1),(n-1)^2,1);
                    Fcell2{f}=zeros(size(Fcell{f},1)*n^2,4);
                    Ftemp=zeros(1,(n+1)^2);
                    for i=1:size(Fe{f},1)
                        Ftemp([1 n+1 (n+1)^2 n*(n+1)+1])=Fcell{f}(i,:);
                        if(Fe{f}(i,1)>0)
                            Ftemp(2:n)=N+((Fe{f}(i,1)-1)*(n-1)+1:Fe{f}(i,1)*(n-1));
                        else
                            Ftemp(2:n)=N+(-Fe{f}(i,1)*(n-1):-1:(-Fe{f}(i,1)-1)*(n-1)+1);
                        end
                        if(Fe{f}(i,2)>0)
                            Ftemp((n+1)*(2:n))=N+((Fe{f}(i,2)-1)*(n-1)+1:Fe{f}(i,2)*(n-1));
                        else
                            Ftemp((n+1)*(2:n))=N+(-Fe{f}(i,2)*(n-1):-1:(-Fe{f}(i,2)-1)*(n-1)+1);
                        end
                        if(Fe{f}(i,3)>0)
                            Ftemp((n+1)^2-1:-1:(n+1)*n+2)=N+((Fe{f}(i,3)-1)*(n-1)+1:Fe{f}(i,3)*(n-1));
                        else
                            Ftemp((n+1)^2-1:-1:(n+1)*n+2)=N+(-Fe{f}(i,3)*(n-1):-1:(-Fe{f}(i,3)-1)*(n-1)+1);
                        end
                        if(Fe{f}(i,4)>0)
                            Ftemp((n+1)*(n-1:-1:1)+1)=N+((Fe{f}(i,4)-1)*(n-1)+1:Fe{f}(i,4)*(n-1));
                        else
                            Ftemp((n+1)*(n-1:-1:1)+1)=N+(-Fe{f}(i,4)*(n-1):-1:(-Fe{f}(i,4)-1)*(n-1)+1);
                        end
                        Ftemp(Fref)=N+N2+N3+(i-1)*(n-1)^2+(1:(n-1)^2);
                        Fcell2{f}((i-1)*n^2+1:i*n^2,:)=Ftemp(Fbase);
                    end
                    Vnew=[Vnew;V3]; %#ok<AGROW>
                    N3=N3+size(V3,1);
                otherwise
                    Fbase=[1:n;2:n+1]';
                    Ftemp=zeros(1,n+1);
                    for i=1:size(Fe{f},1)
                        Ftemp([1 n+1])=Fcell{f}(i,:);
                        if(Fe{f}(i,1)>0)
                            Ftemp(2:n)=N+((Fe{f}(i,1)-1)*(n-1)+1:Fe{f}(i,1)*(n-1));
                        else
                            Ftemp(2:n)=N+(-Fe{f}(i,1)*(n-1):-1:(-Fe{f}(i,1)-1)*(n-1)+1);
                        end
                        Fcell2{f}((i-1)*n+1:i*n,:)=Ftemp(Fbase);
                    end
            end
        end
        Fcell2=[Fcell2;Fnonposs];
        Fcell2=Fcell2(~cellfun(@isempty,Fcell2));
        Fnew=cell2mat(cellfun(@(x)[x nan(size(x,1),max(cellfun(@(x)size(x,2),Fcell2))-size(x,2))],Fcell2,'UniformOutput',false));
    end
end
