function light_idx=addDirectionalLight(gltf,varargin)
    % Add a directional light source.
    %
    % ADDDIRECTIONALLIGHT(GLTF) adds a white directional light source with
    % intensity 1 lm/m^2 to GLTF and returns its index. The light is
    % pointed in the -Z direction.
    %
    % ADDDIRECTIONALLIGHT(...,'name',NAME) sets the name for the light.
    %
    % ADDDIRECTIONALLIGHT(...,'color',COLOR) sets the colour for the light.
    %
    % ADDDIRECTIONALLIGHT(...,'intensity',INTENSITY) sets the intensity for
    % the light in lm/m^2.
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
    ips.parse(varargin{:});
    parameters=ips.Results;
    name=parameters.name;
    color=parameters.color;
    intensity=parameters.intensity;
    lightstruct=struct('type',"directional");
    if(~ismissing(name))
        lightstruct.name=name;
    end
    if(~isempty(color))
        lightstruct.color=color;
    end
    if(~isempty(intensity))
        lightstruct.intensity=intensity;
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
