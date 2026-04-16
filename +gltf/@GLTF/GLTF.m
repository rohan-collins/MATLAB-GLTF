classdef GLTF < dynamicprops
    % Read and write GLTF 3D model and animation files.
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
        function obj=GLTF(filename,varargin)
            % Class constructor.
            %
            % gltf.GLTF() creates and returns a blank GLTF model.
            %
            % gltf.GLTF(FILENAME) reads the GLTF file FILENAME and returns
            % a GLTF object.
            %
            % gltf.GLTF(FILENAME,'readBuffer',FALSE) reads the GLTF file
            % FILENAME but leaves referencing buffers as URI.
            % GLTF object.
            %
            ips=inputParser;
            ips.addOptional('filename',missing);
            ips.addParameter('readBuffer',true,@islogical);
            ips.parse(varargin{:});
            parameters=ips.Results;
            readBuffer=parameters.readBuffer;
            obj.asset=struct('version','2.0');
            obj.scene=0;
            obj.scenes{1}=struct('nodes',[]);
            obj.nodes=[];
            obj.meshes=repmat({struct('primitives',[])},0,1);
            obj.accessors=repmat({struct('bufferView',[],'componentType',[],'count',[],'type','')},0,1);
            obj.bufferViews=repmat({struct('buffer',[],'byteLength',[],'byteOffset',[])},0,1);
            obj.buffers=repmat({struct('byteLength',[],'uri',[])},0,1);
            if(nargin>0)
                [~,~,ext]=fileparts(filename);
                if(or(ext==".glb",ext==".gltf"))
                    if(ext==".glb")
                        finalBuffer=gltf.GLTF.read_file(filename,"b");
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
                            obj2=jsondecode(string(char(jsonBuffer')));
                            fnames=fieldnames(obj2);
                            if(isfield(obj2,'scene'))
                                obj2.scene=gltf.GLTF.toMat(obj2.scene);
                            end
                            for i=1:numel(fnames)
                                if(~isprop(obj,fnames{i}))
                                    obj.addprop(fnames{i});
                                end
                                if(strcmpi(fnames{i},'scene'))
                                    obj.(fnames{i})=obj2.(fnames{i});
                                else
                                    obj.(fnames{i})=gltf.GLTF.toCells(obj2.(fnames{i}));
                                end
                            end
                            if(~isempty(binBuffer))
                                obj.buffers{1}=binBuffer;
                            end
                        end
                    elseif(ext==".gltf")
                        finalBuffer=gltf.GLTF.read_file(filename);
                        obj2=jsondecode(finalBuffer);
                        fnames=fieldnames(obj2);
                        if(isfield(obj2,'scene'))
                            obj2.scene=gltf.GLTF.toMat(obj2.scene);
                        end
                        for i=1:numel(fnames)
                            if(~isprop(obj,fnames{i}))
                                obj.addprop(fnames{i});
                            end
                            if(strcmpi(fnames{i},'scene'))
                                obj.(fnames{i})=obj2.(fnames{i});
                            else
                                obj.(fnames{i})=gltf.GLTF.toCells(obj2.(fnames{i}));
                            end
                        end
                    end
                    for i=1:numel(obj.scenes)
                        obj.scenes{i}.nodes=gltf.GLTF.toCells(obj.scenes{i}.nodes);
                    end
                    for i=1:numel(obj.meshes)
                        obj.meshes{i}.primitives=gltf.GLTF.toCells(obj.meshes{i}.primitives);
                        for j=1:numel(obj.meshes{i}.primitives)
                            if(isfield(obj.meshes{i}.primitives{j},'targets'))
                                obj.meshes{i}.primitives{j}.targets=gltf.GLTF.toCells(obj.meshes{i}.primitives{j}.targets);
                            end
                        end
                        if(isfield(obj.meshes{i},'weights'))
                            obj.meshes{i}.weights=gltf.GLTF.toCells(obj.meshes{i}.weights);
                        end
                    end
                    componentType_num=[  5120,           5121,   5122,            5123,          5125,   5126];
                    componentType_Fcn={ @int8,         @uint8, @int16,         @uint16,       @uint32,@single};
                    for i=1:numel(obj.nodes)
                        node=obj.nodes{i};
                        if(isfield(node,'children'))
                            node.children=num2cell(uint32(node.children));
                        end
                        obj.nodes{i}=node;
                    end
                    for i=1:numel(obj.accessors)
                        accessor=obj.accessors{i};
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
                        obj.accessors{i}=accessor;
                    end
                    for i=1:numel(obj.bufferViews)
                        bufferView=obj.bufferViews{i};
                        bufferView.buffer=uint32(bufferView.buffer);
                        bufferView.byteLength=uint32(bufferView.byteLength);
                        if(isfield(bufferView,"byteOffset"))
                            bufferView.byteOffset=uint32(bufferView.byteOffset);
                        else
                            bufferView.byteOffset=uint32(0);
                        end
                        obj.bufferViews{i}=bufferView;
                    end
                    if(readBuffer)
                        for i=1:numel(obj.buffers)
                            buffer=obj.buffers{i};
                            if(isfield(buffer,'uri'))
                                encoded=regexpi(buffer.uri,"data\:([\w\/\-]+\;)?(\w+)?,([A-Za-z0-9\/+\/=]*)",'tokens');
                                if(isempty(encoded))
                                    [filepath,name,~]=fileparts(filename);
                                    if(gltf.GLTF.is_url(filename))
                                        obj.buffers{i}=gltf.GLTF.read_file(filepath+"/"+string(buffer.uri),"b");
                                    else
                                        if(filepath=="")
                                            obj.buffers{i}=gltf.GLTF.read_file(string(buffer.uri),"b");
                                        else
                                            sep_local=extractBefore(extractAfter(filename,filepath),name);
                                            obj.buffers{i}=gltf.GLTF.read_file(filepath+sep_local+string(buffer.uri),"b");
                                        end
                                    end
                                else
                                    encoded=encoded{1}{3};
                                    obj.buffers{i}=matlab.net.base64decode(encoded);
                                end
                            end
                        end
                    else
                        for i=1:numel(obj.buffers)
                            obj.buffers{i}.byteLength=uint32(obj.buffers{i}.byteLength);
                        end
                    end
                    if(isprop(obj,'animations'))
                        for i=1:numel(obj.animations)
                            obj.animations{i}.samplers=gltf.GLTF.toCells(obj.animations{i}.samplers);
                            obj.animations{i}.channels=gltf.GLTF.toCells(obj.animations{i}.channels);
                        end
                    end
                    if(iscell(obj.asset))
                        obj.asset=obj.asset{1};
                    end
                end
            end
        end

        obj=plus(obj1,obj2)
        writeGLTF(obj,filename,varargin)
        writeGLB(obj,filename,varargin)
        light_idx=addDirectionalLight(obj,varargin)
        light_idx=addPointLight(obj,varargin)
        light_idx=addSpotLight(obj,varargin)
        camera_idx=addOrthographicCamera(obj,varargin)
        camera_idx=addPerspectiveCamera(obj,varargin)
        samplerstruct=addAnimationSampler(~,input,output,varargin)
        channelstruct=addAnimationChannel(obj,sampler,target_node,target_path)
        channelstruct=addAnimationPointerChannel(~,sampler,target_path)
        addAnimation(obj,samplers,channels,varargin)
        accessor_idx=addBinaryData(obj,data,componentType,dataCount,minmax,target)
        node_idx=addNode(obj,varargin)
        skin_idx=addSkin(obj,joints,varargin)
        addMorphTarget(obj,mesh_idx,V,varargin)
        addTargetToPrimitive(obj,mesh_idx,primitive_idx,V,varargin)
        primitive_idx=addPrimitiveToMesh(obj,mesh_idx,V,varargin)
        mesh_idx=addMesh(obj,V,varargin)
        material_idx=addMaterial(obj,varargin)
        data=getAccessor(obj,accessor_idx)
        writeDAE(obj,filename,varargin)
        mat=getNodeTransformation(obj,node_idx)
        sampler_idx=addTextureSampler(obj,varargin)
        image_idx=addImage(obj,image,varargin)
        texture_idx=addTexture(obj,image,varargin)
        [node,library_geometries,library_controllers,node_list]=getNode(obj,documentNode,library_geometries,library_controllers,node_id,node_list,normals,tangents,binormals)
        [node,library_geometries,library_controllers,node_list]=getMeshNode(obj,documentNode,library_geometries,library_controllers,node_id,node_list,normals,tangents,binormals)
        [pred,isMesh,hasSkin]=nodeTree(obj)
        addExtension(obj,extension,required)
        clip_id=addClip(obj,filename,varargin)
        emitter_id=addEmitter(obj,clips,varargin)
        eventStruct=createEventStruct(~,emitter,action,varargin)
        writeOBJ(obj,filename,varargin)
        writePLY(obj,filename,varargin)
    end

    methods(Static)
        out=toCells(mat)
        out=toMat(cells)
        F=toTriangles(F)
        F=fromTriangles(F)
        F=fromTriangleStrip(F)
        F=fromTriangleFan(F)
        E=fromLines(E)
        E=fromLineLoop(E)
        E=fromLineStrip(E)
        Nf=faceNormals(F,V)
        [Tf,Bf]=faceTangents(F,V,UV)
        [Nv,F,idx]=vertexNormals(F,V)
        [Tv,Bv,F,idx]=vertexTangents(F,V,UV)
        R=Q2PreR(q)
        axisangle=Q2AxisAngle(q)
        [F,V,varargout]=catmullClark(F,V,varargin);
    end

    methods(Static,Access=private)
        reg=url_regex()
        tf=is_url(str)
        reg=filepath_regex()
        tf=is_filepath(str)
        out=read_file(filename,varargin)
        formatSpec_float=formatSpec_float()
        formatSpec_integer=formatSpec_integer()
        valid=validateString(input,possibilities)
        valid=validateStringWithIndex(input,possibilities,placeholder)
        valid=validateInteger(input,min,max)
        out=joinString(strings)
        base64string=string2URI(filename)
        [relative1,relative2]=getRelativePath(filename1,filename2)
    end
end
