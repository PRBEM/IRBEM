Radiation belt and effect models
================================

AE8 and AP8 models
------------------

.. irbem:routine:: FLY_IN_NASA_AEAP
   
   This function allows one to fly any spacecraft in NASA AE8 min/max and AP8 min/max models.
   The output can be differential flux or flux within an energy range or integral
   flux.

   .. note::
      
       This routine can also provide the ESA interpolation scheme as detailed
       in (`Daly et al., 1996`_) for enhanced flux interpolations at low altitudes.
       This interpolation scheme can be activated using negative values for the
       `whichm` parameter.

   
   :param integer ntime: number of time points up to :code:`NTIME_MAX` (see :ref:`NTIME_MAX`)
   :param integer sysaxes: key for the input coordinate system (see :ref:`sysaxes`)
   :param integer whichm: key to select the NASA model:

                          * 1 : AE8 MIN
                          * 2 : AE8 MAX
                          * 3 : AP8 MIN
                          * 4 : AP8 MAX
                          * -1 : AE8 MIN - ESA Interpolation
                          * -2 : AE8 MAX - ESA Interpolation
                          * -3 : AP8 MIN - ESA Interpolation
                          * -4 : AP8 MAX - ESA Interpolation

   :param integer whatf: key to select the type of flux to compute:

                         * 1 : differential flux at energy E1 (MeV\ :sup:`-1` cm\ :sup:`-2` s\ :sup:`-1`)
                         * 2 : flux within the E1 to E2 energy range (MeV\ :sup:`-1` cm\ :sup:`-2` s\ :sup:`-1`)
                         * 3 : integral flux above E1 (cm\ :sup:`-2` s\ :sup:`-1`)

   :param integer Nene: number of energies
   :param array of [2, `Nene`] double energy: energy levels (E1, E2), if `whatf` is 1 or 3, E2 is not considered (MeV)
   :param array of `ntime` integer iyear: the year
   :param array of `ntime` integer idoy: the day of year (January 1st is `idoy=1`)
   :param array of `ntime` double UT: the time in seconds 
   :param array of `ntime` double x1: first coordinate according to `sysaxes`
   :param array of `ntime` double x2: second coordinate according to `sysaxes`
   :param array of `ntime` double x3: third coordinate according to `sysaxes`
   :output array of [`NTIME_MAX`, `Nene`] double flux: flux values for all times and energies
   :callseq MATLAB: Flux = onera_desp_lib_fly_in_nasa_aeap(sysaxes,whichm,energy,matlabd,x1,x2,x3)
   :callseq IDL: result = call_external(lib_name, 'fly_in_nasa_aeap_', ntime,sysaxes,whichm,whatf,Nene,energy,iyear,idoy, UT,x1,x2,x3,flux, /f_value)
   :callseq FORTRAN: CALL fly_in_nasa_aeap1(ntime,sysaxes,whichm,whatf,Nene,energy,iyear,idoy, UT,x1,x2,x3,flux)


