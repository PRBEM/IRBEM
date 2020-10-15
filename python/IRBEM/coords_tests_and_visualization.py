"""
These scripts test the coordinate transformations in IRBEM
"""
import IRBEM
import numpy as np
from datetime import datetime

def test_conversions():
    """
    
    """
    cObj = IRBEM.Coords()
    
    time = datetime(1996, 8, 28, 16, 46)
    pos = np.array([6.9027400, -1.6362400, 1.9166900])
    print('Single entry', cObj.coords_transform(time, pos, 'GEO', 'GEO'))
    
    time = [datetime(1996, 8, 28, 16, 46), datetime(2000, 8, 29, 2, 46)]
    pos = np.array([[6.9027400, -1.6362400, 1.9166900], 
        [6.9027400, -1.6362400, 1.9166900]])
    print('Multi entry', cObj.coords_transform(time, pos, 'GEO', 'MAG'))
    return
    
if __name__ == '__main__':
    test_conversions()
    
    
    
