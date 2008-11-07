function maginputs = onera_desp_lib_maginputs(Kp,Dst,Nsw,Vsw,Psw,ByGSM,BzGSM,G1,G2,G3,W1,W2,W3,W4,W5,W6,AL);
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
% function maginputs = onera_desp_lib_maginputs(Kp,Dst,Nsw,Vsw,Psw,ByGSM,BzGSM,G1,G2,G3,W1,W2,W3,W4,W5,W6,AL);
% produces the correct structure for maginputs
% from the provided parameters
% maginput - [length(G1) x 25] provides inputs to dynamic external field models
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

n = max([length(Kp),length(Dst),length(Nsw),length(G1),length(W1),length(AL)]);
maginputs = zeros(n,25);
maginputs(:,1) = floor(Kp*10);
maginputs(:,2) = Dst;
maginputs(:,3) = Nsw;
maginputs(:,4) = Vsw;
maginputs(:,5) = Psw;
maginputs(:,6) = ByGSM;
maginputs(:,7) = BzGSM;
maginputs(:,8) = G1;
maginputs(:,9) = G2;
maginputs(:,10) = G3;
maginputs(:,11) = W1;
maginputs(:,12) = W2;
maginputs(:,13) = W3;
maginputs(:,14) = W4;
maginputs(:,15) = W5;
maginputs(:,16) = W6;
maginputs(:,17) = AL;
