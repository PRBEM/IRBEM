rem builds the Onera library into a DLL for linking with Excel...e.g.

gfortran -shared -ffixed-line-length-none -mrtd .\*.f ..\source\*.f -o irbem-lib.dll


rem Install the AddIn macros for Excel and the DLL to the SYSTEM directory

copy irbem-lib.xla "%UserProfile%\Application Data\Microsoft\AddIns"
copy irbem-lib.dll %SYSTEMROOT%
