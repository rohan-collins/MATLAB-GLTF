function emitter_id=addPositionalEmitter(gltf,varargin)
    % Add a positional emitter for one or more audio clips and return the
    % emitter ID.
    %
    % ADDPOSITIONALEMITTER(...,'addToNode',NODE) adds the emitter to each
    % node specified in the list of nodes NODE. Global audio emitters may
    % not be added to nodes.
    %
    % ADDPOSITIONALEMITTER(...,'sources',SOURCES) sets sources as the array
    % of audio source indices used by the audio emitter.
    %
    % ADDPOSITIONALEMITTER(...,'gain',GAIN) sets gain as the unitless
    % multiplier against original source volume for determining emitter
    % loudness. Gain must be positive. Default value is 1.
    %
    % ADDPOSITIONALEMITTER(...,'coneInnerAngle',CONEINNERANGLE) specifies
    % the size of cone in radians inside of which there will be no volume
    % reduction. coneInnerAngle must be between 0 and 2*pi. Default value
    % is 2*pi.
    %
    % ADDPOSITIONALEMITTER(...,'coneOuterAngle',CONEOUTERANGLE) specifies
    % the size of cone in radians for a directional sound outside of which
    % outside of which the volume will be reduced to a constant value of
    % coneOuterGain. coneOuterAngle must be between 0 and 2*pi. Default
    % value is 2*pi.
    %
    % ADDPOSITIONALEMITTER(...,'coneOuterGain',CONEOUTERGAIN) specifies the
    % gain of the audio emitter set when outside the cone defined by the
    % coneOuterAngle property. It is a linear value (not dB). CONEOUTERGAIN
    % should be between 0 and 1. Default value is 0.
    %
    % ADDPOSITIONALEMITTER(...,'distanceModel',DISTANCEMODEL) specifies the
    % attenuation function to use on the audio source as it moves away from
    % the listener. DistanceModel must be one of:
    %   "linear":       1-rolloffFactor*(distance-refDistance)/(maxDistance-refDistance)
    %   "inverse ":     refDistance/(refDistance+rolloffFactor*(max(distance,refDistance)-refDistance))
    %   "exponential":  (max(distance,refDistance)/refDistance)^-rolloffFactor
    % Default is "inverse".
    %
    % ADDPOSITIONALEMITTER(...,'refDistance',REFDISTANCE) specifies the
    % reference distance for reducing volume as the emitter moves further
    % from the listener. For distances less than this, the volume is not
    % reduced. refDistance must be non-negative. Default value is 1.
    %
    % ADDPOSITIONALEMITTER(...,'maxDistance',MAXDISTANCE) maximum distance
    % between the emitter and listener, after which the volume will not be
    % reduced any further. MaximumDistance is only applicable when the
    % distanceModel is set to linear. maxDistance must be positive. Default
    % value is 10000.
    %
    % ADDPOSITIONALEMITTER(...,'rolloffFactor',ROLLOFFFACTOR) specifies the
    % factor at which attenuation occurs as the the emitter moves away from
    % listener. When distanceModel is set to linear, the maximum value is 1
    % otherwise there is no upper limit. rolloffFactor must be
    % non-negative. Default value is 1.
    %
    % ADDPOSITIONALEMITTER(...,'name',NAME) sets the name of the emitter.
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
    distanceModelValues=["linear","inverse","exponential"];
    allowed_nodes=(1:numel(gltf.nodes))-1;
    ips=inputParser;
    ips.addParameter('addToNode',[],@isnumeric);
    ips.addParameter('distanceModel',missing,@(x)GLTF.validateString(x,distanceModelValues));
    ips.addParameter('sources',[],@isnumeric);
    ips.addParameter('gain',nan,@(x)and(isnumeric(x),x>=0));
    ips.addParameter('coneInnerAngle',nan,@(x)and(isnumeric(x),and(x>=0,x<=2*pi)));
    ips.addParameter('coneOuterAngle',nan,@(x)and(isnumeric(x),and(x>=0,x<=2*pi)));
    ips.addParameter('coneOuterGain',nan,@(x)and(isnumeric(x),and(x>=0,x<=1)));
    ips.addParameter('refDistance',nan,@(x)and(isnumeric(x),x>=0));
    ips.addParameter('maxDistance',nan,@(x)and(isnumeric(x),x>0));
    ips.addParameter('rolloffFactor',nan,@(x)and(isnumeric(x),x>=0));
    ips.addParameter('name',missing,@isstring);
    ips.parse(varargin{:});
    parameters=ips.Results;
    addToNode=parameters.addToNode;
    addToNode=addToNode(ismember(addToNode,allowed_nodes));
    distanceModel=parameters.distanceModel;
    gain=parameters.gain;
    sources=parameters.sources;
    coneInnerAngle=parameters.coneInnerAngle;
    coneOuterAngle=parameters.coneOuterAngle;
    coneOuterGain=parameters.coneOuterGain;
    refDistance=parameters.refDistance;
    maxDistance=parameters.maxDistance;
    rolloffFactor=parameters.rolloffFactor;
    name=parameters.name;
    emitterStruct=struct('type',"positional");
    if(~isempty(sources))
        emitterStruct.sources=GLTF.toCells(sources);
    end
    if(~isnan(gain))
        emitterStruct.gain=gain;
    end
    if(~ismissing(name))
        emitterStruct.name=name;
    end
    if(~or(or(ismissing(distanceModel),or(isnan(coneInnerAngle),isnan(coneOuterAngle))),or(or(isnan(coneOuterGain),isnan(maxDistance)),or(isnan(refDistance),isnan(rolloffFactor)))))
        positionalStruct=struct();
        if(~ismissing(distanceModel))
            positionalStruct.distanceModel=distanceModel;
        end
        if(~isnan(coneInnerAngle))
            positionalStruct.coneInnerAngle=coneInnerAngle;
        end
        if(~isnan(coneOuterAngle))
            positionalStruct.coneOuterAngle=coneOuterAngle;
        end
        if(~isnan(coneOuterGain))
            positionalStruct.coneOuterGain=coneOuterGain;
        end
        if(~isnan(maxDistance))
            positionalStruct.maxDistance=maxDistance;
        end
        if(~isnan(refDistance))
            positionalStruct.refDistance=refDistance;
        end
        if(~isnan(rolloffFactor))
            positionalStruct.rolloffFactor=rolloffFactor;
        end
        emitterStruct.positional=positionalStruct;
    end
    addExtension(gltf,"KHR_audio");
    if(~isprop(gltf,'extensions'))
        gltf.addprop('extensions');
    end
    if(isfield(gltf.extensions,'KHR_audio') && isfield(gltf.extensions.KHR_audio,'emitters') && ~isempty(gltf.extensions.KHR_audio.emitters))
        emitter_id=numel([gltf.extensions.KHR_audio.emitters{:}]);
        gltf.extensions.KHR_audio.emitters=GLTF.toCells([gltf.extensions.KHR_audio.emitters{:} emitterStruct{:}]);
    else
        emitter_id=0;
        gltf.extensions.KHR_audio.emitters=emitterStruct;
    end
    for i=1:numel(addToNode)
        node_idx=addToNode(i)+1;
        if(isfield(gltf.nodes{node_idx},'extensions') && isfield(gltf.nodes{node_idx}.extensions,'KHR_audio') && isfield(gltf.nodes{node_idx}.extensions.KHR_audio,'emitters'))
            gltf.nodes{node_idx}.extensions.KHR_audio.emitters=GLTF.toCells([gltf.nodes{node_idx}.extensions.KHR_audio.emitters{:} emitter_id]);
        else
            gltf.nodes{node_idx}.extensions.KHR_audio.emitters=GLTF.toCells(emitter_id);
        end
    end
end