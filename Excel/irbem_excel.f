c --------------------------------------------------------------------
c
c   GET_GST : interface routine for, get Greenwich sidereal angle.
c
c
c --------------------------------------------------------------------
      REAL*8 FUNCTION get_gst( iyear, iday, ut)
      INTEGER*4 iyear, iday
      REAL*8    ut

      real*8 gst, slong, srasn, sdec

      CALL SUN( iyear, iday, ut, gst, slong, srans, sdec)

      get_gst = gst
      RETURN
      END

c --------------------------------------------------------------------
c
c   GET_LSTAR : interface routine for Excel
c
c
c --------------------------------------------------------------------
      REAL*8 FUNCTION get_lstar( year, doy, ut, x1, x2, x3, csys,
     &                           kint, kext, what)
      
      INTEGER*4 year, doy, kint, kext, csys, what
      REAL*8    ut, x1, x2, x3

      INTEGER*4  nMAX
      PARAMETER ( nMAX=1)

      INTEGER*4 ntime /1/, options(5)/0,0,2,0,0/ ,
     &          i_yr(nMAX), i_doy(nMAX)
      REAL*8    x_ut(nMAX), x_x1(nMAX), x_x2(nMAX), x_x3(nMax),
     &          maginput(25, nMAX)
      REAL*8    lm(nMAX), lstar(nMAX), 
     &          b(nMAX),  b0(nMAX), xj(nMAX), mlt(nMAX)

      x_x1(1) = x1
      x_x2(1) = x2
      x_x3(1) = x3
      i_yr(1) = year
      i_doy(1) = doy
      x_ut(1) = ut

      options(1) = 0
      if (what .eq. 2) options(1) = 1
      options(5) = kint

      CALL make_Lstar1( ntime, kext, options, csys, i_yr, i_doy, x_ut,
     &                   x_x1, x_x2, x_x3, maginput, 
     &                   lm, lstar, b,b0,xj,mlt)

      get_lstar = -1.0
      if ( what .eq. 1) get_lstar = lm(1)
      if ( what .eq. 2) get_lstar = lstar(1)
      if ( what .eq. 3) get_lstar = b(1)
      if ( what .eq. 4) get_lstar = b0(1)
      if ( what .eq. 5) get_lstar = xj(1)
      if ( what .eq. 6) get_lstar = mlt(1)

      RETURN
      END FUNCTION

c --------------------------------------------------------------------
c
c   GET_NASA_A8 : interface routine for Excel
c
c   Uses geographic coordinates
c --------------------------------------------------------------------
      REAL*8 FUNCTION get_nasa_a8( in_sysaxes, 
     &                         in_whichm, in_whatf, 
     &                         in_energy, 
     &                         in_iyear, in_idoy, in_ut, 
     &                         in_x1, in_x2, in_x3)

      PARAMETER (maxpts=100000)
      INTEGER*4 in_sysaxes, in_whichm, in_whatf, in_iyear, in_idoy
      REAL*8    in_energy, in_UT, in_X1, in_X2, in_X3

      INTEGER*4 ntime, nene, sysaxes, whichm, whatf
      REAL*8    energy(2,25), x1(maxpts), x2(maxpts), x3(maxpts)
      INTEGER*4 iyear(maxpts), idoy(maxpts)
      REAL*8    UT(maxpts)
      REAL*8    flux(maxpts, 25)
      ntime = 1
      nene  = 1
    
      sysaxes = in_sysaxes
      whichm  = in_whichm
      whatf   = in_whatf

      get_nasa_a8 = -100
      if (sysaxes .LT. 0 .OR. sysaxes .GT. 8) goto 100
      get_nasa_a8 = -200
      if (ABS(whichm)  .LT. 1 .OR. ABS(whichm) .GT.4) goto 100
      get_nasa_a8 = -300
      if (.not.(whatf.EQ.1 .OR. whatf .EQ. 3)) goto 100

      energy( 1,1 ) = in_energy
      iyear(1) = in_iyear
      idoy(1)  = in_idoy
      ut(1)    = in_UT
      x1(1)    = in_x1
      x2(1)    = in_x2
      x3(1)    = in_x3

      CALL fly_in_nasa_aeap1(
     &     ntime,sysaxes,whichm,whatf,
     &     Nene,energy,
     &     iyear,idoy, UT,
     &     x1,x2,x3,
     &     flux)

      get_nasa_a8 = flux(1,1)
 100  continue
      return
      end

