#***************************************************************************************************
# Copyright 2007, S. Bourdarie
#
# This file is part of IRBEM-LIB.
#
#    IRBEM-LIB is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Lesser General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    IRBEM-LIB is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Lesser General Public License for more details.
#
#    You should have received a copy of the GNU Lesser General Public License
#    along with IRBEM-LIB.  If not, see <http://www.gnu.org/licenses/>.
#
SHELL=/bin/sh
NULL=true

#------------------------------------------------------------------------------
# Library settings
#------------------------------------------------------------------------------
IRBEM_NTIME_MAX=100000

#------------------------------------------------------------------------------
# Directory locations.
#------------------------------------------------------------------------------

SOURCEDIR=./source
HELPDIR=./compile
INSTALLDIR=.
EXAMPLE=./example

#------------------------------------------------------------------------------
# SVN information
#     all this data is acquired by parsing the output of "svn info"
#     SVN_ROOT    : top level root directory of the repository
#     SVN_URL     : the Full URL to this directory of the working copy
#     SVN_DIR     : the first directory of the Working Copy (trunk, tags/<TAG_NAME, branches/branchName)
#     SVN_RELEASE : Same as SVN_DIR, except in the case of a tag, where "tags/" is replaced by "Release: ".
#     SVN_REV     : revision number of the repository.
#------------------------------------------------------------------------------

#SVN_WC?=$(shell if [ -d .svn ] ; then echo 1 ; else echo 0; fi)
# check for existence of svn, then check for working copy
SVN_WC?=$(shell if [[ `svn --version --quiet` =~ [0-9] ]] ; then echo `svn info | grep -c ^URL:` ; else echo 0 ; fi)
ifeq ($(SVN_WC),1)
   SVN_ROOT   =$(strip $(subst Repository Root:,,$(shell svn info | grep 'Repository Root: ')))
   SVN_URL    =$(strip $(subst URL: ,,$(shell svn info | grep 'URL: ')))
   SVN_REV    =$(strip $(shell svn info | grep 'Last Changed Rev:' | sed "s,.*: ,,g"))
   SVN_DIR    =$(strip $(subst $(SVN_ROOT)/,,$(SVN_URL)))
   SVN_RELEASE=$(strip $(subst tags/,Release: , $(SVN_DIR)))
else
   SVN_ROOT    ?=http://irbem.svn.sourceforge.net/svnroot/irbem
   SVN_URL     ?=$(SVN_ROOT)/???
   SVN_REV     ?=-1
   SVN_DIR     ?=NonSVN
   SVN_RELEASE ?=Unknown
endif

#------------------------------------------------------------------------------
# macros.
#------------------------------------------------------------------------------

BUILD_DATE=$(shell date +%Y-%m-%dT%H:%M)
MAKE=make
AR=ar
OS=
ENV=
RANLIB=ranlib
LANG=
IDL=idl

#------------------------------------------------------------------------------
# Macros for sunos.
#------------------------------------------------------------------------------

SHAREDEXT_sunos=so
NONSHAREDEXT_sunos=a
AROPTIONS_sunos=-r

FOPTIONS_SHARED_sunos_sparc32=-xlang=f77 -G
FOPTIONS_NONSHARED_sunos_sparc32=-c -xlang=f77
FC_sunos_sparc32=f95
PIC_sunos_sparc32=-KPIC
LDOPTIONS_sunos_sparc32=
WRAPPER_sunos_sparc32=32
LIBNAME_sunos_sparc32=sunos_sparc

FOPTIONS_SHARED_sunos_sparc64=-xlang=f77 -G -xarch=generic64
FOPTIONS_NONSHARED_sunos_sparc64=-c -xlang=f77 -xarch=generic64
FC_sunos_sparc64=f95
PIC_sunos_sparc64=-KPIC
LDOPTIONS_sunos_sparc64=
WRAPPER_sunos_sparc64=64
LIBNAME_sunos_sparc64=sunos_sparcV9

