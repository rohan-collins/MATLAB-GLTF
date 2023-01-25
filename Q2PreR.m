function R=Q2PreR(q)
    % Convert quaternion to rotation matrix.
    %
    % Q2PRER(Q) returns the rotation matrix associated with the XYZW
    % quaternion Q.
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
    qx=q(1);qy=q(2);qz=q(3);qr=q(4);
    R=[qr^2+qx^2-qy^2-qz^2 2*(qx*qy-qr*qz) 2*(qz*qx+qr*qy);2*(qx*qy+qr*qz) qr^2-qx^2+qy^2-qz^2 2*(qy*qz-qr*qx);2*(qz*qx-qr*qy) 2*(qy*qz+qr*qx) qr^2-qx^2-qy^2+qz^2];
end
