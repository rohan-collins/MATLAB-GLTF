function showGLTF(gltf,varargin)
    % Display a GLTF object.
    %
    % SHOWGLTF(GLTF) shows the GLTF object in a new axis and figure.
    %
    % SHOWGLTF(GLTF,'axis',ax) shows the GLTF object in the specified axis
    % handle.
    %
    % SHOWGLTF(GLTF,'nodes',NODES) shows the specified NODES in the GLTF.
    % Each of the specified nodes should be a mesh node.
    %
    % SHOWGLTF(GLTF,'meshes',MESHES) shows the specified MESHES in the
    % GLTF. This input is ignored if NODES are specified.
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
    [~,isMesh,isSkin]=gltf.nodeTree();
    nodes=find(isMesh)';
    ips=inputParser;
    ips.addParameter('nodes',[],@(x)validateInteger(x,nodes));
    ips.addParameter('meshes',[],@(x)validateInteger(x,0,numel(gltf.meshes)-1));
    ips.addParameter('axis',[],@(x) isa(x,'matlab.graphics.axis.Axes'));
    ips.parse(varargin{:});
    parameters=ips.Results;
    nodes=parameters.nodes;
    ax_h=parameters.axis;
    if(isempty(nodes))
        meshes=parameters.meshes;
    else
        meshes=[];
    end
    if(and(isempty(nodes),isempty(meshes)))
        [~,isMesh,isSkin]=gltf.nodeTree();
        nodes=find(isMesh)';
    end
    nodeF=cell(0,1);
    nodeV=cell(0,1);
    nodeN=cell(0,1);
    nodeFC=cell(0,1);
    ct=0;
    mode_str_values=["POINTS","LINES","LINE_LOOP","LINE_STRIP","TRIANGLES","TRIANGLE_STRIP","TRIANGLE_FAN"];
    mode_num_values=[       0,      1,          2,           3,          4,               5,             6];
    use_materials=true;
    if(~isprop(gltf,'materials'))
        use_materials=false;
    end
    if(~isempty(nodes))
        for node=nodes
            mesh_mat=gltf.getNodeTransformation(node-1);
            mesh=gltf.nodes{node}.mesh;
            np=numel(gltf.meshes{mesh+1}.primitives);
            for primitive=1:np
                V=gltf.getAccessor(gltf.meshes{mesh+1}.primitives{primitive}.attributes.POSITION);
                if(~isempty(V))
                    if(isfield(gltf.meshes{mesh+1}.primitives{primitive}.attributes,'NORMAL'))
                        N=gltf.getAccessor(gltf.meshes{mesh+1}.primitives{primitive}.attributes.NORMAL);
                    end
                    if(isSkin(node))
                        IBM=gltf.getAccessor(gltf.skins{gltf.nodes{node}.skin+1}.inverseBindMatrices);
                        W=gltf.getAccessor(gltf.meshes{mesh+1}.primitives{primitive}.attributes.WEIGHTS_0);
                        J=gltf.getAccessor(gltf.meshes{mesh+1}.primitives{primitive}.attributes.JOINTS_0);
                        j=gltf.skins{gltf.nodes{node}.skin+1}.joints;
                        if(iscell(j))
                            j=cell2mat(j);
                        end
                        nodeT=nan(4,4,numel(j));
                        for i=1:numel(j)
                            nodeT(:,:,i)=gltf.getNodeTransformation(j(i));
                        end
                        TJ=pagemtimes(nodeT,IBM);
                        V=permute(sum(W.*permute(pagemtimes(permute([V ones(size(V,1),1)],[3 2 4 1]),'none',reshape(TJ(1:3,:,J'+1),3,4,size(J,2),size(J,1)),'transpose'),[4 3 2 1]),2),[1 3 2]);
                        if(isfield(gltf.meshes{mesh+1}.primitives{primitive}.attributes,'NORMAL'))
                            N=permute(sum(W.*permute(pagemtimes(permute([N zeros(size(N,1),1)],[3 2 4 1]),'none',reshape(TJ(1:3,:,J'+1),3,4,size(J,2),size(J,1)),'transpose'),[4 3 2 1]),2),[1 3 2]);
                        end
                    end
                    ct=ct+1;
                    nodeV{ct}=[V ones(size(V,1),1)]*mesh_mat(1:3,:)';
                    if(isfield(gltf.meshes{mesh+1}.primitives{primitive}.attributes,'NORMAL'))
                        nodeN{ct}=N*mesh_mat(1:3,1:3)';
                    else
                        nodeN{ct}=[];
                    end
                    if(isfield(gltf.meshes{mesh+1}.primitives{primitive},'mode'))
                        mode_num=gltf.meshes{mesh+1}.primitives{primitive}.mode;
                    else
                        mode_num=4;
                    end
                    mode_str=mode_str_values(mode_num_values==mode_num);
                    switch(mode_str)
                        case "LINES"
                            E=gltf.getAccessor(gltf.meshes{mesh+1}.primitives{primitive}.indices);
                            nodeF{ct}=GLTF.fromLines(E);
                        case "LINE_LOOP"
                            E=gltf.getAccessor(gltf.meshes{mesh+1}.primitives{primitive}.indices);
                            nodeF{ct}=GLTF.fromLineLoop(E);
                        case "LINE_STRIP"
                            E=gltf.getAccessor(gltf.meshes{mesh+1}.primitives{primitive}.indices);
                            nodeF{ct}=GLTF.fromLineStrip(E);
                        case "TRIANGLES"
                            F=gltf.getAccessor(gltf.meshes{mesh+1}.primitives{primitive}.indices);
                            nodeF{ct}=GLTF.fromTriangles(F);
                        case "TRIANGLE_STRIP"
                            F=gltf.getAccessor(gltf.meshes{mesh+1}.primitives{primitive}.indices);
                            nodeF{ct}=GLTF.fromTriangleStrip(F);
                        case "TRIANGLE_FAN"
                            F=gltf.getAccessor(gltf.meshes{mesh+1}.primitives{primitive}.indices);
                            nodeF{ct}=GLTF.fromTriangleFan(F);
                        otherwise
                            nodeF{ct}=[];
                    end
                    if(use_materials)
                        if(isfield(gltf.meshes{mesh+1}.primitives{primitive},'material'))
                            mat=gltf.meshes{mesh+1}.primitives{primitive}.material;
                            if(isfield(gltf.materials{mat+1}.pbrMetallicRoughness,'baseColorFactor'))
                                nodeFC{ct}=gltf.materials{mat+1}.pbrMetallicRoughness.baseColorFactor;
                            end
                        end
                    end
                end
            end
        end
    elseif(~isempty(meshes))
        for mesh=meshes
            np=numel(gltf.meshes{mesh+1}.primitives);
            for primitive=1:np
                V=gltf.getAccessor(gltf.meshes{mesh+1}.primitives{primitive}.attributes.POSITION);
                if(~isempty(V))
                    ct=ct+1;
                    nodeV{ct}=V;
                    if(isfield(gltf.meshes{mesh+1}.primitives{primitive},'mode'))
                        mode_num=gltf.meshes{mesh+1}.primitives{primitive}.mode;
                    else
                        mode_num=4;
                    end
                    mode_str=mode_str_values(mode_num_values==mode_num);
                    switch(mode_str)
                        case "LINES"
                            E=gltf.getAccessor(gltf.meshes{mesh+1}.primitives{primitive}.indices);
                            nodeF{ct}=GLTF.fromLines(E);
                        case "LINE_LOOP"
                            E=gltf.getAccessor(gltf.meshes{mesh+1}.primitives{primitive}.indices);
                            nodeF{ct}=GLTF.fromLineLoop(E);
                        case "LINE_STRIP"
                            E=gltf.getAccessor(gltf.meshes{mesh+1}.primitives{primitive}.indices);
                            nodeF{ct}=GLTF.fromLineStrip(E);
                        case "TRIANGLES"
                            F=gltf.getAccessor(gltf.meshes{mesh+1}.primitives{primitive}.indices);
                            nodeF{ct}=GLTF.fromTriangles(F);
                        case "TRIANGLE_STRIP"
                            F=gltf.getAccessor(gltf.meshes{mesh+1}.primitives{primitive}.indices);
                            nodeF{ct}=GLTF.fromTriangleStrip(F);
                        case "TRIANGLE_FAN"
                            F=gltf.getAccessor(gltf.meshes{mesh+1}.primitives{primitive}.indices);
                            nodeF{ct}=GLTF.fromTriangleFan(F);
                        otherwise
                            nodeF{ct}=[];
                    end
                    if(isfield(gltf.meshes{mesh+1}.primitives{primitive}.attributes,'NORMAL'))
                        N=gltf.getAccessor(gltf.meshes{mesh+1}.primitives{primitive}.attributes.NORMAL);
                        nodeN{ct}=N;
                    else
                        nodeN{ct}=[];
                    end
                    if(use_materials)
                        if(isfield(gltf.meshes{mesh+1}.primitives{primitive},'material'))
                            mat=gltf.meshes{mesh+1}.primitives{primitive}.material;
                            if(isfield(gltf.materials{mat+1}.pbrMetallicRoughness,'baseColorFactor'))
                                nodeFC{ct}=gltf.materials{mat+1}.pbrMetallicRoughness.baseColorFactor;
                            end
                        end
                    end
                end
            end
        end
    end
    if(isempty(ax_h))
        ax_h=gca;
    end
    for ict=1:ct
        if(isempty(nodeN{ict}))
            if(isempty(nodeFC{ict}))
                patch('Parent',ax_h,'Faces',nodeF{ict},'Vertices',nodeV{ict});
            else
                if(nodeFC{ict}(4)<4)
                    if(size(nodeF{ict},2)==2)
                        patch('Parent',ax_h,'Faces',nodeF{ict},'Vertices',nodeV{ict},'FaceColor','none','EdgeColor',nodeFC{ict}(1:3),'EdgeAlpha',nodeFC{ict}(4));
                    else
                        patch('Parent',ax_h,'Faces',nodeF{ict},'Vertices',nodeV{ict},'FaceColor',nodeFC{ict}(1:3),'FaceAlpha',nodeFC{ict}(4),'EdgeColor','none');
                    end
                else
                    if(size(nodeF{ict},2)==2)
                        patch('Parent',ax_h,'Faces',nodeF{ict},'Vertices',nodeV{ict},'FaceColor','none','EdgeColor',nodeFC{ict}(1:3));
                    else
                        patch('Parent',ax_h,'Faces',nodeF{ict},'Vertices',nodeV{ict},'FaceColor',nodeFC{ict}(1:3),'EdgeColor','none');
                    end
                end
            end
        else
            if(isempty(nodeFC{ict}))
                patch('Parent',ax_h,'Faces',nodeF{ict},'Vertices',nodeV{ict},'VertexNormals',-nodeN{ict});
            else
                if(nodeFC{ict}(4)<4)
                    if(size(nodeF{ict},2)==2)
                        patch('Parent',ax_h,'Faces',nodeF{ict},'Vertices',nodeV{ict},'FaceColor','none','EdgeColor',nodeFC{ict}(1:3),'EdgeAlpha',nodeFC{ict}(4));
                    else
                        patch('Parent',ax_h,'Faces',nodeF{ict},'Vertices',nodeV{ict},'FaceColor',nodeFC{ict}(1:3),'FaceAlpha',nodeFC{ict}(4),'EdgeColor','none');
                    end
                else
                    if(size(nodeF{ict},2)==2)
                        patch('Parent',ax_h,'Faces',nodeF{ict},'Vertices',nodeV{ict},'VertexNormals',-nodeN{ict},'FaceColor','none','EdgeColor',nodeFC{ict}(1:3));
                    else
                        patch('Parent',ax_h,'Faces',nodeF{ict},'Vertices',nodeV{ict},'VertexNormals',-nodeN{ict},'FaceColor',nodeFC{ict}(1:3),'EdgeColor','none');
                    end
                end
            end
        end
    end
    axis(ax_h,'equal');
    view(ax_h,3);
end

function valid=validateInteger(input,min,max)
    valid=isnumeric(input);
    valid=valid && all(input==round(input));
    if(nargin>2)
        if(isfinite(min))
            valid=valid && all(input>=min);
        end
        if(isfinite(max))
            valid=valid && all(input<=max);
        end
        if(~valid)
            if(and(isfinite(min),isfinite(max)))
                error("Must be integer(s) from " + min + " to " + max + ".");
            elseif(isfinite(min))
                error("Must be integer(s) greater than or equal to " + min + ".");
            elseif(isfinite(max))
                error("Must be integer(s) less than or equal to " + max + ".");
            else
                error("Must be integer(s).");
            end
        end
    else
        valid=all(ismember(input,min));
        if(~valid)
            error("Must be integer(s) " + GLTF.joinString(string(min)) + ".");
        end
    end
end
