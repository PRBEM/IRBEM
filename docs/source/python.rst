Using with Python
-----------------

We provide a set of Python wrappers for the IRBEM Fortran library through the use of a shared library file (.so on Unix). The wrapper is found in python/IRBEM.py. Python interfaces with the compiled shared library file with ctypes.

Python wrapper install
^^^^^^^^^^^^^^^^^^^^^^

Compile the Fortran source as instructed by the README.install file. This will create the shared object file, "onera_desp_lib_linux....so" in the source firectory.

Change directory into the python folder and add the Python wrapper paths with "sudo python3 setup.py install"

Check that the installation worked by running the provided test scripts (:code:`python/<...>test_and_visualizations.py`).

If the wrapper crashes with the error "Either none or multiple .so files found in the sources folder!", check that the shared object exists in the source folder.

Python usage
^^^^^^^^^^^^

The Python wrapper :code:`IRBEM.py`` currently consists of two classes that load the shared object file. 
This class interface is used to avoid redudant user input formatting code. :code:`IRBEM.py` currently contains wrappers for the magnetic field library via the :code:`MagFields` class 
and coordinate transformation library via the :code:`Coords` class. 
The two classes contain methods which interface with the various IRBEM functions. 
The output from each IRBEM wrapped function can be accesed with the usual return statement and :code:`<FUNCTION_NAME>_output` class attributes.

Current wrapped magnetic field functions are :irbem:ref:`make_lstar`, :irbem:ref:`drift_shell`, :irbem:ref:`find_mirror_point`, 
:irbem:ref:`find_foot_point`, :irbem:ref:`trace_field_line`, and :irbem:ref:`find_magequator`. For more documentation, call :code:`help(<FUNCTION_NAME>)`.

Example code can be found in the :code:`python/<...>test_and_visualizations.py` files.