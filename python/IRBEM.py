__author__ = 'Mykhaylo Shumko'
__last_modified__ = '2017-10-05'
__credit__ = 'IRBEM-LIB development team'

"""
Copyright 2017, Mykhaylo Shumko
    
IRBEM magnetic coordinates and fields wrapper class for Python. Source code
credit goes to the IRBEM-LIB development team.

***************************************************************************
IRBEM-LIB is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

IRBEM-LIB is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with IRBEM-LIB.  If not, see <http://www.gnu.org/licenses/>.
***************************************************************************
"""

import os, glob, copy
import ctypes
import numpy as np
import datetime
import dateutil.parser
import scipy.interpolate
import scipy.optimize

# Physical constants
Re = 6371 #km
c = 3.0E8 # m/s

# External magnetic field model look up table.
extModels = ['None', 'MF75', 'TS87', 'TL87', 'T89', 'OPQ77', 'OPD88', 'T96', 
    'OM97', 'T01', 'T01S' 'T04', 'A00', 'T07', 'MT']

class MagFields:
    """  
    USE
    When initializing the instance, you can provide the directory 
    'IRBEMdir' and 'IRBEMname' arguments to the class to specify the location 
    of the  compiled FORTRAN shared object (so) file, otherwise, it will 
    search for a .so file in the ./../sources/ directory.
    
    When creating the instance object, you can use the 'options' kwarg to 
    set the options, dafault is 0,0,0,0,0. Kwarg 'kext' sets the external B 
    field as is set to default of 4 (T89c model), and 'sysaxes' kwarg sets the 
    input coordinate system, and is set to GDZ (lat, long, alt). 
    
    verbose keyword, set to False by default, will print too much information 
    (TMI)! Usefull for debugging and for knowing too much. Set it to True if
    Python quietly crashes (probably an input to Fortran issue)
    
    Python wrapper error value is -9999.
    
    TESTING IRBEM:
    Run magfields_tests_and_visalization.py. There may be buffer warnings, but 
    otherwise they should run.
    
    Functions wrapped and tested:
    make_lstar()
    drift_shell()
    find_mirror_point()   
    find_foot_point()
    trace_field_line()
    find_magequator()
    
    Functions wrapped and not tested:
    None
    
    Special functions not in normal IRBEM (no online documentation yet):
    bounce_period()
    mirror_point_altitude()
    
    Please contact me at msshumko at gmail.com if you have questions/comments
    or you would like me to wrap a particular function.
    """
    def __init__(self, **kwargs):
        self.compiledIRBEMdir = kwargs.get('IRBEMdir', None)
        self.compiledIRBEMname = kwargs.get('IRBEMname', None)    
        self.TMI = kwargs.get('verbose', False)
        
        # Unless the shared object location is specified, look for it
        # in the source directory of IRBEM.
        if self.compiledIRBEMdir == None and self.compiledIRBEMname == None:
            self.compiledIRBEMdir = \
            os.path.abspath(os.path.join(os.path.dirname( __file__ ), \
            '..', 'source'))
            fullPaths = glob.glob(os.path.join(self.compiledIRBEMdir,'*.so'))
            assert len(fullPaths) == 1, 'Either none or multiple .so files '+\
            'found in the sources folder!'
            self.compiledIRBEMname = os.path.basename(fullPaths[0])
        
        # Open the shared object file.
        try:
            self.irbem = ctypes.cdll.LoadLibrary(os.path.join(\
            self.compiledIRBEMdir, self.compiledIRBEMname))
        except OSError:
            print('Error, cannot find the IRBEM shared object file. Please' + \
            ' correct "IRBEMdir" and "IRBEMname" kwargs to the IRBEM instance.')
            raise
        
        # global model parameters, default is T89 model with GDZ coordinate
        # system.
        # If kext is a string, find the corresponding integer value
        kext = kwargs.get('kext', 4)
        if isinstance(kext, str):
            try:
                self.kext = ctypes.c_int(extModels.index(kext))
            except ValueError:
                print("Incorrect external model selected! Use 'None', 'MF75',",
                    "'TS87', 'TL87', 'T89', 'OPQ77', 'OPD88', 'T96', 'OM97'",
                    "'T01', 'T04', 'A00'")
                raise
        else:
            self.kext = ctypes.c_int(kext)
        
        
        #self.kext = ctypes.c_int(kwargs.get('kext', 4))
        self.sysaxes = ctypes.c_int(kwargs.get('sysaxes', 0))
        
        # If options are not supplied, assume they are all 0's.
        optionsType =  ctypes.c_int * 5
        if 'options' in kwargs:
            self.options = optionsType()
            for i in range(5):
                self.options[i] = kwargs['options'][i]
        else:
            self.options = optionsType(0,0,0,0,0)
        return
        
    def make_lstar(self, X, maginput):
        """
        NAME: call_make_lstar(self, X, maginput)
        USE:  Runs make_lstar1() from the IRBEM-LIB library. This function 
              returns McLlwain L, L*, blocal, bmin, xj, and MLT from the 
              position from input location.
        INPUT: X, a dictionary of positions in the specified coordinate  
             system. a 'dateTime' key and values must be provided as well.
        AUTHOR: Mykhaylo Shumko
        RETURNS: McLLwain L, MLT, blocal, bmin, lstar, xj in a dictionary.
        MOD:     2017-05-21
        """
        # Deep copy so if the single inputs get encapsulated in an array,
        # it wont be propaged back to the user.
        X2 = copy.deepcopy(X)
        
        # Check if function arguments are not lists/arrays. Convert them to 
        # size 1 arrays. This is different than other functions because
        # you can feed an array of positions and times to make_lstar().
        if( not isinstance(X2['dateTime'], list) and 
                not isinstance(X2['dateTime'], np.ndarray) ):
            X2['dateTime'] = np.array([X2['dateTime']])
            X2['x1'] = np.array([X2['x1']])
            X2['x2'] = np.array([X2['x2']])
            X2['x3'] = np.array([X2['x3']])

        nTimePy = len(X2['dateTime'])
        if nTimePy > 50000:
            print('Warning, more than 50,000 data points fed to IRBEM. '+
            'It may crash without warning!')
        ntime = ctypes.c_int(nTimePy)        
        
        # Convert times to datetime objects.
        
        if type(X2['dateTime'][0]) is datetime.datetime:
            t = X2['dateTime']
        else:
            t = nTimePy * [None]
            for i in range(nTimePy):
                t[i] = dateutil.parser.parse(X2['dateTime'][i])
            
        nTimePy = len(X2['dateTime'])
        ntime = ctypes.c_int(nTimePy)
        
        # C arrays are statically defined with the following procedure.
        # There are a few ways of doing this...
        intArrType = ctypes.c_int * nTimePy
        iyear = intArrType()
        idoy = intArrType()
        
        doubleArrType = ctypes.c_double * nTimePy
        ut, x1, x2, x3 = [doubleArrType() for i in range(4)]
        
        # Prep magentic field model inputs        
        maginput = self._prepMagInput(maginput)
        
        # Now fill the input time and model sampling (s/c location) parameters.
        for dt in range(nTimePy):
            iyear[dt] = t[dt].year
            idoy[dt] = t[dt].timetuple().tm_yday
            ut[dt] = 3600*t[dt].hour + 60*t[dt].minute + t[dt].second
            x1[dt] = X2['x1'][dt]
            x2[dt] = X2['x2'][dt] 
            x3[dt] = X2['x3'][dt]
                
        # Model outputs
        lm, lstar, blocal, bmin, xj, mlt = [doubleArrType() for i in range(6)]
        
        if self.TMI: print("Running IRBEM-LIB make_lstar")

        self.irbem.make_lstar1_(ctypes.byref(ntime), ctypes.byref(self.kext), 
                ctypes.byref(self.options), ctypes.byref(self.sysaxes), ctypes.byref(iyear),
                ctypes.byref(idoy), ctypes.byref(ut), ctypes.byref(x1), 
                ctypes.byref(x2), ctypes.byref(x3), ctypes.byref(maginput), 
                ctypes.byref(lm), ctypes.byref(lstar), ctypes.byref(blocal),
                ctypes.byref(bmin), ctypes.byref(xj), ctypes.byref(mlt))
        self.make_lstar_output = {'Lm':lm[:], 'MLT':mlt[:], 'blocal':blocal[:],
            'bmin':bmin[:], 'Lstar':lstar[:], 'xj':xj[:]}  
        #del X
        return self.make_lstar_output
        
    def drift_shell(self, X, maginput):
        """
        NAME:  drift_shell(self, X, maginput, verbose = False)
        USE:  This function traces a full drift shell for particles that have 
               their  mirror point at the input location. The output is a full
               array of positions of the drift shell, usefull for plotting and 
               visualisation (for just the points on the drift-bounce orbit, 
               use DRIFT_BOUNCE_ORBIT). A set of internal/external field can be
               selected.
        
               Note: Need to call this function for one set of ephemeris 
               inputs at a time.
              
        INPUT: X, a dictionary of positions in the specified coordinate  
               system. a 'dateTime' key and values must be provided as 
               well.
        AUTHOR: Mykhaylo Shumko
        RETURNS: A dictionary with the following keys: 'Lm', 'blocal', 'bmin',
               'lstar', 'xj', 'POSIT', and 'Nposit'. 
               Posit structure: 1st element: x, y, z GEO coord, 2nd element: 
               points along field line, 3rd element: number of field lines.
               
               nposit structure: long integer array (48) providing the number 
               of points along the field line for each field line traced in 
               2nd element of POSIT max 1000.
        MOD:     2017-01-09
        """
        # Prep the magnetic field model inputs and samping spacetime location.
        self._prepMagInput(maginput)
        iyear, idoy, ut, x1, x2, x3 = self._prepTimeLoc(X)
        
        # DEFINE OUTPUTS HERE        
        positType = (((ctypes.c_double * 3) * 1000) * 48)
        posit = positType()
        npositType = (48 * ctypes.c_long)
        nposit = npositType()
        lm, lstar, bmin, xj = [ctypes.c_double() for i in range(4)]
        blocalType = ((ctypes.c_double * 1000) * 48)
        blocal = blocalType()
        
        if self.TMI: print("Running IRBEM-LIB drift_shell")

        self.irbem.drift_shell1_(ctypes.byref(self.kext), ctypes.byref(self.options),\
                ctypes.byref(self.sysaxes), ctypes.byref(iyear),\
                ctypes.byref(idoy), ctypes.byref(ut), ctypes.byref(x1), \
                ctypes.byref(x2), ctypes.byref(x3), ctypes.byref(self.maginput), \
                ctypes.byref(lm), ctypes.byref(lstar), ctypes.byref(blocal), \
                ctypes.byref(bmin), ctypes.byref(xj), ctypes.byref(posit), \
                ctypes.byref(nposit))
        # Format the output into a dictionary, and convert ctypes arrays into
        # native Python format.
        self.drift_shell_output = {'Lm':lm.value, 'blocal':np.array(blocal),
            'bmin':bmin.value, 'lstar':lstar.value, 'xj':xj.value, 
            'POSIT':np.array(posit), 'Nposit':np.array(nposit)} 
        return self.drift_shell_output
            
            
    def drift_bounce_orbit(self):
        print('Under construction and not tested!')
        return
    
    def find_mirror_point(self, X, maginput, alpha):
        """
        NAME: find_mirror_point(self, X, maginput, alpha, verbose = False)
        USE:  This function finds the magnitude and location of the mirror 
              point along a field line traced from any given location and 
              local pitch-angle for a set of internal/external field to be 
              selected. 
        INPUTS: X is a dictionary with  single, non-array values in the 
              'dateTime', 'x1', 'x2', and 'x3' keys. maginput
              is the standard dictionary with the same keys as explained in the
              html doc.
        RETURNS: A dictionary with scalar values of blocal and bmin, and POSIT,
              the GEO coordinates of the mirror point
        AUTHOR: Mykhaylo Shumko
        MOD:     2017-01-05
        """
        a = ctypes.c_double(alpha)
        
        # Prep the magnetic field model inputs and samping spacetime location.
        self._prepMagInput(maginput)
        iyear, idoy, ut, x1, x2, x3 = self._prepTimeLoc(X)
        
        blocal, bmin = [ctypes.c_double(-9999) for i in range(2)]
        positType = (3 * ctypes.c_double)
        posit = positType()

        if self.TMI: print("Running IRBEM-LIB mirror_point")
            
        self.irbem.find_mirror_point1_(ctypes.byref(self.kext), \
                ctypes.byref(self.options), ctypes.byref(self.sysaxes), \
                ctypes.byref(iyear), ctypes.byref(idoy), ctypes.byref(ut), \
                ctypes.byref(x1), ctypes.byref(x2), ctypes.byref(x3), \
                ctypes.byref(a), ctypes.byref(self.maginput), \
                ctypes.byref(blocal), ctypes.byref(bmin), ctypes.byref(posit))     
                
        self.find_mirror_point_output = {'blocal':blocal.value, 'bmin':bmin.value, \
                'POSIT':posit[:]}
        return self.find_mirror_point_output
    
    def find_foot_point(self, X, maginput, stopAlt, hemiFlag):
        """
        NAME: find_foot_point(X, kp, stopAlt, hemiFlag)
        USE:  This function finds the of the field line crossing a specified 
              altitude in a specified hemisphere. Error code for IRBEMpy is 
              -9999, IRBEM error code is -9.9999999999999996E+30.
        INPUTS: X is a dictionary with  single, non-array values in the 
              'dateTime', 'x1', 'x2', and 'x3' keys. stopAlt is the desired
              altitude of the foot point (km), hemiFlag is the hemisphere where
              to find the foot point. It can take on values:
              
              0    = same magnetic hemisphere as starting point
              +1   = northern magnetic hemisphere
              -1   = southern magnetic hemisphere
              +2   = opposite magnetic hemisphere as starting point        
        RETURNS: A dictionary with the following values:
                 XFOOT = location of foot point, GDZ coordinates
                 BFOOT = magnetic field vector at foot point, GEO, nT
                 BFOOTMAG = magnetic field magnitude at foot point, GEO,nT unit
        AUTHOR: Mykhaylo Shumko
        MOD:     2016-11-09
        """
        # Prep the magnetic field model inputs and samping spacetime location.
        self._prepMagInput(maginput)
        iyear, idoy, ut, x1, x2, x3 = self._prepTimeLoc(X)      
        
        stop_alt = ctypes.c_double(stopAlt)
        hemi_flag = ctypes.c_int(hemiFlag)
        
        # Define output variables here
        outputType = ctypes.c_double * 3
        XFOOT = outputType(-9999, -9999, -9999)
        BFOOT = outputType(-9999, -9999, -9999)
        BFOOTMAG = outputType(-9999, -9999, -9999)
        
        if self.TMI: print("Running IRBEM-LIB find_foot_point")
            
        self.irbem.find_foot_point1_(ctypes.byref(self.kext), \
                ctypes.byref(self.options),\
                ctypes.byref(self.sysaxes), ctypes.byref(iyear),\
                ctypes.byref(idoy), ctypes.byref(ut), ctypes.byref(x1), \
                ctypes.byref(x2), ctypes.byref(x3), ctypes.byref(stop_alt), \
                ctypes.byref(hemi_flag), ctypes.byref(self.maginput), \
                ctypes.byref(XFOOT), ctypes.byref(BFOOT), \
                ctypes.byref(BFOOTMAG))
        self.find_foot_point_output = {'XFOOT':XFOOT[:], 'BFOOT':BFOOT[:], \
        'BFOOTMAG':BFOOTMAG[:]}
        return self.find_foot_point_output
        
    def trace_field_line(self, X, maginput, R0 = 1):
        """
        NAME: trace_field_line(self, X, maginput, R0 = 1, verbose = False)
        USE:  This function traces a full field line which crosses the input 
              position.  The output is a full array of positions of the field 
              line, usefull for plotting and visualisation for a set of 
              internal/external fields to be selected. A new option (R0) for 
              TRACE_FIELD_LINE2 allows user to specify the radius (RE) of the 
              reference surface between which the line is traced (R0=1 in 
              TRACE_FIELD_LINE)  

        INPUTS: X is a dictionary with  single, non-array values in the 
              'dateTime', 'x1', 'x2', and 'x3' keys. R0 kwarg sets the stop 
              altitude (Re) of the field line tracing, default is R0 = 1.
        RETURNS: A dictionary with the following key:values
                 'POSIT', 'Nposit', 'lm', 'blocal', 'bmin', 'xj'. 
                 POSIT is an array(3, 3000) of GDZ locations of the field line
                 at 3000 points.
        AUTHOR: Mykhaylo Shumko
        MOD:     2017-01-09
        """        
        # specifies radius of reference surface between which field line is 
        # traced.
        R0 = ctypes.c_double(R0) 

        # Prep the magnetic field model inputs and samping spacetime location.
        self._prepMagInput(maginput)
        iyear, idoy, ut, x1, x2, x3 = self._prepTimeLoc(X)
        
        # Output variables
        positType = ((ctypes.c_double * 3) * 3000)
        posit = positType()
        Nposit = ctypes.c_int(-9999)      
        lm, blocal, bmin, xj = [ctypes.c_double(-9999) for i in range(4)]
        
        blocalType = (ctypes.c_double * 3000)
        blocal = blocalType()
    
        if self.TMI: print("Running trace_field_line. Python may",
            "temporarily stop responding")
        
        self.irbem.trace_field_line2_1_(ctypes.byref(self.kext), \
                ctypes.byref(self.options),\
                ctypes.byref(self.sysaxes), ctypes.byref(iyear),\
                ctypes.byref(idoy), ctypes.byref(ut), ctypes.byref(x1), \
                ctypes.byref(x2), ctypes.byref(x3), ctypes.byref(self.maginput), \
                ctypes.byref(R0), ctypes.byref(lm), ctypes.byref(blocal), \
                ctypes.byref(bmin), ctypes.byref(xj), ctypes.byref(posit), \
                ctypes.byref(Nposit))
                
        self.trace_field_line_output = {'POSIT':np.array(posit[:Nposit.value]), \
        "Nposit":Nposit.value, 'lm':lm.value, 'blocal':np.array(blocal[:Nposit.value]), \
        'bmin':bmin.value, 'xj':xj.value}        
        return self.trace_field_line_output
        
    def find_magequator(self, X, maginput):
        """
        NAME: find_magequator(self, X, maginput, verbose = False)
        USE:  This function finds the coordinates of the magnetic equator from 
              tracing the magntic field line from the input location.
        INPUTS: X is a dictionary with  single, non-array values in the 
              'dateTime', 'x1', 'x2', and 'x3' keys. maginput is a dictionary
              with model key:input pairs.
        RETURNS: Dictionary of bmin and XGEO. bmin is the magntitude of the 
              magnetic field at equator. XGEO is an array of [xGEO,yGEO,zGEO].
        AUTHOR: Mykhaylo Shumko
        MOD:     2017-02-02
        """ 
        
        # Prep the magnetic field model inputs and samping spacetime location.
        self._prepMagInput(maginput)
        iyear, idoy, ut, x1, x2, x3 = self._prepTimeLoc(X)
        
        # Define outputs
        bmin = ctypes.c_double(-9999) 
        XGEOType = (ctypes.c_double * 3)
        XGEO = XGEOType(-9999, -9999, -9999)
        
        if self.TMI: print('Running IRBEM find_magequator')

        self.irbem.find_magequator1_(ctypes.byref(self.kext), \
                ctypes.byref(self.options), ctypes.byref(self.sysaxes), \
                ctypes.byref(iyear), ctypes.byref(idoy), ctypes.byref(ut), \
                ctypes.byref(x1), ctypes.byref(x2), ctypes.byref(x3), \
                ctypes.byref(self.maginput), ctypes.byref(bmin), \
                ctypes.byref(XGEO))
        self.find_magequator_output = {'bmin':bmin.value, 'XGEO':np.array(XGEO)}
        return self.find_magequator_output
        
    def bounce_period(self, X, maginput, E, **kwargs):
        """
        NAME:  bounce_period(self, X, maginput, E, **kwargs)
        USE:   Calculates the bounce period in an arbitary magnetic field 
               model. The default particle is electron, but an optional Erest
               parameter can be used to change the rest energy of the particle
               to a proton.
        INPUT: A dictionary, X containing the time and sampling location. 
               Input keys must be 'dateTime', 'x1', 'x2', 'x3'. maginput
               dictionary provides model parameters. Optional parameters
               are Erest in keV, the rest energy of the bouncing particle, 
               default is Erest = 511 (electron rest energy). R0 = 1, the limit
               of the magnetic field line tracing at Earth's surface. Changing 
               this is useful if the mirror point is below the ground 
               (unphysical, but may be useful in certain applications).
               interpNum is the number of samples to take along the field line.
               Default is 100000, a good balance between speed and accuracy.
               alpha is the local pitch angle
        AUTHOR: Mykhaylo Shumko
        RETURNS: Bounce period value or values, depending if E is an array or
                a single value.
        MOD:     2017-04-06        
        """
        Erest = kwargs.get('Erest', 511)
        R0 = kwargs.get('R0', 1)
        alpha = kwargs.get('alpha', 90)
        interpNum = kwargs.get('interpNum', 100000)
        
        if self.TMI: print('IRBEM: Calculating bounce periods')
        
        fLine = self._interpolate_field_line(X, maginput, R0=R0, alpha=alpha)
                                             
        # If the mirror point is below the ground, Scipy will error, try 
        # to change the R0 parameter...
        try:
            startInd = scipy.optimize.brentq(fLine['fB'], 0, 
                                             len(fLine['S'])/2)
            endInd = scipy.optimize.brentq(fLine['fB'], 
                                       len(fLine['S'])/2, len(fLine['S'])-1)
        except ValueError as err:
            if str(err) == 'f(a) and f(b) must have different signs':
                 raise ValueError('Mirror point below the ground!, Change R0' +
                 ' or catch this error and assign it a value.', 
                 '\n Original error: ', err)
        
        # Resample S to a finer density of points.
        if len(fLine['S']) > interpNum: 
            print('Warning: interpolating with less data than IRBEM outputs,'+
            ' the bounce period may be inaccurate!')
        sInterp = np.linspace(startInd, endInd, num = interpNum)
        
        # Calculate the small change in position, and magnetic field.
        dx = np.convolve(fLine['fx'](sInterp), [-1,1], mode = 'same')
        dy = np.convolve(fLine['fy'](sInterp), [-1,1], mode = 'same')
        dz = np.convolve(fLine['fz'](sInterp), [-1,1], mode = 'same')
        ds = 6.371E6*np.sqrt(dx**2 + dy**2 + dz**2)
        dB = fLine['fB'](sInterp) + fLine['mirrorB']
        
        # This is basically an integral of ds/v||.
        if isinstance(E, (np.ndarray, list)):
            self.Tb = [2*np.sum(np.divide(ds[1:-1], vparalel(Ei, fLine['mirrorB'], dB, 
                                              Erest = Erest)[1:-1])) for Ei in E]
        else:
            self.Tb = 2*np.sum(np.divide(ds[1:-1], vparalel(E, fLine['mirrorB'], dB, 
                                             Erest = Erest)[1:-1]))
        return self.Tb
        
    def mirror_point_altitude(self, X, maginput, **kwargs):
        """"
        NAME:  mirror_point_altitude(self, X, maginput)
        USE:   Calculates the mirror point of locally mirroring electrons
               in the opposite hemisphere. Similar to the find_mirror_point()
               function, but it works in the opposite hemisphere.
        INPUT: A dictionary, X containing the time and sampling location. 
               Input keys must be 'dateTime', 'x1', 'x2', 'x3'. maginput
               dictionary provides model parameters. Optional parameters
               are Erest in keV, the rest energy of the bouncing particle, 
               default is Erest = 511 (electron rest energy). R0 = 1, the limit
               of the magnetic field line tracing at Earth's surface. Changing 
               this is useful if the mirror point is below the ground 
               (unphysical, but may be useful in certain applications).
        RETURNS: Mirror point in the opposite hemisphere.
        AUTHOR: Mykhaylo Shumko
        MOD:     2017-04-06        
        """
        R0 = kwargs.get('R0', 1)
        
        if self.TMI: print('IRBEM: Calculating mirror point altitude')
            
        fLine = self._interpolate_field_line(X, maginput, R0=R0)
                                             
        # If the mirror point is below the ground, Scipy will error, try 
        # to change the R0 parameter...
        try:
            startInd = scipy.optimize.brentq(fLine['fB'], 0, 
                                             len(fLine['S'])/2)
            endInd = scipy.optimize.brentq(fLine['fB'], 
                                       len(fLine['S'])/2, len(fLine['S'])-1)
        except ValueError as err:
            if str(err) == 'f(a) and f(b) must have different signs':
                if self.TMI:
                     raise ValueError('Mirror point below the ground!, Change R0' +
                     ' or catch this error and assign it a value.', 
                     '\n Original error: ', err)
                else: 
                    raise ValueError('Mirror point below the ground!')
                        
        # Start indicies of the magnetic field is always in the northern
        # hemisphere, so take the opposite.
        self.mirrorAlt = {}
        if fLine['fz'](startInd) > 0:
            self.mirrorAlt = Re*(np.sqrt(fLine['fx'](endInd)**2 + 
            fLine['fy'](endInd)**2 + fLine['fz'](endInd)**2)-1)
        else:
            self.mirrorAlt = Re*(np.sqrt(fLine['fx'](startInd)**2 + 
            fLine['fy'](startInd)**2 + fLine['fz'](startInd)**2)-1)
        return self.mirrorAlt
        
    def _prepTimeLoc(self, Xloc):
        """
        NAME:  _prepTimeLoc(self, Xloc)
        USE:   Prepares spacetime outputs.
        INPUT: A dictionary, Xloc containing the time and sampling location. 
               Input keys must be 'dateTime', 'x1', 'x2', 'x3'.
        AUTHOR: Mykhaylo Shumko
        RETURNS: ctypes variables iyear, idoy, ut, x1, x2, x3.
        MOD:     2017-01-12
        """
        if self.TMI: print('Prepping time and space input variables')

        if type(Xloc['dateTime']) is datetime.datetime:
            t = Xloc['dateTime']
        else:
            t = dateutil.parser.parse(Xloc['dateTime'])
        iyear = ctypes.c_int(t.year)
        idoy = ctypes.c_int(t.timetuple().tm_yday)
        ut = ctypes.c_double(3600*t.hour + 60*t.minute + t.second)
        x1 = ctypes.c_double(Xloc['x1']) 
        x2 = ctypes.c_double(Xloc['x2'])
        x3 = ctypes.c_double(Xloc['x3'])
        if self.TMI: print('Done prepping time and space input variables')
        return iyear, idoy, ut, x1, x2, x3
    
    def _prepMagInput(self, inputDict = None):
        """
        NAME:  _prepMagInput(self, inputDict)
        USE:   Prepares magnetic field model inputs.
        INPUT: A dictionary containing the maginput keys in either numpy 
              arrays, lists, ints, or doubles. The keys must be some of these: 
              'Kp', 'Dst', 'dens', 'velo', 'Pdyn', 'ByIMF', 'BzIMF',
              'G1', 'G2', 'G3', 'W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'AL'
        AUTHOR: Mykhaylo Shumko
        RETURNS: self.maginput, a ctypes 2D array to pass as an argument to 
              IRBEM functions. Dummy values are -9999.
        MOD:     2017-01-05
        """
        if self.TMI: print('Prepping magnetic field inputs.')

        # If no model inputs (statis magnetic field model)
        if inputDict == None:
            magInputType = (ctypes.c_double * 25)
            self.maginput = magInputType()
            for i in range(25):
                self.maginput[i] = -9999
            return self.maginput
        
        orderedKeys = ['Kp', 'Dst', 'dens', 'velo', 'Pdyn', 'ByIMF', \
            'BzIMF', 'G1', 'G2', 'G3', 'W1', 'W2', 'W3', 'W4', 'W5', 'W6', \
            'AL']
        # Assume all values assosiated with keys are the same type.
        magType = type(inputDict[list(inputDict.keys())[0]])
        
        # If the model inputs are arrays
        if magType in [np.ndarray, list]:
            nTimePy = len(inputDict[list(inputDict.keys())[0]])
            magInputType = ((ctypes.c_double * nTimePy) * 25)
            self.maginput = magInputType()
            
            # Loop over potential keys.
            for i in range(len(orderedKeys)):
                # Loop over times.
                for dt in range(nTimePy):
                    # For every key provided by user, populate the maginput 
                    # C array.
                    if orderedKeys[i] in list(inputDict.keys()):
                        self.maginput[i][dt] = inputDict[orderedKeys[i]][dt]
                    else:
                        self.maginput[i][dt] = ctypes.c_double(-9999) 
                        
        # If model inputs are integers or doubles.
        elif magType in [int, float, np.float64]:
            magInputType = (ctypes.c_double * 25)
            self.maginput = magInputType()
            
            # Loop over ordered keys, and fill the maginput array with keys 
            # given.
            for i in range(len(orderedKeys)):
                # Loop over times.
                if orderedKeys[i] in list(inputDict.keys()):
                    self.maginput[i] = inputDict[orderedKeys[i]]
                else:
                    self.maginput[i] = ctypes.c_double(-9999) 
        
        # If model inputs are something else (probably incorrect format)
        else:
            raise TypeError('Model inputs are in an unrecognizable format.' +\
            ' Try a dictionary of numpy arrays, lists, ints or floats')

        if self.TMI: print('Done prepping magnetic field inputs.')

        return self.maginput  
        
    def _interpolate_field_line(self, X, maginput, R0 = 1, alpha = 90):
        """
        NAME:  _interpolate_field_line(self, X, maginput)
        USE:   This function cubic spline interpolates a magnetic field line 
               that crosses the input location down to a radius, R0 from Earth 
               center.               
        INPUT: A dictionary, X containing the time and and location. 
               Input keys must be 'dateTime', 'x1', 'x2', 'x3'. maginput
               dictionary contains model parameters.
               Optionally, R0 = 1 (Earth's surface) can be changed.
               alpha = 90 is the local pitch angle (for bounce period 
               calculation).
        AUTHOR: Mykhaylo Shumko
        RETURNS: Interpolate objects of the B field, B field path coordinate S,
                 X, Y, Z GEO coordinates, and B field at input location.
        MOD:     2017-04-06
        """
        if self.TMI: print('Interpolating magnetic field line')

        X2 = copy.deepcopy(X)
        self.make_lstar(X2, maginput)
        inputblocal = self.make_lstar_output['blocal'][0]
        
        out = self.trace_field_line(X, maginput)
        if out['Nposit'] == -9999:
            raise ValueError('This is an open field line!')
        
        # Create arrays of GEO coordinates, and path coordinate, S.
        xGEO = out['POSIT'][:out['Nposit'], 0] 
        yGEO = out['POSIT'][:out['Nposit'], 1] 
        zGEO = out['POSIT'][:out['Nposit'], 2] 
        S = range(len(out['blocal'][:out['Nposit']]))
        
        # Interpolate the magnetic field, as well as GEO coordinates.
        fB = scipy.interpolate.interp1d(S, 
            np.subtract(out['blocal'][:out['Nposit']], inputblocal/np.sin(
            np.deg2rad(alpha))**2), kind = 'cubic')
        fx = scipy.interpolate.interp1d(S, xGEO, kind = 'cubic')
        fy = scipy.interpolate.interp1d(S, yGEO, kind = 'cubic')
        fz = scipy.interpolate.interp1d(S, zGEO, kind = 'cubic')
        if self.TMI: print('Done interpolating magnetic field line.')
        return {'S':S, 'fB':fB, 'fx':fx, 'fy':fy, 'fz':fz, 
            'mirrorB':inputblocal/np.sin(np.deg2rad(alpha))**2}
        
        
