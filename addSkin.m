function skin_idx=addSkin(gltf,joints,varargin)
    % Add a skin for skinning animation.
    %
    % ADDSKIN(GLTF,JOINTS) adds a skin with specified joints to GLTF and
    % returns its index.
    %
    % ADDSKIN(...,'name',NAME) sets name of the skin.
    %
    % ADDNODE(...,'inverseBindMatrices',INVERSEBINDMATRICES) specifies the
    % global inverse bind matrices for every joint.
    %
    % ADDNODE(...,'skeleton',SKELETON) specifies index of the node used as
    % a skeleton root.
    %
    % © Copyright 2014-2025 Rohan Chabukswar.
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
    ips.addParameter('skeleton',[],@isnumeric);
    ips.addParameter('name',missing,@isstring);
    ips.addParameter('inverseBindMatrices',[],@isnumeric);
    ips.parse(varargin{:});
    parameters=ips.Results;
    skeleton=parameters.skeleton;
    name=parameters.name;
    inverseBindMatrices=parameters.inverseBindMatrices;
    skin=struct;
    skin.joints=num2cell(joints);
    if(~isempty(skeleton))
        skin.skeleton=skeleton;
    end
    if(~ismissing(name))
        skin.name=name;
    end
    if(~isempty(inverseBindMatrices))
        skin.inverseBindMatrices=addBinaryData(gltf,inverseBindMatrices,"FLOAT","MAT4",false);
    end
    if(~isprop(gltf,'skins'))
        gltf.addprop('skins');
    end
    skin_idx=numel(gltf.skins);
    gltf.skins=[gltf.skins;{skin}];
end
