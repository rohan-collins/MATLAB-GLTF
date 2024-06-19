function data=getAccessor(gltf,accessor_idx)
    % Get data referenced by an accessor.
    %
    % GETACCESSOR(GLTF,ACCESSOR_IDX) returns the data referenced by the
    % accessor with index ACCESSOR_IDX.
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
    componentType_num=[  5120,   5121,   5122,    5123,    5125,    5126];
    componentType_Cst=["int8","uint8","int16","uint16","uint32","single"];
    componentTypeSize=[     1,      1,      2,       2,       4,       4];
    dataCount_str=["SCALAR","VEC2","VEC3","VEC4","MAT2","MAT3","MAT4"];
    dataCount_num=[       1,     2,     3,     4,     4,     9,    16];
    dataCount_shp={       1,     2,     3,     4, [2 2], [3 3], [4 4]};
    accessor=gltf.accessors{accessor_idx+1};
    bufferView=gltf.bufferViews{accessor.bufferView+1};
    buffer=gltf.buffers{bufferView.buffer+1};
    num=dataCount_num(dataCount_str==string(accessor.type));
    shp=dataCount_shp{dataCount_str==string(accessor.type)};
    castFcn=componentType_Cst(componentType_num==accessor.componentType);
    componentSize=componentTypeSize(componentType_num==accessor.componentType);
    if(isfield(accessor,'byteOffset'))
        accessorOffset=uint32(accessor.byteOffset);
    else
        accessorOffset=uint32(0);
    end
    if(isfield(bufferView,'byteStride'))
        byteStride=uint32(bufferView.byteStride);
    else
        byteStride=uint32(num*componentSize);
    end
    indices=bufferView.byteOffset+accessorOffset+reshape(repmat(uint32(1:num*componentSize)',1,accessor.count)+(0:accessor.count-1)*byteStride,[],1);
    binData=buffer(indices);
    if(numel(shp)>1)
        data=reshape(typecast(binData,castFcn),[shp,accessor.count]);
    else
        data=permute(reshape(typecast(binData,castFcn),[shp,accessor.count]),[2 1 3]);
    end
    if(castFcn=="single")
        data=double(data);
    end
end
