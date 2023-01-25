function axisangle=Q2AxisAngle(q)
    % Convert quaternion to axis-angle.
    %
    % Q2AxisAngle(Q) returns the axis and angle of the rotation associated
    % with the XYZW quaternion Q.
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
    angle=acos(q(:,4))*2;
    axis=repmat([0 1 0],size(q,1),1);
    axis(angle~=0,:)=q(angle~=0,1:3);
    axis(angle~=0,:)=axis(angle~=0,:)./vecnorm(axis(angle~=0,:),2,2);
    I=find(angle~=0);
    for j=find(angle'==0)
        i=max(I(I<j));
        k=min(I(I>j));
        if(and(~isempty(i),~isempty(k)))
            axis(j,:)=axis(i,:)+axis(k,:);
            axis(j,:)=axis(j,:)/vecnorm(axis(j,:),2,2);
        elseif(~isempty(i))
            axis(j,:)=axis(i,:);
        elseif(~isempty(k))
            axis(j,:)=axis(k,:);
        end
    end
    axisangle=[axis angle*180/pi];
end
