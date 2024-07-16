function writeGLB(gltf,filename,varargin)
    % Write a GLB file.
    %
    % WRITEGLB(GLB,FILENAME) writes GLTF to a GLB-file specified by
    % FILENAME.
    %
    % WRITEGLB(...,'bufferFile',FILENAME) writes the binary data into a
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
    warning('off','MATLAB:structOnObject');
    st=struct(gltf);
    warning('on','MATLAB:structOnObject');
    ips=inputParser;
    ips.addParameter('bufferFile',missing,@isstring);
    ips.parse(varargin{:});
    parameters=ips.Results;
    bufferFile=parameters.bufferFile;
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
        bufferChunk=cell(numel(gltf.buffers),1);
        bufferLength=zeros(numel(gltf.buffers),1);
        for i=1:numel(gltf.buffers)
            bufferChunk{i}=gltf.buffers{i};
            bufferLength(i)=uint32(numel(gltf.buffers{i}));
            st.buffers{i}=struct('byteLength',uint32(numel(gltf.buffers{i})));
        end
        for i=1:numel(gltf.bufferViews)
            gltf.bufferViews{i}.buffer=0;
            gltf.bufferViews{i}.byteOffset=gltf.bufferViews{i}.byteOffset+sum(bufferLength(1:gltf.bufferViews{i}.buffer));
        end
        jsonBuffer=jsonencode(st);
        jsonAlignedLength=ceil(numel(jsonBuffer)/4)*4;
        jsonPadding=jsonAlignedLength-numel(jsonBuffer);
        jsonBuffer=[jsonBuffer repmat(' ',1,jsonPadding)]';

        binBuffer=cell2mat(bufferChunk);
        binAlignedLength=ceil(numel(binBuffer)/4)*4;
        binPadding=binAlignedLength-numel(binBuffer);
        binBuffer=[binBuffer;repmat(uint8(0),binPadding,1)];

        totalSize=28+jsonAlignedLength+binAlignedLength;
        finalBuffer=[typecast([uint32(hex2dec('46546C67'));uint32(2);uint32(totalSize);uint32(jsonAlignedLength);uint32(hex2dec('4E4F534A'))],'uint8');uint8(jsonBuffer);typecast([uint32(binAlignedLength);uint32(hex2dec('004E4942'))],'uint8');uint8(binBuffer)];
        fid=fopen(filename,'w');
        fwrite(fid,finalBuffer);
        fclose(fid);
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
        jsonBuffer=jsonencode(st);
        jsonAlignedLength=ceil(numel(jsonBuffer)/4)*4;
        jsonPadding=jsonAlignedLength-numel(jsonBuffer);
        jsonBuffer=[jsonBuffer repmat(' ',1,jsonPadding)]';
        totalSize=20+jsonAlignedLength;
        finalBuffer=[typecast([uint32(hex2dec('46546C67'));uint32(2);uint32(totalSize);uint32(jsonAlignedLength);uint32(hex2dec('4E4F534A'))],'uint8');uint8(jsonBuffer)];
        fid=fopen(filename,'w');
        fwrite(fid,finalBuffer);
        fclose(fid);
    end
end
