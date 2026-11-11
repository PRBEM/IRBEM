IRBEM Library
=============

The International Radiation Belt Environment Modeling (IRBEM) library is
a set of source codes dedicated to radiation belt modeling. The library 
facilitates the calculation of magnetic coordinates and drift shells using 
various external magnetic field models. Further routines are provided 
for various spatial coordinate and time format transformations. The library 
can be called from FORTRAN or C, with IDL, Python, and MATLAB wrappers 
provided in the distribution package. 

IRBEM was first developed and released as "ONERA-DESP-LIB" in 2003 by the DESP 
department (the space environment department) of the French aerospace lab, 
ONERA. As the project has grown through the years, its development is now 
an international collaborative effort. Following the 2008 COSPAR Assembly 
held in Montreal, it was decided to change the library's name to "IRBEM-LIB" 
to reflect this international collaboration, and to freely distribute the 
library under the umbrella of the COSPAR Panel on Radiation Belt Environment 
Modeling (PRBEM), a neutral scientific body.

Acknowledgments
---------------
### Publication Acknowledgment
When publishing research that used IRBEM, please provide appropriate credit 
to the IRBEM team via acknowledgment:

> We acknowledge the use of the IRBEM library (XXX), the latest 
version of which can be found at https://doi.org/10.5281/zenodo.6867552.

where the "XXX" is replaced by one of the following, depending on if you are 
using an official release library or a repository version of the library:

* Official Release: XXX = "version X.Y.Z" where X.Y.Z is the version number of 
the official release that was used (https://github.com/PRBEM/IRBEM/releases)

* Repository Version: XXX = "repository version YYY" where YYY is the output 
of `git rev-parse --short HEAD`

### Community Contributors
The IRBEM team wishes to thank:

 - Daniel Boscher, Sebastien Bourdarie, Paul O'Brien, Tim Guild, Daniel 
   Heynderickx, Steve Morley, Adam Kellerman, Christopher Roth, Hugh Evans, 
   Antoine Brunet, Mykhaylo Shumko, Colby Lemon, Seth Claudepierre, Thomas 
   Nilsson, Erwin De Donder, Reiner Friedel, Stu Huston, Kyungguk Min, Alexander Drozdov, and the IRBEM contributor community for general contributions 
   to the IRBEM library.
 - K. Pfitzer, N. Tsyganenko, I. Alexeev and their co-authors for providing
   us magnetic field model source codes and for good discussions on how to
   use their model correctly. 
 - R. Friedel, Y. Dotan and M. Redding for good discussions, advice and bug 
   reports which are always very helpful  when one attempts to develop such 
   a tool.
 - D. Bilitza for his help regarding the use of IGRF magnetic field model
   and MSIS models.
 - D. Brautigam for providing the CRRES models.
 - D. Vallado for providing free of use source code for the orbit propagator
   (SGP4).

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
   1. Run MSYS2 MSYS terminal from the start menu and update the MSYS2 packages via ```pacman -Syu``` (pacman is its package manager).
   2. Run MSYS2 MSYS from the start menu again and update the rest of the packages using ```pacman -Syu```.
   3. Install the Fortran compiler and other dependencies ([base-devel](https://packages.msys2.org/group/base-devel) and [mingw-w64-x86_64-toolchain](https://packages.msys2.org/group/mingw-w64-x86_64-toolchain)) in the MSYS terminal using ```pacman -S --needed base-devel mingw-w64-x86_64-toolchain```. Use the default option `all`.
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
