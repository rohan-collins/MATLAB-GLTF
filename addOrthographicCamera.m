function camera_idx=addOrthographicCamera(gltf,varargin)
    % Add an orthographic camera.
    %
    % ADDORTHOGRAPHICCAMERA(GLTF) adds an orhtographic camera with the
    % default parameters to GLTF and returns its index.
    %
    % ADDORTHOGRAPHICCAMERA(...,'name',NAME) sets the name of the camera.
    %
    % ADDORTHOGRAPHICCAMERA(...,'xmag',xmag) specifies the X-axis
    % magnification for the camera. By default, xmag is 1.
    %
    % ADDORTHOGRAPHICCAMERA(...,'ymag',ymag) specifies the Y-axis
    % magnification for the camera. By default, ymag is 1.
    %
    % ADDORTHOGRAPHICCAMERA(...,'zfar',zfar) specifies the far cutoff
    % distance for the camera. By default, zfar is 100.
    %
    % ADDORTHOGRAPHICCAMERA(...,'znear',znear) specifies the near cutoff
    % distance for the camera. By default, zfar is 0.01.
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
    ips.addParameter('xmag',1,@isnumeric);
    ips.addParameter('ymag',1,@isnumeric);
    ips.addParameter('zfar',100,@isnumeric);
    ips.addParameter('znear',0.01,@isnumeric);
    ips.parse(varargin{:});
    parameters=ips.Results;
    name=parameters.name;
    xmag=parameters.xmag;
    ymag=parameters.ymag;
    zfar=parameters.zfar;
    znear=parameters.znear;
    if(znear>zfar)
        zfar=parameters.znear;
        znear=parameters.zfar;
    end
    camerastruct=struct('type',"orthographic",'orthographic',struct('xmag',xmag,'ymag',ymag,'zfar',zfar,'znear',znear));
    if(~ismissing(name))
        camerastruct.name=name;
    end
    if(~isprop(gltf,'cameras'))
        gltf.addprop('cameras');
    end
    camera_idx=numel(gltf.cameras);
    gltf.cameras=[gltf.cameras;{camerastruct}];
end