.. irbem:routine:: GET_AE8_AP8_FLUX
   
   This function allows one to compute NASA AE8 min/max and AP8 min/max flux
   for any B/Bo, L position.
   
   The output can be differential flux or flux within an energy range or integral
   flux.

   .. note::
      
       This routine can also provide the ESA interpolation scheme as detailed
       in (`Daly et al., 1996`_) for enhanced flux interpolations at low altitudes.
       This interpolation scheme can be activated using negative values for the
       `whichm` parameter.

   
   :param integer ntime: number of time points up to :code:`NTIME_MAX` (see :ref:`NTIME_MAX`)
   :param integer whichm: key to select the NASA model:

                          * 1 : AE8 MIN
                          * 2 : AE8 MAX
                          * 3 : AP8 MIN
                          * 4 : AP8 MAX
                          * -1 : AE8 MIN - ESA Interpolation
                          * -2 : AE8 MAX - ESA Interpolation
                          * -3 : AP8 MIN - ESA Interpolation
                          * -4 : AP8 MAX - ESA Interpolation

   :param integer whatf: key to select the type of flux to compute:

                         * 1 : differential flux at energy E1 (MeV\ :sup:`-1` cm\ :sup:`-2` s\ :sup:`-1`)
                         * 2 : flux within the E1 to E2 energy range (MeV\ :sup:`-1` cm\ :sup:`-2` s\ :sup:`-1`)
                         * 3 : integral flux above E1 (cm\ :sup:`-2` s\ :sup:`-1`)

   :param integer Nene: number of energies
   :param array of [2, `Nene`] double energy: energy levels (E1, E2), if `whatf` is 1 or 3, E2 is not considered (MeV)
   :param array of `ntime` double BBo: B/Bequator for all position where to
                                       compute the fluxes. Note that the Jensen
                                       and Cain 1960 magnetic field model must
                                       be used for any call to AE8min, AE8max,
                                       AP8min and GSFC 1266 (extended to year
                                       1970) for any call to AP8max.
   :param array of `ntime` double L: Provide McIlwain L for all position where
                                     to compute the fluxes.  Note that the
                                     Jensen and Cain 1960 magnetic field model
                                     must be used for any call to AE8min,
                                     AE8max, AP8min and GSFC 1266 (extended to
                                     year 1970) for any call to AP8max.
   :output array of [`NTIME_MAX`, `Nene`] double flux: flux values for all times and energies
   :callseq MATLAB: onera_desp_lib_get_ae8_ap8_flux(whichm,energy,BBo,L)
   :callseq IDL: result = call_external(lib_name, 'get_ae8_ap8_flux_idl_', ntime,whichm,whatf,Nene,energy,BBo,L,,flux, /f_value)
   :callseq FORTRAN: CALL get_ae8_ap8_flux (ntime,whichm,whatf,Nene,energy,BBo,L,flux )
   
.. _Daly et al., 1996: http://doi.org/10.1109/23.490889

AFRL CRRES models
-----------------

.. irbem:routine:: FLY_IN_AFRL_CRRES
   
   This function allows one to fly any spacecraft in AFRL CRRESPRO and CRRESELE
   models.  The output can be differential flux or flux within an energy range
   or integral flux.

   ..warning ::
   
      Integral flux for electron are from E to  5.75 MeV and for proton are
      from E to 81.3 MeV.

   To run CRRES models you have to set the full path for the source code
   directory (where CRRES data files are located).

   :param integer ntime: number of time points up to :code:`NTIME_MAX` (see :ref:`NTIME_MAX`)
   :param integer sysaxes: key for the input coordinate system (see :ref:`sysaxes`)
   :param integer whichm: key to select the NASA model:

                          * 1 : CRRESPRO QUIET
                          * 2 : CRRESPRO ACTIVE
                          * 3 : CRRESELE AVERAGE
                          * 4 : CRRESELE WORST CASE
                          * 5 : CRRESELE Ap15

   :param integer whatf: key to select the type of flux to compute:

                         * 1 : differential flux at energy E1 (MeV\ :sup:`-1` cm\ :sup:`-2` s\ :sup:`-1`)
                         * 2 : flux within the E1 to E2 energy range (MeV\ :sup:`-1` cm\ :sup:`-2` s\ :sup:`-1`)
                         * 3 : integral flux above E1 (cm\ :sup:`-2` s\ :sup:`-1`)

   :param integer Nene: number of energies
   :param array of [2, `Nene`] double energy: energy levels (E1, E2), if `whatf` is 1 or 3, E2 is not considered (MeV)
   :param array of `ntime` integer iyear: the year
   :param array of `ntime` integer idoy: the day of year (January 1st is `idoy=1`)
   :param array of `ntime` double UT: the time in seconds 
   :param array of `ntime` double x1: first coordinate according to `sysaxes`
   :param array of `ntime` double x2: second coordinate according to `sysaxes`
   :param array of `ntime` double x3: third coordinate according to `sysaxes`
   :param array of `ntime` double Ap15: preceding 15-day running average of the Ap index assuming a one day delay, ignored if `whichm` is not equal to 5
   :param byte array path: path to locate the files which describe CRRES models
   :param integer path_len: length of the `path` string
   :output array of [`NTIME_MAX`, `Nene`] double flux: flux values for all times and energies
   :callseq MATLAB: Flux = onera_desp_lib_fly_in_afrl_crres(sysaxes,whichm,energy,matlabd,x1,x2,x3,Ap15,crres_path)
   :callseq IDL: result = call_external(lib_name, 'fly_in_afrl_crres_', ntime,sysaxes,whichm,whatf,Nene,energy,iyear,idoy, UT,x1,x2,x3,Ap15,flux,path,path_len, /f_value)
   :callseq FORTRAN: CALL fly_in_afrl_crres1(ntime,sysaxes,whichm,whatf,Nene,energy,iyear,idoy, UT,x1,x2,x3,Ap15,flux,path,path_len)


