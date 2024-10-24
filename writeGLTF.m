function writeGLTF(gltf,filename,varargin)
    % Write a GLTF file.
    %
    % WRITEGLTF(GLTF,FILENAME) writes GLTF to a GLTF-file specified by
    % FILENAME.
    %
    % WRITEGLTF(...,'bufferFile',FILENAME) writes the binary data into a
    % separate file specified by FILENAME. If there are two or more
    % buffers, the filnames are appended with serial numbers starting with
    % 0.
    %
    % © Copyright 2014-2024 Rohan Chabukswar.
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
    ips.addParameter('bufferFile',missing,@isstring);
    ips.parse(varargin{:});
    parameters=ips.Results;
    bufferFile=parameters.bufferFile;

    warning('off','MATLAB:structOnObject');
    st=struct(gltf);
    warning('on','MATLAB:structOnObject');
    if(isfield(st,"images"))
        for i=1:numel(st.images)
            if(~startsWith(st.images{i}.uri,"data:"))
                [~,relative2]=GLTF.getRelativePath(filename,st.images{i}.uri);
                st.images{i}.uri=relative2;
            end
        end
    end
    if(isfield(st,'extensions') && isfield(st.extensions,'MSFT_audio_emitter') && isfield(st.extensions.MSFT_audio_emitter,'clips'))
        for i=1:numel(st.extensions.MSFT_audio_emitter.clips)
            if(~startsWith(st.extensions.MSFT_audio_emitter.clips,"data:"))
                [~,relative2]=GLTF.getRelativePath(filename,st.extensions.MSFT_audio_emitter.clips{i}.uri);
                st.extensions.MSFT_audio_emitter.clips{i}.uri=relative2;
            end
        end
    end
    if(ismissing(bufferFile))
        for i=1:numel(gltf.buffers)
            if(~isstruct(st.buffers{i}))
                st.buffers{i}=struct('uri',['data:application/octet-stream;base64,' matlab.net.base64encode(gltf.buffers{i})],'byteLength',uint32(numel(gltf.buffers{i})));
            end
        end
    else
        if(numel(gltf.buffers)>1)
            [filepath,name,ext]=fileparts(bufferFile);
            bufferFile=filepath+filesep+name+string(0:numel(gltf.buffers)-1)'+ext;
            for i=1:numel(gltf.buffers)
                fid=fopen(bufferFile(i),'w');
                fwrite(fid,gltf.buffers{i});
                fclose(fid);
                [~,relative2]=GLTF.getRelativePath(filename,bufferFile(i));
                st.buffers{i}=struct('uri',relative2,'byteLength',uint32(numel(gltf.buffers{i})));
            end
        else
            fid=fopen(bufferFile,'w');
            fwrite(fid,gltf.buffers{1});
            fclose(fid);
            [~,relative2]=GLTF.getRelativePath(filename,bufferFile);
            st.buffers{1}=struct('uri',relative2,'byteLength',uint32(numel(gltf.buffers{1})));
        end
    end

    if(iscell(gltf.asset))
        gltf.asset=gltf.asset{1};
    end
    fid=fopen(filename,'w');
    fprintf(fid,jsonencode(st));
    fclose(fid);
end
