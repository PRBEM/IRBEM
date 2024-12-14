import unittest
import datetime
import dateutil.parser
import numpy as np

# Try to import pandas and test it.
pandas_imported = False
try:
    import pandas as pd
    pandas_imported = True
except ModuleNotFoundError as err:
    if str(err) == "No module named 'pandas'":
        pass
    else:
        raise

import IRBEM

class TestIRBEM(unittest.TestCase):
    """
    This test suite runs most of the wrapped IRBEM.MagFields functions
    and checks that the outputs are approximately equal.
    """
    def setUp(self):
        self.model = IRBEM.MagFields(options=[0,0,0,0,0], verbose=False, kext='T89')
        self.dipol_model = IRBEM.MagFields(options=[0,0,5,0,5], verbose=False, kext=0)
        # Create four sets of model inputs: one set of input values, 
        # array of input values, one input value with a string 
        # datetime object, and array of inputs including a 
        # pandas timestamp (if imported)
        self.X, self.maginput = get_dummy_model_inputs(
            n=1, datetime_obj=True, maginput=True
            )
        self.X_array, self.maginput_array = get_dummy_model_inputs(
            n=3, datetime_obj=True, maginput=True
            )
        self.X_time_str, _ = get_dummy_model_inputs(
            n=1, datetime_obj=False, maginput=True
            )
        if pandas_imported:
            self.X_array_pd = self.X_array.copy()
            self.X_array_pd['dateTime'] = pd.to_datetime(self.X_array_pd['dateTime'])

        self.l_star_true_dict = {
                    'Lm': [3.5597242229067536], 'MLT': [],
                    'blocal': [42271.43059990003], 'bmin': [626.2258295723121],
                    'Lstar': [-1e+31], 'xj': [7.020585390925573]
                    }
        return

    def test_lstar_datetime_obj(self):
        """
        Test lstar with one input with and without datetime arrays.
        """
        # datetime time object as 'dateTime'
        self.model.make_lstar(self.X, self.maginput)
        self.assertAlmostEqualDict(self.model.make_lstar_output, self.l_star_true_dict)
        return

    def test_lstar_datetime_str(self):
        """
        Test string time as 'dateTime'
        """
        self.model.make_lstar(self.X_time_str, self.maginput)
        self.assertAlmostEqualDict(self.model.make_lstar_output, self.l_star_true_dict)
        return

    def test_lstar_time_str(self):
        """
        Test string time as a 'Time' column
        """
        X_time = self.X_time_str.copy()
        X_time.pop('dateTime', None)
        X_time['Time'] = self.X_time_str['dateTime']
        self.model.make_lstar(X_time, self.maginput)
        self.assertAlmostEqualDict(self.model.make_lstar_output, self.l_star_true_dict)
        return

    def test_lstar_array(self):
        """
        Test lstar with array inputs
        """
        self.model.make_lstar(self.X_array, self.maginput_array)
        array_true_dict = {'Lm': [3.5597242229067536, 3.5597242229067536, 3.5597242229067536],
                    'MLT': [10.170297893176182, 10.170297893176182, 10.170297893176182],
                    'blocal': [42271.43059990003, 42271.43059990003, 42271.43059990003],
                    'bmin': [626.2258295723121, 626.2258295723121, 626.2258295723121],
                    'Lstar': [-1e+31, -1e+31, -1e+31], 
                    'xj': [7.020585390925573, 7.020585390925573, 7.020585390925573]}
        self.assertAlmostEqualDict(self.model.make_lstar_output, array_true_dict)
        return

    def test_lstar_large_array(self):
        """
        Test lstar with array inputs that are longer than NTIME_MAX and 
        verify that the wrapper returns a ValueError.
        """
        n = self.model.NTIME_MAX.value + 1

        X_huge = {key:n*[value] for key, value in self.X.items()}
        maginput_huge = {key:n*[value] for key, value in self.maginput.items()}
        
        with self.assertRaises(ValueError):
            self.model.make_lstar(X_huge, maginput_huge)
        return

    def test_footPoint(self):
        """
        Test the footpoint coodinate function.
        """
        foot_point_true_dict = {
            'XFOOT': [99.99412846343064, 61.113869939535036, 50.55633537632344],
            'BFOOT': [-25644.012241653385, -25370.689449132995, -38649.994779664776],
            'BFOOTMAG': [52868.793663583165, -9999.0, -9999.0]
            }
        stopAlt = 100
        hemiFlag = 0
        self.model.find_foot_point(self.X, self.maginput, stopAlt, hemiFlag)
        self.assertAlmostEqualDict(self.model.find_foot_point_output, foot_point_true_dict)
        return

    def test_get_field_multi(self):
        """
        Test the get_field_multi function with array inputs.
        """
        get_field_multi_true_dict = {
                                    'BxGEO': [-21079.764883133903, -21079.764883133903, -21079.764883133903],
                                    'ByGEO': [-21504.21460705096, -21504.21460705096, -21504.21460705096],
                                    'BzGEO': [-29666.24532305791, -29666.24532305791, -29666.24532305791],
                                    'Bl': [42271.43059990003, 42271.43059990003, 42271.43059990003]
                                    }
        self.model.get_field_multi(self.X_array, self.maginput_array)
        # Convert numpy arrays to lists for the comparison.
        self.model.get_field_multi_output = {key:list(value) for key, value 
                                    in self.model.get_field_multi_output.items()}
        self.assertAlmostEqualDict(self.model.get_field_multi_output, 
                                    get_field_multi_true_dict)
        return

    def test_find_mirror_point(self):
        """
        Test find_mirror_point for locally-mirroring electrons.
        """
        find_mirror_point_true_dict = {'blocal': 42271.43059990003, 'bmin': 42271.43059990003,
                                        'POSIT': [0.35282136776620165, 0.4204761325793738, 0.9448914452448274]}
        self.model.find_mirror_point(self.X, self.maginput, 90)
        self.assertAlmostEqualDict(self.model.find_mirror_point_output, 
                                    find_mirror_point_true_dict)
        return

    def test_find_magequator(self):
        """
        Tests the find_magequator function.
        """
        find_magequator_true_dict = {'bmin': 626.2258295723121, 'XGEO': [2.1962220856733894, 2.8360222891612192, 0.3472455620354017]}
        self.model.find_magequator(self.X, self.maginput)
        # Convert to list so it can be compared
        self.model.find_magequator_output['XGEO'] = list(self.model.find_magequator_output['XGEO'])
        self.assertAlmostEqualDict(self.model.find_magequator_output, find_magequator_true_dict)
        return

    def test_get_mlt(self):
        """
        Tests the get_mlt IRBEM function. 
        """
        input_dict = {'dateTime':'2015-02-02T06:12:43',
                    'x1':2.195517156287977,
                    'x2':2.834061428571752,
                    'x3':0.34759070278576953}
        true_MLT = 9.56999052595853
        self.model.get_mlt(input_dict)
        self.assertAlmostEqual(self.model.get_mlt_output, true_MLT)
        return
    
    def test_drift_shell(self):
        """
        Tests the drift_shell IRBEM function.
        """
        res = self.dipol_model.drift_shell(self.X, self.maginput)
        Lm = res['Lm']
        self.assertAlmostEqual(Lm, 4.326679, 2)
        L_posit = self._compute_dipole_L_shell(res['POSIT'])
        self.assertLessEqual(np.nanmax(np.abs(L_posit-Lm))/Lm, 1e-2)

    def test_drift_bounce_orbit(self):
        """
        Tests the drift_bounce_orbit IRBEM function.
        """
        res = self.dipol_model.drift_bounce_orbit(self.X, self.maginput)
        Lm = res['Lm']
        self.assertAlmostEqual(Lm, 4.326679, 2)
        alt = self.X['x1']
        self.assertLessEqual((res['hmin']-alt)/alt, 1e-2)
        L_posit = self._compute_dipole_L_shell(res['POSIT'])
        self.assertLessEqual(np.nanmax(np.abs(L_posit-Lm))/Lm, 1e-2)

    @staticmethod
    def _compute_dipole_L_shell(posit):
        """
        Compute the dipole L-shell for each point in coordinate list.
        """
        x = posit[...,0]
        y = posit[...,1]
        z = posit[...,2]
        r = np.sqrt(x**2+y**2+z**2)
        theta = np.arctan2(np.sqrt(x**2+y**2),z)
        return r/np.sin(theta)**2
        
    def assertAlmostEqualDict(self, A, B):
        """
        Wrapper for unittests assertAlmostEqual that compares each value in 
        each key between dicts A and B.
        """
        # Loop over the dict A keys
        for key, values in A.items():
            if not hasattr(values, '__len__'):
                # If this key contains one value then compare it now:
                self.assertAlmostEqual(values, B[key])
            else:
                # Otherwise loop over each array item in the dicts A and B key.
                for value_A, value_B in zip(values, B[key]):
                    try:
                        self.assertAlmostEqual(value_A, value_B)
                    except:
                        print('\nDictionary unit test failed on the ', key, 'key')
                        print('Dict A and B values:', value_A, value_B, '\n\n')
                        raise
        return


def get_dummy_model_inputs(n=1, datetime_obj=True, maginput=False):
    """
    Helper function to get model parameter dictionaries X and maginput
    """
    X = {}
    if n==1:
        X['x1'] = 600 # km
        X['x2'] = 60 # lat
        X['x3'] = 50 # lon
        X['dateTime'] = '2015-02-02T06:12:43'
    elif n > 1:
        X['x1'] = n*[600] # km
        X['x2'] = n*[60] # lat
        X['x3'] = n*[50] # lon
        X['dateTime'] = n*['2015-02-02T06:12:43']
    else:
        raise ValueError(f'n must be greater or equal to 1. n = {n}')

    if datetime_obj:
        if hasattr(X['x1'], '__len__'):
            X['dateTime'] = [dateutil.parser.parse(t) for t in X['dateTime']]
        else:
            X['dateTime'] = dateutil.parser.parse(X['dateTime'])

    if maginput is False:
        maginput = None
    else:
        if n == 1:
            maginput = {'Kp':40.0}
        elif n > 1:
            maginput = {'Kp':n*[40.0]}
        else:
            raise ValueError(f'n must be greater or equal to 1. n = {n}')
    return X, maginput

if __name__ == '__main__':
    unittest.main(verbosity=2, exit=False)
