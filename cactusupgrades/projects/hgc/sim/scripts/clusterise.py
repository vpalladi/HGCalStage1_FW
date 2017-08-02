#!/usr/bin/python

##
# python
import sys
sys.path.append('/home/vpalladi/SW/HGC/sim/HgcTpgSim/python/naming')
from os import listdir,path,makedirs
from optparse import OptionParser

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

    parser = OptionParser()
    parser.add_option('-f', '--file', dest='fileToProcess', default='all',
                      help='File to process. Input ALL (default) to process all files in the directory.')
    parser.add_option('-d', '--directory', dest='folder', default="data",
                      help='Folder to process (the script will process Nfile from this folder)')
    
    (opt, args) = parser.parse_args()

    # create results dir if doesn't exist
    resultsFolder = opt.folder+'/resultsSW'
    if( not path.isdir(resultsFolder) ) :
        makedirs(resultsFolder)

    # log file
    logFile = open(opt.folder+'/cluSummary.log', 'w')
    
    WAFER_WIDTH = 12.37 # diameter = 8'
    WAFER_SIDE = WAFER_WIDTH/math.sqrt(3.0)

    files = []
    if opt.fileToProcess == "all" :
        files = listdir(opt.folder)
    else :
        files.append(opt.fileToProcess)

    cluSummary = {}
        
    for fileName in files :
        
        if path.isdir( opt.folder+'/'+fileName ) :
            continue
        if fileName[-4:] != '.mp7' :
            continue
        
        logFile.write( ' >>> clusterising file : '+fileName+'\n' )
        
        
        mp7 = MP7()
        mp7.load_file( opt.folder+'/'+fileName )
        nClu = mp7.clusterise_NN()
        if str(nClu) in cluSummary :
            cluSummary[str(nClu)] = cluSummary[str(nClu)]+1
        else :
            cluSummary[str(nClu)] = 1
        logFile.write( '     nClusters: '+str(nClu)+'\n' )
        mp7.dump_to_file( opt.folder+'/resultsSW/'+fileName )

    txt = ' >>> Clusters Summary : \n'
    txt = txt + 'nClu'+'\t'+'nEvents'+'\n'
    for key in cluSummary :
        txt = txt + key+'\t'+str(cluSummary[key])+'\n'
        
    logFile.write(txt)
    print txt
###
# if python says run, then we should run
if __name__ == '__main__':
    main()


