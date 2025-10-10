function reg=filepath_regex()
    % The regular expression for checking if string is a file path.
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
    reg="^(?!(?:https?|ftp):\/\/)([a-zA-Z]:[\\/](?:[^<>:""|?*\r\n]+[\\/])*[^<>:""|?*\r\n]*|(?:\.\.?(?:[\\/]|$))+(?:[^<>:""|?*\r\n]+[\\/])*[^<>:""|?*\r\n]*|\\\\+[^\\\s]+\\+[^\\\s]+(?:\\+[^\\\s]+)*|/(?:[^/\s]+/)*[^/\s]*|~/(?:[^/\s]+/)*[^/\s]*|//[^/\s]+/[^/\s]+(?:/[^/\s]+)*|file://[a-zA-Z]:[\\/](?:[^<>:""|?*\r\n]+[\\/])*[^<>:""|?*\r\n]*|\./(?:[^/\s]+/)*[^/\s]*|(?:[^./\\\s][^\\/\s]*[\\/])*[^\\/\s]+)$";
end
