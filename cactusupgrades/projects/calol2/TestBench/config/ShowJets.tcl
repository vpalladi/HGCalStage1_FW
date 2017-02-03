    add wave -divider "SUB-JETS"
    add wave -uns sim:/testbench/sum3x3Pipe(0)
    add wave -uns -color Magenta sim:/testbench/references/reference_3x3Sum 
    add wave -uns sim:/testbench/sum3x9Pipe(0)
    add wave -uns -color Magenta sim:/testbench/references/reference_3x9Sum 
    add wave -uns sim:/testbench/sum9x3Pipe(0)
    add wave -uns -color Magenta sim:/testbench/references/reference_9x3Sum 
    
    add wave -divider "JET VETO"
    add wave -uns sim:/testbench/jets9x9VetoPipe(0) 
    add wave -uns -color Magenta sim:/testbench/references/reference_9x9Veto 
    
    add wave -divider "PILEUP EST."
    add wave -uns sim:/testbench/FilteredPileUpPipe(0) 
    add wave -uns -color Magenta sim:/testbench/references/reference_JetPUestimate 
    
    add wave -divider "FILTERED JETS"
    add wave -uns sim:/testbench/filteredJetPipe(0) 
    add wave -uns -color Magenta sim:/testbench/references/reference_JetSum 
    
    add wave -divider "PILEUP SUB. JETS"
    add wave -uns sim:/testbench/pileUpSubtractedJetPipe(0) 
    add wave -uns -color Magenta sim:/testbench/references/reference_PUsubJet 
    
    add wave -divider "SORTED JETS"
    add wave -uns sim:/testbench/sortedJetPipe(0) 
    add wave -uns -color Magenta sim:/testbench/references/reference_sortedJet
    
    add wave -divider "ACCUMULATED SORTED JETS"
    add wave -uns sim:/testbench/accumulatedSortedJetPipe(0) 
    add wave -uns -color Magenta sim:/testbench/references/reference_accumulatedsortedJet
    add wave sim:/testbench/jetAccumulationCompletePipe(0)

    add wave -divider "DEMUX'ED JETS"
    add wave -uns sim:/testbench/demuxAccumulatedSortedJetPipe(0)
    add wave -uns -color Magenta sim:/testbench/references/reference_demuxAccumulatedsortedJet
    
    add wave -divider "FINAL MERGED JETS"
    add wave -uns sim:/testbench/mergedSortedJetPipe(0)
    add wave -uns -color Magenta sim:/testbench/references/reference_mergedsortedJet
    
    add wave -divider "GT FORMATTED JETS"
    add wave -dec sim:/testbench/gtFormattedJetPipe(0)
    add wave -dec -color Magenta sim:/testbench/references/reference_gtFormattedJet
