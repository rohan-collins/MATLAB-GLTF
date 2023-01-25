function writeDAE(gltf,filename,varargin)
    % Write a COLLADA file for Mac compatibility.
    %
    % WRITEDAE(GLTF,FILENAME) writes GLTF to a COLLADA file specified by
    % filename.
    %
    % WRITEDAE(...,'up_axis',UP_AXIS) sets up axis to use in the COLLADA
    % file. UP_AXIS must be one of "X_UP", "Y_UP", or "Z_UP". Default is
    % "Y_UP".
    %
    % WRITEDAE(...,'normals',TRUE) forces calculation and inclusion of
    % normals.
    %
    % WRITEDAE(...,'tangents',TRUE) forces calculation and inclusion of
    % tangents.
    %
    % WRITEDAE(...,'binormals',TRUE) forces calculation and inclusion of
    % binormals.
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
    up_axis_str_values=["X_UP","Y_UP","Z_UP"];
    ips=inputParser;
    ips.addParameter('up_axis',"Y_UP",@(x)GLTF.validateString(x,up_axis_str_values));
    ips.addParameter('normals',false,@islogical);
    ips.addParameter('tangents',false,@islogical);
    ips.addParameter('binormals',false,@islogical);
    ips.parse(varargin{:});
    parameters=ips.Results;
    up_axis=upper(parameters.up_axis);
    normals=parameters.normals;
    tangents=parameters.tangents;
    binormals=parameters.binormals;

    creation=string(datetime(datetime,'Format','uuuu-MM-dd''T''HH:mm:ss'))+"Z";
    documentNode=com.mathworks.xml.XMLUtils.createDocument('COLLADA'); 
    dae=documentNode.getDocumentElement;
    dae.setAttribute("xmlns","http://www.collada.org/2005/11/COLLADASchema");
    dae.setAttribute("version","1.4.1");
    assetNode=documentNode.createElement("asset");
    created=documentNode.createElement("created");
    created.appendChild(documentNode.createTextNode(creation));
    assetNode.appendChild(created);
    modified=documentNode.createElement("modified");
    modified.appendChild(documentNode.createTextNode(creation));
    assetNode.appendChild(modified);
    upAxis=documentNode.createElement("up_axis");
    upAxis.appendChild(documentNode.createTextNode(up_axis));
    assetNode.appendChild(upAxis);
    dae.appendChild(assetNode);

    sceneNode=documentNode.createElement("scene");
    instance_visual_scene=documentNode.createElement("instance_visual_scene");
    instance_visual_scene.setAttribute("url","#scene_"+string(gltf.scene+1));
    sceneNode.appendChild(instance_visual_scene);
    dae.appendChild(sceneNode);

    library_visual_scenes=documentNode.createElement("library_visual_scenes");
    library_geometries=documentNode.createElement("library_geometries");
    library_controllers=documentNode.createElement("library_controllers");
    node_list=cell(0,1);
    for scene_id=1:numel(gltf.scenes)
        visual_scene=documentNode.createElement("visual_scene");
        visual_scene.setAttribute("id","scene_"+string(scene_id));
        [pred,isMesh]=gltf.nodeTree();
        rootAndMesh=and(pred==0,isMesh);
        for node_id=find(rootAndMesh)'
            [node,library_geometries,library_controllers,node_list]=gltf.getNode(documentNode,library_geometries,library_controllers,node_id,node_list,normals,tangents,binormals);
            visual_scene.appendChild(node);
        end
        skeleton_roots=ismember(pred,find(isMesh));
        for node_id=find(skeleton_roots)'
            [node,library_geometries,library_controllers,node_list]=gltf.getNode(documentNode,library_geometries,library_controllers,node_id,node_list,normals,tangents,binormals);
            visual_scene.appendChild(node);
        end
        library_visual_scenes.appendChild(visual_scene);
    end
    dae.appendChild(library_visual_scenes);
    dae.appendChild(library_geometries);

    if(isprop(gltf,'skins'))
        for skin_id=1:numel(gltf.skins)
            controller=documentNode.createElement("controller");
            controller.setAttribute("id","skin_"+string(skin_id));

        end
    end
    dae.appendChild(library_controllers);

    if(isprop(gltf,'images'))
        library_images=documentNode.createElement("library_images");
        for image_id=1:numel(gltf.images)
            image=documentNode.createElement("image");
            image.setAttribute("id","image_"+image_id);
            init_from=documentNode.createElement("init_from");
            init_from.appendChild(documentNode.createTextNode(gltf.images{image_id}.uri));
            image.appendChild(init_from);
            library_images.appendChild(image);
        end
        dae.appendChild(library_images);
    end

    if(isprop(gltf,'materials'))
        library_materials=documentNode.createElement("library_materials");
        library_effects=documentNode.createElement("library_effects");
        for material_id=1:numel(gltf.materials)
            material=documentNode.createElement("material");
            material.setAttribute("id","material_"+string(material_id));
            instance_effect=documentNode.createElement("instance_effect");
            instance_effect.setAttribute("url","#effect_"+string(material_id));
            material.appendChild(instance_effect);
            library_materials.appendChild(material);
            effect=documentNode.createElement("effect");
            effect.setAttribute("id","effect_"+string(material_id));
            profile_COMMON=documentNode.createElement("profile_COMMON");
            technique=documentNode.createElement("technique");
            lambert=documentNode.createElement("lambert");
            diffuse=documentNode.createElement("diffuse");

            if(isfield(gltf.materials{material_id}.pbrMetallicRoughness,'baseColorTexture'))
                texture_id=gltf.materials{material_id}.pbrMetallicRoughness.baseColorTexture.index+1;
                image_id=gltf.textures{texture_id}.source+1;
                newparam=documentNode.createElement("newparam");
                newparam.setAttribute("sid","texture_"+string(texture_id)+"-surface");
                surface=documentNode.createElement("surface");
                surface.setAttribute("type","2D");
                init_from=documentNode.createElement("init_from");
                init_from.appendChild(documentNode.createTextNode("image_"+image_id));
                surface.appendChild(init_from);
                newparam.appendChild(surface);
                profile_COMMON.appendChild(newparam);
                newparam=documentNode.createElement("newparam");
                newparam.setAttribute("sid","texture_"+string(texture_id)+"-sampler");
                sampler2D=documentNode.createElement("sampler2D");
                source=documentNode.createElement("source");
                source.appendChild(documentNode.createTextNode("texture_"+string(texture_id)+"-surface"));
                sampler2D.appendChild(source);
                newparam.appendChild(sampler2D);
                profile_COMMON.appendChild(newparam);
                texture=documentNode.createElement("texture");
                texture.setAttribute("texture","texture_"+string(texture_id)+"-sampler");
                texture.setAttribute("texcoord","TEXCOORD_0");
                diffuse.appendChild(texture);
            else
                color=documentNode.createElement("color");
                color.appendChild(documentNode.createTextNode(strip(sprintf(GLTF.formatSpec_float(),gltf.materials{material_id}.pbrMetallicRoughness.baseColorFactor))));
                diffuse.appendChild(color);
            end

            lambert.appendChild(diffuse);
            if(isfield(gltf.materials{material_id}.pbrMetallicRoughness,'baseColorFactor'))
                if(gltf.materials{material_id}.pbrMetallicRoughness.baseColorFactor(4)<1)
                    transparency=documentNode.createElement("transparency");
                    float=documentNode.createElement("float");
                    float.appendChild(documentNode.createTextNode(strip(sprintf(GLTF.formatSpec_float(),gltf.materials{material_id}.pbrMetallicRoughness.baseColorFactor(4)))));
                    transparency.appendChild(float);
                    lambert.appendChild(transparency);
                end
            end
            technique.appendChild(lambert);
            profile_COMMON.appendChild(technique);
            effect.appendChild(profile_COMMON);
            library_effects.appendChild(effect);
        end
        dae.appendChild(library_materials);
        dae.appendChild(library_effects);
    end

    if(isprop(gltf,'animations'))
        library_animations=documentNode.createElement("library_animations");
        for animation_id=1:numel(gltf.animations)
            animation=documentNode.createElement("animation");
            animation.setAttribute("id","animation_"+string(animation_id));
            for channel_id=1:numel(gltf.animations{animation_id}.channels)
                subanimation=documentNode.createElement("animation");
                subanimation.setAttribute("id","animation_"+string(animation_id)+"_"+string(channel_id));
                if(gltf.animations{animation_id}.channels{channel_id}.target.path=="translation")
                    sampler_id=gltf.animations{animation_id}.channels{channel_id}.sampler+1;
                    input_data=gltf.getAccessor(gltf.animations{animation_id}.samplers{sampler_id}.input);
                    output_data=gltf.getAccessor(gltf.animations{animation_id}.samplers{sampler_id}.output);
                    if(isfield(gltf.animations{animation_id}.samplers{sampler_id},'interpolation'))
                        interp_data=gltf.getAccessor(gltf.animations{1}.samplers{sampler_id}.interpolation);
                    else
                        interp_data="LINEAR";
                    end
                    source=documentNode.createElement("source");
                    source.setAttribute("id","animation_"+string(animation_id)+"_"+string(channel_id)+"_input");
                    float_array=documentNode.createElement("float_array");
                    float_array.setAttribute("id","animation_"+string(animation_id)+"_"+string(channel_id)+"_input-array");
                    float_array.setAttribute("count",string(numel(input_data)));
                    float_array.appendChild(documentNode.createTextNode(strip(sprintf(GLTF.formatSpec_float(),input_data))));
                    source.appendChild(float_array);
                    technique_common=documentNode.createElement("technique_common");
                    accessor=documentNode.createElement("accessor");
                    accessor.setAttribute("count",string(size(input_data,1)));
                    accessor.setAttribute("source","#animation_"+string(animation_id)+"_"+string(channel_id)+"_input-array");
                    accessor.setAttribute("stride",string(size(input_data,2)));
                    param=documentNode.createElement("param");
                    param.setAttribute("name","TIME");
                    param.setAttribute("type","float");
                    accessor.appendChild(param);
                    technique_common.appendChild(accessor);
                    source.appendChild(technique_common);
                    subanimation.appendChild(source);
                    source=documentNode.createElement("source");
                    source.setAttribute("id","animation_"+string(animation_id)+"_"+string(channel_id)+"_output");
                    float_array=documentNode.createElement("float_array");
                    float_array.setAttribute("id","animation_"+string(animation_id)+"_"+string(channel_id)+"_output-array");
                    float_array.setAttribute("count",string(numel(output_data)));
                    float_array.appendChild(documentNode.createTextNode(strip(sprintf(GLTF.formatSpec_float(),output_data'))));
                    source.appendChild(float_array);
                    technique_common=documentNode.createElement("technique_common");
                    accessor=documentNode.createElement("accessor");
                    accessor.setAttribute("count",string(size(output_data,1)));
                    accessor.setAttribute("source","#animation_"+string(animation_id)+"_"+string(channel_id)+"_output-array");
                    accessor.setAttribute("stride",string(size(output_data,2)));
                    param=documentNode.createElement("param");
                    param.setAttribute("name","X");
                    param.setAttribute("type","float");
                    accessor.appendChild(param);
                    param=documentNode.createElement("param");
                    param.setAttribute("name","Y");
                    param.setAttribute("type","float");
                    accessor.appendChild(param);
                    param=documentNode.createElement("param");
                    param.setAttribute("name","Z");
                    param.setAttribute("type","float");
                    accessor.appendChild(param);
                    technique_common.appendChild(accessor);
                    source.appendChild(technique_common);
                    subanimation.appendChild(source);
                    target="translate";
                    target_node_id=gltf.animations{animation_id}.channels{channel_id}.target.node+1;
                    if(isempty(node_list{target_node_id}.getElementsByTagName("translate").item(0)))
                        translate=documentNode.createElement("translate");
                        translate.setAttribute("sid","translate");
                        translate.appendChild(documentNode.createTextNode(strip(sprintf(GLTF.formatSpec_float(),[0 0 0]))));
                        node_list{target_node_id}.appendChild(translate);
                    end
                    source=documentNode.createElement("source");
                    source.setAttribute("id","animation_"+string(animation_id)+"_"+string(channel_id)+"_interpolations");
                    name_array=documentNode.createElement("Name_array");
                    name_array.setAttribute("id","animation_"+string(animation_id)+"_"+string(channel_id)+"_interpolations-array");
                    name_array.setAttribute("count",string(numel(input_data)));
                    name_array.appendChild(documentNode.createTextNode(join(repmat(interp_data,1,numel(input_data)))));
                    source.appendChild(name_array);
                    technique_common=documentNode.createElement("technique_common");
                    accessor=documentNode.createElement("accessor");
                    accessor.setAttribute("count",string(size(input_data,1)));
                    accessor.setAttribute("source","#animation_"+string(animation_id)+"_"+string(channel_id)+"_interpolations-array");
                    accessor.setAttribute("stride",string(size(input_data,2)));
                    param=documentNode.createElement("param");
                    param.setAttribute("name","INTERPOLATION");
                    param.setAttribute("type","Name");
                    accessor.appendChild(param);
                    technique_common.appendChild(accessor);
                    source.appendChild(technique_common);
                    subanimation.appendChild(source);

                    sampler=documentNode.createElement("sampler");
                    sampler.setAttribute("id","animation_"+string(animation_id)+"_"+string(channel_id)+"_sampler");
                    input=documentNode.createElement("input");
                    input.setAttribute("semantic","INPUT");
                    input.setAttribute("source","#animation_"+string(animation_id)+"_"+string(channel_id)+"_input");
                    sampler.appendChild(input);
                    input=documentNode.createElement("input");
                    input.setAttribute("semantic","OUTPUT");
                    input.setAttribute("source","#animation_"+string(animation_id)+"_"+string(channel_id)+"_output");
                    sampler.appendChild(input);
                    input=documentNode.createElement("input");
                    input.setAttribute("semantic","INTERPOLATION");
                    input.setAttribute("source","#animation_"+string(animation_id)+"_"+string(channel_id)+"_interpolations");
                    sampler.appendChild(input);
                    subanimation.appendChild(sampler);

                    channel=documentNode.createElement("channel");
                    channel.setAttribute("source","#animation_"+string(animation_id)+"_"+string(channel_id)+"_sampler");
                    channel.setAttribute("target","node_"+string(gltf.animations{animation_id}.channels{channel_id}.target.node+1)+"/"+target);
                    subanimation.appendChild(channel);
                elseif(gltf.animations{animation_id}.channels{channel_id}.target.path=="rotation")
                    sampler_id=gltf.animations{animation_id}.channels{channel_id}.sampler+1;
                    input_data=gltf.getAccessor(gltf.animations{animation_id}.samplers{sampler_id}.input);
                    output_data=gltf.getAccessor(gltf.animations{animation_id}.samplers{sampler_id}.output);
                    if(isfield(gltf.animations{animation_id}.samplers{sampler_id},'interpolation'))
                        interp_data=gltf.animations{1}.samplers{sampler_id}.interpolation;
                    else
                        interp_data="LINEAR";
                    end
                    source=documentNode.createElement("source");
                    source.setAttribute("id","animation_"+string(animation_id)+"_"+string(channel_id)+"_input");
                    float_array=documentNode.createElement("float_array");
                    float_array.setAttribute("id","animation_"+string(animation_id)+"_"+string(channel_id)+"_input-array");
                    float_array.setAttribute("count",string(numel(input_data)));
                    float_array.appendChild(documentNode.createTextNode(strip(sprintf(GLTF.formatSpec_float(),input_data))));
                    source.appendChild(float_array);
                    technique_common=documentNode.createElement("technique_common");
                    accessor=documentNode.createElement("accessor");
                    accessor.setAttribute("count",string(size(input_data,1)));
                    accessor.setAttribute("source","#animation_"+string(animation_id)+"_"+string(channel_id)+"_input-array");
                    accessor.setAttribute("stride",string(size(input_data,2)));
                    param=documentNode.createElement("param");
                    param.setAttribute("name","TIME");
                    param.setAttribute("type","float");
                    accessor.appendChild(param);
                    technique_common.appendChild(accessor);
                    source.appendChild(technique_common);
                    subanimation.appendChild(source);
                    output_data=GLTF.Q2AxisAngle(output_data);
                    source=documentNode.createElement("source");
                    source.setAttribute("id","animation_"+string(animation_id)+"_"+string(channel_id)+"_output");
                    float_array=documentNode.createElement("float_array");
                    float_array.setAttribute("id","animation_"+string(animation_id)+"_"+string(channel_id)+"_output-array");
                    float_array.setAttribute("count",string(numel(output_data)));
                    float_array.appendChild(documentNode.createTextNode(strip(sprintf(GLTF.formatSpec_float(),output_data'))));
                    source.appendChild(float_array);
                    technique_common=documentNode.createElement("technique_common");
                    accessor=documentNode.createElement("accessor");
                    accessor.setAttribute("count",string(size(output_data,1)));
                    accessor.setAttribute("source","#animation_"+string(animation_id)+"_"+string(channel_id)+"_output-array");
                    accessor.setAttribute("stride",string(size(output_data,2)));
                    param=documentNode.createElement("param");
                    param.setAttribute("name","X");
                    param.setAttribute("type","float");
                    accessor.appendChild(param);
                    param=documentNode.createElement("param");
                    param.setAttribute("name","Y");
                    param.setAttribute("type","float");
                    accessor.appendChild(param);
                    param=documentNode.createElement("param");
                    param.setAttribute("name","Z");
                    param.setAttribute("type","float");
                    accessor.appendChild(param);
                    param=documentNode.createElement("param");
                    param.setAttribute("name","ANGLE");
                    param.setAttribute("type","float");
                    accessor.appendChild(param);
                    technique_common.appendChild(accessor);
                    source.appendChild(technique_common);
                    subanimation.appendChild(source);
                    target="rotate";
                    target_node_id=gltf.animations{animation_id}.channels{channel_id}.target.node+1;
                    if(isempty(node_list{target_node_id}.getElementsByTagName("rotate").item(0)))
                        rotate=documentNode.createElement("rotate");
                        rotate.setAttribute("sid","rotate");
                        rotate.appendChild(documentNode.createTextNode(strip(sprintf(GLTF.formatSpec_float(),[0 1 0 0]))));
                        node_list{target_node_id}.appendChild(rotate);
                    end
                    source=documentNode.createElement("source");
                    source.setAttribute("id","animation_"+string(animation_id)+"_"+string(channel_id)+"_interpolations");
                    name_array=documentNode.createElement("Name_array");
                    name_array.setAttribute("id","animation_"+string(animation_id)+"_"+string(channel_id)+"_interpolations-array");
                    name_array.setAttribute("count",string(numel(input_data)));
                    name_array.appendChild(documentNode.createTextNode(join(repmat(interp_data,1,numel(input_data)))));
                    source.appendChild(name_array);
                    technique_common=documentNode.createElement("technique_common");
                    accessor=documentNode.createElement("accessor");
                    accessor.setAttribute("count",string(size(input_data,1)));
                    accessor.setAttribute("source","#animation_"+string(animation_id)+"_"+string(channel_id)+"_interpolations-array");
                    accessor.setAttribute("stride",string(size(input_data,2)));
                    param=documentNode.createElement("param");
                    param.setAttribute("name","INTERPOLATION");
                    param.setAttribute("type","Name");
                    accessor.appendChild(param);
                    technique_common.appendChild(accessor);
                    source.appendChild(technique_common);
                    subanimation.appendChild(source);

                    sampler=documentNode.createElement("sampler");
                    sampler.setAttribute("id","animation_"+string(animation_id)+"_"+string(channel_id)+"_sampler");
                    input=documentNode.createElement("input");
                    input.setAttribute("semantic","INPUT");
                    input.setAttribute("source","#animation_"+string(animation_id)+"_"+string(channel_id)+"_input");
                    sampler.appendChild(input);
                    input=documentNode.createElement("input");
                    input.setAttribute("semantic","OUTPUT");
                    input.setAttribute("source","#animation_"+string(animation_id)+"_"+string(channel_id)+"_output");
                    sampler.appendChild(input);
                    input=documentNode.createElement("input");
                    input.setAttribute("semantic","INTERPOLATION");
                    input.setAttribute("source","#animation_"+string(animation_id)+"_"+string(channel_id)+"_interpolations");
                    sampler.appendChild(input);
                    subanimation.appendChild(sampler);

                    channel=documentNode.createElement("channel");
                    channel.setAttribute("source","#animation_"+string(animation_id)+"_"+string(channel_id)+"_sampler");
                    channel.setAttribute("target","node_"+string(gltf.animations{animation_id}.channels{channel_id}.target.node+1)+"/"+target);
                    subanimation.appendChild(channel);
                elseif(gltf.animations{animation_id}.channels{channel_id}.target.path=="scale")
                    sampler_id=gltf.animations{animation_id}.channels{channel_id}.sampler+1;
                    input_data=gltf.getAccessor(gltf.animations{animation_id}.samplers{sampler_id}.input);
                    output_data=gltf.getAccessor(gltf.animations{animation_id}.samplers{sampler_id}.output);
                    if(isfield(gltf.animations{animation_id}.samplers{sampler_id},'interpolation'))
                        interp_data=gltf.getAccessor(gltf.animations{1}.samplers{sampler_id}.interpolation);
                    else
                        interp_data="LINEAR";
                    end
                    source=documentNode.createElement("source");
                    source.setAttribute("id","animation_"+string(animation_id)+"_"+string(channel_id)+"_input");
                    float_array=documentNode.createElement("float_array");
                    float_array.setAttribute("id","animation_"+string(animation_id)+"_"+string(channel_id)+"_input-array");
                    float_array.setAttribute("count",string(numel(input_data)));
                    float_array.appendChild(documentNode.createTextNode(strip(sprintf(GLTF.formatSpec_float(),input_data))));
                    source.appendChild(float_array);
                    technique_common=documentNode.createElement("technique_common");
                    accessor=documentNode.createElement("accessor");
                    accessor.setAttribute("count",string(size(input_data,1)));
                    accessor.setAttribute("source","#animation_"+string(animation_id)+"_"+string(channel_id)+"_input-array");
                    accessor.setAttribute("stride",string(size(input_data,2)));
                    param=documentNode.createElement("param");
                    param.setAttribute("name","TIME");
                    param.setAttribute("type","float");
                    accessor.appendChild(param);
                    technique_common.appendChild(accessor);
                    source.appendChild(technique_common);
                    subanimation.appendChild(source);
                    source=documentNode.createElement("source");
                    source.setAttribute("id","animation_"+string(animation_id)+"_"+string(channel_id)+"_output");
                    float_array=documentNode.createElement("float_array");
                    float_array.setAttribute("id","animation_"+string(animation_id)+"_"+string(channel_id)+"_output-array");
                    float_array.setAttribute("count",string(numel(output_data)));
                    float_array.appendChild(documentNode.createTextNode(strip(sprintf(GLTF.formatSpec_float(),output_data'))));
                    source.appendChild(float_array);
                    technique_common=documentNode.createElement("technique_common");
                    accessor=documentNode.createElement("accessor");
                    accessor.setAttribute("count",string(size(output_data,1)));
                    accessor.setAttribute("source","#animation_"+string(animation_id)+"_"+string(channel_id)+"_output-array");
                    accessor.setAttribute("stride",string(size(output_data,2)));
                    param=documentNode.createElement("param");
                    param.setAttribute("name","X");
                    param.setAttribute("type","float");
                    accessor.appendChild(param);
                    param=documentNode.createElement("param");
                    param.setAttribute("name","Y");
                    param.setAttribute("type","float");
                    accessor.appendChild(param);
                    param=documentNode.createElement("param");
                    param.setAttribute("name","Z");
                    param.setAttribute("type","float");
                    accessor.appendChild(param);
                    technique_common.appendChild(accessor);
                    source.appendChild(technique_common);
                    subanimation.appendChild(source);
                    target="scale";
                    target_node_id=gltf.animations{animation_id}.channels{channel_id}.target.node+1;
                    if(isempty(node_list{target_node_id}.getElementsByTagName("scale").item(0)))
                        scale=documentNode.createElement("scale");
                        scale.setAttribute("sid","scale");
                        scale.appendChild(documentNode.createTextNode(strip(sprintf(GLTF.formatSpec_float(),[1 1 1]))));
                        node_list{target_node_id}.appendChild(scale);
                    end
                    source=documentNode.createElement("source");
                    source.setAttribute("id","animation_"+string(animation_id)+"_"+string(channel_id)+"_interpolations");
                    name_array=documentNode.createElement("Name_array");
                    name_array.setAttribute("id","animation_"+string(animation_id)+"_"+string(channel_id)+"_interpolations-array");
                    name_array.setAttribute("count",string(numel(input_data)));
                    name_array.appendChild(documentNode.createTextNode(join(repmat(interp_data,1,numel(input_data)))));
                    source.appendChild(name_array);
                    technique_common=documentNode.createElement("technique_common");
                    accessor=documentNode.createElement("accessor");
                    accessor.setAttribute("count",string(size(input_data,1)));
                    accessor.setAttribute("source","#animation_"+string(animation_id)+"_"+string(channel_id)+"_interpolations-array");
                    accessor.setAttribute("stride",string(size(input_data,2)));
                    param=documentNode.createElement("param");
                    param.setAttribute("name","INTERPOLATION");
                    param.setAttribute("type","Name");
                    accessor.appendChild(param);
                    technique_common.appendChild(accessor);
                    source.appendChild(technique_common);
                    subanimation.appendChild(source);

                    sampler=documentNode.createElement("sampler");
                    sampler.setAttribute("id","animation_"+string(animation_id)+"_"+string(channel_id)+"_sampler");
                    input=documentNode.createElement("input");
                    input.setAttribute("semantic","INPUT");
                    input.setAttribute("source","#animation_"+string(animation_id)+"_"+string(channel_id)+"_input");
                    sampler.appendChild(input);
                    input=documentNode.createElement("input");
                    input.setAttribute("semantic","OUTPUT");
                    input.setAttribute("source","#animation_"+string(animation_id)+"_"+string(channel_id)+"_output");
                    sampler.appendChild(input);
                    input=documentNode.createElement("input");
                    input.setAttribute("semantic","INTERPOLATION");
                    input.setAttribute("source","#animation_"+string(animation_id)+"_"+string(channel_id)+"_interpolations");
                    sampler.appendChild(input);
                    subanimation.appendChild(sampler);

                    channel=documentNode.createElement("channel");
                    channel.setAttribute("source","#animation_"+string(animation_id)+"_"+string(channel_id)+"_sampler");
                    channel.setAttribute("target","node_"+string(gltf.animations{animation_id}.channels{channel_id}.target.node+1)+"/"+target);
                    subanimation.appendChild(channel);
                elseif(gltf.animations{animation_id}.channels{channel_id}.target.path=="weights")
                    mesh_idx=gltf.nodes{gltf.animations{animation_id}.channels{channel_id}.target.node+1}.mesh+1;
                    sampler_id=gltf.animations{animation_id}.channels{channel_id}.sampler+1;
                    input_data=gltf.getAccessor(gltf.animations{animation_id}.samplers{sampler_id}.input);
                    output_data=gltf.getAccessor(gltf.animations{animation_id}.samplers{sampler_id}.output);
                    output_data=reshape(output_data,[],size(input_data,1))';
                    if(isfield(gltf.animations{animation_id}.samplers{sampler_id},'interpolation'))
                        interp_data=gltf.getAccessor(gltf.animations{1}.samplers{sampler_id}.interpolation);
                    else
                        interp_data="LINEAR";
                    end

                    for primitive_id=1:numel(gltf.meshes{gltf.nodes{gltf.animations{animation_id}.channels{channel_id}.target.node+1}.mesh+1}.primitives)
                        subsubanimation=documentNode.createElement("animation");
                        subsubanimation.setAttribute("id","animation_"+string(animation_id)+"_"+string(channel_id)+"_"+string(primitive_id));
                        for target_id=1:numel(gltf.meshes{gltf.nodes{gltf.animations{animation_id}.channels{channel_id}.target.node+1}.mesh+1}.primitives{1}.targets)
                            subsubsubanimation=documentNode.createElement("animation");
                            subsubsubanimation.setAttribute("id","animation_"+string(animation_id)+"_"+string(channel_id)+"_"+string(primitive_id)+"_"+string(target_id));

                            source=documentNode.createElement("source");
                            source.setAttribute("id","animation_"+string(animation_id)+"_"+string(channel_id)+"_"+string(primitive_id)+"_"+string(target_id)+"_input");
                            float_array=documentNode.createElement("float_array");
                            float_array.setAttribute("id","animation_"+string(animation_id)+"_"+string(channel_id)+"_"+string(primitive_id)+"_"+string(target_id)+"_input-array");
                            float_array.setAttribute("count",string(numel(input_data)));
                            float_array.appendChild(documentNode.createTextNode(strip(sprintf(GLTF.formatSpec_float(),input_data))));
                            source.appendChild(float_array);
                            technique_common=documentNode.createElement("technique_common");
                            accessor=documentNode.createElement("accessor");
                            accessor.setAttribute("count",string(size(input_data,1)));
                            accessor.setAttribute("source","#animation_"+string(animation_id)+"_"+string(channel_id)+"_"+string(primitive_id)+"_"+string(target_id)+"_input-array");
                            accessor.setAttribute("stride",string(size(input_data,2)));
                            param=documentNode.createElement("param");
                            param.setAttribute("name","TIME");
                            param.setAttribute("type","float");
                            accessor.appendChild(param);
                            technique_common.appendChild(accessor);
                            source.appendChild(technique_common);
                            subsubsubanimation.appendChild(source);
                            source=documentNode.createElement("source");
                            source.setAttribute("id","animation_"+string(animation_id)+"_"+string(channel_id)+"_"+string(primitive_id)+"_"+string(target_id)+"_output");
                            float_array=documentNode.createElement("float_array");
                            float_array.setAttribute("id","animation_"+string(animation_id)+"_"+string(channel_id)+"_"+string(primitive_id)+"_"+string(target_id)+"_output-array");
                            float_array.setAttribute("count",string(size(output_data,1)));
                            float_array.appendChild(documentNode.createTextNode(strip(sprintf(GLTF.formatSpec_float(),output_data(:,target_id)'))));
                            source.appendChild(float_array);
                            technique_common=documentNode.createElement("technique_common");
                            accessor=documentNode.createElement("accessor");
                            accessor.setAttribute("count",string(size(output_data,1)));
                            accessor.setAttribute("source","#animation_"+string(animation_id)+"_"+string(channel_id)+"_"+string(primitive_id)+"_"+string(target_id)+"_output-array");
                            accessor.setAttribute("stride","1");
                            param=documentNode.createElement("param");
                            param.setAttribute("type","float");
                            accessor.appendChild(param);
                            technique_common.appendChild(accessor);
                            source.appendChild(technique_common);
                            subsubsubanimation.appendChild(source);

                            source=documentNode.createElement("source");
                            source.setAttribute("id","animation_"+string(animation_id)+"_"+string(channel_id)+"_"+string(primitive_id)+"_"+string(target_id)+"_interpolations");
                            name_array=documentNode.createElement("Name_array");
                            name_array.setAttribute("id","animation_"+string(animation_id)+"_"+string(channel_id)+"_"+string(primitive_id)+"_"+string(target_id)+"_interpolations-array");
                            name_array.setAttribute("count",string(numel(input_data)));
                            name_array.appendChild(documentNode.createTextNode(join(repmat(interp_data,1,numel(input_data)))));
                            source.appendChild(name_array);
                            technique_common=documentNode.createElement("technique_common");
                            accessor=documentNode.createElement("accessor");
                            accessor.setAttribute("count",string(size(input_data,1)));
                            accessor.setAttribute("source","#animation_"+string(animation_id)+"_"+string(channel_id)+"_"+string(primitive_id)+"_"+string(target_id)+"_interpolations-array");
                            accessor.setAttribute("stride",string(size(input_data,2)));
                            param=documentNode.createElement("param");
                            param.setAttribute("name","INTERPOLATION");
                            param.setAttribute("type","Name");
                            accessor.appendChild(param);
                            technique_common.appendChild(accessor);
                            source.appendChild(technique_common);
                            subsubsubanimation.appendChild(source);

                            sampler=documentNode.createElement("sampler");
                            sampler.setAttribute("id","animation_"+string(animation_id)+"_"+string(channel_id)+"_"+string(primitive_id)+"_"+string(target_id)+"_sampler");
                            input=documentNode.createElement("input");
                            input.setAttribute("semantic","INPUT");
                            input.setAttribute("source","#animation_"+string(animation_id)+"_"+string(channel_id)+"_"+string(primitive_id)+"_"+string(target_id)+"_input");
                            sampler.appendChild(input);
                            input=documentNode.createElement("input");
                            input.setAttribute("semantic","OUTPUT");
                            input.setAttribute("source","#animation_"+string(animation_id)+"_"+string(channel_id)+"_"+string(primitive_id)+"_"+string(target_id)+"_output");
                            sampler.appendChild(input);
                            input=documentNode.createElement("input");
                            input.setAttribute("semantic","INTERPOLATION");
                            input.setAttribute("source","#animation_"+string(animation_id)+"_"+string(channel_id)+"_"+string(primitive_id)+"_"+string(target_id)+"_interpolations");
                            sampler.appendChild(input);
                            subsubsubanimation.appendChild(sampler);

                            channel=documentNode.createElement("channel");
                            channel.setAttribute("source","#animation_"+string(animation_id)+"_"+string(channel_id)+"_"+string(primitive_id)+"_"+string(target_id)+"_sampler");
                            channel.setAttribute("target","morph_weights_"+string(mesh_idx)+"_"+string(primitive_id)+"("+string(target_id-1)+")");
                            subsubsubanimation.appendChild(channel);

                            subsubanimation.appendChild(subsubsubanimation);
                        end
                        subanimation.appendChild(subsubanimation);
                    end

                end

                animation.appendChild(subanimation);
            end
            library_animations.appendChild(animation);
        end
        dae.appendChild(library_animations);
    end
    xmlwrite(filename,documentNode);
end
