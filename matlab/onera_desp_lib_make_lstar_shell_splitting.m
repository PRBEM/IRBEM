function [Lm,Lstar,Blocal,Bmin,J,MLT] = onera_desp_lib_make_lstar_shell_splitting(kext,options,sysaxes,matlabd,x1,x2,x3,alpha,maginput)
%***************************************************************************************************
% Copyright 2006, T.P. O'Brien
%
% This file is part of ONERA_DESP_LIB.
%
%    ONERA_DESP_LIB is free software: you can redistribute it and/or modify
%    it under the terms of the GNU Lesser General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    ONERA_DESP_LIB is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU Lesser General Public License for more details.
%
%    You should have received a copy of the GNU Lesser General Public License
%    along with ONERA_DESP_LIB.  If not, see <http://www.gnu.org/licenses/>.
%
%***************************************************************************************************
%
% function [Lm,Lstar,Blocal,Bmin,J,MLT] = onera_desp_lib_make_lstar_shell_splitting(kext,options,sysaxes,matlabd,x1,x2,x3,alpha,maginput)
% returns magnetic coordinates as described in onera documentation
% Lm, Lstar, Blocal, and J are length(x1) x length(alpha)
% Bmin and MLT are length(x1) x 1
% kext - specified the external field model
% For the kext argument, see helps for onera_desp_lib_kext
% options - controls the field tracing
% For the options argument, see helps for onera_desp_lib_options
% sysaxes - sets the coordinate system for the input points
% For the sysaxes argument, see helps for onera_desp_lib_sysaxes
% x1, x2, and x3 are the points of interest in the system specified by sysaxes
% alpha - vector of local pitch angles (degrees)
% maginput - [length(x1) x 25] provides inputs to dynamic external field models
% (if maginput is omitted or empty, then a matrix of zeros is assumed)
% maginput(1st element,*) =Kp: value of Kp as in OMNI2 files but has to be double instead of integer type
% maginput(2nd element,*) =Dst: Dst index (nT)
% maginput(3rd element,*) =dens: Solar Wind density (cm-3)
% maginput(4th element,*) =velo: Solar Wind velocity (km/s)
% maginput(5th element,*) =Pdyn: Solar Wind dynamic pressure (nPa)
% maginput(6th element,*) =ByIMF: GSM y component of IMF mag. field (nT)
% maginput(7th element,*) =BzIMF: GSM z component of IMF mag. field (nT)
% maginput(8th element,*) =G1:  G1=< Vsw*(Bperp/40)^2/(1+Bperp/40)*sin^3(theta/2) > where the <> mean an average over the previous 1 hour, Vsw is the solar wind speed, Bperp is the transverse IMF component (GSM) and theta it's clock angle.
% maginput(9th element,*) =G2: G2=< a*Vsw*Bs > where the <> mean an average over the previous 1 hour, Vsw is the solar wind speed, Bs=|IMF Bz| when IMF Bz < 0 and Bs=0 when IMF Bz > 0, a=0.005.
% maginput(10th element,*) =G3:  G3=< Vsw*Dsw*Bs /2000.>
% where the <> mean an average over the previous 1 hour, Vsw is the solar wind speed, Dsw is the solar wind density, Bs=|IMF Bz| when IMF Bz < 0 and Bs=0 when IMF Bz > 0.
% maginput(11th element,*) =W1 see definition in (JGR-A, v.110(A3), 2005.) (PDF 1.2MB)
% maginput(12th element,*) =W2 see definition in (JGR-A, v.110(A3), 2005.) (PDF 1.2MB)
% maginput(13th element,*) =W3 see definition in (JGR-A, v.110(A3), 2005.) (PDF 1.2MB)
% maginput(14th element,*) =W4 see definition in (JGR-A, v.110(A3), 2005.) (PDF 1.2MB)
% maginput(15th element,*) =W5 see definition in (JGR-A, v.110(A3), 2005.) (PDF 1.2MB)
% maginput(16th element,*) =W6 see definition in (JGR-A, v.110(A3), 2005.) (PDF 1.2MB)
% maginput(17th element,*) =AL the auroral index
%
% maginput(18th element,*) to maginput(25th element,*): for future use
%
% IMPORTANT: all inputs must be present. For those which are not used a dummy value can be provided.
%

if nargin < 9,
    maginput = [];
end

matlabd = datenum(matlabd);

onera_desp_lib_load;

