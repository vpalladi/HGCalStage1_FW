#!/usr/bin/python

##
# python
import sys
sys.path.append('/home/vpalladi/SW/HGC/sim/HgcTpgSim/python/naming')
from os import listdir,path

##
# matlibplot
import matplotlib.path as mplPath
import matplotlib.pyplot as plt
import matplotlib.figure as pfig
from matplotlib.widgets import Button

##
# my classes
from modules.panel import *
from modules.points import *
from modules.seedButton import *
  

###
# main 
def main():

    WAFER_WIDTH = 12.37 # 8'
    WAFER_SIDE = WAFER_WIDTH/math.sqrt(3.0)

    files = listdir('data')
    
    for fileName in files :

        print ' >>> processing file : '+fileName
        
        mp7 = MP7()
        mp7.load_file( 'data/'+fileName )
        mp7.clusterise()
        mp7.dump_to_file('resultsSW/'+fileName)

        #p = Panel( WAFER_SIDE )
        #p.load_mp7( board=mp7, 0 )
        #p.dump_to_file('resultsSW/'+fileName)

###
# if python says run, then we should run
if __name__ == '__main__':
    main()


