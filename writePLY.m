function writePLY(gltf,filename,varargin)
    % Write a Stanford PLY file.
    %
    % WRITEPLY(GLTF,FILENAME) writes GLTF to a Wavefront OBJ file specified
    % by filename.
    %
    % WRITEPLY(GLTF,FILENAME,'nodes',NODES) writes the specified NODES in
    % the GLTF to a Wavefront OBJ file specified by filename. Each of the
    % specified nodes should be a mesh node.
    %
    % WRITEPLY(GLTF,FILENAME,'meshes',MESHES) writes the specified MESHES
    % in the GLTF to a Wavefront OBJ file specified by filename. This input
    % is ignored if NODES are specified.
    %
    % WRITEPLY(...,'materialFile',materialFile) also exports the materials
    % in the specified nodes or meshes to the specified .mtl file, and adds
    % a reference to it in the .obj file.
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
    % Write a Wavefront OBJ file.
    %
    % WRITEOBJ(GLTF,FILENAME) writes GLTF to a Wavefront OBJ file specified
    % by filename.
    %
    % WRITEOBJ(GLTF,FILENAME,'nodes',NODES) writes the specified NODES in
    % the GLTF to a Wavefront OBJ file specified by filename. Each of the
    % specified nodes should be a mesh node.
    %
    % WRITEOBJ(GLTF,FILENAME,'meshes',MESHES) writes the specified MESHES
    % in the GLTF to a Wavefront OBJ file specified by filename. This input
    % is ignored if NODES are specified.
    %
    % WRITEOBJ(...,'materialFile',materialFile) also exports the materials
    % in the specified nodes or meshes to the specified .mtl file, and adds
    % a reference to it in the .obj file.
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
    ips.addParameter('nodes',[],@(x)GLTF.validateInteger(x,nodes));
    ips.addParameter('meshes',[],@(x)GLTF.validateInteger(x,0,numel(gltf.meshes)-1));
    ips.addParameter('materialFile',missing,@isstring);
    ips.parse(varargin{:});
    parameters=ips.Results;
    materialFile=parameters.materialFile;
    nodes=parameters.nodes;
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
    nodeUV=cell(0,1);
    ct=0;
    mode_str_values=["POINTS","LINES","LINE_LOOP","LINE_STRIP","TRIANGLES","TRIANGLE_STRIP","TRIANGLE_FAN"];
    mode_num_values=[       0,      1,          2,           3,          4,               5,             6];
    use_materials=true;
    if(or(ismissing(materialFile),~isprop(gltf,'materials')))
        use_materials=false;
    end
    if(use_materials)
        used_materials=false(numel(gltf.materials),1);        
        nodeM=cell(0,1);
        matct=0;
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
                        nodeN{ct}=nan(size(V,1),3);
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
                    if(isfield(gltf.meshes{mesh+1}.primitives{primitive}.attributes,'TEXCOORD_0'))
                        nodeUV{ct}=gltf.getAccessor(gltf.meshes{mesh+1}.primitives{primitive}.attributes.TEXCOORD_0);
                    else
                        nodeUV{ct}=nan(size(V,1),2);
                    end
                    if(use_materials)
                        if(isfield(gltf.meshes{mesh+1}.primitives{primitive},'material'))
                            mat=gltf.meshes{mesh+1}.primitives{primitive}.material;
                            used_materials(mat+1)=true;
                            if(isfield(gltf.materials{mat+1},'name'))
                                nodeM{ct}=gltf.materials{mat+1}.name;
                            else
                                matct=matct+1;
                                nodeM{ct}="material_"+matct;
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
                        nodeN{ct}=nan(size(V,1),3);
                    end
                    if(isfield(gltf.meshes{mesh+1}.primitives{primitive}.attributes,'TEXCOORD_0'))
                        nodeUV{ct}=gltf.getAccessor(gltf.meshes{mesh+1}.primitives{primitive}.attributes.TEXCOORD_0);
                    else
                        nodeUV{ct}=nan(size(V,1),2);
                    end
                    if(use_materials)
                        if(isfield(gltf.meshes{mesh+1}.primitives{primitive},'material'))
                            mat=gltf.meshes{mesh+1}.primitives{primitive}.material;
                            used_materials(mat+1)=true;
                            if(isfield(gltf.materials{mat+1},'name'))
                                nodeM{ct}=gltf.materials{mat+1}.name;
                            else
                                matct=matct+1;
                                nodeM{ct}="material_"+matct;
                            end
                        end
                    end
                end
            end
        end
    end

    nodeE=nodeF;
    edges=cellfun(@(x)size(x,2)==2,nodeE);
    faces=cellfun(@(x)size(x,2)==3,nodeF);
    nodeE(~edges)=repmat({uint32(zeros(0,2))},size(nodeE(~edges)));
    nodeF(~faces)=repmat({uint32(zeros(0,3))},size(nodeF(~faces)));

    nonormals=cellfun(@(x)all(isnan(x),"all"),nodeN);
    if(~or(all(nonormals),all(~nonormals)))
        I=find(nonormals);
        for i=1:numel(I)
            if(edges(I(i)))
                N=zeros(size(nodeV{I(i)},1),3); %#ok<PREALL>
                % nodeN{I(i)}=N./vecnorm(N,2,2);
            else
                [N,F,idx]=GLTF.vertexNormals(nodeF{I(i)},nodeV{I(i)});
                nodeF{I(i)}=F;
                nodeV{I(i)}=nodeV{I(i)}(idx,:);
                nodeN{I(i)}=N;
            end
        end
    end

    F=cellfun(@(x,y)x+y,nodeF(:),num2cell([0;cumsum(cellfun(@(x)size(x,1),nodeV(1:end-1)'))]),"UniformOutput",false);
    E=cellfun(@(x,y)x+y,nodeE(:),num2cell([0;cumsum(cellfun(@(x)size(x,1),nodeV(1:end-1)'))]),"UniformOutput",false);
    V=cell2mat(nodeV(:));
    N=cell2mat(nodeN(:));
    UV=cell2mat(nodeUV(:));
    F=cell2mat(F);
    E=cell2mat(E);

    if(and(~all(isnan(UV),"all"),~all(isnan(N),"all")))
        VUVN=[V UV N];
    elseif(~all(isnan(UV),"all"))
        VUVN=[V UV];
    elseif(~all(isnan(N),"all"))
        VUVN=[V N];
    else
        VUVN=V;
    end

    header=[
        "ply"
        "format ascii 1.0"
        ];

    vertex_header=[
        "element vertex "+string(size(V,1))
        "property float x"
        "property float y"
        "property float z"
        ];
    if(~all(isnan(UV),"all"))
        vertex_header=[
            vertex_header
            "property float s"
            "property float t"
            ];
        if(~all(isnan(N),"all"))
            vertex_header=[
                vertex_header
                "property float nx"
                "property float ny"
                "property float nz"
                ];
        end
    elseif(~all(isnan(N),"all"))
        vertex_header=[
            vertex_header
            "property float nx"
            "property float ny"
            "property float nz"
            ];
    end
    clear ic;
    faces_header=[
        "element face "+string(size(F,1))
        "property list uchar uint vertex_indices"
        ];
    edges_header=[
        "element edge "+string(size(E,1))
        "property int vertex1"
        "property int vertex2"
        ];
    end_header="end_header";

    vtext=string(VUVN);
    vtext(ismissing(vtext))="";
    vtext=strip(join(vtext));
    ftext=string([sum(~isnan(F),2) F-1]);
    ftext(ismissing(ftext))="";
    ftext=strip(join(ftext));
    etext=string(E-1);
    etext=strip(join(etext));
    writelines([header;vertex_header;faces_header;edges_header;end_header;vtext;ftext;etext],filename);
    clear vtext ftext header vertex_header faces_header end_header;
end