.. irbem:routine:: GET_CRRES_FLUX
   
   This function allows one to compute AFRL CRRESPRO and CRRESELE flux for any
   B/Bo, L position.
   The output can be differential flux or flux within an energy range or integral
   flux.

   ..warning ::
   
      Integral flux for electron are from E to  5.75 MeV and for proton are
      from E to 81.3 MeV.

   To run CRRES models you have to set the full path for the source code
   directory (where CRRES data files are located).

   :param integer ntime: number of time points up to :code:`NTIME_MAX` (see :ref:`NTIME_MAX`)
   :param integer sysaxes: key for the input coordinate system (see :ref:`sysaxes`)
   :param integer whichm: key to select the NASA model:

                          * 1 : CRRESPRO QUIET
                          * 2 : CRRESPRO ACTIVE
                          * 3 : CRRESELE AVERAGE
                          * 4 : CRRESELE WORST CASE
                          * 5 : CRRESELE Ap15

   :param integer whatf: key to select the type of flux to compute:

                         * 1 : differential flux at energy E1 (MeV\ :sup:`-1` cm\ :sup:`-2` s\ :sup:`-1`)
                         * 2 : flux within the E1 to E2 energy range (MeV\ :sup:`-1` cm\ :sup:`-2` s\ :sup:`-1`)
                         * 3 : integral flux above E1 (cm\ :sup:`-2` s\ :sup:`-1`)

   :param integer Nene: number of energies
   :param array of [2, `Nene`] double energy: energy levels (E1, E2), if `whatf` is 1 or 3, E2 is not considered (MeV)
   :param array of `ntime` double BBo: B/Bequator for all position where to
                                       compute the fluxes. Note that the
                                       IGRF1985 magnetic field model must be
                                       used.
   :param array of `ntime` double L: Provide McIlwain L for all position where
                                     to compute the fluxes. Note that the
                                     IGRF1985 magnetic field model must be
                                     used.
   :param array of `ntime` double Ap15: preceding 15-day running average of the Ap index assuming a one day delay, ignored if `whichm` is not equal to 5
   :param byte array path: path to locate the files which describe CRRES models
   :param integer path_len: length of the `path` string
   :output array of [`NTIME_MAX`, `Nene`] double flux: flux values for all times and energies
   :callseq MATLAB: Flux = onera_desp_lib_get_crres_flux(whichm,energy,BBo,L,Ap15,crres_path)
   :callseq IDL: result = call_external(lib_name, 'get_crres_flux_idl_', ntime,whichm,whatf,Nene,energy,BBo,L,Ap15,flux,path,path_len, /f_value)
   :callseq FORTRAN: CALL get_crres_flux(ntime,whichm,whatf,Nene,energy,BBo,L,Ap15,flux,path,path_len)

Other radiation models
----------------------

