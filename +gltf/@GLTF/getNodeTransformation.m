function mat=getNodeTransformation(obj,node_idx)
    % Get the global transformation of a node.
    %
    % GETNODETRANSFORMATION(OBJ,NODE_IDX) returns the global transform of
    % the node specified by index NODE_IDX.
    %
    % © Copyright 2014-2026 Rohan Chabukswar.
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
    pred=obj.nodeTree();
    pred=pred(node_idx+1);
    if(pred==0)
        mat_pred=eye(4);
    else
        mat_pred=obj.getNodeTransformation(pred-1);
    end
    % if(~ismatrix(mat_pred))
    %     mat_pred=eye(4);
    % end
    instancing=false;
    if(isfield(obj.nodes{node_idx+1},'extensions'))
        if(isfield(obj.nodes{node_idx+1}.extensions,'EXT_mesh_gpu_instancing'))
            instancing=true;
        end
    end
    if(and(~instancing,isfield(obj.nodes{node_idx+1},'matrix')))
        mat=reshape(obj.nodes{node_idx+1}.matrix,4,4);
    elseif(instancing)
        mat=eye(4);
        if(isfield(obj.nodes{node_idx+1}.extensions.EXT_mesh_gpu_instancing.attributes,'SCALE'))
            s=obj.getAccessor(obj.nodes{node_idx+1}.extensions.EXT_mesh_gpu_instancing.attributes.SCALE);
            s=cell2mat(permute(cellfun(@(x)diag([x(:);1]),mat2cell(s,ones(size(s,1),1),3),'UniformOutput',false),[2 3 1]));
            mat=pagemtimes(s,mat);
        end
        if(isfield(obj.nodes{node_idx+1}.extensions.EXT_mesh_gpu_instancing.attributes,'ROTATION'))
            q=obj.getAccessor(obj.nodes{node_idx+1}.extensions.EXT_mesh_gpu_instancing.attributes.ROTATION);
            r=cell2mat(permute(cellfun(@(x)[gltf.GLTF.Q2PreR(x) zeros(3,1);zeros(1,3) 1],mat2cell(q,ones(size(q,1),1),4),'UniformOutput',false),[2 3 1]));
            mat=pagemtimes(r,mat);
        end
        if(isfield(obj.nodes{node_idx+1}.extensions.EXT_mesh_gpu_instancing.attributes,'TRANSLATION'))
            t=obj.getAccessor(obj.nodes{node_idx+1}.extensions.EXT_mesh_gpu_instancing.attributes.TRANSLATION);
            t=cell2mat(permute(cellfun(@(x)[eye(3) x(:);zeros(1,3) 1],mat2cell(t,ones(size(t,1),1),3),'UniformOutput',false),[2 3 1]));
            mat=pagemtimes(t,mat);
        end
        mat=pagemtimes(mat_pred,mat);
    else
        mat=eye(4);
        if(isfield(obj.nodes{node_idx+1},'scale'))
            mat=diag([obj.nodes{node_idx+1}.scale' 1])*mat;
        end
        if(isfield(obj.nodes{node_idx+1},'rotation'))
            mat=[gltf.GLTF.Q2PreR(obj.nodes{node_idx+1}.rotation) [0;0;0];0 0 0 1]*mat;
        end
        if(isfield(obj.nodes{node_idx+1},'translation'))
            mat=[eye(3) obj.nodes{node_idx+1}.translation(:);0 0 0 1]*mat;
        end
        mat=pagemtimes(mat_pred,mat);
        % mat=mat_pred*mat;
    end
end
