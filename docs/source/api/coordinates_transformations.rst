Coordinates transformations
===========================

.. irbem:routine:: COORD_TRANS_VEC

   Generic coordinates transformation from one geophysical or heliospheric
   coordinate system to another.  

   :param integer ntime: number of time points
   :param integer sysaxesIN: key for the input coordinate system (see :ref:`sysaxes`)
   :param integer sysaxesOUT: key for the output coordinate system (see :ref:`sysaxes`)
   :param array of `ntime` integer iyear: the year
   :param array of `ntime` integer idoy: the day of year (January 1st is `idoy=1`)
   :param array of `ntime` double UT: the time in seconds 
   :param array of [3, `ntime`] double xIN: position in input coordinates system
   :output array of [3, `ntime`] double xOUT: position in output coordinates system
   :callseq MATLAB: Y=onera_desp_lib_coord_trans(X,rotation,matlabd)
   :callseq IDL: result = call_external(lib_name, 'coord_trans_vec_', ntime,sysaxesIN,sysaxesOUT,iyr,idoy,secs,xIN,xOUT, /f_value)
   :callseq FORTRAN: call coord_trans_vec1(ntime,sysaxesIN,sysaxesOUT,iyr,idoy,secs,xIN,xOUT)

Geographic coordinates transformations
--------------------------------------

.. irbem:routine:: GEO2GSM

   Transforms :ref:`GEO <GEO>` to  :ref:`GSM <GSM>` coordinates.

   :param integer iyr: the year
   :param integer idoy: the day of year (January 1st is `idoy=1`)
   :param double UT: the time in seconds
   :param array of 3 double xGEO: cartesian position in GEO (Re)
   :output double psi: angle for GSM coordinate
   :output array of 3 double xGSM: cartesian position in GSM (Re)
   :callseq MATLAB: xGSM = onera_desp_lib_rotate(xGEO,'geo2gsm',matlabd);
                    [xGSM,psi] = onera_desp_lib_rotate(xGEO,'geo2gsm',matlabd);
   :callseq IDL: result = call_external(lib_name, 'geo2gsm_', iyr,idoy,secs,psi,xGEO,xGSM, /f_value)
   :callseq FORTRAN: call geo2gsm1(iyr,idoy,secs,psi,xGEO,xGSM)

.. irbem:routine:: GSM2GEO

   Transforms :ref:`GSM <GSM>` to  :ref:`GEO <GEO>` coordinates.

   :param integer iyr: the year
   :param integer idoy: the day of year (January 1st is `idoy=1`)
   :param double UT: the time in seconds
   :param array of 3 double xGSM: cartesian position in GSM (Re)
   :output double psi: angle for GSM coordinate
   :output array of 3 double xGEO: cartesian position in GEO (Re)
   :callseq MATLAB: xGEO = onera_desp_lib_rotate(xGSM,'gsm2geo',matlabd);
                    [xGEO,psi] = onera_desp_lib_rotate(xGSM,'gsm2geo',matlabd);
   :callseq IDL: result = call_external(lib_name, 'gsm2geo_', iyr,idoy,secs,psi,xGSM,xGEO, /f_value)
   :callseq FORTRAN: call gsm2geo1(iyr,idoy,secs,psi,xGSM,xGEO)

.. irbem:routine:: GEO2GSE

   Transforms :ref:`GEO <GEO>` to  :ref:`GSE <GSE>` coordinates.

   :param integer iyr: the year
   :param integer idoy: the day of year (January 1st is `idoy=1`)
   :param double UT: the time in seconds
   :param array of 3 double xGEO: cartesian position in GEO (Re)
   :output array of 3 double xGSE: cartesian position in GSE (Re)
   :callseq MATLAB: xGSE = onera_desp_lib_rotate(xGEO,'geo2gse',matlabd);
   :callseq IDL: result = call_external(lib_name, 'geo2gse_', iyr,idoy,secs,xGEO,xGSE, /f_value)
   :callseq FORTRAN: call geo2gse1(iyr,idoy,secs,xGEO,xGSE)

