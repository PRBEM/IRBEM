Using with MATLAB
-----------------

We provide a set of Matlab wrappers for the IRBEM FORTRAN library through the use of a shared library file (.dll on windows, .so on Unix). Matlab refers to this type of interface as a "mex file". In addition to the shared library file, Matlab requires a C-style header file that includes the C-style calling syntax for each FORTRAN function. This .h file is provided with the IRBEM Matlab library. For historical reasons, the Matlab routines and files are prefixed with "onera_desp_lib" rather than "irbem".

MATLAB installation
^^^^^^^^^^^^^^^^^^^
.. warning::

    These MATLAB installation instructions are outdated.

.. todo Update the MATLAB installation instructions

Easy way for 32-bit windows users
"""""""""""""""""""""""""""""""""

* Manually create your top-level folder "irbem"
* Download the `matlab folder tarball`_, and untar/unzip its contents into a folder called "irbem\\matlab"
* Download the `data folder tarball`_, and untar/unzip its contents into a folder called "irbem\\data"
* Open Matlab
* Under the File menu, click "Set Path"
* Add "irbem\\matlab" to your Matlab path
* Add "irbem\\data" to your Matlab path
* Click "Save" to save your new Matlab path for future sessions
* Download the `32-bit windows DLL`_ and save it as "irbem\\matlab\\onera_desp_lib.dll"

Sort of easy way for 64-bit windows users
"""""""""""""""""""""""""""""""""""""""""

* Do all the steps above, except download the `64-bit windows DLL`_ and save it as "irbem\\matlab\\onera_desp_lib.dll"
* Then you have to install the latest free Microsoft Visual Studio, including its "redistributables" (these are DLLs needed by the IRBEM library and Matlab requires this compiler to acceass any DLL)
* Then you have to add the following DLLs to the matlab folder where onera_desp_lib.dll resides. (We're working on a version of the DLL that does not have these dependencies):

  - (Except where noted, these are part of cygwin64, but can sometimes be found on-line without installing it)
  - libgcc_s_seh-1.dll
  - libgfortran-3.dll
  - libquadmath-0.dll
  - (These one may not be needed anymore, or only need for extras)
  - libgsl-0.dll
  - libgcc_s_sjlj-1.dll
  - libgslcblas-0.dll
  - IEShims.dll (usually found in the internet explorer folder, e.g., c:\\program files\\internet explorer. Copy it) 

Hard way for everyone else
""""""""""""""""""""""""""
The IRBEM make file (call make help from irbem/trunk) will create the shared library file
for use with IDL or Matlab. A copy of the shared library is created in the "matlab" 
subdirectory, and is given a name "onera_desp_lib.dll" or "onera_desp_lib.so" depending on 
the platform. Thus, in order to access the library and the wrappers, the user needs only add 
the "matlab" subdirectory (e.g. "c:\\irbem\\matlab") to the Matlab path. In order for the
library to easily locate the data files that it needs, it is also advisable to add the "data" 
subdirectory to the Matlab path. Matlab provides a GUI interface to add folders to the search
path from "Set Path" entry on the "File" menu. It is also possible to add these two folders to 
the path using the Matlab "addpath" command; however, this command does not make the change
to the path permanent, so that "addpath" will have to be issued once in each new Matlab 
session. The "savepath" function can make the path change permanent, as can the GUI path 
manager interface. Thus, one could use the following commands, if the IRBEM library is 
located in "c:\\irbem":
 
.. code-block::
    
    addpath c:\irbem\matlab c:\irbem\data
    savepath 

.. _`matlab folder tarball`: http://sourceforge.net/p/irbem/code/HEAD/tarball?path=/trunk/matlab
.. _`data folder tarball`: http://sourceforge.net/p/irbem/code/HEAD/tarball?path=/trunk/data
.. _`32-bit windows DLL`: http://sourceforge.net/p/irbem/code/HEAD/tree/trunk/onera_desp_lib_Win32_x86.dll?format=raw
.. _`64-bit windows DLL`: http://sourceforge.net/p/irbem/code/HEAD/tree/trunk/onera_desp_lib_Win64_x86.dll?format=raw

MATLAB usage
^^^^^^^^^^^^

The Matlab wrappers are built to provide Matlab-like function calls into the library. These wrappers handle loading the library into Matlab's function space, formatting inputs and outputs for proper calls to the library, and providing "vectorized" functionality wherever reasonable. Each wrapper function will determine whether the FORTRAN library has been loaded, and, if not, attempt to load it from the default location (anywhere in the Matlab path).

Each .m file provided includes a robust set of helps obtainable via help <funtion_name> in the usual Matlab way. This help call will provide details of how to call the function.

Although the FORTRAN library often limits the size of arrays, the Matlab wrappers typically handle arbitrarily large array inputs by splicing together multiple calls to the library. Also, in many cases, when a set of arrays is expected as input, the Matlab wrappers will accept scalars for some, which will be repeated (via Matlab's repmat function) to be the same size as the other array arguments.

In many cases, the library requires integer inputs that represent different options, e.g., kext=5 for the Olson-Pfitzer Quiet external field model. In most cases, the Matlab wrapper supports string (keyword) inputs in place of the integer values. This keyword approach is implemented for kext, options, sysaxes, and whichm, among others.

Whenever date/time arguments are required by the FORTRAN library, the Matlab library expects Matlab Date Numbers (construct argument "matlabd" with Matlab's datenum function).

The FORTRAN library function fly_in_afrl_crres requires a set of text files. If the path to these files is not specified, the wrapper will attempt to guess it by locating one of these, 'crrespro_quiet.txt' in the Matlab search path.

When available from MATLAB a calling sequence is provided for each function (see detailled description of each functions). 

MATLAB helper functions
^^^^^^^^^^^^^^^^^^^^^^^

The following function creates the proper maginputs array for use with the field models:

.. code-block::
    
    maginputs = onera_desp_lib_maginputs(Kp,Dst,Nsw,Vsw,Psw,ByGSM,BzGSM,G1,G2,G3,W1,W2,W3,W4,W5,W6,AL);

The following funnction will load the shared library file from the non-default location:

.. code-block::
    
    onera_desp_lib_load(libfile,headerfile);

The following functions are used by the library to convert the Matlab wrapper inputs into the inputs needed by the FORTRAN library. 
These include "as appropriate" the look-up tables that convert keyword inputs into the integer constants used by the FORTAN library:

.. code-block::

    kext = onera_desp_lib_kext(kext);
    options = onera_desp_lib_options(inoptions);
    sysaxes = onera_desp_lib_sysaxes(sysaxes) ;
    [iyear,idoy,UT] = onera_desp_lib_matlabd2yds(matlabd); 
