#!/usr/bin/python

##
# python
import sys
sys.path.append('/home/vpalladi/SW/HGC/sim/HgcTpgSim/python/naming')
from os import listdir,path
from optparse import OptionParser

##
# my classes
from modules.panel import *
from modules.points import *
from modules.seedButton import *


###
# main 
def main():
    
    parser = OptionParser()
    parser.add_option('-f', '--file', dest='fileToProcess', default='all',
                      help='File to process. Input ALL (default) to process all files in the directory.')
    parser.add_option('-d', '--directory', dest='folder', default="data",
                      help='Folder to process (the script will process Nfile from this folder)')
    
    (opt, args) = parser.parse_args()

    
    WAFER_WIDTH = 12.37 # diameter 8'
    WAFER_SIDE = WAFER_WIDTH/math.sqrt(3.0)

    files = []
    if opt.fileToProcess == "all" :
        files = listdir(opt.folder)
    else :
        files.append(opt.fileToProcess)

    for fileName in files :

        if path.isdir( opt.folder+'/'+fileName ) :
            continue
        if fileName[-4:] != '.mp7' :
            continue
        
        print ' >>> comparing file : '+fileName

        fileName_FW = opt.folder+'/resultsFW/'+fileName
        fileName_SW = opt.folder+'/resultsSW/'+fileName
        
        boardFW = MP7()
        boardFW.load_file( fileName_FW )
        boardSW = MP7()
        boardSW.load_file( fileName_SW )

        if boardFW == boardSW :
            print 'OK'
        else :
            print '>>> NOT EQUAL <<<'
    
###
# if python says run, then we should run
if __name__ == '__main__':
    main()


