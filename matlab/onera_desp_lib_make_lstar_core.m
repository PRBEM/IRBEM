function [Lm,Lstar,Blocal,Bmin,J,MLT] = onera_desp_lib_make_lstar_core(func_name,kext,options,sysaxes,matlabd,x1,x2,x3,maginput)
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
% [Lm,Lstar,Blocal,Bmin,J,MLT] = onera_desp_lib_make_lstar_core(func_name,kext,options,sysaxes,matlabd,x1,x2,x3,maginput)
% wrapper for variants of make_lstar
% func_name is a string that identifies which DLL function to call.
% other inputs/outputs identical to onera_desp_lib_make_lstar

if nargin < 9,
    maginput = [];
end

switch(lower(func_name)),
    case 'make_lstar', libfunc_name = 'make_lstar1_';
    case 'landi2lstar', libfunc_name = 'landi2lstar1_';
    otherwise
        error('Unknown func_name %s',func_name);
end

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
Lm = repmat(nan,Nmax,1);
Lstar = Lm;
Blocal = Lm;
Bmin = Lm;
J = Lm;
MLT = Lm;
if ntime>Nmax,
    % break up the calculation into chunks the libarary can handle
    for i = 1:Nmax:ntime,
        ii = i:min(i+Nmax-1,ntime);
        [Lm(ii),Lstar(ii),Blocal(ii),Bmin(ii),J(ii),MLT(ii)] = ...
            onera_desp_lib_make_lstar(kext,options,sysaxes,matlabd(ii),x1(ii),x2(ii),x3(ii),maginput(ii,:));
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
    
    calllib('onera_desp_lib',libfunc_name,ntime,kext,options,sysaxes,iyear,idoy,UT,x1,x2,x3,maginput,...
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

% truncate arrays
Lm = Lm(1:ntime);
Lstar = Lstar(1:ntime);
Blocal = Blocal(1:ntime);
Bmin = Bmin(1:ntime);
J = J(1:ntime);
MLT = MLT(1:ntime);

Lm = reshape(Lm,siz_in);
Lstar = reshape(Lstar,siz_in);
Blocal = reshape(Blocal,siz_in);
Bmin = reshape(Bmin,siz_in);
J = reshape(J,siz_in);
MLT = reshape(MLT,siz_in);
