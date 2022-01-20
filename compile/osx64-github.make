#------------------------------------------------------------------------------
# This one is for the GitHub Actions CI.
# Compilers information
#     FC: Fortran Compiler
#     CC: C Compiler
#     LD: Linker
#     FFLAGS : Fortran flags
#     CFLAGS : C Flags
#     LDFLAGS: Linker flags
#     COMPILE_LIB_NAME : Name of the compiled library file
#     INSTALL_LIB_NAME : Name of the installed library file
#------------------------------------------------------------------------------

FC = gfortran-11
CC = gcc
LD = gfortran-11

FFLAGS=-fpic -fno-second-underscore -std=legacy -ffixed-line-length-none
CFLAGS=-fpic
LDFLAGS=-shared

COMPILE_LIB_NAME=libirbem.$(OS).$(ENV).so
INSTALL_LIB_NAME=libirbem.so
