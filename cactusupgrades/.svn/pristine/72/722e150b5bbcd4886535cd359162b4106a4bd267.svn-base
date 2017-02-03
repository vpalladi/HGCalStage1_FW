Hi all,
 
I have finally got around to providing a nice user interface for the Testbench.
 
In the folder /cactusupgrades/projects/calol2/TestBench you will find TestBench.py, which provides the user interface:
 
==================================================================================================
 
usage: TestBench.py [-h] -f FILE [-l LATENCY [LATENCY ...]]
                    [-w WAVE [WAVE ...]] [-t TIME]
 
optional arguments:
  -h, --help            show this help message and exit
  -f FILE, --file FILE  source data (required)
  -l LATENCY [LATENCY ...], --latency LATENCY [LATENCY ...]
                        object types for which to include latency debugging
                        [tau, jet, sum, cluster, tower, egamma]
  -w WAVE [WAVE ...], --wave WAVE [WAVE ...]
                        object types for which to draw waves [tau, cluster,
                        link, jet, clock, sum, tower, egamma]
  -t TIME, --time TIME  number of frames to run for
 
==================================================================================================
 
The required FILE argument is the MP7 input capture file over which to run.
The "standard" files (eegun, H->ee, H->TT) are in the patterns folder.
 
The optional TIME argument specifies the number of frames to run for.
If omitted, the entire input file is run.
 
The optional WAVE argument is any number of the keywords [tau, cluster, link, jet, clock, sum, tower, egamma] and specifies which waves to display in the modelsim gui.
If no -w option is used, modelsim is run without the gui for speed.
 
The optional LATENCY argument is any number of the keywords [tau, jet, sum, cluster, tower, egamma] and gives clock-by-clock latency debugging information.
This is only useful when modifying the firmware.
 
Currently the Intermediate debugging files, MP output, Demux input and Demux output are always generated.
If I run out of other things to do, I will add command-line flags to enable their output.
 
==================================================================================================
 
The minimal usage is:
./TestBench.py -f Patterns/pattern-SingleElec-1000evt_0.txt
(Open a file, run it to the end, no gui)
 
The minimal gui usage is:
./TestBench.py -f Patterns/pattern-SingleElec-1000evt_0.txt -w cluster egamma tau
(Open a file, run it to the end, no gui)
 
==================================================================================================
 
Technical details:
 
For speed, the script only recompiles the libraries if the VHDL files are modified, rather than every time the script is run.
 
The coregen VHDL simulation files are included in a tarball in the algorithm_component/firmware/cgn folder and extracted into the TestBench/cgn folder.
 
==================================================================================================

For completeness, to compile the Xilinx simulation libraries, use the following on the commandline (adapting the modelsim path accordingly)

compxlib -s mti_se -l vhdl -p /opt/Mentor/modelsim_10_1b/modeltech/bin -arch virtex7 -lib unisim -lib simprim -lib xilinxcorelib -lib edk -exclude_superseded -intstyle ise
