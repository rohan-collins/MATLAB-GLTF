function addMorphTarget(gltf,mesh_idx,V,varargin)
    % Add a target for morphing animation.
    %
    % ADDMORPHTARGET(GLTF,MESH_IDX,V) adds a morph target to the first
    % primitive in the mesh specified by MESH_IDX, with vertices specified
    % by V. V is an Nx3 array of XYZ vectors.
    %
    % ADDMORPHTARGET(...,'NORMAL',N) adds N as the vertex normals for the
    % mesh. N is an Nx3 array of XYZ vectors.
    %
    % ADDMORPHTARGET(...,'TANGENT',T) adds T as the vertex tangents for the
    % mesh. T is an Nx3 array of XYZW vectors, where W specifies the
    % handedness of the coordinate system used (+1 for NTB frame, -1 for
    % TNB frame).
    %
    % ADDMORPHTARGET(...,'weight',W) specifies the morph weight for the
    % traget. The default weight is 0.
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
    ips.addParameter('weight',0,@isnumeric);
    ips.addParameter('NORMAL',[],@isnumeric);
    ips.addParameter('TANGENT',[],@isnumeric);
    ips.parse(varargin{:});

    addTargetToPrimitive(gltf,mesh_idx,0,V,varargin{:});
end
