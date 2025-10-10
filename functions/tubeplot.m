function varargout=tubeplot(curve,varargin)
    % Create a tube from a one-dimensional curve.
    %
    % [F,V,C,N,T,B,PHI,R]=TUBEPLOT(CURVE) expands the one-dimensional
    % curve given as an Nx3 variable CURVE, and returns the faces F,
    % vertices V, colours C, normals N, tangents T, bitangents B, angle
    % around the tube PHI, and the radius of the tube R, which is the
    % maximum radius possible without causing the tube to intersect itself.
    %
    % [F,V,C,N,T,B,PHI,R]=TUBEPLOT(...,'Radius',R) specifies the radius
    % of the tube.
    %
    % [F,V,C,N,T,B,PHI,R]=TUBEPLOT(...,'Radius',R,'ReduceRadius',TRUE)
    % uses R as the maximum possible radius, and reduces it if necessary to
    % a value that prevents the tube from being self-intersecting.
    %
    % [F,V,C,N,T,B,PHI,R]=TUBEPLOT(...,'CData',CData) associates an NxM
    % matrix CData with the curve, and returns the variable C as the M
    % dimensional value associated with each vertex in V.
    %
    % [F,V,C,N,T,B,PHI,R]=TUBEPLOT(...,'Resolution',N) uses N points
    % around the circle as the resolution for the tube.
    %
    % [F,V,C,N,T,B,PHI,R]=TUBEPLOT(...,'FirstDerivative',FIRST) uses
    % FIRST as the first derivative of the curve. If not provided, it is
    % computed using central differences on CURVE where possible, and
    % forward and backward differences at the ends.
    %
    % [F,V,C,N,T,B,PHI,R]=TUBEPLOT(...,'SecondDerivative',SECOND) uses
    % SECOND as the second derivative of the curve. If not provided, and
    % FirstDerivative is provided, it is computed using central differences
    % on FIRST where possible, and forward and backward differences at the
    % ends. If FirstDerivative is not provided, it is computed using
    % central differences on CURVE where possible, and forward and backward
    % differences at the ends.
    %
    % [F,V,C,N,T,B,PHI,R]=TUBEPLOT(...,'ThirdDerivative',THIRD) uses
    % THIRD as the third derivative of the curve. If not provided, and
    % SecondDerivative is provided, it is computed using central
    % differences on SECOND where possible, and forward and backward
    % differences at the ends. If SecondDerivative is not provided, but
    % FirstDerivative is provided, it is computed using central differences
    % on FIRST where possible, and forward and backward differences at the
    % ends. If neither SecondDerivative nor FirstDerivative are provided,
    % it is computed using central differences on CURVE where possible, and
    % forward and backward differences at the ends.
    %
    % [F,V,C,N,T,B,PHI,R]=TUBEPLOT(...,'PreserveTorsion',FALSE)
    % disregards the torsion of the curve while creating the tube. This
    % option will prevent the tube from twisting around itself with the
    % curve and should be used if low resolution or high torison causes the
    % tube to look "pinched" between curve points.
    %
    % [F,V,C,N,T,B,PHI,R]=TUBEPLOT(...,'Ends',FALSE) does not cap the
    % ends of the tube with a hemisphere in the case of a non-closed curve.
    % This option reduces the number of faces and vertices, but prevents
    % the surface from being closed.
    %
    % [F,V,C,N,T,B,PHI,R]=TUBEPLOT(...,'Split',TRUE) repeats the points
    % along the tube. For a non-closed curve with caps, it does not reuse
    % the degenerate tip of the hemispherical caps. For a closed curve, it
    % does not reuse the first point of the curve as last. This option
    % enables the use of C and PHI to calculate unique U and V values
    % along the tube if a texture needs to be applied later on.
    %
    % [F,V,C,N,T,B,PHI,R]=TUBEPLOT(...,'Theta_0',THETA_0) uses THETA_0 as
    % the start of the tube angle instead of 0. This can make a difference
    % in orienting ribbons or polygonal tubes.
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

    ips=inputParser;
    ips.addParameter('Radius',nan,@isnumeric)
    ips.addParameter('ReduceRadius',false,@islogical);
    ips.addParameter('CData',nan,@isnumeric);
    ips.addParameter('Resolution',12,@isnumeric);
    ips.addParameter('FirstDerivative',nan,@isnumeric);
    ips.addParameter('SecondDerivative',nan,@isnumeric);
    ips.addParameter('ThirdDerivative',nan,@isnumeric);
    ips.addParameter('PreserveTorsion',true,@islogical);
    ips.addParameter('Ends',true,@islogical);
    ips.addParameter('Split',false,@islogical)
    ips.addParameter('Theta_0',0,@isnumeric)
    ips.parse(varargin{:});

    tnbArgs=setdiff({'FirstDerivative','SecondDerivative','ThirdDerivative'},ips.UsingDefaults);
    tnbArgValues=cell(size(tnbArgs));
    for i=1:numel(tnbArgs)
        tnbArgValues{i}=ips.Results.(tnbArgs{i});
    end
    tnbArgs=[tnbArgs;tnbArgValues];

    parameters=ips.Results;

    if(ismember('Radius',ips.UsingDefaults))
        minradius=true;
    else
        minradius=false;
        r=parameters.Radius;
    end
    reduce=parameters.ReduceRadius;
    ntheta=parameters.Resolution;
    preserveTorsion=parameters.PreserveTorsion;
    ends=parameters.Ends;
    if(ntheta<5)
        ends=false;
    end
    split=parameters.Split;
    theta_0=parameters.Theta_0;
    useCData=~ismember('CData',ips.UsingDefaults);
    if(useCData)
        c=parameters.CData;
    end

    dtheta=360/ntheta;

    [T,N,B,s,k,torsion,~,~,~,dsdt]=TNB(curve,tnbArgs{:});

    if(minradius)
        r=1/max(k);
    elseif(reduce)
        if(1/max(k)<r)
            r=1/max(k);
        end
    end

    if(norm(curve(1,:)-curve(end,:))<1e-12)
        closed=true;
    else
        closed=false;
    end

    if(~preserveTorsion)
        [N,B]=removeTorsion(N,B,s/max(s),s,dsdt,torsion,closed,false);
    end
    if(closed)
        if(split)
            if(ntheta<3)
                theta=(0:dtheta:360)'*pi/180+theta_0;
                theta=theta([1 2 2 3]);
                n=size(curve,1);
                m=size(theta,1);
                T=reshape(repmat(permute(T,[3 1 2]),m,1,1),[],3);
                N2=repmat(permute(N,[3 1 2]),m,1,1);
                B2=repmat(permute(B,[3 1 2]),m,1,1);
                N=reshape(repmat(cos(theta),1,n,3).*N2+repmat(sin(theta),1,n,3).*B2,[],3);
                Theta=reshape(repmat(theta,1,n,1),[],1);
                V=reshape(repmat(permute(curve,[3 1 2]),m,1,1),[],3)+r*N;
                F=reshape(mod([1 3;2 4;5 8;2 3;6 8;5 7]+reshape((0:n-2)*m,1,1,[])-1,m*n)+1,3,[])';
                if(useCData)
                    C=reshape(repmat(permute(c,[2 3 1]),1,m,1),size(c,2),[])';
                else
                    C=[];
                end
                N=reshape(repmat(-sin(theta([1 1 3 3])),1,n,3).*N2+repmat(cos(theta([1 1 3 3])),1,n,3).*B2,[],3);
                B=reshape(repmat(-cos(theta([1 1 3 3])),1,n,3).*N2-repmat(sin(theta([1 1 3 3])),1,n,3).*B2,[],3);
            else
                theta=(0:dtheta:360)'*pi/180+theta_0;
                n=size(curve,1);
                m=size(theta,1);
                T=reshape(repmat(permute(T,[3 1 2]),m,1,1),[],3);
                N2=repmat(permute(N,[3 1 2]),m,1,1);
                B2=repmat(permute(B,[3 1 2]),m,1,1);
                N=reshape(repmat(cos(theta),1,n,3).*N2+repmat(sin(theta),1,n,3).*B2,[],3);
                B=reshape(-repmat(sin(theta),1,n,3).*N2+repmat(cos(theta),1,n,3).*B2,[],3);
                Theta=reshape(repmat(theta,1,n,1),[],1);
                V=reshape(repmat(permute(curve,[3 1 2]),m,1,1),[],3)+r*N;
                F=reshape([1:m-1;2:m;m+1:2*m-1;2:m;m+2:2*m;m+1:2*m-1]+reshape((0:n-2)*m,1,1,[]),3,[])';
                if(useCData)
                    C=reshape(repmat(permute(c,[2 3 1]),1,m,1),size(c,2),[])';
                else
                    C=[];
                end
            end
        else
            curve=curve(1:end-1,:);
            T=T(1:end-1,:);
            N=N(1:end-1,:);
            B=B(1:end-1,:);
            theta=(0:dtheta:360)'*pi/180+theta_0;
            theta=theta(1:end-1);
            n=size(curve,1);
            m=size(theta,1);
            T=reshape(repmat(permute(T,[3 1 2]),m,1,1),[],3);
            N2=repmat(permute(N,[3 1 2]),m,1,1);
            B2=repmat(permute(B,[3 1 2]),m,1,1);
            N=reshape(repmat(cos(theta),1,n,3).*N2+repmat(sin(theta),1,n,3).*B2,[],3);
            B=reshape(-repmat(sin(theta),1,n,3).*N2+repmat(cos(theta),1,n,3).*B2,[],3);
            Theta=reshape(repmat(theta,1,n,1),[],1);
            V=reshape(repmat(permute(curve,[3 1 2]),m,1,1),[],3)+r*N;
            if(ntheta<3)
                N=reshape(repmat(-sin(repmat(theta(1),2,1)),1,n,3).*N2+repmat(cos(repmat(theta(1),2,1)),1,n,3).*B2,[],3);
                B=reshape(repmat(-cos(repmat(theta(1),2,1)),1,n,3).*N2-repmat(sin(repmat(theta(1),2,1)),1,n,3).*B2,[],3);
                F=reshape(mod([1;2;3;2;4;3]+reshape((0:n-1)*m,1,1,[])-1,m*n)+1,3,[])';
            else
                F=reshape(mod([1:m;[2:m 1];m+1:2*m;[2:m 1];[m+2:2*m m+1];m+1:2*m]+reshape((0:n-1)*m,1,1,[])-1,m*n)+1,3,[])';
            end
