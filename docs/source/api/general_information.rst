General information
===================

Data types
----------

Unless specified in this documentation, the IRBEM routines use 32 bits integers (also called long integer in IDL) and double-precision (64 bits) floating points numbers. All arrays are represented using the column-major ordering (as usual for Fortran libraries).

.. _NALPHA_MAX:
.. _NENE_MAX:
.. _NTIME_MAX:

Maximum array sizes
-------------------

Some of the IRBEM routines can perform a particular calculation on multiple
points, for multiple energies or multiple pitch angles. For some of these
routines, there are limitations on the input and output array sizes, which
are defined throughout the library.

Some routines have a maximum number of requested points, or use outputs arrays of
fixed size :code:`NTIME_MAX`. The value of :code:`NTIME_MAX` can be
retrieved using the :irbem:ref:`GET_IRBEM_NTIME_MAX` routine.

Similarly, some routines impose maximum numbers of energy (:code:`NENE_MAX`)
and pitch angles (:code:`NALPHA_MAX`), which are defined as:

.. code-block:: Fortran

    NENE_MAX = 25
    NALPHA_MAX = 25

.. _kext:

External magnetic field model
-----------------------------

IRBEM can compute magnetic coordinate and trace the field for various
magnetic field models from the litterature. Most routines
accept a :code:`kext` integer parameter which allows the selection of the
external magnetic field model, according to the following table:

=====  ================================================  ==========
Key    Magnetic field name                               Comments
=====  ================================================  ==========
0      No external field    
1      Mead & Fairfield [1975]                           uses 0 ≤ Kp_ ≤ 9 - valid for rGEO ≤17 Re 
2      Tsyganenko short [1987]                           uses 0 ≤ Kp_ ≤ 9 - valid for rGEO ≤30 Re
3      Tsyganenko long [1987]                            uses 0 ≤ Kp_ ≤ 9 - valid for rGEO ≤70 Re
4      Tsyganenko [1989c]                                uses 0 ≤ Kp_ ≤ 9 - valid for rGEO ≤70 Re
5      Olson & Pfitzer quiet [1977]                      valid for rGEO ≤15 Re
6      Olson & Pfitzer dynamic [1988]                    - uses 5 ≤ Dsw_ ≤ 50, 300 ≤ Vsw_ ≤ 500, -100 ≤ Dst_ ≤ 20
                                                         - valid for rGEO ≤60 Re
7      Tsyganenko [1996]                                 - uses -100 ≤ Dst_ ≤ 20, 0.5 ≤ Pdyn_ ≤ 10, \|\ By_\| ≤ 10, \|\ Bz_\| ≤ 10
                                                         - valid for rGEO ≤40 Re
8      Ostapenko & Maltsev [1997]                        uses Dst_, Pdyn_, Bz_, Kp_
9      Tsyganenko [2001]                                 - uses -50 ≤ Dst_ ≤ 20, 0.5 ≤ Pdyn_ ≤ 5, \|\ By_\| ≤ 5, \|\ Bz_\| ≤ 5, 0 ≤ G1_ ≤ 10, 0 ≤ G2_ ≤ 10
                                                         - valid for xGSM ≥-15 Re
10     Tsyganenko [2001] storm                           - uses Dst_, Pdyn_, By_, Bz_, G2_, G3_
                                                         - there is no upper or lower limit for those inputs
                                                         - valid for xGSM ≥-15 Re
11     Tsyganenko [2004] storm                           - uses Dst_, Pdyn_, By_, Bz_, W1_, W2_, W3_, W4_, W5_, W6_
                                                         - there is no upper or lower limit for those inputs
                                                         - valid for xGSM ≥-15 Re
12     Alexeev [2000], also known as Paraboloid model    - uses Dsw_, Vsw_, Dst_, Bz_, AL_
13     Tsyganenko [2007]
14     Mead-Tsyganenko                                   - uses Kp_
                                                         - onera model where the Tsyganenko 89 model is best fitted by a Mead model     
=====  ================================================  ==========

.. note::
   
   Besides the external field model, it is also possible to select the
   internal magnetic field model used by IRBEM, using the 5th parameter in
   the :ref:`options` array.

.. _options:

IRBEM options
-------------

Some IRBEM routines accept an :code:`option` parameter, which is an array of 5
integer flags allowing to control the behavior of the routines.

