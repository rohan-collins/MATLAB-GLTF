function bufferView=addBufferView(gltf,data,componentType,target)
    % Add bufferView with binary data to the model.
    %
    % ADDBUFFERVIEW(GLTF,DATA,COMPONENTTYPE,TARGET) adds binary data DATA
    % to GLTF and returns its accessor index. COMPONENTTYPE specifies the
    % OpenGL component type of the data and needs to be one of the
    % following (with the corresponding MATLAB data class):
    %   "BYTE":             INT8
    %   "UNSIGNED_BYTE":	UINT8
    %   "SHORT":            INT16
    %   "UNSIGNED_SHORT":   UINT16
    %   "UNSIGNED_INT":	    UINT32
    %   "FLOAT":            SINGLE
    % TARGET specifies the intended GPU buffer tupe to use with the
    % associated buffer view as one of the following:
    %   "ARRAY_BUFFER":             Used for weights, time inputs, vectors,
    %                               matrices, etc.
    %   "ELEMENT_ARRAY_BUFFER ":    Used for indices etc.
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
    componentType_str=["BYTE","UNSIGNED_BYTE","SHORT","UNSIGNED_SHORT","UNSIGNED_INT","FLOAT","BINARY"];
    componentType_Fcn={ @int8,         @uint8, @int16,         @uint16,       @uint32,@single,   @(x)x};
    componentTypeSize=[     1,              1,      2,               2,             4,      4,        0];
    target_num=[         34962,                 34963];
    target_str=["ARRAY_BUFFER","ELEMENT_ARRAY_BUFFER"];
    componentType=upper(componentType);
    GLTF.validateString(componentType,componentType_str);
    if(nargin<4)
        target=[];
    else
        GLTF.validateString(target,target_str);
        target=target_num(target_str==target);
    end
    isBinary=strcmpi(componentType,"BINARY");
    byteCount=componentTypeSize(componentType_str==componentType);
    castFcn=componentType_Fcn{componentType_str==componentType};
    bufferView=numel(gltf.bufferViews);
    bufferCount=numel(gltf.buffers);
    if(bufferCount==0)
        gltf.buffers{1}=[];
        bufferOffset=0;
        bufferCount=1;
    else
        bufferOffset=numel(gltf.buffers{bufferCount});
    end
    gltf.bufferViews{bufferView+1}.buffer=uint32(bufferCount-1);
    gltf.bufferViews{bufferView+1}.byteOffset=uint32(bufferOffset);
    if(~isempty(target))
        gltf.bufferViews{bufferView+1}.target=uint32(target);
    end
    if(isBinary)
        gltf.bufferViews{bufferView+1}.byteLength=uint32(numel(data));
        gltf.buffers{bufferCount}=[gltf.buffers{bufferCount};data(:)];
    else
        gltf.bufferViews{bufferView+1}.byteLength=uint32(numel(data)*byteCount);
        binData=typecast(castFcn(reshape(data',1,[])),'uint8');
        gltf.buffers{bufferCount}=[gltf.buffers{bufferCount};binData(:)];
    end
end
