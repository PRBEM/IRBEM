function [Lstar,J] = onera_desp_lib_empiricallstar(kext,options,sysaxes,matlabd,x1,x2,x3,maginput,Lm)
%***************************************************************************************************
% Copyright 2006-2009, T.P. O'Brien
%
% This file is part of IRBEM-LIB.
%
%    IRBEM-LIB is free software: you can redistribute it and/or modify
%    it under the terms of the GNU Lesser General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    IRBEM-LIB is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU Lesser General Public License for more details.
%
%    You should have received a copy of the GNU Lesser General Public License
%    along with IRBEM-LIB.  If not, see <http://www.gnu.org/licenses/>.
%
%***************************************************************************************************
% [Lstar,J] = onera_desp_lib_empiricallstar(kext,options,sysaxes,matlabd,x1,x2,x3,maginput,Lm)
% compute fast Lstar, J
% inputs/outputs have identical meaning to onera_desp_lib_make_lstar
% Works for Olson-Pfitzer Quiet only (ignores kext and field model options)
% ignores noLstar and makePhi option, always gives Lstar
% set maginput to [] if not needed by kext
% currently only works for Olson-Pfitzer Quiet

matlabd = datenum(matlabd);

onera_desp_lib_load;

ntime = length(x1);
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

siz_in = size(x1);

Nmax = 100000; % maximum array size in fortran library
Lstar = repmat(nan,Nmax,1);
J = Lm;
if ntime>Nmax,
    % break up the calculation into chunks the libarary can handle
    for i = 1:Nmax:ntime,
        ii = i:min(i+Nmax-1,ntime);
        [Lstar(ii),J(ii)] = ...
            onera_desp_lib_make_lstar(kext,options,sysaxes,matlabd(ii),x1(ii),x2(ii),x3(ii),maginput(ii,:),Lm);
    end
else
    [iyear,idoy,UT] = onera_desp_lib_matlabd2yds(matlabd);
    LmPtr = libpointer('doublePtr',Lm);
    LstarPtr = libpointer('doublePtr',Lstar);
    BlocalPtr = libpointer('doublePtr',Blocal);
    BminPtr = libpointer('doublePtr',Bmin);
    JPtr = libpointer('doublePtr',J);
    MLTPtr = libpointer('doublePtr',MLT);
    maginput = maginput';
    % expand arrays
    iyear = [iyear(:)', repmat(nan,1,Nmax-ntime)];
    idoy = [idoy(:)', repmat(nan,1,Nmax-ntime)];
    UT = [UT(:)', repmat(nan,1,Nmax-ntime)];
    x1 = [x1(:)', repmat(nan,1,Nmax-ntime)];
    x2 = [x2(:)', repmat(nan,1,Nmax-ntime)];
    x3 = [x3(:)', repmat(nan,1,Nmax-ntime)];
    maginput = [maginput, repmat(nan,25,Nmax-ntime)];
    Lm = [Lm(:)', repmat(nan,1,Nmax-ntime)];
    
    calllib('onera_desp_lib','empriciallstar1_',ntime,kext,options,sysaxes,iyear,idoy,UT,x1,x2,x3,maginput,Lm,...
        LstarPtr,JPtr);
    % have to do this next bit because Ptr's aren't really pointers
    Lstar = get(LstarPtr,'value');
    J = get(JPtr,'value');
end

% the flag value is actually -1d31
Lstar(Lstar<-1e30) = nan;
J(J<-1e30) = nan;

% truncate arrays
Lstar = Lstar(1:ntime);
J = J(1:ntime);

Lstar = reshape(Lstar,siz_in);
J = reshape(J,siz_in);
