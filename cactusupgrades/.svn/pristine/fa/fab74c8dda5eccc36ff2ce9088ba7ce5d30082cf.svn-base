#!/usr/bin/env python

import subprocess, argparse, os, sys

# =====================================================================================================================================================================
# Parse the commandline arguments
latency_debug = { "tower"   : "tower_latency_debug" ,
                  "jet"     : "jet_latency_debug" ,
                  "cluster" : "cluster_latency_debug" ,
                  "egamma"  : "egamma_latency_debug" ,
                  "tau"     : "tau_latency_debug" ,
                  "sum"     : "sum_latency_debug" }

wave_configs = { "clock"   : "config/ShowClocks.tcl" ,
                 "tower"   : "config/ShowTowers.tcl" ,
                 "jet"     : "config/ShowJets.tcl" ,
                 "cluster" : "config/ShowClusters.tcl" ,
                 "egamma"  : "config/ShowEgammas.tcl" ,
                 "tau"     : "config/ShowTaus.tcl" ,
                 "sum"     : "config/ShowSums.tcl" ,
                 "link"    : "config/ShowLinks.tcl" }   

intermediates = { "tower"   : "tower_intermediates" ,
                  "cluster" : "cluster_intermediates" ,
                  "egamma"  : "egamma_intermediates" ,
                  "tau"     : "tau_intermediates" }


parser = argparse.ArgumentParser()
parser.add_argument('-f', '--file' , help='source data' )
parser.add_argument('-i', '--intermediates' , nargs='+' , default = [] , help='object types for which to generate intermediates [{0}]'.format( ", ".join( intermediates.keys() ) ) )
parser.add_argument('-I', '--AllIntermediates' , action='store_true' , help='generate all intermediates' )
parser.add_argument('-l', '--latency' , nargs='+' , default = [] , help='object types for which to generate latency debugging info [{0}]'.format( ", ".join( latency_debug.keys() ) ) )
parser.add_argument('-L', '--AllLatency' , action='store_true' , help='generate all latency debugging info' )
parser.add_argument('-w', '--wave' , nargs='+' , default = [] , help='object types for which to draw waves [{0}]'.format( ", ".join( wave_configs.keys() ) ) )
parser.add_argument('-W', '--AllWave' , action='store_true' , help='draw all waves' )
parser.add_argument('-t', '--time' , type=int , help='number of frames for which to run' )
parser.add_argument('-o', '--outfile' , help='tarball to which to write output' )
parser.add_argument('-O', '--AutoOutfile' , action='store_true' , help='Automatically write output to tarball' )
parser.add_argument('-p', '--path' , help='path to modelsim executables' )
parser.add_argument('-c', '--compile' , action='store_true' , help='force recompile libraries' )
args = parser.parse_args()
# =====================================================================================================================================================================


# =====================================================================================================================================================================
# If no arguments specified, print help
if len(sys.argv)==1:
  parser.print_help()
  quit()
# =====================================================================================================================================================================

# =====================================================================================================================================================================
# Extract the coregen if necessary
if not os.path.isdir( "cgn" ):
  subprocess.call( "mkdir cgn" , shell=True )
  subprocess.call( "gtar xvzf ../algorithm_components/firmware/cgn/modelsim.tar.gz -C cgn" , shell=True )
# =====================================================================================================================================================================

# =====================================================================================================================================================================
# Executable paths
if args.path:
  vlib = os.path.abspath( os.path.join( args.path , "vlib" ) ) 
  vcom = os.path.abspath( os.path.join( args.path , "vcom" ) ) 
  vsim = os.path.abspath( os.path.join( args.path , "vsim" ) ) 
else:
  vlib = "vlib"
  vcom = "vcom"
  vsim = "vsim"
# =====================================================================================================================================================================

# =====================================================================================================================================================================
# Remove old libraries
if args.compile:
  subprocess.call( "rm -rf work .Files.txt" , shell=True )
# =====================================================================================================================================================================

