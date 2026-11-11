Atmospheric models
==================

.. irbem:routine:: MSIS86

   The Mass-Spectrometer-Incoherent-Scatter-1986 (MSIS-86) neutral atmosphere
   model describes the neutral temperature and the densities of He, O, N2, O2,
   Ar, H, and N. The MSIS model is based on the extensive data compilation and
   analysis work of A. E. Hedin and his collaborators [A. E. Hedin et al., J.
   Geophys. Res. 82, 2139-2156, 1977; A. E. Hedin, J. Geophys. Res. 88, 10170-
   10188, 1983; A. E. Hedin, J. Geophys. Res. 92, 4649, 1987]. MSIS-86
   constitutes the upper part of the COSPAR International Reference Atmosphere
   (CIRA-86).

   Data sources for the present model include temperature and density
   measurements from several rockets, satellites (OGO-6, San Marco 3, Aeros-A,
   AE-C, AE-D, AE-E, ESRO 4 and DE-2) and incoherent scatter radars (Millstone
   Hill, St. Santin, Arecibo, Jicamarca, and Malvern). Since the MSIS-83 model,
   terms were added or changed to better represent seasonal variations in the
   polar regions under both quiet and magnetically disturbed conditions and
   local time variations in the magnetic activity effect. In addition a new
   species, atomic nitrogen, was added to the list of species covered by the
   model.

   :param integer ntime: number of time points
   :param integer whichAp: key for the kind of Ap input:

            * 1 - only daily Ap magnetic index is provided in the `Ap` parameter
            * 2 - all fields are provided in the `Ap` parameter

   :param array of `ntime` integer idoy: the day of year (January 1st is `idoy=1`)
   :param array of `ntime` double UT: the time in seconds 
   :param array of `ntime` double alt: altitude (km, greater than 85km)
   :param array of `ntime` double lat: geodetic latitude (deg)
   :param array of `ntime` double long: geodetic longitude (deg)
   :param array of `ntime` double F107A: 3 month average of F10.7 flux
   :param array of `ntime` double F107: daily F10.7 flux for previous day
   :param array of [7, `ntime`] double Ap: averaged Ap index
            
            * 1 - Daily Ap
            * 2 - 3 hours Ap index for current time
            * 3 - 3 hours Ap index for 3 hours before current time
            * 4 - 3 hours Ap index for 6 hours before current time
            * 5 - 3 hours Ap index for 9 hours before current time
            * 6 - Average of eight 3 hours Ap indices from 12 to 33 hours before current time
            * 7 - Average of eight 3 hours Ap indices from 36 to 59 hours before current time

   :output array of [8, `ntime`] double dens: density:

            * 1 - He number density (cm\ :sup:`-3`)
            * 2 - O number density (cm\ :sup:`-3`)
            * 3 - N\ :sub:`2` number density (cm\ :sup:`-3`)
            * 4 - O\ :sub:`2` number density (cm\ :sup:`-3`)
            * 5 - Ar number density (cm\ :sup:`-3`)
            * 6 - Total mass density (g.cm\ :sup:`-3`)
            * 7 - H number density (cm\ :sup:`-3`)
            * 8 - N number density (cm\ :sup:`-3`)

   :output array of [2, `ntime`] double temp: temperature:

            * 1 - Exospheric temperature (K)
            * 2 - Temperature at altitude (K)

   :callseq MATLAB: out = onera_desp_lib_msis('msis86',date,X,sysaxes,F107A,F107,Ap)
   :callseq IDL: result = call_external(lib_name, 'msis86_idl_', ntime,whichAp,DOY,UT,Alt,Lat,Lon,F107A,F107,Ap,Dens,Temp, /f_value)
   :callseq FORTRAN: CALL msis86(ntime,whichAp,DOY,UT,Alt,Lat,Lon,F107A,F107,Ap,Dens,Temp)
   

.. irbem:routine:: MSISE90

   The MSISE model describes the neutral temperature and densities in Earth's
   atmosphere from ground to thermospheric heights. Below 72.5 km the model is
   primarily based on the MAP Handbook (Labitzke et al., 1985) tabulation of
   zonal average temperature and pressure by Barnett and Corney, which was also
   used for the CIRA-86. Below 20 km these data were supplemented with averages
   from the National Meteorological Center (NMC). In addition, pitot tube,
   falling sphere, and grenade sounder rocket measurements from 1947 to 1972
   were taken into consideration. Above 72.5 km MSISE-90 is essentially a
   revised MSIS-86 model taking into account data derived from space shuttle
   flights and newer incoherent scatter results. For someone interested only in
   the thermosphere (above 120 km), the author recommends the MSIS-86 model.
   MSISE is also not the model of preference for specialized tropospheric work.
   It is rather for studies that reach across several atmospheric boundaries.

   :param integer ntime: number of time points
   :param integer whichAp: key for the kind of Ap input:

            * 1 - only daily Ap magnetic index is provided in the `Ap` parameter
            * 2 - all fields are provided in the `Ap` parameter

   :param array of `ntime` integer idoy: the day of year (January 1st is `idoy=1`)
   :param array of `ntime` double UT: the time in seconds 
   :param array of `ntime` double alt: altitude (km, greater than 85km)
   :param array of `ntime` double lat: geodetic latitude (deg)
   :param array of `ntime` double long: geodetic longitude (deg)
   :param array of `ntime` double F107A: 3 month average of F10.7 flux
   :param array of `ntime` double F107: daily F10.7 flux for previous day
   :param array of [7, `ntime`] double Ap: averaged Ap index
            
            * 1 - Daily Ap
            * 2 - 3 hours Ap index for current time
            * 3 - 3 hours Ap index for 3 hours before current time
            * 4 - 3 hours Ap index for 6 hours before current time
            * 5 - 3 hours Ap index for 9 hours before current time
            * 6 - Average of eight 3 hours Ap indices from 12 to 33 hours before current time
            * 7 - Average of eight 3 hours Ap indices from 36 to 59 hours before current time

   :output array of [8, `ntime`] double dens: density:

            * 1 - He number density (cm\ :sup:`-3`)
            * 2 - O number density (cm\ :sup:`-3`)
            * 3 - N\ :sub:`2` number density (cm\ :sup:`-3`)
            * 4 - O\ :sub:`2` number density (cm\ :sup:`-3`)
            * 5 - Ar number density (cm\ :sup:`-3`)
            * 6 - Total mass density (g.cm\ :sup:`-3`)
            * 7 - H number density (cm\ :sup:`-3`)
            * 8 - N number density (cm\ :sup:`-3`)

   :output array of [2, `ntime`] double temp: temperature:

            * 1 - Exospheric temperature (K)
            * 2 - Temperature at altitude (K)

   :callseq MATLAB: out = onera_desp_lib_msis('msise90',date,X,sysaxes,F107A,F107,Ap)
   :callseq IDL: result = call_external(lib_name, 'msise90_idl_', ntime,whichAp,DOY,UT,Alt,Lat,Lon,F107A,F107,Ap,Dens,Temp, /f_value)
   :callseq FORTRAN: CALL msise90(ntime,whichAp,DOY,UT,Alt,Lat,Lon,F107A,F107,Ap,Dens,Temp)
   

