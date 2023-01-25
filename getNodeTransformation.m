function mat=getNodeTransformation(gltf,node_idx)
    % Get the global transformation of a node.
    %
    % GETNODETRANSFORMATION(GLTF,NODE_IDX) returns the global transform of
    % the node specified by index NODE_IDX.
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
    pred=gltf.nodeTree();
    pred=pred(node_idx+1);
    if(pred==0)
        mat=eye(4);
    else
        mat=gltf.getNodeTransformation(pred-1);
    end
    if(isfield(gltf.nodes{node_idx+1},'matrix'))
        mat=reshape(gltf.nodes{node_idx+1}.matrix,4,4)*mat;
    else
        if(isfield(gltf.nodes{node_idx+1},'scale'))
            mat=diag([gltf.nodes{node_idx+1}.scale' 1])*mat;
        end
        if(isfield(gltf.nodes{node_idx+1},'rotation'))
            mat=[GLTF.Q2PreR(gltf.nodes{node_idx+1}.rotation) [0;0;0];0 0 0 1]*mat;
        end
        if(isfield(gltf.nodes{node_idx+1},'translation'))
            mat=[eye(3) gltf.nodes{node_idx+1}.translation;0 0 0 1]*mat;
        end
    end
end
