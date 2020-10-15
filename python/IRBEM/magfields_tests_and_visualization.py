# -*- coding: utf-8 -*-
"""
Created on Fri Jan  6 19:26:04 2017

@author: mike
"""

# IRBEM test and visualization functions.
#from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pylab as plt
import matplotlib.gridspec as gridspec
import numpy as np
import datetime
#from mpl_toolkits.mplot3d import Axes3D
from IRBEM import MagFields

# A few test and visualization scripts.
def testLStarOutput(test_datetime = True):
    """
    This test function will test is the make_lstar1() function works correctly.
    If you run this, the output should be the follwing. 
    
    {'MLT': [8.34044753112316], 'xj': [9.898414822276834], 'lstar': [-1e+31],
    'Lm': [4.631806704496794], 'bmin': [268.5087756309121], 
    'blocal': [39730.828875776126]}
    """
    model = MagFields(options = [0,0,0,0,0], verbose = True)
    LLA = {}
    LLA['x1'] = [651, 651]
    LLA['x2'] = [63, 61]
    LLA['x3'] = [15.9, 1]
    if test_datetime:
        LLA['dateTime'] = [datetime.datetime(2015, 2, 2, 6, 12,43), 
        datetime.datetime(2015, 2, 2, 6,12, 43)]
    else:
        LLA['dateTime'] = ['2015-02-02T06:12:43', '2015-02-02T06:12:43']
    maginput = {'Kp':[40.0, 50]}
    model.make_lstar(LLA, maginput)
    print(model.make_lstar_output)

def footPointTest():
    """
    Test script to find the same hemisphere footprint for some arbitary 
    loccation.
    
    {'XFOOT': [99.15918384268508, 65.18720406063792, 16.115261431962285], 
    'BFOOT': [-30667.04604376155, -7651.837684485317, -39138.97550317413],
    'BFOOTMAG': [50307.82977269011, -9999.0, -9999.0]}
    """
    model = MagFields(options = [0,0,0,0,0], verbose = True)
    LLA = {}
    LLA['x1'] = 651
    LLA['x2'] = 63.97
    LLA['x3'] = 15.9
    LLA['dateTime'] = '2015-02-02T06:12:43'
    maginput = {'Kp':40.0} 
    stopAlt = 100
    hemiFlag = 0
    model.find_foot_point(LLA, maginput, stopAlt, hemiFlag)
    print(model.find_foot_point_output)
    