.. irbem:routine:: GSE2GEO

   Transforms :ref:`GSE <GSE>` to  :ref:`GEO <GEO>` coordinates.

   :param integer iyr: the year
   :param integer idoy: the day of year (January 1st is `idoy=1`)
   :param double UT: the time in seconds
   :param array of 3 double xGSE: cartesian position in GSE (Re)
   :output array of 3 double xGEO: cartesian position in GEO (Re)
   :callseq MATLAB: xGEO = onera_desp_lib_rotate(xGSE,'gse2geo',matlabd);
   :callseq IDL: result = call_external(lib_name, 'gse2geo_', iyr,idoy,secs,xGSE,xGEO, /f_value)
   :callseq FORTRAN: call gse2geo1(iyr,idoy,secs,xGSE,xGEO)

.. irbem:routine:: GEO2GDZ
   Transforms :ref:`GEO <GEO>` to  :ref:`GDZ <GDZ>` coordinates.

   :param double xx: xGEO (Re)
   :param double yy: yGEO (Re)
   :param double zz: zGEO (Re)
   :output double lati: latitude (deg)
   :output double longi: East longitude (deg)
   :output double alti: altitude (km)
   :callseq MATLAB: xGDZ = onera_desp_lib_rotate([xx(:) yy(:) zz(:)],'geo2gdz');
                    alti = xGDZ(:,1); lati = xGDZ(:,2); longi = xGDZ(:,3);
   :callseq IDL: result = call_external(lib_name, 'geo2gdz_', xx,yy,zz,lati,longi,alti, /f_value)
   :callseq FORTRAN: call geo_gdz(xx,yy,zz,lati,longi,alti)

.. irbem:routine:: GDZ2GEO
   Transforms :ref:`GDZ <GDZ>` to  :ref:`GEO <GEO>` coordinates.

   :param double lati: latitude (deg)
   :param double longi: East longitude (deg)
   :param double alti: altitude (km)
   :output double xx: xGEO (Re)
   :output double yy: yGEO (Re)
   :output double zz: zGEO (Re)
   :callseq MATLAB: xGEO = onera_desp_lib_rotate([alti(:), lati(:), longi(:)],'gdz2geo');
                    xx = xGEO(:,1); yy = xGEO(:,2); zz = xGEO(:,3);
   :callseq IDL: result = call_external(lib_name, 'gdz2geo_', lati,longi,alti,xx,yy,zz, /f_value)
   :callseq FORTRAN: call gdz_geo(lati,longi,alti,xx,yy,zz)

.. irbem:routine:: GEO2GEI

   Transforms :ref:`GEO <GEO>` to  :ref:`GEI <GEI>` coordinates.

   :param integer iyr: the year
   :param integer idoy: the day of year (January 1st is `idoy=1`)
   :param double UT: the time in seconds
   :param array of 3 double xGEO: cartesian position in GEO (Re)
   :output array of 3 double xGEI: cartesian position in GEI (Re)
   :callseq MATLAB: xGEI = onera_desp_lib_rotate(xGEO,'geo2gei',matlabd);
   :callseq IDL: result = call_external(lib_name, 'geo2gei_', iyr,idoy,secs,xGEO,xGEI, /f_value)
   :callseq FORTRAN: call geo2gei1(iyr,idoy,secs,xGEO,xGEI)

.. irbem:routine:: GEI2GEO

   Transforms :ref:`GEI <GEI>` to  :ref:`GEO <GEO>` coordinates.

   :param integer iyr: the year
   :param integer idoy: the day of year (January 1st is `idoy=1`)
   :param double UT: the time in seconds
   :param array of 3 double xGEI: cartesian position in GEI (Re)
   :output array of 3 double xGEO: cartesian position in GEO (Re)
   :callseq MATLAB: xGEO = onera_desp_lib_rotate(xGEI,'gei2geo',matlabd);
   :callseq IDL: result = call_external(lib_name, 'gei2geo_', iyr,idoy,secs,xGEI,xGEO, /f_value)
   :callseq FORTRAN: call gei2geo1(iyr,idoy,secs,xGEI,xGEO)

