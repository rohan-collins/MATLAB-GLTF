function addTargetToPrimitive(gltf,mesh_idx,primitive_idx,V,varargin)
    % Add a primitive target for morphing animation.
    %
    % ADDTARGETTOPRIMITIVE(GLTF,MESH_IDX,PRIMITIVE_IDX,V) adds a morph
    % target to the mesh primitive specified by MESH_IDX and PRIMITIVE_IDX,
    % with vertices specified by V. V is an Nx3 array of XYZ vectors.
    %
    % ADDTARGETTOPRIMITIVE(...,'NORMAL',N) adds N as the vertex normals for
    % the mesh. N is an Nx3 array of XYZ vectors.
    %
    % ADDTARGETTOPRIMITIVE(...,'TANGENT',T) adds T as the vertex tangents
    % for the mesh. T is an Nx3 array of XYZW vectors, where W specifies
    % the handedness of the coordinate system used (+1 for NTB frame, -1
    % for TNB frame).
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
    ips.addParameter('weight',[],@isnumeric);
    ips.addParameter('NORMAL',[],@isnumeric);
    ips.addParameter('TANGENT',[],@isnumeric);
    ips.parse(varargin{:});
    parameters=ips.Results;
    N=parameters.NORMAL;
    T=parameters.TANGENT;
    weight=parameters.weight;
    position=addBinaryData(gltf,V,"FLOAT","VEC3",true,"ARRAY_BUFFER");
    targets=struct('POSITION',position);
    if(~isempty(N))
        targets.NORMAL=addBinaryData(gltf,N,"FLOAT","VEC3",true,"ARRAY_BUFFER");
    end
    if(~isempty(T))
        targets.TANGENT=addBinaryData(gltf,T(:,1:3),"FLOAT","VEC",true,"ARRAY_BUFFER");
    end
    if(isfield(gltf.meshes{mesh_idx+1}.primitives{primitive_idx+1},'targets'))
        gltf.meshes{mesh_idx+1}.primitives{primitive_idx+1}.targets=[gltf.meshes{mesh_idx+1}.primitives{primitive_idx+1}.targets targets];
        if(~isempty(weight)&& isfield(gltf.meshes{mesh_idx+1},'weights') && ~isempty(gltf.meshes{mesh_idx+1}.weights))
            gltf.meshes{mesh_idx+1}.weights=[gltf.meshes{mesh_idx+1}.weights;{weight}];
        elseif(isfield(gltf.meshes{mesh_idx+1},'weights') && ~isempty(gltf.meshes{mesh_idx+1}.weights))
            gltf.meshes{mesh_idx+1}.weights=[gltf.meshes{mesh_idx+1}.weights;{weight}];
        elseif(~isempty(weight))
            gltf.meshes{mesh_idx+1}.weights=repmat({0},1,numel(gltf.meshes{mesh_idx+1}.primitives{primitive_idx+1}.targets)+1);
        end
    else
        gltf.meshes{mesh_idx+1}.primitives{primitive_idx+1}.targets={targets};
        if(~isempty(weight))
            gltf.meshes{mesh_idx+1}.weights=num2cell(weight);
        end
    end
end