.. irbem:routine:: FLY_IN_IGE
   
   This function allows one to fly any geostationary spacecraft in IGE
   (International Geostationary Electron) models. The use of the model is
   limited to geostationary altitude as it is based on LANL-GEO  bird series
   (1976 to 2006) and JAXA-DRTS spacecraft (added in IGE2006). Three versions
   of the model are provided:
   
   POLE-V1: 
      it covers electron energies from 30 keV-1.3 MeV (issued in 2003)
      Published in Boscher D., S. Bourdarie, R. Friedel and D. Belian, A model
      for the geostationary electron environment : POLE, IEEE Trans. Nuc. Sci.,
      50 (6), 2278-2283, Dec. 2003.
   POLE-V2:
      it covers electron energies from 30 keV-5.2 MeV (issued in 2005)
      Published in Sicard-Piet A., S. Bourdarie, Boscher D. and R. Friedel, A
      model for the geostationary electron environment : POLE from 30 keV to 5.2
      MeV, IEEE Trans. Nuc. Sci., 53 (4), 1844-1850, Aug. 2006.
   IGE-2006:
      it covers electron energies from 0.9 keV-5.2 MeV (issued in 2006)
      Submitted in Sicard-Piet A., S. Bourdarie, Boscher D., R. Friedel M.
      Thomsen, T. Goka, H. Matsumoto, H. Koshiishi, A new international
      geostationary model: IGE-2006 from 1 keV to 5.2 MeV, JGR-Space Weather,
      2007.

   POLE stands for Particle-ONERA-LANL-Electrons. The output can be
   differential flux or flux within an energy range or integral flux.

   .. warning::

      This routine returns fluxes expressed in MeV\ :sup:`-1` cm\ :sup:`-2` s\ :sup:`-1` sr\ :sup:`-1`for differential fluxes of in cm\ :sup:`-2` s\ :sup:`-1` sr\ :sup:`-1` for integral fluxes. To derive omnidirectional fluxes at GEO, one should multiply these flux values by 4π sr.

   .. warning::
   
      Integral flux for electron are from E to Emax of the given
      selected model. So one should be very carrefull when looking at integral
      fluxes with POLE-V1 .

   :param integer launch_year: year of spacecraft start of life in space
   :param integer mission_duration: duration of the mission (year)
   :param integer whichm: key to select the NASA model:

                          * 1 : POLE-V1
                          * 2 : POLE-V2
                          * 3 : IGE-2006

   :param integer whatf: key to select the type of flux to compute:

                         * 1 : differential flux at energy E1 (MeV\ :sup:`-1` cm\ :sup:`-2` s\ :sup:`-1` sr\ :sup:`-1`)
                         * 2 : flux within the E1 to E2 energy range (MeV\ :sup:`-1` cm\ :sup:`-2` s\ :sup:`-1` sr\ :sup:`-1`)
                         * 3 : integral flux above E1 (cm\ :sup:`-2` s\ :sup:`-1` sr\ :sup:`-1`)

   :param integer Nene: number of energies - if 0, then the default energies are used (their number are returned in the `Nene` parameter, and their values are returned in the `energy` parameter) in this case all arrays of size `Nene` should be at least of size 50
   :param array of [2, `Nene`] double energy: energy levels (E1, E2), if `whatf` is 1 or 3, E2 is not considered (MeV)
   :output array of `Nene` double lower_flux: lower flux according to selection of whatf for all energies averaged over entire mission duration - This has to be considered as a lower envelop to bound expected flux at GEO for any solar cycle
   :output array of `Nene` double mean_flux: mean flux according to selection of whatf for all energies averaged over entire mission duration - This spectrum is an averaged expected flux at GEO for any solar cycle , no margins are included at this point
   :output array of `Nene` double upper_flux: upper flux according to selection of whatf for all energies averaged over entire mission duration - This has to be considered as an upper envelop for expected flux at GEO for any solar cycle, this spectrum can be used for any conservative approach as margins are included at this point. Note that the margins are energy dependant and can be assesed by looking at the ratio between `upper_flux` and `mean_flux`
   :callseq MATLAB: [Lower_flux,Mean_flux,Upper_flux] = onera_desp_lib_fly_in_ige(launch_year,mission_duration,whichm,whatf,energy)
   :callseq IDL: result = call_external(lib_name, 'fly_in_ige_', launch_year,mission_duration,whichm,whatf,Nene,energy,Lower_flux,Mean_flux,Upper_flux, /f_value)
   :callseq FORTRAN: CALL fly_in_ige1(launch_year,mission_duration,whichm,whatf,Nene,energy,Lower_flux,Mean_flux,Upper_flux)


