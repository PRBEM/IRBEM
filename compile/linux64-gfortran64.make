#------------------------------------------------------------------------------
# Compilers information
#     FC: Fortran Compiler
#     CC: C Compiler
#     LD: Linker
#     FFLAGS : Fortran flags
#     CFLAGS : C Flags
#     LDFLAGS: Linker flags
#     LIB_NAME : Name of the library file
#------------------------------------------------------------------------------

FC = gfortran
CC = gcc
LD = gfortran

FFLAGS=-fpic -fno-second-underscore -mno-align-double -std=legacy -ffixed-line-length-none
CFLAGS=-fpic
LDFLAGS=-shared

