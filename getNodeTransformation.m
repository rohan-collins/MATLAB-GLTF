function mat=getNodeTransformation(gltf,node_idx)
    % Get the global transformation of a node.
    %
    % GETNODETRANSFORMATION(GLTF,NODE_IDX) returns the global transform of
    % the node specified by index NODE_IDX.
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
    pred=gltf.nodeTree();
    pred=pred(node_idx+1);
    if(pred==0)
        mat=eye(4);
    else
        mat=gltf.getNodeTransformation(pred-1);
    end
    instancing=false;
    if(isfield(gltf.nodes{node_idx+1},'extensions'))
        if(isfield(gltf.nodes{node_idx+1}.extensions,'EXT_mesh_gpu_instancing'))
            instancing=true;
        end
    end
    if(and(~instancing,isfield(gltf.nodes{node_idx+1},'matrix')))
        mat=reshape(gltf.nodes{node_idx+1}.matrix,4,4)*mat;
    elseif(instancing)
        if(isfield(gltf.nodes{node_idx+1}.extensions.EXT_mesh_gpu_instancing.attributes,'SCALE'))
            s=gltf.getAccessor(gltf.nodes{node_idx+1}.extensions.EXT_mesh_gpu_instancing.attributes.SCALE);
            s=cell2mat(permute(cellfun(@(x)diag([x(:);1]),mat2cell(s,ones(size(s,1),1),3),'UniformOutput',false),[2 3 1]));
            mat=pagemtimes(s,mat);
        end
        if(isfield(gltf.nodes{node_idx+1}.extensions.EXT_mesh_gpu_instancing.attributes,'ROTATION'))
            q=gltf.getAccessor(gltf.nodes{node_idx+1}.extensions.EXT_mesh_gpu_instancing.attributes.ROTATION);
            r=cell2mat(permute(cellfun(@(x)[GLTF.Q2PreR(x) zeros(3,1);zeros(1,3) 1],mat2cell(q,ones(size(q,1),1),4),'UniformOutput',false),[2 3 1]));
            mat=pagemtimes(r,mat);
        end
        if(isfield(gltf.nodes{node_idx+1}.extensions.EXT_mesh_gpu_instancing.attributes,'TRANSLATION'))
            t=gltf.getAccessor(gltf.nodes{node_idx+1}.extensions.EXT_mesh_gpu_instancing.attributes.TRANSLATION);
            t=cell2mat(permute(cellfun(@(x)[eye(3) x(:);zeros(1,3) 1],mat2cell(t,ones(size(t,1),1),3),'UniformOutput',false),[2 3 1]));
            mat=pagemtimes(t,mat);
        end
        if(isfield(gltf.nodes{node_idx+1},'scale'))
            mat=pagemtimes(diag([gltf.nodes{node_idx+1}.scale' 1]),mat);
        end
        if(isfield(gltf.nodes{node_idx+1},'rotation'))
            mat=pagemtimes([GLTF.Q2PreR(gltf.nodes{node_idx+1}.rotation) [0;0;0];0 0 0 1],mat);
        end
        if(isfield(gltf.nodes{node_idx+1},'translation'))
            mat=pagemtimes([eye(3) gltf.nodes{node_idx+1}.translation(:);0 0 0 1],mat);
        end
    else
        if(isfield(gltf.nodes{node_idx+1},'scale'))
            mat=diag([gltf.nodes{node_idx+1}.scale' 1])*mat;
        end
        if(isfield(gltf.nodes{node_idx+1},'rotation'))
            mat=[GLTF.Q2PreR(gltf.nodes{node_idx+1}.rotation) [0;0;0];0 0 0 1]*mat;
        end
        if(isfield(gltf.nodes{node_idx+1},'translation'))
            mat=[eye(3) gltf.nodes{node_idx+1}.translation(:);0 0 0 1]*mat;
        end
    end
end