.. irbem:routine:: FLY_IN_MEO_GNSS
   
   This function allows one to fly any MEO GNSS type spacecraft in MEO ONERA
   models. The use of the model is limited to GPS altitude (~20000 km - 55 deg
   inclination) as it is based on LANL-GPS  bird series (1990 to 2006). Two
   versions of the model are provided:
   
   MEO-V1: 
       it covers electron energies from 280 keV-1.12 MeV (issued in 2006). Note
       that in this model there is no solar cycle variations which is to say
       that the model should be used for long term studies on the order of a
       solar cycle duration (i.e. 11 years).
       Published in Sicard-Piet A., S. Bourdarie,D. Boscher, R. Friedel and T.
       Cayton, Solar cycle electron environment at GNSS like altitudes,
       IAC-06-D5.2.04,2006.
   MEO-V2:
       known as MEO-V2, it covers electron energies from 280 keV-2.24 MeV
       (issued in 2007)

   The output can be differential flux or flux within an energy range or
   integral flux.

   .. warning::

      This routine returns fluxes expressed in MeV\ :sup:`-1` cm\ :sup:`-2` s\ :sup:`-1` sr\ :sup:`-1`for differential fluxes of in cm\ :sup:`-2` s\ :sup:`-1` sr\ :sup:`-1` for integral fluxes. To derive omnidirectional fluxes, one should multiply these flux values by 4π sr.

   :param integer launch_year: year of spacecraft start of life in space
   :param integer mission_duration: duration of the mission (year)
   :param integer whichm: key to select the NASA model:

                          * 1 : MEO-V1
                          * 2 : MEO-V2

   :param integer whatf: key to select the type of flux to compute:

                         * 1 : differential flux at energy E1 (MeV\ :sup:`-1` cm\ :sup:`-2` s\ :sup:`-1` sr\ :sup:`-1`)
                         * 2 : flux within the E1 to E2 energy range (MeV\ :sup:`-1` cm\ :sup:`-2` s\ :sup:`-1` sr\ :sup:`-1`)
                         * 3 : integral flux above E1 (cm\ :sup:`-2` s\ :sup:`-1` sr\ :sup:`-1`)

   :param integer Nene: number of energies - if 0, then the default energies are used (their number are returned in the `Nene` parameter, and their values are returned in the `energy` parameter) in this case all arrays of size `Nene` should be at least of size 50
   :param array of [2, `Nene`] double energy: energy levels (E1, E2), if `whatf` is 1 or 3, E2 is not considered (MeV)
   :output array of `Nene` double lower_flux: lower flux according to selection of whatf for all energies averaged over entire mission duration - This has to be considered as a lower envelop to bound expected flux at MEO-GNSS for any solar cycle
   :output array of `Nene` double mean_flux: mean flux according to selection of whatf for all energies averaged over entire mission duration - This spectrum is an averaged expected flux at MEO-GNSS for any solar cycle, no margins are included at this point
   :output array of `Nene` double upper_flux: upper flux according to selection of whatf for all energies averaged over entire mission duration - This has to be considered as an upper envelop for expected flux at MEO-GNSS for any solar cycle, this spectrum can be used for any conservative approach as margins are included at this point. Note that the margins are energy dependant and can be assesed by looking at the ratio between `upper_flux` and `mean_flux`
   :callseq MATLAB: [Lower_flux,Mean_flux,Upper_flux] = onera_desp_lib_fly_in_meo_gnss(launch_year,mission_duration,whichm,energy)
   :callseq IDL: result = call_external(lib_name, 'fly_in_meo_gnss_', launch_year,mission_duration,whichm,whatf,Nene,energy,Lower_flux,Mean_flux,Upper_flux, /f_value)
   :callseq FORTRAN: CALL fly_in_meo_gnss1(launch_year,mission_duration,whichm,whatf,Nene,energy,Lower_flux,Mean_flux,Upper_flux)CALL fly_in_ige1(launch_year,mission_duration,whichm,whatf,Nene,energy,Lower_flux,Mean_flux,Upper_flux)

