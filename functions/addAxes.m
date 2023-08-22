function [gltf,ax_node]=addAxes(gltf,varargin)
    % Add axes to GLTF model.
    %
    % GLTF=ADDAXES(GLTF) adds all 12 axes of the current axis object to the
    % GLTF object in white colour and returns the new GLTF object.
    %
    % [GLTF,NODE]=ADDAXES(...) also returns the index of the parent node of
    % the axis elements.
    %
    % ADDAXES(...,'axisIds',axisIds) specifies a list of axes to include in
    % the model. Each element of axisIds should be one of the following:
    %   "x00":  X axis at minimum Y and minimum Z
    %   "x10":  X axis at maximum Y and minimum Z
    %   "x01":  X axis at minimum Y and maximum Z
    %   "x11":  X axis at maximum Y and maximum Z
    %   "0y0":  Y axis at minimum X and minimum Z
    %   "0y1":  Y axis at minimum X and maximum Z
    %   "1y0":  Y axis at maximum X and minimum Z
    %   "1y1":  Y axis at maximum X and maximum Z
    %   "00z":  Z axis at minimum X and minimum Y
    %   "10z":  Z axis at maximum X and minimum Y
    %   "01z":  Z axis at minimum X and maximum Y
    %   "11z":  Z axis at maximum X and maximum Y
    %
    % ADDAXES(...,'gridIds',gridIds) specifies a list of grids to include
    % in the model. Grids are drawn at major ticks. Each element of gridIds
    % should be one of the following:
    %   "xy0":  XY-plane-filling grid at minimum Z
    %   "xy1":  XY-plane-filling grid at maximum Z
    %   "x0z":  XZ-plane-filling grid at minimum Y
    %   "x0z":  XZ-plane-filling grid at maximum Y
    %   "0yz":  YZ-plane-filling grid at minimum X
    %   "1yz":  YZ-plane-filling grid at maximum X
    %   "xyz":  Space-filling grid
    %
    % ADDAXES(...,'backPlanes',backPlanes) specifies a list of grids to
    % include in the model. Grids are drawn at major ticks. Each element of
    % backPlanes should be one of the following:
    %   "xy0":  XY plane at minimum Z
    %   "xy1":  XY plane at maximum Z
    %   "x0z":  XZ plane at minimum Y
    %   "x0z":  XZ plane at maximum Y
    %   "0yz":  YZ plane at minimum X
    %   "1yz":  YZ plane at maximum X
    %
    % ADDAXES(...,'fontFile',fontFile) specifies the font file to use. The
    % output of READFONTFILE can be passed instead of the filename to avoid
    % re-reading of large font files.
    %
    % ADDAXES(...,'axis',axis) specifies the axis object to use for axis
    % labels and tick positions and lablels.
    %
    % ADDAXES(...,'baseRotation',baseRotation) specifies the base rotation
    % matrix to use for the axes cube.
    %
    % ADDAXES(...,'plotAspect',false) prevents scaling the axis using
    % MATLAB plotbox aspect.
    %
    % ADDAXES(...,'dataAspect',false) prevents scaling the axis using
    % MATLAB data aspect.
    %
    % ADDAXES(...,'scaleFactor',scaleFactor) scales the tick lengths, text
    % size, and distances between them by a single factor.
    %
    % ADDAXES(...,'letterHeight',letterHeight) specifies the height of the
    % text for a unit cube.
    %
    % ADDAXES(...,'tickLength',tickLength) specifies the length of the
    % ticks for a unit cube.
    %
    % ADDAXES(...,'tickLabelDistance',tickLabelDistance) specifies the
    % distance of the tick label from the axis for a unit cube.
    %
    % ADDAXES(...,'axisLabelDistance',axisLabelDistance) specifies the
    % distance of the axis label from the axis for a unit cube.
    %
    if(nargin>0)
        ax_id=["x00";"x10";"x01";"x11";"0y0";"0y1";"1y0";"1y1";"00z";"10z";"01z";"11z"];
        grid_id=["xy0","xy1","x0z","x1z","0yz","1yz","xyz"];
        ips=inputParser;
        ips.StructExpand=false;
        ips.addParameter('axis',[],@(x) isa(x,'matlab.graphics.axis.Axes'));
        ips.addParameter('baseRotation',eye(3),@(x) and(isnumeric(x),and(ismatrix(x),all(size(x)==[3 3]))));
        ips.addParameter('plotAspect',false,@islogical);
        ips.addParameter('dataAspect',false,@islogical);
        ips.addParameter('scaleFactor',1,@isnumeric);
        ips.addParameter('letterHeight',0.04,@isnumeric);
        ips.addParameter('tickLength',0.03,@isnumeric);
        ips.addParameter('tickLabelDistance',0.05,@isnumeric);
        ips.addParameter('axisLabelDistance',0.09,@isnumeric);
        ips.addParameter('axisIds',ax_id,@(x) validateAxisIds(x,ax_id));
        ips.addParameter('gridIds',[],@(x) validateAxisIds(x,grid_id));
        ips.addParameter('skeleton',false,@islogical);
        ips.addParameter('backPlanes',[],@(x) validateAxisIds(x,grid_id(1:6)));
        ips.addParameter('fontFile',"ARIALUNI_1.svg",@(x) or(isstring(x),isstruct(x)));
        ips.parse(varargin{:});
        parameters=ips.Results;
        plane_delta=1e-4;

        scaleFactor=parameters.scaleFactor;
        plotAspect=parameters.plotAspect;
        dataAspect=parameters.dataAspect;
        fontFile=parameters.fontFile;
        if(isstring(fontFile))
            fontFile=readFontFile(fontFile);
        end
        base_rotation=parameters.baseRotation;
        ax_h=parameters.axis;
        if(isempty(ax_h))
            ax_h=gca;
        end
        if(and(plotAspect,dataAspect))
            s=pbaspect(ax_h)./daspect(ax_h);
        elseif(plotAspect)
            s=pbaspect(ax_h);
        elseif(dataAspect)
            s=1./daspect(ax_h);
        else
            s=ones(1,3);
        end
        line_h=parameters.letterHeight*scaleFactor;
        tick_l=parameters.tickLength*scaleFactor;
        ticklabel_l=parameters.tickLabelDistance*scaleFactor;
        axlabel_l=parameters.axisLabelDistance*scaleFactor;
        axisIds=parameters.axisIds(:);
        gridIds=parameters.gridIds;
        backPlanes=parameters.backPlanes;
        skeleton=parameters.skeleton;

        needed_axes=any([contains(axisIds,"x") contains(axisIds,"y") contains(axisIds,"z")],1);
        ax_dir=zeros(size(axisIds,1),3);
        x=extractBefore(axisIds,2)=="x";
        ax_dir(x,2:3)=char(extractAfter(axisIds(x),1))*2-97;
        y=extractBetween(axisIds,2,2)=="y";
        ax_dir(y,[1 3])=char(extractBefore(axisIds(y),2)+extractAfter(axisIds(y),2))*2-97;
        z=extractAfter(axisIds,2)=="z";
        ax_dir(z,1:2)=char(extractBefore(axisIds(z),3))*2-97;

        clear locB;

        V=(flip(dec2bin(7:-1:0)*2,2)-97)/sqrt(3);
        F=[1 2 4 3;5 7 8 6;1 5 6 2;2 6 8 4;4 8 7 3;3 7 5 1];
        Fbox=[4 8 6;6 2 4;7 3 1;1 5 7;7 8 4;4 3 7;1 2 6;6 5 1;6 8 7;7 5 6;4 2 1;1 3 4];
        E(:,:,1)=F;
        E(:,:,2)=F(:,[2:end 1]);
        E=unique(sort(reshape(permute(E,[3 2 1]),2,[]),1)','rows');

        V=V*sqrt(3)/2+0.5;
        ax=axis(ax_h);
        ax=reshape(ax,2,3);
        Vbox=V.*diff(ax)+ax(1,:);

        tick=string(char(88:90)')+"Tick";
        ticklabel=tick+"Label";
        axislabel=string(char(88:90)')+"Label";
        ticklabelrotation=ticklabel+"Rotation";
        colour=string(char(88:90)')+"Color";

        colourfactors=nan(6,3);
        for i=1:3
            if(needed_axes(i))
                colourfactors(i,:)=ax_h.(colour(i));
                colourfactors(i+3,:)=ax_h.(axislabel(i)).Color;
            end
        end
        mat_idx=nan(6,1);
        [colourfactors,~,mat_idx2]=unique(colourfactors,'rows');
        colourfactors=colourfactors(~any(isnan(colourfactors),2),:);
        mat_idx(needed_axes)=mat_idx2(needed_axes);
        mat_idx(find(needed_axes)+3)=mat_idx2(find(needed_axes)+3);
        mat_idx2=nan(size(colourfactors,1),1);
        for i=1:size(colourfactors,1)
            mat_idx2(i)=gltf.addMaterial('baseColorFactor',colourfactors(i,:));
        end
        mat_idx(~isnan(mat_idx))=mat_idx2(mat_idx(~isnan(mat_idx)));

        if(~isempty(gridIds))
            if(ax_h.GridAlpha<1)
                gridlines_mat=gltf.addMaterial('baseColorFactor',[ax_h.GridColor ax_h.GridAlpha]);
            else
                gridlines_mat=gltf.addMaterial('baseColorFactor',ax_h.GridColor);
            end
            gridlinesNodes=nan(1,7);
            if(any(ismember(["0yz","1yz"],gridIds)))
                [A,B]=meshgrid(ax_h.(tick(2)),ax(:,3));
                Vg1=[zeros(numel(ax_h.(tick(2)))*2,1) A(:) B(:)];
                Eg1=reshape(1:numel(ax_h.(tick(2)))*2,2,numel(ax_h.(tick(2))))';
                [A,B]=meshgrid(ax_h.(tick(3)),ax(:,2));
                Vg2=[zeros(numel(ax_h.(tick(3)))*2,1) B(:) A(:)];
                Eg2=reshape(1:numel(ax_h.(tick(3)))*2,2,numel(ax_h.(tick(3))))';
                if(skeleton)
                    Js=zeros(size(Vg1,1),4);
                    Ws=[ones(size(Vg1,1),1) zeros(size(Vg1,1),3)];
                    yzmesh=gltf.addMesh(Vg1.*s*base_rotation,'indices',Eg1,'mode',"LINES",'material',gridlines_mat,'WEIGHTS',Ws,'JOINTS',Js);
                    Js=zeros(size(Vg2,1),4);
                    Ws=[ones(size(Vg2,1),1) zeros(size(Vg2,1),3)];
                    gltf.addPrimitiveToMesh(yzmesh,Vg2.*s*base_rotation,'indices',Eg2,'mode',"LINES",'material',gridlines_mat,'WEIGHTS',Ws,'JOINTS',Js);
                    if(ismember("0yz",gridIds))
                        gridlinesNodes(1)=gltf.addNode('translation',[1 0 0]*ax(1,1).*s*base_rotation,'addToScene',false);
                        skin_idx=gltf.addSkin(gridlinesNodes(1),'inverseBindMatrices',reshape(eye(4),16,1)');
                        gltf.addNode('mesh',yzmesh,'skin',skin_idx,'children',gridlinesNodes(1));
                    end
                    if(ismember("1yz",gridIds))
                        gridlinesNodes(2)=gltf.addNode('translation',[1 0 0]*ax(2,1).*s*base_rotation,'addToScene',false);
                        skin_idx=gltf.addSkin(gridlinesNodes(2),'inverseBindMatrices',reshape(eye(4),16,1)');
                        gltf.addNode('mesh',yzmesh,'skin',skin_idx,'children',gridlinesNodes(2));
                    end
                else
                    yzmesh=gltf.addMesh(Vg1.*s*base_rotation,'indices',Eg1,'mode',"LINES",'material',gridlines_mat);
                    gltf.addPrimitiveToMesh(yzmesh,Vg2.*s*base_rotation,'indices',Eg2,'mode',"LINES",'material',gridlines_mat);
                    if(ismember("0yz",gridIds))
                        gridlinesNodes(1)=gltf.addNode('mesh',yzmesh,'translation',[1 0 0]*ax(1,1).*s*base_rotation,'addToScene',false);
                    end
                    if(ismember("1yz",gridIds))
                        gridlinesNodes(2)=gltf.addNode('mesh',yzmesh,'translation',[1 0 0]*ax(2,1).*s*base_rotation,'addToScene',false);
                    end
                end
            end
            if(any(ismember(["x0z","x1z"],gridIds)))
                [A,B]=meshgrid(ax_h.(tick(3)),ax(:,1));
                Vg1=[B(:) zeros(numel(ax_h.(tick(3)))*2,1) A(:)];
                Eg1=reshape(1:numel(ax_h.(tick(3)))*2,2,numel(ax_h.(tick(3))))';
                [A,B]=meshgrid(ax_h.(tick(1)),ax(:,3));
                Vg2=[A(:) zeros(numel(ax_h.(tick(1)))*2,1) B(:)];
                Eg2=reshape(1:numel(ax_h.(tick(1)))*2,2,numel(ax_h.(tick(1))))';
                if(skeleton)
                    Js=zeros(size(Vg1,1),4);
                    Ws=[ones(size(Vg1,1),1) zeros(size(Vg1,1),3)];
                    xzmesh=gltf.addMesh(Vg1.*s*base_rotation,'indices',Eg1,'mode',"LINES",'material',gridlines_mat,'WEIGHTS',Ws,'JOINTS',Js);
                    Js=zeros(size(Vg2,1),4);
                    Ws=[ones(size(Vg2,1),1) zeros(size(Vg2,1),3)];
                    gltf.addPrimitiveToMesh(xzmesh,Vg2.*s*base_rotation,'indices',Eg2,'mode',"LINES",'material',gridlines_mat,'WEIGHTS',Ws,'JOINTS',Js);
                    if(ismember("0yz",gridIds))
                        gridlinesNodes(3)=gltf.addNode('translation',[0 1 0]*ax(1,1).*s*base_rotation,'addToScene',false);
                        skin_idx=gltf.addSkin(gridlinesNodes(3),'inverseBindMatrices',reshape(eye(4),16,1)');
                        gltf.addNode('mesh',xzmesh,'skin',skin_idx,'children',gridlinesNodes(3));
                    end
                    if(ismember("1yz",gridIds))
                        gridlinesNodes(4)=gltf.addNode('translation',[0 1 0]*ax(2,1).*s*base_rotation,'addToScene',false);
                        skin_idx=gltf.addSkin(gridlinesNodes(4),'inverseBindMatrices',reshape(eye(4),16,1)');
                        gltf.addNode('mesh',xzmesh,'skin',skin_idx,'children',gridlinesNodes(4));
                    end
                else
                    xzmesh=gltf.addMesh(Vg1.*s*base_rotation,'indices',Eg1,'mode',"LINES",'material',gridlines_mat);
                    gltf.addPrimitiveToMesh(xzmesh,Vg2.*s*base_rotation,'indices',Eg2,'mode',"LINES",'material',gridlines_mat);
                    if(ismember("x0z",gridIds))
                        gridlinesNodes(3)=gltf.addNode('mesh',xzmesh,'translation',[0 1 0]*ax(1,2).*s*base_rotation,'addToScene',false);
                    end
                    if(ismember("x1z",gridIds))
                        gridlinesNodes(4)=gltf.addNode('mesh',xzmesh,'translation',[0 1 0]*ax(2,2).*s*base_rotation,'addToScene',false);
                    end
                end
            end
            if(any(ismember(["xy0","xy1"],gridIds)))
                [A,B]=meshgrid(ax_h.(tick(1)),ax(:,2));
                Vg1=[A(:) B(:) zeros(numel(ax_h.(tick(1)))*2,1)];
                Eg1=reshape(1:numel(ax_h.(tick(1)))*2,2,numel(ax_h.(tick(1))))';
                [A,B]=meshgrid(ax_h.(tick(2)),ax(:,1));
                Vg2=[B(:) A(:) zeros(numel(ax_h.(tick(2)))*2,1)];
                Eg2=reshape(1:numel(ax_h.(tick(2)))*2,2,numel(ax_h.(tick(2))))';
                if(skeleton)
                    Js=zeros(size(Vg1,1),4);
                    Ws=[ones(size(Vg1,1),1) zeros(size(Vg1,1),3)];
                    xymesh=gltf.addMesh(Vg1.*s*base_rotation,'indices',Eg1,'mode',"LINES",'material',gridlines_mat,'WEIGHTS',Ws,'JOINTS',Js);
                    Js=zeros(size(Vg2,1),4);
                    Ws=[ones(size(Vg2,1),1) zeros(size(Vg2,1),3)];
                    gltf.addPrimitiveToMesh(xymesh,Vg2.*s*base_rotation,'indices',Eg2,'mode',"LINES",'material',gridlines_mat,'WEIGHTS',Ws,'JOINTS',Js);
                    if(ismember("0yz",gridIds))
                        gridlinesNodes(5)=gltf.addNode('translation',[0 1 0]*ax(1,1).*s*base_rotation,'addToScene',false);
                        skin_idx=gltf.addSkin(gridlinesNodes(5),'inverseBindMatrices',reshape(eye(4),16,1)');
                        gltf.addNode('mesh',xymesh,'skin',skin_idx,'children',gridlinesNodes(5));
                    end
                    if(ismember("1yz",gridIds))
                        gridlinesNodes(6)=gltf.addNode(translation',[0 1 0]*ax(2,1).*s*base_rotation,'addToScene',false);
                        skin_idx=gltf.addSkin(gridlinesNodes(6),'inverseBindMatrices',reshape(eye(4),16,1)');
                        gltf.addNode('mesh',xymesh,'skin',skin_idx,'children',gridlinesNodes(6));
                    end
                else
                    xymesh=gltf.addMesh(Vg1.*s*base_rotation,'indices',Eg1,'mode',"LINES",'material',gridlines_mat);
                    gltf.addPrimitiveToMesh(xymesh,Vg2.*s*base_rotation,'indices',Eg2,'mode',"LINES",'material',gridlines_mat);
                    if(ismember("xy0",gridIds))
                        gridlinesNodes(5)=gltf.addNode('mesh',xymesh,'translation',[0 0 1]*ax(1,3).*s*base_rotation,'addToScene',false);
                    end
                    if(ismember("xy1",gridIds))
                        gridlinesNodes(6)=gltf.addNode('mesh',xymesh,'translation',[0 0 1]*ax(2,3).*s*base_rotation,'addToScene',false);
                    end
                end
            end
            if(ismember("xyz",gridIds))
                [C,A,B]=meshgrid(ax_h.(tick(3)),ax(:,1),ax_h.(tick(2)));
                Vg1=[A(:) B(:) C(:)];
                Eg1=reshape(1:2*numel(ax_h.(tick(2)))*numel(ax_h.(tick(3))),2,numel(ax_h.(tick(2)))*numel(ax_h.(tick(3))))';
                [A,B,C]=meshgrid(ax_h.(tick(1)),ax(:,2),ax_h.(tick(3)));
                Vg2=[A(:) B(:) C(:)];
                Eg2=reshape(1:2*numel(ax_h.(tick(1)))*numel(ax_h.(tick(3))),2,numel(ax_h.(tick(1)))*numel(ax_h.(tick(3))))';
                [B,C,A]=meshgrid(ax_h.(tick(2)),ax(:,3),ax_h.(tick(1)));
                Vg3=[A(:) B(:) C(:)];
                Eg3=reshape(1:2*numel(ax_h.(tick(1)))*numel(ax_h.(tick(2))),2,numel(ax_h.(tick(1)))*numel(ax_h.(tick(2))))';
                if(skeleton)
                    Js=zeros(size(Vg1,1),4);
                    Ws=[ones(size(Vg1,1),1) zeros(size(Vg1,1),3)];
                    xyzmesh=gltf.addMesh(Vg1.*s*base_rotation,'indices',Eg1,'mode',"LINES",'material',gridlines_mat,'WEIGHTS',Ws,'JOINTS',Js);
                    Js=zeros(size(Vg2,1),4);
                    Ws=[ones(size(Vg2,1),1) zeros(size(Vg2,1),3)];
                    gltf.addPrimitiveToMesh(xyzmesh,Vg2.*s*base_rotation,'indices',Eg2,'mode',"LINES",'material',gridlines_mat,'WEIGHTS',Ws,'JOINTS',Js);
                    Js=zeros(size(Vg3,1),4);
                    Ws=[ones(size(Vg3,1),1) zeros(size(Vg2,1),3)];
                    gltf.addPrimitiveToMesh(xyzmesh,Vg3.*s*base_rotation,'indices',Eg3,'mode',"LINES",'material',gridlines_mat,'WEIGHTS',Ws,'JOINTS',Js);
                    gridlinesNodes(7)=gltf.addNode('addToScene',false);
                    skin_idx=gltf.addSkin(gridlinesNodes(7),'inverseBindMatrices',reshape(eye(4),16,1)');
                    gltf.addNode('mesh',xyzmesh,'skin',skin_idx,'children',gridlinesNodes(7));
                else
                    xyzmesh=gltf.addMesh(Vg1.*s*base_rotation,'indices',Eg1,'mode',"LINES",'material',gridlines_mat);
                    gltf.addPrimitiveToMesh(xyzmesh,Vg2.*s*base_rotation,'indices',Eg2,'mode',"LINES",'material',gridlines_mat);
                    gltf.addPrimitiveToMesh(xyzmesh,Vg3.*s*base_rotation,'indices',Eg3,'mode',"LINES",'material',gridlines_mat);
                    gridlinesNodes(7)=gltf.addNode('mesh',xyzmesh,'addToScene',false);
                end
            end
            gridlinesNodes=gridlinesNodes(~isnan(gridlinesNodes));
        else
            gridlinesNodes=[];
        end
        
        if(~isempty(backPlanes))
            backplane_mat=gltf.addMaterial('baseColorFactor',ax_h.Color);
            backPlaneNodes=nan(1,6);
            if(ismember("0yz",gridIds))
                [Vbox1,~,ic]=unique(Fbox(1:2,:));
                Vbox_i=Vbox(Vbox1,:)+(V(Vbox1,:)-0.5)*2.*diff(ax)*plane_delta;
                F1=reshape(ic,2,3);
                if(det(base_rotation)<0)
                    F1=F1(:,[1 3 2]);
                end
                if(skeleton)
                    Js=zeros(size(Vbox_i,1),4);
                    Ws=[ones(size(Vbox_i,1),1) zeros(size(Vbox_i,1),3)];
                    mesh=gltf.addMesh(Vbox_i.*s*base_rotation,'indices',F1,'normals',true,'material',backplane_mat,'WEIGHTS',Ws,'JOINTS',Js);
                    backPlaneNodes(1)=gltf.addNode('addToScene',false);
                    skin_idx=gltf.addSkin(backPlaneNodes(1),'inverseBindMatrices',reshape(eye(4),16,1)');
                    gltf.addNode('mesh',mesh,'skin',skin_idx,'children',backPlaneNodes(1));
                else
                    backPlaneNodes(1)=gltf.addNode('mesh',gltf.addMesh(Vbox_i.*s*base_rotation,'indices',F1,'normals',true,'material',backplane_mat),'addToScene',false);
                end
            end
            if(ismember("1yz",gridIds))
                [Vbox1,~,ic]=unique(Fbox(3:4,:));
                Vbox_i=Vbox(Vbox1,:)+(V(Vbox1,:)-0.5)*2.*diff(ax)*plane_delta;
                F1=reshape(ic,2,3);
                if(det(base_rotation)<0)
                    F1=F1(:,[1 3 2]);
                end
                if(skeleton)
                    Js=zeros(size(Vbox_i,1),4);
                    Ws=[ones(size(Vbox_i,1),1) zeros(size(Vbox_i,1),3)];
                    mesh=gltf.addMesh(Vbox_i.*s*base_rotation,'indices',F1,'normals',true,'material',backplane_mat,'WEIGHTS',Ws,'JOINTS',Js);
                    backPlaneNodes(2)=gltf.addNode('addToScene',false);
                    skin_idx=gltf.addSkin(backPlaneNodes(2),'inverseBindMatrices',reshape(eye(4),16,1)');
                    gltf.addNode('mesh',mesh,'skin',skin_idx,'children',backPlaneNodes(2));
                else
                    backPlaneNodes(2)=gltf.addNode('mesh',gltf.addMesh(Vbox_i.*s*base_rotation,'indices',F1,'normals',true,'material',backplane_mat),'addToScene',false);
                end
            end
            if(ismember("x0z",gridIds))
                [Vbox1,~,ic]=unique(Fbox(5:6,:));
                Vbox_i=Vbox(Vbox1,:)+(V(Vbox1,:)-0.5)*2.*diff(ax)*plane_delta;
                F1=reshape(ic,2,3);
                if(det(base_rotation)<0)
                    F1=F1(:,[1 3 2]);
                end
                if(skeleton)
                    Js=zeros(size(Vbox_i,1),4);
                    Ws=[ones(size(Vbox_i,1),1) zeros(size(Vbox_i,1),3)];
                    mesh=gltf.addMesh(Vbox_i.*s*base_rotation,'indices',F1,'normals',true,'material',backplane_mat,'WEIGHTS',Ws,'JOINTS',Js);
                    backPlaneNodes(3)=gltf.addNode('addToScene',false);
                    skin_idx=gltf.addSkin(backPlaneNodes(3),'inverseBindMatrices',reshape(eye(4),16,1)');
                    gltf.addNode('mesh',mesh,'skin',skin_idx,'children',backPlaneNodes(3));
                else
                    backPlaneNodes(3)=gltf.addNode('mesh',gltf.addMesh(Vbox_i.*s*base_rotation,'indices',F1,'normals',true,'material',backplane_mat),'addToScene',false);
                end
            end
            if(ismember("x1z",gridIds))
                [Vbox1,~,ic]=unique(Fbox(7:8,:));
                Vbox_i=Vbox(Vbox1,:)+(V(Vbox1,:)-0.5)*2.*diff(ax)*plane_delta;
                F1=reshape(ic,2,3);
                if(det(base_rotation)<0)
                    F1=F1(:,[1 3 2]);
                end
                if(skeleton)
                    Js=zeros(size(Vbox_i,1),4);
                    Ws=[ones(size(Vbox_i,1),1) zeros(size(Vbox_i,1),3)];
                    mesh=gltf.addMesh(Vbox_i.*s*base_rotation,'indices',F1,'normals',true,'material',backplane_mat,'WEIGHTS',Ws,'JOINTS',Js);
                    backPlaneNodes(4)=gltf.addNode('addToScene',false);
                    skin_idx=gltf.addSkin(backPlaneNodes(4),'inverseBindMatrices',reshape(eye(4),16,1)');
                    gltf.addNode('mesh',mesh,'skin',skin_idx,'children',backPlaneNodes(4));
                else
                    backPlaneNodes(4)=gltf.addNode('mesh',gltf.addMesh(Vbox_i.*s*base_rotation,'indices',F1,'normals',true,'material',backplane_mat),'addToScene',false);
                end
            end
            if(ismember("xy0",gridIds))
                [Vbox1,~,ic]=unique(Fbox(9:10,:));
                Vbox_i=Vbox(Vbox1,:)+(V(Vbox1,:)-0.5)*2.*diff(ax)*plane_delta;
                F1=reshape(ic,2,3);
                if(det(base_rotation)<0)
                    F1=F1(:,[1 3 2]);
                end
                if(skeleton)
                    Js=zeros(size(Vbox_i,1),4);
                    Ws=[ones(size(Vbox_i,1),1) zeros(size(Vbox_i,1),3)];
                    mesh=gltf.addMesh(Vbox_i.*s*base_rotation,'indices',F1,'normals',true,'material',backplane_mat,'WEIGHTS',Ws,'JOINTS',Js);
                    backPlaneNodes(5)=gltf.addNode('addToScene',false);
                    skin_idx=gltf.addSkin(backPlaneNodes(5),'inverseBindMatrices',reshape(eye(4),16,1)');
                    gltf.addNode('mesh',mesh,'skin',skin_idx,'children',backPlaneNodes(5));
                else
                    backPlaneNodes(5)=gltf.addNode('mesh',gltf.addMesh(Vbox_i.*s*base_rotation,'indices',F1,'normals',true,'material',backplane_mat),'addToScene',false);
                end
            end
            if(ismember("xy1",gridIds))
                [Vbox1,~,ic]=unique(Fbox(11:12,:));
                Vbox_i=Vbox(Vbox1,:)+(V(Vbox1,:)-0.5)*2.*diff(ax)*plane_delta;
                F1=reshape(ic,2,3);
                if(det(base_rotation)<0)
                    F1=F1(:,[1 3 2]);
                end
                if(skeleton)
                    Js=zeros(size(Vbox_i,1),4);
                    Ws=[ones(size(Vbox_i,1),1) zeros(size(Vbox_i,1),3)];
                    mesh=gltf.addMesh(Vbox_i.*s*base_rotation,'indices',F1,'normals',true,'material',backplane_mat,'WEIGHTS',Ws,'JOINTS',Js);
                    backPlaneNodes(6)=gltf.addNode('addToScene',false);
                    skin_idx=gltf.addSkin(backPlaneNodes(6),'inverseBindMatrices',reshape(eye(4),16,1)');
                    gltf.addNode('mesh',mesh,'skin',skin_idx,'children',backPlaneNodes(6));
                else
                    backPlaneNodes(6)=gltf.addNode('mesh',gltf.addMesh(Vbox_i.*s*base_rotation,'indices',F1,'normals',true,'material',backplane_mat),'addToScene',false);
                end
            end
        else
            backPlaneNodes=[];
        end
        
        direction=abs(V(E(:,2),:)-V(E(:,1),:))>0.5;
        Nv=vertexNormals(F,V);
        tick_dir=(Nv(E(:,1),:)+Nv(E(:,2),:))*sqrt(3/4);
        tickV=cell(size(E,1),1);
        tickE=cell(size(E,1),1);

        Nv=vertexNormals(F,V);
        E_dir=(Nv(E(:,1),:)+Nv(E(:,2),:))*sqrt(3/4);

        Emat=abs(ax_dir)==0;
        mat=unique(mat_idx(1:3));
        box_nodes=nan(1,numel(mat));
        if(skeleton)
            box_nodes2=nan(1,numel(mat));
        end
        for m=1:numel(mat)
            thismat=any(Emat(:,mat_idx(1:3)==mat(m)),2);
            [~,axisIndices]=ismember(ax_dir(thismat,:),E_dir,'rows');
            [Vbox1,~,ic]=unique(E(axisIndices,:));
            Vbox_i=Vbox(Vbox1,:);
            E1=reshape(ic,size(E(axisIndices,:)));
            if(skeleton)
                Js=zeros(size(Vbox_i,1),4);
                Ws=[ones(size(Vbox_i,1),1) zeros(size(Vbox_i,1),3)];
                mesh=gltf.addMesh(Vbox_i.*s*base_rotation,'indices',E1,'mode',"LINES",'material',mat(m),'WEIGHTS',Ws,'JOINTS',Js);
                box_nodes(m)=gltf.addNode('addToScene',false);
                skin_idx=gltf.addSkin(box_nodes(m),'inverseBindMatrices',reshape(eye(4),16,1)');
                box_nodes2(m)=gltf.addNode('mesh',mesh,'skin',skin_idx,'children',box_nodes(m));
            else
                box_nodes(m)=gltf.addNode('mesh',gltf.addMesh(Vbox_i.*s*base_rotation,'indices',E1,'mode',"LINES",'material',mat(m)),'addToScene',false);
            end
        end
%         if(skeleton)
%             box_node2=gltf.addNode('children',box_nodes2,'addToScene',false);
%             box_node=gltf.addNode('children',box_nodes,'addToScene',false);
%         else
%             box_node=gltf.addNode('children',box_nodes,'addToScene',false);
%         end

        ticklabelsF=cell(3,1);
        ticklabelsV=cell(3,1);
        axlabelsF=cell(3,1);
        axlabelsV=cell(3,1);
        VYmax=-Inf;
        VYmin=Inf;
        for i=1:3
            tempstr=string(ax_h.(ticklabel(i)));
            rot=ax_h.(ticklabelrotation(i))*pi/180;
            R=[cos(rot) sin(rot) 0;-sin(rot) cos(rot) 0;0 0 1];
            J=numel(tempstr);
            if(strlength(string(ax_h.(axislabel(i)).String))>0)
                [axlabelsF{i},axlabelsV{i}]=text2FV(string(ax_h.(axislabel(i)).String),fontFile);
                axlabelsV{i}(:,1)=axlabelsV{i}(:,1)-(max(axlabelsV{i}(:,1))+min(axlabelsV{i}(:,1)))/2;
                VYmax=max(VYmax,max(axlabelsV{i}(:,2)));
                VYmin=min(VYmin,min(axlabelsV{i}(:,2)));
            end
            ticklabelsF{i}=cell(J,1);
            ticklabelsV{i}=cell(J,1);
            for j=1:J
                if(tempstr(j)=="")
                    ticklabelsF{i}{j}=[];
                    ticklabelsV{i}{j}=[];
                else
                    [ticklabelsF{i}{j},ticklabelsV{i}{j}]=text2FV(tempstr(j),fontFile);
                    VYmax=max(VYmax,max(ticklabelsV{i}{j}(:,2)));
                    VYmin=min(VYmin,min(ticklabelsV{i}{j}(:,2)));
                    ticklabelsV{i}{j}=ticklabelsV{i}{j}*R;
                    ticklabelsV{i}{j}(:,1)=ticklabelsV{i}{j}(:,1)-(max(ticklabelsV{i}{j}(:,1))+min(ticklabelsV{i}{j}(:,1)))/2;
                    ticklabelsV{i}{j}(:,2)=ticklabelsV{i}{j}(:,2)-max(ticklabelsV{i}{j}(:,2));
                end
            end
        end
        VYcentre=(VYmax+VYmin)/2;
        VYrange=VYmax-VYmin;
        ticklabel_mesh=cell(3,1);
        axlabel_mesh=cell(3,1);
        up_axis=[0 1 0]*base_rotation';
        right_axis=[1 0 0]*base_rotation';
        forward_axis=[0 0 1]*base_rotation';
        for i=1:3
            if(needed_axes(i))
                if(strlength(string(ax_h.(axislabel(i)).String))>0)
                    axlabelsV{i}(:,2)=axlabelsV{i}(:,2)-VYcentre;
                    axlabelsV{i}=axlabelsV{i}/VYrange*line_h;
                    if(abs(up_axis(i)))
                        if(skeleton)
                            Js=zeros(size(axlabelsV{i},1),4);
                            Ws=[ones(size(axlabelsV{i},1),1) zeros(size(axlabelsV{i},1),3)];
                            axlabel_mesh{i}=gltf.addMesh(axlabelsV{i}*[0 1 0;-1 0 0;0 0 1],'indices',axlabelsF{i},'material',mat_idx(i+3),'WEIGHTS',Ws,'JOINTS',Js);
                            gltf.addPrimitiveToMesh(axlabel_mesh{i},axlabelsV{i}.*[1 -1 0]*[0 1 0;-1 0 0;0 0 1],'indices',axlabelsF{i},'material',mat_idx(i+3),'WEIGHTS',Ws,'JOINTS',Js);
                        else
                            axlabel_mesh{i}=gltf.addMesh(axlabelsV{i}*[0 1 0;-1 0 0;0 0 1],'indices',axlabelsF{i},'material',mat_idx(i+3));
                            gltf.addPrimitiveToMesh(axlabel_mesh{i},axlabelsV{i}.*[1 -1 0]*[0 1 0;-1 0 0;0 0 1],'indices',axlabelsF{i},'material',mat_idx(i+3));
                        end
                    else
                        if(skeleton)
                            Js=zeros(size(axlabelsV{i},1),4);
                            Ws=[ones(size(axlabelsV{i},1),1) zeros(size(axlabelsV{i},1),3)];
                            axlabel_mesh{i}=gltf.addMesh(axlabelsV{i},'indices',axlabelsF{i},'material',mat_idx(i+3),'WEIGHTS',Ws,'JOINTS',Js);
                            gltf.addPrimitiveToMesh(axlabel_mesh{i},axlabelsV{i}.*[-1 1 0],'indices',axlabelsF{i},'material',mat_idx(i+3),'WEIGHTS',Ws,'JOINTS',Js);
                        else
                            axlabel_mesh{i}=gltf.addMesh(axlabelsV{i},'indices',axlabelsF{i},'material',mat_idx(i+3));
                            gltf.addPrimitiveToMesh(axlabel_mesh{i},axlabelsV{i}.*[-1 1 0],'indices',axlabelsF{i},'material',mat_idx(i+3));
                        end
                    end
                end
                J=numel(ticklabelsV{i});
                for j=1:J
                    if(~isempty(ticklabelsV{i}{j}))
                        ticklabelsV{i}{j}(:,2)=ticklabelsV{i}{j}(:,2)-VYcentre;
                        ticklabelsV{i}{j}=ticklabelsV{i}{j}/VYrange*line_h;
                        if(skeleton)
                            Js=zeros(size(ticklabelsV{i}{j},1),4);
                            Ws=[ones(size(ticklabelsV{i}{j},1),1) zeros(size(ticklabelsV{i}{j},1),3)];
                            ticklabel_mesh{i}{j}=gltf.addMesh(ticklabelsV{i}{j},'indices',ticklabelsF{i}{j},'material',mat_idx(i),'WEIGHTS',Ws,'JOINTS',Js);
                            gltf.addPrimitiveToMesh(ticklabel_mesh{i}{j},ticklabelsV{i}{j}.*[-1 1 0],'indices',ticklabelsF{i}{j},'material',mat_idx(i),'WEIGHTS',Ws,'JOINTS',Js);
                        else
                            ticklabel_mesh{i}{j}=gltf.addMesh(ticklabelsV{i}{j},'indices',ticklabelsF{i}{j},'material',mat_idx(i));
                            gltf.addPrimitiveToMesh(ticklabel_mesh{i}{j},ticklabelsV{i}{j}.*[-1 1 0],'indices',ticklabelsF{i}{j},'material',mat_idx(i));
                        end
                    end
                end
            end
        end

        tickmat=nan(1,size(E,1));
        axislabel_node=nan(1,size(E,1));
        ticklabel_node=cell(1,size(E,1));
        for i=1:size(E,1)
            if(ismember(tick_dir(i,:),ax_dir,'rows'))
                tickmat(i)=mat_idx(abs(tick_dir(i,:))==0);
                if(direction(i,abs(right_axis)>0.5))
                    if(tick_dir(i,abs(up_axis)>0.5)*up_axis(abs(up_axis)>0.5)<0)
                        if(tick_dir(i,abs(forward_axis)>0.5)*forward_axis(abs(forward_axis)>0.5)<0)
                            rot=[sin(pi/8) 0 0 cos(pi/8)];
                        else
                            rot=[-sin(pi/8) 0 0 cos(pi/8)];
                        end
                    else
                        if(tick_dir(i,abs(forward_axis)>0.5)*forward_axis(abs(forward_axis)>0.5)<0)
                            rot=[-sin(pi/8) 0 0 cos(pi/8)];
                        else
                            rot=[sin(pi/8) 0 0 cos(pi/8)];
                        end
                    end
                elseif(direction(i,abs(forward_axis)>0.5))
                    if(tick_dir(i,abs(up_axis)>0.5)*up_axis(abs(up_axis)>0.5)<0)
                        if(tick_dir(i,abs(right_axis)>0.5)*right_axis(abs(right_axis)>0.5)<0)
                            rot=[-sin(pi/8)*sin(pi/4) -cos(pi/8)*sin(pi/4) -sin(pi/8)*cos(pi/4) cos(pi/8)*cos(pi/4)];
                        else
                            rot=[-sin(pi/8)*sin(pi/4) cos(pi/8)*sin(pi/4) sin(pi/8)*cos(pi/4) cos(pi/8)*cos(pi/4)];
                        end
                    else
                        if(tick_dir(i,abs(right_axis)>0.5)*right_axis(abs(right_axis)>0.5)<0)
                            rot=[sin(pi/8)*sin(pi/4) -cos(pi/8)*sin(pi/4) sin(pi/8)*cos(pi/4) cos(pi/8)*cos(pi/4)];
                        else
                            rot=[sin(pi/8)*sin(pi/4) cos(pi/8)*sin(pi/4) -sin(pi/8)*cos(pi/4) cos(pi/8)*cos(pi/4)];
                        end
                    end
                elseif(direction(i,abs(up_axis)>0.5))
                    if(tick_dir(i,abs(right_axis)>0.5)*right_axis(abs(right_axis)>0.5)<0)
                        if(tick_dir(i,abs(forward_axis)>0.5)*forward_axis(abs(forward_axis)>0.5)<0)
                            rot=[0 -sin(pi/8) 0 cos(pi/8)];
                        else
                            rot=[0 sin(pi/8) 0 cos(pi/8)];
                        end
                    else
                        if(tick_dir(i,abs(forward_axis)>0.5)*forward_axis(abs(forward_axis)>0.5)<0)
                            rot=[0 sin(pi/8) 0 cos(pi/8)];
                        else
                            rot=[0 -sin(pi/8) 0 cos(pi/8)];
                        end
                    end
                end
                tick_loc=ax_h.(tick(direction(i,:)));
                J=numel(tick_loc);
                tickV{i}=repmat([zeros(1,3);tick_dir(i,:)],numel(tick_loc),1)*tick_l+(s.*ax(1,:)+s.*diff(ax).*double(tick_dir(i,:)>0));
                tickV{i}(:,direction(i,:))=reshape(repmat(tick_loc,2,1),[],1)*s(direction(i,:));
                tickE{i}=reshape(1:2*numel(tick_loc),2,[])';
                if(strlength(string(ax_h.(axislabel(direction(i,:))).String))>0)
                    trans=tick_dir(i,:)*axlabel_l+s.*ax(1,:)+s.*diff(ax).*(double(tick_dir(i,:)>0)+direction(i,:)/2);
                    if(skeleton)
                        axislabel_node(i)=gltf.addNode('translation',trans*base_rotation,'rotation',rot,'addToScene',false);
                        skin_idx=gltf.addSkin(axislabel_node(i),'inverseBindMatrices',reshape(eye(4),16,1)');
                        gltf.addNode('mesh',axlabel_mesh{direction(i,:)},'skin',skin_idx,'children',axislabel_node(i));
                    else
                        axislabel_node(i)=gltf.addNode('mesh',axlabel_mesh{direction(i,:)},'translation',trans*base_rotation,'rotation',rot,'addToScene',false);
                    end
                end
                trans=tick_dir(i,:)*ticklabel_l+(s.*ax(1,:)+s.*diff(ax).*double(tick_dir(i,:)>0));
                trans=repmat(trans,J,1);
                trans(:,direction(i,:))=tick_loc'*s(direction(i,:));
                J=numel(ticklabelsV{direction(i,:)});
                ticklabel_node{i}=nan(1,J);
                for j=1:J
                    if(~isempty(ticklabel_mesh{direction(i,:)}{j}))
                        if(skeleton)
                            ticklabel_node{i}(j)=gltf.addNode('translation',trans(j,:)*base_rotation,'rotation',rot,'addToScene',false);
                            skin_idx=gltf.addSkin(ticklabel_node{i}(j),'inverseBindMatrices',reshape(eye(4),16,1)');
                            gltf.addNode('mesh',ticklabel_mesh{direction(i,:)}{j},'skin',skin_idx,'children',ticklabel_node{i}(j));
                        else
                            ticklabel_node{i}(j)=gltf.addNode('mesh',ticklabel_mesh{direction(i,:)}{j},'translation',trans(j,:)*base_rotation,'rotation',rot,'addToScene',false);
                        end
                    end
                end
            end
        end
        tick_node=nan(1,numel(tickV));
        if(~isempty(tickV))
            for i=1:numel(tickV)
                if(~isempty(tickV{i}))
                    if(skeleton)
                        Js=zeros(size(tickV{i},1),4);
                        Ws=[ones(size(tickV{i},1),1) zeros(size(tickV{i},1),3)];
                        mesh=gltf.addMesh(tickV{i}*base_rotation,'indices',tickE{i},'mode',"LINES",'material',tickmat(i),'WEIGHTS',Ws,'JOINTS',Js);
                        tick_node(i)=gltf.addNode('addToScene',false);
                        skin_idx=gltf.addSkin(tick_node(i),'inverseBindMatrices',reshape(eye(4),16,1)');
                        gltf.addNode('mesh',mesh,'skin',skin_idx,'children',tick_node(i));
                    else
                        tick_node(i)=gltf.addNode('mesh',gltf.addMesh(tickV{i}*base_rotation,'indices',tickE{i},'mode',"LINES",'material',tickmat(i)),'addToScene',false);
                    end
                end
            end
            tick_node=tick_node(~isnan(tick_node));
        else
            tick_node=[];
        end
        children=[box_nodes axislabel_node cell2mat(ticklabel_node) tick_node backPlaneNodes gridlinesNodes];
        children=children(~isnan(children));
        if(skeleton)
            ax_node=children;
        else
            ax_node=gltf.addNode('children',children);
        end
    end
end

function valid=validateAxisIds(input,possibilities)
    % Validate string inputs for axis IDs.
    %
    % VALIDATEAXISIDS(INPUT,POSSIBILITIES) returns TRUE if INPUT is a
    % member of POSSIBILITIES, and returns an error if it isn't.
    %
    valid=all(ismember(input,possibilities));
    if(~valid)
        strings2="""" + possibilities + """";
        strings2(end)="or " + strings2(end);
        out="one of """ + join(strings2, ", ");
        error("It must be " + out + ".");
    end
end

function Nv=vertexNormals(F,V)
    % Calculate vertex normals for a mesh.
    %
    % VERTEXNORMALS(F,V) calculates the vertex normals for each vertex of
    % the mesh of vertices V and faces F.
    %
    Nv=zeros(size(V));
    for i=1:size(F,1)
        f=F(i,~isnan(F(i,:)));
        if(norm(cross(diff(V(f([2 3]),:)),diff(V(f([2 1]),:))))>eps)
            Nf=cross(diff(V(f([2 3]),:)),diff(V(f([2 1]),:)))/norm(cross(diff(V(f([2 3]),:)),diff(V(f([2 1]),:))));
            for j=1:numel(f)
                Nv(f(j),:)=Nv(f(j),:)+Nf;
            end
        end
    end
    Nv=Nv./vecnorm(Nv,2,2);
end
