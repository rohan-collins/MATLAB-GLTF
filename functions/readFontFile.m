function fontstruct=readFontFile(fontfile)
    % Read an SVG font file.
    %
    % READFONTFILE(fontfile) reads the SVG font in fontfile, and returns a
    % struct of glyphs ordered by length, kerning corrections, line height,
    % and default advance.
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

    fonttext=fileread(fontfile);
    fonttext=regexprep(fonttext,'[\n\r]+','');
    fonttext=regexprep(fonttext,'\s+',' ');
    fonttext=regexprep(fonttext,'>[\s\n\r]*<','>\n<');
    fontinforegex="<font-face font-family=""[\w\s]+"" font-weight=""[\d\-\.]+"" font-stretch=""[\w\s]*"" units-per-em=""[\d\-\.]+"" panose-1=""[\d\-\.\s]+"" ascent=""([\d\-\.]+)"" descent=""([\d\-\.]+)"" x-height=""[\d\-\.]+"" cap-height=""[\d\-\.]+"" bbox=""([\d\-\.\s]+)"" underline-thickness=""[\d\-\.]+"" underline-position=""[\d\-\.]+""( stemh=""[\d\-\.]+"")?( stemv=""[\d\-\.]+"")? unicode-range=""[\w\s\-\+]+"" \/>";
    glyphregex="<glyph glyph-name=""([\w\.]+)""\s?(unicode=""[.|&#x\w*;\,!$\(\)\+\-\/%]+"")?\s?(horiz-adv-x=""\d+"")?\s?(arabic\-form=""\w*""\s)?\s?(d=""[\w\-\s\.]*"")?\s?\/>";
    spaceregex="<glyph glyph-name=""space"" unicode="" "" (horiz-adv-x=""[\d\.\-]+"") \/>";
    widthregex="horiz-adv-x=""([\d\.\-]+)""";
    kernregex="<hkern u1=""(.|&#x[\w]*;)"" u2=""(.|&#x[\w]*;)"" k=""([\d\-\.]*)"" \/>";
    htmlregex="&#x([\w]*)";
    unicoderegex="uni([A-F\d]+)";
    spaceglyph=regexp(fonttext,spaceregex,'tokens');
    glyphs_cell=regexp(fonttext,glyphregex,'tokens');
    glyphs=repmat("",numel(glyphs_cell)+1,3);
    glyphs(1,1)=" ";
    width=regexp(spaceglyph{1}{1},widthregex,'tokens');
    missingadv=regexp(spaceglyph{1}{1},widthregex,'tokens');
    missingadv=str2double(missingadv{1}{1});
    glyphs(1,2)=string(width);
    for i=1:numel(glyphs_cell)
        if(isempty(glyphs_cell{i}{3}))
            glyphs_cell{i}{3}=spaceglyph{1}{1};
        end
        width=regexp(glyphs_cell{i}{3},widthregex,'tokens');
        glyphs_cell{i}{3}=width{1}{1};
        temp=regexp(glyphs_cell{i}{2},htmlregex,'tokens');
        if(~isempty(temp))
            glyphs_cell{i}{2}=char(hex2dec([temp{:}])');
        else
            glyphs_cell{i}{2}=glyphs_cell{i}{2}(10:end-1);
        end
        temp=regexp(glyphs_cell{i}{1},unicoderegex,'tokens');
        if(~isempty(temp))
            glyphs_cell{i}{1}=char(hex2dec(string(temp)));
            glyphs_cell{i}{2}=char(hex2dec(string(temp)));
        end
        glyphs(i+1,1)=string(glyphs_cell{i}{2});
        glyphs(i+1,2)=string(glyphs_cell{i}{3});
        glyphs(i+1,3)=string(glyphs_cell{i}{5}(4:end-1));
    end
    kerns_cell=regexp(fonttext,kernregex,'tokens');
    kerns=repmat("",numel(kerns_cell),3);
    for i=1:numel(kerns_cell)
        kerns_cell{i}{3}=kerns_cell{i}{3};
        temp=regexp(kerns_cell{i}{1},htmlregex,'tokens');
        if(~isempty(temp))
            kerns_cell{i}{1}=char(hex2dec(temp{1}{1}));
        end
        temp=regexp(kerns_cell{i}{2},htmlregex,'tokens');
        if(~isempty(temp))
            kerns_cell{i}{2}=char(hex2dec(temp{1}{1}));
        end
        kerns(i,:)=string(kerns_cell{i});
    end
    fontinfo=regexp(fonttext,fontinforegex,'tokens');
    ascent=str2double(fontinfo{1}{1});
    descent=str2double(fontinfo{1}{2});
    lineheight=ascent-descent;
    [~,idx]=sort(strlength(glyphs(:,1)),'descend');
    glyphs=glyphs(idx,:);
    glyphs=glyphs(strlength(glyphs(:,1))>0,:);
    fontstruct=struct('glyphs',glyphs,'kerns',kerns,'lineheight',lineheight,'missingadv',missingadv);
end
