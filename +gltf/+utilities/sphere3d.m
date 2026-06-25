function [F,V,N,UV,T,B]=sphere3d(varargin)
    % Create a sphere.
    %
    % [F,V,N]=SPHERE3D() returns an icosahedron as faces and vertices, and
    % vertex normals.
    %
    % [F,V,N]=SPHERE3D('polyhedron',POLYHEDRON) returns a sphere by
    % subdividing the faces of the given POLYHEDRON. POLYHEDRON must be one
    % of "tetrahedron", "octahedron", "icosahedron", "cube" or
    % (equivalently) "hexahedron". The latter two return (possibly
    % non-coplanar) quadrilateral surfaces by subdividing square faces of
    % the cube.
    %
    % [F,V,N]=SPHERE3D('resolution',N) returns a sphere by subdividing the
    % faces of the polyhedron into N^2 parts.
    %
    % [F,V,N]=SPHERE3D('uniform',FALSE) returns a sphere with a 20x20 grid
    % of longitude and latitude, with triangular faces.
    %
    % [F,V,N]=SPHERE3D('uniform',FALSE,'resolution',M) returns a sphere
    % with an MxM grid of longitude and latitude if M is a scalar. If M is
    % a 1x2 vector [M P], the sphere is generated with an MxP grid of
    % longitude and latitude. The faces are triangular.
    %
    % [F,V,N]=SPHERE3D('uniform',FALSE,...,'triangles',FALSE) returns a
    % longitude and latitude sphere with rectangular faces.
    %
    % [F,V,N]=SPHERE3D('uniform',FALSE,...,'staggerTriangles',TRUE) returns
    % a latitude and longitude sphere, with triangular faces. The vertices
    % along each alternate latitude are staggered by half a step to make
    % the triangles more regular.
    %
    % [F,V,N,UV,T,B]=SPHERE3D(...,'unwrap',TRUE) unwraps the sphere, taking
    % care of duplicating repeated vertices and faces, and duplicating
    % degenerate vertices. It also returns the vertex UV coordinates,
    % vertex tangents, and vertex bitangents. If this option is TRUE,
    % setting 'STAGGERTRIANGLES' to TRUE does not affect the vertices.
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
    polyhedra=["tetrahedron","octahedron","icosahedron","cube","hexahedron"];
    schlafli=[3 3;3 4;3 5;4 3;4 3];
    ips.addParameter('resolution',[],@isnumeric);
    ips.addParameter('uniform',true,@islogical);
    ips.addParameter('unwrap',false,@islogical);
    ips.addParameter('staggerTriangles',false,@islogical);
    ips.addParameter('triangles',true,@islogical);
    ips.addParameter('polyhedron',missing,@(x) ismember(x,polyhedra));
    
    ips.parse(varargin{:});
    parameters=ips.Results;
    uniform=parameters.uniform;
    PM=parameters.resolution;
    staggerTriangles=parameters.staggerTriangles;
    unwrap=parameters.unwrap;
    triangles=parameters.triangles;
    polyhedron=parameters.polyhedron;
    if(~ismissing(polyhedron))
        symbol=schlafli(polyhedron==polyhedra,:);
    end
    if(uniform)
        if(numel(PM)<1)
            M=1;
        else
            M=PM(1);
        end
        if(~ismissing(polyhedron))
            [F,V]=uniformsphere(M,symbol);
        else
            [F,V]=uniformsphere(M);
        end
        if(unwrap)
            V(abs(V)<eps)=0;
            V(abs(V-1)<eps)=1;
            V(abs(V+1)<eps)=-1;
            angles=atan2(V(:,2),V(:,1));
            quadrant=atan2(sign(V(:,2)),sign(V(:,1)))/pi*4;
            sectors=false(size(V,1),4);
            sectors(and(quadrant>=0,quadrant<=2),1)=true;
            sectors(and(quadrant>=2,quadrant<=4),2)=true;
            sectors(or(quadrant>=4,quadrant<=-2),3)=true;
            sectors(and(quadrant>=-2,quadrant<=0),4)=true;
            sectors(all(sign(V(:,1:2))==0,2),:)=false;
            [F,V,angles,sectors,degenerate]=handleDegenerates(F,V,angles,sectors);
            [F,V,angles,sectors]=handleFaces(F,V,angles,sectors,degenerate);
            [F,V,angles,sectors]=consolidateVertices(F,V,angles,sectors);
            [F,V,angles,~]=removeUnusedVertices(F,V,angles,sectors);
            theta=acos(V(:,3));
            phi=angles;
            A=cos(phi);
            C=sin(phi);
            D=cos(theta).*cos(phi);
            E=cos(theta).*sin(phi);
            G=sin(theta);
            T=[-C A zeros(size(V,1),1) ones(size(V,1),1)];
            B=[-D -E G];
            UV=[angles/2/pi+0.5 acos(V(:,3))/pi];
        else
            UV=[];T=[];B=[];
        end
        N=V;
    else
        if(numel(PM)<1)
            P=20;
            M=20;
        elseif(numel(PM)<2)
            P=PM;
            M=PM;
        else
            P=PM(1);
            M=PM(2);
        end
        theta=linspace(0,180,M+1)*pi/180;
        phi=linspace(-180,180,P+1)*pi/180;
        if(unwrap)
            if(triangles)
                phi2=(phi(1:end-1)+phi(2:end))/2;
                X=[reshape(sin(theta(1)).*cos(phi2'),P,1);reshape(sin(theta(2:end-1)).*cos(phi'),(M-1)*(P+1),1);reshape(sin(theta(end)).*cos(phi2'),P,1)];
                Y=[reshape(sin(theta(1)).*sin(phi2'),P,1);reshape(sin(theta(2:end-1)).*sin(phi'),(M-1)*(P+1),1);reshape(sin(theta(end)).*sin(phi2'),P,1)];
                Z=[reshape(repmat(cos(theta(1)),P,1),P,1);reshape(repmat(cos(theta(2:end-1)),P+1,1),(M-1)*(P+1),1);reshape(repmat(cos(theta(end)),P,1),P,1)];
                R=[phi2'/2/pi+0.5;repmat(phi'/2/pi+0.5,M-1,1);phi2'/2/pi+0.5];
                S=[repmat(theta(1)/pi,P,1);reshape(repmat(theta(2:end-1)/pi,P+1,1),(M-1)*(P+1),1);repmat(theta(end)/pi,P,1)];
                A=[cos(phi2');repmat(cos(phi'),M-1,1);cos(phi2')];
                C=[sin(phi2');repmat(sin(phi'),M-1,1);sin(phi2')];
                D=[reshape(cos(theta(1)).*cos(phi2'),P,1);reshape(cos(theta(2:end-1)).*cos(phi'),(M-1)*(P+1),1);reshape(cos(theta(end)).*cos(phi2'),P,1)];
                E=[reshape(cos(theta(1)).*sin(phi2'),P,1);reshape(cos(theta(2:end-1)).*sin(phi'),(M-1)*(P+1),1);reshape(cos(theta(end)).*sin(phi2'),P,1)];
                G=[reshape(repmat(sin(theta(1)),P,1),P,1);reshape(repmat(sin(theta(2:end-1)),P+1,1),(M-1)*(P+1),1);reshape(repmat(sin(theta(end)),P,1),P,1)];
                F=[[1:P;P+1:2*P;P+2:2*P+1]';reshape([1:P;P+2:2*P+1;P+3:2*P+2;P+3:2*P+2;2:P+1;1:P]+permute(1:M-2,[1 3 2])*(P+1)-1,3,2*P*(M-2))';[1:P;P+2:2*P+1;2:P+1]'+P+(M-2)*(P+1)];
            else
                X=reshape(sin(theta).*cos(phi'),(M+1)*(P+1),1);
                Y=reshape(sin(theta).*sin(phi'),(M+1)*(P+1),1);
                Z=reshape(repmat(cos(theta),P+1,1),(M+1)*(P+1),1);
                R=repmat(phi'/2/pi+0.5,M+1,1);
                S=reshape(repmat(theta/pi,P+1,1),(M+1)*(P+1),1);
                A=repmat(cos(phi'),M+1,1);
                C=repmat(sin(phi'),M+1,1);
                D=reshape(cos(theta).*cos(phi'),(M+1)*(P+1),1);
                E=reshape(cos(theta).*sin(phi'),(M+1)*(P+1),1);
                G=reshape(repmat(sin(theta),P+1,1),(M+1)*(P+1),1);
                F=reshape([1:P;P+2:2*P+1;P+3:2*P+2;2:P+1]+permute(0:M-1,[1 3 2])*(P+1),4,P*M)';
            end
        else
            phi=phi(1:end-1);
            if(staggerTriangles)
                dphi=pi/P*mod(1:M-1,2);
                X=[0;reshape(sin(theta(2:end-1)).*cos(phi'+dphi),(M-1)*P,1);0];
                Y=[0;reshape(sin(theta(2:end-1)).*sin(phi'+dphi),(M-1)*P,1);0];
                Z=[1;reshape(repmat(cos(theta(2:end-1)),P,1),(M-1)*P,1);-1];
                A=[1;reshape(repmat(cos(phi),1,M-1),(M-1)*P,1);-1];
                C=[0;reshape(repmat(sin(phi),1,M-1),(M-1)*P,1);0];
                D=[1;reshape(cos(theta(2:end-1)).*cos(phi'),(M-1)*P,1);1];
                E=[0;reshape(cos(theta(2:end-1)).*sin(phi'),(M-1)*P,1);0];
                G=[0;reshape(repmat(sin(theta(2:end-1)),P,1),(M-1)*P,1);0];
                R=[0;reshape(repmat(phi/2/pi+0.5,1,M-1),(M-1)*P,1);0];
                S=[0;reshape(repmat(theta(2:end-1)/pi,P,1),(M-1)*P,1);1];
                Ftemp=repmat(cat(3,[1:P;P+1:2*P;P+2:2*P P+1;P+2:2*P P+1;2:P 1;1:P],[1:P;2*P P+1:2*P-1;P+1:2*P;P+1:2*P;2:P 1;1:P]),1,1,ceil(M/2-1));
                Ftemp=Ftemp(:,:,1:M-2);
                F=[[ones(1,P);2:P+1;3:P+1 2]';reshape(Ftemp+1+permute((0:M-3)*P,[1 3 2]),3,2*P*(M-2))';[(P+1)*ones(1,P);2:P 1;1:P]'+(M-2)*P+1];
            else
                X=[0;reshape(sin(theta(2:end-1)).*cos(phi'),(M-1)*P,1);0];
                Y=[0;reshape(sin(theta(2:end-1)).*sin(phi'),(M-1)*P,1);0];
                Z=[1;reshape(repmat(cos(theta(2:end-1)),P,1),(M-1)*P,1);-1];
                A=[1;reshape(repmat(cos(phi),1,M-1),(M-1)*P,1);-1];
                C=[0;reshape(repmat(sin(phi),1,M-1),(M-1)*P,1);0];
                D=[1;reshape(cos(theta(2:end-1)).*cos(phi'),(M-1)*P,1);1];
                E=[0;reshape(cos(theta(2:end-1)).*sin(phi'),(M-1)*P,1);0];
                G=[0;reshape(repmat(sin(theta(2:end-1)),P,1),(M-1)*P,1);0];
                R=[0;reshape(repmat(phi/2/pi+0.5,1,M-1),(M-1)*P,1);0];
                S=[0;reshape(repmat(theta(2:end-1)/pi,P,1),(M-1)*P,1);1];
                if(triangles)
                    F=[[ones(1,P);2:P+1;3:P+1 2]';reshape([1:P;P+1:2*P;P+2:2*P P+1;P+2:2*P P+1;2:P 1;1:P]+1+permute((0:M-3)*P,[1 3 2]),3,2*P*(M-2))';[(P+1)*ones(1,P);2:P 1;1:P]'+(M-2)*P+1];
                else
                    F=[[ones(1,P);2:P+1;3:P+1 2;ones(1,P)]';reshape([1:P;P+1:2*P;P+2:2*P P+1;2:P 1]+1+permute((0:M-3)*P,[1 3 2]),4,P*(M-2))';[(P+1)*ones(1,P);2:P 1;1:P;(P+1)*ones(1,P)]'+(M-2)*P+1];
                end
            end
        end
        V=[X Y Z];
        N=[X Y Z];
        T=[-C A zeros(size(X)) ones(size(X))];
        B=[-D -E G];
        UV=[R S];
    end
end

function [F,V,angles,sectors]=consolidateVertices(F,V,angles,sectors)
    [~,ia,ic]=unique([V angles],'rows');
    V=V(ia,:);
    angles=angles(ia,:);
    sectors=sectors(ia,:);
    F=ic(F);
end

function [F,V,angles,sectors,varargout]=handleFaces(F,V,angles,sectors,degenerate,varargin)
    out=cell(min(nargin-4,nargout-4),1);
    for i=1:numel(out)
        out{i}=varargin{i};
    end
    sF=false(size(F,1),size(F,2),size(sectors,2));
    for i=1:size(sectors,2)
        temp=sF(:,:,i);
        temp(~isnan(F))=sectors(F(~isnan(F)),i);
        sF(:,:,i)=temp;
    end
    duplicatingFaces=find(and(any(sF(:,:,2),2),any(and(~sF(:,:,2),sF(:,:,3)),2)))';
    duplicatingFaces_master=duplicatingFaces;
    two=false(numel(duplicatingFaces_master),1);
    three=false(numel(duplicatingFaces_master),1);
    for i=1:numel(duplicatingFaces_master)
        f=duplicatingFaces_master(i);
        degen=ismember(F(f,:),find(degenerate));
        if(any(degen))
            if(sum(angles(F(f,~ismember(F(f,:),find(degenerate)))))<0)
                two(i)=true;
            else
                three(i)=true;
            end
        else
            if(sum(sF(f,:,2),2)>=sum(sF(f,:,3),2))
                two(i)=true;
            else
                three(i)=true;
            end
        end
    end
    duplicatingFaces=duplicatingFaces_master(two);
    [duplicatingVertices,~,ic]=unique(F(duplicatingFaces,:)');
    duplicatingVertices=duplicatingVertices(~isnan(duplicatingVertices));
    Fnew=reshape(ic,size(F,2),[])';
    newV1=V(duplicatingVertices,:);
    newAngles1=angles(duplicatingVertices,:);
    newSectors1=sectors(duplicatingVertices,:);
    newAngles1(~newSectors1(:,2))=newAngles1(~newSectors1(:,2))+2*pi;
    newSectors1(~newSectors1(:,2),3)=false;
    newSectors1(~newSectors1(:,2),2)=true;
    F=[F;Fnew+size(V,1)];
    V=[V;newV1];
    angles=[angles;newAngles1];
    sectors=[sectors;newSectors1];
    for i=1:numel(out)
        out{i}=[out{i};out{i}(duplicatingVertices,:)];
    end
    duplicatingFaces=duplicatingFaces_master(three);
    [duplicatingVertices,~,ic]=unique(F(duplicatingFaces,:)');
    duplicatingVertices=duplicatingVertices(~isnan(duplicatingVertices));
    Fnew=reshape(ic,size(F,2),[])';
    newV2=V(duplicatingVertices,:);
    newAngles2=angles(duplicatingVertices,:);
    newSectors2=sectors(duplicatingVertices,:);
    newAngles2(newSectors2(:,2))=newAngles2(newSectors2(:,2))-2*pi;
    newSectors2(newSectors2(:,2),3)=true;
    newSectors2(newSectors2(:,2),2)=false;
    F=[F;Fnew+size(V,1)];
    V=[V;newV2];
    angles=[angles;newAngles2];
    sectors=[sectors;newSectors2];
    for i=1:numel(out)
        out{i}=[out{i};out{i}(duplicatingVertices,:)];
    end
    F=F(setdiff(1:size(F,1),duplicatingFaces_master),:);

    varargout=cell(numel(out),1);
    for i=1:numel(out)
        varargout{i}=out{i};
    end
end

function [F,varargout]=removeUnusedVertices(F,varargin)
    Ftemp=F(~isnan(F));
    [newidx,~,ic]=unique(Ftemp);
    F(~isnan(F))=ic;
    varargout=cell(min(nargin,nargout)-1,1);
    for i=1:numel(varargout)
        varargout{i}=varargin{i}(newidx,:);
    end
end

function [F,V,angles,sectors,degenerate]=handleDegenerates(F,V,angles,sectors)
    degenerate=~any(sectors,2);
    for idx=find(~any(sectors,2))'
        vCount=size(V,1);
        V=[V;repmat(V(idx,:),nnz(any(F==idx,2)),1)]; %#ok<AGROW>
        degenerate=[degenerate;repmat(degenerate(idx,:),nnz(any(F==idx,2)),1)]; %#ok<AGROW>
        angles=[angles;nan(nnz(any(F==idx,2)),1)]; %#ok<AGROW>
        sectors=[sectors;false(nnz(any(F==idx,2)),4)]; %#ok<AGROW>
        count=1;
        for f=find(any(F==idx,2))'
            if(all(any(sectors(F(f,F(f,:)~=idx),2:3))))
                angles(count+vCount)=mean(angles(F(f,F(f,:)~=idx)))+pi;
                sectors(count+vCount,2)=true;
            else
                angles(count+vCount)=mean(angles(F(f,F(f,:)~=idx)));
                quadrant=angles(count+vCount)/pi*4;
                sectortemp=false(1,4);
                sectortemp(and(quadrant>=0,quadrant<=2),1)=true;
                sectortemp(and(quadrant>=2,quadrant<=4),2)=true;
                sectortemp(or(quadrant>=4,quadrant<=-2),3)=true;
                sectortemp(and(quadrant>=-2,quadrant<=0),4)=true;
                sectors(count+vCount,:)=sectortemp;
            end
            F(f,F(f,:)==idx)=count+vCount;
            count=count+1;
        end
    end
end

function [F,V]=uniformsphere(N,symbol)
    if(nargin<2)
        [V,~,F]=gltf.utilities.polytope(3,5);
        [F,V]=gltf.utilities.subDivideFaces(F,V,'resolution',N,'spherical',true);
    else
        [V,~,F]=gltf.utilities.polytope(symbol);
        [F,V]=gltf.utilities.subDivideFaces(F,V,'resolution',N,'spherical',true);
    end
end
