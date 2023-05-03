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
    isurl=~isfile(filename);
    if(ext==".png")
        if(isurl)
            bytes=webread(filename,weboptions("ContentType","binary"));
        else
            fid=fopen(filename,'rb');
            bytes=fread(fid);
            fclose(fid);
        end
        base64string=['data:image/png;base64,' matlab.net.base64encode(bytes)];
    elseif(or(ext==".jpg",ext==".jpeg"))
        if(isurl)
            bytes=webread(filename,weboptions("ContentType","binary"));
        else
            fid=fopen(filename,'rb');
            bytes=fread(fid);
            fclose(fid);
        end
        base64string=['data:image/jpeg;base64,' matlab.net.base64encode(bytes)];
    elseif(ext==".wav")
        if(isurl)
            bytes=webread(filename,weboptions("ContentType","binary"));
        else
            fid=fopen(filename,'rb');
            bytes=fread(fid);
            fclose(fid);
        end
        base64string=['data:audio/wav;base64,' matlab.net.base64encode(bytes)];
    elseif(ext==".webp")
        if(isurl)
            bytes=webread(filename,weboptions("ContentType","binary"));
        else
            fid=fopen(filename,'rb');
            bytes=fread(fid);
            fclose(fid);
        end
        base64string=['data:image/webp;base64,' matlab.net.base64encode(bytes)];
    else
        base64string=filename;
    end
end
