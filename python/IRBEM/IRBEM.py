__author__ = 'Mykhaylo Shumko'
__last_modified__ = '2022-06-16'
__credit__ = 'IRBEM-LIB development team'

"""
Copyright 2022, Mykhaylo Shumko
    
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

import os
import sys
import copy
import pathlib
import ctypes
import shutil
import datetime
import dateutil.parser
import warnings

import numpy as np
import scipy.interpolate
import scipy.optimize

try:
    import pandas as pd
    pandas_imported = True
except ModuleNotFoundError as err:
    if str(err) == "No module named 'pandas'":
        pandas_imported = False
    else:
        raise

# Physical constants
Re = 6371 #km
c = 3.0E8 # m/s

# External magnetic field model look up table.
extModels = ['None', 'MF75', 'TS87', 'TL87', 'T89', 'OPQ77', 'OPD88', 'T96', 
    'OM97', 'T01', 'T01S', 'T04', 'A00', 'T07', 'MT']

class MagFields:
    """
    Wrappers for IRBEM's magnetic field functions. 
        
    Functions wrapped and tested:
    make_lstar()
    drift_shell()
    find_mirror_point()   
    find_foot_point()
    trace_field_line()
    find_magequator()
    get_field_multi()
    get_mlt()
    
    Functions wrapped and not tested:
    None at this time
    
    Special functions not in normal IRBEM (no online documentation yet):
    bounce_period()
    mirror_point_altitude()
    
    Please contact me at msshumko at gmail.com if you have questions/comments
    or you would like me to wrap a particular function.
    """
    def __init__(self, **kwargs):
        """  
        When initializing the IRBEM instance, you can provide the path kwarg that 
        specifies the location of the compiled FORTRAN shared object (.so or .dll) 
        file, otherwise, it will search for the shared object file in the top-level
        IRBEM directory.

        Python wrapper error value is -9999 (IRBEM-Lib's Fortan error value is -1E31).

        Parameters
        ----------
        path: str or pathlib.Path
            An optional path to the IRBEM shared object (.so or .dll). If unspecified, it
            it will search for the shared object file in the top-level IRBEM directory.
        options: list
            array(5) of long integer to set some control options on computed values. See the
            HTML documentation for more information
        kext: str
            The external magnetic field model, defaults to OPQ77.
        sysaxes: str 
            Set the input coordinate system. By default set to GDZ (alt, lat, long). 
        verbose: bool
            Prints a statement prior to running each function. Usefull for debugging in 
            case Python quietly crashes (likely a wrapper or a Fortran issue).
        """
        self.irbem_obj_path = kwargs.get('path', None)
        self.TMI = kwargs.get('verbose', False)
        
        self.path, self._irbem_obj = _load_shared_object(self.irbem_obj_path)
        
        # global model parameters, default is OPQ77 model with GDZ coordinate
        # system. If kext is a string, find the corresponding integer value.
        kext = kwargs.get('kext', 5)
        if isinstance(kext, str):
            try:
                self.kext = ctypes.c_int(extModels.index(kext))
            except ValueError as err:
                raise ValueError("Incorrect external model selected. Valid models are 'None', 'MF75',",
                    "'TS87', 'TL87', 'T89', 'OPQ77', 'OPD88', 'T96', 'OM97'",
                    "'T01', 'T04', 'A00'") from err
        else:
            self.kext = ctypes.c_int(kext)
        
        self.sysaxes = ctypes.c_int(kwargs.get('sysaxes', 0))
        
        # If options are not supplied, assume they are all 0's.
        optionsType =  ctypes.c_int * 5
        if 'options' in kwargs:
            self.options = optionsType()
            for i in range(5):
                self.options[i] = kwargs['options'][i]
        else:
            self.options = optionsType(0,0,0,0,0)
            
        # Get the NTIME_MAX value
        self.NTIME_MAX = ctypes.c_int(-1)
        self._irbem_obj.get_irbem_ntime_max1_(ctypes.byref(self.NTIME_MAX))
        return
        
    def make_lstar(self, X, maginput):
        """
        This function allows one to compute magnetic coordinate at any s/c position, 
        i.e. L, L*, Blocal/Bmirror, Bequator. A set of internal/external field can be selected.

        Parameters
        ----------
        X: dict
            A dictionary that specifies the input time and location. The `time` key can be a
            ISO-formatted time string, or a `datetime.datetime` or `pd.TimeStamp` objects. 
            The three location keys: `x1`, `x2`, and `x3` specify the location in the `sysaxes`.
        maginput: dict
            The magnetic field input dictionary. See the online documentation for the valid
            keys and the corresponding models.

        Returns
        -------
        dict
            Contains keys Lm, MLT, blocal, bmin, LStar, and xj.
        """
        # Convert the satellite time and position into c objects.
        ntime, iyear, idoy, ut, x1, x2, x3 = self._prepTimeLocArray(X)       

        # Convert the model parameters into c objects.     
        maginput = self._prepMagInput(maginput)
                
        # Model outputs
        doubleArrType = ctypes.c_double * ntime.value
        lm, lstar, blocal, bmin, xj, mlt = [doubleArrType() for i in range(6)]
        
        if self.TMI: print("Running IRBEM-LIB make_lstar")

        self._irbem_obj.make_lstar1_(ctypes.byref(ntime), ctypes.byref(self.kext), 
                ctypes.byref(self.options), ctypes.byref(self.sysaxes), ctypes.byref(iyear),
                ctypes.byref(idoy), ctypes.byref(ut), ctypes.byref(x1), 
                ctypes.byref(x2), ctypes.byref(x3), ctypes.byref(maginput), 
                ctypes.byref(lm), ctypes.byref(lstar), ctypes.byref(blocal),
                ctypes.byref(bmin), ctypes.byref(xj), ctypes.byref(mlt))
        self.make_lstar_output = {'Lm':lm[:], 'MLT':mlt[:], 'blocal':blocal[:],
            'bmin':bmin[:], 'Lstar':lstar[:], 'xj':xj[:]}  
        return self.make_lstar_output
        
    def drift_shell(self, X, maginput):
        """
        This function traces a full drift shell for particles that have their 
        mirror point at the input location.  The output is a full array of positions 
        of the drift shell, usefull for plotting and visualization.

        Parameters
        ----------
        X: dict
            A dictionary that specifies the input time and location. The `time` key can be a
            ISO-formatted time string, or a `datetime.datetime` or `pd.TimeStamp` objects. 
            The three location keys: `x1`, `x2`, and `x3` specify the location in the `sysaxes`.
        maginput: dict
            The magnetic field input dictionary. See the online documentation for the valid
            keys and the corresponding models.

        Returns
        -------
        dict
            Contains keys Lm, Lstar or Φ, Blocal, Bmin, XJ, POSIT, Nposit 
            
            Posit structure: 1st element: x, y, z GEO coord, 2nd element: points along field 
            line, 3rd element: number of field lines. Nposit structure: long integer array 
            (48) providing the number of points along the field line for each field line 
            traced in 2nd element of POSIT max 1000.
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

        self._irbem_obj.drift_shell1_(ctypes.byref(self.kext), ctypes.byref(self.options),\
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
        raise NotImplementedError()
        return
    
    def find_mirror_point(self, X, maginput, alpha):
        """
        Find the magnitude and location of the mirror point along a field 
        line traced from any given location and local pitch-angle.

        Parameters
        ----------
        X: dict
            A dictionary that specifies the input time and location. The `time` key can be a
            ISO-formatted time string, or a `datetime.datetime` or `pd.TimeStamp` objects. 
            The three location keys: `x1`, `x2`, and `x3` specify the location in the `sysaxes`.
        maginput: dict
            The magnetic field input dictionary. See the online documentation for the valid
            keys and the corresponding models.
        alpha: float
            The local pitch angle in degrees.

        Returns
        -------
        dict
            A dictionary with "blocal" and "bmin" scalars, and "POSIT" that contains the 
            GEO coordinates of the mirror point.
        """
        a = ctypes.c_double(alpha)
        
        # Prep the magnetic field model inputs and samping spacetime location.
        self._prepMagInput(maginput)
        iyear, idoy, ut, x1, x2, x3 = self._prepTimeLoc(X)
        
        blocal, bmin = [ctypes.c_double(-9999) for i in range(2)]
        positType = (3 * ctypes.c_double)
        posit = positType()

        if self.TMI: print("Running IRBEM-LIB mirror_point")
            
        self._irbem_obj.find_mirror_point1_(ctypes.byref(self.kext), \
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
        Find the footprint of a field line that passes throgh location X in
        a given hemisphere.

        Parameters
        ----------
        X: dict
            A dictionary that specifies the input time and location. The `time` key can be a
            ISO-formatted time string, or a `datetime.datetime` or `pd.TimeStamp` objects. 
            The three location keys: `x1`, `x2`, and `x3` specify the location in the `sysaxes`.
        maginput: dict
            The magnetic field input dictionary. See the online documentation for the valid
            keys and the corresponding models.
        stopAlt: float
            The footprint altitude above Earth's surface, in kilometers.
        hemiFlag: int
            Determines what hemisphere to find the footprint. 
            - 0    = same magnetic hemisphere as starting point
            - +1   = northern magnetic hemisphere
            - -1   = southern magnetic hemisphere
            - +2   = opposite magnetic hemisphere as starting point  

        Returns
        -------
        dict:
            A dictionary with three keys:
            - "XFOOT" the footprint location in GDZ coordinates
            - "BFOOT" the magnetic field vector at the footprint, in GEO coordinates, and in 
            unit of nT.
            - "BFOOTMAG" the footprint magnetic field magnitude in nT units.
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
            
        self._irbem_obj.find_foot_point1_(ctypes.byref(self.kext), \
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
        
    def trace_field_line(self, X, maginput, R0=1):
        """
        Trace a full field line which crosses the input position.

        Parameters
        ----------
        X: dict
            A dictionary that specifies the input time and location. The `time` key can be a
            ISO-formatted time string, or a `datetime.datetime` or `pd.TimeStamp` objects. 
            The three location keys: `x1`, `x2`, and `x3` specify the location in the `sysaxes`.
        maginput: dict
            The magnetic field input dictionary. See the online documentation for the valid
            keys and the corresponding models.
        R0: float
            The radius, in units of RE, of the reference surface (i.e. altitude) between which 
            the line is traced.

        Returns
        -------
        dict:
            A dictionary with six keys:
            - "POSIT" the field line locations in GEO coordinates with shape (3, 3000).
            - "Nposit" the number of points along the field line for each field line traced.
            - "lm" is the McIlwain L shell.
            - "blocal" the magnitude of the local magnetic field.
            - "bmin" the magnitude of the minimum magnetic field.
            - "xj" I, related to second adiabatic invariant.
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
        
        self._irbem_obj.trace_field_line2_1_(ctypes.byref(self.kext), \
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
        Find the coordinates of the magnetic equator from tracing the magntic 
        field line from the input location.

        Parameters
        ----------
        X: dict
            A dictionary that specifies the input time and location. The `time` key can be a
            ISO-formatted time string, or a `datetime.datetime` or `pd.TimeStamp` objects. 
            The three location keys: `x1`, `x2`, and `x3` specify the location in the `sysaxes`.
        maginput: dict
            The magnetic field input dictionary. See the online documentation for the valid
            keys and the corresponding models.

        Returns
        -------
        dict:
            A dictionary with two keys:
            - "bmin" the magntitude of the magnetic field at the equator.
            - "XGEO" the location of the magnetic equator in GEO coordinates.
        """
        # Prep the magnetic field model inputs and samping spacetime location.
        self._prepMagInput(maginput)
        iyear, idoy, ut, x1, x2, x3 = self._prepTimeLoc(X)
        
        # Define outputs
        bmin = ctypes.c_double(-9999) 
        XGEOType = (ctypes.c_double * 3)
        XGEO = XGEOType(-9999, -9999, -9999)
        
        if self.TMI: print('Running IRBEM find_magequator')

        self._irbem_obj.find_magequator1_(ctypes.byref(self.kext), \
                ctypes.byref(self.options), ctypes.byref(self.sysaxes), \
                ctypes.byref(iyear), ctypes.byref(idoy), ctypes.byref(ut), \
                ctypes.byref(x1), ctypes.byref(x2), ctypes.byref(x3), \
                ctypes.byref(self.maginput), ctypes.byref(bmin), \
                ctypes.byref(XGEO))
        self.find_magequator_output = {'bmin':bmin.value, 'XGEO':np.array(XGEO)}
        return self.find_magequator_output

    def get_field_multi(self, X, maginput):
        """
        This function computes the GEO vector of the magnetic field at input 
        location for a set of internal/external magnetic field to be selected. 

        Parameters
        ----------
        X : dict
            The dictionary specifying the time and location.  
        maginput : dict
            The magnetic field inpit parameter dictionary.

        Returns
        -------
        A dictionary with the following key-value pairs:
        BxGEO: array
            X component of the magnetic field (nT)
        ByGEO: array
            Y component of the magnetic field (nT)
        BzGEO: array
            Z component of the magnetic field (nT)
        Bl: array
            Magnitude of magnetic field (nT)
        
        Example
        -------
        model = IRBEM.MagFields(options=[0,0,0,0,0], verbose=True)
        LLA = {}
        LLA['x1'] = 651
        LLA['x2'] = 63.97
        LLA['x3'] = 15.9
        LLA['dateTime'] = '2015-02-02T06:12:43'
        maginput = {'Kp':40.0} 
        output = model.get_field_multi(LLA, maginput)
        print(output)
        """
        # Prep the time and position variables.
        ntime, iyear, idoy, ut, x1, x2, x3 = self._prepTimeLocArray(X)

        # Prep magnetic field model inputs        
        maginput = self._prepMagInput(maginput)

        # Model output types
        Bl_type = ctypes.c_double * ntime.value
        Bgeo_type = ( (ctypes.c_double * 3) * ntime.value )
        # Model output arrays
        Bgeo = Bgeo_type()
        Bl = Bl_type()
        
        if self.TMI: print("Running IRBEM-LIB get_field_multi")

        self._irbem_obj.get_field_multi_(
                ctypes.byref(ntime), ctypes.byref(self.kext), 
                ctypes.byref(self.options), ctypes.byref(self.sysaxes), 
                ctypes.byref(iyear), ctypes.byref(idoy), ctypes.byref(ut), 
                ctypes.byref(x1), ctypes.byref(x2), ctypes.byref(x3), 
                ctypes.byref(maginput), ctypes.byref(Bgeo), ctypes.byref(Bl)
                )
        Bgeo_np = np.array(Bgeo)
        self.get_field_multi_output = {'BxGEO':Bgeo_np[:,0], 'ByGEO':Bgeo_np[:,1], 
            'BzGEO':Bgeo_np[:,2], 'Bl':np.array(Bl)}
        return self.get_field_multi_output

    def get_mlt(self, X):
        """
        Method to get Magnetic Local Time (MLT) from a Cartesian GEO 
        position and date.

        Parameters
        ----------
        X: dict
            The dictionary specifying the time and location in GEO coordinates. 

        Returns
        -------
        MLT: float
            The MLT value (hours).
        """
        # Inputs
        iyear, idoy, ut, _, _, _ = self._prepTimeLoc(X)
        coordsType =  ctypes.c_double * 3
        geo_coords = coordsType(X['x1'], X['x2'], X['x3'])

        # Model output variable
        MLT = ctypes.c_double(-9999)
        
        if self.TMI: print("Running IRBEM-LIB get_mlt")

        self._irbem_obj.get_mlt1_( 
                ctypes.byref(iyear), ctypes.byref(idoy), ctypes.byref(ut), 
                ctypes.byref(geo_coords), ctypes.byref(MLT)
                )
        self.get_mlt_output = MLT.value
        return self.get_mlt_output

    ### Non-IRBEM methods.
    def bounce_period(self, X, maginput, E, Erest=511, R0=1, alpha=90, interpNum=100000):
        """
        Calculate the bounce period in an arbitary magnetic field model. 
        The default particle is electron, but you can change the Erest 
        parameter to calculate the bounce period for other particles.

        Parameters
        ----------
        X: dict
            A dictionary that specifies the input time and location. The `time` key can be a
            ISO-formatted time string, or a `datetime.datetime` or `pd.TimeStamp` objects. 
            The three location keys: `x1`, `x2`, and `x3` specify the location in the `sysaxes`.
        maginput: dict
            The magnetic field input dictionary. See the online documentation for the valid
            keys and the corresponding models.
        E: float, list, or np.array
            A single or multiple values of particle energy in keV.
        Erest: float
            The particle's rest energy in keV.
        R0: float
            The radius, in units of RE, of the reference surface (i.e. altitude) between which 
            the line is traced.
        alpha: float
            The local pitch angle.
        interpNum: int
            The number of samples to interpolate the magnetic field line.
            100000 is a good balance between speed and accuracy.

        Returns
        -------
        float or np.array
            Bounce period(s) in seconds.    
        """        
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
                 raise ValueError('Mirror point below R0') from err
            else:
                raise
        
        # Resample S to a finer density of points.
        if len(fLine['S']) > interpNum: 
            warnings.warn('Warning: interpolating with less data than IRBEM outputs,'+
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
            self.Tb = np.array([2*np.sum(np.divide(ds[1:-1], vparalel(Ei, fLine['mirrorB'], dB, 
                                              Erest = Erest)[1:-1])) for Ei in E])
        else:
            self.Tb = 2*np.sum(np.divide(ds[1:-1], vparalel(E, fLine['mirrorB'], dB, 
                                             Erest = Erest)[1:-1]))
        return self.Tb
        
    def mirror_point_altitude(self, X, maginput, R0=1):
        """
        Calculate the mirror point of locally mirroring electrons 
        in the opposite hemisphere. Similar to the find_mirror_point()
        method, but it works in the opposite hemisphere.

        Parameters
        ----------
        X: dict
            The dictionary specifying the time and location.  
        maginput: dict
            The magnetic field inpit parameter dictionary.
        R0: float
            The radius, in units of RE, of the reference surface (i.e. altitude) between which 
            the line is traced.
        
        Returns
        -------
        float
            The mirror point altitude in the opposite hemisphere.    
        """        
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
                raise ValueError('Mirror point below R0') from err
            else:
                raise
                        
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
        
    def _prepTimeLoc(self, X):
        """
        Prepares spacetime inputs.

        Parameters
        ----------
        X: dict
            The dictionary specifying the time and location. Keys must be 
            'dateTime', 'x1', 'x2', 'x3'. Other time keys will work, as 
            long as they contain the word 'time' (case insensitive). 
        Returns
        -------
        ctype:
            year
        ctype:
            day of year
        ctype:
            seconds elapsed since midnight
        ctype:
            First cooridnate in sysaxes coordinates
        ctype:
            Second cooridnate in sysaxes coordinates
        ctype:
            Third cooridnate in sysaxes coordinates
        """
        if self.TMI: print('Prepping time and space input variables')

        # Deep copy X so if the single inputs get encapsulated in 
        # an array, it wont be propaged back to the user.
        Xc = copy.deepcopy(X)

        time_key = [key for key in Xc.keys() if 'time' in key.lower()]
        assert len(time_key) == 1, ('None or multiple time keys found in '
                                    f'dictionary input \n {Xc}')
        time_key = time_key[0]

        if isinstance(Xc[time_key], datetime.datetime):
            t = Xc[time_key]
        elif pandas_imported and isinstance(Xc[time_key], pd.Timestamp):
            t = pd.dt.to_pydatetime()
        else:
            t = dateutil.parser.parse(Xc[time_key])
        iyear = ctypes.c_int(t.year)
        idoy = ctypes.c_int(t.timetuple().tm_yday)
        ut = ctypes.c_double(3600*t.hour + 60*t.minute + t.second)  # Seconds of day
        x1 = ctypes.c_double(Xc['x1']) 
        x2 = ctypes.c_double(Xc['x2'])
        x3 = ctypes.c_double(Xc['x3'])
        if self.TMI: print('Done prepping time and space input variables')
        return iyear, idoy, ut, x1, x2, x3
    
    def _prepTimeLocArray(self, X):
        """
        NAME:  _prepTimeLocArray(self, X)
        USE:   Prepares spacetime inputs used for IRBEM functions accepting
                array inputs.
        INPUT: A dictionary, X, containing the time and sampling location. 
               Input keys must be 'dateTime', 'x1', 'x2', 'x3'. Other time keys
               will work, as long as they contain the word 'time' (case 
               insensitive). 
        AUTHOR: Mykhaylo Shumko
        RETURNS: ctypes variables iyear, idoy, ut, x1, x2, x3.
        MOD:     2020-05-26
        """
        # Deep copy X so if the single inputs get encapsulated in 
        # an array, it wont be propaged back to the user.
        Xc = copy.deepcopy(X)

        # identify the time key.
        time_keys = [key for key in Xc.keys() if 'time' in key.lower()]
        assert len(time_keys) == 1, ('None or multiple time keys found in '
                                    f'dictionary input \n {Xc}')
        time_key = time_keys[0]

        # Check if function arguments are lists or arrays and convert them
        # to numpy arrays if they are not.
        if not isinstance(Xc[time_key], (list, np.ndarray)):
            for key in Xc.keys():
                Xc[key] = np.array([Xc[key]])

        # Check that the input array length does not exceed NTIME_MAX.
        nTimePy = len(Xc[time_key])
        if nTimePy > self.NTIME_MAX.value:
            raise ValueError(f"Input array length {nTimePy} is longer "
                             f"than IRBEM's NTIME_MAX = {self.NTIME_MAX.value}. "
                             f"Use a for loop.")
        ntime = ctypes.c_int(nTimePy)

        # Check that the times are datetime objects, and convert otherwise.
        if isinstance(Xc[time_key][0], datetime.datetime):
            t = Xc[time_key]
        elif pandas_imported and isinstance(Xc[time_key][0], pd.Timestamp):
            t = pd.dt.to_pydatetime()
        else:
            t = [dateutil.parser.parse(t_i) for t_i in Xc[time_key]]

        nTimePy = len(Xc[time_key])
        ntime = ctypes.c_int(nTimePy)
        
        # C arrays are statically defined with the following procedure.
        # There are a few ways of doing this...
        intArrType = ctypes.c_int * nTimePy
        iyear = intArrType()
        idoy = intArrType()
        
        doubleArrType = ctypes.c_double * nTimePy
        ut, x1, x2, x3 = [doubleArrType() for i in range(4)]

        # Now fill the input time and model sampling (s/c location) parameters.
        for dt in range(nTimePy):
            iyear[dt] = t[dt].year
            idoy[dt] = t[dt].timetuple().tm_yday
            ut[dt] = 3600*t[dt].hour + 60*t[dt].minute + t[dt].second
            x1[dt] = Xc['x1'][dt]
            x2[dt] = Xc['x2'][dt] 
            x3[dt] = Xc['x3'][dt]
        return ntime, iyear, idoy, ut, x1, x2, x3

    def _prepMagInput(self, inputDict=None):
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
        if (inputDict is None) or (inputDict == {}):
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
            magInputType = ((ctypes.c_double * 25) * nTimePy)
            self.maginput = magInputType()
            
            # Loop over potential keys.
            for i in range(len(orderedKeys)):
                # Loop over times.
                for dt in range(nTimePy):
                    # For every key provided by user, populate the maginput 
                    # C array.
                    if orderedKeys[i] in list(inputDict.keys()):
                        # maginput(25,ntime_max)
                        self.maginput[dt][i] = inputDict[orderedKeys[i]][dt]
                    else:
                        self.maginput[dt][i] = ctypes.c_double(-9999) 
                        
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
    Wrappers for IRBEM's coordinate transformation functions. 

    When initializing the instance, you can provide the directory 
    'IRBEMdir' and 'IRBEMname' arguments to the class to specify the location 
    of the  compiled FORTRAN shared object (so) file, otherwise, it will 
    search for a .so file in the ./../ directory.
    
    When creating the instance object, you can use the 'options' kwarg to 
    set the options, dafault is 0,0,0,0,0. Kwarg 'kext' sets the external B 
    field as is set to default of 4 (T89c model), and 'sysaxes' kwarg sets the 
    input coordinate system, and is set to GDZ (lat, long, alt). 
    
    verbose keyword, set to False by default, will print too much information 
    (TMI). Usefull for debugging and for knowing too much. Set it to True if
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
        self.irbem_obj_path = kwargs.get('path', None)  
        self.TMI = kwargs.get('verbose', False)
        
        self.path, self._irbem_obj = _load_shared_object(self.irbem_obj_path)
        return 
    
    def coords_transform(self, *args, **kwargs):
        warnings.warn('Coords.coords_transform() is deprecated. Use Coords.transform instead.')
        return self.transform(*args, **kwargs)

    def transform(self, time, pos, sysaxesIn, sysaxesOut):
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
       
        self._irbem_obj.coord_trans_vec1_(ctypes.byref(nTime), ctypes.byref(sysIn),
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
            raise ValueError('Unknown time format. Valid formats: ISO '
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


def _load_shared_object(path=None):
    """
    Searches for and loads a shared object (.so or .dll file). If path is specified
    it doesn't search for the file.
    """
    if path is None:
        if (sys.platform == 'win32') or (sys.platform == 'cygwin'):
            obj_ext = '*.dll'
            loader = ctypes.WinDLL
        else:
            obj_ext = '*.so'
            loader = ctypes.cdll
        matched_object_files = list(pathlib.Path(__file__).parents[2].glob(obj_ext))
        assert len(matched_object_files) == 1, (
            f'{len(matched_object_files)} .so or .dll shared object files found in '
            f'{pathlib.Path(__file__).parents[2]} folder: {matched_object_files}.'
            )
        path = matched_object_files[0]
        
    # Open the shared object file.
    try:
        if (sys.platform == 'win32') or (sys.platform == 'cygwin'):
            # Some versions of ctypes (Python) need to know where msys64 binary 
            # files are located, or ctypes is unable to load the IREBM dll.
            gfortran_path = pathlib.Path(shutil.which('gfortran.exe'))
            os.add_dll_directory(gfortran_path.parent)  # e.g. C:\msys64\mingw64\bin
            _irbem_obj = ctypes.WinDLL(str(path))
        else:
            _irbem_obj = ctypes.CDLL(str(path))
    except OSError as err:
        if 'Try using the full path with constructor syntax.' in str(err):
            raise OSError(f'Could not load the IRBEM shared object file in {path}') from err
        else:
            raise
    return path, _irbem_obj

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