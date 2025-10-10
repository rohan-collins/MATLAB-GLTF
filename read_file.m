function out=read_file(filename,varargin)
    % Reads file from given filename, either from the web or from local
    % file. Reads the file as bytes if fmt is "b".
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
    useweb=and(isMATLABReleaseOlderThan("R2024b"),and(~GLTF.is_url(filename),GLTF.is_filepath(filename)));
    if(nargin>1)
        fmt=varargin{1};
        bin_fmt=startsWith(string(fmt),"b",'IgnoreCase',true);
    else
        bin_fmt=false;
    end
    if(useweb)
        if(bin_fmt)
            out=uint8(webread(filename,weboptions("ContentType","binary")));
        else
            out=webread(filename);
        end
    else
        if(bin_fmt)
            fid=fopen(filename,'rb');
            out=uint8(fread(fid));
            fclose(fid);
        else
            out=fileread(filename);
        end
    end
end