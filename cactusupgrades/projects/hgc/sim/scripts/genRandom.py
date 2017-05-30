#!/usr/bin/python

##
# python
import sys
sys.path.append('/home/vpalladi/SW/HGC/sim/HgcTpgSim/python/naming')
from os import listdir,path
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
from modules.panel import *
from modules.points import *
from modules.seedButton import *


###
# main 
def main():

    WAFER_WIDTH = 12.37 # 8'
    WAFER_SIDE = WAFER_WIDTH/math.sqrt(3.0)

    parser = OptionParser()
    parser.add_option('-n', '--nEvents', dest='nEvt',
                      help='Number of event to generate')
    parser.add_option('-N', '--Nfirst', dest='nFirst',
                      help='First event ID')
    (opt, args) = parser.parse_args()

    nFirst = int(opt.nFirst)
    for i_evt in range( 0, int(opt.nEvt) ) :
        print ' >>> Event ',i_evt+nFirst 
        p = Panel( WAFER_SIDE )
        p.gen_random_event( nNonSeeds=np.random.randint(10,50) )
        p.dump_to_file( fileName='data/outR_'+str(i_evt+nFirst)+'.mp7' )

###
# if python says run, then we should run
if __name__ == '__main__':
    main()