.. irbem:routine:: GEO2SM

   Transforms :ref:`GEO <GEO>` to  :ref:`SM <SM>` coordinates.

   :param integer iyr: the year
   :param integer idoy: the day of year (January 1st is `idoy=1`)
   :param double UT: the time in seconds
   :param array of 3 double xGEO: cartesian position in GEO (Re)
   :output array of 3 double xSM: cartesian position in SM (Re)
   :callseq MATLAB: xSM = onera_desp_lib_rotate(xGEO,'geo2sm',matlabd);
   :callseq IDL: result = call_external(lib_name, 'geo2sm_', iyr,idoy,secs,xGEO,xSM, /f_value)
   :callseq FORTRAN: call geo2sm1(iyr,idoy,secs,xGEO,xSM)

.. irbem:routine:: SM2GEO

   Transforms :ref:`SM <SM>` to  :ref:`GEO <GEO>` coordinates.

   :param integer iyr: the year
   :param integer idoy: the day of year (January 1st is `idoy=1`)
   :param double UT: the time in seconds
   :param array of 3 double xSM: cartesian position in SM (Re)
   :output array of 3 double xGEO: cartesian position in GEO (Re)
   :callseq MATLAB: xGEO = onera_desp_lib_rotate(xSM,'sm2geo',matlabd);
   :callseq IDL: result = call_external(lib_name, 'sm2geo_', iyr,idoy,secs,xSM,xGEO, /f_value)
   :callseq FORTRAN: call sm2geo1(iyr,idoy,secs,xSM,xGEO)

.. irbem:routine:: GSM2SM

   Transforms :ref:`GSM <GSM>` to  :ref:`SM <SM>` coordinates.

   :param integer iyr: the year
   :param integer idoy: the day of year (January 1st is `idoy=1`)
   :param double UT: the time in seconds
   :param array of 3 double xGSM: cartesian position in GSM (Re)
   :output array of 3 double xSM: cartesian position in SM (Re)
   :callseq MATLAB: xSM = onera_desp_lib_rotate(xGSM,'gsm2sm',matlabd);
   :callseq IDL: result = call_external(lib_name, 'gsm2sm_', iyr,idoy,secs,xGSM,xSM, /f_value)
   :callseq FORTRAN: call gsm2sm1(iyr,idoy,secs,xGSM,xSM)

.. irbem:routine:: SM2GSM

   Transforms :ref:`SM <SM>` to  :ref:`GSM <GSM>` coordinates.

   :param integer iyr: the year
   :param integer idoy: the day of year (January 1st is `idoy=1`)
   :param double UT: the time in seconds
   :param array of 3 double xSM: cartesian position in SM (Re)
   :output array of 3 double xGSM: cartesian position in GSM (Re)
   :callseq MATLAB: xGSM = onera_desp_lib_rotate(xSM,'sm2gsm',matlabd);
   :callseq IDL: result = call_external(lib_name, 'sm2gsm_', iyr,idoy,secs,xSM,xGSM, /f_value)
   :callseq FORTRAN: call sm2gsm1(iyr,idoy,secs,xSM,xGSM)

.. irbem:routine:: GEO2MAG

   Transforms :ref:`GEO <GEO>` to  :ref:`MAG <MAG>` coordinates.

   :param integer iyr: the year
   :param array of 3 double xGEO: cartesian position in GEO (Re)
   :output array of 3 double xMAG: cartesian position in MAG (Re)
   :callseq MATLAB: xMAG = onera_desp_lib_rotate(xGEO,'geo2mag',matlabd);
   :callseq IDL: result = call_external(lib_name, 'geo2mag_', iyr,idoy,secs,xGEO,xMAG, /f_value)
   :callseq FORTRAN: call geo2mag1(iyr,xGEO,xMAG)

.. irbem:routine:: MAG2GEO

   Transforms :ref:`MAG <MAG>` to  :ref:`GEO <GEO>` coordinates.

   :param integer iyr: the year
   :param integer idoy: the day of year (January 1st is `idoy=1`)
   :param double UT: the time in seconds
   :param array of 3 double xMAG: cartesian position in MAG (Re)
   :output array of 3 double xGEO: cartesian position in GEO (Re)
   :callseq MATLAB: xGEO = onera_desp_lib_rotate(xMAG,'mag2geo',matlabd);
   :callseq IDL: result = call_external(lib_name, 'mag2geo_', iyr,idoy,secs,xMAG,xGEO, /f_value)
   :callseq FORTRAN: call mag2geo1(iyr,xMAG,xGEO)