%             F=reshape(mod([1:m;[2:m 1];m+1:2*m;[2:m 1];[m+2:2*m m+1];m+1:2*m]+reshape((0:n-1)*m,1,1,[])-1,m*n)+1,3,[])';
            if(useCData)
                C=reshape(repmat(permute(c(1:end-1,:),[2 3 1]),1,m,1),size(c,2),[])';
            else
                C=[];
            end
        end
    else
        if(split)
            theta=(0:dtheta:360)'*pi/180+theta_0;
            n=size(curve,1);
            m=size(theta,1);
            if(ends)
                phi=(0:dtheta:90-dtheta)';
                if(90-phi(end)>dtheta)
                    phi=(dtheta:dtheta:90)';
                end
                phi=phi*pi/180;
                p=size(phi,1);
                T2=permute(T,[3 1 2]);
                N2=permute(N,[3 1 2]);
                B2=permute(B,[3 1 2]);
                T3=[repmat(reshape(cos(theta)*cos(phi)',[],1),1,3).*repmat(N(1,:),m*p,1)+repmat(reshape(sin(theta)*cos(phi)',[],1),1,3).*repmat(B(1,:),m*p,1)+repmat(reshape(repmat(sin(phi'),m,1),[],1),1,3).*repmat(T(1,:),m*p,1);...
                    reshape(repmat(T2,m,1,1),[],3);...
                    -repmat(reshape(cos(theta)*cos(flip(phi))',[],1),1,3).*repmat(N(end,:),m*p,1)-repmat(reshape(sin(theta)*cos(flip(phi))',[],1),1,3).*repmat(B(end,:),m*p,1)+repmat(reshape(repmat(sin(flip(phi)'),m,1),[],1),1,3).*repmat(T(end,:),m*p,1);...
                    ];
                N3=[repmat(reshape(cos(theta)*sin(phi)',[],1),1,3).*repmat(N(1,:),m*p,1)+repmat(reshape(sin(theta)*sin(phi)',[],1),1,3).*repmat(B(1,:),m*p,1)+repmat(reshape(-repmat(cos(phi'),m,1),[],1),1,3).*repmat(T(1,:),m*p,1);...
                    reshape(repmat(cos(theta),1,n,3).*repmat(N2,m,1,1)+repmat(sin(theta),1,n,3).*repmat(B2,m,1,1),[],3);...
                    repmat(reshape(cos(theta)*sin(flip(phi))',[],1),1,3).*repmat(N(end,:),m*p,1)+repmat(reshape(sin(theta)*sin(flip(phi))',[],1),1,3).*repmat(B(end,:),m*p,1)+repmat(reshape(repmat(cos(flip(phi)'),m,1),[],1),1,3).*repmat(T(end,:),m*p,1);...
                    ];
                B3=[repmat(reshape(repmat(-sin(theta),1,p),[],1),1,3).*repmat(N(1,:),m*p,1)+repmat(reshape(repmat(cos(theta),1,p),[],1),1,3).*repmat(B(1,:),m*p,1);...
                    reshape(repmat(cos(theta),1,n,3).*repmat(B2,m,1,1)-repmat(sin(theta),1,n,3).*repmat(N2,m,1,1),[],3);...
                    repmat(reshape(repmat(-sin(theta),1,p),[],1),1,3).*repmat(N(end,:),m*p,1)+repmat(reshape(repmat(cos(theta),1,p),[],1),1,3).*repmat(B(end,:),m*p,1);...
                    ];
                T=T3;
                N=N3;
                B=B3;
                Theta=[
                    reshape(repmat(theta,1,p),[],1);...
                    reshape(repmat(theta,1,n,1),[],1);...
                    reshape(repmat(theta,1,p),[],1);...
                    ];

                V=[repmat(curve(1,:),m*p,1);reshape(repmat(permute(curve,[3 1 2]),m,1,1),[],3);repmat(curve(end,:),m*p,1)]+r*N;
                F=[
                    reshape([1:m-1;2:m;m+1:2*m-1;2:m;m+2:2*m;m+1:2*m-1]+reshape((0:p-1)*m,1,1,[]),3,[]),...
                    reshape([1:m-1;2:m;m+1:2*m-1;2:m;m+2:2*m;m+1:2*m-1]+reshape(p*m+(0:n-2)*m,1,1,[]),3,[]),...
                    reshape((n+p-1)*m+1+[1:m-1;2:m;m+1:2*m-1;2:m;m+2:2*m;m+1:2*m-1]+reshape((0:p-1)*m,1,1,[]),3,[])-1,...
                    ]';
                if(useCData)
                    C=[repmat(c(1,:),m*p,1);reshape(repmat(permute(c,[2 3 1]),1,m,1),size(c,2),[])';repmat(c(end,:),m*p,1);];
                else
                    C=[];
                end
            else
                if(ntheta<3)
                    T2=repmat(permute(T,[3 1 2]),m+1,1,1);
                    N2=repmat(permute(N,[3 1 2]),m+1,1,1);
                    B2=repmat(permute(B,[3 1 2]),m+1,1,1);
                    T=reshape(T2,[],3);
                    theta=theta([1 2 2 3]);
                    N=reshape(repmat(cos(theta),1,n,3).*N2+repmat(sin(theta),1,n,3).*B2,[],3);
                    V=reshape(repmat(permute(curve,[3 1 2]),m+1,1,1),[],3)+r*N;
                    F=reshape(mod([1 3;2 4;5 8;2 3;6 8;5 7]+reshape((0:n-2)*(m+1),1,1,[])-1,(m+1)*n)+1,3,[])';
                    Theta=reshape(repmat(theta,1,n,1),[],1);
                    if(useCData)
                        C=reshape(repmat(permute(c,[2 3 1]),1,m+1,1),size(c,2),[])';
                    else
                        C=[];
                    end
                    N=reshape(repmat(-sin(theta([1 1 3 3])),1,n,3).*N2+repmat(cos(theta([1 1 3 3])),1,n,3).*B2,[],3);
                    B=reshape(repmat(-cos(theta([1 1 3 3])),1,n,3).*N2-repmat(sin(theta([1 1 3 3])),1,n,3).*B2,[],3);
                else
                    T2=repmat(permute(T,[3 1 2]),m,1,1);
                    N2=repmat(permute(N,[3 1 2]),m,1,1);
                    B2=repmat(permute(B,[3 1 2]),m,1,1);
                    T=reshape(T2,[],3);
                    N=reshape(repmat(cos(theta),1,n,3).*N2+repmat(sin(theta),1,n,3).*B2,[],3);
                    B=reshape(-repmat(sin(theta),1,n,3).*N2+repmat(cos(theta),1,n,3).*B2,[],3);
                    F=reshape(mod([1:m-1;2:m;m+1:2*m-1;2:m;m+2:2*m;m+1:2*m-1]+reshape((0:n-2)*m,1,1,[])-1,m*n)+1,3,[])';
                    Theta=reshape(repmat(theta,1,n,1),[],1);
                    V=reshape(repmat(permute(curve,[3 1 2]),m,1,1),[],3)+r*N;
                    if(useCData)
                        C=reshape(repmat(permute(c,[2 3 1]),1,m,1),size(c,2),[])';
                    else
                        C=[];
                    end
                end
            end
        else
            theta=(0:dtheta:360)'*pi/180+theta_0;
            theta=theta(1:end-1);
            n=size(curve,1);
            m=size(theta,1);
            if(ends)
                phi=(dtheta:dtheta:90-dtheta)';
                if(90-phi(end)>dtheta)
                    phi=(dtheta:dtheta:90)';
                end
                phi=phi*pi/180;
                p=size(phi,1);
                T2=permute(T,[3 1 2]);
                N2=permute(N,[3 1 2]);
                B2=permute(B,[3 1 2]);
                T3=[-N(1,:);...
                    repmat(reshape(cos(theta)*cos(phi)',[],1),1,3).*repmat(N(1,:),m*p,1)+repmat(reshape(sin(theta)*cos(phi)',[],1),1,3).*repmat(B(1,:),m*p,1)+repmat(reshape(repmat(sin(phi'),m,1),[],1),1,3).*repmat(T(1,:),m*p,1);...
                    reshape(repmat(T2,m,1,1),[],3);...
                    -repmat(reshape(cos(theta)*cos(flip(phi))',[],1),1,3).*repmat(N(end,:),m*p,1)-repmat(reshape(sin(theta)*cos(flip(phi))',[],1),1,3).*repmat(B(end,:),m*p,1)+repmat(reshape(repmat(sin(flip(phi)'),m,1),[],1),1,3).*repmat(T(end,:),m*p,1);...
                    -N(end,:)...
                    ];
                N3=[-T(1,:);...
                    repmat(reshape(cos(theta)*sin(phi)',[],1),1,3).*repmat(N(1,:),m*p,1)+repmat(reshape(sin(theta)*sin(phi)',[],1),1,3).*repmat(B(1,:),m*p,1)+repmat(reshape(-repmat(cos(phi'),m,1),[],1),1,3).*repmat(T(1,:),m*p,1);...
                    reshape(repmat(cos(theta),1,n,3).*repmat(N2,m,1,1)+repmat(sin(theta),1,n,3).*repmat(B2,m,1,1),[],3);...
                    repmat(reshape(cos(theta)*sin(flip(phi))',[],1),1,3).*repmat(N(end,:),m*p,1)+repmat(reshape(sin(theta)*sin(flip(phi))',[],1),1,3).*repmat(B(end,:),m*p,1)+repmat(reshape(repmat(cos(flip(phi)'),m,1),[],1),1,3).*repmat(T(end,:),m*p,1);...
                    T(end,:)...
                    ];
                B3=[-B(1,:);...
                    repmat(reshape(repmat(-sin(theta),1,p),[],1),1,3).*repmat(N(1,:),m*p,1)+repmat(reshape(repmat(cos(theta),1,p),[],1),1,3).*repmat(B(1,:),m*p,1);...
                    reshape(repmat(cos(theta),1,n,3).*repmat(B2,m,1,1)-repmat(sin(theta),1,n,3).*repmat(N2,m,1,1),[],3);...
                    repmat(reshape(repmat(-sin(theta),1,p),[],1),1,3).*repmat(N(end,:),m*p,1)+repmat(reshape(repmat(cos(theta),1,p),[],1),1,3).*repmat(B(end,:),m*p,1);...
                    B(end,:) ...
                    ];
                T=T3;
                N=N3;
                B=B3;
                Theta=[0;...
                    reshape(repmat(theta,1,p),[],1);...
                    reshape(repmat(theta,1,n,1),[],1);...
                    reshape(repmat(theta,1,p),[],1);...
                    0 ...
                    ];

                V=[repmat(curve(1,:),m*p+1,1);reshape(repmat(permute(curve,[3 1 2]),m,1,1),[],3);repmat(curve(end,:),m*p+1,1)]+r*N;
                F=[...
                    [ones(1,m);3:m+1 2;2:m+1],...
                    reshape(1+[1:m;[2:m 1];m+1:2*m;[2:m 1];[m+2:2*m m+1];m+1:2*m]+reshape((0:p-1)*m,1,1,[]),3,[]),...
                    reshape([1:m;[2:m 1];m+1:2*m;[2:m 1];[m+2:2*m m+1];m+1:2*m]+reshape(p*m+(0:n-2)*m,1,1,[])+1,3,[]),...
                    reshape((n+p-1)*m+1+[1:m;[2:m 1];m+1:2*m;[2:m 1];[m+2:2*m m+1];m+1:2*m]+reshape((0:p-1)*m,1,1,[]),3,[]),...
                    [(m*(n+2*p)+2)*ones(1,m);(n+2*p-1)*m+2:m*(n+2*p)+1;(n+2*p-1)*m+3:m*(n+2*p)+1 (n+2*p-1)*m+2],...
                    ]';
                if(useCData)
                    C=[repmat(c(1,:),m*p+1,1);reshape(repmat(permute(c,[2 3 1]),1,m,1),size(c,2),[])';repmat(c(end,:),m*p+1,1)];
                else
                    C=[];
                end
            else
                T2=repmat(permute(T,[3 1 2]),m,1,1);
                N2=repmat(permute(N,[3 1 2]),m,1,1);
                B2=repmat(permute(B,[3 1 2]),m,1,1);
                T=reshape(T2,[],3);
                N=reshape(repmat(cos(theta),1,n,3).*N2+repmat(sin(theta),1,n,3).*B2,[],3);
                B=reshape(-repmat(sin(theta),1,n,3).*N2+repmat(cos(theta),1,n,3).*B2,[],3);
                Theta=reshape(repmat(theta,1,n,1),[],1);
                V=reshape(repmat(permute(curve,[3 1 2]),m,1,1),[],3)+r*N;
                if(ntheta<3)
                    N=reshape(repmat(-sin(repmat(theta(1),2,1)),1,n,3).*N2+repmat(cos(repmat(theta(1),2,1)),1,n,3).*B2,[],3);
                    B=reshape(repmat(-cos(repmat(theta(1),2,1)),1,n,3).*N2-repmat(sin(repmat(theta(1),2,1)),1,n,3).*B2,[],3);
                    F=reshape(mod([1;2;3;2;4;3]+reshape((0:n-2)*m,1,1,[])-1,m*n)+1,3,[])';
                else
                    F=reshape(mod([1:m;[2:m 1];m+1:2*m;[2:m 1];[m+2:2*m m+1];m+1:2*m]+reshape((0:n-2)*m,1,1,[])-1,m*n)+1,3,[])';
                end
                if(useCData)
                    C=reshape(repmat(permute(c,[2 3 1]),1,m,1),size(c,2),[])';
                else
                    C=[];
                end
            end
        end
    end
    T=[T ones(size(T,1),1)];
    out={F,V,C,N,T,-B,Theta,r};
    varargout=cell(1,nargout);
    for i=1:nargout
        varargout{i}=out{i};
    end
end
