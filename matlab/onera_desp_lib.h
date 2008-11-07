/*
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
prototype C header file for access to generic .dll or .so file
e.g., onera_desp_lib.dll
Paul O'Brien paul.obrien@aero.org
 */


void make_lstar1_(long int *ntime, long int *kext,
		  long int *options,long int *sysaxes,
		  long int *iyear,long int *idoy,
		  double *UT,double *x1,
		  double *x2,double *x3,
		  double *maginput, double *Lm,
		  double *Lstar, double *Blocal,
		  double *Bmin, double *J,
		  double *MLT);

void make_lstar_shell_splitting1_(long int *ntime, 
				  long int *Nipa,
				  long int *kext,
				  long int *options,
				  long int *sysaxes,
				  long int *iyear,
				  long int *idoy,
				  double *UT,
				  double *x1,
				  double *x2,
				  double *x3,
				  double *alpha,
				  double *maginput, 
				  double *Lm,
				  double *Lstar, 
				  double *Blocal,
				  double *Bmin, 
				  double *J,
				  double *MLT);

void drift_shell1_(long int *kext, long int *options,
		   long int *sysaxes, long int *iyear,
		   long int *idoy, double * UT,
		   double *x1, double *x2, double *x3,
		   double *maginput,
		   double *Lm,
		   double *Lstar, 
		   double *Blocal,
		   double *Bmin, 
		   double *J,
		   double *posit,
		   long int *ind);

void trace_field_line1_(long int *kext, long int *options,
		   long int *sysaxes, long int *iyear,
		   long int *idoy, double * UT,
		   double *x1, double *x2, double *x3,
		   double *maginput,
		   double *Lm,
		   double *Blocal,
		   double *Bmin, 
		   double *J,
		   double *posit,
		   long int *ind);

void get_field1_(long int *kext, long int *options,
		 long int *sysaxes,
		 long int *iyear,long int *idoy,
		 double *UT,double *x1,
		 double *x2,double *x3,
		 double *maginput,
		 double *Bgeo,
		 double *B);

void find_mirror_point1_(long int *kext, 
			 long int *options,
			 long int *sysaxes,
			 long int *iyear,long int *idoy,
			 double *UT,double *x1,
			 double *x2,double *x3,
			 double *alpha,
			 double *maginput,
			 double *Blocal,
			 double *Bmirror,
			 double *xGEO);

void find_foot_point1_(long int *kext, 
		       long int *options,
		       long int *sysaxes,
		       long int *iyear,long int *idoy,
		       double *UT,double *x1,
		       double *x2,double *x3,
		       double *stop_alt,
		       long int *hemi_flag,
		       double *maginput,
		       double *xfoot,
		       double *Bfoot,
		       double *Bfootmag);

void get_hemi1_(long int *kext, 
		long int *options,
		long int *sysaxes,
		long int *iyear,long int *idoy,
		double *UT,double *x1,
		double *x2,double *x3,
		double *maginput,
		long int *xHEMI);

void find_magequator1_(long int *kext, 
			 long int *options,
			 long int *sysaxes,
			 long int *iyear,long int *idoy,
			 double *UT,double *x1,
			 double *x2,double *x3,
			 double *maginput,
			 double *Bmin,
			 double *xGEO);

void get_mlt1_(long int *iyr, long int *idoy,
	       double *UT, double *xGEO, double *MLT);

void fly_in_nasa_aeap1_(long int *ntime, long int *sysaxes,
			long int *whichm, long int *whatf,
			long int *Nene, double *energy, 
			long int *iyear, long int *idoy, double *UT,
			double *x1,double *x2, double *x3,
			double *flux);

void get_ae8_ap8_flux_(long int *ntime, long int *whichm, long int *whatf,
		       long int *Nene, double *energy, 
		       double *BBo, double *L, double *flux);

void fly_in_afrl_crres1_(long int *ntime, long int *sysaxes,
			 long int *whichm, long int *whatf,
			 long int *nene, double *energy, 
			 long int *iyear, long int *idoy, double *UT,
			 double *x1, double *x2, double *x3,
			 double *Ap15,
			 double *flux,
			 char *ascii_path,
			 long int *strlen);

void get_crres_flux_(long int *ntime, long int *whichm, long int *whatf,
		     long int *nene, double *energy, 
		     double *BBo,double *L, double *Ap15,
		     double *flux,
		     char *ascii_path,
		     long int *strlen);

void sgp4_tle1_(long int *runtype,double *startsfe,double *stopsfe,double *deltasec,
		char *InFileByte,long int *strlenIn,
		char *OutFileByte,long int *strlenOut);

void sgp4_ele1_(long int *sysaxes,
		long int *Yr,long int *Mon,long int *Day,long int *Hr,long int *Minute,double *Sec,
		double *e1, double *e2,	double *e3, double *e4,	double *e5, double *e6,
		long int *ele_opts,
		double *startsfe,double *stopsfe,double *deltasec,
		long int *outYr,long int *outDoy, double *outSec,
		double *x1, double *x2,	double *x3);

void coord_trans_vec1_(long int *ntime, long int *sysaxesIN,long int *sysaxesOUT,
		   long int *iyr,long int *idoy,double *secs,
		   double *xINV,double *xOUTV);

void rv2coe_(double *R, double *V, 
	     double *P, double *A, double *Ecc, double *Incl, double *Omega, 
	     double *Argp, double *Nu, double *M, double *ArgLat,
	     double *TrueLon, double *LonPer);

void fly_in_ige1_(long int *launch_year, long int *duration,
		  long int *whichm, long int *whatf,
		  long int *nene, double *energy,
		  double *Lower_flux, double *Mean_flux, double *Upper_flux);

void nrlmsise00_(long int *ntime,long int *whichAp,
		long int *DOY,double *UT,double *ALT,double *LAT,double *LON,
		double *F107A,double *F107,double *AP,double *Dens,double *Temp);

void msise90_(long int *ntime,long int *whichAp,
		long int *DOY,double *UT,double *ALT,double *LAT,double *LON,
		double *F107A,double *F107,double *AP,double *Dens,double *Temp);

void msis86_(long int *ntime,long int *whichAp,
		long int *DOY,double *UT,double *ALT,double *LAT,double *LON,
		double *F107A,double *F107,double *AP,double *Dens,double *Temp);

