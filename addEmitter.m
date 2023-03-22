function emitter_id=addPositionalEmitter(gltf,varargin)
    % Add an emitter for one or more audio clips with rendering properties
    % and return the emitter ID.
    %
    % ADDPOSITIONALEMITTER(...,'addToNode',NODE) adds the emitter to each node
    % specified in the list of nodes NODE. Global audio emitters may not be
    % added to nodes.
    %
    % ADDPOSITIONALEMITTER(...,'sources',SOURCES) sets sources as the array of audio
    % source indices used by the audio emitter. This array may be empty.
    %
    % ADDPOSITIONALEMITTER(...,'gain',GAIN) sets gain as the unitless multiplier
    % against original source volume for determining emitter loudness. Gain
    % must be positive. Default value is 1.
    %
    % ADDPOSITIONALEMITTER(...,'coneInnerAngle',CONEINNERANGLE) specifies the size of
    % cone in radians inside of which there will be no volume reduction.
    % coneInnerAngle must be between 0 and 2*pi. Default value is 2*pi.
    %
    % ADDPOSITIONALEMITTER(...,'coneOuterAngle',CONEOUTERANGLE) specifies the size of
    % cone in radians for a directional sound outside of which outside of
    % which the volume will be reduced to a constant value of
    % coneOuterGain. coneOuterAngle must be between 0 and 2*pi. Default
    % value is 2*pi.
    %
    % ADDPOSITIONALEMITTER(...,'coneOuterGain',CONEOUTERGAIN) specifies the gain of
    % the audio emitter set when outside the cone defined by the
    % `coneOuterAngle` property. It is a linear value (not dB).
    % CONEOUTERGAIN should be between 0 and 1. Default value is 0.
    %
    % ADDPOSITIONALEMITTER(...,'distanceModel',DISTANCEMODEL) specifies the attenuation
    % function to use on the audio source as it moves away from the
    % listener. distanceModel must be one of: 
    %   "linear":       1-rolloffFactor*(distance-refDistance)/(maxDistance-refDistance)
    %   "inverse ":     refDistance/(refDistance+rolloffFactor*(max(distance,refDistance)-refDistance))
    %   "exponential":  (max(distance,refDistance)/refDistance)^-rolloffFactor
    % Default is "inverse".
    %
    % ADDPOSITIONALEMITTER(...,'refDistance',REFDISTANCE) specifies the reference
    % distance for reducing volume as the emitter moves further from the
    % listener. For distances less than this, the volume is not reduced.
    % refDistance must be non-negative. Default value is 1.
    %
    % ADDPOSITIONALEMITTER(...,'maxDistance',MAXDISTANCE) maximum distance between
    % the emitter and listener, after which the volume will not be reduced
    % any further. maximumDistance is only applicable when the
    % distanceModel is set to linear. maxDistance must be positive. Default
    % value is 10000.
    %
    % ADDPOSITIONALEMITTER(...,'rolloffFactor',ROLLOFFFACTOR) specifies the factor at
    % which attenuation occurs as the the emitter moves away from listener.
    % When distanceModel is set to linear, the maximum value is 1 otherwise
    % there is no upper limit. rolloffFactor must be non-negative. Default
    % value is 1.
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
    typeValues=["positional","global"];
    distanceModelValues=["linear","inverse","exponential"];
    allowed_nodes=(1:numel(gltf.nodes))-1;
    ips=inputParser;
    ips.addParameter('addToNode',[],@isnumeric);
    ips.addParameter('addToScene',false,@islogical);
    ips.addParameter('distanceModel',missing,@(x)GLTF.validateString(x,distanceModelValues));
    ips.addParameter('sources',[],@isnumeric);
    ips.addParameter('gain',nan,@(x)and(isnumeric(x),x>=0));
    ips.addParameter('coneInnerAngle',[],@(x)and(isnumeric(x),and(x>=0,x<=2*pi)));
    ips.addParameter('coneOuterAngle',[],@(x)and(isnumeric(x),and(x>=0,x<=2*pi)));
    ips.addParameter('coneOuterGain',[],@(x)and(isnumeric(x),and(x>=0,x<=1)));
    ips.addParameter('refDistance',nan,@(x)and(isnumeric(x),x>=0));
    ips.addParameter('maxDistance',nan,@(x)and(isnumeric(x),x>0));
    ips.addParameter('rolloffFactor',nan,@(x)and(isnumeric(x),x>=0));
    ips.parse(varargin{:});
    parameters=ips.Results;
    addToNode=parameters.addToNode;
    addToNode=addToNode(ismember(addToNode,allowed_nodes));
    addToScene=parameters.addToScene;
    addToScene=and(addToScene,isempty(addToNode));
    distanceModel=parameters.distanceModel;
    gain=parameters.gain;
    sources=parameters.sources;
    coneInnerAngle=parameters.coneInnerAngle;
    coneOuterAngle=parameters.coneOuterAngle;
    coneOuterGain=parameters.coneOuterGain;
    refDistance=parameters.refDistance;
    maxDistance=parameters.maxDistance;
    rolloffFactor=parameters.rolloffFactor;
    if(~isempty(sources))
        emitter_sources=repmat({struct('clip',[])},1,numel(sources));
        if(~isempty(weights) || sum(weights)>0)
            if(numel(sources)>numel(weights))
                weights=[weights(:);repmat(weights(end),numel(sources)-numel(weights),1)];
            else
                weights=weights(1:numel(sources));
            end
            weights=weights/sum(weights);
            for i=1:numel(sources)
                emitter_sources{i}.clip=sources(i);
                if(isfinite(weights(i)))
                    emitter_sources{i}.weight=weights(i);
                end
            end
        else
            for i=1:numel(sources)
                emitter_sources{i}.clip=sources(i);
            end
        end
        if(numel(emitter_sources)==1)
            emitter_struct=struct('clips',{emitter_sources});
        else
            emitter_struct=struct('clips',emitter_sources);
        end
        if(~addToScene)
            if(~ismissing(distanceModel))
                emitter_struct.distanceModel=distanceModel;
            end
            if(~isnan(refDistance))
                emitter_struct.refDistance=refDistance;
            end
            if(~isnan(maxDistance))
                emitter_struct.maxDistance=max(maxDistance,refDistance);
            end
            if(~isnan(rolloffFactor))
                if(distanceModel=="linear")
                    emitter_struct.maxDistance=min(rolloffFactor,1);
                else
                    emitter_struct.maxDistance=rolloffFactor;
                end
            end
            innerAngle=min(max(0,innerAngle),pi/2);
            outerAngle=min(max(outerAngle,0),pi/2);
            if(and(~isempty(innerAngle),~isempty(outerAngle)))
                if(innerAngle>outerAngle)
                    temp=innerAngle;
                    innerAngle=outerAngle;
                    outerAngle=temp;
                end
            end
            if(~isempty(innerAngle))
                emitter_struct.innerAngle=innerAngle;
            end
            if(~isempty(outerAngle))
                emitter_struct.outerAngle=outerAngle;
            end
        end
        if(~isempty(loop))
            emitter_struct.loop=loop;
        end
        if(~isnan(gain))
            emitter_struct.outerAngle=min(max(0,gain),1);
        end
        if(~ismissing(name))
            emitter_struct.name=name;
        end
        addExtension(gltf,"MSFT_audio_emitter");
        if(~isprop(gltf,'extensions'))
            gltf.addprop('extensions');
        end
        if(isfield(gltf.extensions,'MSFT_audio_emitter') && isfield(gltf.extensions.MSFT_audio_emitter,'emitters') && ~isempty(gltf.extensions.MSFT_audio_emitter.emitters))
            emitter_id=numel([gltf.extensions.MSFT_audio_emitter.emitters{:}]);
            gltf.extensions.MSFT_audio_emitter.emitters=[gltf.extensions.MSFT_audio_emitter.emitters{:} emitter_struct];
        else
            emitter_id=0;
            gltf.extensions.MSFT_audio_emitter.emitters={emitter_struct};
        end
        if(~isempty(addToNode))
            for i=1:numel(addToNode)
                node_idx=addToNode(i)+1;
                if(isfield(gltf.nodes{node_idx},'extensions') && isfield(gltf.nodes{node_idx}.extensions,'MSFT_audio_emitter') && isfield(gltf.nodes{node_idx}.extensions.MSFT_audio_emitter,'emitters'))
                    gltf.nodes{node_idx}.extensions.MSFT_audio_emitter.emitters=[gltf.nodes{node_idx}.extensions.MSFT_audio_emitter.emitters{:} emitter_id];
                else
                    gltf.nodes{node_idx}.extensions.MSFT_audio_emitter.emitters=GLTF.toCells(emitter_id);
                end
            end
        elseif(addToScene)
            if(isfield(gltf.scenes{1},'extensions') && isfield(gltf.scenes{1}.extensions,'MSFT_audio_emitter') && isfield(gltf.scenes{1}.extensions.MSFT_audio_emitter,'emitters'))
                gltf.scenes{1}.extensions.MSFT_audio_emitter.emitters=[gltf.scenes{1}.extensions.MSFT_audio_emitter.emitters{:} emitter_id];
            else
                gltf.scenes{1}.extensions.MSFT_audio_emitter.emitters=GLTF.toCells(emitter_id);
            end
        end
    end
end