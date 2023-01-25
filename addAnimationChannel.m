function channelstruct=addAnimationChannel(~,sampler,target_node,target_path)
    % Add an animation channel.
    %
    % ADDANIMATIONCHANNEL(GLTF,SAMPLER,TARGET_NODE,TARGET_PATH) creates and
    % returns an animation channel for GLTF, with SAMPLER as the sampler
    % index, TARGET_NODE as the index of the node to be animated, and
    % TARGET_PATHas the property to be animated. In general, the sampler
    % index needs to be calculated before constructing the channel, and
    % needs to be calculated as the zero-based array index of the sampler
    % when passed to ADDANIMATION. TARGET_PATH needs to be one of
    % "translation", "rotation", "scale", or "weights".
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
    target_path=lower(target_path);
    GLTF.validateString(target_path,["translation","rotation","scale","weights"]);
    channelstruct=struct('sampler',sampler,'target',struct('node',target_node,'path',target_path));
end
