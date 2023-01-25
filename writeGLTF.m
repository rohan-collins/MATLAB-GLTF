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
    ips.addParameter('bufferFile',missing,@isstring);
    ips.parse(varargin{:});
    parameters=ips.Results;
    bufferFile=parameters.bufferFile;

    encoder=org.apache.commons.codec.binary.Base64;
    warning('off','MATLAB:structOnObject');
    st=struct(gltf);
    warning('on','MATLAB:structOnObject');
    if(ismissing(bufferFile))
        for i=1:numel(gltf.buffers)
            st.buffers{i}=struct('uri',['data:application/octet-stream;base64,' char(encoder.encode(gltf.buffers{i})')],'byteLength',uint32(numel(gltf.buffers{i})));
        end
    else
        if(numel(gltf.buffers)>1)
            [filepath,name,ext]=fileparts(bufferFile);
            bufferFile=filepath+name+string(0:numel(gltf.buffers)-1)'+ext;
            for i=1:numel(gltf.buffers)
                fid=fopen(bufferFile(i),'w');
                fwrite(fid,gltf.buffers{i});
                fclose(fid);
                st.buffers{i}=struct('uri',bufferFile(i),'byteLength',uint32(numel(gltf.buffers{i})));
            end
        else
            fid=fopen(bufferFile,'w');
            fwrite(fid,gltf.buffers{1});
            fclose(fid);
            st.buffers{1}=struct('uri',bufferFile,'byteLength',uint32(numel(gltf.buffers{1})));
        end
    end

    if(iscell(gltf.asset))
        gltf.asset=gltf.asset{1};
    end
    fid=fopen(filename,'w');
    fprintf(fid,jsonencode(st));
    fclose(fid);
end
