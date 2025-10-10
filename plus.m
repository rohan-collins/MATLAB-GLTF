function gltf=plus(gltf1,gltf2)
    % Combine two GTLF objects.
    %
    % gltf1 + gltf2 combines the two GLTF objects GLTF1 and GLTF2.
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
    n_nodes=numel(gltf1.nodes);
    n_meshes=numel(gltf1.meshes);
    if(isprop(gltf1,'materials'))
    	n_materials=numel(gltf1.materials);
    else
        n_materials=0;
    end
    n_bufferViews=numel(gltf1.bufferViews);
    n_accessors=numel(gltf1.accessors);
    n_buffers=numel(gltf1.buffers);
    if(isprop(gltf1,'skins'))
        n_skins=numel(gltf1.skins);
    else
        n_skins=0;
    end
    if(isprop(gltf1,'images'))
        n_images=numel(gltf1.images);
    else
        n_images=0;
    end
    if(isprop(gltf1,'samplers'))
        n_samplers=numel(gltf1.samplers);
    else
        n_samplers=0;
    end
    if(isprop(gltf1,'textures'))
        n_textures=numel(gltf1.textures);
    else
        n_textures=0;
    end
    new_scenes=gltf1.scenes;
    new_scenes{1}.nodes=[reshape(GLTF.toMat(gltf1.scenes{1}.nodes),1,[]) reshape(GLTF.toMat(gltf2.scenes{1}.nodes)+n_nodes,1,[])]';
    accessors_save=gltf2.accessors;
    for i=1:numel(gltf2.accessors)
        if(isfield(gltf2.accessors{i},'bufferView'))
            gltf2.accessors{i}.bufferView=gltf2.accessors{i}.bufferView+n_bufferViews;
        end
    end
    bufferViews_save=gltf2.bufferViews;
    for i=1:numel(gltf2.bufferViews)
        if(isfield(gltf2.bufferViews{i},'buffer'))
            gltf2.bufferViews{i}.buffer=gltf2.bufferViews{i}.buffer+n_buffers;
        end
    end
    if(and(isprop(gltf1,'materials'),isprop(gltf2,'materials')))
        materials_save=gltf2.materials;
        for i=1:numel(gltf2.materials)
            if(isfield(gltf2.materials{i}.pbrMetallicRoughness,'baseColorTexture'))
                gltf2.materials{i}.pbrMetallicRoughness.baseColorTexture.index=gltf2.materials{i}.pbrMetallicRoughness.baseColorTexture.index+n_textures;
            end
            if(isfield(gltf2.materials{i},'normalTexture'))
                gltf2.materials{i}.normalTexture.index=gltf2.materials{i}.normalTexture.index+n_textures;
            end
            if(isfield(gltf2.materials{i},'occlusionTexture'))
                gltf2.materials{i}.occlusionTexture.index=gltf2.materials{i}.occlusionTexture.index+n_textures;
            end
            if(isfield(gltf2.materials{i},'baseColorTexture'))
                gltf2.materials{i}.emissiveTexture.index=gltf2.materials{i}.emissiveTexture.index+n_textures;
            end
        end
    end
    if(and(isprop(gltf1,'textures'),isprop(gltf2,'textures')))
        textures_save=gltf2.textures;
        for i=1:numel(gltf2.textures)
            gltf2.textures{i}.sampler=gltf2.textures{i}.sampler+n_samplers;
            gltf2.textures{i}.source=gltf2.textures{i}.source+n_images;
        end
    end
    nodes_save=gltf2.nodes;
    for i=1:numel(gltf2.nodes)
        if(isfield(gltf2.nodes{i},'children'))
            gltf2.nodes{i}.children=GLTF.toCells(cell2mat(gltf2.nodes{i}.children)+n_nodes);
        end
        if(isfield(gltf2.nodes{i},'mesh'))
            gltf2.nodes{i}.mesh=gltf2.nodes{i}.mesh+n_meshes;
        end
        if(isfield(gltf2.nodes{i},'skin'))
            gltf2.nodes{i}.skin=gltf2.nodes{i}.skin+n_skins;
        end
    end
    meshes_save=gltf2.meshes;
    for i=1:numel(gltf2.meshes)
        for j=1:numel(gltf2.meshes{i}.primitives)
            fnames=fieldnames(gltf2.meshes{i}.primitives{j}.attributes);
            for k=1:numel(fnames)
                gltf2.meshes{i}.primitives{j}.attributes.(fnames{k})=gltf2.meshes{i}.primitives{j}.attributes.(fnames{k})+n_accessors;
            end
            if(isfield(gltf2.meshes{i}.primitives{j},'targets'))
                for k=1:numel(gltf2.meshes{i}.primitives{j}.targets)
                    fnames=fieldnames(gltf2.meshes{i}.primitives{j}.targets{k});
                    for l=1:numel(fnames)
                        gltf2.meshes{i}.primitives{j}.targets{k}.(fnames{l})=gltf2.meshes{i}.primitives{j}.targets{k}.(fnames{l})+n_accessors;
                    end
                end
            end
            if(isfield(gltf2.meshes{i}.primitives{j},'indices'))
                gltf2.meshes{i}.primitives{j}.indices=gltf2.meshes{i}.primitives{j}.indices+n_accessors;
            end
            if(isfield(gltf2.meshes{i}.primitives{j},'material'))
                gltf2.meshes{i}.primitives{j}.material=gltf2.meshes{i}.primitives{j}.material+n_materials;
            end
        end
    end
    if(and(isprop(gltf1,'skins'),isprop(gltf2,'skins')))
        skins_save=gltf2.skins;
        for i=1:numel(gltf2.skins)
            gltf2.skins{i}.joints=cell2mat(gltf2.skins{i}.joints)+n_nodes;
            gltf2.skins{i}.inverseBindMatrices=gltf2.skins{i}.inverseBindMatrices+n_accessors;
        end
    end
    if(and(isprop(gltf1,'animations'),isprop(gltf2,'animations')))
        animations_save=gltf2.animations;
        for i=1:numel(gltf2.animations)
            for j=1:numel(gltf2.animations{i}.samplers)
                gltf2.animations{i}.samplers{j}.input=gltf2.animations{i}.samplers{j}.input+n_accessors;
                gltf2.animations{i}.samplers{j}.output=gltf2.animations{i}.samplers{j}.output+n_accessors;
            end
            for j=1:numel(gltf2.animations{i}.channels)
                gltf2.animations{i}.channels{j}.target.node=gltf2.animations{i}.channels{j}.target.node+n_nodes;
            end
        end
    end
    gltf=GLTF();
    fnames1=string(fieldnames(gltf1));
    fnames2=string(fieldnames(gltf2));
    fnames=setdiff(intersect(fnames1,fnames2),"asset");
    fnames1=setdiff(fnames1,fnames);
    fnames2=setdiff(fnames2,fnames);
    for i=1:numel(fnames)
        if(~isprop(gltf,fnames(i)))
            gltf.addprop(fnames(i));
        end
        gltf.(fnames(i))=[gltf1.(fnames(i))(:);gltf2.(fnames(i))(:)]';
    end
    for i=1:numel(fnames1)
        if(~isprop(gltf,fnames1(i)))
            gltf.addprop(fnames1(i));
        end
        gltf.(fnames1(i))=gltf1.(fnames1(i))(:)';
    end
    for i=1:numel(fnames2)
        if(~isprop(gltf,fnames2(i)))
            gltf.addprop(fnames2(i));
        end
        gltf.(fnames2(i))=gltf2.(fnames2(i))(:)';
    end
    gltf.asset=struct('version','2.0');
    gltf.scene=0;
    gltf.scenes={struct('nodes',[reshape(GLTF.toMat(gltf1.scenes{1}.nodes),1,[]) reshape(GLTF.toMat(gltf2.scenes{1}.nodes)+n_nodes,1,[])])};
    gltf2.accessors=accessors_save;
    gltf2.bufferViews=bufferViews_save;
    gltf2.nodes=nodes_save;
    gltf2.meshes=meshes_save;
    if(and(isprop(gltf1,'animations'),isprop(gltf2,'animations')))
        gltf2.animations=animations_save;
    end
    if(and(isprop(gltf1,'skins'),isprop(gltf2,'skins')))
        gltf2.skins=skins_save;
    end
    if(and(isprop(gltf1,'materials'),isprop(gltf2,'materials')))
        gltf2.materials=materials_save;
    end
    if(and(isprop(gltf1,'textures'),isprop(gltf2,'textures')))
        gltf2.textures=textures_save;
    end
end
