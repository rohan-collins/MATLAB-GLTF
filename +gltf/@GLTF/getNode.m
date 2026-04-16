function [node,library_geometries,library_controllers,node_list]=getNode(obj,documentNode,library_geometries,library_controllers,node_id,node_list,normals,tangents,binormals)
    % GETNODE is a helper function for writing COLLADA files.
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
    if(and(isfield(obj.nodes{node_id},'children'),isfield(obj.nodes{node_id},'mesh')))
        node=documentNode.createElement("node");
        node.setAttribute("id","node_"+string(node_id));
        [childNode,library_geometries,library_controllers]=obj.getMeshNode(documentNode,library_geometries,library_controllers,node_id,normals,tangents,binormals);
        childNode.setAttribute("id",string(childNode.getAttribute("id"))+"_mesh");
        node.appendChild(childNode);
        [~,isMesh]=obj.nodeTree();
        for i=cell2mat(obj.nodes{node_id}.children)+1
            if(isMesh(i))
                [childNode,library_geometries,library_controllers,node_list]=obj.getNode(documentNode,library_geometries,library_controllers,i,node_list,normals,tangents,binormals);
                node.appendChild(childNode);
            end
        end
    elseif(isfield(obj.nodes{node_id},'children'))
        node=documentNode.createElement("node");
        node.setAttribute("id","node_"+string(node_id));
        for i=cell2mat(obj.nodes{node_id}.children)+1
            [childNode,library_geometries,library_controllers,node_list]=obj.getNode(documentNode,library_geometries,library_controllers,i,node_list,normals,tangents,binormals);
            node.appendChild(childNode);
        end
    elseif(isfield(obj.nodes{node_id},'mesh'))
        [node,library_geometries,library_controllers,node_list]=obj.getMeshNode(documentNode,library_geometries,library_controllers,node_id,node_list,normals,tangents,binormals);
    else
        node=documentNode.createElement("node");
        node.setAttribute("id","node_"+string(node_id));
    end
    if(isfield(obj.nodes{node_id},'matrix'))
        matrix=documentNode.createElement("matrix");
        matrix.setAttribute("sid","matrix");
        matrix.appendChild(documentNode.createTextNode(strip(sprintf(gltf.GLTF.formatSpec_float(),reshape(reshape(obj.nodes{node_id}.matrix,4,4)',[],1)'))));
        node.appendChild(matrix);
    else
        if(isfield(obj.nodes{node_id},'translation'))
            translate=documentNode.createElement("translate");
            translate.setAttribute("sid","translate");
            translate.appendChild(documentNode.createTextNode(strip(sprintf(gltf.GLTF.formatSpec_float(),obj.nodes{node_id}.translation))));
            node.appendChild(translate);
        end
        if(isfield(obj.nodes{node_id},'rotation'))
            rotate=documentNode.createElement("rotate");
            rotate.setAttribute("sid","rotate");
            rotate.appendChild(documentNode.createTextNode(strip(sprintf(gltf.GLTF.formatSpec_float(),gltf.GLTF.Q2AxisAngle(obj.nodes{node_id}.rotation)))));
            node.appendChild(rotate);
        end
        if(isfield(obj.nodes{node_id},'scale'))
            scale=documentNode.createElement("scale");
            scale.setAttribute("sid","scale");
            scale.appendChild(documentNode.createTextNode(strip(sprintf(gltf.GLTF.formatSpec_float(),obj.nodes{node_id}.scale))));
            node.appendChild(scale);
        end
    end
    node_list{node_id}=node;
end
