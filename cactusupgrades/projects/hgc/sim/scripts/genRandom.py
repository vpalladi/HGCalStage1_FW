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
from modules.panel import *
from modules.points import *
from modules.seedButton import *

###
# main 
def main():

    parser = OptionParser()
    parser.add_option('-n', '--nEvents', dest='nEvt', default='10',
                      help='Number of event to generate')
    parser.add_option('--first_event_id', dest='firstEvtId', default='0',
                      help='First event ID')
    parser.add_option('-d', '--directory', dest='destinationFolder',
                      help='Destination folder')
    parser.add_option('--n_seeds', dest='nSeeds', default='1',
                      help='Number of seeds to generate.')
    parser.add_option('--n_non_seeds_min', dest='nNonSeeds_min', default='10',
                      help='Non seeds tc random generation minimum.')
    parser.add_option('--n_non_seeds_max', dest='nNonSeeds_max', default='50',
                      help='Non seeds tc random generation maximum.')
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
    
    nFirst = int(opt.firstEvtId)
    
    for i_evt in range( 0, int(opt.nEvt) ) :
        print ' >>> Generating event ',i_evt+nFirst 
        p = Panel( WAFER_SIDE )
        p.gen_random_event( nSeeds = int(opt.nSeeds), nNonSeeds=np.random.randint( int(opt.nNonSeeds_min), int(opt.nNonSeeds_max) ) )
        p.dump_to_file( fileName=opt.destinationFolder+'/outR_'+str(i_evt+nFirst)+'.mp7' )


###
# if python says run, then we should run
if __name__ == '__main__':
    main()