class Coords:
    """
    USE
    When initializing the instance, you can provide the directory 
    'IRBEMdir' and 'IRBEMname' arguments to the class to specify the location 
    of the  compiled FORTRAN shared object (so) file, otherwise, it will 
    search for a .so file in the ./../sources/ directory.
    
    When creating the instance object, you can use the 'options' kwarg to 
    set the options, dafault is 0,0,0,0,0. Kwarg 'kext' sets the external B 
    field as is set to default of 4 (T89c model), and 'sysaxes' kwarg sets the 
    input coordinate system, and is set to GDZ (lat, long, alt). 
    
    verbose keyword, set to False by default, will print too much information 
    (TMI)! Usefull for debugging and for knowing too much. Set it to True if
    Python quietly crashes (probably an input to Fortran issue)
    
    Python wrapper error value is -9999.
    
    TESTING IRBEM: Run coords_tests_and_visalization.py (FORTRAN coord_trans_vec1)
    Rough validation was done with "Heliospheric Coordinate Systems" by Franz and 
    Harper 2017.
    
    WRAPPED_FUNCTION: 
        coords_transform(self, time, pos, sysaxesIn, sysaxesOut)
    
    Please contact me at msshumko at gmail.com if you have questions/comments
    or you would like me to wrap a particular function.
    """
    def __init__(self, **kwargs):
        self.compiledIRBEMdir = kwargs.get('IRBEMdir', None)
        self.compiledIRBEMname = kwargs.get('IRBEMname', None)    
        self.TMI = kwargs.get('verbose', False)
        
        # Unless the shared object location is specified, look for it
        # in the source directory of IRBEM.
        if self.compiledIRBEMdir == None and self.compiledIRBEMname == None:
            self.compiledIRBEMdir = \
            os.path.abspath(os.path.join(os.path.dirname( __file__ ), \
            '..', 'source'))
            fullPaths = glob.glob(os.path.join(self.compiledIRBEMdir,'*.so'))
            assert len(fullPaths) == 1, 'Either none or multiple .so files '+\
            'found in the sources folder!'
            self.compiledIRBEMname = os.path.basename(fullPaths[0])
            
        self.__author__ = 'Mykhaylo Shumko'
        self.__last_modified__ = '2017-01-12'
        self.__credit__ = 'IRBEM-LIB development team'
        
        # Open the shared object file.
        try:
            self.irbem = ctypes.cdll.LoadLibrary(os.path.join(\
            self.compiledIRBEMdir, self.compiledIRBEMname))
        except OSError:
            print('Error, cannot find the IRBEM shared object file. Please' + \
            ' correct "IRBEMdir" and "IRBEMname" kwargs to the IRBEM instance.')
            raise
        return 
        
    def coords_transform(self, time, pos, sysaxesIn, sysaxesOut):
        """
        NAME:  coords_transform(self, X, sysaxesIn, sysaxesOut)
        USE:   This function transforms coordinate systems from a point at time
               time and position pos from a coordinate system sysaxesIn to 
               sysaxesOut.
        INPUT:  time - datetime.datetime objects
                       (or arrays/lists containing them)
                pos - A (nT x 3) array where nT is the number of points to transform.
                
                Avaliable coordinate transformations (either as an integer or 
                3 letter keyword will work as arguments)
                
                0: GDZ (alti, lati, East longi - km,deg.,deg)
                1: GEO (cartesian) - Re
                2: GSM (cartesian) - Re
                3: GSE (cartesian) - Re
                4: SM (cartesian) - Re
                5: GEI (cartesian) - Re
                6: MAG (cartesian) - Re
                7: SPH (geo in spherical) - (radial distance, lati, East 
                    longi - Re, deg., deg.)
                8: RLL  (radial distance, lati, East longi - Re, deg., 
                    deg. - prefered to 7)    
        AUTHOR: Mykhaylo Shumko
        RETURNS: Transformed positions as a 1d or 2d array.
        MOD:     2017-07-17
        """
        # Create the position arrays        
        if hasattr(time, '__len__'):
            pos = np.array(pos)
            pos = pos.reshape((len(time), 3))
            posArrType = ((ctypes.c_double * 3) * len(time))
            nTime = ctypes.c_int(len(time))
        else: 
            pos = np.array([pos])
            posArrType = ((ctypes.c_double * 3) * 1)
            nTime = ctypes.c_int(1)   
        posInArr = posArrType()
        posOutArr = posArrType()

        ### Get the time entries ###
        iyear, idoy, ut = self._cTimes(time)
        
        ### Lookup coordinate systems ###
        sysIn = self._coordSys(sysaxesIn)
        sysOut = self._coordSys(sysaxesOut)
        
        # Fill the positions array.
        for nT in range(pos.shape[0]):
            for nX in range(pos.shape[1]):
                posInArr[nT][nX] = ctypes.c_double(pos[nT, nX])   
       
        self.irbem.coord_trans_vec1_(ctypes.byref(nTime), ctypes.byref(sysIn),
           ctypes.byref(sysOut), ctypes.byref(iyear), ctypes.byref(idoy),
           ctypes.byref(ut), ctypes.byref(posInArr), ctypes.byref(posOutArr))
        return np.array(posOutArr[:])
        
    def _cTimes(self, times):
        """
        NAME:  _cTimes(self, times)
        USE:   This is a helper function that takes in an array of times in ISO 
                format or datetime format and returns it in ctypes format with 
                iyear, idoy, and ut.
        INPUT: times as datetime or ISO string objects. Or an array/list of those
                objects.
        AUTHOR: Mykhaylo Shumko
        RETURNS: Arrays of iyear, idoy, ut.
        MOD:     2017-07-14
        """
        if not hasattr(times, '__len__'): # Make an array if only one value supplied.
            times = np.array([times])
        N = len(times)
        
        # Intialize the C arrays
        tArrType = (ctypes.c_int * N)
        utArrType = (ctypes.c_double * N)
        iyear, idoy = [tArrType() for i in range(2)]
        ut = utArrType()
        
        # Convert to datetimes if necessary.
        if isinstance(times[0], str): 
            t = list(map(dateutil.parser.parse, times))
        elif isinstance(times[0], datetime.datetime):
            t = times
        else:
            raise ValueError('ERROR: Unknown time format! I can accept ISO '
                'string, datetime objects, or arrays of those objects')   
        
        for nT in range(N): # Populate C arrays
            iyear[nT] = ctypes.c_int(t[nT].year)
            idoy[nT] = ctypes.c_int(t[nT].timetuple().tm_yday)
            ut[nT] = ctypes.c_double(3600*t[nT].hour + 60*t[nT].minute + 
                t[nT].second)
        return iyear, idoy, ut

    def _coordSys(self, coordSystem):
        """
        NAME:  _coordSys(self, axes)
        USE:   This function looks up the IRBEM coordinate system integer, given
               an input integer, or string representing the coordinate system.
        INPUT: axes, a coordinate system from:
                0: GDZ (alti, lati, East longi - km,deg.,deg)
                1: GEO (cartesian) - Re
                2: GSM (cartesian) - Re
                3: GSE (cartesian) - Re
                4: SM (cartesian) - Re
                5: GEI (cartesian) - Re
                6: MAG (cartesian) - Re
                7: SPH (geo in spherical) - (radial distance, lati, East 
                    longi - Re, deg., deg.)
                8: RLL  (radial distance, lati, East longi - Re, deg., 
                    deg. - prefered to 7)
               either an integer or a 3 letter string.
        AUTHOR: Mykhaylo Shumko
        RETURNS: IRBEM sysaxes integer
        MOD:     2017-07-14
        """
        lookupTable = {'GDZ':0, 'GEO':1, 'GSM':2, 'GSE':3, 'SM':4, 'GEI':5, 
            'MAG':6, 'SPH':7, 'RLL':8}
        
        if isinstance(coordSystem, str):
            assert coordSystem.upper() in lookupTable.keys(), ('ERROR: Unknown'
                ' coordinate system! Choose from GDZ, GEO, GSM, GSE, SM, GEI, '
                'MAG, SPH, RLL.')
            return ctypes.c_int(lookupTable[coordSystem])
        elif isinstance(coordSystem, int):
            return ctypes.c_int(coordSystem)
        else:
            raise ValueError('Error, coordinate axis can only be a string or int!')


