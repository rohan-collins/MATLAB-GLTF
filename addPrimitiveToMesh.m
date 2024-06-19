function primitive_idx=addPrimitiveToMesh(gltf,mesh_idx,V,varargin)
    % Add a mesh primitive and returns the index.
    %
    % ADDPRIMITIVETOMESH(GLTF,MESH_IDX,V) adds a primitive to GLTF to the
    % mesh specified by MESH_IDX, with vertices specified by V and returns
    % its index. V is an Nx3 array of XYZ vectors.
    %
    % ADDPRIMITIVETOMESH(...,'indices',F) sets the indices of the vertices
    % for each triangular face.
    %
    % ADDPRIMITIVETOMESH(...,'mode',MODE) sets the mode to use for
    % interpreting indices as per OpenGL. MODE must be one of "POINTS",
    % "LINES", "LINE_LOOP", "LINE_STRIP", "TRIANGLES" (default),
    % "TRIANGLE_STRIP", or "TRIANGLE_FAN".
    %
    % ADDPRIMITIVETOMESH(...,'name',NAME) sets the name of the mesh.
    %
    % ADDPRIMITIVETOMESH(...,'material',MAT) uses the material with index
    % MAT as the material for the mesh.
    %
    % ADDPRIMITIVETOMESH(...,'NORMAL',N) adds N as the vertex normals for
    % the mesh. N is an Nx3 array of XYZ vectors.
    %
    % ADDPRIMITIVETOMESH(...,'TANGENT',T) adds T as the vertex tangents for
    % the mesh. T is an Nx3 array of XYZW vectors, where W specifies the
    % handedness of the coordinate system used (+1 for NTB frame, -1 for
    % TNB frame).
    %
    % ADDPRIMITIVETOMESH(...,'normals',TRUE) forces calculation and
    % inclusion of normals.
    %
    % ADDPRIMITIVETOMESH(...,'tangents',TRUE) forces calculation and
    % inclusion of tangents.
    %
    % ADDPRIMITIVETOMESH(...,'TEXCOORD',UV) adds UV as the vertex UV (or
    % ST) coordinates for the mesh. UV is an Nx2xM array of UV vectors.
    % Each of the M sets of coordinates is saved as TEXCOORD_0, TEXCOORD_1,
    % etc.
    %
    % ADDPRIMITIVETOMESH(...,'COLOR',C) adds C as the vertex colours for
    % the mesh. C is an Nx3xM (RGB) or Nx4xM (RGBA) array of vectors. Each
    % of the M sets of colours is saved as COLOR_0, COLOR_1, etc.
    %
    % ADDPRIMITIVETOMESH(...,'JOINTS',J) adds J as the list of joints (in
    % multiples of 4) that affect each vertex in a skinned animation. J is
    % an Nx4xM array of joint indices. Each of the M sets of 4 joints is
    % saved as JOINTS_0, JOINTS_1, etc.
    %
    % ADDPRIMITIVETOMESH(...,'WEIGHTS',W) adds W as the list of weights for
    % each vertex and joint combination. W is a norm-1 Nx4xM array. Each of
    % the M sets of 4 weights is saved as JOINTS_0, JOINTS_1, etc. Joints
    % with a weight of 0 should be set to 0.
    %
    % ADDPRIMITIVETOMESH(...,'triangulate',TRUE) forces conversion of
    % non-triangular faces to triangles. The convention used while
    % triangulating ensures that the original polygonal information can be
    % reconstructed. Polygons that cannot be decomposed into a triangle fan
    % (for example, non-convex polygons) must first be cut into ones that
    % can.
    %
    % ADDPRIMITIVETOMESH(...,'skipTest',FALSE) skips the test for
    % discarding degenerate faces.
    %
    % ADDPRIMITIVETOMESH(...,'flatShading',TRUE) forces duplication of
    % vertices for all faces.
    %
    % ADDPRIMITIVETOMESH(...,'variants',variants) adds variant materials to
    % the primitive, given as an array of structs
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
    tangents=or(tangents,~isempty(T));
    tangents=and(tangents,~isempty(texcoord));
    normals=or(normals,~isempty(N));
    normals=or(normals,tangents);
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
            texcoord=texcoord(new_idx,:);
        end
        if(~isempty(color))
            color=color(new_idx,:);
        end
        if(~isempty(joints))
            joints=joints(new_idx,:);
        end
        if(~isempty(weights))
            weights=weights(new_idx,:);
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
                texcoord=texcoord(idx,:);
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
    position=addBinaryData(gltf,V,"FLOAT","VEC3",true,"ARRAY_BUFFER");
    attributes=struct('POSITION',position);
    if(normals)
        if(isempty(N))
            if(isempty(indices))
                N=GLTF.vertexNormals(reshape(1:size(V,1),3,[])',V);
            else
                N=GLTF.vertexNormals(indices,V);
            end
        end
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
    end
    primitivestruct=struct('attributes',attributes);
    if(~isempty(indices))
        indices=addBinaryData(gltf,reshape(indices',[],1)-1,"UNSIGNED_INT","SCALAR",false,"ELEMENT_ARRAY_BUFFER");
        primitivestruct.indices=indices;
    end
    if(~isempty(mode))
       primitivestruct.mode=mode_num_values(mode_str_values==mode);
    end
    if(~isempty(material))
        primitivestruct.material=material;
    end
    if(~isempty(texcoord))
        for i=1:size(texcoord,3)
            primitivestruct.attributes.("TEXCOORD_"+string(i-1))=addBinaryData(gltf,texcoord(:,:,i),"FLOAT","VEC2",true,"ARRAY_BUFFER");
        end
    end
    if(~isempty(color))
        if(size(color,2)==3)
            for i=1:size(color,3)
                primitivestruct.attributes.("COLOR_"+string(i-1))=addBinaryData(gltf,color(:,:,i),"FLOAT","VEC3",true,"ARRAY_BUFFER");
            end
        elseif(size(color,2)==4)
            for i=1:size(color,3)
                primitivestruct.attributes.("COLOR_"+string(i-1))=addBinaryData(gltf,color(:,:,i),"FLOAT","VEC4",true,"ARRAY_BUFFER");
            end
        end
    end
    if(~isempty(joints))
        for i=1:size(joints,3)
            primitivestruct.attributes.("JOINTS_"+string(i-1))=addBinaryData(gltf,joints(:,:,i),"UNSIGNED_SHORT","VEC4",true,"ARRAY_BUFFER");
        end
    end
    if(~isempty(weights))
        for i=1:size(weights,3)
            primitivestruct.attributes.("WEIGHTS_"+string(i-1))=addBinaryData(gltf,weights(:,:,i),"FLOAT","VEC4",true,"ARRAY_BUFFER");
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
        primitivestruct.primitives{1}.extensions.KHR_materials_variants=KHR_materials_variants_struct;
    end
    primitive_idx=numel(gltf.meshes{mesh_idx+1}.primitives);
    gltf.meshes{mesh_idx+1}.primitives=[gltf.meshes{mesh_idx+1}.primitives primitivestruct];
end
