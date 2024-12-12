Date and time functions
=======================

.. irbem:routine:: JULDAY

   Calculate the Julian Day Number for a given month, day, and year.
 
   :param integer month: month number (1 = January, ..., 12 = December)
   :param integer day: day of the month
   :param integer year: year
   :output integer julday: Julian Day Number which begins at noon of the specified calendar date
   :callseq FORTRAN: result = JULDAY(year, month, day)

.. irbem:routine:: CALDAT
   
   Return the calendar date given julian day. This is the inverse of the function :irbem:ref:`JULDAY`.

   :param integer julday: Julian Day Number
   :output integer month: month number (1 = January, ..., 12 = December)
   :output integer day: day of the month
   :output integer year: year
   :callseq FORTRAN: call CALDAT(julian, year, month, day)

.. irbem:routine:: GET_DOY

   Calculate the day of year for a given month, day, and year.

   :param integer month: month number (1 = January, ..., 12 = December)
   :param integer day: day of the month
   :param integer year: year
   :output integer doy: day of year
   :callseq FORTRAN: doy = GET_DOY(year, month, day)
   
.. irbem:routine:: DECY2DATE_AND_TIME

   Calculate the date and time (year, month, day of month, day of year and Universal Time)

   :param double dec_y: decimal year, where :code:`yyyy.0d0` is January 1st at 00:00
   :output integer year: year
   :output integer month: month number (1 = January, ..., 12 = December)
   :output integer day: day of the month
   :output integer doy: day of year (1 for January 1st)
   :output integer hour: UT hour of day (h)
   :output integer minute: UT minute (min)
   :output integer second: UT second (sec)
   :output double UT: UT time of day (sec)
   :callseq FORTRAN: CALL DECY2DATE_AND_TIME(Dec_y,Year,Month, Day, doy, hour,minute,second,UT)

.. irbem:routine:: DATE_AND_TIME2DECY

   Calculate the decimal year from date and time.

   :param integer year: year
   :param integer month: month number (1 = January, ..., 12 = December)
   :param integer day: day of the month
   :param integer hour: UT hour of day (h)
   :param integer minute: UT minute (min)
   :param integer second: UT second (sec)
   :output double dec_y: decimal year, where :code:`yyyy.0d0` is January 1st at 00:00
   :callseq FORTRAN: CALL DATE_AND_TIME2DECY(Year,Month,Day,hour,minute,second,Dec_y)

.. irbem:routine:: DOY_AND_UT2DATE_AND_TIME

   Calculate month, day, year, hour, minute, second from year, day of year and UT.

   :param integer year: year
   :param integer doy: day of year (1 for January 1st)
   :param double UT: UT time of day (sec)
   :output integer month: month number (1 = January, ..., 12 = December)
   :output integer day: day of the month
   :output integer hour: UT hour of day (h)
   :output integer minute: UT minute (min)
   :output integer second: UT second (sec)
   :callseq FORTRAN: CALL DOY_AND_UT2DATE_AND_TIME(Year,Doy,UT,Month, Day, hour,minute,second)
   