# =====================================================================================================================================================================
# Compile the libraries
subprocess.call( "{0} work".format( vlib ) , shell=True )
if os.path.isfile( ".Files.txt" ): files = [ l.split() for l in open( ".Files.txt" , "r" ) ]
else: files = [ [ l.strip() , 0.0 ] for l in open( "Files.txt" , "r" ) ]
modified = False
for l in files:
  l[0] = os.path.abspath( l[0] )
  mtime = os.path.getmtime( l[0] )
  if modified or mtime > float(l[1]) :
    modified = True
    if subprocess.call( "{0} -explicit -93 '{1}'".format( vcom , l[0] ) , shell=True ):
      print "COMPILE {0} FAILED".format( l[0] )
      quit()
    l[1] = mtime

if modified:
  with open( ".Files.txt" , "w" ) as f:
    for l in files: f.write( "{0}\t{1}\n".format(l[0] , l[1]) )
# =====================================================================================================================================================================



# =====================================================================================================================================================================
# If no source file, don't go any further
if not args.file: quit()
# =====================================================================================================================================================================

# =====================================================================================================================================================================
# Read length of the source file
try:
  source_length = sum( 1 if len( line.strip() ) else 0 for line in open( args.file , "r" ) )
except:
  print "SOURCE FILE '{0}' DOES NOT EXIST OR IS INACCESSIBLE".format( args.file )
  quit()
# =====================================================================================================================================================================

# =====================================================================================================================================================================
# Add the source file to the vsim commandline flags
flags = "-gsourcefile='\"{0}\"'".format( args.file )
# =====================================================================================================================================================================

# =====================================================================================================================================================================
# Calculate the run time
frames = source_length-3

if args.time and ( args.time < frames ):
  frames = args.time

flags += " -gnumberOfFrames={0}".format( frames )
# =====================================================================================================================================================================

# =====================================================================================================================================================================
# Create a tcl script to run...
if args.AllWave:
  args.wave = [ "clock" , "tower" , "jet" , "cluster" , "egamma" , "tau" , "sum" , "link" ]

with open( "Test.do" , "w" ) as f:

  f.write( "view wave\n" )
  f.write( "delete wave *\n" )
  f.write( "config wave -signalnamewidth 1\n" )

  for w in args.wave:
    try:
      f.write( "do {0}\n".format( wave_configs[w.lower()] ) )
    except:
      print "INVALID WAVE OPTION '{0}'".format( w )
      print "VALID OPTIONS ARE {0}".format( ", ".join( wave_configs.keys() ) )
      quit()
   
  f.write( "run {0}ps\n".format( frames*4166 ) )
    
  if not len( args.wave ):
    f.write( "quit -f" )
    flags += " -c"
# =====================================================================================================================================================================

# =====================================================================================================================================================================
# Add the latency debugging flags to the vsim commandline flags
if args.AllLatency:
  args.latency = latency_debug.keys()
  
for l in args.latency:
  try:
    flags += " -g{0}=TRUE".format( latency_debug[l.lower()] )
  except:
    print "INVALID LATENCY OPTION '{0}'".format( l )
    print "VALID OPTIONS ARE {0}".format( ", ".join( latency_debug.keys() ) )
    quit()
# =====================================================================================================================================================================

# =====================================================================================================================================================================
# Add the intermediates flags to the vsim commandline flags
if args.AllIntermediates:
  args.intermediates = intermediates.keys()

for l in args.intermediates:
  try:
    flags += " -g{0}=TRUE".format( intermediates[l.lower()] )
  except:
    print "INVALID INTERMEDIATES OPTION '{0}'".format( l )
    print "VALID OPTIONS ARE {0}".format( ", ".join( intermediates.keys() ) )
    quit()
# =====================================================================================================================================================================

# =====================================================================================================================================================================
# Add the remaining vsim commandline flags for consistency
flags += " -do Test.do"
flags += " -voptargs='+acc'"
flags += " -t 1ps"
flags += " -lib work"
# =====================================================================================================================================================================

# =====================================================================================================================================================================
# Run vsim
if subprocess.call( "{0} {1} work.TestBench".format( vsim , flags ) , shell=True ):
  print "SIMULATION FAILED".format( l[0] )
  quit()
# =====================================================================================================================================================================

# =====================================================================================================================================================================
# Create output
if args.outfile:
  subprocess.call( "gtar cvzf {0} {1} IntermediateSteps/*.txt".format( args.outfile , args.file ) , shell=True )
elif args.AutoOutfile:
  subprocess.call( "gtar cvzf {0}.tgz {0} IntermediateSteps/*.txt".format( args.file ) , shell=True )
# =====================================================================================================================================================================


