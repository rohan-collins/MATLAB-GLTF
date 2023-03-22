function base64string=string2URI(filename)
    % Convert image file to base-64 representation.
    %
    % STRINGTOURI(FILENAME) converts the PNG or JPG image specified by
    % FILENAME to a base-64 representation for embedding.
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
    [~,~,ext]=fileparts(string(filename));
    if(ext==".png")
        fid=fopen(filename,'rb');
        bytes=fread(fid);
        fclose(fid);
        encoder=org.apache.commons.codec.binary.Base64;
        base64string=['data:image/png;base64,' char(encoder.encode(bytes)')];
    elseif(or(ext==".jpg",ext==".jpeg"))
        fid=fopen(filename,'rb');
        bytes=fread(fid);
        fclose(fid);
        encoder=org.apache.commons.codec.binary.Base64;
        base64string=['data:image/jpeg;base64,' char(encoder.encode(bytes)')];
    elseif(ext==".wav")
        fid=fopen(filename,'rb');
        bytes=fread(fid);
        fclose(fid);
        encoder=org.apache.commons.codec.binary.Base64;
        base64string=['data:audio/wav;base64,' char(encoder.encode(bytes)')];
    elseif(ext==".webp")
        fid=fopen(filename,'rb');
        bytes=fread(fid);
        fclose(fid);
        encoder=org.apache.commons.codec.binary.Base64;
        base64string=['data:image/webp;base64,' char(encoder.encode(bytes)')];
    elseif(ext==".mp3")
        fid=fopen(filename,'rb');
        bytes=fread(fid);
        fclose(fid);
        encoder=org.apache.commons.codec.binary.Base64;
        base64string=['data:audio/mpeg;base64,' char(encoder.encode(bytes)')];
    else
        base64string=filename;
    end
end
