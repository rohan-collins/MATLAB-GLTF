function [F,V]=text2FV(text,fontfile)
    % Create a mesh from text
    %
    % TEXT2FV(text,fontfile,resolution) converts text to mesh, using the
    % font file specified. The output of READFONTFILE can be used instead
    % of filename, to avoid re-reading of large font files. The function
    % returns faces and vertices.
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
    if(isstring(fontfile))
        fontfile=readFontFile(fontfile);
    end
    N=fontfile.lineheight/50;
    patchlist=readSVG(writeSVG(text,fontfile),N);
    F=[];
    V=[];
    for i=1:numel(patchlist)
        warning('off','MATLAB:polyshape:repairedBySimplify');
        warning('off','MATLAB:polyshape:boundary3Points');
        p=polyshape(cellfun(@(x) x(:,1),patchlist{i},'UniformOutput',false),cellfun(@(x) x(:,2),patchlist{i},'UniformOutput',false));
        warning('on','MATLAB:polyshape:repairedBySimplify');
        warning('on','MATLAB:polyshape:boundary3Points');
        r=p.regions;
        Fi=[];
        Vi=[];
        for j=1:numel(r)
            tri=r(j).triangulation;
            v=tri.Points;
            f=tri.ConnectivityList;
            n=size(v,1);
            Vj=[v zeros(n,1)];
            Fj=f;
            Fi=[Fi;Fj+size(Vi,1)]; %#ok<AGROW>
            Vi=[Vi;Vj]; %#ok<AGROW>
        end
        F=[F;Fi+size(V,1)]; %#ok<AGROW>
        V=[V;Vi]; %#ok<AGROW>
    end
    V(:,2)=-V(:,2);
    F=F(:,[1 3 2]);
end

