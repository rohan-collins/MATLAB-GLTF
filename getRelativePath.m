function [relative1,relative2]=getRelativePath(filename1,filename2)
    % Find relative paths between two filenames.
    %
    % GETRELATIVEPATH(FILENAME1,FILENAME2) returns the relative paths
    % between the two filenames.
    %
    % © Copyright 2014-2024 Rohan Chabukswar
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
    [filepath1,name1,ext1]=fileparts(filename1);
    [filepath2,name2,ext2]=fileparts(filename2);
    p1=split(filepath1,filesep);
    p2=split(filepath2,filesep);
    if(filesep=="\")
        a1=contains(p1(1),":");
        a2=contains(p2(1),":");
    elseif(filesep=="/")
        a1=p1(1)=="";
        a2=p2(1)=="";
    end
    if(and(~a1,a2))
        temp=find(p1~="..",1,"first");
        p1=[p2(1:end-(temp-1));p1(temp:end)];
    elseif(and(a1,~a2))
        temp=find(p2~="..",1,"first");
        p2=[p1(1:end-(temp-1));p2(temp:end)];
    elseif(and(~a1,~a2))
        temp1=find(p1~="..",1,"first");
        temp2=find(p2~="..",1,"first");
        temp0=max(temp1,temp2);
        PWDlist="PWD"+(temp0:-1:1)';
        p1new=[PWDlist;p2(1:end-(temp1-1));p1(temp1:end)];
        p2new=[PWDlist;p1(1:end-(temp2-1));p2(temp2:end)];
        p1=resolveParents(p1new);
        p2=resolveParents(p2new);
    end
    lastcommon=find(p1(1:min(numel(p1),numel(p2)))==p2(1:min(numel(p1),numel(p2))),1,"last");
    if(or(and(filesep=="\",isempty(lastcommon)),and(filesep=="/",lastcommon==1)))
        relative1=filename1;
        relative2=filename2;
    else
        relative1=join([repmat("..",numel(p2)-lastcommon,1);p1(lastcommon+1:end);name1],filesep)+ext1;
        relative2=join([repmat("..",numel(p1)-lastcommon,1);p2(lastcommon+1:end);name2],filesep)+ext2;
    end
end

function p=resolveParents(p)
    while(nnz(p(find(p~="..",1,"first"):end)=="..")>0)
        p=resolveLastParent(p);
    end
end

function p=resolveLastParent(p)
    i=find(p=="..",1,"first");
    if(~isempty(i) && i>1)
        p=p([1:i-2 i+1:end]);
    end
end
