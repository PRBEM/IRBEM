Library information functions
=============================

.. irbem:routine:: IRBEM_FORTRAN_VERSION

   Provides the repository version number of the fortran source code.

   :output integer VERSN: IRBEM version number
   :callseq MATLAB: VERSN = onera_desp_lib_fortran_version
   :callseq IDL: result = call_external(lib_name, 'irbem_fortran_version_',versn, /f_value)
   :callseq FORTRAN: call IRBEM_FORTRAN_VERSION1(VERSN)

.. irbem:routine:: IRBEM_FORTRAN_RELEASE

   Provides the repository release tag of the fortran source code.
   
   :output array of 80 characters RLS: release tag
   :callseq MATLAB: RLS = onera_desp_lib_fortran_release
   :callseq IDL: result = call_external(lib_name, 'irbem_fortran_release_', rls, /f_value)
   :note: In IDL, string arguments should be defined as byte arrays, i.e.: :code:`rls = BYTARR(80)`
   :callseq FORTRAN: call IRBEM_FORTRAN_RELEASE1(RLS)

.. irbem:routine:: GET_IGRF_VERSION

   Returns the version number of the IGRF model.

   :output integer IGRF_VERSION:  IGRF version number
   :callseq MATLAB: igrf_version = onera_desp_lib_igrf_version
   :callseq IDL: result = call_external(lib_name, 'igrf_version_idl_',igrf_version, /f_value)
   :callseq FORTRAN: call GET_IGRF_VERION_(igrf_version)

.. irbem:routine:: GET_IRBEM_NTIME_MAX

   Returns the size of time dimension in inputs and/or output arrays for some of the routines.

   .. note::
      In previous versions, the `ntime_max` parameter was used extensively in the IRBEM library.
      
      When possible (which is when the time dimension is the first dimension of the array), the 
      IRBEM routines now use variable-length array, so arbitrary array length can be provided, as
      long as the array is big enough to contain the needed data (usually of size `ntime`).

      For routines where the `ntime_max` array size is still needed, it is explicitely mentioned 
      in the corresponding part of this documentation.

   :output integer NTIME_MAX:  Time dimension size
   :callseq MATLAB: ntime_max = onera_desp_lib_ntime_max
   :callseq IDL: result = call_external(lib_name, 'get_irbem_ntime_max_',ntime_max, /f_value)
   :callseq FORTRAN: call GET_IRBEM_NTIME_MAX1(ntime_max)