function groupPaths=readSVG(text,N)
    % Convert paths in SVG format to polygons.
    %
    % READSVG(text,N) reads lines of an SVG file and return all paths as
    % polygons, using given resolution for bezier arcs.
    %
    tags=string(regexp(text,'(<[^>]*>)','match')');
    defTags=find(~cellfun(@isempty,regexp(tags,'<\/?defs')));
    definitions=tags(min(defTags)+1:max(defTags)-1);
    if(~isempty(definitions))
        test=regexp(definitions,'id=[''"]([\w-]*)[''"]','tokens');
        if(iscell(test{1}))
            defIDs=cellfun(@(x)string(x{1}{1}),test);
        else
            try
                defIDs=cellfun(@(x)string(x{1}),test);
            catch
                defIDs=repmat(string,size(test));
                defIDs(~cellfun(@isempty,test))=cellfun(@(x)string(x),test(~cellfun(@isempty,test)),'UniformOutput',false);
            end
        end
        test=regexp(definitions,'<(\w*)','tokens');
        if(iscell(test{1}))
            defType=cellfun(@(x)string(x{1}{1}),test);
        else
            defType=cellfun(@(x)string(x{1}),test);
        end
        defPaths=cell(numel(definitions),1);
        left=true(numel(definitions),1);
        for i=1:numel(definitions)
            if(strcmpi(defType(i),"path"))
                pathText=regexp(definitions(i),'\sd=[''"]([mMzZlLhHvVcCsSqQtTaA\d\,\.\s\-]*)[''"]','tokens');
                pathText=char(strtrim(pathText{1}));
                if(~isempty(pathText))
                    xy=readSVGpaths(pathText,N);
                    transform=regexp(definitions(i),'transform=[''"]([\w\s\-\(\.\)]*)[''"]','tokens');
                    if(~isempty(transform))
                        matrix=svgTransform(transform{1});
                        for j=1:numel(xy)
                            xy{j}=[xy{j} ones(size(xy{j},1),1)]*matrix(1:2,:)';
                        end
                    end
                    defPaths{i}=xy;
                else
                    defPaths{i}=cell(0,0);
                end
            elseif(strcmpi(defType(i),"symbol"))
                defIDs(i+1)=defIDs(i);
                defIDs(i)="";
            end
        end
        left=and(left,~strcmpi(defType,"path"));
        while(any(left))
            for i=find(left(:)')
                useID=regexp(definitions(i),'href=[''"]#([\w-]*)[''"]','tokens');
                if(~isempty(useID))
                    useID=useID{1};
                    if(ismember(useID,defIDs(~left)))
                        xy=defPaths{strcmpi(defIDs,useID)};
                        transform=regexp(definitions(i),'transform=[''"]([\w\s\-\(\.\)]*)[''"]','tokens');
                        if(~isempty(transform))
                            matrix=svgTransform(transform{1});
                            for j=1:numel(xy)
                                xy{j}=[xy{j} ones(size(xy{j},1),1)]*matrix(1:2,:)';
                            end
                        end
                        defPaths{i}=xy;
                    end
                end
                left(i)=false;
            end
        end
        tags=tags(max(defTags)+1:end-1);
    end
    gTags=find(~cellfun(@isempty,regexp(tags,'<\/?g')));
    if(isempty(gTags))
        tagType=cellfun(@(x)string(x{1}{1}),regexp(tags,'<(\w*)','tokens'));
        groupPaths=cell(numel(tags),1);
        for i=1:numel(tags)
            if(strcmpi(tagType(i),"rect"))
                x=regexp(tags(i),'x=[''"]([\d\.\-]+)[''"]','tokens');
                x=str2double(x{1});
                y=regexp(tags(i),'y=[''"]([\d\.\-]+)[''"]','tokens');
                y=str2double(y{1});
                width=regexp(tags(i),'width=[''"]([\d\.\-]+)[''"]','tokens');
                width=str2double(width{1});
                height=regexp(tags(i),'height=[''"]([\d\.\-]+)[''"]','tokens');
                height=str2double(height{1});
                xy=[x y;x y+height;x+width y+height;x+width y];
                transform=regexp(tags(i),'transform=''([\w\s\-\(\.\)]*)''','tokens');
                if(~isempty(transform))
                    matrix=svgTransform(transform{1});
                else
                    matrix=eye(3);
                end
                xy=[xy ones(size(xy,1),1)]*matrix(1:2,:)';
                groupPaths{i}={xy};
            elseif(strcmpi(tagType(i),"path"))
                pathText=regexp(tags(i),'\sd=[''"]([mMzZlLhHvVcCsSqQtTaA\d\,\.\s\-]*)[''"]','tokens');
                pathText=char(strtrim(pathText{1}));
                xy=readSVGpaths(pathText,N);
                transform=regexp(tags(i),'transform=[''"]([\w\s\-\(\.\)]*)[''"]','tokens');
                if(~isempty(transform))
                    matrix=svgTransform(transform{1});
                    for j=1:numel(xy)
                        xy{j}=[xy{j} ones(size(xy{j},1),1)]*matrix(1:2,:)';
                    end
                    xy=[xy ones(size(xy,1),1)]*matrix(1:2,:)';
                end
                groupPaths{i}=xy;
            end
        end
        if(~isempty(definitions))
            for i=1:numel(tags)
                if(strcmpi(tagType(i),"use"))
                    useID=regexp(tags(i),'href=[''"]#([\w-]*)[''"]','tokens');
                    useID=useID{1};
                    xy=defPaths{strcmpi(defIDs,useID)};
                    transform=regexp(tags(i),'transform=[''"]([\w\s\-\(\.\)]*)[''"]','tokens');
                    if(~isempty(transform))
                        matrix=svgTransform(transform{1});
                    else
                        matrix=eye(3);
                    end
                    x=regexp(tags(i),'x=[''"]([\d\.\-]+)[''"]','tokens');
                    x=str2double(x{1});
                    y=regexp(tags(i),'y=[''"]([\d\.\-]+)[''"]','tokens');
                    y=str2double(y{1});
                    for j=1:numel(xy)
                        xy{j}=[(xy{j}+[x y]) ones(size(xy{j},1),1)]*matrix(1:2,:)';
                    end
                    groupPaths{i}=xy;
                end
            end
        end
    else
        groupTransform=regexp(tags(min(gTags)),'transform=[''"]([\w\s\-\(\.\)]*)[''"]','tokens');
        if(~isempty(groupTransform))
            groupMatrix=svgTransform(groupTransform{1});
        else
            groupMatrix=eye(3);
        end
        groupTags=tags(min(gTags)+1:max(gTags)-1);
        test=regexp(groupTags,'<(\w*)','tokens');
        if(iscell(test{1}))
            tagType=cellfun(@(x)string(x{1}{1}),test);
        else
            tagType=cellfun(@(x)string(x{1}),test);
        end
        groupPaths=cell(numel(groupTags),1);
        for i=1:numel(groupTags)
            if(strcmpi(tagType(i),"rect"))
                x=regexp(groupTags(i),'x=[''"]([\d\.\-]+)[''"]','tokens');
                x=str2double(x{1});
                y=regexp(groupTags(i),'y=[''"]([\d\.\-]+)[''"]','tokens');
                y=str2double(y{1});
                width=regexp(groupTags(i),'width=[''"]([\d\.\-]+)[''"]','tokens');
                width=str2double(width{1});
                height=regexp(groupTags(i),'height=[''"]([\d\.\-]+)[''"]','tokens');
                height=str2double(height{1});
                xy=[x y;x y+height;x+width y+height;x+width y];
                transform=regexp(groupTags(i),'transform=[''"]([\w\s\-\(\.\)]*)[''"]','tokens');
                if(~isempty(transform))
                    matrix=groupMatrix*svgTransform(transform{1});
                else
                    matrix=groupMatrix;
                end
                xy=[xy ones(size(xy,1),1)]*matrix(1:2,:)';
                groupPaths{i}={xy};
            elseif(strcmpi(tagType(i),"path"))
                pathText=regexp(groupTags(i),'\sd=[''"]([mMzZlLhHvVcCsSqQtTaA\d\,\.\s\-]*)[''"]','tokens');
                pathText=char(strtrim(pathText{1}));
                xy=readSVGpaths(pathText,N);
                transform=regexp(groupTags(i),'transform=[''"]([\w\s\-\(\.\)]*)[''"]','tokens');
                if(~isempty(transform))
                    matrix=svgTransform(transform{1});
                    for j=1:numel(xy)
                        xy{j}=[xy{j} ones(size(xy{j},1),1)]*matrix(1:2,:)';
                    end
                end
                groupPaths{i}=xy;
            end
        end
        for i=1:numel(groupTags)
            if(strcmpi(tagType(i),"use"))
                useID=regexp(groupTags(i),'href=[''"]#([\w-]*)[''"]','tokens');
                useID=useID{1};
                xy=defPaths{strcmpi(defIDs,useID)};
                transform=regexp(groupTags(i),'transform=[''"]([\w\s\-\(\.\)]*)[''"]','tokens');
                if(~isempty(transform))
                    matrix=groupMatrix*svgTransform(transform{1});
                else
                    matrix=groupMatrix;
                end
                x=regexp(groupTags(i),'x=[''"]([\d\.\-]+)[''"]','tokens');
                x=str2double(x{1});
                y=regexp(groupTags(i),'y=[''"]([\d\.\-]+)[''"]','tokens');
                y=str2double(y{1});
                for j=1:numel(xy)
                    xy{j}=[(xy{j}+[x y]) ones(size(xy{j},1),1)]*matrix(1:2,:)';
                end
                groupPaths{i}=xy;
            end
        end
    end
    groupPaths=groupPaths(~cellfun(@isempty,groupPaths));
end

function fullout=writeSVG(multitext,fontfile)
    % Convert text to SVG paths
    %
    % WRITESVG(text,N) converts the text to SVG paths using the given font
    % struct and returns all the lines of an SVG file.
    %
    glyphs=fontfile.glyphs;
    missingadv=fontfile.missingadv;
    if(~exist('lineheight','var'))
        lineheight=fontfile.lineheight;
    end
    N2=lineheight/50;
    N=numel(multitext);
    bounds=repmat([Inf -Inf Inf -Inf],N,1);
    for j=1:N
        text=multitext(j);
        glyphIdx=text2glyphIdx(text,glyphs);
        newx=0;
        for i=1:numel(glyphIdx)
            if(glyphIdx(i)>0)
                if(glyphs(glyphIdx(i),1)~=" ")
                    pathstr=glyphs(glyphIdx(i),3);
                    [~,bounds_temp]=readSVGpaths(pathstr,N2);
                    bounds_temp=bounds_temp+[newx newx 0 0];
                    bounds(j,:)=[min(bounds(j,1),bounds_temp(1)) max(bounds(j,2),bounds_temp(2)) min(bounds(j,3),bounds_temp(3)) max(bounds(j,4),bounds_temp(4))];
                end
            end
            if(i<numel(glyphIdx))
                if(glyphIdx(i)>0)
                    newx=newx+str2double(glyphs(glyphIdx(i),2));
                else
                    newx=newx+missingadv;
                end
            end
        end
    end
    matrices=[ones(N,1) zeros(N,2) ones(N,1) -bounds(:,1) (0:N-1)'*lineheight-bounds(:,3)];
    newbounds=bounds;
    for j=1:N
        newbounds(j,:)=reshape([bounds(j,1) bounds(j,3) 1;bounds(j,2) bounds(j,4) 1]*reshape(matrices(j,:),2,3)',1,[]);
    end
    fullbounds=[min(newbounds(:,1)) max(newbounds(:,2)) min(newbounds(:,3)) max(newbounds(:,4))];
    fullout=[];
    for j=1:N
        text=multitext(j);
        glyphIdx=text2glyphIdx(text,glyphs);
        out=repmat("",strlength(text),1);
        newx=0;
        for i=1:numel(glyphIdx)
            if(glyphIdx(i)>0)
                if(glyphs(glyphIdx(i),1)~=" ")
                    pathstr=glyphs(glyphIdx(i),3);
                    out(i)="<path transform=""matrix(1 0 0 -1 " + double2string(newx) + " " + double2string(bounds(j,4)+bounds(j,3)) + ")"" d=""" + pathstr + """ />";
                end
            end
            if(i<numel(glyphIdx))
                if(glyphIdx(i)>0)
                    newx=newx+str2double(glyphs(glyphIdx(i),2));
                else
                    newx=newx+missingadv;
                end
            end
        end
        fullout=[fullout;"<g transform=""matrix("+join(double2string(matrices(j,:)))+")"">";out;"</g>"]; %#ok<AGROW>
    end
    fullout=fullout(fullout~="");
    base=repmat("",3,1);
    base(1)="<?xml version=""1.0"" standalone=""no""?>";
    base(2)="<!DOCTYPE svg PUBLIC ""-//W3C//DTD SVG 1.1//EN"" ""http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd"">";
    base(3)="<svg xmlns=""http://www.w3.org/2000/svg"" version=""1.1"" viewBox=""0 0 " + double2string(fullbounds(2)) + " " + double2string(fullbounds(4)-fullbounds(3)) + """ width=""" + double2string(fullbounds(2)) + """ height=""" + double2string(fullbounds(4)-fullbounds(3)) + """>";
    finish="</svg>";
    fullout=[base;fullout;finish];
end

function glyphIdx=text2glyphIdx(text,glyphs)
    % Convert text to list of glyph indices.
    %
    % TEXT2GLYPHIDX(text,glyphs) converts the given text to a list of glyph
    % indices from the given glyphs. The function assumes that the list of
    % glyphs has been presorted from longest to shortest.
    %
    temp=mat2cell(glyphs(:,1),ones(size(glyphs,1),1));
    temp=cellfun(@char,temp,'UniformOutput',false);
    temp=cellfun(@uint32,temp,'UniformOutput',false);
    textunicode=uint32(char(text));
    strl=strlength(glyphs(:,1));
    glyphIdx=zeros(size(textunicode));

    L=min(numel(textunicode),max(strl));

    count=nnz(strl>L);
    for l=L:-1:2
        substrings=textunicode((1:numel(textunicode)-l+1)'+(0:l-1));
        checklist=cell2mat(temp(strl==l));
        for i=1:size(substrings,1)
            if(all(~isnan(glyphIdx(i:i+l-1))))
                if(any(all(substrings(i,:)==checklist,2)))
                    if(i+l<numel(textunicode))
                        if(textunicode(i+l)~=8204)
                            locB=find(all(substrings(i,:)==checklist,2));
                            glyphIdx(i)=locB+count;
                            glyphIdx(i+1:i+l-1)=nan;
                        end
                    else
                        locB=find(all(substrings(i,:)==checklist,2));
                        glyphIdx(i)=locB+count;
                        glyphIdx(i+1:i+l-1)=nan;
                    end
                end
            end
        end
        count=count+size(checklist,1);
    end
    checklist=cell2mat(temp(strl==1));
    [~,locB]=ismember(textunicode(glyphIdx==0),checklist);
    locB(locB>0)=locB(locB>0)+count;
    glyphIdx(glyphIdx==0)=locB;
    glyphIdx=glyphIdx(~isnan(glyphIdx));
end

function [newpath,bounds]=readSVGpaths(path,N)
    % Convert SVG path definition string to polygon and bounds.
    %
    % READSVGPATHS(path,N) converts the SVG path definition string to
    % polygon, and returns the bounds of the path as [xmin xmax ymin ymax].
    %
    cmdsplit = '\s*([mMzZlLhHvVcCsSqQtTaA])\s*';
    numsplit = [ ...
        '\s*,\s*|'                ... % Split at comma with whitespace, or
        '\s+|'                    ... % split at whitespace, or
        '(?<=[0-9])(?=[-+])|'     ... % split before a sign, or
        '(?<=[.eE][0-9]+)(?=[.])' ... % split before a second decimal point.
        ];

    [cmds, allparams] = regexp(path, cmdsplit, 'match', 'split');
    cmds = strtrim(cmds);           % Trim any excess whitespace.
    allparams = allparams(2:end);   % Ignore part before first command.
    allparams = regexp(allparams, numsplit, 'split', 'emptymatch');

    % Starting at the point (0, 0), keep a running tally of where the start point
    % should be for the next segment. Loop through all of the command blocks,
    % and for each one, loop through its constituent segments. For each one,
    % add the appropriate command to segmentcmds, and the full set of
    % control point locations including the starting point to segmentcoeffs.
    % Also keep a running tally of the number of segments, starting at zero.
    startpoint = [0 0];
    segmentcmds = {};
    segmentcoeffs = {};
    segments = 0;
    for cmdIdx=1:numel(cmds)
        params = str2double(allparams{cmdIdx});
        nparams = numel(params);
        switch cmds{cmdIdx}
            case 'm'  % Move to:
                startpoint = startpoint + params(1:2);
                segments = segments + 1;
                segmentcoeffs{segments} = [nan(2,2);startpoint]; %#ok<AGROW>
                segmentcmds{segments} = 'L'; %#ok<AGROW>
                for k=3:2:nparams
                    segments = segments + 1;
                    segmentcmds{segments} = 'L';
                    endpoint = startpoint + params(k:k+1);
                    segmentcoeffs{segments} = [nan(2,2);startpoint; endpoint];
                    startpoint = endpoint;
                end
            case 'M'
                startpoint = params(1:2);
                segments = segments + 1;
                segmentcoeffs{segments} = [nan(2,2);startpoint]; %#ok<AGROW>
                segmentcmds{segments} = 'L'; %#ok<AGROW>
                for k=3:2:nparams
                    segments = segments + 1;
                    segmentcmds{segments} = 'L';
                    endpoint = params(k:k+1);
                    segmentcoeffs{segments} = [nan(2,2); startpoint; endpoint];
                    startpoint = endpoint;
                end
            case 'l'  % Line to:
                for k=1:2:nparams
                    segments = segments + 1;
                    segmentcmds{segments} = 'L'; %#ok<AGROW>
                    endpoint = startpoint + params(k:k+1);
                    segmentcoeffs{segments} = [startpoint; endpoint]; %#ok<AGROW>
                    startpoint = endpoint;
                end
            case 'L'
                for k=1:2:nparams
                    segments = segments + 1;
                    segmentcmds{segments} = 'L'; %#ok<AGROW>
                    endpoint = params(k:k+1);
                    segmentcoeffs{segments} = [startpoint; endpoint]; %#ok<AGROW>
                    startpoint = endpoint;
                end
            case 'h'  % Horizontal line to:
                for k=1:nparams
                    segments = segments + 1;
                    segmentcmds{segments} = 'L'; %#ok<AGROW>
                    endpoint = startpoint + [params(k) 0];
                    segmentcoeffs{segments} = [startpoint; endpoint]; %#ok<AGROW>
                    startpoint = endpoint;
                end
            case 'H'
                for k=1:nparams
                    segments = segments + 1;
                    segmentcmds{segments} = 'L'; %#ok<AGROW>
                    endpoint = [params(k) startpoint(2)];
                    segmentcoeffs{segments} = [startpoint; endpoint]; %#ok<AGROW>
                    startpoint = endpoint;
                end
            case 'v'  % Vertical line to:
                for k=1:nparams
                    segments = segments + 1;
                    segmentcmds{segments} = 'L'; %#ok<AGROW>
                    endpoint = startpoint + [0 params(k)];
                    segmentcoeffs{segments} = [startpoint; endpoint]; %#ok<AGROW>
                    startpoint = endpoint;
                end
            case 'V'
                for k=1:nparams
                    segments = segments + 1;
                    segmentcmds{segments} = 'L'; %#ok<AGROW>
                    endpoint = [startpoint(1) params(k)];
                    segmentcoeffs{segments} = [startpoint; endpoint]; %#ok<AGROW>
                    startpoint = endpoint;
                end
            case 'c'  % Cubic curve to:
                for k=1:6:nparams
                    segments = segments + 1;
                    segmentcmds{segments} = 'C'; %#ok<AGROW>
                    ctrlpt1 = startpoint + params(k:k+1);
                    ctrlpt2 = startpoint + params(k+2:k+3);
                    endpoint = startpoint + params(k+4:k+5);
                    segmentcoeffs{segments} = [startpoint; ctrlpt1; ctrlpt2; endpoint]; %#ok<AGROW>
                    startpoint = endpoint;
                end
            case 'C'
                for k=1:6:nparams
                    segments = segments + 1;
                    segmentcmds{segments} = 'C'; %#ok<AGROW>
                    ctrlpt1 = params(k:k+1);
                    ctrlpt2 = params(k+2:k+3);
                    endpoint = params(k+4:k+5);
                    segmentcoeffs{segments} = [startpoint; ctrlpt1; ctrlpt2; endpoint]; %#ok<AGROW>
                    startpoint = endpoint;
                end
            case 's'  % Smooth cubic to:
                for k=1:4:nparams
                    segments = segments + 1;
                    segmentcmds{segments} = 'C'; %#ok<AGROW>
                    if strcmp(segmentcmds{segments-1}, 'C')
                        prevctrlpt2 = segmentcoeffs{segments-1}(3,:);
                        ctrlpt1 = 2 * startpoint - prevctrlpt2;
                    else
                        ctrlpt1 = startpoint;
                    end
                    ctrlpt2 = startpoint + params(k:k+1);
                    endpoint = startpoint + params(k+2:k+3);
                    segmentcoeffs{segments} = [startpoint; ctrlpt1; ctrlpt2; endpoint]; %#ok<AGROW>
                    startpoint = endpoint;
                end
            case 'S'
                for k=1:4:nparams
                    segments = segments + 1;
                    segmentcmds{segments} = 'C'; %#ok<AGROW>
                    if strcmp(segmentcmds{segments-1}, 'C')
                        prevctrlpt2 = segmentcoeffs{segments-1}(3,:);
                        ctrlpt1 = 2 * startpoint - prevctrlpt2;
                    else
                        ctrlpt1 = startpoint;
                    end
                    ctrlpt2 = params(k:k+1);
                    endpoint = params(k+2:k+3);
                    segmentcoeffs{segments} = [startpoint; ctrlpt1; ctrlpt2; endpoint]; %#ok<AGROW>
                    startpoint = endpoint;
                end
            case 'q'  % Quadratic curve to:
                for k=1:4:nparams
                    segments = segments + 1;
                    segmentcmds{segments} = 'Q'; %#ok<AGROW>
                    ctrlpt = startpoint + params(k:k+1);
                    endpoint = startpoint + params(k+2:k+3);
                    segmentcoeffs{segments} = [startpoint; ctrlpt; endpoint]; %#ok<AGROW>
                    startpoint = endpoint;
                end
            case 'Q'
                for k=1:4:nparams
                    segments = segments + 1;
                    segmentcmds{segments} = 'Q'; %#ok<AGROW>
                    ctrlpt = params(k:k+1);
                    endpoint = params(k+2:k+3);
                    segmentcoeffs{segments} = [startpoint; ctrlpt; endpoint]; %#ok<AGROW>
                    startpoint = endpoint;
                end
            case 't'  % Smooth quadratic to:
                for k=1:2:nparams
                    segments = segments + 1;
                    segmentcmds{segments} = 'Q'; %#ok<AGROW>
                    if strcmp(segmentcmds{segments-1}, 'Q')
                        prevctrlpt = segmentcoeffs{segments-1}(2,:);
                        ctrlpt = 2 * startpoint - prevctrlpt;
                    else
                        ctrlpt = startpoint;
                    end
                    endpoint = startpoint + params(k:k+1);
                    segmentcoeffs{segments} = [startpoint; ctrlpt; endpoint]; %#ok<AGROW>
                    startpoint = endpoint;
                end
            case 'T'
                for k=1:2:nparams
                    segments = segments + 1;
                    segmentcmds{segments} = 'Q'; %#ok<AGROW>
                    if strcmp(segmentcmds{segments-1}, 'Q')
                        prevctrlpt = segmentcoeffs{segments-1}(2,:);
                        ctrlpt = 2 * startpoint - prevctrlpt;
                    else
                        ctrlpt = startpoint;
                    end
                    endpoint = params(k:k+1);
                    segmentcoeffs{segments} = [startpoint; ctrlpt; endpoint]; %#ok<AGROW>
                    startpoint = endpoint;
                end
            case 'a'  % Elliptical arc to:
                for k=1:7:nparams
                    segments = segments + 1;
                    segmentcmds{segments} = 'A'; %#ok<AGROW>
                    endpoint = startpoint + params(k+5:k+6);
                    r=params(k:k+1);
                    phi=params(k+2);
                    f=params(k+3:k+4)>0.5;
                    segmentcoeffs{segments} = [startpoint; endpoint; r; phi nan; f]; %#ok<AGROW>
                    startpoint = endpoint;
                end
            case 'A'
                for k=1:7:nparams
                    segments = segments + 1;
                    segmentcmds{segments} = 'A'; %#ok<AGROW>
                    endpoint = params(k+5:k+6);
                    r=params(k:k+1);
                    phi=params(k+2);
                    f=params(k+3:k+4)>0.5;
                    segmentcoeffs{segments} = [startpoint; endpoint; r; phi nan; f]; %#ok<AGROW>
                    startpoint = endpoint;
                end
            case 'z'  % Close path:
            case 'Z'
        end
    end
    path=zeros(0,2);
    bounds=[Inf -Inf Inf -Inf];
    for i=1:numel(segmentcmds)
        switch(segmentcmds{i})
            case{'C','Q'}
                t=[0;cumsum(vecnorm(diff(bezier(segmentcoeffs{i},linspace(0,1,1001))),2,2))]/sum(vecnorm(diff(bezier(segmentcoeffs{i},linspace(0,1,1001))),2,2));
                t(end)=1;
                [newpath,boundstemp]=bezier(segmentcoeffs{i},interp1(t,linspace(0,1,1001)',linspace(0,1,ceil(sum(vecnorm(diff(bezier(segmentcoeffs{i},linspace(0,1,1001))),2,2))/N)+1)'));
                bounds=[min(bounds(1),boundstemp(1)) max(bounds(2),boundstemp(2)) min(bounds(3),boundstemp(3)) max(bounds(4),boundstemp(4))];
            case{'A'}
                [newpath,boundstemp]=arc(segmentcoeffs{i},N);
                bounds=[min(bounds(1),boundstemp(1)) max(bounds(2),boundstemp(2)) min(bounds(3),boundstemp(3)) max(bounds(4),boundstemp(4))];
            otherwise
                newpath=segmentcoeffs{i};
                bounds=[min(min(newpath(:,1)),bounds(1)) max(max(newpath(:,1)),bounds(2)) min(min(newpath(:,2)),bounds(3)) max(max(newpath(:,2)),bounds(4))];
        end
        newpath=newpath(2:end,:);
        path=[path;newpath]; %#ok<AGROW>
    end
    if(numel(path)>0)
        if(all(isnan(path(1,:))))
            path=path(2:end,:);
        end
    end
    I=find(all(isnan(path),2));
    newpath=cell(0,1);
    if(isempty(I))
        newpath{1}=path;
    else
        newpath{1}=path(1:I(1)-1,:);
        for i=2:numel(I)
            newpath=[newpath;{path(I(i-1)+1:I(i)-1,:)}]; %#ok<AGROW>
        end
        newpath=[newpath;{path(I(end)+1:end,:)}];
    end
end

function [curve,bounds]=bezier(points,t)
    % Get the coordinates of a bezier curve and the bounds.
    %
    % BEZIER(points,t) computes the coordinates of the bezier curve defined
    % by the control points, at each element of the parameter vector. The
    % degree of the curve is determined based on to the number of control
    % points provided. It also returns the bounds of the curve as
    % [xmin xmax ymin ymax]. The bounds are calculated using optimisation
    % and are independent of the resolution of the parameter vector.
    %
    if(size(t,2)>size(t,1))
        t=t';
    end
    degree=size(points,1)-1;
    curve=zeros(size(t,1),size(points,2));
    for i=0:degree
        for j=1:size(points,2)
            curve(:,j)=curve(:,j)+nchoosek(degree,i)*(t.^i).*((1-t).^(degree-i))*points(i+1,j);
        end
    end
    [~,bounds(1)]=fminbnd(@(x) bezierfun(x,points(:,1)),0,1);
    [~,bounds(2)]=fminbnd(@(x) -bezierfun(x,points(:,1)),0,1);
    bounds(2)=-bounds(2);
    [~,bounds(3)]=fminbnd(@(x) bezierfun(x,points(:,2)),0,1);
    [~,bounds(4)]=fminbnd(@(x) -bezierfun(x,points(:,2)),0,1);
    bounds(4)=-bounds(4);
end

function curve=bezierfun(x,points)
    % Get the coordinates of a bezier curve at given parameters
    %
    % BEZIERFUN(t,points) computes the coordinates of the bezier curve
    % defined by the control points, at each element of the parameter
    % vector. The degree of the curve is determined based on to the number
    % of control points provided.
    %
    if(size(x,2)>size(x,1))
        x=x';
    end
    degree=size(points,1)-1;
    curve=zeros(size(x,1),size(points,2));
    for i=0:degree
        curve(:,1)=curve(:,1)+nchoosek(degree,i)*(x.^i).*((1-x).^(degree-i))*points(i+1,1);
    end
end

function [curve,bounds]=arc(params,N)
    % Generate an elliptical arc given parameters and the bounds.
    %
    % ARC(params,N) computes the coordiantes of the elliptical arc defined
    % by the parameters. The first row of the parameters gives the start
    % point, the second gives the end point, the third row has the
    % semimajor and semiminor axes, the first element of fourth row is the
    % angle or rotation of the ellipse in degrees, if the first element of
    % the fifth row is more than 0.5 the arc is greater than 180°,
    % otherwise it's less than 180°, if the second element of the fifth row
    % is more than 0.5, the arc begins moving at positive angles, otherwise
    % at negative angles, and the second element of the fifth row is
    % disregarded. If the start and end points are farther than the
    % ellipse's x and y radius can reach, the ellipse's radii will be
    % minimally expanded so it could reach the start and end points.
    %
    x1=params(1,1);
    y1=params(1,2);
    x2=params(2,1);
    y2=params(2,2);
    rx=params(3,1);
    ry=params(3,2);
    phi=params(4,1);
    fa=params(5,1);
    fs=params(5,2);
    if(or(rx==0,ry==0))
        curve=[x1 y1;x2 y2];
        bounds=[min(x1,x2) max(x1,x2) min(y1,y2) max(y1,y2)];
    else
        R=[cos(phi*pi/180) -sin(phi*pi/180);sin(phi*pi/180) cos(phi*pi/180)];
        xy1dash=R'*[(x1-x2)/2;(y1-y2)/2];
        x1dash=xy1dash(1);
        y1dash=xy1dash(2);
        rx=abs(rx);
        ry=abs(ry);
        Lambda=x1dash.^2./rx.^2+y1dash.^2./ry.^2;
        if(Lambda>1)
            rx=sqrt(Lambda)*rx;
            ry=sqrt(Lambda)*ry;
        end
        sgn=1-(fa==fs)*2;
        radicand_numerator=rx.^2.*ry.^2;
        radicand_denominator=rx.^2.*y1dash.^2+ry.^2.*x1dash.^2;
        if(radicand_numerator./radicand_denominator-1<=2*eps) %#ok<BDSCA>
            cxydash=[0;0];
        else
            cxydash=sgn*sqrt(radicand_numerator./radicand_denominator-1)*[rx./ry.*y1dash;-ry./rx.*x1dash];
        end
        cxdash=cxydash(1);
        cydash=cxydash(2);
        cxy=R*cxydash+[(x1+x2)/2;(y1+y2)/2];
        cx=cxy(1);
        cy=cxy(2);
        theta1=ang([1;0],[(x1dash-cxdash)./rx;(y1dash-cydash)./ry]);
        dtheta=mod(ang([(x1dash-cxdash)./rx;(y1dash-cydash)./ry],[(-x1dash-cxdash)./rx;(-y1dash-cydash)./ry]),2*pi);
        if(fs<0.5)
            dtheta=dtheta-2*pi;
        end
        theta=linspace(theta1,theta1+dtheta,N+1);
        curve=R*[rx.*cos(theta);ry.*sin(theta)]+cxy;
        curve=curve';
        if(dtheta<0)
            t1=theta1+dtheta;
            t2=theta1;
        else
            t1=theta1;
            t2=theta1+dtheta;
        end
        [~,bounds(1)]=fminbnd(@(x)R(1,:)*[rx.*cos(x);ry.*sin(x)]+cx,t1,t2);
        [~,bounds(2)]=fminbnd(@(x)-(R(1,:)*[rx.*cos(x);ry.*sin(x)]+cx),t1,t2);
        bounds(2)=-bounds(2);
        [~,bounds(3)]=fminbnd(@(x)R(2,:)*[rx.*cos(x);ry.*sin(x)]+cy,t1,t2);
        [~,bounds(4)]=fminbnd(@(x)-(R(2,:)*[rx.*cos(x);ry.*sin(x)]+cy),t1,t2);
        bounds(4)=-bounds(4);
    end
end

function alpha=ang(u,v)
    % Calculate the angle between two vectors.
    %
    % ANG(u,v) calculates the angle in radians between the two column
    % vectors u and v.
    %
    if(det([u v])<0)
        sgn=-1;
    else
        sgn=1;
    end
    alpha=sgn*real(acos(dot(u,v)/vecnorm(u)/vecnorm(v)));
end

function out=double2string(num)
    % Convert from double to string while rounding off values very close to
    % integers.
    %
    % DOUBLE2STRING(num) converts num to string using 15 decimal points. It
    % rounds off values closer than 1e-5 to an integer to that integer.
    %
    out=repmat("",size(num));
    for i=1:numel(num)
        if(abs(num(i)-round(num(i)))<1e-5)
            out(i)=string(num(i));
        else
            out(i)=string(sprintf('%.15f',num(i)));
        end
    end
end

function matrix=svgTransform(transformString)
    % Convert from SVG transform string to an affine transformation matrix.
    %
    % SVGTRANSFORM(transformString) converts the SVG transform string into
    % its corresponding affine transformation matrix.
    %
    allTransforms=regexp(transformString,'(\w*)\(([\d\-\s\.,]*)\)','tokens');
    matrix=eye(3);
    for j=1:numel(allTransforms)
        switch(allTransforms{j}(1))
            case "rotate"
                params=regexp(allTransforms{j}(2),'[\d\-\.]*','match');
                if(numel(params)==1)
                    a=str2double(params(1))*pi/180;
                    matrix=[cos(a) -sin(a) 0;sin(a) cos(a) 0;0 0 1]*matrix;
                elseif(numel(params)==3)
                    a=str2double(params(1))*pi/180;
                    tx=str2double(params(2));
                    ty=str2double(params(3));
                    matrix=[1 0 tx;0 1 ty;0 0 1]*[cos(a) -sin(a) 0;sin(a) cos(a) 0;0 0 1]*[1 0 -tx;0 1 -ty;0 0 1]*matrix;
                end
            case "translate"
                params=regexp(allTransforms{j}(2),'[\d\-\.]*','match');
                tx=str2double(params(1));
                ty=str2double(params(2));
                matrix=[1 0 tx;0 1 ty;0 0 1]*matrix;
            case "skewX"
                params=regexp(allTransforms{j}(2),'[\d\-\.]*','match');
                a=str2double(params(1))*pi/180;
                matrix=[1 tan(a) 0;0 1 0;0 0 1]*matrix;
            case "skewY"
                params=regexp(allTransforms{j}(2),'[\d\-\.]*','match');
                a=str2double(params(1))*pi/180;
                matrix=[1 0 0;tan(a) 1 0;0 0 1]*matrix;
            case "scale"
                params=regexp(allTransforms{j}(2),'[\d\-\.]*','match');
                sx=str2double(params(1));
                if(numel(params)>1)
                    sy=str2double(params(2));
                else
                    sy=sx;
                end
                matrix=[sx 0 0;0 sy 0;0 0 1]*matrix;
            case "matrix"
                params=regexp(allTransforms{j}(2),'[\d\-\.]*','match');
                a=str2double(params(1));b=str2double(params(2));c=str2double(params(3));d=str2double(params(4));e=str2double(params(5));f=str2double(params(6));
                matrix=[a c e;b d f;0 0 1]*matrix;
        end
    end
end