c --------------------------------------------------------------------
c
c   GET_NASA_A8 : interface routine for Excel
c
c   Uses geographic coordinates
c --------------------------------------------------------------------
      REAL*8 FUNCTION get_nasa_a8_BB0_L(
     &                         in_whichm, in_whatf, 
     &                         in_energy, 
     &                         in_BB0, in_L)

      PARAMETER (maxpts=100000)
      INTEGER*4 in_whichm, in_whatf
      REAL*8    in_energy, in_BB0, in_L

      INTEGER*4 ntime, nene, sysaxes, whichm, whatf
      REAL*8    energy(2,25), BB0(maxpts), L(maxpts)
      REAL*8    flux(maxpts, 25)

      ntime = 1
      nene  = 1
    
      whichm  = in_whichm
      whatf   = in_whatf

      get_nasa_a8_BB0_L = -200
      if (ABS(whichm)  .LT. 1 .OR. ABS(whichm) .GT.4) goto 100
      get_nasa_a8_BB0_L = -300
      if (.not.(whatf.EQ.1 .OR. whatf .EQ. 3)) goto 100

      energy( 1,1 ) = in_energy
      BB0(1)    = in_BB0
      L(1)      = in_L

      CALL get_AE8_AP8_Flux(
     &     ntime, whichm,whatf,
     &     Nene,energy,
     &     BB0,L,
     &     flux)

      get_nasa_a8_BB0_L = flux(1,1)
 100  continue
      return
      end


c --------------------------------------------------------------------
c
c   GET_AFRL_CRRES : interface routine for Excel
c
c
c --------------------------------------------------------------------
      REAL*8 FUNCTION get_afrl_crres( in_sysaxes, 
     &                         in_whichm, in_whatf, 
     &                         in_energy, 
     &                         in_iyear, in_idoy, in_ut, 
     &                         in_x1, in_x2, in_x3,
     &                         in_ap15 )

      PARAMETER (maxpts=100000)
      INTEGER*4 in_sysaxes, in_whichm, in_whatf, in_iyear, in_idoy
      REAL*8    in_energy, in_UT, in_X1, in_X2, in_X3, in_ap15

      INTEGER*4 ntime, nene, sysaxes, whichm, whatf
      REAL*8    energy(2,25), x1(maxpts), x2(maxpts), x3(maxpts)
      INTEGER*4 iyear(maxpts), idoy(maxpts)
      REAL*8    UT(maxpts)
      REAL*8    flux(maxpts, 25)
      REAL*8    ap15(maxpts)
      CHARACTER*500 cpath
      BYTE      bpath(500)
      INTEGER*4 path_len, i
C     ------------------------------------------------------------

C     ---------- Get location of the CRRES files --------
      CALL GetEnv('ONERA_DESP_DATA', cpath)

      cpath = 'C:\Documents and Settings\Hugh Evans\' //
     &        'Desktop\meo-geo\data\'

      path_len = 0
C     copy the character path to the byte path array.
      DO i=500,1,-1
         bpath(i) = ICHAR(cpath(i:i))
C        if we haven't found the end of the string...
         IF (path_len .EQ. 0) then
C           if we just found the end of the string, save the position
            IF ( ICHAR(cpath(i:i)) .NE. 32) path_len = i
         ENDIF
      ENDDO
      get_afrl_crres = -500
      IF ( path_len .eq. 0) GOTO 100 
