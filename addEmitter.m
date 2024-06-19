function emitter_id=addEmitter(gltf,clips,varargin)
    % Add an emitter for one or more audio clips with rendering properties
    % and return the emitter ID.
    %
    % ADDEMITTER(GLTF,CLIPS) adds an emitter with the given clip IDs.
    %
    % ADDEMITTER(...,'addToNode',NODE) adds the emitter to each node
    % specified in the list of nodes NODE.
    %
    % ADDEMITTER(...,'addToScene',TRUE) adds the emitter to the scene.
    % Directional and distance properties are ignored. This setting is
    % ignored if the emitter is already supposed to be added to nodes.
    %
    % ADDEMITTER(...,'weights',WEIGHTS) uses the random selection weights
    % defined by WEIGHTS. Weights will be normalised to sum to 1.
    %
    % ADDEMITTER(...,'distanceModel',MODEL) specifies the attenuation
    % function to use on the audio source as it moves away from the
    % listener. The attenuation calculation is done in emitter space. Model
    % must be one of: 
    %   "linear": 1-rolloffFactor*(distance-refDistance)/(maxDistance-refDistance)
    %   "inverse ": refDistance/(refDistance+rolloffFactor*(distance-refDistance))
    %   "exponential": pow(distance/refDistance,-rolloffFactor)
    % Default is "exponential".
    %
    % ADDEMITTER(...,'refDistance',REFDISTANCE) specifies the reference
    % distance to use for the model. Default value is 1.
    %
    % ADDEMITTER(...,'maxDistance',MAXDISTANCE) specifies the maximum
    % distance between source and listener outside of which there will be
    % no sound. Default value is 256.
    %
    % ADDEMITTER(...,'rolloffFactor',ROLLOFFFACTOR) specifies the factor at
    % which attenuation occurs as the source moves further from the
    % listener. Default value is 1.
    %
    % ADDEMITTER(...,'innerAngle',INNERANGLE) specifies the size of cone in
    % radians for a directional sound in which there will be no
    % attenuation. Default value is pi. If neither innerAngle or outerAngle
    % are defined the emitter will behave as an omnidirectional source.
    %
    % ADDEMITTER(...,'outerAngle',OUTERANGLE) specifies the size of cone in
    % radians for a directional sound outside of which there will be no
    % sound. Listener angles between innerAngle and outerAngle will falloff
    % linearly. The outerAngle value must be greater than or equal to the
    % innerAngle value. Default value is pi. If neither innerAngle or
    % outerAngle are defined the emitter will behave as an omnidirectional
    % source.
    %
    % ADDEMITTER(...,'loop',TRUE) makes the source play in loops.
    %
    % ADDEMITTER(...,'volume',VOLUME)specifies the playback volume. Value
    % is clipped between 0 and 1.
    %
    % ADDEMITTER(...,'name',NAME) sets the name of the emitter.
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
    distanceModelValues=["linear","inverse","exponential"];
    allowed_nodes=(1:numel(gltf.nodes))-1;
    ips=inputParser;
    ips.addParameter('addToNode',[],@isnumeric);
    ips.addParameter('addToScene',false,@islogical);
    ips.addParameter('weights',[],@isnumeric);
    ips.addParameter('distanceModel',missing,@(x)GLTF.validateString(x,distanceModelValues));
    ips.addParameter('refDistance',nan,@isnumeric);
    ips.addParameter('maxDistance',nan,@isnumeric);
    ips.addParameter('rolloffFactor',nan,@isnumeric);
    ips.addParameter('innerAngle',[],@isnumeric);
    ips.addParameter('outerAngle',[],@isnumeric);
    ips.addParameter('loop',[],@islogical);
    ips.addParameter('volume',[],@isnumeric);
    ips.addParameter('name',missing,@isstring);
    ips.parse(varargin{:});
    parameters=ips.Results;
    addToNode=parameters.addToNode;
    addToNode=addToNode(ismember(addToNode,allowed_nodes));
    addToScene=parameters.addToScene;
    addToScene=and(addToScene,isempty(addToNode));
    weights=parameters.weights;
    distanceModel=parameters.distanceModel;
    refDistance=parameters.refDistance;
    maxDistance=parameters.maxDistance;
    rolloffFactor=parameters.rolloffFactor;
    innerAngle=parameters.innerAngle;
    outerAngle=parameters.outerAngle;
    loop=parameters.loop;
    volume=parameters.volume;
    name=parameters.name;
    if(~isempty(clips))
        emitter_clips=repmat({struct('clip',[])},1,numel(clips));
        if(~isempty(weights) || sum(weights)>0)
            if(numel(clips)>numel(weights))
                weights=[weights(:);repmat(weights(end),numel(clips)-numel(weights),1)];
            else
                weights=weights(1:numel(clips));
            end
            weights=weights/sum(weights);
            for i=1:numel(clips)
                emitter_clips{i}.clip=clips(i);
                if(isfinite(weights(i)))
                    emitter_clips{i}.weight=weights(i);
                end
            end
        else
            for i=1:numel(clips)
                emitter_clips{i}.clip=clips(i);
            end
        end
        if(numel(emitter_clips)==1)
            emitter_struct=struct('clips',{emitter_clips});
        else
            emitter_struct=struct('clips',emitter_clips);
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
        if(~isnan(volume))
            emitter_struct.outerAngle=min(max(0,volume),1);
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