.. list-table::
   :header-rows: 1

   * - Index
     - Quantity
     - Values description
   * - 1
     - L* or Φ           
     - - 0 - don't compute L* or Φ
       - 1 - compute L*
       - 2 - compute Φ
   * - 2
     - IGRF Initialization
     - - 0 - initialize IGRF field once per year (year.5)
       - `n` - `n` is the  frequency (in days) starting on January 1st of
         each year (i.e. if options(2nd element)=15 then IGRF will be
         updated on the following days of the year: 1, 15, 30, 45 ...)  
   * - 3
     - L* field line resolution
     - 0-9, where 0 is the recommended value to ensure a good ratio
       precision/computation time (i.e. an error of ~2% at L=6) - The higher
       the value the better will be the precision, the longer will be the
       computing time. Generally there is not much improvement for values
       larger than 4. Note that this parameter defines the integration step
       (θ) along the field line such as dθ=(π)/(720*[options(3rd
       element)+1])
   * - 4
     - L* drift shell resolution
     - 0-9 - The higher the value the better will be the precision, the longer
       will be the computing time. It is recommended to use 0 (usually
       sufficient) unless L* is not computed on a LEO orbit. For LEO orbit
       higher values are recommended. Note that this parameter defines the
       integration step (φ) along the drift shell such as
       dφ=(2π)/(25*[options(4th element)+1])
   * - 5
     - Internal magnetic field selection
     - - 0 - IGRF - default
       - 1 - Eccentric tilted dipole
       - 2 - Jensen & Cain 1960
       - 3 - GSFC 12/66 updated to 1970
       - 4 - User own magnetic field. The library then called a routine
         which has to be written by the user
         :code:`myOwnMagField(xGEO,Bxint)` where inputs are `xGEO` a double
         array of 3 elements (x,y,z) containing geographic cartesian
         coordinates in Re and outputs are `Bxint` a double array of 3
         elements (Bx,By,Bz) containing magnetic field components in
         geographic cartesian coordinates in nT.
       - 5 - Centered dipole

.. todo give reference to magnetic fields

.. _sysaxes:

Coordinate systems
------------------

=====  =========  ========================
Key    Name       Description
=====  =========  ========================
0      _`GDZ`     - Geodetic (altitude, latitude, East longitude) - km, deg, deg
                  - Defined using a reference ellipsoid. Geodetic longitude
                    is identical to `GEO`_ longitude. Both the altitude and
                    latitude depend on the ellipsoid used. IRBEM uses the
                    WGS84 reference ellipsoid.
1      _`GEO`     - Geocentric geographic (cartesian) - Re
                  - Earth-Centered and Earth-Fixed. X lies in the
                    Earth's equatorial plane (zero latitude) and intersects
                    the Prime Meridian (zero longitude; Greenwich, UK). Z
                    points to True North (roughly aligned with the
                    instantaneous rotation axis).
2      _`GSM`     - Geocentric Solar Magnetospheric (cartesian) - Re
                  - X points sunward from Earth's center. The X-Z plane is
                    defined to contain Earth's dipole axis (positive North).
3      _`GSE`     - Geocentric Solar Ecliptic (cartesian) - Re
                  - X points sunward from Earth's center. Y lies in the
                    ecliptic plane of date, pointing in the anti-orbit
                    direction. Z is parallel to the ecliptic pole of date.
4      _`SM`      - Solar Magnetic (cartesian) - Re
                  - Z is aligned with the centered dipole axis of date
                    (positive North), and Y is perpendicular to both the
                    Sun-Earth line and the dipole axis. X is therefore is
                    not aligned with the Sun-Earth line and `SM`_ is a rotation
                    about Y from `GSM`_.
5      _`GEI`     - Geocentric Equatorial Inertial (cartesian) - Re
                  - X points from Earth toward the equinox of date (first
                    point of Aries; position of the Sun at the vernal
                    equinox). Z is parallel to the instantaneous rotation
                    axis of the Earth.
6      _`MAG`     - Geomagnetic (cartesian) - Re
                  - Z is parallel to Earth's centered dipole axis (positive
                    North). Y is the intersection between Earth's equator
                    and the geographic meridian 90 degrees east of the
                    meridan containing the dipole axis.
7      _`SPH`     - `GEO`_ in spherical (radial distance, latitude, East longitude) - Re, deg, deg
                  - Geoecentric geographic coordinates (`GEO`_ system)
                    expressed in spherical instead of Cartesian.
8      _`RLL`     - Geodetic (radial distance, latitude, East longitude) - Re, deg, deg
                  - A re-expression of geodetic (`GDZ`_) coordinates using
                    radial distance instead of altitude above the reference
                    ellipsoid. Note that the latitude is still geodetic
                    latitude and is therefore not interchangeable with
                    `SPH`_.
