Using with FORTRAN
------------------

The library is written is FORTRAN 77 so it is very easy to CALL any subroutine from any FORTRAN code.

A call to the library is trivial. Make sure anyway that the variables are of the same type as defined in the detailled functions (subroutines).

To link any FORTRAN source code with the static library you have to add at the end of the compilation command the option -Lpath where path allows to locate the static library file and the option -loneradesp (make sure the static lib name is liboneradesp.a)

If you have been using the Makefile to build the library then you have to add the proper option depending on the compiler in order to force the compiler to add only a single underscore to any subroutine. e.g. with g77 the option is -fno-second-underscore.


