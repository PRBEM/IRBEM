#!/bin/ksh
version=$1
tar cvf onera_desp_lib_$version.tar COPYING COPYING.LESSER Makefile README.install compile data example manual matlab source
gzip onera_desp_lib_$version.tar
