#!/usr/bin/python

##
# python
import sys
sys.path.append('/home/vpalladi/SW/HGC/sim/HgcTpgSim/python/naming')
from os import listdir,path

##
# matlibplot
#import matplotlib.path as mplPath
#import matplotlib.pyplot as plt
#import matplotlib.figure as pfig
#from matplotlib.widgets import Button

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

#    file0Name = 'data/outR_'+sys.argv[1]+'.mp7'
    fileNameFW = 'results/outR_'+sys.argv[1]+'.mp7'
    fileNameSW = 'resultsSW/outR_'+sys.argv[1]+'.mp7'

#    board0 = MP7()
#    board0.load_file( file0Name )    
    boardFW = MP7()
    boardFW.load_file( fileNameFW )
    boardSW = MP7()
    boardSW.load_file( fileNameSW )

    print fileNameFW,fileNameSW
    if boardFW == boardSW :
        print 'OK'
    else :
        print '>>> NOT EQUAL <<<'
    
###
# if python says run, then we should run
if __name__ == '__main__':
    main()


