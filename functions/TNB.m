function [T,N,B,s,k,t,first,second,third,dsdt]=TNB(curve,varargin)
    % Calculate the TNB frame along a curve given as an Nx3 variable CURVE,
    % and return the tangent T, normal N, binormal B, curve length S,
    % curvature K, torsion T, the FIRST, SECOND, and THIRD derivatives of
    % the curve, and the speed along the curve DSDT.
    %
    % [T,N,B,s,k,t,first,second,third,dsdt]=TNB(...,'FirstDerivative',FIRST)
    % uses FIRST as the first derivative of the curve. If not provided, it
    % is computed using central differences on CURVE where possible, and
    % forward and backward differences at the ends.
    %
    % [T,N,B,s,k,t,first,second,third,dsdt]=TNB(...,'SecondDerivative',SECOND)
    % uses SECOND as the second derivative of the curve. If not provided,
    % and FirstDerivative is provided, it is computed using central
    % differences on FIRST where possible, and forward and backward
    % differences at the ends. If FirstDerivative is not provided, it is
    % computed using central differences on CURVE where possible, and
    % forward and backward differences at the ends.
    %
    % [T,N,B,s,k,t,first,second,third,dsdt]=TNB(...,'ThirdDerivative',THIRD)
    % uses THIRD as the third derivative of the curve. If not provided, and
    % SecondDerivative is provided, it is computed using central
    % differences on SECOND where possible, and forward and backward
    % differences at the ends. If SecondDerivative is not provided, but
    % FirstDerivative is provided, it is computed using central differences
    % on FIRST where possible, and forward and backward differences at the
    % ends. If neither SecondDerivative nor FirstDerivative are provided,
    % it is computed using central differences on CURVE where possible, and
    % forward and backward differences at the ends.
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

    ips=inputParser;
    addParameter(ips,'FirstDerivative',nan,@isnumeric)
    addParameter(ips,'SecondDerivative',nan,@isnumeric)
    addParameter(ips,'ThirdDerivative',nan,@isnumeric)
    parse(ips,varargin{:});
    parameters=ips.Results;

    last_given=0;
    if(and(size(curve,1)>1,norm(curve(1,:)-curve(end,:))<1e-12))
        closed=true;
    else
        closed=false;
    end
    if(closed)
        curve=curve(1:end-1,:);
        if(ismember('FirstDerivative',ips.UsingDefaults))
            first=(circshift(curve,-1)-circshift(curve,1))/2;
        else
            first=parameters.FirstDerivative;
            first=first(1:end-1,:);
            last_given=1;
        end
        if(ismember('SecondDerivative',ips.UsingDefaults))
            if(last_given==1)
                second=(circshift(first,-1)-circshift(first,1))/2;
            else
                second=circshift(curve,-1)-2*curve+circshift(curve,1);
            end
        else
            second=parameters.SecondDerivative;
            second=second(1:end-1,:);
            last_given=2;
        end
        if(ismember('ThirdDerivative',ips.UsingDefaults))
            if(last_given==2)
                third=(circshift(second,-1)-circshift(second,1))/2;
            elseif(last_given==1)
                third=circshift(first,-1)-2*first+circshift(first,1);
            else
                third=(circshift(curve,-2)-2*circshift(curve,-1)+2*circshift(curve,1)-circshift(curve,2))/2;
            end
        else
            third=parameters.ThirdDerivative;
            third=third(1:end-1,:);
        end
    else
        if(ismember('FirstDerivative',ips.UsingDefaults))
            first=[curve(2,:)-curve(1,:);(curve(3:end,:)-curve(1:end-2,:))/2;curve(end,:)-curve(end-1,:)];
        else
            first=parameters.FirstDerivative;
            last_given=1;
        end
        if(ismember('SecondDerivative',ips.UsingDefaults))
            if(last_given==1)
                second=[first(2,:)-first(1,:);(first(3:end,:)-first(1:end-2,:))/2;first(end,:)-first(end-1,:)];
            else
                second=curve([3 3:end end],:)-2*curve([2 2:end-1 end-1],:)+curve([1 1:end-2 end-2],:);
            end
        else
            second=parameters.SecondDerivative;
            last_given=2;
        end
        if(ismember('ThirdDerivative',ips.UsingDefaults))
            if(last_given==2)
                third=[second(2,:)-second(1,:);(second(3:end,:)-second(1:end-2,:))/2;second(end,:)-second(end-1,:)];
            elseif(last_given==1)
                third=first([3 3:end end],:)-2*first([2 2:end-1 end-1],:)+first([1 1:end-2 end-2],:);
            else
                third=[repmat(curve(4,:)-3*curve(3,:)+3*curve(2,:)-curve(1,:),2,1);(curve(5:end,:)-2*curve(4:end-1,:)+2*curve(2:end-3,:)-curve(1:end-4,:))/2;repmat(curve(end,:)-3*curve(end-1,:)+3*curve(end-2,:)-curve(end-3,:),2,1)];
            end
        else
            third=parameters.ThirdDerivative;
        end
    end

    dsdt=sqrt(sum(first.^2,2));
    s=cumsum(dsdt);
    send=s(end);
    s=[0;s(1:end-1)];
    T=first./dsdt;

    fixing_idx=find(any(isnan(T),2));
    nonfixing_idx=find(all(~isnan(T),2));
    if(closed)
        if(and(~isempty(nonfixing_idx),~isempty(fixing_idx)))
            T(fixing_idx(fixing_idx<nonfixing_idx(1)),1)=interp1([s(nonfixing_idx(end))-s(end);s(nonfixing_idx(1))],T([nonfixing_idx(end) nonfixing_idx(1)],1),s(fixing_idx(fixing_idx<nonfixing_idx(1))),'linear');
            T(fixing_idx(fixing_idx<nonfixing_idx(1)),2)=interp1([s(nonfixing_idx(end))-s(end);s(nonfixing_idx(1))],T([nonfixing_idx(end) nonfixing_idx(1)],2),s(fixing_idx(fixing_idx<nonfixing_idx(1))),'linear');
            T(fixing_idx(fixing_idx<nonfixing_idx(1)),3)=interp1([s(nonfixing_idx(end))-s(end);s(nonfixing_idx(1))],T([nonfixing_idx(end) nonfixing_idx(1)],3),s(fixing_idx(fixing_idx<nonfixing_idx(1))),'linear');
            T(fixing_idx(fixing_idx>nonfixing_idx(end)),1)=interp1([s(nonfixing_idx(end));s(nonfixing_idx(1))+s(end)],T([nonfixing_idx(end) nonfixing_idx(1)],1),s(fixing_idx(fixing_idx>nonfixing_idx(end))),'linear');
            T(fixing_idx(fixing_idx>nonfixing_idx(end)),2)=interp1([s(nonfixing_idx(end));s(nonfixing_idx(1))+s(end)],T([nonfixing_idx(end) nonfixing_idx(1)],2),s(fixing_idx(fixing_idx>nonfixing_idx(end))),'linear');
            T(fixing_idx(fixing_idx>nonfixing_idx(end)),3)=interp1([s(nonfixing_idx(end));s(nonfixing_idx(1))+s(end)],T([nonfixing_idx(end) nonfixing_idx(1)],3),s(fixing_idx(fixing_idx>nonfixing_idx(end))),'linear');
            T(fixing_idx(and(fixing_idx>nonfixing_idx(1),fixing_idx<nonfixing_idx(end))),1)=interp1(s(nonfixing_idx),T(nonfixing_idx,1),s(fixing_idx(and(fixing_idx>nonfixing_idx(1),fixing_idx<nonfixing_idx(end)))),'linear');
            T(fixing_idx(and(fixing_idx>nonfixing_idx(1),fixing_idx<nonfixing_idx(end))),2)=interp1(s(nonfixing_idx),T(nonfixing_idx,2),s(fixing_idx(and(fixing_idx>nonfixing_idx(1),fixing_idx<nonfixing_idx(end)))),'linear');
            T(fixing_idx(and(fixing_idx>nonfixing_idx(1),fixing_idx<nonfixing_idx(end))),3)=interp1(s(nonfixing_idx),T(nonfixing_idx,3),s(fixing_idx(and(fixing_idx>nonfixing_idx(1),fixing_idx<nonfixing_idx(end)))),'linear');
        end
    else
        if(and(~isempty(nonfixing_idx),~isempty(fixing_idx)))
            T(fixing_idx(fixing_idx<nonfixing_idx(1)),:)=repmat(T(nonfixing_idx(1),:),nnz(fixing_idx<nonfixing_idx(1)),1);
            T(fixing_idx(fixing_idx>nonfixing_idx(end)),:)=repmat(T(nonfixing_idx(end),:),nnz(fixing_idx>nonfixing_idx(end)),1);
            T(fixing_idx(and(fixing_idx>nonfixing_idx(1),fixing_idx<nonfixing_idx(end))),1)=interp1(s(nonfixing_idx),T(nonfixing_idx,1),s(fixing_idx(and(fixing_idx>nonfixing_idx(1),fixing_idx<nonfixing_idx(end)))),'linear');
            T(fixing_idx(and(fixing_idx>nonfixing_idx(1),fixing_idx<nonfixing_idx(end))),2)=interp1(s(nonfixing_idx),T(nonfixing_idx,2),s(fixing_idx(and(fixing_idx>nonfixing_idx(1),fixing_idx<nonfixing_idx(end)))),'linear');
            T(fixing_idx(and(fixing_idx>nonfixing_idx(1),fixing_idx<nonfixing_idx(end))),3)=interp1(s(nonfixing_idx),T(nonfixing_idx,3),s(fixing_idx(and(fixing_idx>nonfixing_idx(1),fixing_idx<nonfixing_idx(end)))),'linear');
        end
    end

    if(size(curve,2)>2)
        d2sdt2=sum(first.*second,2)./dsdt;
        dTds=(dsdt.*second-d2sdt2.*first)./dsdt.^3;
        N=dTds./sqrt(sum(dTds.^2,2));
        fixing_idx=find(any(isnan(N),2));
        v=[1 exp(1) pi];
        N(fixing_idx,:)=(v-T(fixing_idx,:)*v'.*T(fixing_idx,:))./sqrt(sum((v-T(fixing_idx,:)*v'.*T(fixing_idx,:)).^2,2));
        fixing_idx=find(any(isnan(N),2));
        v=[1 pi exp(1)];
        N(fixing_idx,:)=(v-T(fixing_idx,:)*v'.*T(fixing_idx,:))./sqrt(sum((v-T(fixing_idx,:)*v'.*T(fixing_idx,:)).^2,2));
        absdTds=sqrt(dsdt.^2.*sum(second.^2,2)+d2sdt2.^2.*sum(first.^2,2)-2*d2sdt2.^2.*dsdt.^2)./dsdt.^3;
        d3sdt3=(sum(first.*third,2)+sum(second.^2,2))./dsdt-d2sdt2.^2./dsdt;
        d2Tds2=(dsdt.*third-d3sdt3.*first)./dsdt.^4-3*d2sdt2.*(dsdt.*second-d2sdt2.*first)./dsdt.^5;
        dabsdTdsds=(dsdt.*d2sdt2.*sum(second.^2,2)+dsdt.^2.*sum(second.*third,2)+d2sdt2.*d3sdt3.*sum(first.^2,2)+d2sdt2.^2.*sum(first.*second,2)-2*dsdt.*d2sdt2.^3-2*dsdt.^2.*d2sdt2.*d3sdt3)./sqrt(dsdt.^2.*sum(second.^2,2)+d2sdt2.^2.*sum(first.^2,2)-2*d2sdt2.^2.*dsdt.^2)./dsdt.^4-3*d2sdt2.*sqrt(dsdt.^2.*sum(second.^2,2)+d2sdt2.^2.*sum(first.^2,2)-2*d2sdt2.^2.*dsdt.^2)./dsdt.^5;
        dabsdTdsds(isnan(dabsdTdsds))=0;
        dNds=(absdTds.*d2Tds2-dabsdTdsds.*dTds)./absdTds.^2;
    %     fixing_idx=find(any(isnan(dNds),2));
    %     dNds=zeros(nnz(fixing_idx),3);
        B=cross(T,N,2);
        B=B./sqrt(sum(B.^2,2));

        fixing_idx=find(any(isnan(B),2));
        nonfixing_idx=find(all(~isnan(B),2));
        if(closed)
            if(and(~isempty(nonfixing_idx),~isempty(fixing_idx)))
                B(fixing_idx(fixing_idx<nonfixing_idx(1)),1)=interp1([s(nonfixing_idx(end))-s(end);s(nonfixing_idx(1))],B([nonfixing_idx(end) nonfixing_idx(1)],1),s(fixing_idx(fixing_idx<nonfixing_idx(1))),'linear');
                B(fixing_idx(fixing_idx<nonfixing_idx(1)),2)=interp1([s(nonfixing_idx(end))-s(end);s(nonfixing_idx(1))],B([nonfixing_idx(end) nonfixing_idx(1)],2),s(fixing_idx(fixing_idx<nonfixing_idx(1))),'linear');
                B(fixing_idx(fixing_idx<nonfixing_idx(1)),3)=interp1([s(nonfixing_idx(end))-s(end);s(nonfixing_idx(1))],B([nonfixing_idx(end) nonfixing_idx(1)],3),s(fixing_idx(fixing_idx<nonfixing_idx(1))),'linear');
                B(fixing_idx(fixing_idx>nonfixing_idx(end)),1)=interp1([s(nonfixing_idx(end));s(nonfixing_idx(1))+s(end)],B([nonfixing_idx(end) nonfixing_idx(1)],1),s(fixing_idx(fixing_idx>nonfixing_idx(end))),'linear');
                B(fixing_idx(fixing_idx>nonfixing_idx(end)),2)=interp1([s(nonfixing_idx(end));s(nonfixing_idx(1))+s(end)],B([nonfixing_idx(end) nonfixing_idx(1)],2),s(fixing_idx(fixing_idx>nonfixing_idx(end))),'linear');
                B(fixing_idx(fixing_idx>nonfixing_idx(end)),3)=interp1([s(nonfixing_idx(end));s(nonfixing_idx(1))+s(end)],B([nonfixing_idx(end) nonfixing_idx(1)],3),s(fixing_idx(fixing_idx>nonfixing_idx(end))),'linear');
                B(fixing_idx(and(fixing_idx>nonfixing_idx(1),fixing_idx<nonfixing_idx(end))),1)=interp1(s(nonfixing_idx),B(nonfixing_idx,1),s(fixing_idx(and(fixing_idx>nonfixing_idx(1),fixing_idx<nonfixing_idx(end)))),'linear');
                B(fixing_idx(and(fixing_idx>nonfixing_idx(1),fixing_idx<nonfixing_idx(end))),2)=interp1(s(nonfixing_idx),B(nonfixing_idx,2),s(fixing_idx(and(fixing_idx>nonfixing_idx(1),fixing_idx<nonfixing_idx(end)))),'linear');
                B(fixing_idx(and(fixing_idx>nonfixing_idx(1),fixing_idx<nonfixing_idx(end))),3)=interp1(s(nonfixing_idx),B(nonfixing_idx,3),s(fixing_idx(and(fixing_idx>nonfixing_idx(1),fixing_idx<nonfixing_idx(end)))),'linear');
                N(fixing_idx,:)=cross(B(fixing_idx,:),T(fixing_idx,:),2);
                N(fixing_idx,:)=N(fixing_idx,:)./sqrt(sum(N(fixing_idx,:).^2,2));
            end
        else
            if(and(~isempty(nonfixing_idx),~isempty(fixing_idx)))
                B(fixing_idx(fixing_idx<nonfixing_idx(1)),:)=repmat(B(nonfixing_idx(1),:),nnz(fixing_idx<nonfixing_idx(1)),1);
                B(fixing_idx(fixing_idx>nonfixing_idx(end)),:)=repmat(B(nonfixing_idx(end),:),nnz(fixing_idx>nonfixing_idx(end)),1);
                B(fixing_idx(and(fixing_idx>nonfixing_idx(1),fixing_idx<nonfixing_idx(end))),1)=interp1(s(nonfixing_idx),B(nonfixing_idx,1),s(fixing_idx(and(fixing_idx>nonfixing_idx(1),fixing_idx<nonfixing_idx(end)))),'linear');
                B(fixing_idx(and(fixing_idx>nonfixing_idx(1),fixing_idx<nonfixing_idx(end))),2)=interp1(s(nonfixing_idx),B(nonfixing_idx,2),s(fixing_idx(and(fixing_idx>nonfixing_idx(1),fixing_idx<nonfixing_idx(end)))),'linear');
                B(fixing_idx(and(fixing_idx>nonfixing_idx(1),fixing_idx<nonfixing_idx(end))),3)=interp1(s(nonfixing_idx),B(nonfixing_idx,3),s(fixing_idx(and(fixing_idx>nonfixing_idx(1),fixing_idx<nonfixing_idx(end)))),'linear');
                N(fixing_idx,:)=cross(B(fixing_idx,:),T(fixing_idx,:),2);
                N(fixing_idx,:)=N(fixing_idx,:)./sqrt(sum(N(fixing_idx,:).^2,2));
            end
        end
        k=sqrt(sum(dTds.^2,2));
        t=mean((dNds+k.*T)./B,2,'omitnan');
    else
        d2sdt2=sum(first.*second,2)./dsdt;
        dTds=(dsdt.*second-d2sdt2.*first)./dsdt.^3;
        N=dTds./sqrt(sum(dTds.^2,2));
        k=sqrt(sum(dTds.^2,2));
        B=nan(size(k,1),2);
        t=zeros(size(k,1),1);
    end

    if(closed)
        T=T([1:end 1],:);
        N=N([1:end 1],:);
        B=B([1:end 1],:);
        k=k([1:end 1]);
        t=t([1:end 1]);
        first=first([1:end 1],:);
        second=second([1:end 1],:);
        third=third([1:end 1],:);
        dsdt=dsdt([1:end 1],:);
        s=[s;send];
    end
end
