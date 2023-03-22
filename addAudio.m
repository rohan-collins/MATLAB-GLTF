function audio_id=addAudio(gltf,audio,varargin)
    % Add an image.
    %
    % ADDAUDIO(GLTF,FILENAME) adds the audio file specified by FILENAME to
    % GLTF as a source for audio data and returns its index.
    %
    % ADDAUDIO(...,'embedAudio',FALSE) uses the the relative filepath of
    % the audio file instead of embedding the data. If this option is used,
    % the GLTF object does not have to be recreated whenever audio files
    % are changed.
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
    ips.addParameter('embedAudio',true,@islogical);
    ips.parse(varargin{:});
    parameters=ips.Results;
    embedAudio=parameters.embedAudio;
    if(embedAudio)
        fid2=fopen(string(audio),'r');
        data=uint8(fread(fid2));
        fclose(fid2);
        bufferView=addBufferView(gltf,data,"BINARY");
        audioStruct={struct('bufferView',uint32(bufferView),'mimeType',"audio/mpeg")};
    else
        audioStruct={struct('uri',audio)};
    end
    addExtension(gltf,"KHR_audio");
    if(~isprop(gltf,'extensions'))
        gltf.addprop('extensions');
    end
    if(isfield(gltf.extensions,'KHR_audio') && isfield(gltf.extensions.KHR_audio,'audio') && ~isempty(gltf.extensions.KHR_audio.audio))
        audio_id=numel([gltf.extensions.KHR_audio.audio{:}]);
        gltf.extensions.KHR_audio.audio=[gltf.extensions.KHR_audio.audio(:) audioStruct(:)];
    else
        audio_id=0;
        gltf.extensions.KHR_audio.audio=audioStruct;
    end
end