ntime = length(x1);
nipa = length(alpha);
kext = onera_desp_lib_kext(kext);
options = onera_desp_lib_options(options);
sysaxes = onera_desp_lib_sysaxes(sysaxes);
if isempty(maginput),
    maginput = zeros(ntime,25);
end
if size(maginput,2) == 1, % make column vector into row vector
    maginput = maginput';
end
if size(maginput,1) ~= ntime,
    maginput = repmat(maginput,ntime,1);
end
if length(matlabd)==1,
    matlabd = repmat(matlabd,ntime,1);
end

Nmax = 100000; % maximum array size in fortran library
Nmaxpa = 25; % maximum number of pitch angles
Lm = repmat(nan,Nmax,Nmaxpa);
Lstar = repmat(nan,Nmax,Nmaxpa);
Blocal = repmat(nan,Nmax,Nmaxpa);
Bmin = repmat(nan,Nmax,1);
J = repmat(nan,Nmax,Nmaxpa);
MLT = repmat(nan,Nmax,1);
if ntime>Nmax,
    % break up the calculation into chunks the libarary can handle
    for i = 1:Nmax:ntime,
        ii = i:min(i+Nmax-1,ntime);
        [Lm(ii,:),Lstar(ii,:),Blocal(ii,:),Bmin(ii),J(ii,:),MLT(ii)] = ...
            onera_desp_lib_make_lstar_shell_splitting(kext,options,sysaxes,matlabd(ii),x1(ii),x2(ii),x3(ii),alpha,maginput(ii,:));
    end
elseif nipa>Nmaxpa,
    % break up the calculation into chunks the libarary can handle
    for i = 1:Nmaxpa:nipa,
        ii = i:min(i+Nmaxpa-1,nipa);
        [Lm(:,ii),Lstar(:,ii),Blocal(:,ii),Bmin(:),J(:,ii),MLT(:)] = ...
            onera_desp_lib_make_lstar_shell_splitting(kext,options,sysaxes,matlabd,x1,x2,x3,alpha(ii),maginput);
    end
else
    [iyear,idoy,UT] = onera_desp_lib_matlabd2yds(matlabd);
    LmPtr = libpointer('doublePtr',Lm);
    LstarPtr = libpointer('doublePtr',Lstar);
    BlocalPtr = libpointer('doublePtr',Blocal);
    BminPtr = libpointer('doublePtr',Bmin);
    JPtr = libpointer('doublePtr',J);
    MLTPtr = libpointer('doublePtr',MLT);
    if nipa<Nmaxpa,
        alpha = [alpha(:)',repmat(nan,1,Nmaxpa-nipa)];
    end
    maginput = maginput';
    % expand arrays
    iyear = [iyear(:)', repmat(nan,1,Nmax-ntime)];
    idoy = [idoy(:)', repmat(nan,1,Nmax-ntime)];
    UT = [UT(:)', repmat(nan,1,Nmax-ntime)];
    x1 = [x1(:)', repmat(nan,1,Nmax-ntime)];
    x2 = [x2(:)', repmat(nan,1,Nmax-ntime)];
    x3 = [x3(:)', repmat(nan,1,Nmax-ntime)];
    maginput = [maginput, repmat(nan,25,Nmax-ntime)];
    calllib('onera_desp_lib','make_lstar_shell_splitting1_',ntime,nipa,kext,options,sysaxes,iyear,idoy,UT,x1,x2,x3,alpha,maginput,...
        LmPtr,LstarPtr,BlocalPtr,BminPtr,JPtr,MLTPtr);
    % have to do this next bit because Ptr's aren't really pointers
    Lm = get(LmPtr,'value');
    Lstar = get(LstarPtr,'value');
    Blocal = get(BlocalPtr,'value');
    Bmin = get(BminPtr,'value');
    J = get(JPtr,'value');
    MLT = get(MLTPtr,'value');
end

% the flag value is actually -1d31
Lm(Lm<-1e30) = nan;
Lstar(Lstar<-1e30) = nan;
Blocal(Blocal<-1e30) = nan;
Bmin(Bmin<-1e30) = nan;
J(J<-1e30) = nan;
MLT(MLT<-1e30) = nan;

Lm = Lm(1:ntime,1:nipa);
Lstar = Lstar(1:ntime,1:nipa);
Blocal = Blocal(1:ntime,1:nipa);
Bmin = Bmin(1:ntime);
J = J(1:ntime,1:nipa);
MLT = MLT(1:ntime);
