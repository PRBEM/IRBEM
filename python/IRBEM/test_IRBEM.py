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
                    'Lm': [3.5579374952779204], 'MLT': [10.169456256499693], 
                    'blocal': [42262.312614335955], 'bmin': [627.2214166228032], 
                    'Lstar': [-1e+31], 'xj': [7.015533298820233]
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
        array_true_dict = {'Lm': [3.5579374952779204, 3.5579374952779204, 3.5579374952779204], 
                    'MLT': [10.169456256499693, 10.169456256499693, 10.169456256499693], 
                    'blocal': [42262.312614335955, 42262.312614335955, 42262.312614335955], 
                    'bmin': [627.2214166228032, 627.2214166228032, 627.2214166228032], 
                    'Lstar': [-1e+31, -1e+31, -1e+31], 
                    'xj': [7.015533298820233, 7.015533298820233, 7.015533298820233]}
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
            'XFOOT': [99.07260167773684, 61.1161410800498, 50.557493433938184], 
            'BFOOT': [-25647.999959167002, -25374.352958200077, -38659.636791258556], 
            'BFOOTMAG': [52879.534857870865, -9999.0, -9999.0]
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
                                    'BxGEO': [-21076.63920463125, -21076.63920463125, -21076.63920463125], 
                                    'ByGEO': [-21501.116789645264, -21501.116789645264, -21501.116789645264], 
                                    'BzGEO': [-29657.71946977204, -29657.71946977204, -29657.71946977204], 
                                    'Bl': [42262.312614335955, 42262.312614335955, 42262.312614335955]
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
        find_mirror_point_true_dict = {'blocal': 42262.312614335955, 'bmin': 42262.312614335955, 
                                        'POSIT': [0.35282136776620165, 0.4204761325793738, 0.9448914452448274]}
        self.model.find_mirror_point(self.X, self.maginput, 90)
        self.assertAlmostEqualDict(self.model.find_mirror_point_output, 
                                    find_mirror_point_true_dict)
        return

    def test_find_magequator(self):
        """
        Tests the find_magequator function.
        """
        find_magequator_true_dict = {'bmin': 627.2214166228032, 'XGEO': [2.195517156287977, 2.834061428571752, 0.34759070278576953]}
        self.model.find_magequator(self.X, self.maginput)
        # Convert to list so it can be compared
        self.model.find_magequator_output['XGEO'] = list(self.model.find_magequator_output['XGEO'])
        self.assertAlmostEqualDict(self.model.find_magequator_output, find_magequator_true_dict)
        return
        

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