C     ---------------------------------------------------
      ntime = 1
      nene  = 1
    
      sysaxes = in_sysaxes
      whichm  = in_whichm
      whatf   = in_whatf

      get_afrl_crres = -100
      if (sysaxes .LT. 0 .OR. sysaxes .GT. 8) goto 100
      get_afrl_crres = -200
      if (whichm  .LT. 1 .OR. whichm .GT.5) goto 100
      get_afrl_crres = -300
      if (.not.(whatf.EQ.1 .OR. whatf .EQ. 3)) goto 100

      energy( 1,1 ) = in_energy
      iyear(1) = in_iyear
      idoy(1)  = in_idoy
      ut(1)    = in_UT
      x1(1)    = in_x1
      x2(1)    = in_x2
      x3(1)    = in_x3

      CALL fly_in_afrl_crres1(
     &     ntime,sysaxes,whichm,whatf,
     &     Nene,energy,
     &     iyear,idoy, UT,
     &     x1,x2,x3, Ap15,
     &     flux, bpath, path_len)

      get_afrl_crres = flux(1,1)
 100  continue
      return
      end


c --------------------------------------------------------------------
c --------------------------------------------------------------------
c
c   GET_AFRL_CRRES_BL : interface routine for Excel
c
c
c --------------------------------------------------------------------
      REAL*8 FUNCTION get_afrl_crres_BL( 
     &                         in_whichm, in_whatf, 
     &                         in_energy, 
     &                         in_BB0, in_L,
     &                         in_ap15 )

      PARAMETER (maxpts=100000)
      INTEGER*4 in_whichm, in_whatf
      REAL*8    in_energy, in_BB0, in_L, in_ap15

      INTEGER*4 ntime, nene, sysaxes, whichm, whatf
      REAL*8    energy(2,25), BB0(maxpts), L(maxpts)

      REAL*8    flux(maxpts, 25)
      REAL*8    ap15(maxpts)
      CHARACTER*500 cpath
      BYTE      bpath(500)
      INTEGER*4 path_len, i
      CHARACTER*20 crres_files(10)
      
C     ------------------------------------------------------------

C     ---------- Get location of the CRRES files --------
      CALL GetEnv('ONERA_DESP_DATA', cpath)

      cpath = 'C:\Documents and Settings\Hugh Evans\' //
     &        'Desktop\meo-geo\data\'

      path_len = 0
C     copy the character path to the byte path array.
      DO i=500,1,-1
         bpath(i) = ICHAR(cpath(i:i))
C        if we haven't found the end of the string...
         IF (path_len .EQ. 0) then
C           if we just found the end of the string, save the position
            IF ( ICHAR(cpath(i:i)) .NE. 32) path_len = i
         ENDIF
      ENDDO
      get_afrl_crres_BL = -500
      IF ( path_len .eq. 0) GOTO 100 
C     ---------------------------------------------------
      ntime = 1
      nene  = 1
    
      sysaxes = in_sysaxes
      whichm  = in_whichm
      whatf   = in_whatf
      BB0(1)  = in_BB0
      L(1)    = in_L
      energy( 1,1 ) = in_energy

      get_afrl_crres_BL = -100
      if (sysaxes .LT. 0 .OR. sysaxes .GT. 8) goto 100
      get_afrl_crres_BL = -200
      if (whichm  .LT. 1 .OR. whichm .GT.5) goto 100
      get_afrl_crres_BL = -300
      if (.not.(whatf.EQ.1 .OR. whatf .EQ. 3)) goto 100

      energy( 1,1 ) = in_energy

      CALL get_crres_flux(
     &     ntime,whichm,whatf,
     &     Nene,energy,
     &     bb0, L, Ap15,
     &     flux, bpath, path_len)

      get_afrl_crres = flux(1,1)
 100  continue
      return
      end