.. irbem:routine:: SPH2CAR
   
   Routine to transform spherical coordinates to cartesian.

   :param double r: radial distance (arbitrary unit)
   :param double lati: latitude (deg)
   :param double longi: East longitude (deg)
   :output array of 3 double x: cartesian coordinates (same unit as `r`)
   :callseq MATLAB: xCAR = onera_desp_lib_rotate([r(:), lati(:), longi(:)],'sph2car');
   :callseq IDL: result = call_external(lib_name, 'sph2car_', r,lati,longi,x, /f_value)
   :callseq FORTRAN: call SPH_CAR(r,lati,longi,x)

.. irbem:routine:: CAR2SPH
   
   Routine to transform cartesian coordinates to spherical.

   :param array of 3 double x: cartesian coordinates (arbitrary unit)
   :output double r: radial distance (same unit as `x`)
   :output double lati: latitude (deg)
   :output double longi: East longitude (deg)
   :callseq MATLAB: xSPH = onera_desp_lib_rotate(xCAR,'car2sph');
                    r = xSPH(:,1); lati = xSPH(:,2); longi = xSPH(:,3);
   :callseq IDL: result = call_external(lib_name, 'car2sph_',x,r,lati,longi, /f_value)
   :callseq FORTRAN: call CAR_SPH(x,r,lati,longi)

.. irbem:routine:: RLL2GDZ

   Transforms :ref:`RLL <RLL>` to :ref:`GDZ <GDZ>`

   :param double r: radial distance (Re)
   :param double lati: latitude (deg)
   :param double longi: East longitude (deg)
   :output double alti: altitude (km)
   :callseq MATLAB: xGDZ = onera_desp_lib_rotate([r(:), lati(:), longi(:)],'rll2gdz');
                    alti = xGDZ(:,1); lati = xGDZ(:,2); longi = xGDZ(:,3);
   :callseq IDL: result = call_external(lib_name, 'rll2gdz_', r,lati,longi,alti, /f_value)
   :callseq FORTRAN: call RLL_GDZ(r,lati,longi,alti)


Geographic to heliospheric and vice versa coordinates transformations
---------------------------------------------------------------------

.. irbem:routine:: GSE2HEE

   Routine to transform geocentric coordinates GSE to heliospheric coordinates HEE
   (Heliocentric Earth Ecliptic also sometime known as Heliospheric Solar Ecliptic
   (HSE)).

   :param integer iyr: the year
   :param integer idoy: the day of year (January 1st is `idoy=1`)
   :param double UT: the time in seconds
   :param array of 3 double xGSE: cartesian position in GSE (Re)
   :output array of 3 double xHEE: cartesian position in HEE (AU)
   :callseq MATLAB: xHEE = onera_desp_lib_rotate(xGSE,'gse2hee',matlabd);
   :callseq IDL: result = call_external(lib_name, 'gse2hee_', iyr,idoy,UT,xGSE,xHEE, /f_value)
   :callseq FORTRAN: call gse2hee1(iyr,idoy,UT,xGSE,xHEE)

.. irbem:routine:: HEE2GSE

   Routine to transform heliospheric coordinates HEE (Heliocentric Earth
   Ecliptic, also sometime known as Heliospheric Solar Ecliptic (HSE)) to
   geocentric coordinates GSE.
   
   :param integer iyr: the year
   :param integer idoy: the day of year (January 1st is `idoy=1`)
   :param double UT: the time in seconds
   :param array of 3 double xHEE: cartesian position in HEE (AU)
   :output array of 3 double xGSE: cartesian position in GSE (Re)
   :callseq MATLAB: xGSE = onera_desp_lib_rotate(xHEE,'hee2gse',matlabd);
   :callseq IDL: result = call_external(lib_name, 'hee2gse_', iyr,idoy,UT,xHEE,xGSE, /f_value)
   :callseq FORTRAN: call hee2gse1(iyr,idoy,UT,xHEE,xGSE)


