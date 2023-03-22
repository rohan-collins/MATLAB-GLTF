function emitter_id=addGlobalEmitter(gltf,varargin)
    % Add a positional emitter for one or more audio clips and return the
    % emitter ID.
    %
    % ADDGLOBALEMITTER(...,'addToScene',false) adds the emitter, but does
    % not automatically add it to the scene.
    %
    % ADDGLOBALEMITTER(...,'sources',SOURCES) sets sources as the array of
    % audio source indices used by the audio emitter.
    %
    % ADDGLOBALEMITTER(...,'gain',GAIN) sets gain as the unitless
    % multiplier against original source volume for determining emitter
    % loudness. Gain must be positive. Default value is 1.
    %
    % ADDGLOBALEMITTER(...,'name',NAME) sets the name of the emitter.
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
    ips=inputParser;
    ips.addParameter('addToScene',true,@islogical);
    ips.addParameter('sources',[],@isnumeric);
    ips.addParameter('gain',nan,@(x)and(isnumeric(x),x>=0));
    ips.addParameter('name',missing,@isstring);
    ips.parse(varargin{:});
    parameters=ips.Results;
    addToScene=parameters.addToScene;
    gain=parameters.gain;
    sources=parameters.sources;
    name=parameters.name;
    emitterStruct=struct('type',"global");
    if(~isempty(sources))
        emitterStruct.sources=GLTF.toCells(sources);
    end
    if(~isnan(gain))
        emitterStruct.gain=gain;
    end
    if(~ismissing(name))
        emitterStruct.name=name;
    end
    addExtension(gltf,"KHR_audio");
    if(~isprop(gltf,'extensions'))
        gltf.addprop('extensions');
    end
    if(isfield(gltf.extensions,'KHR_audio') && isfield(gltf.extensions.KHR_audio,'emitters') && ~isempty(gltf.extensions.KHR_audio.emitters))
        emitter_id=numel([gltf.extensions.KHR_audio.emitters{:}]);
        gltf.extensions.KHR_audio.emitters=[gltf.extensions.KHR_audio.emitters(:);emitterStruct];
    else
        emitter_id=0;
        gltf.extensions.KHR_audio.emitters={emitterStruct};
    end
    if(addToScene)
        if(isfield(gltf.scenes{1},'extensions') && isfield(gltf.scenes{1}.extensions,'KHR_audio') && isfield(gltf.scenes{1}.extensions.KHR_audio,'emitters'))
            gltf.scenes{1}.extensions.KHR_audio.emitters=[gltf.scenes{1}.extensions.KHR_audio.emitters{:} emitter_id];
        else
            gltf.scenes{1}.extensions.KHR_audio.emitters=GLTF.toCells(emitter_id);
        end
    end
end