classdef GLTF < dynamicprops
    % Read and write GLTF 3D model and animation files.
    %
    % © Copyright 2014-2023 Rohan Chabukswar
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
    properties
        asset       % GLTF Asset field
        scene       % Default scene
        scenes      % Array of scenes
        nodes       % Array of nodes
        meshes      % Array of meshes
        accessors   % Array of accessors
        bufferViews % Array of buffer views
        buffers     % Array of buffers
    end
    methods
        function gltf=GLTF(varargin)
            % Class constructor.
            %
            % GLTF() creates and returns a blank GLTF model.
            %
            % GLTF(FILENAME) reads the GLTF file FILENAME and returns a
            % GLTF object.
            %
            % GLTF(F,V) creates a GLTF model of one mesh with faces F and
            % vertices V. V specifies vertex values and F defines which
            % vertices to connect as triangles. The first colour given by
            % the LINES function is used as material colour.
            %
            % GLTF(F,V,C) creates a GLTF model of one mesh with faces F and
            % vertices V. C determines the polygon colors. If C has the
            % same number of rows as V, it is added as per-vertex colour.
            % Otherwise, it is assumed to be 1x3 (RGB) or 1x4 (RGBA) vector
            % for material colour.
            %
            gltf.asset=struct('version','2.0');
            gltf.scene=0;
            gltf.scenes{1}=struct('nodes',[]);
            gltf.nodes=[];
            gltf.meshes=repmat({struct('primitives',[])},0,1);
            gltf.accessors=repmat({struct('bufferView',[],'componentType',[],'count',[],'type','')},0,1);
            gltf.bufferViews=repmat({struct('buffer',[],'byteLength',[],'byteOffset',[])},0,1);
            gltf.buffers=repmat({struct('byteLength',[],'uri',[])},0,1);
            if(nargin>1)
                F=varargin{1};
                V=varargin{2};
                if(nargin>2)
                    C=varargin{3};
                else
                    C=lines(1);
                end
                if(and(or(size(C,2)==3,size(C,2)==4),size(C,1)==size(V,1)))
                    gltf.addNode('mesh',gltf.addMesh(V,'indices',F,'COLOR',C));
                elseif(and(or(size(C,2)==3,size(C,2)==4),size(C,1)==1))
                    gltf.addNode('mesh',gltf.addMesh(V,'indices',F,'material',gltf.addMaterial('baseColorFactor',C)));
                else
                    gltf.addNode('mesh',gltf.addMesh(V,'indices',F,'material',gltf.addMaterial('baseColorFactor',lines(1))));
                end
            elseif(nargin>0)
                filename=varargin{1};
                [~,~,ext]=fileparts(filename);
                if(or(ext==".glb",ext==".gltf"))
                    if(ext==".glb")
                        fid=fopen(filename,'r');
                        finalBuffer=uint8(fread(fid));
                        fclose(fid);
                        glb=and(typecast(finalBuffer(1:4),'uint32')==hex2dec('46546C67'),typecast(finalBuffer(5:8),'uint32')==2);
                        jsonChunkType=typecast(finalBuffer(17:20),'uint32')==hex2dec('4E4F534A');
                        jsonAlignedLength=typecast(finalBuffer(13:16),'uint32');
                        glb=glb && jsonChunkType;
                        if(glb)
                            jsonBuffer=finalBuffer(21:20+jsonAlignedLength);
                            if(numel(finalBuffer)>20+jsonAlignedLength)
                                binAlignedLength=typecast(finalBuffer(21+jsonAlignedLength:24+jsonAlignedLength),'uint32');                            
                                binBuffer=finalBuffer(29+jsonAlignedLength:28+jsonAlignedLength+binAlignedLength);
                            else
                                binBuffer=[];
                            end
                            gltf2=jsondecode(string(char(jsonBuffer')));
                            fnames=fieldnames(gltf2);
                            if(isfield(gltf2,'scene'))
                                gltf2.scene=GLTF.toMat(gltf2.scene);
                            end
                            for i=1:numel(fnames)
                                if(~isprop(gltf,fnames{i}))
                                    gltf.addprop(fnames{i});
                                end
                                if(strcmpi(fnames{i},'scene'))
                                    gltf.(fnames{i})=gltf2.(fnames{i});
                                else
                                    gltf.(fnames{i})=GLTF.toCells(gltf2.(fnames{i}));
                                end
                            end
                            if(~isempty(binBuffer))
                                gltf.buffers{1}=binBuffer;
                            end
                        end
                    elseif(ext==".gltf")
                        decoder=org.apache.commons.codec.binary.Base64;
                        gltf2=jsondecode(fileread(filename));
                        fnames=fieldnames(gltf2);
                        if(isfield(gltf2,'scene'))
                            gltf2.scene=GLTF.toMat(gltf2.scene);
                        end
                        for i=1:numel(fnames)
                            if(~isprop(gltf,fnames{i}))
                                gltf.addprop(fnames{i});
                            end
                            if(strcmpi(fnames{i},'scene'))
                                gltf.(fnames{i})=gltf2.(fnames{i});
                            else
                                gltf.(fnames{i})=GLTF.toCells(gltf2.(fnames{i}));
                            end
                        end
                    end
                    for i=1:numel(gltf.scenes)
                        gltf.scenes{i}.nodes=GLTF.toCells(gltf.scenes{i}.nodes);
                    end
                    for i=1:numel(gltf.meshes)
                        gltf.meshes{i}.primitives=GLTF.toCells(gltf.meshes{i}.primitives);
                        for j=1:numel(gltf.meshes{i}.primitives)
                            if(isfield(gltf.meshes{i}.primitives{j},'targets'))
                                gltf.meshes{i}.primitives{j}.targets=GLTF.toCells(gltf.meshes{i}.primitives{j}.targets);
                            end
                        end
                        if(isfield(gltf.meshes{i},'weights'))
                            gltf.meshes{i}.weights=GLTF.toCells(gltf.meshes{i}.weights);
                        end
                    end
                    componentType_num=[  5120,           5121,   5122,            5123,          5125,   5126];
                    componentType_Fcn={ @int8,         @uint8, @int16,         @uint16,       @uint32,@single};
                    for i=1:numel(gltf.nodes)
                        node=gltf.nodes{i};
                        if(isfield(node,'children'))
                            node.children=num2cell(uint32(node.children));
                        end
                        gltf.nodes{i}=node;
                    end
                    for i=1:numel(gltf.accessors)
                        accessor=gltf.accessors{i};
                        accessor.bufferView=uint32(accessor.bufferView);
                        accessor.componentType=uint16(accessor.componentType);
                        castFcn=componentType_Fcn{accessor.componentType==componentType_num};
                        accessor.count=uint32(accessor.count);
                        if(string(accessor.type)=="SCALAR")
                            if(isfield(accessor,'max'))
                                accessor.max=num2cell(castFcn(accessor.max));
                            end
                            if(isfield(accessor,'min'))
                                accessor.min=num2cell(castFcn(accessor.min));
                            end
                        end
                        gltf.accessors{i}=accessor;
                    end
                    for i=1:numel(gltf.bufferViews)
                        bufferView=gltf.bufferViews{i};
                        bufferView.buffer=uint32(bufferView.buffer);
                        bufferView.byteLength=uint32(bufferView.byteLength);
                        if(isfield(bufferView,"byteOffset"))
                            bufferView.byteOffset=uint32(bufferView.byteOffset);
                        else
                            bufferView.byteOffset=uint32(0);
                        end
                        gltf.bufferViews{i}=bufferView;
                    end
                    for i=1:numel(gltf.buffers)
                        buffer=gltf.buffers{i};
                        if(isfield(buffer,'uri'))
                            encoded=regexpi(buffer.uri,"data\:([\w\/\-]+\;)?(\w+)?,([A-Za-z0-9\/+\/=]*)",'tokens');
                            if(isempty(encoded))
                                [filepath,~,~]=fileparts(filename);
                                if(filepath=="")
                                    fid2=fopen(string(buffer.uri),'r');
                                else
                                    fid2=fopen(filepath+string(filesep)+string(buffer.uri),'r');
                                end
                                gltf.buffers{i}=uint8(fread(fid2));
                                fclose(fid2);
                            else
                                encoded=encoded{1}{3};
                                gltf.buffers{i}=decoder.decode(uint8(encoded));
                            end
                        end
                    end
                    if(isprop(gltf,'animations'))
                        for i=1:numel(gltf.animations)
                            gltf.animations{i}.samplers=GLTF.toCells(gltf.animations{i}.samplers);
                            gltf.animations{i}.channels=GLTF.toCells(gltf.animations{i}.channels);
                        end
                    end
                    if(iscell(gltf.asset))
                        gltf.asset=gltf.asset{1};
                    end
                end
            end
        end

        gltf=plus(gltf1,gltf2)
        writeGLTF(gltf,filename,varargin)
        writeGLB(gltf,filename,varargin)
        light_idx=addDirectionalLight(gltf,varargin)
        light_idx=addPointLight(gltf,varargin)
        light_idx=addSpotLight(gltf,varargin)
        camera_idx=addOrthographicCamera(gltf,varargin)
        camera_idx=addPerspectiveCamera(gltf,varargin)
        samplerstruct=addAnimationSampler(~,input,output,varargin)
        channelstruct=addAnimationChannel(~,sampler,target_node,target_path)
        addAnimation(gltf,samplers,channels,varargin)
        bufferView=addBufferView(gltf,data,componentType,target)
        accessor_idx=addBinaryData(gltf,data,componentType,dataCount,minmax,target)
        node_idx=addNode(gltf,varargin)
        skin_idx=addSkin(gltf,joints,varargin)
        addMorphTarget(gltf,mesh_idx,V,varargin)
        addTargetToPrimitive(gltf,mesh_idx,primitive_idx,V,varargin)
        primitive_idx=addPrimitiveToMesh(gltf,mesh_idx,V,varargin)
        mesh_idx=addMesh(gltf,V,varargin)
        material_idx=addMaterial(gltf,varargin)
        data=getAccessor(gltf,accessor_idx)
        writeDAE(gltf,filename,varargin)
        mat=getNodeTransformation(gltf,node_idx)
        sampler_idx=addTextureSampler(gltf,varargin)
        image_idx=addImage(gltf,image,varargin)
        texture_idx=addTexture(gltf,image,varargin)
        [node,library_geometries,library_controllers,node_list]=getNode(gltf,documentNode,library_geometries,library_controllers,node_id,node_list,normals,tangents,binormals)
        [node,library_geometries,library_controllers,node_list]=getMeshNode(gltf,documentNode,library_geometries,library_controllers,node_id,node_list,normals,tangents,binormals)
        [pred,isMesh]=nodeTree(gltf)
        addExtension(gltf,extension)
        audio_id=addAudio(gltf,audio,varargin)
        source_id=addSource(gltf,audio_id,varargin)
        emitter_id=addPositionalEmitter(gltf,varargin)
        emitter_id=addGlobalEmitter(gltf,varargin)
    end

    methods(Static)
        out=toCells(mat)
        out=toMat(cells)
        F=toTriangles(F)
        F=fromTriangles(F)
        Nf=faceNormals(F,V)
        [Tf,Bf]=faceTangents(F,V,UV)
        [Nv,F,idx]=vertexNormals(F,V)
        [Tv,Bv,F,idx]=vertexTangents(F,V,UV)
        R=Q2PreR(q)
        axisangle=Q2AxisAngle(q)
    end

    methods(Static,Access=private)
        formatSpec_float=formatSpec_float()
        formatSpec_integer=formatSpec_integer()
        valid=validateString(input,possibilities)
        out=joinString(strings)
        base64string=string2URI(filename)
    end
end