Effect models
--------------

.. irbem:routine:: SHIELDOSE2

   SHIELDOSE2 [Seltzer, 1994] is a computer code for space-shielding radiation
   dose calculations. It determines the absorbed dose as a function of depth in
   aluminium shielding material of spacecraft, given the electron and proton
   fluences encountered in orbit. The code makes use of precalculated,
   mono-energetic depth-dose data for an isotropic, broad-beam fluence of
   radiation incident on uniform aluminium plane media. Such data are
   particularly suitable for routine dose predictions in situations where the
   geometrical and compositional complexities of the spacecraft are not known.
   Furthermore, the restriction to these rather simple geometries has allowed
   for the development of accurate electron and electron-bremsstrahlung data
   sets based on detailed transport calculations rather than on more
   approximate methods.

   SHIELDOSE2 calculates, for arbitrary proton and electron incident spectra,
   the dose absorbed in small volumes of different detector materials for the
   following aluminium shield geometries:

   * in a semi-infinite plane medium, as a function of depth; irradiation is
     from one side only (the assumed infinite backing effectively insures
     this).
   * at the transmission surface of a plane slab, as a function of slab
     thickness; irradiation is from one side only.
   * at the centre of a solid sphere, as a function of sphere radius;
     irradiation is from all directions.

   .. note::
      
      Below is provided a reasonable thickness array in g/cm2 with IMAX=70
          
      .. code-block:: FORTRAN

          data Zin /1.000E-06,2.000E-06,5.000E-06,1.000E-05,2.000E-05,5.000E-05,1.000E-04,2.000E-04,&
                    5.000E-04,1.000E-03,1.000E-01,2.000E-01,5.000E-01,7.000E-01,1.000E+00,1.250E+00,&
                    1.500E+00,1.750E+00,2.000E+00,2.500E+00,3.000E+00,3.500E+00,4.000E+00,4.500E+00,&
                    5.000E+00,6.000E+00,7.000E+00,8.000E+00,9.000E+00,1.000E+01,1.100E+01,1.200E+01,&
                    1.300E+01,1.400E+01,1.500E+01,1.600E+01,1.700E+01,1.800E+01,1.900E+01,2.000E+01,&
                    2.100E+01,2.200E+01,2.300E+01,2.400E+01,2.500E+01,2.600E+01,2.700E+01,2.800E+01,&
                    2.900E+01,3.000E+01,3.100E+01,3.200E+01,3.300E+01,3.400E+01,3.500E+01,3.600E+01,&
                    3.700E+01,3.800E+01,3.900E+01,4.000E+01,4.100E+01,4.200E+01,4.300E+01,4.400E+01,&
                    4.500E+01,4.600E+01,4.700E+01,4.800E+01,4.900E+01,5.000E+01,0.000E+00/

   :param integer idet: detector type:

                    #. Al detector
                    #. Graphite detector
                    #. Si detector
                    #. Air detector
                    #. Bone detector
                    #. Calcium Fluoride detector
                    #. Gallium Arsenide detector
                    #. Lithium Fluoride detector
                    #. Silicon Dioxide detector
                    #. Tissue detector
                    #. Water detector

   :param integer inuc: nuclear interaction to account for:
   
                    #. No nuclear attenuation for protons in Al
                    #. Nuclear attenuation, local charged-secondary energy deposition
                    #. Nuclear attenuation, local charged-secondary energy deposition, and approx exponential distribution of neutron dose

   :param integer imax: number of shielding depth (up to 71) - it is recommended to set this number close to maximum allowed value to compute accurate doses in semi-infinite aluminium medium and at center of aluminium spheres

   :param integer iunt: key to set the shielding depth unit:

                    #. Mils
                    #. g/cm2
                    #. mm

   :param array of `imax` double Zin: thickness in unit as specified by `iunt`. 
   :param double EminS: min energy of solar protons spectrum (MeV)
   :param double EmaxS: max energy of solar protons spectrum (MeV)
   :param double EminP: min energy of trapped protons spectrum (MeV)
   :param double EmaxP: max energy of trapped protons spectrum (MeV)
   :param integer NPTSP: number of spectrum points which divides proton spectra for integration - a value of 1001 is recommended
   :param double EminE: min energy of trapped electrons spectrum (MeV)
   :param double EmaxE: max energy of trapped electrons spectrum (MeV)
   :param integer NPTSE: number of spectrum points which divides electron spectra for integration - a value of 1001 is recommended
   :param integer JSMAX: number of points in falling spectrum of solar protons, max allowed=301
   :param integer JPMAX: number of points in falling spectrum of trapped protons, max allowed=301
   :param integer JEMAX: number of points in falling spectrum of trapped electrons, max allowed=301
   :param double eunit: conversion factor from /energy to /MeV; e.g. eunit = 1000 if flux is /keV
   :param double duratn: mission duration in multiples of unit time (s)
   :param array of 301 double ESin: energy of solar proton spectrum (MeV)
   :param array of 301 double SFLUXin: solar flare flux for solar protons (/energy/cm\ :sup:`2`)
   :param array of 301 double EPin: energy of trapped proton spectrum (MeV)
   :param array of 301 double PFLUXin: incident omnidirectional flux for trapped protons (/energy/cm\ :sup:`2`/s)
   :param array of 301 double EEin: energy of trapped electron spectrum (MeV)
   :param array of 301 double EFLUXin: incident omnidirectional flux for trapped electrons (/energy/cm\ :sup:`2`/s)
   :output array of [71, 3] double SolDose: dose profile for solar protons (rads)
   
         #. Dose in semi-infinite aluminium medium
         #. Dose at transmission surface of finite aluminium slab shields
         #. 1/2 Dose at center of aluminium spheres

   :output array of [71, 3] double ProtDose: dose profile for trapped protons (rads)
   :output array of [71, 3] double ElecDose: dose profile for trapped electrons (rads)
   :output array of [71, 3] double BremDose: dose profile for Bremsstrahlung (rads)
   :output array of [71, 3] double TotDose: total dose profile (rads)
   :callseq MATLAB: [ProtDose,ElecDose,BremDose,SolDose,TotDose] = onera_desp_lib_shieldose2(ProtSpect,ElecSpect,SolSpect,Target,...)
   :callseq IDL: result = call_external(lib_name, 'shieldose2idl_', IDET,INUC,IMAX,IUNT,Zin,EMINS,EMAXS,EMINP,EMAXP,NPTSP,EMINE,EMAXE,NPTSE,JSMAX,JPMAX,JEMAX,EUNIT,DURATN,ESin,SFLUXin,EPin,PFLUXin,EEin,EFLUXin,SolDose,ProtDose,ElecDose,BremDose,TotDose,/f_value)
   :callseq FORTRAN: CALL shieldose2(IDET,INUC,IMAX,IUNT,Zin,EMINS,EMAXS,EMINP,EMAXP,NPTSP,EMINE,EMAXE,NPTSE,JSMAX,JPMAX,JEMAX,EUNIT,DURATN,ESin,SFLUXin,EPin,PFLUXin,EEin,EFLUXin,SolDose,ProtDose,ElecDose,BremDose,TotDose)

