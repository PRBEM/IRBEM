Using with IDL
--------------

We provide a set of IDL wrappers for the IRBEM FORTRAN library through the use of a shared library file (.dll on windows, .so on Unix). 
IDL access to any FORTRAN function with the use of the IDL function :code:`CALL_EXTERNAL` (see IDL manual for more details).

IDL installation
^^^^^^^^^^^^^^^^

The IRBEM compile scripts will create the shared library file for use with IDL (or Matlab) and is given a name "libirbem.dll" or "libirbem.so" depending on the platform. 
The `lib_name` can be defined from IDL by the following:

.. code-block::

    case !version.os of
       'linux':ext='so'
       'sunos':ext='so'
       'Win32':ext='dll'
    endcase
    lib_name=libirbem+'.'+ext

Thus, in order to access the library and the wrappers, the user needs only to use the :code:`CALL_EXTERNAL` function where "image" (here refers as `lib_name` in the detailled function descriptions) 
provide the path+name of the shared library file.

IDL usage
^^^^^^^^^

When calling from IDL using :code:`call_external`, ALL input and output variables have to be declared in the correct type. 
Failure to do this will result in a very ungracefull idl exit with no error messages or possibility of tracing! In general, integers need to be declared as longs and floats as double.