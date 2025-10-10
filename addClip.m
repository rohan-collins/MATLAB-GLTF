function clip_id=addClip(gltf,filename,varargin)
    % Add an audio clip and return the clip ID.
    %
    % ADDCLIP(GLTF,FILENAME) adds the audio file specified by FILENAME to
    % GLTF. The file must be of Waveform Audio Format with a .wav
    % extension.
    %
    % ADDCLIP(...,'embed',FALSE) uses the the relative filepath of the
    % audio file instead of embedding the audio. If this option is used,
    % the GLTF object does not have to be recreated whenever the audio
    % clips are changed.
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
    ips=inputParser;
    ips.addParameter('embed',true,@islogical);
    ips.parse(varargin{:});
    parameters=ips.Results;
    embed=parameters.embed;
    if(embed)
        clips_struct={struct('uri',GLTF.string2URI(filename))};
    else
        clips_struct={struct('uri',filename)};
    end
    addExtension(gltf,"MSFT_audio_emitter");
    if(~isprop(gltf,'extensions'))
        gltf.addprop('extensions');
    end
    if(isfield(gltf.extensions,'MSFT_audio_emitter') && isfield(gltf.extensions.MSFT_audio_emitter,'clips') && ~isempty(gltf.extensions.MSFT_audio_emitter.clips))
        clip_id=numel([gltf.extensions.MSFT_audio_emitter.clips{:}]);
        gltf.extensions.MSFT_audio_emitter.clips=[gltf.extensions.MSFT_audio_emitter.clips{:} clips_struct{:}];
    else
        clip_id=0;
        gltf.extensions.MSFT_audio_emitter.clips=clips_struct;
    end
end
