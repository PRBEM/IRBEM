import os, glob
import ctypes
import numpy as np
import datetime
import dateutil.parser

class IRBEM:
    """
    Copyright 2017, Mykhaylo Shumko
    
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
    ***************************************************************************
    
    USE
    When initializing the instance, you can provide the directory 
    'IRBEMdir' and 'IRBEMname' arguments to the class to specify the location 
    of the  compiled FORTRAN shared object (so) file, otherwise, it will 
    search for a .so file in the /sources directory.
    
    When creating the instance object, you can use the 'options' kwarg to 
    set the options, dafault is 0,0,0,0,0. Kwarg 'kext' sets the external B 
    field as is set to default of 4 (T89c model), and 'sysaxes' kwarg sets the 
    input coordinate system, and is set to GDZ (lat, long, alt). 
    
    STATUS_FLAG keyword, set to False by default, prints will print a statement
    letting you know its about to call a function in shared object. This is 
    usefull for debugging if Python crashes without any error messages.
    
    Python wrapper error value is -9999.
    
    TESTING IRBEM:
    Run the functions from IRBEM_tests_and_visalization.py. There may be 
    buffer warnings, but otherwise they should run.
    
    Functions wrapped and tested:
    make_lstar()
    drift_shell()
    find_mirror_point()   
    find_foot_point()
    trace_field_line()
    
    Functions wrapped and not tested:
    None
    
    Please contact me at msshumko at gmail.com if you have questions/comments
    or you would like me to wrap a particular function.
    
    """
    def __init__(self, **kwargs):
        self.compiledIRBEMdir = kwargs.get('IRBEMdir', None)
        self.compiledIRBEMname = kwargs.get('IRBEMname', None)    
        
        if self.compiledIRBEMdir == None and self.compiledIRBEMname == None:
            # Find the .so file in the source directory of IRBEM.
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
        
        # global model parameters, default is T89 model with GDZ coordinate
        # system.
        self.kext = ctypes.c_int(kwargs.get('kext', 4))
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
        
    def make_lstar(self, X, maginput, STATUS_FLAG = False):
        """
        NAME: call_make_lstar(self, X, maginput)
        USE:  Runs make_lstar1() from the IRBEM-LIB library. This function 
              returns McLlwain L, L*, blocal, bmin, xj, and MLT from the 
              position from input location.
        INPUT: X, a dictionary of positions in the specified coordinate  
             system. a 'dateTime' key and values must be provided as well.
        AUTHOR: Mykhaylo Shumko
        RETURNS: McLLwain L, MLT, blocal, bmin, lstar, xj in a dictionary.
        MOD:     2017-01-09
        """
        # Check if function arguments are not lists/arrays. Convert them to 
        # size 1 arrays. This is different than other functions because
        # you can feed an array of positions and times to make_lstar().
        if type(X['dateTime']) != list and type(X['dateTime']) != np.ndarray:
            X['dateTime'] = np.array([X['dateTime']])
            X['x1'] = np.array([X['x1']])
            X['x2'] = np.array([X['x2']])
            X['x3'] = np.array([X['x3']])

        nTimePy = len(X['dateTime'])
        ntime = ctypes.c_int(nTimePy)        
        
        # Convert times to datetime objects.
        
        if type(X['dateTime'][0]) is datetime.datetime:
            t = X['dateTime']
        else:
            t = nTimePy * [None]
            for i in range(nTimePy):
                t[i] = dateutil.parser.parse(X['dateTime'][i])
            
        nTimePy = len(X['dateTime'])
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
            x1[dt] = X['x1'][dt]
            x2[dt] = X['x2'][dt] 
            x3[dt] = X['x3'][dt]
                
        # Model outputs
        lm, lstar, blocal, bmin, xj, mlt = [doubleArrType() for i in range(6)]
        
        if STATUS_FLAG:
            print("Running IRBEM-LIB make_lstar")
        self.irbem.make_lstar1_(ctypes.byref(ntime), ctypes.byref(self.kext), \
                ctypes.byref(self.options), ctypes.byref(self.sysaxes), ctypes.byref(iyear),\
                ctypes.byref(idoy), ctypes.byref(ut), ctypes.byref(x1), \
                ctypes.byref(x2), ctypes.byref(x3), ctypes.byref(maginput), \
                ctypes.byref(lm), ctypes.byref(lstar), ctypes.byref(blocal), \
                ctypes.byref(bmin), ctypes.byref(xj), ctypes.byref(mlt));
        self.lstar1_output = {'Lm':lm[:], 'MLT':mlt[:], 'blocal':blocal[:], \
            'bmin':bmin[:], 'lstar':lstar[:], 'xj':xj[:]}    
        return self.lstar1_output
        
    def drift_shell(self, X, maginput, STATUS_FLAG = False):
        """
        NAME:  drift_shell(self, X, maginput, STATUS_FLAG = False)
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
        
        if STATUS_FLAG:
            print("Running IRBEM-LIB drift_shell")
        self.irbem.drift_shell1_(ctypes.byref(self.kext), ctypes.byref(self.options),\
                ctypes.byref(self.sysaxes), ctypes.byref(iyear),\
                ctypes.byref(idoy), ctypes.byref(ut), ctypes.byref(x1), \
                ctypes.byref(x2), ctypes.byref(x3), ctypes.byref(self.maginput), \
                ctypes.byref(lm), ctypes.byref(lstar), ctypes.byref(blocal), \
                ctypes.byref(bmin), ctypes.byref(xj), ctypes.byref(posit), \
                ctypes.byref(nposit));
        # Format the output into a dictionary, and convert ctypes arrays into
        # native Python format.
        self.drift_shell_output = {'Lm':lm.value, 'blocal':np.array(blocal), \
            'bmin':bmin.value, 'lstar':lstar.value, 'xj':xj.value, 'POSIT':np.array(posit), \
            'Nposit':np.array(nposit)} 
        return self.drift_shell_output
            
            
    def drift_bounce_orbit(self):
        print('Under construction and not tested!')
        return
    
    def find_mirror_point(self, X, maginput, alpha, STATUS_FLAG = False):
        """
        NAME: find_mirror_point(self, X, maginput, alpha, STATUS_FLAG = False)
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

        if STATUS_FLAG:
            print("Running IRBEM-LIB mirror_point")
            
        self.irbem.find_mirror_point1_(ctypes.byref(self.kext), \
                ctypes.byref(self.options), ctypes.byref(self.sysaxes), \
                ctypes.byref(iyear), ctypes.byref(idoy), ctypes.byref(ut), \
                ctypes.byref(x1), ctypes.byref(x2), ctypes.byref(x3), \
                ctypes.byref(a), ctypes.byref(self.maginput), \
                ctypes.byref(blocal), ctypes.byref(bmin), ctypes.byref(posit))     
                
        self.mirror_point_output = {'blocal':blocal.value, 'bmin':bmin.value, \
                'POSIT':posit[:]}
        return self.mirror_point_output
    
    def find_foot_point(self, X, maginput, stopAlt, hemiFlag, STATUS_FLAG = False):
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
        
        if STATUS_FLAG:
            print("Running IRBEM-LIB find_foot_point")
            
        self.irbem.find_foot_point1_(ctypes.byref(self.kext), \
                ctypes.byref(self.options),\
                ctypes.byref(self.sysaxes), ctypes.byref(iyear),\
                ctypes.byref(idoy), ctypes.byref(ut), ctypes.byref(x1), \
                ctypes.byref(x2), ctypes.byref(x3), ctypes.byref(stop_alt), \
                ctypes.byref(hemi_flag), ctypes.byref(self.maginput), \
                ctypes.byref(XFOOT), ctypes.byref(BFOOT), \
                ctypes.byref(BFOOTMAG))
        self.foot_point_output = {'XFOOT':XFOOT[:], 'BFOOT':BFOOT[:], \
        'BFOOTMAG':BFOOTMAG[:]}
        return self.foot_point_output
        
    def trace_field_line(self, X, maginput, R0 = 1, STATUS_FLAG = False):
        """
        NAME: trace_field_line(self, X, maginput, R0 = 1, STATUS_FLAG = False)
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
    
        if STATUS_FLAG:
            print("Running IRBEM-LIB trace_field_line. Python may " + \
            "temporarily stop responding")
        
        self.irbem.trace_field_line2_1_(ctypes.byref(self.kext), \
                ctypes.byref(self.options),\
                ctypes.byref(self.sysaxes), ctypes.byref(iyear),\
                ctypes.byref(idoy), ctypes.byref(ut), ctypes.byref(x1), \
                ctypes.byref(x2), ctypes.byref(x3), ctypes.byref(self.maginput), \
                ctypes.byref(R0), ctypes.byref(lm), ctypes.byref(blocal), \
                ctypes.byref(bmin), ctypes.byref(xj), ctypes.byref(posit), \
                ctypes.byref(Nposit))
                
        self.trace_field_line2_output = {'POSIT':np.array(posit), \
        "Nposit":Nposit.value, 'lm':lm.value, 'blocal':blocal, \
        'bmin':bmin.value, 'xj':xj.value}        
        return self.trace_field_line2_output
        
    def find_magequator(self, X, maginput, STATUS_FLAG = False):
        """
        NAME: find_magequator(self, X, maginput, STATUS_FLAG = False)
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
        
        if STATUS_FLAG:
            print('Running IRBEM find_magequator')
        self.irbem.find_magequator1_(ctypes.byref(self.kext), \
                ctypes.byref(self.options), ctypes.byref(self.sysaxes), \
                ctypes.byref(iyear), ctypes.byref(idoy), ctypes.byref(ut), \
                ctypes.byref(x1), ctypes.byref(x2), ctypes.byref(x3), \
                ctypes.byref(self.maginput), ctypes.byref(bmin), \
                ctypes.byref(XGEO))
        self.find_magequator_output = {'bmin':bmin.value, 'XGEO':np.array(XGEO)}
        return self.find_magequator_output
        
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
            
        # If the model inputs are arrays
        if type(inputDict[list(inputDict.keys())[0]]) == np.ndarray or\
        type(inputDict[list(inputDict.keys())[0]]) == list:
            nTimePy = len(list(inputDict.keys())[0])
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
        elif type(inputDict[list(inputDict.keys())[0]]) == int or \
        type(inputDict[list(inputDict.keys())[0]]) == float:
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
        return self.maginput
        
    def _prepTimeLoc(self, X):
        """
        NAME:  _prepTimeLoc(self, X)
        USE:   Prepares spacetime outputs.
        INPUT: A dictionary, X containing the time and sampling location. 
               Input keys must be 'dateTime', 'x1', 'x2', 'x3'.
        AUTHOR: Mykhaylo Shumko
        RETURNS: ctypes variables iyear, idoy, ut, x1, x2, x3.
        MOD:     2017-01-12
        """
        if type(X['dateTime']) is datetime.datetime:
            t = X['dateTime']
        else:
            t = dateutil.parser.parse(X['dateTime'])
        iyear = ctypes.c_int(t.year)
        idoy = ctypes.c_int(t.timetuple().tm_yday)
        ut = ctypes.c_double(3600*t.hour + 60*t.minute + t.second)
        x1 = ctypes.c_double(X['x1']) 
        x2 = ctypes.c_double(X['x2'])
        x3 = ctypes.c_double(X['x3'])
        return iyear, idoy, ut, x1, x2, x3