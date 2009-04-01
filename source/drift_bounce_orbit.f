!***************************************************************************************************
! Copyright 2009 T.P. O'Brien
!
! This file is part of IRBEM-LIB.
!
!    IRBEM-LIB is free software: you can redistribute it and/or modify
!    it under the terms of the GNU Lesser General Public License as published by
!    the Free Software Foundation, either version 3 of the License, or
!    (at your option) any later version.
!
!    IRBEM-LIB is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU Lesser General Public License for more details.
!
!    You should have received a copy of the GNU Lesser General Public License
!    along with IRBEM-LIB.  If not, see <http://www.gnu.org/licenses/>.
!
      
C-----------------------------------------------------------------------------
C     Wrappers and procedures for ONERA_DESP_LIB
C-----------------------------------------------------------------------------
      REAL*4 FUNCTION drift_bounce_orbit(argc, argv) ! Called by IDL
      INCLUDE 'wrappers.inc'
c     INTEGER*4 argc, argv(*)                      ! Argc and Argv are integers
      
c     Call subroutine drift_bounce_orbit1, 
c     converting the IDL parameters to standard FORTRAN
c     passed by reference arguments.
c     
      call drift_bounce_orbit1(%VAL(argv(1)), %VAL(argv(2)),
     +     %VAL(argv(3)),
     *     %VAL(argv(4)),  %VAL(argv(5)),  %VAL(argv(6)),  
     +     %VAL(argv(7)),  %VAL(argv(8)),  %VAL(argv(9)),  
     +     %VAL(argv(10)), %VAL(argv(11)), %VAL(argv(12)), 
     +     %VAL(argv(13)), %VAL(argv(14)), %VAL(argv(15)),
     +     %VAL(argv(16)), %VAL(argv(17)), %VAL(argv(18)),
     +     %VAL(argv(19)))
      
      drift_bounce_orbit = 9.9  ! return value (copied from make_lstar_splitting
      
      RETURN
      END
c     
c     --------------------------------------------------------------------
c     
      
      SUBROUTINE drift_bounce_orbit1(kext,options,sysaxes,
     &     iyearsat,idoy,UT,xIN1,xIN2,xIN3,alpha,maginput,
     &     Lm,Lstar,BLOCAL,BMIN,BMIR,XJ,posit,ind)
      
c     computes posit(3,1000,25), BLOCAL(1000,25) and ind(25) in same
c     format as drift_shell1 (note 25 not 48 azimuths)
c     also provides Bmin, Bmirror and usual stuff
      
      
      IMPLICIT NONE
      INCLUDE 'variables.inc'
C     
c     declare inputs
      INTEGER*4    kext,k_ext,k_l,options(5)
      INTEGER*4    sysaxes
      INTEGER*4    iyearsat
      integer*4    idoy
      real*8     UT
      real*8     xIN1,xIN2,xIN3
      real*8     alpha
      real*8     maginput(25)
c     1: Kp
c     2: Dst
c     3: dens
c     4: velo
c     5: Pdyn
c     6: ByIMF
c     7: BzIMF
c     8: G1
c     9: G2
c     10: G3
c     
c     
c     Declare internal variables
      INTEGER*4    iyear,kint,i,j,k
      INTEGER*4    Ndays,activ,Ilflag,t_resol,r_resol
      INTEGER*4    firstJanuary,lastDecember,Julday,currentdoy
      INTEGER*4    a2000_iyear,a2000_imonth,a2000_iday
      REAL*8     yearsat,dec_year,a2000_ut
      REAL*8     psi,tilt,BL,BMIN_tmp
      REAL*8     xGEO(3),xMAG(3)
      REAL*8     xGSM(3),xSM(3),xGEI(3),xGSE(3)
      real*8     alti,lati,longi
      REAL*8     ERA,AQUAD,BQUAD
      real*8     density,speed,dst_nt,Pdyn_nPa,ByIMF_nt,BzIMF_nt
      real*8     G1_tsy01,G2_tsy01,fkp,G3_tsy01,W1_tsy04,W2_tsy04
      real*8     W3_tsy04,W4_tsy04,W5_tsy04,W6_tsy04,Al
c     
c     Declare output variables
      INTEGER*4  ind(25)
      REAL*8     posit(3,1000,25)
      REAL*8     BLOCAL(1000,25)
      REAL*8     BMIN,BMIR
      REAL*8     XJ
      REAL*8     Lm,Lstar
C     
      COMMON/GENER/ERA,AQUAD,BQUAD
      COMMON /dip_ang/tilt
      COMMON /magmod/k_ext,k_l,kint
      COMMON /drivers/density,speed,dst_nt,Pdyn_nPa,ByIMF_nt,BzIMF_nt
     &     ,G1_tsy01,G2_tsy01,fkp,G3_tsy01,W1_tsy04,W2_tsy04,
     &     W3_tsy04,W4_tsy04,W5_tsy04,W6_tsy04,Al
      COMMON /index/activ
      COMMON /flag_L/Ilflag
      COMMON /a2000_time/a2000_ut,a2000_iyear,a2000_imonth,a2000_iday
C     

c     initialize outputs
      Lm=baddata
      Lstar=baddata
      XJ=baddata
      BMIN=baddata
      BMIR=baddata
      do i=1,25
         ind(i)=0
         do j=1,1000
            BLOCAL(j,i)=baddata
            do k=1,3
               posit(k,j,i)=baddata
            enddo
         enddo
      enddo

      Ilflag=0
      iyear=1800
      k_ext=kext
      if (options(1).eq.0) options(1)=1
      if (options(3).lt.0 .or. options(3).gt.9) options(3)=0
      t_resol=options(3)+1
      r_resol=options(4)+1
      k_l=options(1)
      kint=options(5)
      IF (kint .lt. 0) THEN
         kint=0
         WRITE(6,*)
         WRITE(6,*)'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
         WRITE(6,*)'Invalid internal field specification'
         WRITE(6,*)'Selecting IGRF'
         WRITE(6,*)'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
         WRITE(6,*)
      ENDIF
      if (kint .gt. 3) THEN
         kint=0
         WRITE(6,*)
         WRITE(6,*)'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
         WRITE(6,*)'Invalid internal field specification'
         WRITE(6,*)'Selecting IGRF'
         WRITE(6,*)'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
         WRITE(6,*)
      ENDIF
      IF (kext .lt. 0) THEN
         k_ext=5
         WRITE(6,*)
         WRITE(6,*)'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
         WRITE(6,*)'Invalid external field specification'
         WRITE(6,*)'Selecting Olson-Pfitzer (quiet)'
         WRITE(6,*)'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
         WRITE(6,*)
      ENDIF
      if (kext .gt. 12) THEN
         k_ext=5
         WRITE(6,*)
         WRITE(6,*)'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
         WRITE(6,*)'Invalid external field specification'
         WRITE(6,*)'Selecting Olson-Pfitzer (quiet)'
         WRITE(6,*)'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
         WRITE(6,*)
      ENDIF
c     
      CALL INITIZE
      if (kint .eq. 2) CALL JensenANDCain1960
      if (kint .eq. 3) CALL GSFC1266
      if (kint .le. 1) then
         if (options(2) .eq. 0) then
            if (iyearsat .ne. iyear) then
               iyear=iyearsat
               dec_year=iyear+0.5d0
               CALL INIT_DTD(dec_year)
            endif
         else
            if (iyearsat .ne. iyear .or.
     &           MOD(idoy*1.d0,options(2)*1.d0) .eq. 0) THEN
               iyear=iyearsat
               firstJanuary=JULDAY(iyear,01,01)
               lastDecember=JULDAY(iyear,12,31)
               currentdoy=(idoy/options(2))*options(2)
               if (currentdoy .eq. 0) currentdoy=1
               dec_year=iyear+currentdoy*1.d0/
     &              ((lastDecember-firstJanuary+1)*1.d0)
               CALL INIT_DTD(dec_year)
            endif
         endif
      endif
c     
      CALL INIT_GSM(iyearsat,idoy,UT,psi)
      tilt = psi/(4.D0*ATAN(1.D0)/180.d0)
      if (sysaxes .EQ. 0) then
         alti=xIN1
         lati=xIN2
         longi=xIN3
      endif
      if (sysaxes .EQ. 1) then
         xGEO(1)=xIN1
         xGEO(2)=xIN2
         xGEO(3)=xIN3
         CALL GEO_GDZ(xGEO(1),xGEO(2),xGEO(3),lati,longi,alti)
      endif
      if (sysaxes .EQ. 2) then
         xGSM(1)=xIN1
         xGSM(2)=xIN2
         xGSM(3)=xIN3
         CALL GSM_GEO(xGSM,xGEO)
         CALL GEO_GDZ(xGEO(1),xGEO(2),xGEO(3),lati,longi,alti)
      endif
      if (sysaxes .EQ. 3) then
         xGSE(1)=xIN1
         xGSE(2)=xIN2
         xGSE(3)=xIN3
         CALL GSE_GEO(xGSE,xGEO)
         CALL GEO_GDZ(xGEO(1),xGEO(2),xGEO(3),lati,longi,alti)
      endif
      if (sysaxes .EQ. 4) then
         xSM(1)=xIN1
         xSM(2)=xIN2
         xSM(3)=xIN3
         CALL SM_GEO(xSM,xGEO)
         CALL GEO_GDZ(xGEO(1),xGEO(2),xGEO(3),lati,longi,alti)
      endif
      if (sysaxes .EQ. 5) then
         xGEI(1)=xIN1
         xGEI(2)=xIN2
         xGEI(3)=xIN3
         CALL GEI_GEO(xGEI,xGEO)
         CALL GEO_GDZ(xGEO(1),xGEO(2),xGEO(3),lati,longi,alti)
      endif
      if (sysaxes .EQ. 6) then
         xMAG(1)=xIN1
         xMAG(2)=xIN2
         xMAG(3)=xIN3
         CALL MAG_GEO(xMAG,xGEO)
         CALL GEO_GDZ(xGEO(1),xGEO(2),xGEO(3),lati,longi,alti)
      endif
      if (sysaxes .EQ. 7) then
         xMAG(1)=xIN1
         xMAG(2)=xIN2
         xMAG(3)=xIN3
         CALL SPH_CAR(xMAG(1),xMAG(2),xMAG(3),xGEO)
         CALL GEO_GDZ(xGEO(1),xGEO(2),xGEO(3),lati,longi,alti)
      endif
      if (sysaxes .EQ. 8) then
         xMAG(1)=xIN1
         lati=xIN2
         longi=xIN3
         CALL RLL_GDZ(xMAG(1),lati,longi,alti)
      endif
c     
c     make inputs according to magn. field model chosen
c     
      if (kext .eq. 1) then
c     Input for MEAD
         if (maginput(1).le.3.d0) Activ=1
         if (maginput(1).gt.3.d0 .and.
     &        maginput(1).lt.20.d0) Activ=2
         if (maginput(1).ge.20.d0 .and.
     &        maginput(1).lt.30.d0) Activ=3
         if (maginput(1).ge.30.d0) Activ=4
c     
         if (maginput(1).lt.0.d0 .or.
     &        maginput(1).gt.90.d0) then
            GOTO 99
         endif
      endif
      if (kext .eq. 2) then
c     Input for TSYG87s
         if (maginput(1).lt.7.d0) Activ=1
         if (maginput(1).ge.7.d0 .and.
     &        maginput(1).lt.17.d0) Activ=2
         if (maginput(1).ge.17.d0 .and.
     &        maginput(1).lt.20.d0) Activ=3
         if (maginput(1).ge.20.d0 .and.
     &        maginput(1).lt.27.d0) Activ=4
         if (maginput(1).ge.27.d0 .and.
     &        maginput(1).lt.37.d0) Activ=5
         if (maginput(1).ge.37.d0 .and.
     &        maginput(1).lt.47.d0) Activ=6
         if (maginput(1).ge.47.d0) Activ=7
         if (maginput(1).ge.53.d0) Activ=8
c     
         if (maginput(1).lt.0.d0 .or.
     &        maginput(1).gt.90.d0) then
            GOTO 99
         endif
      endif
      if (kext .eq. 3) then
c     Input for TSYG87l
         if (maginput(1).lt.7.d0) Activ=1
         if (maginput(1).ge.7.d0 .and.
     &        maginput(1).lt.17.d0) Activ=2
         if (maginput(1).ge.17.d0 .and.
     &        maginput(1).lt.27.d0) Activ=3
         if (maginput(1).ge.27.d0 .and.
     &        maginput(1).lt.37.d0) Activ=4
         if (maginput(1).ge.37.d0 .and.
     &        maginput(1).lt.47.d0) Activ=5
         if (maginput(1).ge.47.d0) Activ=6
c     
         if (maginput(1).lt.0.d0 .or.
     &        maginput(1).gt.90.d0) then
            GOTO 99
         endif
      endif
      if (kext .eq. 4) then
c     Input for Tsy89
         if (maginput(1).lt.7.d0) Activ=1
         if (maginput(1).ge.7.d0 .and.
     &        maginput(1).lt.17.d0) Activ=2
         if (maginput(1).ge.17.d0 .and.
     &        maginput(1).lt.27.d0) Activ=3
         if (maginput(1).ge.27.d0 .and.
     &        maginput(1).lt.37.d0) Activ=4
         if (maginput(1).ge.37.d0 .and.
     &        maginput(1).lt.47.d0) Activ=5
         if (maginput(1).ge.47.d0 .and.
     &        maginput(1).lt.57.d0) Activ=6
         if (maginput(1).ge.57.d0) Activ=7
c     
         if (maginput(1).lt.0.d0 .or.
     &        maginput(1).gt.90.d0) then
            GOTO 99
         endif
      endif
      if (kext .eq. 6) then
c     Input for OP dyn
         density=maginput(3)
         speed=maginput(4)
         dst_nt=maginput(2)
c     
         if (dst_nt.lt.-100.d0 .or. dst_nt.gt.20.d0) then
            GOTO 99
         endif
         if (density.lt.5.d0 .or. density.gt.50.d0) then
            GOTO 99
         endif
         if (speed.lt.300.d0 .or. speed.gt.500.d0) then
            GOTO 99
         endif
      endif
      if (kext .eq. 7) then
c     Input for Tsy96
         dst_nt=maginput(2)
         Pdyn_nPa=maginput(5)
         ByIMF_nt=maginput(6)
         BzIMF_nt=maginput(7)
c     
         if (dst_nt.lt.-100.d0 .or. dst_nt.gt.20.d0) then
            GOTO 99
         endif
         if (Pdyn_nPa.lt.0.5d0 .or. Pdyn_nPa.gt.10.d0) then
            GOTO 99
         endif
         if (ByIMF_nt.lt.-10.d0 .or. ByIMF_nt.gt.10.d0) then
            GOTO 99
         endif
         if (BzIMF_nt.lt.-10.d0 .or. BzIMF_nt.gt.10.d0) then
            GOTO 99
         endif
      endif
      if (kext .eq. 8) then
c     Input for Ostapenko97
         dst_nt=maginput(2)
         Pdyn_nPa=maginput(5)
         BzIMF_nt=maginput(7)
         fkp=maginput(1)*1.d0/10.d0
      endif
      if (kext .eq. 9) then
c     Input for Tsy01
         dst_nt=maginput(2)
         Pdyn_nPa=maginput(5)
         ByIMF_nt=maginput(6)
         BzIMF_nt=maginput(7)
         G1_tsy01=maginput(8)
         G2_tsy01=maginput(9)
c     
         if (dst_nt.lt.-50.d0 .or. dst_nt.gt.20.d0) then
            GOTO 99
         endif
         if (Pdyn_nPa.lt.0.5d0 .or. Pdyn_nPa.gt.5.d0) then
            GOTO 99
         endif
         if (ByIMF_nt.lt.-5.d0 .or. ByIMF_nt.gt.5.d0) then
            GOTO 99
         endif
         if (BzIMF_nt.lt.-5.d0 .or. BzIMF_nt.gt.5.d0) then
            GOTO 99
         endif
         if (G1_tsy01.lt.0.d0 .or. G1_tsy01.gt.10.d0) then
            GOTO 99
         endif
         if (G2_tsy01.lt.0.d0 .or. G2_tsy01.gt.10.d0) then
            GOTO 99
         endif
      endif
      if (kext .eq. 10) then
c     Input for Tsy01 storm
         dst_nt=maginput(2)
         Pdyn_nPa=maginput(5)
         ByIMF_nt=maginput(6)
         BzIMF_nt=maginput(7)
         G2_tsy01=maginput(9)
         G3_tsy01=maginput(10)
      endif
c     
      if (kext .eq. 11) then
c     Input for Tsy04 storm
         dst_nt=maginput(2)
         Pdyn_nPa=maginput(5)
         ByIMF_nt=maginput(6)
         BzIMF_nt=maginput(7)
         W1_tsy04=maginput(11)
         W2_tsy04=maginput(12)
         W3_tsy04=maginput(13)
         W4_tsy04=maginput(14)
         W5_tsy04=maginput(15)
         W6_tsy04=maginput(16)
      endif
c     
      if (kext .eq. 12) then
c     Input for Alexeev 2000
         a2000_iyear=iyearsat
         firstJanuary=JULDAY(a2000_iyear,01,01)
         currentdoy=firstJanuary+idoy-1
         CALL CALDAT(currentdoy,a2000_iyear,
     &        a2000_imonth,a2000_iday)
         a2000_ut=UT
         density=maginput(3)
         speed=maginput(4)
         dst_nt=maginput(2)
         BzIMF_nt=maginput(7)
         Al=maginput(17)
      endif
c     
      if (alpha.ne.90.0d0) then
         CALL find_bm(
     &        lati,longi,alti,alpha,BL,BMIR,xGEO)
         CALL GEO_GDZ(xGEO(1),xGEO(2),xGEO(3),lati,
     &        longi,alti)
      ELSE
         Bmir=0.0D0
      ENDIF
      IF (Bmir.NE.baddata) THEN
         Ilflag=0
         call trace_drift_bounce_orbit(t_resol,r_resol,
     &        lati,longi,alti,Lm,Lstar,XJ,
     &        BLOCAL,Bmin,Bmir,posit,ind)
         
      ENDIF
 99   continue
      
      end                       ! end subroutine drift_bounce_orbit1


c     --------------------------------------------------------------------
c     
      
      SUBROUTINE trace_drift_bounce_orbit(t_resol,r_resol,
     &     lati,longi,alti,Lm,Lstar,leI0,Bposit,Bmin,Bmir,
     &     posit,Nposit)
C     
      IMPLICIT NONE
      INCLUDE 'variables.inc'
      
C     Parameters
      INTEGER*4  Nreb_def,Nder_def,Ntet_def
      PARAMETER (Nreb_def = 50, Nder_def = 25, Ntet_def = 720)
      
C     Input Variables
      INTEGER*4 t_resol,r_resol
      REAL*8     lati,longi,alti
      
C     Internal Variables
      INTEGER*4  Nder,Nreb,Ntet
      INTEGER*4  k_ext,k_l,kint,n_resol
      INTEGER*4  Nrebmax
      REAL*8     rr,rr2
      REAL*8     xx0(3),xx(3),x1(3),x2(3)
      REAL*8     xmin(3)
      REAL*8     B(3),Bl,B0,B1,B3
      REAL*8     dsreb,smin
      
      INTEGER*4  I,J,K,Iflag,Iflag_I,Ilflag,Ifail
      INTEGER*4  Ibounce_flag
      INTEGER*4  istore         ! azimuth cursor
      REAL*8     Lb
      REAL*8     leI,leI1
      REAL*8     XY,YY
      REAL*8     aa,bb
      
C     
      REAL*8     pi,rad,tt
      REAL*8     tet(10*Nder_def),phi(10*Nder_def)
      REAL*8     tetl,tet1,dtet
      REAL*8     somme
C     
      REAL*8     Bo,xc,yc,zc,ct,st,cp,sp
      
C     Output Variables       
      REAL*8     Lm,Lstar,leI0,Bmin,Bmir
      REAL*8     posit(3,20*Nreb_def,Nder_def)
      REAL*8     Bposit(20*Nreb_def,Nder_def)
      INTEGER*4  Nposit(Nder_def)
C     
      COMMON /dipigrf/Bo,xc,yc,zc,ct,st,cp,sp
      COMMON /calotte/tet
      COMMON /flag_L/Ilflag
      COMMON /magmod/k_ext,k_l,kint
C     
C     


      Nder=Nder_def*r_resol     ! longitude steps
      Nreb=Nreb_def             ! steps along field line
      Ntet=Ntet_def*t_resol     ! latitude steps
      pi = 4.D0*ATAN(1.D0)
      rad = pi/180.D0
      dtet = pi/Ntet            ! theta (latitude) step
C     
      Nrebmax = 20*Nreb         ! maximum steps along field line
C     
C
      CALL GDZ_GEO(lati,longi,alti,xx0(1),xx0(2),xx0(3))
C     
      CALL GEO_SM(xx0,xx)
      rr = SQRT(xx(1)*xx(1)+xx(2)*xx(2)+xx(3)*xx(3))
      tt = ACOS(xx(3)/rr)
      Lb  = rr/SIN(tt)/SIN(tt)  ! dipole L
C     
      CALL CHAMP(xx0,B,B0,Ifail)
      Bmir = B0 ! local field at starting point
      IF (Ifail.LT.0) THEN
         Ilflag = 0
         RETURN
      ENDIF
      Bmin = B0
C     
      dsreb = Lb/Nreb           ! step size dipole L / Nsteps
C     
C     calcul du sens du depart
C     (compute hemisphere)
      CALL sksyst(-dsreb,xx0,x1,Bl,Ifail)
      IF (Ifail.LT.0) THEN
         Ilflag = 0
         RETURN
      ENDIF
      B1 = Bl
      CALL sksyst(dsreb,xx0,x2,Bl,Ifail)
      IF (Ifail.LT.0) THEN
         Ilflag = 0
         RETURN
      ENDIF
      B3 = Bl
C     
C     attention cas equatorial
C     (equatorial special case)
      IF(B1.GT.B0 .AND. B3.GT.B0)THEN
         aa = 0.5D0*(B3+B1-2.D0*B0)
         bb = 0.5D0*(B3-B1)
         smin = -0.5D0*bb/aa
         Bmin = B0 - aa*smin*smin
         leI0 = SQRT(1.D0-Bmin/B0)*2.D0*ABS(smin*dsreb)
         Lm = (Bo/Bmin)**(1.D0/3.D0)
c     write(6,*)'L McIlwain eq ',B0,leI0,Lm
         GOTO 100
      ENDIF
      IF (B3.GT.B1) THEN
         dsreb = -dsreb
      ENDIF
C     
C     calcul de la ligne de champ et de I
C     (compute field line and I)
      Bmin = B0
      B1 = B0
      leI = 0.D0
      DO I = 1,3
         x1(I)  = xx0(I)
      ENDDO
C     
      DO J = 1,Nrebmax
         CALL sksyst(dsreb,x1,x2,Bl,Ifail)
         IF (Ifail.LT.0) THEN
            Ilflag = 0
            RETURN
         ENDIF
         IF (Bl.LT.Bmin) THEN
            xmin(1) = x2(1)
            xmin(2) = x2(2)
            xmin(3) = x2(3)
            Bmin = Bl
         ENDIF
         IF (Bl.GT.B0) GOTO 20  ! traced past southern mirror point
         x1(1) = x2(1)
         x1(2) = x2(2)
         x1(3) = x2(3)
         leI = leI + SQRT(1.D0-Bl/B0)
         B1 = Bl
      ENDDO
 20   CONTINUE

C     
      IF (J.GE.Nrebmax) THEN    !open field line
         Ilflag = 0
         RETURN
      ENDIF

C     
      leI = leI+0.5D0*SQRT(1.D0-B1/B0)*(B0-Bl)/(Bl-B1)
      leI = leI*ABS(dsreb)
      leI0 = leI
C     
C     calcul de L Mc Ilwain (Mc Ilwain-Hilton)
C     (compute L McIlwain (McIlwain-Hilton))
C     
      XY = leI*leI*leI*B0/Bo
      YY = 1.D0 + 1.35047D0*XY**(1.D0/3.D0)
     &     + 0.465376D0*XY**(2.D0/3.D0)
     &     + 0.0475455D0*XY
      Lm = (Bo*YY/B0)**(1.D0/3.D0)
C     
C     calcul de Bmin
c     (compute Bmin)
C     
      CALL sksyst(dsreb,xmin,x1,B3,Ifail)
      IF (Ifail.LT.0) THEN
         Ilflag = 0
         RETURN
      ENDIF
      CALL sksyst(-dsreb,xmin,x1,B1,Ifail)
      IF (Ifail.LT.0) THEN
         Ilflag = 0
         RETURN
      ENDIF
      aa = 0.5D0*(B3+B1-2.D0*Bmin)
      bb = 0.5D0*(B3-B1)
      smin = -0.5D0*bb/aa
      Bmin = Bmin - aa*smin*smin
      IF (x2(1)*x2(1)+x2(2)*x2(2)+x2(3)*x2(3).LT.1.D0) THEN
         Lm = -Lm
      ENDIF
C     
 100  CONTINUE
      if (k_l .eq.0) then
         Ilflag = 0
         RETURN
      endif
      IF (ABS(Lm) .GT. 10.D0) THEN
         Ilflag = 0
         RETURN
      ENDIF
C     
C     calcul du point sur la ligne de champ a la surface de la terre du
C     cote nord
C     (compute the point nothern footpoint at Earth's surface)
C     
      DO I = 1,3
         x1(I)  = xx0(I)
      ENDDO
      dsreb = ABS(dsreb)
      DO J = 1,Nrebmax
         CALL sksyst(dsreb,x1,x2,Bl,Ifail)
         IF (Ifail.LT.0) THEN
            Ilflag = 0
	    RETURN
	 ENDIF
	 rr = sqrt(x2(1)*x2(1)+x2(2)*x2(2)+x2(3)*x2(3))
	 IF (rr.LT.1.D0) GOTO 102
	 x1(1) = x2(1)
	 x1(2) = x2(2)
	 x1(3) = x2(3)
      ENDDO
 102  CONTINUE
      smin = sqrt(x1(1)*x1(1)+x1(2)*x1(2)+x1(3)*x1(3))
      smin = (1.D0-smin)/(rr-smin)
      CALL sksyst(smin*dsreb,x1,x2,Bl,Ifail)
      IF (Ifail.LT.0) THEN
         Ilflag = 0
         RETURN
      ENDIF
      rr = sqrt(x2(1)*x2(1)+x2(2)*x2(2)+x2(3)*x2(3))
      tet(1) = ACOS(x2(3)/rr)
      phi(1) = ATAN2(x2(2),x2(1))
C     
C     et on tourne -> on se decale sur la surface en phi et on cherche teta
C     pour avoir leI0 et B0 constants
C     (find the thetta/phi contour on the surface of the earth that conserves
C     B0= Bmirror and leI0=I)
      call trace_bounce_orbit(x2,B0,1,
     &     Bposit,posit,Nposit,Ibounce_flag)
      if (Ibounce_flag.ne.1) then
         Ilflag = 0
         RETURN
      endif
      istore = 2 ! istore=1 already stored in first bounce orbit trace
      dsreb = -dsreb
      DO I = 2,Nder
         phi(I) = phi(I-1)+2.D0*pi/Nder
         Iflag_I = 0
         IF (Ilflag.EQ.0) THEN
            tetl = tet(I-1)
            IF (I.GT.2) tetl = 2.D0*tet(I-1)-tet(I-2)
            tet1 = tetl
         ELSE
            tetl = tet(I)
            tet1 = tetl
         ENDIF
         leI1 = baddata
C     
 107     CONTINUE
         x1(1) = SIN(tetl)*COS(phi(I))
         x1(2) = SIN(tetl)*SIN(phi(I))
         x1(3) = COS(tetl)
         Iflag = 0
         leI = baddata
C     
         DO J = 1,Nrebmax
            CALL sksyst(dsreb,x1,x2,Bl,Ifail)
            IF (Ifail.LT.0) THEN
               Ilflag = 0
               RETURN
            ENDIF
            rr2 = x2(1)*x2(1)+x2(2)*x2(2)+x2(3)*x2(3)
            IF (Bl.LT.B0) THEN
               IF (Iflag .EQ. 0) THEN
                  CALL CHAMP(x1,B,B1,Ifail)
                  IF (Ifail.LT.0) THEN
                     Ilflag = 0
                     RETURN
                  ENDIF
                  leI = 0.5D0*SQRT(1.D0-Bl/B0)*(1.D0+(Bl-B0)/(Bl-B1))
                  Iflag = 1
               ELSE
                  leI = leI+SQRT(1.D0-Bl/B0)
               ENDIF
            ENDIF
            IF (Bl.GT.B0 .AND. Iflag.EQ.1) GOTO 103
            IF (rr2.LT.1.D0) GOTO 103
            x1(1) = x2(1)
            x1(2) = x2(2)
            x1(3) = x2(3)
         ENDDO
 103     CONTINUE
c     Pourquoi? (why? I don't know!)
         IF (rr2.LT.1.D0) THEN
            leI = baddata
         ENDIF
         IF (J.LT.Nrebmax .AND. rr2.GE.1.D0) THEN
            CALL CHAMP(x1,B,B1,Ifail)
	    IF (Ifail.LT.0) THEN
               Ilflag = 0
	       RETURN
	    ENDIF
            leI = leI+0.5D0*SQRT(1.D0-B1/B0)*(B0-Bl)/(Bl-B1)
            leI = leI*ABS(dsreb)
         ENDIF
C     
         IF (Iflag_I .EQ.0) THEN
            IF (J.GE.Nrebmax) THEN
               tetl = tetl-dtet
            ELSE
               tetl = tetl+dtet
            ENDIF
            leI1 = leI
            tet1 = tetl
            Iflag_I = 1
            GOTO 107
         ENDIF
         IF ((leI-leI0)*(leI1-leI0) .LT. 0.D0) GOTO 108
         leI1 = leI
         tet1 = tetl
         IF (leI.LT.leI0) THEN
            tetl = tetl-dtet
         ElSE
            tetl = tetl+dtet
         ENDIF
         IF (tetl.GT.pi .OR. tetl.LT.0.D0) GOTO 108
         GOTO 107
 108     CONTINUE
         IF (J.GE.Nrebmax .AND. leI.GT.0.D0) THEN
            Ilflag = 0
            RETURN
         ENDIF
         tet(I) = 0.5D0*(tetl+tet1)
C     
         x1(1) = SIN(tet(I))*COS(phi(I))
         x1(2) = SIN(tet(I))*SIN(phi(I))
         x1(3) = COS(tet(I))
         CALL CHAMP(x1,B,Bl,Ifail)
         IF (Ifail.LT.0) THEN
            Ilflag = 0
            RETURN
         ENDIF
         IF (Bl.LT.B0) THEN
            Ilflag = 0
            RETURN
         ENDIF
         
         if (MOD(I-1,r_resol).eq.0) then
            ! Trace bounce orbit on field line from x1
            call trace_bounce_orbit(x1,Bmir,istore,
     &           Bposit,posit,Nposit,Ibounce_flag)
            if (Ibounce_flag.ne.1) then
               Ilflag = 0
               RETURN
            endif
            istore = istore+1
         endif                  ! mode(I,r_resol)
      ENDDO                     ! end of do I = 2,Nder
C     
C     calcul de somme de BdS sur la calotte nord
C     (compute the integral of BdS on the norther polar cap)
      x1(1) = 0.D0
      x1(2) = 0.D0
      x1(3) = 1.D0
      CALL CHAMP(x1,B,Bl,Ifail)
      IF (Ifail.LT.0)THEN
         Ilflag = 0
         RETURN
      ENDIF
      somme = Bl*pi*dtet*dtet/4.D0
      DO I = 1,Nder
         tetl = 0.D0
         DO J = 1,Ntet
            tetl = tetl+dtet
            IF (tetl .GT. tet(I)) GOTO 111
            x1(1) = SIN(tetl)*COS(phi(I))
            x1(2) = SIN(tetl)*SIN(phi(I))
            x1(3) = COS(tetl)
            CALL CHAMP(x1,B,Bl,Ifail)
            IF (Ifail.LT.0)THEN
               Ilflag = 0
               RETURN
            ENDIF
            somme = somme+Bl*SIN(tetl)*dtet*2.D0*pi/Nder
	 ENDDO
 111     CONTINUE
      ENDDO
      if (k_l .eq.1) Lstar = 2.D0*pi*Bo/somme
      if (k_l .eq.2) Lstar = somme ! Phi and not Lstar
      IF (Lm.LT.0.D0) Lstar = -Lstar
      Ilflag = 1
C     
      END
      
      SUBROUTINE trace_bounce_orbit(xstart,Bmirror,istore,
     &     Bposit,posit,Nposit,Iflag)

      IMPLICIT NONE

c     Declare input variables
      REAL*8 xstart(3) ! GEO
      REAL*8 Bmirror  ! particle's mirror field strength
      INTEGER*4 istore ! where to store bounce orbit

c     Declare output variables
      INTEGER*4  Nposit(25),Iflag ! Iflag=1 means success
      REAL*8     posit(3,1000,25)
      REAL*8     Bposit(1000,25)

c     Declare internal variables
      INTEGER*4 i,j,k,Ifail
      REAL*8 lati,longi,alti,Bl,Beq,Bmir
      REAL*8 xeq(3),xmir(3)
      REAL*8 pi,rad,alpha
      REAL*8 dsreb,x1(3),x2(3),B2

      Iflag = 0

      if ((istore.gt.25).or.(istore.lt.1)) then
         return
      endif

      pi = 4.D0*ATAN(1.D0)
      rad = pi/180.D0

c     trace to mag equator
      call geo_gdz(xstart(1),xstart(2),xstart(3),lati,longi,alti)
      call loc_equator(lati,longi,alti,Beq,xeq)

c     trace back to mirror point
      call geo_gdz(xeq(1),xeq(2),xeq(3),lati,longi,alti)
      alpha = asin(sqrt(Beq/Bmirror))/rad
      CALL find_bm(lati,longi,alti,alpha,BL,BMIR,xmir)

c     estimate dsreb
c     assume field-line length is ~20 times dist between xmir and xeq
      dsreb = sqrt((xmir(1)-xeq(1))**2 + (xmir(2)-xeq(2))**2 
     &     + (xmir(3)-xeq(3))**2)/100

      call sksyst(dsreb,xmir,x2,B2,Ifail)
      if (B2.GT.Bmir) then
         dsreb = -dsreb ! going wrong way
      endif

c     trace to opposite mirror point
c     set up trace
      B2 = BMIR
      do k=1,3
         x1(k)=xmir(k)
      enddo
c     do trace
      do j=1,999
         Bposit(j,istore) = B2
         Nposit(istore) = j
         do k = 1,3
            posit(k,j,istore) = x1(k)
         enddo
         call sksyst(dsreb,x1,x2,B2,Ifail)
         if (Ifail.LT.0) then
            Iflag = 0
            return
         endif
         if (B2.ge.BMIR) goto 201
         do k=1,3
            x1(k)=x2(k)
         enddo
      enddo
 201  continue
      if (B2.lt.BMIR) then
         Iflag = 0 ! failed to get past BMIR
         return
      elseif (B2.gt.BMIR) then
c     finish trace to Bm: Bm between x1 and x2
         BL = B2 ! closest stored point so far (x1)
         do i = 1,10 ! this converges logarithmically, so reduces step size by up to 2^10
            dsreb = dsreb/2.0D0 ! restart with half step size
            call sksyst(dsreb,x1,x2,B2,Ifail)
            if (B2.LT.Bmirror) then ! still inside bounce orbit
               do k=1,3
                  x1(k) = x2(k)
               enddo
            endif
         enddo
         if (B2.gt.BL) then ! got closer, so store x1
            j = j+1
            Bposit(j,istore) = B2
            Nposit(istore) = j
            posit(k,j,istore) = x1(k)
         endif
      endif

      Iflag = 1
      END ! end sub trace_bounce_orbit
