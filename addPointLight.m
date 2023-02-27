function light_idx=addPointLight(gltf,varargin)
    % Add a point light source.
    %
    % ADDPOINTLIGHT(GLTF) adds a white point light source with intensity 1
    % candela to GLTF and returns its index.
    %
    % ADDPOINTLIGHT(...,'name',NAME) sets the name for the light.
    %
    % ADDPOINTLIGHT(...,'color',COLOR) sets the colour for the light.
    %
    % ADDPOINTLIGHT(...,'intensity',INTENSITY) sets the intensity for the
    % light in candela.
    %
    % ADDPOINTLIGHT(...,'range',RANGE) sets the distance cut-off at which
    % the light's intensity may be considered to have reached zero.
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
    ips.addParameter('name',missing,@isstring);
    ips.addParameter('color',[],@isnumeric);
    ips.addParameter('intensity',[],@isnumeric);
    ips.addParameter('range',[],@isnumeric);
    ips.parse(varargin{:});
    parameters=ips.Results;
    name=parameters.name;
    color=parameters.color;
    intensity=parameters.intensity;
    range=parameters.range;
    lightstruct=struct('type',"point");
    if(~ismissing(name))
        lightstruct.name=name;
    end
    if(~isempty(color))
        lightstruct.color=color;
    end
    if(~isempty(intensity))
        lightstruct.intensity=intensity;
    end
    if(~isempty(range))
        lightstruct.range=range;
    end
    addExtension(gltf,"KHR_lights_punctual");
    if(~isprop(gltf,'extensions'))
        gltf.addprop('extensions');
    end
    if(isfield(gltf.extensions,'KHR_lights_punctual'))
        light_idx=numel(gltf.extensions.KHR_lights_punctual.lights);
        gltf.extensions.KHR_lights_punctual.lights=[gltf.extensions.KHR_lights_punctual.lights {lightstruct}];
    else
        gltf.extensions.KHR_lights_punctual.lights={lightstruct};
        light_idx=0;
    end
end
