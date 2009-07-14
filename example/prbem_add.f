C     This FORTRAN program adds to an NSSDC CDF file the 
C     magnetospheric variables calculated using the IRBEM-LIB.
C     (http://sourceforge.net/projects/irbem)
C
C     The Variables and associated attributes that are added to the file
C     include:
C         B_Calc   - calculated magnetic field strength (nT)
C         B_Eq     - equatorial magnetic field strength (nT)
C         I        - Adiabatic Invariant (km)
C         L        - McIlwain's L-shell (Earth Radii)
C         L_star   - Roederer's L* parameter (Earth Radii)
C         MLT      - magnetic local time (hours)
C         Alpha    - pitch angle (degrees)
C         Alpha_Eq - Equatorial pitch angle (degrees)
C
C     NOTE!!! If these variables exist already in the file, then their
C             contents will be overwritten!!! If they don't exist, then
C             the variables will be added to the file.
C
C     To use:
C     prbem_add [-e Epoch_Variable] [-p Position_Variable]<CDF_FILE>
C
C     if the Epoch_variable in the CDF file is NOT the default "Epoch",
C     then the Epoch variable name can be specified with the "-e" switch
C     Similarly for the position (default value is "Position"). When this
C     happens, the "Position" and "Position_LABL_1" variables are added
C     to the file.
C
C     For example:
C         % prbem_add -e EPOCH -p ORBIT IREM_PACC_20090531.cdf
C
C     July 2009, H. Evans
C
C     =================================================================
      PROGRAM prbem_add
      IMPLICIT NONE
      INCLUDE 'cdf.inc' 
      INCLUDE 'ntime_max.inc'
      INTEGER*4 MAX_NVAR
      PARAMETER (MAX_NVAR=10)

      REAL*4      x,y

C     ------------------------------------------------------------------
C     checks the CDF file for specific variables
C     CDF file paramters/attributes
      character*200 FILNAM
      character*200 epoch_var, pos_var
      character*200 VARNAM( MAX_NVAR)
      INTEGER*4 CDF_ID,MAX_REC, VARNUM(MAX_NVAR), STATUS, iNvars
C     ------------------------------------------------------------------
C     Magnetospheric variables (IRBEM-LIB)
C
C                 values passed to IRBEM-LIB
      INTEGER*4   iyear(NTIME_MAX), idoy(NTIME_MAX)
      REAL*8      dUT(NTIME_MAX), 
     &            x1(NTIME_MAX), x2(NTIME_MAX), x3(NTIME_MAX)
      REAL*8      maginput(25, NTIME_MAX)

      INTEGER*4   kext, options(5), sysaxes, idhf
      DATA        kext /5/, options /1,0,2,0,0/, sysaxes/1/
     &            idhf/0/

C                 values returned from IRBEM-LIB
      REAL*8      dL(NTIME_MAX),dL_star(NTIME_MAX),dB_calc(NTIME_MAX)
      REAL*8      dB_Eq(NTIME_MAX),dI(NTIME_MAX),dMLT(NTIME_MAX)

      CHARACTER*10 c_nmx, c_mxr
      CHARACTER*200 c_errorstr
      INTEGER*4 i, i1, i2, i3,i4

CC
C     ------------------------------------------------------------------

      CALL PARSE_CMD( FILNAM, epoch_var, pos_var, sysaxes)

      VARNAM(1) = epoch_var
      VARNAM(2) = pos_var

C     .................................................................

C     Open the CDF file, and create the variables if they don't already
C     exist
      CALL OPEN_CDFFILE( FILNAM, CDF_ID, MAX_REC, 
     &                   VARNAM, VARNUM, iNVars, STATUS)

C     .................................................................

      IF ( MAX_REC .GT. NTIME_MAX) THEN
           PRINT*,'Too many records in CDF file: ' //
     &            'NRECS Greater than NTIME_MAX. '//
     &            'Either split CDF into smaller files or '//
     &             'rebuild IRBEM-LIB with larger NTIME_MAX'

           WRITE(*,'(5x,a,i5)') '# CDF Records:       ', MAX_REC
           WRITE(*,'(5x,a,i5)') 'IRBEM-LIB NTIME_MAX: ', NTIME_MAX
           STOP
      ENDIF

C     .................................................................

C     Read in the dataset
      CALL READ_CDFFILE( varnum, MAX_REC, iyear, idoy, dut, 
     &                   x1, x2, x3, status)

C     .................................................................

C     If the CDF file doesn't have the COSPAR/PRBEM standard variable
C     for the position, then add it to the file.
      IF ( pos_var .NE. "Position") THEN
         WRITE(*,*) 'Adding Position Variable to file.'
         CALL ADD_Position_VAR( CDF_ID, pos_Var, MAX_REC,
     &              iyear, idoy, dut, x1, x2, x3, sysaxes)
      ENDIF

C     .................................................................

C     Use IRBEM-LIB to calculate the magnetic field coordinates
      CALL MAKE_LSTAR1( MAX_REC, kext, options, sysaxes,
     &                  iyear, idoy, dut, x1, x2, x3, maginput,
     &                  dL, dL_star, dB_calc, dB_eq, dI, dMLT
     &                  )

C     .................................................................

C     write values to the dataset
      DO i=1, MAX_REC
         ! Note, the parameters must match the list in VARNUM/VARNAM!
         CALL WRITE_CDFFILE( VARNUM, 
     &        dB_calc(i), dB_eq(i), dI(i), dL(i), dL_star(i), dMLT(i),
     &        status )
      ENDDO

C     .................................................................

      CALL STR_TRIM(FILNAM,i1,i2)
      PRINT*,'Finished '//FILNAM(i1:i2)//', NRecs=',MAX_REC
C     close the CDF file.
      CALL CDF_CLOSE( CDF_ID, STATUS)

      END

C ======================================================================
C ======================================================================
C ======================================================================
      SUBROUTINE ADD_Position_VAR( CDF_ID, locVarName, npts,
     &                   iyear, idoy, dut, x1, x2, x3, in_sysaxes)
      IMPLICIT NONE
      INCLUDE 'cdf.inc'
      INTEGER*4 CDF_ID, npts
      CHARACTER*(*) locVarName     ! the existing location variable
      INTEGER*4  iyear(NPTS), IDOY(NPTS), in_sysaxes
      REAL*8     dut(NPTS), x1(NPTS), x2(NPTS), x3(NPTS)

      INTEGER*4 SYSAXES_GEO
      PARAMETER (SYSAXES_GEO = 1)
      REAL*8    Earth_radius
      PARAMETER (Earth_radius = 6371.2 ) ! km.

      REAL*8    x(3), xgeo(3)
      INTEGER*4 VarNum, VarLabNum, locVarNum, i1,i2, status, i, j
      CHARACTER*4   ValLabVals(3)
C     ------------------------------------------------------------------

C        Check the case where the Position variable is not listed
C        as "Position", e.g. "ORBIT". Then we want to create the
C        "Position" variable to comply with the COSPAR/PRBEM standard

      CALL STR_TRIM( locVarName, i1,i2)
      IF ( locVarName(i1:i2) .EQ. "Position") THEN
         RETURN
      ENDIF

C     Check if the "Position" variable already exists, if not, then create it
      STATUS = CDF_LIB(GET_, zVAR_NUMBER_, 'Position', VarNum,
     &                 NULL_, STATUS)
      IF ( VarNum .EQ. 0) THEN
           CALL CDF_Create_zvar( CDF_ID, 'Position', CDF_DOUBLE,
     &                  1, 1, 3, VARY, VARY, VarNum,
     &                  STATUS)
      ENDIF

C     Add the position attributes

      CALL CREATE_IRBEM_ATT_C( CDF_ID, 
     &           'AVG_TYPE', VARNUM, 'standard', STATUS)
      CALL CREATE_IRBEM_ATT_C( CDF_ID, 'CATDESC', VARNUM,
     &           'Position of the satellite in GEO coordinates', 
     &           STATUS) 
      CALL CREATE_IRBEM_ATT_C( CDF_ID, 
     &           'DEPEND_0', VARNUM, 'Epoch', STATUS) 
      CALL CREATE_IRBEM_ATT_C( CDF_ID, 
     &           'DICT_KEY', VARNUM, 'position>geographic', STATUS)
      CALL CREATE_IRBEM_ATT_C( CDF_ID, 
     &           'DISPLAY_TYPE', VARNUM, 'time_series', STATUS) 
      CALL CREATE_IRBEM_ATT_C( CDF_ID, 'FIELDNAM', VARNUM,
     &           'Satellite Position (GEO)', STATUS) 
      CALL CREATE_IRBEM_ATT_F( CDF_ID, 
     &           'FILLVAL', VARNUM, -1.0D31, 1, STATUS)
      CALL CREATE_IRBEM_ATT_C( CDF_ID, 
     &           'FORMAT', VARNUM, 'F15.3', STATUS) 
      CALL CREATE_IRBEM_ATT_C( CDF_ID, 
     &           'LABL_PTR_1', VARNUM, 'Position_LABL_1', STATUS) 
      CALL CREATE_IRBEM_ATT_C( CDF_ID, 
     &           'SCALETYP', VARNUM, 'linear', STATUS) 
      CALL CREATE_IRBEM_ATT_C( CDF_ID, 
     &           'SI_conversion', VARNUM, '1.0e-3>m', STATUS) 
      CALL CREATE_IRBEM_ATT_C( CDF_ID, 
     &           'UNITS', VARNUM, 'km', STATUS) 
      CALL CREATE_IRBEM_ATT_F( CDF_ID, 
     &           'VALIDMIN', VARNUM, -1.D+6, 1, STATUS)
      CALL CREATE_IRBEM_ATT_F( CDF_ID, 
     &           'VALIDMAX', VARNUM,  1.D+6, 1, STATUS)
      CALL CREATE_IRBEM_ATT_C( CDF_ID, 'VAR_NOTES', VARNUM,
     &           'Calculated from '// locVarName(i1:i2), STATUS) 
      CALL CREATE_IRBEM_ATT_C( CDF_ID, 
     &           'VAR_TYPE', VARNUM, 'data', STATUS) 

C     Now create the LABL_PTR_1 variable and associated gumph

      CALL CDF_Create_zvar( CDF_ID,'Position_LABL_1', CDF_CHAR,
     &                   4, 1, 3, NOVARY, VARY, VarLabNum, STATUS)
      CALL CREATE_IRBEM_ATT_C( CDF_ID, 'CATDESC', VarLabNum,
     &                         'Position_LABL_1', STATUS) 
      CALL CREATE_IRBEM_ATT_C( CDF_ID, 'DICT_KEY', VarLabNum,
     &                         'label', STATUS)
      CALL CREATE_IRBEM_ATT_C( CDF_ID, 'FIELDNAM', VarLabNum,
     &                         'Position_LABL_1', STATUS) 
      CALL CREATE_IRBEM_ATT_C( CDF_ID, 'FORMAT', VarLabNum,
     &                         'A4', STATUS) 
      CALL CREATE_IRBEM_ATT_C( CDF_ID, 'VAR_TYPE', VarLabNum,
     &                         'metadata', STATUS) 

      ValLabVals(1) ='Xgeo'
      ValLabVals(2) ='Ygeo'
      ValLabVals(3) ='Zgeo'
      CALL CDF_PUT_zvar_data( CDF_ID, VarLabNum,1, 1, ValLabVals(1), 
     &                        STATUS)
      CALL CDF_PUT_zvar_data( CDF_ID, VarLabNum,1, 2, ValLabVals(2), 
     &                        STATUS)
      CALL CDF_PUT_zvar_data( CDF_ID, VarLabNum,1, 3, ValLabVals(3), 
     &                        STATUS)


      DO i=1, NPTS
         x(1) = x1(i)
         x(2) = x2(i)
         x(3) = x3(i)
         CALL COORD_TRANS1( in_sysaxes, SYSAXES_GEO, 
     &                     iyear(i), idoy(i), dut(i),
     &                     x, xGEO)

         DO j=1,3
            CALL CDF_PUT_zvar_data( CDF_ID, VARNUM, i, j, 
     &                              xGEO(j) * Earth_Radius, 
     &                              STATUS)
         ENDDO
      ENDDO

      RETURN
      END

C ======================================================================
C ======================================================================
C ======================================================================
C     Creates the attribute if it doesn't exist and adds a value to the
C     variable.
C     This version is for Character String values.
      SUBROUTINE CREATE_IRBEM_ATT_C( CDF_ID, ATTNAM, VARNUM, 
     &                               VAL, STATUS)
      IMPLICIT NONE
      INCLUDE 'cdf.inc'
      INTEGER*4 CDF_ID, VARNUM, STATUS
      CHARACTER*(*) ATTNAM, VAL
      INTEGER*4 ATTNUM, I1, I2, sLen

      ATTNUM = CDF_get_attr_num( CDF_ID, ATTNAM)

C     if the attribute doesn't exist, then create it.
      IF ( ATTNUM .LT. 0) THEN
          CALL CDF_attr_create( CDF_ID, ATTNAM, VARIABLE_SCOPE,
     &                          ATTNUM, status)
      ENDIF

c      PRINT*,'CREATE_IRBEM_ATT_C: ',ATTNAM,ATTNUM
      CALL STR_TRIM( VAL, I1, I2)
      sLen = I2 - I1 + 1
      CALL CDF_put_attr_zentry( CDF_ID, ATTNUM, VARNUM, 
     &                 CDF_CHAR, sLEN, VAL(I1:I2), STATUS)

      RETURN
      END

C ======================================================================
C ======================================================================
C ======================================================================
C     Creates the attribute if it doesn't exist and adds a value to the
C     variable.
C     This version is for REAL values.
      SUBROUTINE CREATE_IRBEM_ATT_F( CDF_ID, ATTNAM, VARNUM, 
     &                               VAL, NELEM, STATUS)

      IMPLICIT NONE
      INTEGER*4 get_zVar_DataType
      EXTERNAL  get_ZVar_DataType

      INCLUDE 'cdf.inc'
      INTEGER*4 CDF_ID, VARNUM, STATUS, NELEM
      CHARACTER*(*) ATTNAM
      REAL*8    VAL(NELEM)
      REAL*4    VAL4
      INTEGER*4 ATTNUM, VAR_Type

      NELEM = 1
      VAL4 = VAL(1)
      ATTNUM = CDF_get_attr_num( CDF_ID, ATTNAM)

C     get the data type of the variable, the attribute type should be
C     of the same type.
      VAR_Type = get_ZVar_DataType( VARNUM, STATUS)

C     if the attribute doesn't exist, then create it.
      IF ( ATTNUM .LT. 0) THEN
          CALL CDF_attr_create( CDF_ID, ATTNAM, VARIABLE_SCOPE,
     &                          ATTNUM, status)
      ENDIF

C     Add the attribute and value to the variable
      IF ( VAR_TYPE .EQ. CDF_FLOAT) THEN
         CALL CDF_put_attr_zentry( CDF_ID, ATTNUM, VARNUM, 
     &                 CDF_FLOAT, NELEM, VAL4 , STATUS)
      ELSE
         CALL CDF_put_attr_zentry( CDF_ID, ATTNUM, VARNUM, 
     &                 CDF_DOUBLE, NELEM, VAL , STATUS)
      ENDIF

      RETURN
      END

C ======================================================================
C ======================================================================
C ======================================================================
      SUBROUTINE PUT_IRBEM_ATT( CDF_ID, VARNUM,
     &                          CATDESC, FIELDNAM, C_FORMAT,
     &                          LABLAXIS, SI_conv, UNITS, DICT_KEY,
     &                          AVG_TYPE,
     &                          VALIDMIN, VALIDMAX,
     &                          VAR_NOTES)
      IMPLICIT NONE
      INCLUDE 'cdf.inc'

      INTEGER*4 CDF_ID, VARNUM
      CHARACTER*(*) CATDESC, FIELDNAM, C_FORMAT
      CHARACTER*(*) LABLAXIS, SI_conv, UNITS, DICT_KEY, AVG_TYPE
      CHARACTER*(*) VAR_NOTES
      REAL*8        VALIDMIN, VALIDMAX
      INTEGER*4  STATUS, ATTNUM
      INTEGER*4  var_datatype


      CALL CREATE_IRBEM_ATT_C( CDF_ID, 'AVG_TYPE', VARNUM,
     &                         AVG_TYPE, STATUS)
      CALL CREATE_IRBEM_ATT_C( CDF_ID, 'CATDESC', VARNUM,
     &                         CATDESC, STATUS) 
      CALL CREATE_IRBEM_ATT_C( CDF_ID, 'DEPEND_0', VARNUM,
     &                         'Epoch', STATUS) 
      CALL CREATE_IRBEM_ATT_C( CDF_ID, 'DICT_KEY', VARNUM,
     &                         DICT_KEY, STATUS)
      CALL CREATE_IRBEM_ATT_C( CDF_ID, 'DISPLAY_TYPE', VARNUM,
     &                         'time_series', STATUS) 
      CALL CREATE_IRBEM_ATT_C( CDF_ID, 'FIELDNAM', VARNUM,
     &                         FIELDNAM, STATUS) 
      CALL CREATE_IRBEM_ATT_F( CDF_ID, 'FILLVAL', VARNUM,
     &                         -1.0D31, 1, STATUS)
      CALL CREATE_IRBEM_ATT_C( CDF_ID, 'FORMAT', VARNUM,
     &                         C_FORMAT, STATUS) 
      CALL CREATE_IRBEM_ATT_C( CDF_ID, 'LABLAXIS', VARNUM,
     &                         LABLAXIS, STATUS) 
      CALL CREATE_IRBEM_ATT_C( CDF_ID, 'SCALETYP', VARNUM,
     &                         'linear', STATUS) 
      CALL CREATE_IRBEM_ATT_C( CDF_ID, 'SI_conversion', VARNUM,
     &                         Si_conv, STATUS) 
      CALL CREATE_IRBEM_ATT_C( CDF_ID, 'UNITS', VARNUM,
     &                         UNITS, STATUS) 
      CALL CREATE_IRBEM_ATT_F( CDF_ID, 'VALIDMIN', VARNUM,
     &                         VALIDMIN, 1, STATUS)
      CALL CREATE_IRBEM_ATT_F( CDF_ID, 'VALIDMAX', VARNUM,
     &                         VALIDMAX, 1, STATUS)
      CALL CREATE_IRBEM_ATT_C( CDF_ID, 'VAR_NOTES', VARNUM,
     &                         VAR_NOTES, STATUS) 
      CALL CREATE_IRBEM_ATT_C( CDF_ID, 'VAR_TYPE', VARNUM,
     &                         'data', STATUS) 


      RETURN
      END

C ======================================================================
C ======================================================================
C ======================================================================
      SUBROUTINE OPEN_CDFFILE(FILNAM, CDF_ID, MAX_REC, oVARNAM, 
     &                        oVARNUM, oNvars, STATUS)

      IMPLICIT NONE

      INCLUDE 'cdf.inc'

      INTEGER*4 get_zVar_DataType
      EXTERNAL get_ZVar_DataType

      INTEGER*4 NVAR
      PARAMETER (NVAR=10)

      INTEGER*4 CDF_ID, MAX_REC, oVARNUM(NVAR), oNvars, STATUS
      CHARACTER*(*) FILNAM, oVARNAM(NVAR)
      CHARACTER*200 vname, ctmp

      INTEGER*4 i,i1,i2, iposvarnum
C     ------------------------------------------------------------------
C     CDF File variable attributes...
      CHARACTER*200 CATDESC(NVAR), FIELDNAM(NVAR), C_FORMAT(NVAR),
     &              LABLAXIS(NVAR), SI_CONV(NVAR), UNITS(NVAR),
     &              DICT_KEY(NVAR), AVG_TYPE(NVAR)
      REAL*8        VALIDMIN(NVAR), VALIDMAX(NVAR)
      INTEGER*4     DATATYPE(NVAR)
      CHARACTER*500 VAR_NOTES
C     ------------------------------------------------------------------

      CALL SETCDFVALS( NVAR, VAR_NOTES, oVARNAM, CATDESC, FIELDNAM,
     &                 C_FORMAT,
     &                 LABLAXIS, SI_CONV, UNITS, DICT_KEY, AVG_TYPE,
     &                 VALIDMIN, VALIDMAX,
     &                 DATATYPE)
      oNvars = NVAR  ! used to return to the calling routine
                     ! the number of variables...

      STATUS = CDF_LIB(OPEN_, CDF_, FILNAM, CDF_ID,
     &                 NULL_, STATUS)
      IF (STATUS .LT. CDF_OK) RETURN

      STATUS = CDF_LIB(GET_, zVARs_MAXREC_, MAX_REC,
     &                 NULL_, STATUS)
      IF (STATUS .LT. CDF_OK) RETURN

C      PRINT*,'NVAR=',nvar,'; MAX_REC=',MAX_REC
      DO i=1, NVAR
         vname = oVarNam(i)
         CALL STR_TRIM( vname, i1,i2)

C        get the CDF variable number for this variable
         STATUS = CDF_LIB(GET_, zVAR_NUMBER_, vname, oVARNum(i),
     &                 NULL_, STATUS)

C        The First two variables (Epoch, position) are assumed to exist
C        so don't modify them...
         IF (i .GT. 2) THEN
            IF ( oVARNum(i) .EQ. 0) THEN  ! variable not found, so create
               CALL CDF_Create_zvar( CDF_ID, VNAME(i1:i2), DATATYPE(i),
     &                       1, 0, 1, VARY, NOVARY, oVARNUM(i),
     &                       STATUS)
            ENDIF
            STATUS = CDF_LIB(GET_, zVAR_NUMBER_, oVARNAM(i), oVARNum(i),
     &               NULL_, STATUS)

C           Set/Add the various variable attributes/meta data.
            CALL PUT_IRBEM_ATT( CDF_ID, oVARNUM(i), 
     &            CATDESC(i),FIELDNAM(i), 
     &            C_FORMAT(i), LABLAXIS(i),
     &            SI_CONV(i), UNITS(i), DICT_KEY(i), 
     &            AVG_TYPE(i), VALIDMIN(i),
     &            VALIDMAX(i), VAR_NOTES)
         ENDIF

      ENDDO
      RETURN
      END
C     =================================================================
C     =================================================================
C     =================================================================
      SUBROUTINE READ_CDFFILE(VARNUM, MAX_REC, 
     &                        oYEAR, oDOY, oUT, oX1, oX2,oX3, oSTATUS)

      IMPLICIT NONE

      INCLUDE 'cdf.inc'
c      INCLUDE 'CDFDF.INC'
c      INCLUDE 'CDFDVF.INC'
      INTEGER*4  MAX_REC
      INTEGER*4  VARNUM(2)  ! epoch and position variables...
      INTEGER*4  oYear(MAX_REC), oDOY(MAX_REC)
      REAL*8     oUT(MAX_REC), oX1(MAX_REC), oX2(MAX_REC), oX3(MAX_REC)

      REAL*8 EPOCH, UT, GEO(3)
      INTEGER*4 DOY, oSTATUS
      INTEGER*4 YEAR, MONTH, DAY, HOUR, MINUTE, SECOND, MSEC
      INTEGER*4 MD(11) /31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30/
      INTEGER*4 I, irec

      DO irec = 1, MAX_REC
c         WRITE(*,'(i5,$)') irec
         EPOCH = -1.0D31
         GEO(1) = -1.0D31
         GEO(2) = -1.0D31
         GEO(3) = -1.0D31

         oSTATUS = CDF_LIB(SELECT_, zVAR_, VarNum(1),
     &                 GET_, zVAR_SEQDATA_, Epoch,
     &                 SELECT_, zVAR_, VarNum(2),
     &                 SELECT_, zVAR_DIMINDICES_, 1,
     &                 GET_, zVAR_SEQDATA_, GEO(1),
     &                 SELECT_, zVAR_DIMINDICES_, 2,
     &                 GET_, zVAR_SEQDATA_, GEO(2),
     &                 SELECT_, zVAR_DIMINDICES_, 3,
     &                 GET_, zVAR_SEQDATA_, GEO(3),
     &                 NULL_, oSTATUS)

c         WRITE(*,'(d21.2,3F10.2,i,$)') 
c     &         Epoch, GEO(1), GEO(2),GEO(3), ostatus

         IF (oSTATUS .LT. CDF_OK) RETURN

         CALL EPOCH_BREAKDOWN(EPOCH, YEAR, MONTH, DAY, HOUR, MINUTE,
     &                     SECOND, MSEC)
c         WRITE(*,'(i,i)') oYEAR(irec), oDOY(irec)

         DOY = DAY
         DO I=1,MONTH-1
            DOY = DOY + MD(I)
         END DO
         IF ((((YEAR .EQ. 4*(YEAR/4)) .AND.
     &        (YEAR .NE. 100*(YEAR/100))) .OR.
     &        (YEAR .EQ. 400*(YEAR/400))) .AND.
     &        (MONTH .GT. 2)) DOY = DOY + 1

         UT = (HOUR+(MINUTE+(SECOND+MSEC/1000.0D0)/60.0D0)/60.0D0) *
     &        3600.0D0

         oYEAR(irec) = YEAR
         oDOY(irec) = DOY
         oUT(irec) = UT
         oX1(irec) = GEO(1)/6371.2D0
         oX2(irec) = GEO(2)/6371.2D0
         oX3(irec) = GEO(3)/6371.2D0
      ENDDO
      RETURN
      END
C
C     =================================================================
C     =================================================================
C     =================================================================
      SUBROUTINE WRITE_CDFFILE(VARNUM, B, B0, Si, L, Lstar, MLT,
     &                         STATUS)

      IMPLICIT NONE

      INCLUDE 'cdf.inc'
c      INCLUDE 'CDFDF.INC'
c      INCLUDE 'CDFDVF.INC'
C     NOTE: these parameters are assumed to match the variables
C           indicated via VARNUM(3-8), see SETCDFVALS
      REAL*8 B, B0, SI, L, LSTAR, MLT
      REAL*4 oSI, oL, oLSTAR, oMLT, oAlpha
      INTEGER*4 VarNum(10), STATUS

      CALL CALC_ALPHA( B, B0, oalpha)
      oL = L
      oLstar = Lstar
      oMLT   = MLT
      oSI    = SI

      STATUS = CDF_LIB(SELECT_, zVAR_, VarNum(3),  ! B_calc
     &                 PUT_, zVAR_SEQDATA_, B,

     &                 SELECT_, zVAR_, VarNum(4),  ! B_eq
     &                 PUT_, zVAR_SEQDATA_, B0,

     &                 SELECT_, zVAR_, VarNum(5),  ! I
     &                 PUT_, zVAR_SEQDATA_, oSI,

     &                 SELECT_, zVAR_, VarNum(6),  ! L
     &                 PUT_, zVAR_SEQDATA_, oL,

     &                 SELECT_, zVAR_, VarNum(7),  ! L_star
     &                 PUT_, zVAR_SEQDATA_, oLSTAR,

     &                 SELECT_, zVAR_, VarNum(8),  ! MLT
     &                 PUT_, zVAR_SEQDATA_, oMLT,

     &                 SELECT_, zVAR_, VarNum(9),  ! Alpha
     &                 PUT_, zVAR_SEQDATA_, oALPHA,

     &                 SELECT_, zVAR_, VarNum(10), ! Alpha_eq - NULL for now
     &                 PUT_, zVAR_SEQDATA_, -1.0E31,

     &                 NULL_, STATUS)

      RETURN
      END

C ======================================================================
C ======================================================================
C ======================================================================
      INTEGER*4 FUNCTION GET_ZVAR_DATATYPE( zvarnum, Status)
      IMPLICIT NONE
      INCLUDE 'cdf.inc'
      INTEGER*4 ZVarNum, Status

      INTEGER*4 data_type
C     ------------------------------------------------------------------

      STATUS = CDF_LIB(
     &             SELECT_, zVAR_, zVarNum,
     &             GET_, zVAR_DATATYPE_, data_type,
     &             NULL_, STATUS)

      GET_ZVAR_DATATYPE = data_type
      RETURN
      END
C ======================================================================
C ======================================================================
C ======================================================================

      SUBROUTINE SETCDFVALS( NVAR, VAR_NOTES, VARNAM, CATDESC, FIELDNAM,
     &                 C_FORMAT, 
     &                 LABLAXIS, SI_CONV, UNITS, DICT_KEY, AVG_TYPE,
     &                 VALIDMIN, VALIDMAX,
     &                 DATATYPE)
      IMPLICIT NONE
      INCLUDE 'cdf.inc'
      INTEGER*4 MAX_VAR
      LOGICAL  STR_EMPTY
      EXTERNAL STR_EMPTY
      PARAMETER (MAX_VAR=10)
      INTEGER*4 NVAR, i
C     CDF File variable attributes...
      CHARACTER*500 VAR_NOTES
      CHARACTER*200 VARNAM(NVAR), CATDESC(NVAR), FIELDNAM(NVAR),
     &              LABLAXIS(NVAR), SI_CONV(NVAR), UNITS(NVAR),
     &              DICT_KEY(NVAR), AVG_TYPE(NVAR), C_FORMAT(NVAR)
      REAL*8        VALIDMIN(NVAR), VALIDMAX(NVAR)
      INTEGER*4     DATATYPE(NVAR)
      INTEGER*4     IRBEM_REL
      CHARACTER*4   sIRBEM_REL

      INTEGER*4  Pos,B_calc, B_eq, B_I, L, LStar, MLT, alpha, alpha_eq
      PARAMETER  (Pos=2, B_CALC=3, B_Eq=4, B_I=5, L=6, LSTAR=7, MLT=8,
     &            alpha=9, alpha_eq=10)

C     ------------------------------------------------------------------

      CALL IRBEM_FORTRAN_VERSION1( IRBEM_REL)
c      PRINT*,'IRBEM_REL: ', IRBEM_REL
      WRITE( sIRBEM_REL,FMT='(i4)') IRBEM_REL

      VAR_NOTES = 'Calculated using IRBEM-LIB'//
     &            '(v' // sIRBEM_REL // 
     &            ', https://sourceforge.net/projects/irbem) '  //
     &            'Internal field: DGRF/IGRF, '//
     &            'External field: Olson & Pfitzer quiet'


c      VARNAM(1) = 'Epoch'  ! this is set in the parse_cmd routine...
c      VARNAM(2) = 'Position'
      VARNAM(B_CALC) = 'B_Calc'
      VARNAM(B_EQ) = 'B_Eq'
      VARNAM(B_I) = 'I'
      VARNAM(L) = 'L'
      VARNAM(LSTAR) = 'L_star'
      VARNAM(MLT) = 'MLT'
      VARNAM(ALPHA) = 'Alpha'
      VARNAM(ALPHA_EQ) = 'Alpha_Eq'

      CATDESC(POS) = 'Position of the satellite in '//
     &               'geographic coordinates'
      CATDESC(B_CALC) ='Calculated magnetic field strength'
      CATDESC(B_EQ) ='Calculated magnetic field strength '//
     &            'at magnetic equator'
      CATDESC(B_I) ='Adiabatic invariant (bounce)'
      CATDESC(L) ='Calculated McIlwain''s L parameter ' //
     &            '(Earth''s radii)'
      CATDESC(LSTAR) ='Calculated Roederer''s L* parameter ' //
     &            '(Earth''s radii)'
      CATDESC(MLT) ='Calculated Magnetic Local Time (hours)'
      CATDESC(ALPHA) ='Pitch Angle'
      CATDESC(ALPHA_EQ)='Equatorial pitch angle'

      FIELDNAM(POS) = 'Satellite position (GEO)'
      FIELDNAM(B_CALC)='Magnetic field strength'
      FIELDNAM(B_EQ)='Equatorial magnetic field strength'
      FIELDNAM(B_I)='Adiabatic invariant (bounce)'
      FIELDNAM(L)='McIlwain''s L parameter'
      FIELDNAM(LSTAR)='Roederer''s L* parameter'
      FIELDNAM(MLT)='Magnetic Local Time'
      FIELDNAM(ALPHA)='Pitch angle'
      FIELDNAM(ALPHA_EQ)='Equat. Pitch angle'

      C_FORMAT(POS)    = 'F15.3'
      C_FORMAT(B_CALC) = 'E15.8'
      C_FORMAT(B_EQ) = 'E15.8'
      C_FORMAT(B_I) = 'E15.8'
      C_FORMAT(L) = 'E15.8'
      C_FORMAT(LSTAR) = 'E15.8'
      C_FORMAT(MLT) = 'F7.4'
      C_FORMAT(ALPHA) = 'F8.4'
      C_FORMAT(ALPHA_EQ) = 'F8.4'

      LABLAXIS(POS) = ''
      LABLAXIS(B_CALC)='B'
      LABLAXIS(B_EQ)='B_Eq'
      LABLAXIS(B_I)='I'
      LABLAXIS(L)='L'
      LABLAXIS(LSTAR)='L*'
      LABLAXIS(MLT)='MLT'
      LABLAXIS(ALPHA)='Alpha'
      LABLAXIS(ALPHA_EQ)='Alpha(Eq)'

      SI_CONV(B_CALC)='1.0e-9>T'
      SI_CONV(B_EQ)='1.0e-9>T'
      SI_CONV(B_I)='1.0e3>m'
      SI_CONV(L)='6371200.0>m'
      SI_CONV(LSTAR)='6371200.0>m'
      SI_CONV(MLT)='3600.0>s'
      SI_CONV(ALPHA)='1.74533E-2>rad'
      SI_CONV(ALPHA_EQ)='1.74533E-2>rad'

      UNITS(B_CALC)='nT'
      UNITS(B_EQ)='nT'
      UNITS(B_I)='km'
      UNITS(L)='R_E'
      UNITS(LSTAR)='R_E'
      UNITS(MLT)='h'
      UNITS(ALPHA)='degrees'
      UNITS(ALPHA_EQ)='degrees'

      DO i=B_CALC,NVAR
         DICT_KEY(i) = 'magnetic_field>amplitude'
      ENDDO
      DICT_KEY(MLT) = 'time>magnetic'
      DICT_KEY(ALPHA) = 'angle>pitch'
      DICT_KEY(ALPHA_EQ) = 'angle>pitch'

      DO i=B_CALC,LSTAR
         AVG_TYPE(i) = 'standard'
      ENDDO
      AVG_TYPE( MLT) = 'angle_hour'
      DO i=ALPHA, ALPHA_EQ
         AVG_TYPE(i) = 'angle_degrees'
      ENDDO

      DO i=B_CALC,NVAR
         VALIDMIN(i)=0.0
         VALIDMAX(i)=1.0E+31
      ENDDO
      VALIDMIN(MLT) = 0
      VALIDMIN(ALPHA) = 0
      VALIDMIN(ALPHA_EQ)= 0

      VALIDMAX(B_CALC)  = 1.0E+5   !B_Calc
      VALIDMAX(B_EQ)  = 1.0E+5   !B_Eq
      VALIDMAX(B_I)  = 100.0    !I
      VALIDMAX(L)  = 100.0    !L
      VALIDMAX(LSTAR)  = 100.0    !L_star
      VALIDMAX(MLT)  = 24.0     !MLT 
      VALIDMAX(ALPHA)  = 180.0    !Alpha
      VALIDMAX(ALPHA_EQ) = 180.0    !Alpha_Eq

      DATATYPE(B_CALC) = CDF_DOUBLE
      DATATYPE(B_EQ) = CDF_DOUBLE
      DATATYPE(B_I) = CDF_FLOAT
      DATATYPE(L) = CDF_FLOAT
      DATATYPE(LSTAR) = CDF_FLOAT
      DATATYPE(MLT) = CDF_FLOAT
      DATATYPE(ALPHA) = CDF_FLOAT
      DATATYPE(ALPHA_EQ) = CDF_FLOAT

      RETURN
      END

C ======================================================================
C ======================================================================
C ======================================================================
      SUBROUTINE PARSE_CMD( file, epoch_var, pos_var, pos_sysaxes)
      IMPLICIT NONE

      CHARACTER*(*) file, epoch_var, pos_var
      INTEGER*4     pos_sysaxes
      
      INTEGER*4 IARGC,nargs, i, i1,i2, e_arg, p_arg, s_arg
      EXTERNAL IARGC

C     max cmd line:   irbem_add -e <Epoch> -p <Position> -s <sysaxes> <file>
      CHARACTER*200   args(7),arg

C     ------------------------------------------------------------------

      epoch_var = 'Epoch'
      pos_var   = 'Position'
      pos_sysaxes = 1

      nargs = IARGC()
      IF ( nargs .EQ. 0) THEN
         PRINT*,'CDF file not specified'
         PRINT*,'test_cdf [-e <Epoch Variable>] '//
     &          '[-p <position Variable>] [-s <sysaxes>] <cdf_file>'
         PRINT*,''
         PRINT*,'If the epoch variable is not defined, '//
     &          'it defaults to [Epoch]'
         PRINT*,'If the position variable is not defined, '//
     &          'it defaults to [Position]'
         PRINT*,'If the sysaxes variable is not defined, ' //
     &          'it defaults to 1 (GEO)'
         PRINT*,'  NOTE: sysaxes is only used if the position '//
     &          'variable is also specified.'
         STOP
      ENDIF

      e_arg = -1
      p_arg = -1
      s_arg = -1
      DO i=1, nargs
          CALL getarg( i, arg )
          CALL STR_TRIM( arg, i1,i2)
C         if the command line switch is found then save index of 
C         the relevant variable name
          if (arg(i1:i2) .EQ. '-e') e_arg = i+1
          if (arg(i1:i2) .EQ. '-p') p_arg = i+1
          if (arg(i1:i2) .EQ. '-s') s_arg = i+1
          args(i) = arg
      ENDDO
      if ( e_arg .GT. 0) epoch_var = args(e_arg)
      if ( p_arg .GT. 0) pos_var   = args(p_arg)
      if ( s_arg .GT. 0) 
     &       READ( args(s_arg),*) pos_sysaxes


C     file is always the last argument
      file = args( nargs)

c      CALL STR_TRIM( file, i1,i2)
c      WRITE(*,'(a,$)')   'CDFFile="'//file(i1:i2)//'"'
c      CALL STR_TRIM( epoch_var, i1,i2)
c      WRITE(*,'(a,$)')   ', Epoch Var="'//epoch_var(i1:i2)//'"'
c      CALL STR_TRIM( pos_var, i1,i2)
c      WRITE(*,'(a,$)')   ', Pos. Var="'//pos_var(i1:i2)//'"'
c      WRITE(*,'(a,i2)')  ', SYSAXES=', pos_sysaxes
      
      RETURN
      END
C ======================================================================
C ======================================================================
C ======================================================================
      SUBROUTINE STR_TRIM(STR, I1, I2)

      IMPLICIT NONE

      CHARACTER*(*) STR
      INTEGER*4 I1, I2

      DO I1=1,LEN(STR)
        IF (STR(I1:I1) .NE. ' ') GO TO 1
      END DO
      I1 = 0
   1  DO I2=LEN(STR),I1+1,-1
        IF (STR(I2:I2) .NE. ' ') GO TO 2
      END DO
      I2 = I1
   2  RETURN

      END

C ======================================================================
C ======================================================================
C ======================================================================

      SUBROUTINE CALC_ALPHA( B_calc, B_eq, alpha)
      IMPLICIT NONE

      REAL*8 R_to_D

      REAL*8 B_calc, B_eq
      REAL*4 alpha

      R_to_D=57.295779513082322865D+00

      IF (( B_calc .GT. 0.0D0) .AND. (B_eq .GT. 0.0D0)) THEN
         alpha = 1.0D0*ASIN( MIN(SQRT( B_eq/B_calc), 1.0D0) )
         alpha = alpha * R_to_D
      ELSE
         alpha = -1.0D31
      ENDIF

      RETURN
      END
