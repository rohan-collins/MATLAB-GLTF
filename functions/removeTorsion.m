function [P,Q]=removeTorsion(N,B,t,s,dsdt,torsion,closed,stable)
    % Rotate the normal vectors N and binormal vector B within their plane
    % to minimise the torsion in the TNB frame.
    % [P,Q]=REMOVETORSION(N,B,S,TORSION,T,DSDT,closed,stable) returns
    % orthogonal vectors P and Q, in the same plane as normal vector N and
    % binormal vector B, such that the torsion between consecutive TNB
    % frames is minimised. It uses the cumulative curve length S, the curve
    % speed DSDT, and the TORSION. If CLOSED is true, the angle between the
    % first and the last frames is spread along the length of the curve so
    % that the first and last TPQ frames match with minimum torsion. If
    % stable is TRUE, the TPQ frames are calculated in a slower but
    % numerically stable fashion instead of algebraically.
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

    if(nargin<8)
        stable=false;
    end
    if(stable)
        intt=cumtrapz(t,torsion.*dsdt);
        if(closed)
            intt=cumtrapz(t,(torsion-(intt(end)-intt(1))./s(end)).*dsdt);
        end
        a=sin(intt);
        b=cos(intt);
        P=b.*N-a.*B;
        Q=a.*N+b.*B;
    else
        P=N;
        Q=B;
        T=cross(N,B);
        T=T./vecnorm(T,2,2);
        for i=2:size(T,1)
            d=cross(T(i,:),P(i-1,:));
            Q(i,:)=d/norm(d);
            P(i,:)=cross(Q(i,:),T(i,:));
        end
        if(closed)
            d=acos(dot(P(end,:),P(1,:)));
            for i=2:size(T,1)
                ax=T(i,:);
                a=cos(d/2*s(i)/s(end));
                b=sin(d/2*s(i)/s(end));
                q=[a b*ax];
                qr=q(1);qx=q(2);qy=q(3);qz=q(4);
                R=[qr^2+qx^2-qy^2-qz^2 2*(qx*qy-qr*qz) 2*(qz*qx+qr*qy);2*(qx*qy+qr*qz) qr^2-qx^2+qy^2-qz^2 2*(qy*qz-qr*qx);2*(qz*qx-qr*qy) 2*(qy*qz+qr*qx) qr^2-qx^2-qy^2+qz^2];
                P(i,:)=P(i,:)*R';
                Q(i,:)=Q(i,:)*R';
            end
        end
    end
end
