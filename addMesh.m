function mesh_idx=addMesh(gltf,V,varargin)
    % Add a mesh.
    %
    % ADDMESH(GLTF,V) adds a mesh primitive to GLTF with vertices specified
    % by V and returns its index. V is an Nx3 array of XYZ vectors.
    %
    % ADDMESH(...,'indices',F) sets the indices of the vertices for each
    % triangular face.
    %
    % ADDMESH(...,'mode',MODE) sets the mode to use for interpreting
    % indices as per OpenGL. MODE must be one of "POINTS", "LINES",
    % "LINE_LOOP", "LINE_STRIP", "TRIANGLES" (default), "TRIANGLE_STRIP",
    % or "TRIANGLE_FAN".
    %
    % ADDMESH(...,'name',NAME) sets the name of the mesh.
    %
    % ADDMESH(...,'material',MAT) uses the material with index MAT as the
    % material for the mesh.
    %
    % ADDMESH(...,'NORMAL',N) adds N as the vertex normals for the mesh. N
    % is an Nx3 array of XYZ vectors.
    %
    % ADDMESH(...,'TANGENT',T) adds T as the vertex tangents for the mesh.
    % T is an Nx3 array of XYZW vectors, where W specifies the handedness
    % of the coordinate system used (+1 for NTB frame, -1 for TNB frame).
    %
    % ADDMESH(...,'normals',TRUE) forces calculation and inclusion of
    % normals.
    %
    % ADDMESH(...,'tangents',TRUE) forces calculation and inclusion of
    % tangents.
    %
    % ADDMESH(...,'TEXCOORD',UV) adds UV as the vertex UV (or ST)
    % coordinates for the mesh. UV is an Nx2xM array of UV vectors. Each of
    % the M sets of coordinates is saved as TEXCOORD_0, TEXCOORD_1, etc.
    %
    % ADDMESH(...,'COLOR',C) adds C as the vertex colours for the mesh. C
    % is an Nx3xM (RGB) or Nx4xM (RGBA) array of vectors. Each of the M
    % sets of colours is saved as COLOR_0, COLOR_1, etc.
    %
    % ADDMESH(...,'JOINTS',J) adds J as the list of joints (in multiples of
    % 4) that affect each vertex in a skinned animation. J is an Nx4xM
    % array of joint indices. Each of the M sets of 4 joints is saved as
    % JOINTS_0, JOINTS_1, etc.
    %
    % ADDMESH(...,'WEIGHTS',W) adds W as the list of weights for each
    % vertex and joint combination. W is a norm-1 Nx4xM array. Each of the
    % M sets of 4 weights is saved as JOINTS_0, JOINTS_1, etc. Joints with
    % a weight of 0 should be set to 0.
    %
    % ADDMESH(...,'triangulate',TRUE) forces conversion of non-triangular
    % faces to triangles. The convention used while triangulating ensures
    % that the original polygonal information can be reconstructed.
    % Polygons that cannot be decomposed into a triangle fan (for example,
    % non-convex polygons) must first be cut into ones that can.
    %
    % ADDMESH(...,'skipTest',FALSE) forces the test for discarding
    % degenerate faces.
    %
    % ADDMESH(...,'flatShading',TRUE) forces duplication of vertices for
    % all faces.
    %
    % ADDMESH(...,'variants',variants) adds variant materials to the mesh,
    % given as an array of structs
    % ('material',material_idx,'variants',list_of_variant_indices).
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
    mode_str_values=["POINTS","LINES","LINE_LOOP","LINE_STRIP","TRIANGLES","TRIANGLE_STRIP","TRIANGLE_FAN"];
    mode_num_values=[       0,      1,          2,           3,          4,               5,             6];
    ips=inputParser;
    ips.addParameter('indices',[],@isnumeric);
    ips.addParameter('name',missing,@isstring);
    ips.addParameter('skipTest',true,@islogical);
    ips.addParameter('mode',[],@(x)GLTF.validateString(x,mode_str_values));
    ips.addParameter('normals',false,@islogical);
    ips.addParameter('tangents',false,@islogical);
    ips.addParameter('flatShading',false,@islogical);
    ips.addParameter('NORMAL',[],@isnumeric);
    ips.addParameter('TANGENT',[],@isnumeric);
    ips.addParameter('TEXCOORD',[],@isnumeric);
    ips.addParameter('COLOR',[],@isnumeric);
    ips.addParameter('JOINTS',[],@isnumeric);
    ips.addParameter('WEIGHTS',[],@isnumeric);
    ips.addParameter('material',[],@isnumeric);
    ips.addParameter('triangulate',false,@islogical);
    ips.addParameter('variants',[],@isstruct);
    ips.parse(varargin{:});
    parameters=ips.Results;
    indices=parameters.indices;
    name=parameters.name;
    mode=upper(parameters.mode);
    N=parameters.NORMAL;
    T=parameters.TANGENT;
    texcoord=parameters.TEXCOORD;
    joints=parameters.JOINTS;
    weights=parameters.WEIGHTS;
    color=parameters.COLOR;
    normals=parameters.normals;
    tangents=parameters.tangents;
    flatShading=parameters.flatShading;
    material=parameters.material;
    skipTest=parameters.skipTest;
    triangulate=parameters.triangulate;
    variants=parameters.variants;
    tangents=or(and(tangents,~isempty(texcoord)),~isempty(T));
    normals=or(or(normals,~isempty(N)),tangents);
    if(and(size(indices,2)>3,triangulate))
        indices=GLTF.toTriangles(indices);
    end
    if(size(indices,2)<3)
        skipTest=true;
    end
    if(and(flatShading,~isempty(indices)))
        V2=V(reshape(indices',[],1),:);
        F2=reshape(1:numel(indices),3,[])';
        Nv2=GLTF.vertexNormals(F2,V2);
        VN2=[V2 Nv2];
        [VN3,ia,ic]=uniquetol(VN2,'ByRows',true);
        V=VN3(:,1:3);
        old_indices=indices;
        indices=ic(F2);
        new_idx=old_indices';
        new_idx=new_idx(ia);
        if(~isempty(texcoord))
            texcoord=texcoord(new_idx,:,:);
        end
        if(~isempty(color))
            color=color(new_idx,:,:);
        end
        if(~isempty(joints))
            joints=joints(new_idx,:,:);
        end
        if(~isempty(weights))
            weights=weights(new_idx,:,:);
        end
    end
    if(~skipTest)
        if(isempty(indices))
            testNormals=GLTF.vertexNormals(reshape(1:size(V,1),3,[])',V);
            V=V(~any(isnan(testNormals),2),:);
        else
            testNormals=GLTF.faceNormals(indices,V);
            indices=indices(~any(isnan(testNormals),2),:);
            [~,indices,idx]=GLTF.vertexNormals(indices,V);
            V=V(idx,:);
            if(and(normals,~isempty(N)))
                N=N(idx,:);
            end
            if(and(tangents,~isempty(T)))
                T=T(idx,:);
            end
            if(texcoord)
                texcoord=texcoord(idx,:,:);
            end
            if(color)
                color=color(idx,:,:);
            end
            if(joints)
                joints=joints(idx,:,:);
            end
            if(weights)
                weights=weights(idx,:,:);
            end
        end
    end
    if(normals)
        if(isempty(N))
            if(isempty(indices))
                N=GLTF.vertexNormals(reshape(1:size(V,1),3,[])',V);
            else
                [N,indices,idx]=GLTF.vertexNormals(indices,V);
                V=V(idx,:);
            end
            if(and(tangents,~isempty(T)))
                T=T(idx,:);
            end
            if(~isempty(texcoord))
                texcoord=texcoord(idx,:,:);
            end
            if(color)
                color=color(idx,:,:);
            end
            if(~isempty(joints))
                joints=joints(idx,:,:);
            end
            if(~isempty(weights))
                weights=weights(idx,:,:);
            end
        end
        position=addBinaryData(gltf,V,"FLOAT","VEC3",true,"ARRAY_BUFFER");
        attributes=struct('POSITION',position);
        attributes.NORMAL=addBinaryData(gltf,N,"FLOAT","VEC3",true,"ARRAY_BUFFER");
        if(tangents)
            if(isempty(T))
                texcoord_temp=texcoord(:,:,1);
                if(isempty(indices))
                    T=GLTF.vertexTangents(reshape(1:size(V,1),3,[])',V,texcoord_temp);
                else
                    T=GLTF.vertexTangents(indices,V,texcoord_temp);
                end
            else
                if(size(T,2)==3)
                    T=[T ones(size(T,1),1)];
                end
            end
            attributes.TANGENT=addBinaryData(gltf,T,"FLOAT","VEC4",true,"ARRAY_BUFFER");
        end
    else
        position=addBinaryData(gltf,V,"FLOAT","VEC3",true,"ARRAY_BUFFER");
        attributes=struct('POSITION',position);
    end
    meshstruct=struct('primitives',cell(1,1));
    meshstruct.primitives{1}.attributes=attributes;
    if(~isempty(indices))
        indices=addBinaryData(gltf,reshape(indices',[],1)-1,"UNSIGNED_INT","SCALAR",false,"ELEMENT_ARRAY_BUFFER");
        meshstruct.primitives{1}.indices=indices;
    end
    if(~isempty(mode))
        meshstruct.primitives{1}.mode=mode_num_values(mode_str_values==mode);
    end
    if(~ismissing(name))
        meshstruct.name=name;
    end
    if(~isempty(material))
        meshstruct.primitives{1}.material=material;
    end
    if(~isempty(texcoord))
        for i=1:size(texcoord,3)
            meshstruct.primitives{1}.attributes.("TEXCOORD_"+string(i-1))=addBinaryData(gltf,texcoord(:,:,i),"FLOAT","VEC2",true,"ARRAY_BUFFER");
        end
    end
    if(~isempty(color))
        if(size(color,2)==3)
            for i=1:size(color,3)
                meshstruct.primitives{1}.attributes.("COLOR_"+string(i-1))=addBinaryData(gltf,color(:,:,i),"FLOAT","VEC3",true,"ARRAY_BUFFER");
            end
        elseif(size(color,2)==4)
            for i=1:size(color,3)
                meshstruct.primitives{1}.attributes.("COLOR_"+string(i-1))=addBinaryData(gltf,color(:,:,i),"FLOAT","VEC4",true,"ARRAY_BUFFER");
            end
        end
    end
    if(~isempty(joints))
        for i=1:size(joints,3)
            meshstruct.primitives{1}.attributes.("JOINTS_"+string(i-1))=addBinaryData(gltf,joints(:,:,i),"UNSIGNED_SHORT","VEC4",true,"ARRAY_BUFFER");
        end
    end
    if(~isempty(weights))
        for i=1:size(weights,3)
            meshstruct.primitives{1}.attributes.("WEIGHTS_"+string(i-1))=addBinaryData(gltf,weights(:,:,i),"FLOAT","VEC4",true,"ARRAY_BUFFER");
        end
    end
    if(~isempty(variants))
        addExtension(gltf,"KHR_materials_variants");
        KHR_materials_variants_struct=struct('mappings',repmat(struct('material',[],'variants',[]),0));
        max_var_idx=-Inf;
        for var_idx=1:numel(variants)
            max_var_idx=max(max_var_idx,max(variants(var_idx).variants));
            KHR_materials_variants_struct.mappings(var_idx)=struct('material',variants(var_idx).material,'variants',[]);
            KHR_materials_variants_struct.mappings(var_idx).variants=GLTF.toCells(variants(var_idx).variants);
        end
        if(~isprop(gltf,'extensions'))
            addprop(gltf,'extensions');
        end
        if(isfield(gltf.extensions,'KHR_materials_variants') && isfield(gltf.extensions.KHR_materials_variants,'variants'))
            start_idx=numel(gltf.extensions.KHR_materials_variants.variants)-1;
            gltf.extensions.KHR_materials_variants.variants=[gltf.extensions.KHR_materials_variants.variants repmat(struct(),1,max_var_idx-start_idx)];
        else
            gltf.extensions.KHR_materials_variants.variants=repmat(struct(),1,max_var_idx+1);
        end
        meshstruct.primitives{1}.extensions.KHR_materials_variants=KHR_materials_variants_struct;
    end
    mesh_idx=numel(gltf.meshes);
    gltf.meshes=[gltf.meshes meshstruct];
end
