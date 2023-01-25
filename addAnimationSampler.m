function samplerstruct=addAnimationSampler(~,input,output,varargin)
    % Add an animation sampler.
    %
    % ADDANIMATIONSAMPLER(GLTF,INPUT,OUTPUT) creates and returns an
    % animation sampler for GLTF, with INPUT as the accessor index for the
    % input data, and OUTPUT as the accessor index for the output data. The
    % returned struct needs to be added to the animation using
    % ADDANIMATION, and hence the sampler index is not returned. It needs
    % to be calculated manually as the zero-based array index of the
    % sampler when passed to ADDANIMATION.
    %
    % ADDANIMATIONSAMPLER(...,'interpolation',METHOD) sets the
    % interpolation method to be used by the sampler. When specified,
    % METHOD needs to be one of "LINEAR", "STEP", or "CUBICSPLINE".
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
    ips.addParameter('interpolation',[],@(x)GLTF.validateString(x,["LINEAR","STEP","CUBICSPLINE"]));
    ips.parse(varargin{:});
    parameters=ips.Results;
    interpolation=upper(parameters.interpolation);
    samplerstruct=struct('input',input,'output',output);
    if(~isempty(interpolation))
        samplerstruct.interpolation=interpolation;
    end
end