FOPTIONS_SHARED_sunos_gnu32=-fno-second-underscore -w -m32
FOPTIONS_NONSHARED_sunos_gnu32=-c -fno-second-underscore -w -m32
FC_sunos_gnu32=g77
PIC_sunos_gnu32=-fPIC
LDOPTIONS_sunos_gnu32=-shared
WRAPPER_sunos_gnu32=32
LIBNAME_sunos_gnu32=sunos_sparc

FOPTIONS_SHARED_sunos_gnu64=-fno-second-underscore -w -m64
FOPTIONS_NONSHARED_sunos_gnu64=-c -fno-second-underscore -w -m64
FC_sunos_gnu64=g77
PIC_sunos_gnu64=-fPIC
LDOPTIONS_sunos_gnu64=-shared
WRAPPER_sunos_gnu64=64
LIBNAME_sunos_gnu64=sunos_sparcV9

#------------------------------------------------------------------------------
# Macros for Linux32.
#------------------------------------------------------------------------------

SHAREDEXT_linux32=so
NONSHAREDEXT_linux32=a
AROPTIONS_linux32=-r

FOPTIONS_SHARED_linux32_intel32=-Bstatic
FOPTIONS_NONSHARED_linux32_intel32=-c -assume 2underscores
FC_linux32_intel32=ifort
PIC_linux32_intel32=
LDOPTIONS_linux32_intel32=-shared
WRAPPER_linux32_intel32=32
LIBNAME_linux32_intel32=linux_x86

FOPTIONS_SHARED_linux32_gnu32=-mno-align-double -fno-second-underscore -w -m32
FOPTIONS_NONSHARED_linux32_gnu32=-c -mno-align-double -w -m32
FC_linux32_gnu32=gfortran
PIC_linux32_gnu32=-fPIC
LDOPTIONS_linux32_gnu32=-shared
WRAPPER_linux32_gnu32=32
LIBNAME_linux32_gnu32=linux_x86

FOPTIONS_SHARED_linux32_pgi32=-Bstatic -Mnosecond_underscore -w
FOPTIONS_NONSHARED_linux32_pgi32=-c -w
FC_linux32_pgi32=pgf77
PIC_linux32_pgi32=-fpic
LDOPTIONS_linux32_pgi32=-shared
WRAPPER_linux32_pgi32=32
LIBNAME_linux32_pgi32=linux_x86

#------------------------------------------------------------------------------
# Macros for Linux64.
#------------------------------------------------------------------------------

SHAREDEXT_linux64=so
NONSHAREDEXT_linux64=a
AROPTIONS_linux64=-r

#FOPTIONS_SHARED_linux64_intel32=-Bstatic -traceback -check bounds -check format -check output_conversion -fexceptions -fpe0 -fmath-errno
#FOPTIONS_SHARED_linux64_intel32=-Bstatic -g -debug extended -fpe0 -O0 -check all -traceback
FOPTIONS_SHARED_linux64_intel32=-Bdynamic
FOPTIONS_NONSHARED_linux64_intel32=-c
FC_linux64_intel32=ifort
PIC_linux64_intel32=-fPIC
LDOPTIONS_linux64_intel32=-shared
WRAPPER_linux64_intel32=32
LIBNAME_linux64_intel32=linux_x86

FOPTIONS_SHARED_linux64_intel64=-Bdynamic
FOPTIONS_NONSHARED_linux64_intel64=-c
FC_linux64_intel64=ifort
PIC_linux64_intel64=-fPIC
LDOPTIONS_linux64_intel64=-shared
WRAPPER_linux64_intel64=64
LIBNAME_linux64_intel64=linux_x86_64

FOPTIONS_SHARED_linux64_intel64_debug=-Bdynamic -g -debug extended -fpe0 -O0 -check all -traceback
FOPTIONS_NONSHARED_linux64_intel64_debug=-c -g -debug extended -fpe0 -O0 -check all -traceback
FC_linux64_intel64_debug=ifort
PIC_linux64_intel64_debug=-fPIC
LDOPTIONS_linux64_intel64_debug=-shared
WRAPPER_linux64_intel64_debug=64
LIBNAME_linux64_intel64_debug=linux_x86_64_debug