Heliospheric coordinates transformations
----------------------------------------

.. irbem:routine:: HEE2HAE

   Routine to transform heliospheric coordinates HEE (Heliocentric Earth
   Ecliptic also sometime known as Heliospheric Solar Ecliptic (HSE)) to
   heliospheric coordinates HAE (Heliocentric Aries Ecliptic also sometime
   known as Heliospheric Solar Ecliptic (HSE))
   
   :param integer iyr: the year
   :param integer idoy: the day of year (January 1st is `idoy=1`)
   :param double UT: the time in seconds
   :param array of 3 double xHEE: cartesian position in HEE (AU)
   :output array of 3 double xHAE: cartesian position in HAE (AU)
   :callseq MATLAB: onera_desp_lib_rotate(xHEE,'hee2hae',matlabd);
   :callseq IDL: result = call_external(lib_name, 'hee2hae_', iyr,idoy,UT,xHEE,xHAE, /f_value)
   :callseq FORTRAN: call hee2hae1(iyr,idoy,UT,xHEE,xHAE)

.. irbem:routine:: HAE2HEE

   Routine to transform heliospheric coordinates HAE (Heliocentric Aries
   Ecliptic also sometime known as Heliospheric Solar Ecliptic (HSE)) to
   heliospheric coordinates HEE (Heliocentric Earth Ecliptic also sometime
   known as Heliospheric Solar Ecliptic (HSE))
   
   :param integer iyr: the year
   :param integer idoy: the day of year (January 1st is `idoy=1`)
   :param double UT: the time in seconds
   :param array of 3 double xHAE: cartesian position in HAE (AU)
   :output array of 3 double xHEE: cartesian position in HEE (AU)
   :callseq MATLAB: xHEE = onera_desp_lib_rotate(xHAE,'hae2hee',matlabd);
   :callseq IDL: result = call_external(lib_name, 'hae2hee_', iyr,idoy,UT,xHAE,xHEE, /f_value)
   :callseq FORTRAN: call hae2hee1(iyr,idoy,UT,xHAE,xHEE)

.. irbem:routine:: HAE2HEEQ

   Routine to transform heliospheric coordinates HAE (Heliocentric Aries
   Ecliptic also sometime known as Heliospheric Solar Ecliptic (HSE)) to
   heliospheric coordinates HEEQ (Heliocentric Earth Equatorial also
   sometime known as Heliospheric Solar (HS))
   
   :param integer iyr: the year
   :param integer idoy: the day of year (January 1st is `idoy=1`)
   :param double UT: the time in seconds
   :param array of 3 double xHAE: cartesian position in HAE (AU)
   :output array of 3 double xHEEQ: cartesian position in HEEQ (AU)
   :callseq MATLAB: xHEEQ = onera_desp_lib_rotate(xHAE,'hae2heeq',matlabd);
   :callseq IDL: result = call_external(lib_name, 'hae2heeq_', iyr,idoy,UT,xHAE,xHEEQ, /f_value)
   :callseq FORTRAN: call hae2heeq1(iyr,idoy,UT,xHAE,xHEEQ)


.. irbem:routine:: HEEQ2HAE
   
   Routine to transform heliospheric coordinates HEEQ (Heliocentric Earth
   Equatorial also sometime known as Heliospheric Solar (HS)) to heliospheric
   coordinates HAE (Heliocentric Aries Ecliptic also sometime known as
   Heliospheric Solar Ecliptic (HSE))
    
   
   :param integer iyr: the year
   :param integer idoy: the day of year (January 1st is `idoy=1`)
   :param double UT: the time in seconds
   :param array of 3 double xHEEQ: cartesian position in HEEQ (AU)
   :output array of 3 double xHAE: cartesian position in HAE (AU)
   :callseq MATLAB: xHAE = onera_desp_lib_rotate(xHEEQ,'heeq2hae',matlabd);
   :callseq IDL: result = call_external(lib_name, 'heeq2hae_', iyr,idoy,UT,xHEEQ,xHAE, /f_value)
   :callseq FORTRAN: call heeq2hae1(iyr,idoy,UT,xHEEQ,xHAE)

