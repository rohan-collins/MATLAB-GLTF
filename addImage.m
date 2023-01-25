function image_idx=addImage(gltf,image,varargin)
    % Add an image.
    %
    % ADDIMAGE(GLTF,FILENAME) adds the image specified by FILENAME to GLTF
    % as a texture, normal map, occlusion map, or emmision map and returns
    % its index.
    %
    % ADDIMAGE(...,'name',NAME) sets the name of the image.
    %
    % ADDIMAGE(...,'embedTexture',FALSE) uses the the relative filepath of
    % the texture instead of embedding the texture. If this option is used,
    % the GLTF object does not have to be recreated whenever texture images
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
    ips.addParameter('embedTexture',true,@islogical);
    ips.addParameter('name',missing,@isstring);
    ips.parse(varargin{:});
    parameters=ips.Results;
    name=parameters.name;
    embedTexture=parameters.embedTexture;
    if(embedTexture)
        image={struct('uri',GLTF.string2URI(image))};
    else
        image={struct('uri',image)};
    end
    if(~ismissing(name))
        image.name=name;
    end
    if(~isprop(gltf,'images'))
        gltf.addprop('images');
    end
    image_idx=numel(gltf.images);
    gltf.images=[gltf.images image];
end
