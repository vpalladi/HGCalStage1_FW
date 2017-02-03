    add wave -divider "E/GAMMA PROTOCLUSTER"
    add wave -uns sim:/testbench/EgammaProtoClusterPipe(0)
    add wave -uns -color Magenta sim:/testbench/references/reference_EgammaProtoCluster
  
    add wave -divider "E/GAMMA CLUSTER"
    add wave -uns sim:/testbench/EgammaClusterPipe(0)
    add wave -uns -color Magenta sim:/testbench/references/reference_EgammaCluster
  
    add wave -divider "E/GAMMA ISOLATION"
    add wave -uns sim:/testbench/Isolation5x2Pipe(0)
    add wave -uns -color Magenta sim:/testbench/references/reference_Isolation5x2
    add wave -uns sim:/testbench/Isolation9x6Pipe(0)
    add wave -uns -color Magenta sim:/testbench/references/reference_Isolation9x6
    add wave -uns sim:/testbench/EgammaIsolationRegionPipe(0)
    add wave -uns -color Magenta sim:/testbench/references/reference_EgammaIsolationRegion
  
    add wave -divider "CLUSTER PILEUP ESTIMATION"
    add wave -uns sim:/testbench/ClusterPileupEstimationPipe(0)
    add wave -uns -color Magenta sim:/testbench/references/reference_ClusterPileupEstimation
  
    #add wave -divider "ISOLATION FLAGS"
    #add wave -uns sim:/testbench/EgammaIsolationFlagPipe(0)
    #add wave -uns -color Magenta sim:/testbench/references/reference_EgammaIsolationFlag
  
    add wave -divider "CALIBRATED E/GAMMAS"
    add wave -uns sim:/testbench/CalibratedEgammaPipe(0) 
    add wave -uns -color Magenta sim:/testbench/references/reference_CalibratedEgamma
  
    add wave -divider "SORTED E/GAMMAS"
    add wave -uns sim:/testbench/SortedEgammaPipe(0) 
    add wave -uns -color Magenta sim:/testbench/references/reference_SortedEgamma
    
    add wave -divider "ACCUMULATED SORTED E/GAMMAS"
    add wave -uns sim:/testbench/accumulatedSortedEgammaPipe(0) 
    add wave -uns -color Magenta sim:/testbench/references/reference_accumulatedSortedEgamma
    add wave sim:/testbench/EgammaAccumulationCompletePipe(0)