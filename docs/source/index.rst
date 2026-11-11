IRBEM Library user manual
=========================

The International Radiation Belt Environment Modeling (IRBEM) library is a set
of source codes dedicated to radiation belt modeling. The library facilitates
the calculation of magnetic coordinates and drift shells using various external
magnetic field models. Further routines are provided for various spatial
coordinate and time format transformations.

The library can be called from FORTRAN or C code and from Python, IDL or MATLAB
code. For Python, IDL and MATLAB, wrappers are provided in the distribution package. 
The `SpacePy python package <https://spacepy.github.io/>`_ does also provide a
wrapper to the IRBEM library (`spacepy.irbempy`).

The International Radiation Belt Environment Modeling (IRBEM) library is freely
distributed under the umbrella of `COSPAR <https://cosparhq.cnes.fr>`_'s `Panel
on Radiation Belt Modeling (PRBEM) <https://prbem.github.io>`_.

For any questions, suggestions or to report bugs please visit the `issue tracker
<https://github.com/PRBEM/IRBEM/issues>`_ at the `source repository on GitHub
<https://github.com/PRBEM/IRBEM>`_.

Publication aknowledgement
--------------------------
When publishing research that used IRBEM, please provide appropriate credit to the IRBEM team via acknowledgment:

    We acknowledge the use of the IRBEM library (XXX), the latest version of which can be found at https://doi.org/10.5281/zenodo.6867552.

where `XXX` is replaced by one of the following, depending on if you are using an official release library or a repository version of the library:

* Official Release: `XXX = "version X.Y.Z"` where `X.Y.Z` is the version number of the official release that was used (https://github.com/PRBEM/IRBEM/releases)
* Repository Version: `XXX = "repository version YYY"` where `YYY` is the output of :code:`git rev-parse --short HEAD`


Library content
---------------
.. toctree::
   :maxdepth: 2

   user-manual
   api/api
   irbem-routines


Rule of use
-----------

This library is free software: you can redistribute it and/or modify it under
the terms of the GNU Lesser General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option) any
later version. This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License
for more details. You should have received a copy of the GNU Lesser General
Public License along with this library. If not, see
http://www.gnu.org/licenses/. 

COSPAR does not warrant or assume any legal liability or responsibility for the
accuracy, completeness, use, or usefulness of any information, apparatus,
product, or process disclosed in documents and software available from the
IRBEM library or developed as a result of the use of information or software
made available from the library. 
