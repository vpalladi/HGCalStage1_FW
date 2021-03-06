######################################################################
##
## Filename: TestBenchDemux.udo
## Created on: Tue May 03 13:32:51 BST 2016
##
## Auto generated by Project Navigator for Post-Behavioral Simulation
##
## You may want to edit this file to control your simulation.
##
######################################################################


if { ! [batch_mode] } {
  delete wave *
  config wave -signalnamewidth 1

  add wave -divider 
  # add wave -hex sim:/testbenchdemux/links_*
  # add wave -divider 
  # add wave -hex sim:/testbenchdemux/DemuxInstance/*
  # add wave -divider 
  # 
  add wave -hex sim:/testbenchdemux/DemuxInstance/LinksOutInstance/PackedRingSumPipeIn(0)
  add wave -hex sim:/testbenchdemux/DemuxInstance/LinksOutInstance/PackedJetPipeIn(0)
  add wave -hex sim:/testbenchdemux/DemuxInstance/LinksOutInstance/PackedEgammaPipeIn(0)
  add wave -hex sim:/testbenchdemux/DemuxInstance/LinksOutInstance/PackedTauPipeIn(0)

  add wave -hex sim:/testbenchdemux/DemuxInstance/LinksOutInstance/*
  add wave -divider 
}