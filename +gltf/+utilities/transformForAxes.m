function varargout=transformForAxes(V,varargin)
    % Return vertices and optionally normals transformed to look visually
    % the same as the MATLAB axis.
    %
    % Vax=TRANSFORMFORAXES(V) returns the vertices V transformed to look
    % visually the same as the MATLAB axis.
    %
    % [Vax,Nax]=TRANSFORMFORAXES(V,N) returns the vertices V and normals N
    % transformed to look visually the same as the MATLAB axis.
    %
    % [Vax,Nax,Dax]=TRANSFORMFORAXES(V,N,D) returns the vertices V, normals
    % N, and displacements D transformed to look visually the same as the
    % MATLAB axis.
    %
    % TRANSFORMFORAXES(...,'axis',axis) specifies the axis object to use
    % instead of the current one.
    %
    % © Copyright 2014-2026 Rohan Chabukswar.
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
    if(nargin>0)
        N=[];
        D=[];
        if(nargin>1)
            firstarg=varargin{1};
            if(isnumeric(firstarg))
                N=firstarg;
                varargin=varargin(2:end);
                if(nargin>2)
                    secondarg=varargin{1};
                    if(isnumeric(secondarg))
                        D=secondarg;
                        varargin=varargin(2:end);
                    end
                end
            end
            ips=inputParser;
            ips.StructExpand=false;
            ips.addParameter('axis',[],@(x)isa(x,'matlab.graphics.axis.Axes'));
            ips.parse(varargin{:});
            parameters=ips.Results;
            ax_h=parameters.axis;
            if(isempty(ax_h))
                ax_h=gca;
            end
        else
            ax_h=gca;
        end
        ax=axis(ax_h);
        ax=reshape(ax,2,3);
        scales=string({ax_h.XScale,ax_h.YScale,ax_h.ZScale});
        logAxes=scales=="log";
        if(any(logAxes))
            ax(:,logAxes)=log10(ax(:,logAxes));
        end
        axisMin=ax(1,:);
        axisSpan=diff(ax,1,1);
        plotBoxAspect=pbaspect(ax_h);
        s=plotBoxAspect./axisSpan;
        Vax=V;
        if(any(logAxes))
            Vax(:,logAxes)=log10(V(:,logAxes));
        end
        if(~isempty(V))
            Vax=(Vax-axisMin).*s;
        end
        Nax=N;
        if(~isempty(N))
            Nax=Nax./vecnorm(Nax,2,2);
            for k=find(logAxes)
                Nax(:,k)=Nax(:,k).*V(:,k)*log(10);
            end
            Nax=Nax./s;
            Nax=Nax./vecnorm(Nax,2,2);
        end
        Dax=D;
        if(~isempty(D))
            for k=find(logAxes)
                Dax(:,k)=Dax(:,k)./V(:,k)/log(10);
            end
            Dax=Dax.*s;
        end
        out={Vax,Nax,Dax};
        varargout=out(1:nargout);
    end
end