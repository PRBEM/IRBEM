# IRBEM Python wrapper installation 

1. follow the installation instructions at irbem-lib/README.install to compile the source code. You should check that you have a shared object (.so) file in the irbem-lib/source/ directory.

2. On unix systems this wrapper is installed with the following steps:
   - cd into ```irbem-lib/python/```
   - Run ```sudo python3 -m pip install -e .``` for a system-wide install, or alternatively ```python3 -m pip install --user -e .``` to install it for the user.

This wrapper was only developed and tested on Linux and for Python version > 3.6. For Windows users, one solution is to use the Windows Subsystem for Linux (WSL).