def testDriftShell(pltDensity = 10):
    """
    Test script to generate a drift shell for electrons mirroring at the
    input location. 
    
    You may get a PEP 3118 buffer warning.
    """
    print('Under construction')
    model = MagFields(options = [0,0,0,0,0], verbose = True)
    LLA = {}
    LLA['x1'] = 651
    LLA['x2'] = 34
    LLA['x3'] = 90
    LLA['dateTime'] = '2015-02-02T06:12:43'
    maginput = {'Kp':0.0}
    output = model.drift_shell(LLA, maginput)
    
    # Now plot the drift shell   
    fig = plt.figure()
    ax = fig.add_subplot(111, projection='3d')
    n = 10
    xGEO = -9999*np.ones(n*1000//pltDensity)
    yGEO = -9999*np.ones(n*1000//pltDensity)
    zGEO = -9999*np.ones(n*1000//pltDensity)
    
    for i in range(n):
        xGEO[i*1000//pltDensity:(i+1)*1000//pltDensity] = output['POSIT'][i,::pltDensity,0]
        yGEO[i*1000//pltDensity:(i+1)*1000//pltDensity] = output['POSIT'][i,::pltDensity,1]
        zGEO[i*1000//pltDensity:(i+1)*1000//pltDensity] = output['POSIT'][i,::pltDensity,2]

    ax.scatter(xGEO, yGEO, zGEO)
    
    # Now draw a sphere
    u, v = np.mgrid[0:2*np.pi:40j, 0:np.pi:20j]
    x=np.cos(u)*np.sin(v)
    y=np.sin(u)*np.sin(v)
    z=np.cos(v)
    ax.plot_wireframe(x, y, z, color="k")
    ax.set_ylim([-5, 5])
    ax.set_xlim([-5, 5])
    ax.set_zlim([-5, 5])
    ax.set_xlabel('x GEO')
    ax.set_ylabel('y GEO')
    ax.set_zlabel('z GEO')
    
def test_find_mirror_point():
    """
    Test function to calculate the mirror point. Output should be
    
    {'blocal': 39730.828875776126, 'POSIT': [0.4828763104086329, 
    0.13755093538265498, 0.9794110012635103], 'bmin': 39730.828875776126}
    """
    model = MagFields(options = [0,0,0,0,0], verbose = True)
    LLA = {}
    LLA['x1'] = 651
    LLA['x2'] = 63
    LLA['x3'] = 15.9
    LLA['dateTime'] = '2015-02-02T06:12:43'
    maginput = {'Kp':40.0}
    alpha = 90 # Locally mirroring at input location.
    print(model.find_mirror_point(LLA, maginput, alpha))
    
def testTraceFieldLine(pltDensity = 10):
    """
    Test function to plot a fieldline and a sphere.
    """
    model = MagFields(options = [0,0,0,0,0], verbose = True)
    LLA = {}
    LLA['x1'] = 651
    LLA['x2'] = 63
    LLA['x3'] = 15.9
    LLA['dateTime'] = '2015-02-02T06:12:43'
    maginput = {'Kp':40.0}
    out = model.trace_field_line(LLA, maginput)
    
    # Now plot the field lines
    fig = plt.figure()
    ax = fig.add_subplot(111, projection='3d')
    xGEO = out['POSIT'][::pltDensity, 0] 
    yGEO = out['POSIT'][::pltDensity, 1] 
    zGEO = out['POSIT'][::pltDensity, 2] 

    ax.scatter(xGEO, yGEO, zGEO)
    
    # Draw sphere    
    u, v = np.mgrid[0:2*np.pi:40j, 0:np.pi:20j]
    x=np.cos(u)*np.sin(v)
    y=np.sin(u)*np.sin(v)
    z=np.cos(v)
    ax.plot_wireframe(x, y, z, color="k")
    ax.set_ylim([-5, 5])
    ax.set_xlim([-5, 5])
    ax.set_zlim([-5, 5])
    ax.set_xlabel('x GEO')
    ax.set_ylabel('y GEO')
    ax.set_zlabel('z GEO')
    
def azimuthalFieldLineVisualization(lat = 55, dLon = 20, pltDensity = 10):
    """
    This function draws the megnetic field lines defined by the lat argument,
    at different longitudes from 0 to 360, in dLon angle steps. pltDensity 
    defines at what inerval to plot the field lines, since it is very 
    computationaly expensive to plot. 
    """
    model = MagFields(options = [0,0,0,0,0], verbose = True)
    startLon = 0
    endLon = 360
    
    N = (endLon - startLon)//dLon
    # We will have to append since we can't tell how big the output will be
    xGEO = np.array([])
    yGEO = np.array([])
    zGEO = np.array([])
    
    for i in range(N):#np.arange(startLon, endLon, dLon):
        LLA = {}
        LLA['x1'] = 651
        LLA['x2'] = lat
        LLA['x3'] = i*dLon
        LLA['dateTime'] = '2015-02-02T06:12:43'
        maginput = {'Kp':0.0}
        out = model.trace_field_line(LLA, maginput)
        # pltDensity is to plot every pltDensity location of the field line,
        # to ease the graphical visualization. 
        xGEO = np.append(xGEO, out['POSIT'][::pltDensity, 0])
        yGEO = np.append(yGEO, out['POSIT'][::pltDensity, 1])
        zGEO = np.append(zGEO, out['POSIT'][::pltDensity, 2])
    
    # Now plot the field line
    fig = plt.figure()
    ax = fig.add_subplot(111, projection='3d')
    ax.scatter(xGEO, yGEO, zGEO, s = 1)
    
    # Draw sphere    
    u, v = np.mgrid[0:2*np.pi:40j, 0:np.pi:20j]
    x=np.cos(u)*np.sin(v)
    y=np.sin(u)*np.sin(v)
    z=np.cos(v)
    ax.plot_wireframe(x, y, z, color="k")
    ax.set_ylim([-5, 5])
    ax.set_xlim([-5, 5])
    ax.set_zlim([-5, 5])
    ax.set_xlabel('x GEO')
    ax.set_ylabel('y GEO')
    ax.set_zlabel('z GEO')
    return
    
def test_find_magequator():
    model = MagFields(options = [0,0,0,0,0], verbose = True)
    X = {}
    X['x1'] = 651
    X['x2'] = 63
    X['x3'] = 15.9
    X['dateTime'] = '2015-02-02T06:12:43'
    maginput = {'Kp':40.0}
    model.find_magequator(X, maginput)
    print(model.find_magequator_output)
    return


# Schults and Lanzerotti Bounce period equation.
Tsl = lambda L, alpha0, v: 4*6.371E6*np.divide(L, v) * \
       (1.3802 - 0.3198*(np.sin(np.deg2rad(alpha0)) + \
       np.sqrt(np.sin(np.deg2rad(alpha0)))))
beta = lambda Ek: np.sqrt(1-((Ek/511)+1)**(-2))

def test_bounce_period():
    model = MagFields(options = [0,0,0,0,0], verbose = True)
    X = {}
    kp = 40
    X['x1'] = 651
    X['x2'] = 65
    X['x3'] = 15.9
    X['dateTime'] = '2015-02-02T22:00:00'
    maginput = {'Kp':kp}
    E = np.arange(200, 1000)
    Tb = model.bounce_period(X, maginput, E)
    model.make_lstar(X, maginput)
    L = np.abs(model.make_lstar_output['Lm'][0])
    MLT = model.make_lstar_output['MLT'][0]
   
    # Plot the bounce period, and compare to the analytic result from Shulz and
    # Lanzerotti.
    fig = plt.figure(figsize=(8, 8), dpi=80, facecolor = 'grey')
    gs = gridspec.GridSpec(1,1)
    tbPlt = fig.add_subplot(gs[0, 0])
    tbPlt.plot(E, Tb, label = 'T89')
    tbPlt.plot(E, Tsl(L, 3.7, 3.0E8*beta(E)), label = 'Shultz and Lanzerotti')
    tbPlt.legend()
    tbPlt.set(title = (r'$T_b$'+ ' with IRBEM and S&L. MLT = ' + \
    str('%.1f' % MLT) + ' kp = ' + str(kp//10)+ ' L = '+ '%.1f' % L), 
    xlabel = 'Electron kinetic energy (KeV)', ylabel = 'Bounce time (s)')
    tbPlt.set_xlim([np.min(E), np.max(E)])
    tbPlt.set_ylim([0.5, 1])
    gs.tight_layout(fig)
    
def test_mirror_point_alt():
    model = MagFields(options = [0,0,0,0,0], verbose = True)
    X = {}
    kp = 40
    X['x1'] = 651
    X['x2'] = -63
    X['x3'] = 15.9
    X['dateTime'] = '2015-02-02T06:12:43'
    maginput = {'Kp':kp}
    print(model.mirror_point_altitude(X, maginput))
    print('Altitude should be ~640.96 km')
    
if __name__ == '__main__':
    print('Running test: testLStarOutput()')    
    testLStarOutput()
    print('Running test: footPointTest')
    footPointTest()
    #print('Running test: azimuthalFieldLineVisualization')
    #azimuthalFieldLineVisualization(dLon = 5)
    #print('Running test: testDriftShell')
    #testDriftShell()
    print('Running test: test_find_magequator')
    test_find_magequator()
    print('Running test: test_bounce_period')
    test_bounce_period()
    plt.show()
