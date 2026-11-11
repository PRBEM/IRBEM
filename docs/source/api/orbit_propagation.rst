Orbit propagation
=================

.. irbem:routine:: SGP4_TLE

   Propagates NORAD Two-Lines Elements and compute the spacecraft position.

   SGP4 stands for Simplified General Perturbation -4 and consists in an orbit
   propagator. This function allows one to propagate NORAD two lines elements
   (TLE sets can be found at http://celestrak.com/). More about SGP4 can be
   found at http://celestrak.com/NORAD/documentation/spacetrk.pdf .

   .. important::
     
      Those who are running the library on Unix or linux system
      have to convert TLE files from NORAD from DOS to UNIX using the command
      :code:`dos2unix file.tle newfile.tle`. Also be aware that some TLE files
      contains random errors, like elements from another satellite, repeated
      elements, ...  there are no specific filters implemented in the SGP4
      function.  

   For those who are familiar with SGP4 code, be aware for one difference
   between orginal SGP4 code and the one provided here: input start and stop
   time and time step are not in minutes but in seconds. This was chosen for
   convenience.

   :param integer runtype: key to select the SGP4_TLE mode:

      0. defines start and stop time to propagate each TLE according to input file 
      1. propagates each TLE according to user start and stop time 

   :param double startsfe: start time from date provided in each TLE (s) - can be negative, ignored for `runtype = 0`
   :param double stopsfe: stop time from date provided in each TLE (s) - can be negative, ignored for `runtype = 0`
   :param double deltasec: step time to propagate TLE (s)
   :param byte array InFileByte: path and name of the input TLE file to be propagated
   :param integer strlenIn: length of `InFileByte` string
   :param byte array OutFileByte: path and name of the output file
   :param integer strlenOut: length of `OutFileByte` string
   :output file: The output file is composed of 6 columns:

      1. date (dd/mm/yyyy)
      2. time (hh:mm:ss)
      3. decimal year
      4. altitude (km)
      5. latitude (deg)
      6. East longitude (deg)

      .. note::

         The Matlab wrapper handles calculation of runtype strlenIn,
         OutfileByte, strlenOut. OutfileByte and strlenOut will be set
         appropriately for a temporary file (`onera_desp_lib_sgp4_tle.tmp` or
         `onera_desp_lib_sgp4_tle.tmp.####`). The wrapper reads the library
         routine's output from the temporary file and passes it back as a
         Matlab structure. The temporary file is deleted, so the Matlab
         structure is the only result of a successful call to sgp4_tle. In
         order to avoid a memory overflow for very long TLE runs, it is
         possible to leave the output in a text file (as in the FORTRAN call):
         the syntax is then :code:`onera_desp_lib_sgp4_tle(InFile,OutFile)`

   :callseq MATLAB: pos = onera_desp_lib_sgp4_tle(InFileByte) %implies runtype=0
                    pos = onera_desp_lib_sgp4_tle(startsfe,stopsfe,deltasec,InFileByte) %implies runtype=1
   :callseq IDL: result = call_external(lib_name, 'sgp4_tle_', runtype,startsfe,stopsfe,deltasec,InFileByte,strlenIn,OutFileByte,strlenOut, /f_value)
   :callseq FORTRAN: CALL sgp4_tle1(runtype,startsfe,stopsfe,deltasec,InFileByte,strlenIn,OutFileByte,strlenOut)

.. irbem:routine:: SGP4_ELE

   Compute orbit coordinates from orbital elements.

   SGP4 stands for Simplified General Perturbation -4 and consists in an orbit
   propagator. This function allows one to produce orbit coordinates from
   different types of orbital elements. More about SGP4 can be found at:
   http://celestrak.com/NORAD/documentation/spacetrk.pdf .

   For those who are familiar with SGP4 code, be aware for one difference
   between orginal SGP4 code and the one provided here: input start and stop
   time and time step are not in minutes but in seconds. This was chosen for
   convenience.

   :param integer sysaxesOUT: key for the output coordinate system (see :ref:`sysaxes`)
   :param integer year: year of start date
   :param integer month: month of start date
   :param integer day: day of start date
   :param integer hour: hour of start time
   :param integer minute: minute of start time
   :param integer seconds: seconds of start time
   :param double e1-e6: orbital elements - see definition according to `options` array
   :param array of 5 integer options: type of orbital elements:

           - `options(1) = 1` : ONERA-type elements:

               * `e1` : inclination (deg)
               * `e2` : geocentric altitude of perigee (km)
               * `e3` : geocentric altitude of apogee (km)
               * `e4` : longitude of the ascending node (deg)
               * `e5` : 
        
                 - `options(2) = 1` : argument of perigee (deg)
                 - `options(2) = 2` : longitude of perigee (deg)
        
               * `e6` :
        
                 - `options(3) = 1` : time since perigee passage (s)
                 - `options(3) = 2` : true anomaly at epoch (deg)
                 - `options(3) = 3` : argument of latitude at epoch (deg)
                 - `options(3) = 4` : true longitude at epoch (deg)
                 - `options(3) = 5` : mean anomaly at epoch (deg)

           - `options(1) = 2` : classical type elements:

              * `e1` : semimajor axis (Re)
              * `e2` : eccentricity
              * `e3` : inclination (deg)
              * `e4` : longitude of the ascending node (deg)
              * `e5` : 
        
                - `options(2) = 1` : argument of perigee (deg)
                - `options(2) = 2` : longitude of perigee (deg)
        
              * `e6` :
        
                - `options(3) = 1` : time since perigee passage (s)
                - `options(3) = 2` : true anomaly at epoch (deg)
                - `options(3) = 3` : argument of latitude at epoch (deg)
                - `options(3) = 4` : true longitude at epoch (deg)
                - `options(3) = 5` : mean anomaly at epoch (deg)

           - `options(1) = 3` : RV-type elements:

              * `e1` : xGEI (km)
              * `e2` : yGEI (km)
              * `e3` : zGEI (km)
              * `e4` : VxGEI (km/s)
              * `e5` : VyGEI (km/s)
              * `e6` : VzGEI (km/s)

           - `options(1) = 4` : SOLAR type elements:

              * `e1` : inclination (deg)
              * `e2` : geocentric altitude of perigee (km)
              * `e3` : geocentric altitude of apogee (km)
              * `e4` : local time of apogee (hours)
              * `e5` : local time of maximum inclination (hours)
              * `e6` :
        
                - `options(3) = 1` : time since perigee passage (s)
                - `options(3) = 2` : true anomaly at epoch (deg)
                - `options(3) = 3` : argument of latitude at epoch (deg)
                - `options(3) = 4` : true longitude at epoch (deg)
                - `options(3) = 5` : mean anomaly at epoch (deg)

           - `options(1) = 5` : MEAN type elements:

              * `e1` : mean motion (rev/day)
              * `e2` : eccentricity
              * `e3` : inclination (deg)
              * `e4` : longitude of the ascending node (deg)
              * `e5` : 
        
                - `options(2) = 1` : argument of perigee (deg)
                - `options(2) = 2` : longitude of perigee (deg)
        
              * `e6` :
        
                - `options(3) = 1` : time since perigee passage (s)
                - `options(3) = 2` : true anomaly at epoch (deg)
                - `options(3) = 3` : argument of latitude at epoch (deg)
                - `options(3) = 4` : true longitude at epoch (deg)
                - `options(3) = 5` : mean anomaly at epoch (deg)

   :param double startsfe: start time from provided date (s) - can be negative
   :param double stopsfe: stop time from provided date (s) - can be negative
   :param double deltasec: propagation step time (s)
   :output array of `NTIME_MAX` integer OUTyear: year for each orbital locations
   :output array of `NTIME_MAX` integer OUTdoy: day of year for each orbital locations
   :output array of `NTIME_MAX` double UT: time of day for each orbital locations (s)
   :output array of `NTIME_MAX` double X1: first coordinate of orbit according to `sysaxesOUT`
   :output array of `NTIME_MAX` double X2: second coordinate of orbit according to `sysaxesOUT`
   :output array of `NTIME_MAX` double X3: third coordinate of orbit according to `sysaxesOUT`
   :callseq MATLAB: pos = onera_desp_lib_sgp4_ele([e1,e2,e3,e4,e5,e6],startdate,enddate,deltasec,sysaxesOUT)
   :callseq IDL: result = call_external(lib_name, 'sgp4_ele_', sysaxesOUT,year,month,day,hour,minute,sec, e1,e2,e3,e4,e5,e6,options,startsfe,stopsfe,deltasec,OUTyear,OUTdoy,UT,X1,X2,X3, /f_value)
   :callseq FORTRAN: CALL sgp4_ele1(sysaxesOUT,year,month,day,hour,minute,sec, e1,e2,e3,e4,e5,e6,options,startsfe,stopsfe,deltasec,OUTyear,OUTdoy,UT,X1,X2,X3)

.. irbem:routine:: RV2COE

   This function finds the classical orbital elements given the Geocentric
   Equatorial Position and Velocity vectors. It comes from SGP4 distribution.

   :param array of 3 double R: position in :ref:`GEI <GEI>` (km)
   :param array of 3 double V: velocity in :ref:`GEI <GEI>` (km/s)
   :output double P: semilatus rectum (km)
   :output double A: semimajor axis (km)
   :output double ecc: eccentricity
   :output double incl: inclination (rad)
   :output double omega: longitude of ascending node (rad)
   :output double argp: argument of perigee (rad)
   :output double nu: true anomaly (rad)
   :output double M: mean anomaly (rad)
   :output double argLat: argument of latitude (rad)
   :output double lamTrue: true longitude (rad)
   :output double lonPer: longitude of periapsis (rad) 
   :callseq MATLAB: elements=onera_desp_lib_rv2coe(R,V) 
   :callseq IDL: result = call_external(lib_name, 'rv2coe_idl_', R,V,P,A,Ecc,Incl,Omega,Argp,Nu,M,ArgLat,LamTrue,LonPer, /f_value)
   :callseq FORTRAN: CALL rv2coe(R,V,P,A,Ecc,Incl,Omega,Argp,Nu,M,ArgLat,LamTrue,LonPer)