def IRBEM(*args, **kwargs):
    """
    Warn user that IRBEM class is depricated.
    """
    from warnings import warn
    warn("\n \n The IRBEM class is depricated, functionality has moved to MagFields.\n")
    return MagFields(*args, **kwargs)

"""
These are helper functions to calculate relativistic velocity, 
parallel velocity, and relativistic gamma factor.
Units of energy is keV unless you supply both the particle energy and rest 
energy in different units.

These functions should be used with caution in your own applications!
"""
beta = lambda Ek, Erest = 511: np.sqrt(1-((Ek/Erest)+1)**(-2)) # Ek,a dErest must be in keV
gamma = lambda Ek, Erest = 511:np.sqrt(1-beta(Ek, Erest = 511)**2)**(-1/2)
vparalel = lambda Ek, Bm, B, Erest = 511:c*beta(Ek, Erest)*np.sqrt(1 - np.abs(B/Bm))

############### PACKAGE INFO #############################
__version__ = '0.2.0'
__author__ = 'Mykhaylo Shumko'
__contact__ = 'msshumko@gmail.com'
__license__ = """Copyright 2017, Mykhaylo Shumko
    
IRBEM wrapper class for Python. Source code credit goes to the 
IRBEM-LIB development team.

***************************************************************************
IRBEM-LIB is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

IRBEM-LIB is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with IRBEM-LIB.  If not, see <http://www.gnu.org/licenses/>.
"""
