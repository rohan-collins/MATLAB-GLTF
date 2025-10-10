function [relative1,relative2]=getRelativePath(filename1,filename2)
    % Find relative paths between two filenames.
    %
    % GETRELATIVEPATH(FILENAME1,FILENAME2) returns the relative paths
    % between the two filenames.
    %
    % © Copyright 2014-2025 Rohan Chabukswar.
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
    if(and(GLTF.is_url(filename1),GLTF.is_url(filename2)))
        [relative1,relative2]=url_mode(filename1,filename2);
    elseif(and(GLTF.is_filepath(filename1),GLTF.is_filepath(filename2)))
        [relative1,relative2]=file_mode(filename1,filename2);
    else
        relative1=filename1;
        relative2=filename2;
    end
end

function [rel1,rel2]=url_mode(url1,url2)
    u1=split_url(url1);
    u2=split_url(url2);
    if(and(strcmpi(u1.scheme,u2.scheme),strcmpi(u1.authority,u2.authority)))
        rel1=compute_relative(u2.path,u1.path,false);
        rel2=compute_relative(u1.path,u2.path,false);
    else
        rel1=url1;
        rel2=url2;
    end
end

function parts=split_url(u)
    reg=url_regex();
    m=regexp(u,reg,"tokens","once");
    if(~isempty(m))
        parts.scheme=erase(m{1},"://");
        parts.authority=string(m{2});
        if(numel(m)<3 || isempty(m{3}))
            parts.path="/";
        else
            parts.path=string(m{3});
        end
    end
end

function [rel1,rel2]=file_mode(f1,f2)
    f1=fullfile(string(f1));
    f2=fullfile(string(f2));
    rel1=compute_relative(f2,f1,true); % f1 relative to f2
    rel2=compute_relative(f1,f2,true); % f2 relative to f1
end

function rel=compute_relative(fromTarget,toTarget,normaliseDrives)
    fromTarget=convertToUnix(fromTarget);
    toTarget=convertToUnix(toTarget);
    [fromDir,~,~]=fileparts(fromTarget);
    [toDir,toName,toExt]=fileparts(toTarget);
    if(strlength(fromDir)==0)
        fromDir=".";
    end
    if(strlength(toDir)==0)
        toDir=".";
    end
    fromParts=erase(split(string(fromDir),"/"),"");
    fromParts=fromParts(fromParts ~="" & fromParts ~=".");
    toParts=erase(split(string(toDir),"/"),"");
    toParts=toParts(toParts   ~="" & toParts   ~=".");
    if(normaliseDrives && ~isempty(fromParts) && ~isempty(toParts))
        if(contains(fromParts(1),":") || contains(toParts(1),":"))
            if(~strcmpi(fromParts(1),toParts(1)))
                rel=toTarget;
                return;
            end
            fromParts=fromParts(2:end);
            toParts=toParts(2:end);
        end
    end
    minLen=min(numel(fromParts),numel(toParts));
    diffIdx=find(~strcmp(fromParts(1:minLen),toParts(1:minLen)),1);
    if(isempty(diffIdx))
        common=minLen;
    else
        common=diffIdx-1;
    end
    numUp=numel(fromParts)-common;
    upParts=repmat("..",1,numUp);
    downParts=toParts(common+1:end);
    relParts=[upParts,downParts,toName+toExt];
    relParts=relParts(relParts ~="");
    if(isempty(relParts))
        rel="./"+toName+toExt;
    else
        rel=strjoin(relParts,"/");
    end
end

function p=convertToUnix(p)
    p=strrep(p,"\","/");
    if(strlength(p)>1 && endsWith(p,"/"))
        p=extractBefore(p,strlength(p));
    end
end