FOPTIONS_SHARED_linux64_gnu32=-mno-align-double -fno-second-underscore -w -m32
FOPTIONS_NONSHARED_linux64_gnu32=-c -mno-align-double -w -m32
FC_linux64_gnu32=gfortran
PIC_linux64_gnu32=-fPIC
LDOPTIONS_linux64_gnu32=-shared
WRAPPER_linux64_gnu32=32
LIBNAME_linux64_gnu32=linux_x86

FOPTIONS_SHARED_linux64_gnu64=-mno-align-double -fno-second-underscore -w -m64
FOPTIONS_NONSHARED_linux64_gnu64=-c -mno-align-double -w -m64
FC_linux64_gnu64=gfortran
PIC_linux64_gnu64=-fPIC
LDOPTIONS_linux64_gnu64=-shared
WRAPPER_linux64_gnu64=64
LIBNAME_linux64_gnu64=linux_x86_64

FOPTIONS_SHARED_linux64_pgi64=-Mnosecond_underscore -w -tp p7-64
FOPTIONS_NONSHARED_linux64_pgi64=-c -w -tp p7-64
FC_linux64_pgi64=pgf77
PIC_linux64_pgi64=-fPIC
LDOPTIONS_linux64_pgi64=-shared
WRAPPER_linux64_pgi64=64
LIBNAME_linux64_pgi64=linux_x86_64

FOPTIONS_SHARED_linux64_gfortran64=-mno-align-double -fno-second-underscore -w -m64
FOPTIONS_NONSHARED_linux64_gfortran64=-c -mno-align-double -w -m64
FC_linux64_gfortran64=gfortran -std=legacy -ffixed-line-length-none
PIC_linux64_gfortran64=-fPIC
LDOPTIONS_linux64_gfortran64=-shared
WRAPPER_linux64_gfortran64=64
LIBNAME_linux64_gfortran64=linux_x86_64

#------------------------------------------------------------------------------
# Macros for Windows32.
#------------------------------------------------------------------------------

SHAREDEXT_win32=dll
NONSHAREDEXT_win32=a
AROPTIONS_win32=-r

FOPTIONS_SHARED_win32_cygwin32=-mno-cygwin -I%IDLINC% -Wl,--add-stdcall-alias -fno-second-underscore -w
FOPTIONS_NONSHARED_win32_cygwin32=-c -mno-cygwin -shared -mno-align-double -fno-second-underscore -w
#FC_win32_cygwin32=gfortran
# gfortran doesn't accept -mno-cygwin
# alternative is FC_win32_cygwin32=i686-w64-mingw32-gfortran if you install the mingw cross compilers
# but that generates a DLL that matlab doesn't recognize
# using g77 does work under cygwin, if you have g77 installed, and it builds a DLL Matlab likes.
FC_win32_cygwin32=g77
PIC_win32_cygwin32=
LDOPTIONS_win32_cygwin32=-shared
WRAPPER_win32_cygwin32=32
LIBNAME_win32_cygwin32=Win32_x86

FOPTIONS_SHARED_win32_mingw=-I%IDLINC% -fno-second-underscore -static
FOPTIONS_NONSHARED_win32_mingw=-c -shared -fno-second-underscore -static
FC_win32_mingw=gfortran
PIC_win32_mingw=
LDOPTIONS_win32_mingw=-shared
WRAPPER_win32_mingw=32
LIBNAME_win32_mingw=Win32_x86

FOPTIONS_SHARED_win64_mingw=-I%IDLINC% -fno-second-underscore -static
FOPTIONS_NONSHARED_win64_mingw=-c -shared -fno-second-underscore -static
FC_win64_mingw=gfortran
PIC_win64_mingw=
LDOPTIONS_win64_mingw=-shared
WRAPPER_win64_mingw=64
LIBNAME_win64_mingw=Win64_x86

