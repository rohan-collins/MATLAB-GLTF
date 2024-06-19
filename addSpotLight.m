function light_idx=addSpotLight(gltf,varargin)
    % Add a spot light source.
    %
    % ADDSPOTLIGHT(GLTF) adds a white spot light source with intensity 1
    % candela to GLTF and returns its index. The light is pointed in the -Z
    % direction.
    %
    % ADDSPOTLIGHT(...,'name',NAME) sets the name for the light.
    %
    % ADDSPOTLIGHT(...,'color',COLOR) sets the colour for the light.
    %
    % ADDSPOTLIGHT(...,'intensity',INTENSITY) sets the intensity for the
    % light in candela.
    %
    % ADDSPOTLIGHT(...,'range',RANGE) sets the distance cut-off at which
    % the light's intensity may be considered to have reached zero.
    %
    % ADDSPOTLIGHT(...,'innerConeAngle',INNERCONEANGLE) specifies the
    % angle, in radians, from centre of spotlight where fall-off begins.
    % Must be greater than or equal to 0 and less than outerConeAngle.
    %
    % ADDSPOTLIGHT(...,'outerConeAngle',OUTERCONEANGLE) specifies the
    % angle, in radians, from centre of spotlight where fall-off ends. Must
    % be greater than innerConeAngle and less than or equal to pi/2.
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
    ips=inputParser;
    ips.addParameter('name',missing,@isstring);
    ips.addParameter('color',[],@isnumeric);
    ips.addParameter('intensity',[],@isnumeric);
    ips.addParameter('range',[],@isnumeric);
    ips.addParameter('innerConeAngle',[],@isnumeric);
    ips.addParameter('outerConeAngle',[],@isnumeric);
    ips.parse(varargin{:});
    parameters=ips.Results;
    name=parameters.name;
    color=parameters.color;
    intensity=parameters.intensity;
    range=parameters.range;
    innerConeAngle=parameters.innerConeAngle;
    outerConeAngle=parameters.outerConeAngle;
    lightstruct=struct('type',"spot",'spot',[]);
    innerConeAngle=max(0,innerConeAngle);
    outerConeAngle=min(outerConeAngle,pi/2);
    if(and(~isempty(innerConeAngle),~isempty(outerConeAngle)))
        if(innerConeAngle>outerConeAngle)
            temp=innerConeAngle;
            innerConeAngle=outerConeAngle;
            outerConeAngle=temp;
        elseif(innerConeAngle==outerConeAngle)
            avg=(innerConeAngle+outerConeAngle)/2;
            innerConeAngle=avg-sqrt(eps)/2;
            outerConeAngle=avg+sqrt(eps)/2;
        end
    end
    if(~isempty(innerConeAngle))
        lightstruct.spot.innerConeAngle=innerConeAngle;
    end
    if(~isempty(outerConeAngle))
        lightstruct.spot.outerConeAngle=outerConeAngle;
    end
    if(~ismissing(name))
        lightstruct.name=name;
    end
    if(~isempty(isnan(color)))
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