.. irbem:routine:: NRLMSISE00

   The NRLMSIS-00 empirical atmosphere model was developed by Mike Picone, Alan
   Hedin, and Doug Drob based on the MSISE90 model. The main differences to
   MSISE90 are noted in the comments at the top of the computer code. They
   involve:

   #. the extensive use of drag and accelerometer data on total mass density,
   #. the addition of a component to the total mass density that accounts for
      possibly significant contributions of O+ and hot oxygen at altitudes
      above 500 km, and
   #. the inclusion of the SMM UV occultation data on [O2]. 
   
   The MSISE90 model describes the neutral temperature and densities in Earth's
   atmosphere from ground to thermospheric heights. Below 72.5 km the model is
   primarily based on the MAP Handbook (Labitzke et al., 1985) tabulation of
   zonal average temperature and pressure by Barnett and Corney, which was also
   used for the CIRA-86. Below 20 km these data were supplemented with averages
   from the National Meteorological Center (NMC). In addition, pitot tube,
   falling sphere, and grenade sounder rocket measurements from 1947 to 1972
   were taken into consideration. Above 72.5 km MSISE-90 is essentially a
   revised MSIS-86 model taking into account data derived from space shuttle
   flights and newer incoherent scatter results. For someone interested only in
   the thermosphere (above 120 km), the author recommends the MSIS-86 model.
   MSISE is also not the model of preference for specialized tropospheric work.
   It is rather for studies that reach across several atmospheric boundaries.

   :param integer ntime: number of time points
   :param integer whichAp: key for the kind of Ap input:

            * 1 - only daily Ap magnetic index is provided in the `Ap` parameter
            * 2 - all fields are provided in the `Ap` parameter

   :param array of `ntime` integer idoy: the day of year (January 1st is `idoy=1`)
   :param array of `ntime` double UT: the time in seconds 
   :param array of `ntime` double alt: altitude (km, greater than 85km)
   :param array of `ntime` double lat: geodetic latitude (deg)
   :param array of `ntime` double long: geodetic longitude (deg)
   :param array of `ntime` double F107A: 3 month average of F10.7 flux
   :param array of `ntime` double F107: daily F10.7 flux for previous day
   :param array of [7, `ntime`] double Ap: averaged Ap index
            
            * 1 - Daily Ap
            * 2 - 3 hours Ap index for current time
            * 3 - 3 hours Ap index for 3 hours before current time
            * 4 - 3 hours Ap index for 6 hours before current time
            * 5 - 3 hours Ap index for 9 hours before current time
            * 6 - Average of eight 3 hours Ap indices from 12 to 33 hours before current time
            * 7 - Average of eight 3 hours Ap indices from 36 to 59 hours before current time

   :output array of [9, `ntime`] double dens: density:

            * 1 - He number density (cm\ :sup:`-3`)
            * 2 - O number density (cm\ :sup:`-3`)
            * 3 - N\ :sub:`2` number density (cm\ :sup:`-3`)
            * 4 - O\ :sub:`2` number density (cm\ :sup:`-3`)
            * 5 - Ar number density (cm\ :sup:`-3`)
            * 6 - Total mass density (g.cm\ :sup:`-3`)
            * 7 - H number density (cm\ :sup:`-3`)
            * 8 - N number density (cm\ :sup:`-3`)
            * 9 - Anomalous oxygen number density (cm\ :sup:`-3`)

   :output array of [2, `ntime`] double temp: temperature:

            * 1 - Exospheric temperature (K)
            * 2 - Temperature at altitude (K)

   :callseq MATLAB: out = onera_desp_lib_msis('nrlmsise00',date,X,sysaxes,F107A,F107,Ap)
   :callseq IDL: result = call_external(lib_name, 'nrlmsise00_idl_', ntime,whichAp,DOY,UT,Alt,Lat,Lon,F107A,F107,Ap,Dens,Temp, /f_value)
   :callseq FORTRAN: CALL nrlmsise00(ntime,whichAp,DOY,UT,Alt,Lat,Lon,F107A,F107,Ap,Dens,Temp)
