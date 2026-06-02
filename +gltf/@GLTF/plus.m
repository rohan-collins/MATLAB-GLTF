function obj=plus(obj1,obj2)
    % Combine two GTLF objects.
    %
    % obj1 + obj2 combines the two GLTF objects GLTF1 and GLTF2.
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
    n_nodes=numel(obj1.nodes);
    n_meshes=numel(obj1.meshes);
    if(isprop(obj1,'materials'))
    	n_materials=numel(obj1.materials);
    else
        n_materials=0;
    end
    n_bufferViews=numel(obj1.bufferViews);
    n_accessors=numel(obj1.accessors);
    n_buffers=numel(obj1.buffers);
    if(isprop(obj1,'skins'))
        n_skins=numel(obj1.skins);
    else
        n_skins=0;
    end
    if(isprop(obj1,'images'))
        n_images=numel(obj1.images);
    else
        n_images=0;
    end
    if(isprop(obj1,'samplers'))
        n_samplers=numel(obj1.samplers);
    else
        n_samplers=0;
    end
    if(isprop(obj1,'textures'))
        n_textures=numel(obj1.textures);
    else
        n_textures=0;
    end
    new_scenes=obj1.scenes;
    new_scenes{1}.nodes=[reshape(gltf.GLTF.toMat(obj1.scenes{1}.nodes),1,[]) reshape(gltf.GLTF.toMat(obj2.scenes{1}.nodes)+n_nodes,1,[])]';
    accessors_save=obj2.accessors;
    for i=1:numel(obj2.accessors)
        if(isfield(obj2.accessors{i},'bufferView'))
            obj2.accessors{i}.bufferView=obj2.accessors{i}.bufferView+n_bufferViews;
        end
    end
    bufferViews_save=obj2.bufferViews;
    for i=1:numel(obj2.bufferViews)
        if(isfield(obj2.bufferViews{i},'buffer'))
            obj2.bufferViews{i}.buffer=obj2.bufferViews{i}.buffer+n_buffers;
        end
    end
    if(and(isprop(obj1,'materials'),isprop(obj2,'materials')))
        materials_save=obj2.materials;
        for i=1:numel(obj2.materials)
            if(isfield(obj2.materials{i}.pbrMetallicRoughness,'baseColorTexture'))
                obj2.materials{i}.pbrMetallicRoughness.baseColorTexture.index=obj2.materials{i}.pbrMetallicRoughness.baseColorTexture.index+n_textures;
            end
            if(isfield(obj2.materials{i},'normalTexture'))
                obj2.materials{i}.normalTexture.index=obj2.materials{i}.normalTexture.index+n_textures;
            end
            if(isfield(obj2.materials{i},'occlusionTexture'))
                obj2.materials{i}.occlusionTexture.index=obj2.materials{i}.occlusionTexture.index+n_textures;
            end
            if(isfield(obj2.materials{i},'baseColorTexture'))
                obj2.materials{i}.emissiveTexture.index=obj2.materials{i}.emissiveTexture.index+n_textures;
            end
        end
    end
    if(and(isprop(obj1,'textures'),isprop(obj2,'textures')))
        textures_save=obj2.textures;
        for i=1:numel(obj2.textures)
            obj2.textures{i}.sampler=obj2.textures{i}.sampler+n_samplers;
            obj2.textures{i}.source=obj2.textures{i}.source+n_images;
        end
    end
    nodes_save=obj2.nodes;
    for i=1:numel(obj2.nodes)
        if(isfield(obj2.nodes{i},'children'))
            obj2.nodes{i}.children=gltf.GLTF.toCells(cell2mat(obj2.nodes{i}.children)+n_nodes);
        end
        if(isfield(obj2.nodes{i},'mesh'))
            obj2.nodes{i}.mesh=obj2.nodes{i}.mesh+n_meshes;
        end
        if(isfield(obj2.nodes{i},'skin'))
            obj2.nodes{i}.skin=obj2.nodes{i}.skin+n_skins;
        end
    end
    meshes_save=obj2.meshes;
    for i=1:numel(obj2.meshes)
        for j=1:numel(obj2.meshes{i}.primitives)
            fnames=fieldnames(obj2.meshes{i}.primitives{j}.attributes);
            for k=1:numel(fnames)
                obj2.meshes{i}.primitives{j}.attributes.(fnames{k})=obj2.meshes{i}.primitives{j}.attributes.(fnames{k})+n_accessors;
            end
            if(isfield(obj2.meshes{i}.primitives{j},'targets'))
                for k=1:numel(obj2.meshes{i}.primitives{j}.targets)
                    fnames=fieldnames(obj2.meshes{i}.primitives{j}.targets{k});
                    for l=1:numel(fnames)
                        obj2.meshes{i}.primitives{j}.targets{k}.(fnames{l})=obj2.meshes{i}.primitives{j}.targets{k}.(fnames{l})+n_accessors;
                    end
                end
            end
            if(isfield(obj2.meshes{i}.primitives{j},'indices'))
                obj2.meshes{i}.primitives{j}.indices=obj2.meshes{i}.primitives{j}.indices+n_accessors;
            end
            if(isfield(obj2.meshes{i}.primitives{j},'material'))
                obj2.meshes{i}.primitives{j}.material=obj2.meshes{i}.primitives{j}.material+n_materials;
            end
        end
    end
    if(and(isprop(obj1,'skins'),isprop(obj2,'skins')))
        skins_save=obj2.skins;
        for i=1:numel(obj2.skins)
            obj2.skins{i}.joints=cell2mat(obj2.skins{i}.joints)+n_nodes;
            obj2.skins{i}.inverseBindMatrices=obj2.skins{i}.inverseBindMatrices+n_accessors;
        end
    end
    if(and(isprop(obj1,'animations'),isprop(obj2,'animations')))
        animations_save=obj2.animations;
        for i=1:numel(obj2.animations)
            for j=1:numel(obj2.animations{i}.samplers)
                obj2.animations{i}.samplers{j}.input=obj2.animations{i}.samplers{j}.input+n_accessors;
                obj2.animations{i}.samplers{j}.output=obj2.animations{i}.samplers{j}.output+n_accessors;
            end
            for j=1:numel(obj2.animations{i}.channels)
                obj2.animations{i}.channels{j}.target.node=obj2.animations{i}.channels{j}.target.node+n_nodes;
            end
        end
    end
    obj=gltf.GLTF();
    fnames1=string(fieldnames(obj1));
    fnames2=string(fieldnames(obj2));
    fnames=setdiff(intersect(fnames1,fnames2),"asset");
    fnames1=setdiff(fnames1,fnames);
    fnames2=setdiff(fnames2,fnames);
    for i=1:numel(fnames)
        if(~isprop(obj,fnames(i)))
            obj.addprop(fnames(i));
        end
        obj.(fnames(i))=[obj1.(fnames(i))(:);obj2.(fnames(i))(:)]';
    end
    for i=1:numel(fnames1)
        if(~isprop(obj,fnames1(i)))
            obj.addprop(fnames1(i));
        end
        obj.(fnames1(i))=obj1.(fnames1(i))(:)';
    end
    for i=1:numel(fnames2)
        if(~isprop(obj,fnames2(i)))
            obj.addprop(fnames2(i));
        end
        obj.(fnames2(i))=obj2.(fnames2(i))(:)';
    end
    obj.asset=struct('version','2.0');
    obj.scene=0;
    obj.scenes={struct('nodes',[reshape(gltf.GLTF.toMat(obj1.scenes{1}.nodes),1,[]) reshape(gltf.GLTF.toMat(obj2.scenes{1}.nodes)+n_nodes,1,[])])};
    obj2.accessors=accessors_save;
    obj2.bufferViews=bufferViews_save;
    obj2.nodes=nodes_save;
    obj2.meshes=meshes_save;
    if(and(isprop(obj1,'animations'),isprop(obj2,'animations')))
        obj2.animations=animations_save;
    end
    if(and(isprop(obj1,'skins'),isprop(obj2,'skins')))
        obj2.skins=skins_save;
    end
    if(and(isprop(obj1,'materials'),isprop(obj2,'materials')))
        obj2.materials=materials_save;
    end
    if(and(isprop(obj1,'textures'),isprop(obj2,'textures')))
        obj2.textures=textures_save;
    end
end
