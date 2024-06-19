    function accessor_idx=addBinaryData(gltf,data,componentType,dataCount,minmax,target)
    % Add binary data to the model.
    %
    % ADDBINARYDATA(GLTF,DATA,COMPONENTTYPE,DATACOUNT,MINMAX) adds binary
    % data DATA to GLTF and returns its accessor index. COMPONENTTYPE
    % specifies the OpenGL component type of the data and needs to be one
    % of the following (with the corresponding MATLAB data class):
    % "BYTE":           INT8
    % "UNSIGNED_BYTE":	UINT8
    % "SHORT":          INT16
    % "UNSIGNED_SHORT":	UINT16
    % "UNSIGNED_INT":	UINT32
    % "FLOAT":          SINGLE
    % DATACOUNT specifies the dimensions of the data as one of the
    % following:
    % "SCALAR": Nx1, used for indices, weights, time inputs, etc.
    % "VEC2":   Nx2, used for texture coordinates, etc.
    % "VEC3":   Nx3, used for positions, normals, RGB vertex colours,
    %           translation, scale, etc.
    % "VEC4":   Nx4, used for tangents, rotation, RGBA vertex
    %           colours,joints, weights, etc.
    % "MAT4":   4x4xN in column-major order, used for matrix
    %           transformations, inverse bind matrices, etc.
    % "MAT2":   2x2xN in column-major order, not currently used.
    % "MAT3":   3x3xN in column-major order, not currently used.
    % MINMAX is a boolean variable that specifies whether minimum and
    % maximum values should be included for the accessor. Minimum and
    % maximum values are only included for data of type "SCALAR", "VEC2",
    % "VEC3", or "VEC4".
    % TARGET specifies the intended GPU buffer tupe to use with the
    % associated buffer view as one of the following:
    % "ARRAY_BUFFER":           Used for weights, time inputs, vectors,
    %                           matrices, etc.
    % "ELEMENT_ARRAY_BUFFER ":  Used for indices etc.
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
    componentType_num=[  5120,           5121,   5122,            5123,          5125,   5126];
    componentType_str=["BYTE","UNSIGNED_BYTE","SHORT","UNSIGNED_SHORT","UNSIGNED_INT","FLOAT"];
    componentType_Fcn={ @int8,         @uint8, @int16,         @uint16,       @uint32,@single};
    componentTypeSize=[     1,              1,      2,               2,             4,      4];
    target_num=[         34962,                 34963];
    target_str=["ARRAY_BUFFER","ELEMENT_ARRAY_BUFFER"];
    dataCount_str=["SCALAR","VEC2","VEC3","VEC4","MAT2","MAT3","MAT4"];
    componentType=upper(componentType);
    GLTF.validateString(componentType,componentType_str);
    dataCount=upper(dataCount);
    GLTF.validateString(dataCount,dataCount_str);
    if(nargin<6)
        target=[];
    else
        GLTF.validateString(target,target_str);
        target=target_num(target_str==target);
    end
    component=componentType_num(componentType_str==componentType);
    byteCount=componentTypeSize(componentType_str==componentType);
    castFcn=componentType_Fcn{componentType_str==componentType};
    accessor_idx=numel(gltf.accessors);
    bufferViewCount=numel(gltf.bufferViews);
    bufferCount=numel(gltf.buffers);
    if(bufferCount==0)
        gltf.buffers{1}=[];
        bufferOffset=0;
        bufferCount=1;
    else
        bufferOffset=numel(gltf.buffers{bufferCount});
    end
    gltf.accessors{accessor_idx+1}.bufferView=uint32(bufferViewCount);
    gltf.accessors{accessor_idx+1}.componentType=component;
    if(or(or(dataCount=="MAT2",dataCount=="MAT3"),dataCount=="MAT4"))
        data=reshape(data,size(data,1)*size(data,1),size(data,3))';
    end
    if(dataCount=="SCALAR")
        gltf.accessors{accessor_idx+1}.count=uint32(numel(data));
    else
        gltf.accessors{accessor_idx+1}.count=uint32(size(data,1));
    end
    gltf.accessors{accessor_idx+1}.type=dataCount;
    if(minmax)
        if(dataCount=="SCALAR")
            gltf.accessors{accessor_idx+1}.max=num2cell(max(data(:)));
            gltf.accessors{accessor_idx+1}.min=num2cell(min(data(:)));
        elseif(ismember(dataCount,["VEC2","VEC3","VEC4"]))
            gltf.accessors{accessor_idx+1}.max=max(data,[],1)';
            gltf.accessors{accessor_idx+1}.min=min(data,[],1)';
        end
    end
    gltf.bufferViews{bufferViewCount+1}.buffer=uint32(bufferCount-1);
    gltf.bufferViews{bufferViewCount+1}.byteLength=uint32(numel(data)*byteCount);
    gltf.bufferViews{bufferViewCount+1}.byteOffset=uint32(bufferOffset);
    if(~isempty(target))
        gltf.bufferViews{bufferViewCount+1}.target=uint32(target);
    end
    binData=typecast(castFcn(reshape(data',1,[])),'uint8');
    gltf.buffers{bufferCount}=[gltf.buffers{bufferCount};binData(:)];
end
