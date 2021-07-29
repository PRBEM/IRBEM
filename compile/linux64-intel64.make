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

FC = ifort
CC = icc
LD = ifort

FFLAGS=-fPIC -Bdynamic
CFLAGS=-fPIC
LDFLAGS=-shared