c --------------------------------------------------------------------
c
c
c   GET_ONERA_MEO : interface routine for Excel
c     in_iyear            : year mission starts
c     in_iduration        : duration of mission in years
c     in_whichm           : which model (1: MEO-v1, 2:MEO-v2)
c     in_whatf            : flux spectra (1: diff flux, 3: integ. flux)
c     in_energy           : energy at which to return the fluxes (MeV)
c     in_whatcase         : which sub model (  <0: lower case,
c                                              =0: mean flux
c                                              >0: upper case
c     fluxes are returned in units of:
c              whatf=1     1/(MeV cm2 s sr) 
c              whatf=3     1/(cm2 s sr)
c --------------------------------------------------------------------
      REAL*8 FUNCTION get_onera_meo_gnss( 
     &                         in_iyear, in_iduration,
     &                         in_whichm, in_whatf, 
     &                         in_energy, in_whatc )
      IMPLICIT NONE
      INTEGER*4 in_iyear, in_iduration, in_whichm, in_whatf, in_whatc
      REAL*8    in_energy

      INTEGER*4 Nene, iyear, idur, wm, wf
      REAL*8    energy(2,50)
      REAL*8    flo( 50), fav( 50), fup(50)
c     ----------------------------------------------------------------

      get_onera_meo_gnss = -200
      if (in_whichm  .LT. 1 .OR. in_whichm .GT.2) goto 100
      get_onera_meo_gnss = -300
      if (.not.(in_whatf.EQ.1 .OR. in_whatf .EQ. 3)) goto 100

      Nene = 1
      energy(1,1) = in_energy
      iyear = in_iyear
      idur = in_iduration
      wm   = in_whichm
      wf   = in_whatf

      call fly_in_meo_gnss1( iyear, idur, wm, wf, nene, energy, 
     &                       flo, fav, fup)

      if (in_whatc .lt. 0)  get_onera_meo_gnss = flo(1)
      if (in_whatc .eq. 0)  get_onera_meo_gnss = fav(1)
      if (in_whatc .gt. 0)  get_onera_meo_gnss = fup(1)

 100  continue
      return
      end
c --------------------------------------------------------------------
c
c
c   GET_ONERA_IGE : interface routine for Excel
c     in_iyear            : year mission starts
c     in_iduration        : duration of mission in years
c     in_whichm           : which model (1: MEO-v1, 2:MEO-v2)
c     in_whatf            : flux spectra (1: diff flux, 3: integ. flux)
c     in_energy           : energy at which to return the fluxes (MeV)
c     in_whatcase         : which sub model (  <0: lower case,
c                                              =0: mean flux
c                                              >0: upper case
c     fluxes are returned in units of:
c              whatf=1     1/(MeV cm2 s sr) 
c              whatf=3     1/(cm2 s sr)
c --------------------------------------------------------------------
      REAL*8 FUNCTION get_onera_ige( 
     &                         in_iyear, in_iduration,
     &                         in_whichm, in_whatf, 
     &                         in_energy, in_whatc )
      IMPLICIT NONE
      INTEGER*4 in_iyear, in_iduration, in_whichm, in_whatf, in_whatc
      REAL*8    in_energy

      INTEGER*4 Nene, iyear, idur, wm, wf
      REAL*8    energy(2,50)
      REAL*8    flo( 50), fav( 50), fup(50)
c     ----------------------------------------------------------------

      get_onera_ige = -200
      if (in_whichm  .LT. 1 .OR. in_whichm .GT.3) goto 100
      get_onera_ige = -300
      if (.not.(in_whatf.EQ.1 .OR. in_whatf .EQ. 3)) goto 100

      Nene = 1
      energy(1,1) = in_energy
      iyear = in_iyear
      idur = in_iduration
      wm   = in_whichm
      wf   = in_whatf

      call fly_in_ige1( iyear, idur, wm, wf, nene, energy, 
     &                       flo, fav, fup)

      if (in_whatc .lt. 0)  get_onera_ige = flo(1)
      if (in_whatc .eq. 0)  get_onera_ige = fav(1)
      if (in_whatc .gt. 0)  get_onera_ige = fup(1)

 100  continue
      return
      end
