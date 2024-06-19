function writeOBJ(gltf,filename,varargin)
    % Write a COLLADA file.
    %
    % WRITEDAE(GLTF,FILENAME) writes GLTF to a Wavefront OBJ file specified by filename.
    %
    % WRITEDAE(GLTF,FILENAME,'nodes',NODES) writes the specified NODES in
    % the GLTF to a Wavefront OBJ file specified by filename. Each of the
    % specified nodes should be a mesh node.
    %
    % WRITEDAE(GLTF,FILENAME,'meshes',MESHES) writes the specified MESHES
    % in the GLTF to a Wavefront OBJ file specified by filename. This input
    % is ignored if NODES are specified.
    %
    % WRITEDAE(...,'materialFile',materialFile) also exports the materials
    % in the specified nodes or meshes to the specified .mtl file, and adds
    % a reference to it in the .obj file.
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
            if(isSkin(node))
                ibm=gltf.getAccessor(gltf.skins{gltf.nodes{node}.skin+1}.inverseBindMatrices);
                baseNode=gltf.nodes{node}.children{1};
                ibm=ibm(:,:,gltf.skins{gltf.nodes{node}.skin+1}.joints==baseNode);
                mat=gltf.getNodeTransformation(baseNode);
                mesh_mat=mat(:,:,1);
                mesh_mat=ibm*mesh_mat;
            else
                mat=gltf.getNodeTransformation(node-1);
                mesh_mat=mat(:,:,1);
            end
            mesh=gltf.nodes{node}.mesh;
            np=numel(gltf.meshes{mesh+1}.primitives);
            for primitive=1:np
                V=gltf.getAccessor(gltf.meshes{mesh+1}.primitives{primitive}.attributes.POSITION);
                if(~isempty(V))
                    ct=ct+1;
                    nodeV{ct}=[V ones(size(V,1),1)]*mesh_mat(1:3,:)';
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
                        nodeN{ct}=N*mesh_mat(1:3,1:3)';
                    else
                        nodeN{ct}=[];
                    end
                    if(isfield(gltf.meshes{mesh+1}.primitives{primitive}.attributes,'TEXCOORD_0'))
                        nodeUV{ct}=gltf.getAccessor(gltf.meshes{mesh+1}.primitives{primitive}.attributes.TEXCOORD_0);
                    else
                        nodeUV{ct}=[];
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
                        nodeN{ct}=[];
                    end
                    if(isfield(gltf.meshes{mesh+1}.primitives{primitive}.attributes,'TEXCOORD_0'))
                        nodeUV{ct}=gltf.getAccessor(gltf.meshes{mesh+1}.primitives{primitive}.attributes.TEXCOORD_0);
                    else
                        nodeUV{ct}=[];
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
    edges=cellfun(@(x)size(x,2)==2,nodeF);
    faces=cellfun(@(x)size(x,2)==3,nodeF);
    nodeE(~edges)=repmat({uint32(zeros(0,2))},size(nodeE(~edges)));
    nodeF(~faces)=repmat({uint32(zeros(0,3))},size(nodeF(~faces)));
    
    FV=cellfun(@(x,y)x+y,nodeF(:),num2cell([0;cumsum(cellfun(@(x)size(x,1),nodeV(1:end-1)'))]),"UniformOutput",false);
    FN=cellfun(@(x,y)x+y,nodeF(:),num2cell([0;cumsum(cellfun(@(x)size(x,1),nodeN(1:end-1)'))]),"UniformOutput",false);
    FT=cellfun(@(x,y)x+y,nodeF(:),num2cell([0;cumsum(cellfun(@(x)size(x,1),nodeUV(1:end-1)'))]),"UniformOutput",false);
    EV=cellfun(@(x,y)x+y,nodeE(:),num2cell([0;cumsum(cellfun(@(x)size(x,1),nodeV(1:end-1)'))]),"UniformOutput",false);
    EN=cellfun(@(x,y)x+y,nodeE(:),num2cell([0;cumsum(cellfun(@(x)size(x,1),nodeN(1:end-1)'))]),"UniformOutput",false);
    ET=cellfun(@(x,y)x+y,nodeE(:),num2cell([0;cumsum(cellfun(@(x)size(x,1),nodeUV(1:end-1)'))]),"UniformOutput",false);
    V=cell2mat(nodeV(:));
    N=cell2mat(nodeN(:));
    UV=cell2mat(nodeUV(:));
    if(isempty(N))
        FN=cellfun(@(x)nan(size(x)),FN,'UniformOutput',false);
        EN=cellfun(@(x)nan(size(x)),EN,'UniformOutput',false);
    end
    if(isempty(UV))
        FT=cellfun(@(x)nan(size(x)),FT,'UniformOutput',false);
        ET=cellfun(@(x)nan(size(x)),ET,'UniformOutput',false);
    end
    vtext="v "+join(string(V));
    ntext="vn "+join(string(N));
    ttext="vt "+join(string(UV));
    ftext=cellfun(@(x,y,z)cat(3,string(x),string(y),string(z)),FV,FT,FN,'UniformOutput',false);
    for i=1:numel(ftext)
        ftext{i}(ismissing(ftext{i}))="";
    end
    ftext=cellfun(@(x)join("f "+strip(join(strip(join(x,"/",3),"/"),2)),newline),ftext,'UniformOutput',false);
    etext=cellfun(@(x,y,z)cat(3,string(x),string(y),string(z)),EV,ET,EN,'UniformOutput',false);
    for i=1:numel(etext)
        etext{i}(ismissing(etext{i}))="";
    end
    etext=cellfun(@(x)join("l "+strip(join(strip(join(x,"/",3),"/"),2)),newline),etext,'UniformOutput',false);
    if(use_materials)
        if(any(used_materials))
            ftext=cellfun(@(x,y)"g"+newline+"usemtl "+x+newline+y,nodeM(:),ftext);
            etext=cellfun(@(x,y)"g"+newline+"usemtl "+x+newline+y,nodeM(:),etext);
        else
            ftext=cellfun(@(x)"g"+newline+x,ftext);
            etext=cellfun(@(x)"g"+newline+x,etext);
        end
    else
        ftext=cellfun(@(x)"g"+newline+x,ftext);
        etext=cellfun(@(x)"g"+newline+x,etext);
    end
    ftext=ftext(~ismissing(ftext));
    etext=etext(~ismissing(etext));
    if(use_materials)
        if(any(used_materials))
            [~,relative2]=GLTF.getRelativePath(filename,materialFile);
            matline="mtllib "+relative2;
            writelines([matline;vtext;ttext;ntext;ftext;etext],filename);
        else
            writelines([vtext;ttext;ntext;ftext;etext],filename);
        end
    else
        writelines([vtext;ttext;ntext;ftext;etext],filename);
    end
    
    if(use_materials)
        if(any(used_materials))
            matcell=cell(nnz(used_materials),1);
            used_materials=find(used_materials);
            for m=1:numel(used_materials)
                mat=used_materials(m);
                matcell{m}="newmtl "+nodeM{m};
                if(isfield(gltf.materials{mat},'pbrMetallicRoughness'))
                    if(isfield(gltf.materials{mat}.pbrMetallicRoughness,'baseColorFactor'))
                        matcell{m}=[matcell{m};"Kd"+sprintf(" %0-9.7f",gltf.materials{mat}.pbrMetallicRoughness.baseColorFactor(1:3))];
                    end
                    if(isfield(gltf.materials{mat}.pbrMetallicRoughness,'metallicFactor'))
                        matcell{m}=[matcell{m};"Ks"+sprintf(" %0-9.7f",repmat(gltf.materials{mat}.pbrMetallicRoughness.metallicFactor,1,3))];
                    end
                    if(isfield(gltf.materials{mat}.pbrMetallicRoughness,'roughnessFactor'))
                        matcell{m}=[matcell{m};"Ns"+sprintf(" %0-9.7f",repmat(gltf.materials{mat}.pbrMetallicRoughness.metallicFactor,1,3))];
                    end
                    if(isfield(gltf.materials{mat},'alphaMode') && gltf.materials{mat}.alphaMode~="OPAQUE" && isfield(gltf.materials{mat}.pbrMetallicRoughness,'baseColorFactor'))
                        matcell{m}=[matcell{m};"d"+sprintf(" %0-9.7f",gltf.materials{mat}.pbrMetallicRoughness.baseColorFactor(4))];
                    end
                    if(isfield(gltf.materials{mat}.pbrMetallicRoughness,'baseColorTexture'))
                        matcell{m}=[matcell{m};"map_Kd"+string(gltf.images{gltf.textures{gltf.materials{mat}.pbrMetallicRoughness.baseColorTexture.index+1}.source+1}.uri)];
                    end
                end
                if(isfield(gltf.materials{mat},'emissiveFactor'))
                    matcell{m}=[matcell{m};"Ke"+sprintf(" %0-9.7f",gltf.materials{mat}.emissiveFactor)];
                end
            end
            mat=[matcell{:}];
            writelines(mat,materialFile);
        end
    end
end
