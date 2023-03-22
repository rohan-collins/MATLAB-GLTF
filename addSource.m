function source_id=addSource(gltf,audio_id,varargin)
    % Add a positional emitter for the given audio id and return the emitter
    % ID.
    %
    % ADDSOURCE(...,'gain',GAIN) sets gain as the unitless multiplier
    % against original audio file volume for determining audio source
    % loudness. Gain must be positive. Default value is 1.
    %
    % ADDSOURCE(...,'autoPlay',true) sets to play the specified audio when
    % the glTF is loaded.
    %
    % ADDSOURCE(...,'loop',true) sets to loop the specified audio when
    % finished.
    %
    % ADDSOURCE(...,'name',NAME) sets the name of the emitter.
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
    ips.addParameter('gain',nan,@(x)and(isnumeric(x),x>=0));
    ips.addParameter('autoplay',false,@islogical);
    ips.addParameter('loop',false,@islogical);
    ips.addParameter('name',missing,@isstring);
    ips.parse(varargin{:});
    parameters=ips.Results;
    gain=parameters.gain;
    autoplay=parameters.autoplay;
    loop=parameters.loop;
    name=parameters.name;
    sourceStruct=struct('audio',audio_id);
    if(~isnan(gain))
        sourceStruct.gain=gain;
    end
    if(~ismissing(name))
        sourceStruct.name=name;
    end
    if(autoplay)
        sourceStruct.autoplay=autoplay;
    end
    if(loop)
        sourceStruct.autoplay=loop;
    end
    addExtension(gltf,"KHR_audio");
    if(~isprop(gltf,'extensions'))
        gltf.addprop('extensions');
    end
    if(isfield(gltf.extensions,'KHR_audio') && isfield(gltf.extensions.KHR_audio,'sources') && ~isempty(gltf.extensions.KHR_audio.sources))
        source_id=numel([gltf.extensions.KHR_audio.sources{:}]);
        gltf.extensions.KHR_audio.sources=[gltf.extensions.KHR_audio.sources{:} sourceStruct{:}];
    else
        source_id=0;
        gltf.extensions.KHR_audio.sources=sourceStruct;
    end
end