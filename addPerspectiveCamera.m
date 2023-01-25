function camera_idx=addPerspectiveCamera(gltf,varargin)
    % Add a perspective camera.
    %
    % ADDPERSPECTIVECAMERA(GLTF) adds a perspective camera with the default
    % parameters to GLTF and returns its index.
    %
    % ADDPERSPECTIVECAMERA(...,'name',NAME) sets the name of the camera.
    %
    % ADDPERSPECTIVECAMERA(...,'aspectRatio',aspectRatio) sets the aspect
    % ratio for the camera.
    %
    % ADDPERSPECTIVECAMERA(...,'yfov',yfov) specifies the field-of-view
    % angle for the camera in radians. By default, yfov is 0.7.
    %
    % ADDPERSPECTIVECAMERA(...,'zfar',zfar) sets the far cutoff distance
    % for the camera.
    %
    % ADDPERSPECTIVECAMERA(...,'znear',znear) specifies the near cutoff
    % distance for the camera. By default, znear is 0.01.
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
    ips.addParameter('aspectRatio',[],@isnumeric);
    ips.addParameter('yfov',0.7,@isnumeric);
    ips.addParameter('zfar',[],@isnumeric);
    ips.addParameter('znear',0.01,@isnumeric);
    ips.parse(varargin{:});
    parameters=ips.Results;
    name=parameters.name;
    aspectRatio=parameters.aspectRatio;
    yfov=parameters.yfov;
    zfar=parameters.zfar;
    znear=parameters.znear;
    if(~isempty(zfar))
        if(znear>zfar)
            zfar=parameters.znear;
            znear=parameters.zfar;
        end
    end
    camerastruct=struct('type',"perspective",'perspective',struct('yfov',yfov,'znear',znear));
    if(~ismissing(name))
        camerastruct.name=name;
    end
    if(~isempty(aspectRatio))
        camerastruct.perspective.aspectRatio=aspectRatio;
    end
    if(~isempty(zfar))
        camerastruct.perspective.zfar=zfar;
    end
    if(~isprop(gltf,'cameras'))
        gltf.addprop('cameras');
    end
    camera_idx=numel(gltf.cameras);
    gltf.cameras=[gltf.cameras;{camerastruct}];
end