#------------------------------------------------------------------------------
# Macros for Windows64.
#------------------------------------------------------------------------------

SHAREDEXT_win64=dll
NONSHAREDEXT_win64=a
AROPTIONS_win64=-r

FOPTIONS_SHARED_win64_cygwin64=-mno-cygwin -I%IDLINC% -Wl,--add-stdcall-alias -fno-second-underscore -w -m64
FOPTIONS_NONSHARED_win64_cygwin64=-c -mno-cygwin -shared -mno-align-double -fno-second-underscore -w -m64
FC_win64_cygwin64=gfortran
PIC_win64_cygwin64=
LDOPTIONS_win64_cygwin64=-shared
WRAPPER_win64_cygwin64=64
LIBNAME_win64_cygwin64=Win64_x86

#------------------------------------------------------------------------------
# Macros for Mach.
#------------------------------------------------------------------------------

SHAREDEXT_mach=dylib
NONSHAREDEXT_mach=a
AROPTIONS_mach=rc

FOPTIONS_SHARED_mach_gnu32=-w
FOPTIONS_NONSHARED_mach_gnu32=-w
FC_mach_gnu32=g95
PIC_mach_gnu32=
LDOPTIONS_mach_gnu32=-dynamic
WRAPPER_mach_gnu32=32
LIBNAME_mach_gnu32=mach

#------------------------------------------------------------------------------
# Compile/link entire distribution.
#------------------------------------------------------------------------------
all.help:
	@more $(HELPDIR)/Help.all

all: all.$(OS).$(ENV)

all..:
	echo "Missing OS and ENV variables"

all.linux32.intel32: all.build
all.linux32.gnu32: all.build
all.linux32.pgi32: all.build
all.linux64.intel32: all.build
all.linux64.intel64: all.build
all.linux64.intel64_debug: all.build
all.linux64.gnu32: all.build
all.linux64.gnu64: all.build
all.linux64.pgi64: all.build
all.linux64.gfortran64: all.build
all.win32.cygwin32: all.build
all.win64.cygwin64: all.build
all.win32.mingw: all.build
all.win64.mingw: all.build
all.mach.gnu32: all.build
all.sunos.sparc32: all.build
all.sunos.sparc64: all.build
all.sunos.gnu32: all.build
all.sunos.gnu64: all.build


all.build: version.fortran ntime_max
	@cd $(SOURCEDIR); \
cp wrappers_$(WRAPPER_$(OS)_$(ENV)).inc wrappers.inc;\
echo "Building non-sharable object \
onera_desp_lib_$(LIBNAME_$(OS)_$(ENV)).$(NONSHAREDEXT_$(OS))"; \
$(FC_$(OS)_$(ENV)) $(FOPTIONS_NONSHARED_$(OS)_$(ENV)) *.f;\
$(AR) $(AROPTIONS_$(OS)) liboneradesp_$(LIBNAME_$(OS)_$(ENV)).$(NONSHAREDEXT_$(OS)) *.o;\
$(RANLIB) liboneradesp_$(LIBNAME_$(OS)_$(ENV)).$(NONSHAREDEXT_$(OS));\
echo "non-sharable object built";\
echo "";\
echo "Building sharable object \
onera_desp_lib_$(LIBNAME_$(OS)_$(ENV)).$(SHAREDEXT_$(OS))"; \
$(FC_$(OS)_$(ENV)) $(FOPTIONS_SHARED_$(OS)_$(ENV)) $(PIC_$(OS)_$(ENV)) -o onera_desp_lib_$(LIBNAME_$(OS)_$(ENV)).$(SHAREDEXT_$(OS)) \
*.f $(LDOPTIONS_$(OS)_$(ENV));\
echo "sharable object built";\
echo "";\
echo "Building sequence achieved";

#------------------------------------------------------------------------------
# Install files.
#------------------------------------------------------------------------------

install.help:
	@more $(HELPDIR)/Help.install

install: install.lib

