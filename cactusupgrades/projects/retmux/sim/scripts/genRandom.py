#!/usr/bin/python

##
# python
import sys
sys.path.append('/home/vpalladi/SW/HGC/sim/HgcTpgSim/python/naming')
from os import listdir,path,makedirs
from optparse import OptionParser

import numpy as np
##
# matlibplot
#import matplotlib.path as mplPath
#import matplotlib.pyplot as plt
#import matplotlib.figure as pfig
#from matplotlib.widgets import Button

##
# my classes
from modules.mp7 import *
from modules.points import *
from modules.seedButton import *

###
# main 
def main():

    parser = OptionParser()
    parser.add_option('-d', '--directory', dest='destinationFolder', default='./',
                      help='Destination folder')
    parser.add_option('-f', '--file', dest='fOutName', default='out.mp7',
                      help='File out name')
    parser.add_option('--nBX', dest='nBX', default='18',
                      help='Number of BX to generate')
    parser.add_option('--nC3D', dest='nC3D', default='100',
                      help='Number of C3D')
    (opt, args) = parser.parse_args()

    # create target dir if it doesn't exist
    if( not path.isdir(opt.destinationFolder) ) :
        makedirs(opt.destinationFolder)
    
    f = file(opt.destinationFolder+'/'+opt.destinationFolder+'_generation.log', 'w')
    for key,value in opt.__dict__.iteritems() :
        f.write( key+' '+value+'\n' )
    f.close()
        
    WAFER_WIDTH = 12.37 # 8'
    WAFER_SIDE = WAFER_WIDTH/math.sqrt(3.0)
    
    board = MP7()

    nCHs=4 # numer of channels out of c3d board
    nMP7links=72
    nBX=int(opt.nBX)
    nC3D=int(opt.nC3D)
    
    for i in range(0, nMP7links/nCHs) :
        for ifrm in range(0, i*10) :    
            board.add_zeros( channels=range(i*4, i*4+4) )

    chGroup = 0

    for ibx in range(0, nBX) :
        board.add_c3d_event( chGroup*4, 4, nC3d=10, BXid=ibx )
        if chGroup == nMP7links/nCHs-1 :
            chGroup = 0
        else :
            chGroup = chGroup+1
        
    board.dump_to_file(opt.fOutName)

###
# if python says run, then we should run
if __name__ == '__main__':
    main()


