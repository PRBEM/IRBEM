IRBEM Library
=============

The International Radiation Belt Environment Modeling (IRBEM) library is
freely distributed under the umbrella of the PRBEM COSPAR panel.

In 2003 ONERA-DESP (space environment department) decided to put together a
set of source codes into a library dedicated to radiation belt modeling. The
toolkit was then called ONERA-DESP-LIB. Because the project has grown along
time, and because its development is nowadays more like an international
collaborative effort, it has been decided in 2008, after COSPAR 2008
Montreal assembly, to move the library name to IRBEM-LIB (which refers to
COSPAR PRBEM panel) and to distribute it under COSPAR PRBEM umbrella (a
neutral body).

The IRBEM Fortran library allows to compute magnetic coordinates and drift
shells using various external magnetic field models.  Further routines are
provided for  various coordinate and time format transformations.

The library can be called from FORTRAN or C code and from IDL, Python or
MATLAB code. For IDL, Python and MATLAB wrappers are provided in the
distribution package. 

Installation
------------
IRBEM requires a [Fortran compiler](https://fortran-lang.org/learn/os_setup/install_gfortran), and can be installed on modern Windows, Linux, and Mac computers.

## Linux
The quick build procedure on Linux with gfortran:
```bash
    git clone https://github.com/PRBEM/IRBEM.git
    cd IRBEM
    make OS=linux64 ENV=gfortran64 all
    make OS=linux64 ENV=gfortran64 install
```

## Mac OSX
The quick build procedure on Mac OSX with gfortran:
```bash
    git clone https://github.com/PRBEM/IRBEM.git
    cd IRBEM
    make OS=osx64 ENV=gfortran64 all
    make OS=osx64 ENV=gfortran64 install
```

## Windows
Here is one way to build IRBEM for 64-bit Windows using the gfortran compiler. 

1. Download and install [MSYS2](https://www.msys2.org/) and follow the [Fortran installation steps](https://www.msys2.org/#:~:text=and%20what%20for.-,Installation,-Download%20the%20installer) (summarized below). 
   1. Run MSYS2 MSYS terminal from the start menu and update the MSYS2 packages via ```pacman -Syu``` (pacman is its package manager). Close the terminal after packages are updated. 
   2. Run MSYS2 MSYS from the start menu again and update the rest of the packages using ```pacman -Syu```.
   3. Install the Fortran compiler and other dependencies ([base-devel](https://packages.msys2.org/group/base-devel) and [mingw-w64-x86_64-toolchain](https://packages.msys2.org/group/mingw-w64-x86_64-toolchain)) in the MSYS terminal using ```pacman -S --needed base-devel mingw-w64-x86_64-toolchain```.
   4. git is required for building IRBEM. If you don't have it, install it using [msys2-git](https://packages.msys2.org/base/git) ```pacman -S git```.
   5. Add the directory where `gfortran.exe` is located to the Windows path (a good place to look for it is `C:\msys64\mingw64\bin`). You can follow these [instructions](https://docs.microsoft.com/en-us/previous-versions/office/developer/sharepoint-2010/ee537574(v=office.14)#to-add-a-path-to-the-path-environment-variable) to add the path environmental variables.
   6. Confirm that the paths are set up correctly. Run `gfortran --version` command runs. Also, check that `make` runs (it will print "make: *** No targets specified and no makefile found.  Stop."). 

2. Clone and install IRBEM
   ```bash
    git clone https://github.com/PRBEM/IRBEM.git
    cd IRBEM
    make OS=win64 ENV=gfortran64 all
    make OS=win64 ENV=gfortran64 install
    ```
Congratulations! Now you have compiled libirbem.dll library in the root folder of IRBEM/.


See the `README.install` or `compile/WINDOWS_INSTRUCTIONS.md` files for more details.

Contributions
-------------

The IRBEM project is an international effort, and welcomes any contribution.
Please raise any issue (bug reports, usage questions, feature requests, ...)
on the [Issues page](https://github.com/PRBEM/IRBEM/issues).

We also welcome Pull Requests (PR) for bug fixes or new features. All
developments should be done on a dedicated branch and be submitted as a PR.
If you are not familiar with this process, see [this
guide](https://guides.github.com/activities/forking/). The overall process is
the following:

  - First fork the project on github using the *Fork* button at the top of
    this page.
  - Clone the forked repository or add it as a new remote on your local git
	repository.
  - Create a new branch for the new development.
  - *Modify the code*.
  - Push to your forked repository.
  - Submit a Pull Request on the [Pull requests
	page](https://github.com/PRBEM/IRBEM/pulls)

License
-------
The IRBEM library is free software: you can redistribute it and/or modify it
under the terms of the GNU Lesser General Public License as published by the
Free Software Foundation, either version 3 of the License, or (at your
option) any later version. This library is distributed in the hope that it
will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser
General Public License for more details. You should have received a copy of
the GNU Lesser General Public License along with this library. If not, see
http://www.gnu.org/licenses/.

COSPAR does not warrant or assume any legal liability or responsibility for
the accuracy, completeness, use, or usefulness of any information,
apparatus, product, or process disclosed in documents and software available
from the IRBEM library or developed as a result of the use of information or
software made available from the library.

Acknowledgments
---------------
The main authors of IRBEM are Daniel Boscher and Sebastien Bourdarie 
(ONERA-DESP, Toulouse, France).

The authors wish to thank:

 - Erwin De Donder, Hugh Evans, Reiner Friedel, Tim Guild, Daniel 
   Heynderickx, Stu Huston, Adam Kellerman, Colby Lemon, Kyungguk Min, 
   Steve Morley, Paul O'Brien, Christopher Roth, and Mykhaylo Shumko for 
   general contributions to the IRBEM library.
 - K. Pfitzer, N. Tsyganenko, I. Alexeev and their co-authors for providing
   us magnetic field model source codes and for good discussions on how to
   use their model correctly. 
 - R. Friedel (LANL), Y. Dotan and M. Redding (Aerospace Corporation) for
   good discussions, advices and bug reports which are always very helpfull
   when one attemps to develop such a tool.
 - D. Bilitza for his help regarding the use of IGRF magnetic field model
   and MSIS models.
 - D. Brautigam for providing us CRRES models.
 - D. Vallado for providing free of use source code for orbit propagator
   (SGP4).
