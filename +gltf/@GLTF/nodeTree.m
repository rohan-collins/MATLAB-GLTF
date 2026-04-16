function [pred,isMesh,hasSkin]=nodeTree(obj)
    % Get the node hierarchy.
    %
    % NODETREE(OBJ) returns the tree of node hierarchy in GLTF. This is
    % given as the index of the parent for each node. Root nodes have 0 as
    % the index of the parent node. The second output is a boolean array of
    % whether the node or any of its descendents are mesh nodes. The third output is a boolean array of whether the node has a skin attached.
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
    pred=zeros(numel(obj.nodes),1);
    isMesh=false(numel(obj.nodes),1);
    hasSkin=false(numel(obj.nodes),1);
    for i=1:numel(obj.nodes)
        if(isfield(obj.nodes{i},'children'))
            pred(cell2mat(obj.nodes{i}.children)+1)=i;
        end
        if(isfield(obj.nodes{i},'mesh'))
            isMesh(i)=true;
        end
        if(isfield(obj.nodes{i},'skin'))
            hasSkin(i)=true;
        end
    end
    for i=1:numel(obj.nodes)
        oldMesh=isMesh;
        for j=find(oldMesh)'
            if(pred(j)>0)
                isMesh(pred(j))=true;
            end
        end
        if(all(oldMesh==isMesh))
            break;
        end
    end
end
