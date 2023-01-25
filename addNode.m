function node_idx=addNode(gltf,varargin)
    % Add a node.
    %
    % ADDNODE(GLTF) adds a new empty node to GLTF and returns its index.
    %
    % ADDNODE(...,'name',NAME) sets name of the node.
    %
    % ADDNODE(...,'addToScene',FALSE) prevents the new node from being
    % added to the scene.
    %
    % ADDNODE(...,'translation',TRANSLATION) sets a translation
    % transformation for the node as a XYZ vector.
    %
    % ADDNODE(...,'rotation',ROTATION) sets a rotation transformation for
    % the node as a XYZW quaternion.
    %
    % ADDNODE(...,'scale',SCALE) sets a scale transformation for the node
    % as a XYZ vector.
    %
    % ADDNODE(...,'matrix',MATRIX) sets a matrix transformation for the
    % node as a 4x4 column-major matrix.
    %
    % ADDNODE(...,'mesh',MESH_IDX) adds node with a mesh specified by the
    % index MESH_IDX.
    %
    % ADDNODE(...,'skin',SKIN) specifies the skin to use for a mesh node.
    %
    % ADDNODE(...,'children',CHILDREN) adds the nodes with indices
    % specified in the CHILDREN array as child nodes.
    %
    % ADDNODE(...,'light',LIGHT_IDX) adds node with a light specified by
    % the index LIGHT_IDX.
    %
    % ADDNODE(...,'camera',CAMERA_IDX) adds node with a camera specified by
    % the index CAMERA_IDX.
    %
    % ADDNODE(...,'weights',WEIGHTS) adds node with morph target weights
    % WEIGHTS overriding the the weights of the morph target referenced in
    % the mesh property.
    %
    % ADDNODE(...,'instancingTranslation',INSTANCINGTRANSLATION) generates
    % N instances of the mesh with translations given by the Nx3 matrix
    % INSTANCINGTRANSLATION.
    %
    % ADDNODE(...,'instancingRotation',INSTANCINGROTATION) generates N
    % instances of the mesh with rotations given by the Nx4 quaternion
    % matrix INSTANCINGROTATION.
    %
    % ADDNODE(...,'instancingScale',INSTANCINGSCALE) generates N instances
    % of the mesh with scale given by the Nx3 matrix INSTANCINGSCALE.
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
    ips.addParameter('mesh',[],@isnumeric);
    ips.addParameter('name',missing,@isstring);
    ips.addParameter('skin',[],@isnumeric);
    ips.addParameter('children',[],@isnumeric);
    ips.addParameter('translation',[],@isnumeric);
    ips.addParameter('rotation',[],@isnumeric);
    ips.addParameter('scale',[],@isnumeric);
    ips.addParameter('matrix',[],@isnumeric);
    ips.addParameter('addToScene',true,@islogical);
    ips.addParameter('light',[],@isnumeric);
    ips.addParameter('camera',[],@isnumeric);
    ips.addParameter('weights',[],@isnumeric);
    ips.addParameter('instancingTranslation',[],@isnumeric);
    ips.addParameter('instancingRotation',[],@isnumeric);
    ips.addParameter('instancingScale',[],@isnumeric);
    ips.parse(varargin{:});
    parameters=ips.Results;
    mesh=parameters.mesh;
    name=parameters.name;
    skin=parameters.skin;
    children=parameters.children;
    translation=parameters.translation;
    rotation=parameters.rotation;
    scale=parameters.scale;
    matrix=parameters.matrix;
    addToScene=parameters.addToScene;
    light=parameters.light;
    camera=parameters.camera;
    weights=parameters.weights;
    node_idx=numel(gltf.nodes);
    added=false;
    instancingTranslation=parameters.instancingTranslation;
    instancingRotation=parameters.instancingRotation;
    instancingScale=parameters.instancingScale;
    if(~isempty(children))
        gltf.nodes{node_idx+1}.children=GLTF.toCells(children);
        added=true;
    end
    if(~ismissing(name))
        gltf.nodes{node_idx+1}.name=name;
        added=true;
    end
    if(~isempty(mesh))
        gltf.nodes{node_idx+1}.mesh=mesh;
        added=true;
    end
    if(~isempty(light))
        gltf.nodes{node_idx+1}.extensions=struct('KHR_lights_punctual',struct('light',light));
        added=true;
    end
    if(~isempty(camera))
        gltf.nodes{node_idx+1}.camera=camera;
        added=true;
    end
    if(~isempty(translation))
        gltf.nodes{node_idx+1}.translation=translation;
        added=true;
    end
    if(~isempty(rotation))
        gltf.nodes{node_idx+1}.rotation=rotation;
        added=true;
    end
    if(~isempty(scale))
        gltf.nodes{node_idx+1}.scale=scale;
        added=true;
    end
    if(~isempty(skin))
        gltf.nodes{node_idx+1}.skin=skin;
        added=true;
    end
    if(and(~isempty(matrix),and(and(isempty(translation),isempty(rotation)),isempty(scale))))
        gltf.nodes{node_idx+1}.matrix=matrix(:);
        added=true;
    end
    if(~isempty(weights))
        gltf.nodes{node_idx+1}.weights=weights;
        added=true;
    end
    if(or(or(~isempty(instancingTranslation),~isempty(instancingRotation)),~isempty(instancingScale)))
        gltf.addExtension("EXT_mesh_gpu_instancing");
        if(~isempty(instancingTranslation))
            gltf.nodes{node_idx+1}.extensions.EXT_mesh_gpu_instancing.attributes.TRANSLATION=gltf.addBinaryData(instancingTranslation,"FLOAT","VEC3",true,"ARRAY_BUFFER");
        end
        if(~isempty(instancingRotation))
            gltf.nodes{node_idx+1}.extensions.EXT_mesh_gpu_instancing.attributes.ROTATION=gltf.addBinaryData(instancingRotation,"FLOAT","VEC4",true,"ARRAY_BUFFER");
        end
        if(~isempty(instancingScale))
            gltf.nodes{node_idx+1}.extensions.EXT_mesh_gpu_instancing.attributes.SCALE=gltf.addBinaryData(instancingScale,"FLOAT","VEC3",true,"ARRAY_BUFFER");
        end
        added=true;
    end
    if(~added)
        gltf.nodes{node_idx+1}=struct;
    end
    if(addToScene)
        if(isempty(gltf.scenes{1}.nodes))
            gltf.scenes{1}.nodes=num2cell(node_idx);
        else
            gltf.scenes{1}.nodes=[gltf.scenes{1}.nodes(:);num2cell(node_idx)]';
        end
    end
end
