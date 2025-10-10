function channelstruct=addAnimationPointerChannel(gltf,sampler,target_path)
    % Add an animation channel.
    %
    % ADDANIMATIONPOINTERCHANNEL(GLTF,SAMPLER,TARGET_PATH) creates and
    % returns an animation channel for GLTF, with SAMPLER as the sampler
    % index and TARGET_PATH as the property to be animated. In general, the
    % sampler index needs to be calculated before constructing the channel,
    % and needs to be calculated as the zero-based array index of the
    % sampler when passed to ADDANIMATIONPOINTERCHANNEL. TARGET_PATH needs
    % to be one of the following strings (where the idx is the index of the
    % mesh, node, camera, material, or light in question):
    %   "/meshes/idx/weights"
    %   "/nodes/idx/rotation"
    %   "/nodes/idx/scale"
    %   "/nodes/idx/translation"
    %   "/nodes/idx/weights"
    %   "/cameras/idx/orthographic/xmag"
    %   "/cameras/idx/orthographic/ymag"
    %   "/cameras/idx/orthographic/zfar"
    %   "/cameras/idx/orthographic/znear"
    %   "/cameras/idx/perspective/aspectRatio"
    %   "/cameras/idx/perspective/yfov"
    %   "/cameras/idx/perspective/zfar"
    %   "/cameras/idx/perspective/znear"
    %   "/materials/idx/pbrMetallicRoughness/baseColorFactor"
    %   "/materials/idx/pbrMetallicRoughness/metallicFactor"
    %   "/materials/idx/pbrMetallicRoughness/roughnessFactor"
    %   "/materials/idx/alphaCutoff"
    %   "/materials/idx/emissiveFactor"
    %   "/materials/idx/normalTexture/scale"
    %   "/materials/idx/occlusionTexture/strength"
    %   "/extensions/KHR_lights_punctual/lights/idx/color"
    %   "/extensions/KHR_lights_punctual/lights/idx/intensity"
    %   "/extensions/KHR_lights_punctual/lights/idx/range"
    %   "/extensions/KHR_lights_punctual/lights/idx/spot.innerConeAngle"
    %   "/extensions/KHR_lights_punctual/lights/idx/spot.outerConeAngle"
    %   "/materials/idx/extensions/KHR_materials_clearcoat/clearcoatFactor"
    %   "/materials/idx/extensions/KHR_materials_clearcoat/clearcoatRoughnessFactor"
    %   "/materials/idx/extensions/KHR_materials_emissive_strength/emissiveStrength"
    %   "/materials/idx/extensions/KHR_materials_ior/ior"
    %   "/materials/idx/extensions/KHR_materials_iridescence/iridescenceFactor"
    %   "/materials/idx/extensions/KHR_materials_iridescence/iridescenceIor"
    %   "/materials/idx/extensions/KHR_materials_iridescence/iridescenceThicknessMinimum"
    %   "/materials/idx/extensions/KHR_materials_iridescence/iridescenceThicknessMaximum"
    %   "/materials/idx/extensions/KHR_materials_sheen/sheenColorFactor"
    %   "/materials/idx/extensions/KHR_materials_sheen/sheenRoughnessFactor"
    %   "/materials/idx/extensions/KHR_materials_specular/specularFactor"
    %   "/materials/idx/extensions/KHR_materials_specular/specularColorFactor"
    %   "/materials/idx/extensions/KHR_materials_transmission/transmissionFactor"
    %   "/materials/idx/extensions/KHR_materials_volume/thicknessFactor"
    %   "/materials/idx/extensions/KHR_materials_volume/attenuationDistance"
    %   "/materials/idx/extensions/KHR_materials_volume/attenuationColor"
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
    possibilities=["/meshes/idx/weights";"/meshes/idx/COLOR";
        "/nodes/idx/rotation";
        "/nodes/idx/scale";
        "/nodes/idx/translation";
        "/nodes/idx/weights";
        "/cameras/idx/orthographic/xmag";
        "/cameras/idx/orthographic/ymag";
        "/cameras/idx/orthographic/zfar";
        "/cameras/idx/orthographic/znear";
        "/cameras/idx/perspective/aspectRatio";
        "/cameras/idx/perspective/yfov";
        "/cameras/idx/perspective/zfar";
        "/cameras/idx/perspective/znear";
        "/materials/idx/pbrMetallicRoughness/baseColorFactor";
        "/materials/idx/pbrMetallicRoughness/metallicFactor";
        "/materials/idx/pbrMetallicRoughness/roughnessFactor";
        "/materials/idx/alphaCutoff";
        "/materials/idx/emissiveFactor";
        "/materials/idx/normalTexture/scale";
        "/materials/idx/occlusionTexture/strength";
        "/extensions/KHR_lights_punctual/lights/idx/color";
        "/extensions/KHR_lights_punctual/lights/idx/intensity";
        "/extensions/KHR_lights_punctual/lights/idx/range";
        "/extensions/KHR_lights_punctual/lights/idx/spot.innerConeAngle";
        "/extensions/KHR_lights_punctual/lights/idx/spot.outerConeAngle";
        "/materials/idx/extensions/KHR_materials_clearcoat/clearcoatFactor";
        "/materials/idx/extensions/KHR_materials_clearcoat/clearcoatRoughnessFactor";
        "/materials/idx/extensions/KHR_materials_emissive_strength/emissiveStrength";
        "/materials/idx/extensions/KHR_materials_ior/ior";
        "/materials/idx/extensions/KHR_materials_iridescence/iridescenceFactor";
        "/materials/idx/extensions/KHR_materials_iridescence/iridescenceIor";
        "/materials/idx/extensions/KHR_materials_iridescence/iridescenceThicknessMinimum";
        "/materials/idx/extensions/KHR_materials_iridescence/iridescenceThicknessMaximum";
        "/materials/idx/extensions/KHR_materials_sheen/sheenColorFactor";
        "/materials/idx/extensions/KHR_materials_sheen/sheenRoughnessFactor";
        "/materials/idx/extensions/KHR_materials_specular/specularFactor";
        "/materials/idx/extensions/KHR_materials_specular/specularColorFactor";
        "/materials/idx/extensions/KHR_materials_transmission/transmissionFactor";
        "/materials/idx/extensions/KHR_materials_volume/thicknessFactor";
        "/materials/idx/extensions/KHR_materials_volume/attenuationDistance";
        "/materials/idx/extensions/KHR_materials_volume/attenuationColor";
        ];
    GLTF.validateStringWithIndex(target_path,possibilities,"idx");
    addExtension(gltf,"KHR_animation_pointer");
    channelstruct=struct('sampler',sampler,'target',struct('path',"pointer",'extensions',struct('KHR_animation_pointer',struct('pointer',target_path))));
end