install.lib:
	@echo Installing
	@if [ -f $(SOURCEDIR)/onera_desp_lib_*.so ] ; then \
	   cp $(SOURCEDIR)/onera_desp_lib_*.so $(INSTALLDIR)/matlab/onera_desp_lib.so;\
	   cp $(SOURCEDIR)/onera_desp_lib_*.so $(INSTALLDIR);\
	 else \
	   $(NULL) ; \
	 fi
	@if [ -f $(SOURCEDIR)/onera_desp_lib_*.dll ] ; then \
	   cp $(SOURCEDIR)/onera_desp_lib_*.dll $(INSTALLDIR)/matlab/onera_desp_lib.dll;\
	   cp $(SOURCEDIR)/onera_desp_lib_*.dll $(INSTALLDIR);\
	 else \
	   $(NULL) ; \
	 fi
	@if [ -f $(SOURCEDIR)/onera_desp_lib_*.dylib ] ; then \
	  @cp $(SOURCEDIR)/onera_desp_lib_*.dylib $(INSTALLDIR)/matlab;\
	   cp $(SOURCEDIR)/onera_desp_lib_*.dll $(INSTALLDIR);\
	 else \
	   $(NULL) ; \
	 fi
	@if [ -f $(SOURCEDIR)/liboneradesp_*.a ] ; then \
	   cp $(SOURCEDIR)/liboneradesp_*.a $(INSTALLDIR);\
	 else \
	   $(NULL) ; \
	fi
	@echo Installing done


#------------------------------------------------------------------------------
# Test distribution.
#------------------------------------------------------------------------------

test.help:
	@more $(HELPDIR)/Help.test

test: test.$(LANG)

test.IDL:
	@cd $(EXAMPLE); $(IDL) idl_test.pro 

#------------------------------------------------------------------------------
# Clean/purge.
#------------------------------------------------------------------------------

clean:
	@-rm -f core
	@-rm -f $(SOURCEDIR)/core
	@-rm -f $(SOURCEDIR)/*.o
	@-rm -f $(SOURCEDIR)/*.so
	@-rm -f $(SOURCEDIR)/*.a
	@-rm -f $(SOURCEDIR)/*.dll
	@-rm -f $(SOURCEDIR)/*.dylib
	@echo 'Cleaning process done'
	@echo ' '

purge:
	@-rm -f *~
	@-rm -f *#
	@-rm -f $(SOURCEDIR)/*~
	@-rm -f $(SOURCEDIR)/*#

#------------------------------------------------------------------------------
# determine fortran code version from svn or cvs, store in fortran_version.inc
# if subversion is not found, then leave in place existing fortran_version.inc
#------------------------------------------------------------------------------

version.fortran:
	@echo "$(SVN_ROOT), $(SVN_URL), $(SVN_DIR), $(SVN_RELEASE)" 
	@if [ $(SVN_WC) -eq 1 ] ; then \
		echo "        INTEGER*4 FORTRAN_VERSION ! generated by Make File $(BUILD_DATE)"    > $(SOURCEDIR)/fortran_version.inc ; \
		echo "        PARAMETER (FORTRAN_VERSION = $(SVN_REV) ) ! Generated by Make File" >> $(SOURCEDIR)/fortran_version.inc;\
		echo "        CHARACTER*80 FORTRAN_RELEASE ! Generated by MakeFile  $(BUILD_DATE)" > $(SOURCEDIR)/fortran_release.inc ; \
		echo "        PARAMETER (FORTRAN_RELEASE = '$(SVN_RELEASE)')"                     >> $(SOURCEDIR)/fortran_release.inc; \
	 fi

#------------------------------------------------------------------------------
# store #(IRBEM_NTIME_MAX) in ntime_max.inc
#------------------------------------------------------------------------------

ntime_max:
	@echo "        INTEGER*4 NTIME_MAX ! generated by Make File" > $(SOURCEDIR)/ntime_max.inc ; \
	 echo "        PARAMETER (NTIME_MAX = " $(IRBEM_NTIME_MAX) ") ! Generated by Make File" >> $(SOURCEDIR)/ntime_max.inc
