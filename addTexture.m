function texture_idx=addTexture(gltf,image,varargin)
    % Add a texture.
    %
    % ADDTEXTURE(GLTF,FILENAME) adds the image specified in filename as a
    % new texture, normal map, occusion map, or emission map and returns
    % its index.
    %
    % ADDTEXTURE(...,'name',NAME) sets the name of the texture.
    %
    % ADDTEXTURE(...,'webpImage',FILENAME) uses the WebP image specified in
    % filename as the texture. A client that does not accept WebP images
    % can ignore this image and continue to rely on the PNG and JPG
    % textures available in the base specification.
    %
    % ADDTEXTURE(...,'magFilter',MAGFILTER) sets the magnification filter
    % for the texture as per OpenGL. MAGFILTER should be one of "NEAREST",
    % "LINEAR", "NEAREST_MIPMAP_NEAREST", "LINEAR_MIPMAP_NEAREST",
    % "NEAREST_MIPMAP_LINEAR", or "LINEAR_MIPMAP_LINEAR".
    %
    % ADDTEXTURE(...,'minFilter',MINFILTER) sets the minification filter
    % for the texture as per OpenGL. MINFILTER should be one of "NEAREST",
    % "LINEAR", "NEAREST_MIPMAP_NEAREST", "LINEAR_MIPMAP_NEAREST",
    % "NEAREST_MIPMAP_LINEAR", or "LINEAR_MIPMAP_LINEAR".
    %
    % ADDTEXTURE(...,'wrapS',WRAPS) sets the wrapping of the U coordinate
    % of texture coordinates as per OpenGL. WRAPS should be one of
    % "CLAMP_TO_EDGE", "MIRRORED_REPEAT", or "REPEAT".
    %
    % ADDTEXTURE(...,'wrapT',WRAPT) sets the wrapping of the V coordinate
    % of texture coordinates as per OpenGL. WRAPT should be one of
    % "CLAMP_TO_EDGE", "MIRRORED_REPEAT", or "REPEAT".
    %
    % ADDTEXTURE(...,'embedTexture',FALSE) uses the the relative filepath
    % of the texture instead of embedding the texture. If this option is
    % used, the GLTF object does not have to be recreated whenever texture
    % images are changed.
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
    filter_str_values=["NEAREST","LINEAR","NEAREST_MIPMAP_NEAREST","LINEAR_MIPMAP_NEAREST","NEAREST_MIPMAP_LINEAR","LINEAR_MIPMAP_LINEAR"];
    wrap_str_values=["CLAMP_TO_EDGE","MIRRORED_REPEAT","REPEAT"];
    ips=inputParser;
    ips.addParameter('name',missing,@isstring);
    ips.addParameter('magFilter',missing,@(x)GLTF.validateString(x,filter_str_values));
    ips.addParameter('minFilter',missing,@(x)GLTF.validateString(x,filter_str_values));
    ips.addParameter('wrapS',missing,@(x)GLTF.validateString(x,wrap_str_values));
    ips.addParameter('wrapT',missing,@(x)GLTF.validateString(x,wrap_str_values));
    ips.addParameter('embedTexture',true,@islogical);
    ips.addParameter('webpImage',missing,@isstring);
    ips.parse(varargin{:});
    parameters=ips.Results;
    name=parameters.name;
    magFilter=upper(parameters.magFilter);
    minFilter=upper(parameters.minFilter);
    wrapS=upper(parameters.wrapS);
    wrapT=upper(parameters.wrapT);
    embedTexture=parameters.embedTexture;
    webpImage=parameters.webpImage;
    sampler_idx=gltf.addTextureSampler('magFilter',magFilter,'minFilter',minFilter,'wrapS',wrapS,'wrapT',wrapT);
    image_idx=gltf.addImage(image,'embedTexture',embedTexture);
    if(~isprop(gltf,'textures'))
        gltf.addprop('textures');
    end
    texture_idx=numel(gltf.textures);
    if(ismissing(name))
        texturestruct=struct('sampler',sampler_idx,'source',image_idx);
    else
        texturestruct=struct('sampler',sampler_idx,'source',image_idx,'name',name);
    end
    if(~ismissing(webpImage))
        addExtension(gltf,"EXT_texture_webp");
        webp_idx=gltf.addImage(webpImage,'embedTexture',embedTexture);
        EXT_texture_webp_struct=struct('source',webp_idx);
        texturestruct.extensions.EXT_texture_webp=EXT_texture_webp_struct;
    end
    gltf.textures=[gltf.textures {texturestruct}];
end
