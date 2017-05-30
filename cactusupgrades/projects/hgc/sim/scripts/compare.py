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

    files = listdir('data')

    for fileName in files :

        print ' >>> processing file : '+fileName

        file1Name = 'results/'+fileName
        file2Name = 'resultsSW/'+fileName
        
        board1 = MP7()
        board1.load_file( file1Name )
        board2 = MP7()
        board2.load_file( file1Name )

        if board1 == board1 :
            print 'OK'
        else :
            print '>>> NOT EQUAL <<<'
    
###
# if python says run, then we should run
if __name__ == '__main__':
    main()


