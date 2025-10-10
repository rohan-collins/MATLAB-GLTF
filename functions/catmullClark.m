function [F,V,varargout]=catmullClark(F,V,varargin)
    % Create a subdivision surface by refining the given mesh using the
    % Catmull-Clark algorithm.
    %
    % [F,V]=CATMULLCLARK(F,V) subdivides the given mesh by one level using
    % the Catmull-Clark algorithm. F will be returned as quadrilaterals,
    % which in general will not be planar, as is default for the
    % Catmull-Clark algorithm.
    %
    % [...]=CATMULLCLARK(...,'level',LEVELS) subdivides the given mesh
    % recursively LEVELS times.
    %
    % [...,UV]=CATMULLCLARK(...,'TEXCOORD',UV) subdivides the given UV
    % coordinates along with the vertices, while handling vertices with
    % same XYZ coordinates but different UV coordinates.
    %
    % [...,J,W]=CATMULLCLARK(...,'JOINTS',J,'WEIGHTS',W) subdivides the
    % mesh and returns the influence of the original vertices as joints and
    % weights for skinned animation.
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
    ips=inputParser;
    ips.addParameter('TEXCOORD',[],@isnumeric);
    ips.addParameter('JOINTS',[],@isnumeric);
    ips.addParameter('WEIGHTS',[],@isnumeric);
    ips.addParameter('level',1,@(x)GLTF.validateInteger(x,0,inf));
    ips.parse(varargin{:});
    parameters=ips.Results;
    UV=parameters.TEXCOORD;
    J=parameters.JOINTS;
    W=parameters.WEIGHTS;
    level=parameters.level;
    if(and(~isempty(J),~isempty(W)))
        JW=toJW(J,W);
    else
        JW=[];
    end
    for l=1:level
        F1=F;
        if(isempty(UV))
            V1=V;
            if(isempty(JW))
                JW=eye(size(V1,1));
            end
        else
            [V1,ia,ic]=unique(V,"rows","stable");
            VV1=speye(size(V1,1));
            VV1=VV1(ic,:);
            IA=false(size(V,1),1);
            IA(ia)=true;
            if(isempty(JW))
                JW=eye(size(V,1));
                JW=JW(IA,IA);
            else
                JW=JW(IA,:);
            end
            F1(~isnan(F1))=ic(F(~isnan(F)));
        end
        
        F2=F;
        F3=F1;
        for i=1:size(F,1)
            F2(i,~isnan(F(i,:)))=circshift(F(i,~isnan(F(i,:))),-1,2);
            F3(i,~isnan(F1(i,:)))=circshift(F1(i,~isnan(F1(i,:))),-1,2);
        end
        E=reshape(permute(cat(3,F,F2),[3 2 1]),2,numel(F))';
        E1=reshape(permute(cat(3,F1,F3),[3 2 1]),2,numel(F1))';
        clear F3;
        
        E2=E(~any(isnan(E),2),:);
        E=sort(E2,2);
        clear E2;
        [E,~,ic]=unique(E,"rows","stable");
        E3=E1(~any(isnan(E1),2),:);
        E1=sort(E3,2);
        clear E3;
        [E1,~,ic1]=unique(E1,"rows","stable");
        EE1=sparse(ic,ic1,true,size(E,1),size(E1,1));
        
        dirF=F<F2;
        clear F2;
        
        FE=F';
        FE(~isnan(FE))=ic;
        clear ic;
        FE2=FE;
        FE=sparse(cell2mat(cellfun(@(x,y)repmat(x,y,1),num2cell(1:size(F,1))',num2cell(sum(~isnan(F),2)),'UniformOutput',false)),FE2(~isnan(FE2)),true,size(F,1),size(E,1));
        
        F1E1=F1';
        F1E1(~isnan(F1E1))=ic1;
        clear ic1;
        FE3=F1E1;
        F1E1=sparse(cell2mat(cellfun(@(x,y)repmat(x,y,1),num2cell(1:size(F1,1))',num2cell(sum(~isnan(F1),2)),'UniformOutput',false)),FE3(~isnan(FE3)),true,size(F1,1),size(E1,1));
        clear FE3;
        
        VE=sparse(E(:)',[1:size(E,1) 1:size(E,1)],true,size(V,1),size(E,1));
        V1E1=sparse(E1(:)',[1:size(E1,1) 1:size(E1,1)],true,size(V1,1),size(E1,1));
        
        [I,J]=find(~isnan(F));
        J=F(sub2ind(size(F),I,J));
        VF=sparse(J,I,true,size(V,1),size(F,1));
        clear I J;

        [I,J]=find(~isnan(F1));
        J=F1(sub2ind(size(F1),I,J));
        V1F1=sparse(J,I,true,size(V1,1),size(F1,1));
        clear I J;
        
        dir2=dirF'>0;
        [~,J]=find(and(dirF'==1,~isnan(dirF')));
        dirF=sparse(J,FE2(dir2),true,size(F,1),size(E,1));
        clear dir2 J FE2;
        
        dirV=sparse(E(:,1),1:size(E,1),true,size(V,1),size(E,1));
        clear E;
        
        temp=(V1F1./sum(V1F1));
        FP=temp'*V1;
        JW_F=temp'*JW;
        JW_E=(V1E1./sum(V1E1))'*JW;
        EP=(F1E1'*FP+V1E1'*V1)/4;
        clear F1E1 temp;
        EMP=V1E1'*V1/2;
        FF=(V1F1./sum(V1F1,2))*FP;
        R=V1E1./sum(V1E1,2)*EMP;
        clear V1E1 EMP;
        n=sum(V1F1,2);
        clear V1F1;
        VP=(FF+2*R+(n-3).*V1)./n;
        clear FF R n V1;
        if(isempty(UV))
            newV=[VP;FP;EP];
            newJW=[JW;JW_F;JW_E];
        else
            newV=[VV1*VP;FP;EE1*EP];
            newJW=[VV1*JW;JW_F;EE1*JW_E];
            clear VV1 EE1;
        end
        clear VP FP EP;

        if(~isempty(UV))
            FUV=(VF'./sum(VF)')*UV;
            EUV=VE'*UV/2;
            newUV=[UV;FUV;EUV];
            clear FUV EUV;
        end
        
        [I,J]=find(VF);
        n=size(V,1);
        m=size(F,1);
        newF=nan(nnz(VF),4);
        for k=1:nnz(VF)
            i=I(k);
            j=J(k);
            newF(k,:)=[i n+m+find(and(and(VE(i,:),FE(j,:)),~xor(dirV(i,:),dirF(j,:)))) n+j n+m+find(and(and(VE(i,:),FE(j,:)),xor(dirV(i,:),dirF(j,:))))];
        end
        clear i I i I n m VE FE dirV dirF;
        F=newF;
        V=newV;
        JW=newJW;
        if(~isempty(UV))
            UV=newUV;
            clear newUV;
        end
        clear newF newV;
    end
    [J,W]=fromJW(JW);
    if(isempty(UV))
        varargout={J,W};
    else
        varargout={UV,J,W};
    end
end

function JW=toJW(J,W)
    % Convert given joints and weights matrices to a sparse weighted
    % incidence matrix.
    tempJ=reshape(J,size(J,1),[]);
    tempW=reshape(W,size(W,1),[]);
    present=~all(tempW==0,1);
    tempW=tempW(:,present);
    tempJ=tempJ(:,present);
    I=repmat((1:size(tempJ,1))',1,nnz(present));
    JW=sparse(I(:),tempJ(:)+1,tempW);
end

function [J,W]=fromJW(JW)
    % Convert given sparse weighted incidence matrix to joints and weights
    % format.
    [J,I]=find(JW');
    tempW=sparse(I,sum(cumsum(I==1:size(JW,1)).*(I==1:size(JW,1)),2),JW(sub2ind(size(JW),I,J)));
    tempJ=sparse(I,sum(cumsum(I==1:size(JW,1)).*(I==1:size(JW,1)),2),J-1);
    [W,I]=sort(tempW,2,"descend");
    J=repmat((1:size(tempW,1))',1,size(tempW,2));
    J=sub2ind(size(tempW),J,I);
    J=tempJ(J);
    W=full(W);
    J=full(J);
    W=reshape([W zeros(size(W,1),4-mod(size(W,2)-1,4)-1)],size(W,1),4,[]);
    J=reshape([J zeros(size(J,1),4-mod(size(J,2)-1,4)-1)],size(J,1),4,[]);
end