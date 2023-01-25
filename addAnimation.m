function addAnimation(gltf,samplers,channels,varargin)
    % Add an animation to the mode.
    %
    % ADDANIMATION(GLTF,SAMPLERS,CHANNELS) adds an animation to GLTF, where
    % SAMPLERS is an array of animation samplers, and CHANNELS is an array
    % of animation channels.
    %
    % ADDANIMATIONSAMPLER(...,'name',NAME) sets the name of the animation,
    % that is used when triggering animations.
    %
    % ADDANIMATIONSAMPLER(...,'events',EVENTS) adds EVENTS as an array of
    % MSFT_audio_emitter events to the animation.
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
    ips.addParameter('events',[],@isstruct);
    ips.parse(varargin{:});
    parameters=ips.Results;
    name=parameters.name;
    events=parameters.events;
    if(~isprop(gltf,'animations'))
        gltf.addprop('animations');
    end
    animationstruct={struct('samplers',[],'channels',[])};
    animationstruct{1}.samplers=GLTF.toCells(samplers);
    animationstruct{1}.channels=GLTF.toCells(channels);
    if(~ismissing(name))
        animationstruct{1}.name=name;
    end
    if(~isempty(events))
        animationstruct{1}.extensions.MSFT_audio_emitter.events=GLTF.toCells(events);
    end
    if(isempty(gltf.animations))
        gltf.animations=animationstruct;
    else
        gltf.animations=[gltf.animations(:);animationstruct(:)]';
    end
end