9      _`HEE`     - Heliocentric Earth Ecliptic (cartesian) - Re
                  - Origin is solar center; X points towards the Earth, and
                    Z is perpendicular to the plane of Earth's orbit
                    (positive North). This system is fixed with respect to
                    the Earth-Sun line.
10     _`HAE`     - Heliocentric Aries Ecliptic (cartesian) - Re
                  - Origin is solar center. Z is perpendicular to the plane
                    of Earth's orbit (positive North) and X points towards
                    the equinox of date (first point of Aries).
11     _`HEEQ`    - Heliocentric Earth Equatorial (cartesian) - Re
                  - Origin is solar center. Z is parallel to the Sun's
                    rotation axis (positive North) and X points towards the
                    intersection of the solar equator and solar central
                    meridian as seen from Earth.
12     _`TOD`     - True of Date, same as `GEI`_ (cartesian) - Re
                  - This is the same as IRBEM's `GEI`_ and both are included
                    for legacy support. `TOD`_ uses the "true" (not mean)
                    equator of date and equinox of date to define the
                    coordinate system.
13     _`J2000`   - `GEI`_ at J2000 (cartesian) - Re
                  - A key geocentric inertial frame. X is aligned with the
                    mean equinox at J2000; Z is parallel to the mean
                    rotation axis of the Earth at J2000 (that is,
                    perpendicular to the mean equator of J2000). The mean
                    equinox of date and mean equator of date (at any epoch)
                    correct only for precession, and not nutation.
14     _`TEME`    - True Equator Mean Equinox (cartesian) - Re
                  - `TEME`_ is the inertial system used by the SGP4 orbit
                    propagator.
=====  =========  ========================

.. note::
   
   Four geocentric equatorial inertial systems are in widespread use. These
   are J2000, MOD (Mean of Date), TOD, and TEME. J2000 defines the axes
   using the equinox and pole at the J2000 epoch. Correcting for precession
   transforms to MOD (which is identical to J2000 at 2000-01-01T11:58:55.816
   UTC), and then correcting for nutation tansforms to TOD (GEI). IRBEM
   defines the geophysical systems (e.g., `GSE`_, `GSM`_, `SM`_) relative to TOD,
   although some missions define these coordinate systems relative to a
   different inertial reference system (usually MOD).

.. note::
   
   For details of the approximations used by IRBEM's coordinate
   transformations, including the equation for estimating the Sun vector,
   see (`Russel, 1971`_) and (`Hapgood, 1992`_).

.. _Russel, 1971: http://jsoc.stanford.edu/~jsoc/keywords/Chris_Russel/Geophysical%20Coordinate%20Transformations.htm
.. _Hapgood, 1992: https://doi.org/10.1016/0032-0633(92)90012-D

.. _maginput:

Magnetic field inputs
---------------------

======  ==========  ========================
Index   Name        Description
======  ==========  ========================
1       _`Kp`       value of Kp as in OMNI2 files but has to be double instead of integer type. (NOTE, consistent with OMNI2, this is Kp*10, and it is in the range 0 to 90)
2       _`Dst`      Dst index (nT)
3       _`Dsw`      solar wind density (cm\ :sup:`-3`)
4       _`Vsw`      solar wind velocity (km/s)
5       _`Pdyn`     solar wind dynamic pressure (nPa)
6       _`By`       GSM y component of interplanetary magnetic field (nT)
7       _`Bz`       GSM z component of interplanetary magnetic field (nT)
8       _`G1`       <\ Vsw_ (Bperp/40)\ :sup:`2`/(1+Bperp/40) sin\ :sup:`3`\ (θ/2)> where the `<>` mean an average over the previous 1 hour, Bperp is the transverse IMF component (GSM) and θ its clock angle
9       _`G2`       <a Vsw_ Bs> where Bs=|IMF Bz| when IMF Bz < 0 and Bs=0 when IMF Bz > 0, a=0.005
10      _`G3`       <\ Vsw_ Dsw_ Bs/2000>
11-16   _`W1`       see definitions in (`Tsyganenko et al., 2005`_)
        _`W2`
        _`W3`
        _`W4`
        _`W5`
        _`W6`
17      _`AL`       auroral index
18-25               reserved for future use
======  ==========  ========================

.. note::

   Solar wind inputs must be taken in the vicinity of the day side
   magnetopause and _not_ at L1. For instance, one can use the hourly NASA
   OMNI2 dataset.

.. _Tsyganenko et al., 2005: https://doi.org/10.1029/2004JA010798
