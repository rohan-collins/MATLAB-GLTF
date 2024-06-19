function eventStruct=createEventStruct(~,emitter,action,varargin)
    % Create and return an event struct for an emitter to be used in an
    % animation.
    %
    % ADDEMITTER(GLTF,EMITTER,ACTION) returns an event struct for an
    % EMITTER to take action ACTION.
    %
    % ADDEMITTER(...,'delay',TIME), delays the action by TIME seconds.
    %
    % ADDEMITTER(...,'startOffset',OFFSET) positions the clip head at a
    % specific time in seconds. This setting nly used when ACTION is
    % "play".
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
    actionValues=["play","pause","stop"];
    ips=inputParser;
    ips.addParameter('startOffset',[],@isnumeric);
    ips.addParameter('delay',0,@isnumeric);
    ips.parse(varargin{:});
    parameters=ips.Results;
    startOffset=parameters.startOffset;
    time=parameters.delay;
    if(ismember(action,actionValues))
        eventStruct=struct('emitter',round(emitter),'action',action,'time',max(time,0));
        if(action=="play" && ~isempty(startOffset))
            eventStruct.startOffset=startOffset;
        end
    else
        eventStruct=struct();
    end
end
