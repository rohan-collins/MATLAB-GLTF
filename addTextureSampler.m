function sampler_idx=addTextureSampler(gltf,varargin)
    % Add a texture sampler.
    %
    % ADDTEXTURESAMPLER(GLTF) adds a new empty texture sampler to GLTF and
    % returns its index.
    %
    % ADDTEXTURESAMPLER(...,'magFilter',MAGFILTER) sets the magnification
    % filter for the texture as per OpenGL. MAGFILTER should be one of
    % "NEAREST", "LINEAR", "NEAREST_MIPMAP_NEAREST",
    % "LINEAR_MIPMAP_NEAREST", "NEAREST_MIPMAP_LINEAR", or
    % "LINEAR_MIPMAP_LINEAR".
    %
    % ADDTEXTURESAMPLER(...,'minFilter',MINFILTER) sets the minifications
    % filter for the texture as per OpenGL. MINFILTER should be one of
    % "NEAREST", "LINEAR", "NEAREST_MIPMAP_NEAREST",
    % "LINEAR_MIPMAP_NEAREST", "NEAREST_MIPMAP_LINEAR", or
    % "LINEAR_MIPMAP_LINEAR".
    %
    % ADDTEXTURESAMPLER(...,'wrapS',WRAPS) sets the wrapping of the U
    % coordinate of texture coordinates as per OpenGL. WRAPS should be one
    % of "CLAMP_TO_EDGE", "MIRRORED_REPEAT", or "REPEAT".
    %
    % ADDTEXTURESAMPLER(...,'wrapT',WRAPT) sets the wrapping of the V
    % coordinate of texture coordinates as per OpenGL. WRAPT should be one
    % of "CLAMP_TO_EDGE", "MIRRORED_REPEAT", or "REPEAT".
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
    filter_str_values=["NEAREST","LINEAR","NEAREST_MIPMAP_NEAREST","LINEAR_MIPMAP_NEAREST","NEAREST_MIPMAP_LINEAR","LINEAR_MIPMAP_LINEAR"];
    filter_num_values=[     9728,    9729,                    9984,                   9985,                   9986,                  9987];
    wrap_str_values=["CLAMP_TO_EDGE","MIRRORED_REPEAT","REPEAT"];
    wrap_num_values=[          33071,            33071,   10497];
    ips=inputParser;
    ips.addParameter('magFilter',missing,@(x)GLTF.validateString(x,filter_str_values));
    ips.addParameter('minFilter',missing,@(x)GLTF.validateString(x,filter_str_values));
    ips.addParameter('wrapS',missing,@(x)GLTF.validateString(x,wrap_str_values));
    ips.addParameter('wrapT',missing,@(x)GLTF.validateString(x,wrap_str_values));
    ips.parse(varargin{:});
    parameters=ips.Results;
    samplerstruct=struct();
    magFilter=parameters.magFilter;
    minFilter=parameters.minFilter;
    wrapS=parameters.wrapS;
    wrapT=parameters.wrapT;
    if(~ismissing(magFilter))
        magFilter=upper(magFilter);
        magFilter=filter_num_values(filter_str_values==magFilter);
        samplerstruct.magFilter=magFilter;
    end
    if(~ismissing(minFilter))
        minFilter=upper(minFilter);
        minFilter=filter_num_values(filter_str_values==minFilter);
        samplerstruct.minFilter=minFilter;
    end
    if(~ismissing(wrapS))
        wrapS=upper(wrapS);
        wrapS=wrap_num_values(wrap_str_values==wrapS);
        samplerstruct.wrapS=wrapS;
    end
    if(~ismissing(wrapT))
        wrapT=upper(wrapT);
        wrapT=wrap_num_values(wrap_str_values==wrapT);
        samplerstruct.wrapT=wrapT;
    end
    sampler={samplerstruct};
    if(~isprop(gltf,'samplers'))
        gltf.addprop('samplers');
    end
    sampler_idx=numel(gltf.samplers);
    gltf.samplers=[gltf.samplers;sampler];
end
