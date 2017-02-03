######################################################################
##
## Filename: TestbenchFMBus.udo
## Created on: Thu Mar 31 13:48:22 BST 2016
##
## Auto generated by Project Navigator for Post-Behavioral Simulation
##
## You may want to edit this file to control your simulation.
##
######################################################################


delete wave *
config wave -signalnamewidth 1

add wave -divider "testbenchFMBus"
#add wave -hex sim:/testbenchFMBus/BusInfoSpace
add wave -hex sim:/testbenchFMBus/*

add wave -divider "FMBusMasterInstance"
add wave -hex sim:/testbenchFMBus/FMBusMasterInstance/*
add wave -hex sim:/testbenchFMBus/FMBusMasterInstance/prc/*
add wave -hex sim:/testbenchFMBus/FMBusMasterInstance/prc/Fifo

add wave -divider "FMBusDecoderInstance1"
add wave -hex sim:/testbenchFMBus/FMBusDecoderInstance1/*

add wave -divider

run 100ns

# ==================================================
# WRITE TEST
# ==================================================

# force -freeze sim:/testbenchfmbus/MasterInstructionIn Unlock 0
# force -freeze sim:/testbenchfmbus/MasterInstructionValid TRUE 0
# run 20ns

# force -freeze sim:/testbenchfmbus/MasterInstructionIn Ignore 0
# force -freeze sim:/testbenchfmbus/MasterInstructionValid FALSE 0
# run 20ns

# force -freeze sim:/testbenchfmbus/MasterInstructionIn WriteData 0
# force -freeze sim:/testbenchfmbus/MasterInstructionValid TRUE 0
# run 20ns

# force -freeze sim:/testbenchfmbus/MasterInstructionIn Ignore 0
# force -freeze sim:/testbenchfmbus/MasterInstructionValid FALSE 0
# run 20ns

# force -freeze sim:/testbenchFMbus/MasterDataIn 32'hCAFEBABE 0
# force -freeze sim:/testbenchfmbus/MasterDataValid TRUE 0
# run 20ns

# force -freeze sim:/testbenchFMbus/MasterDataIn 32'h00000000 0
# force -freeze sim:/testbenchfmbus/MasterDataValid FALSE 0
# run 20ns

# ==================================================

# ==================================================
# READ TEST
# ==================================================

force -freeze sim:/testbenchFMbus/SlaveDataIn1 9'h0BE 0

force -freeze sim:/testbenchfmbus/MasterInstructionIn Unlock 0
force -freeze sim:/testbenchfmbus/MasterInstructionValid TRUE 0
run 20ns

force -freeze sim:/testbenchfmbus/MasterInstructionIn Ignore 0
force -freeze sim:/testbenchfmbus/MasterInstructionValid FALSE 0
run 20ns

force -freeze sim:/testbenchfmbus/MasterInstructionIn ReadData 0
force -freeze sim:/testbenchfmbus/MasterInstructionValid TRUE 0
run 20ns

force -freeze sim:/testbenchfmbus/MasterInstructionIn Ignore 0
force -freeze sim:/testbenchfmbus/MasterInstructionValid FALSE 0
run 20ns

force -freeze sim:/testbenchfmbus/MasterDataValid TRUE 0
run 20ns

force -freeze sim:/testbenchfmbus/MasterDataValid FALSE 0
run 20ns

force -freeze sim:/testbenchFMbus/SlaveDataIn1 9'h15D 0
run 180ns

force -freeze sim:/testbenchFMbus/SlaveDataIn1 9'h0BF 0
run 180ns

force -freeze sim:/testbenchFMbus/SlaveDataIn1 9'h019 0
run 300ns


force -freeze sim:/testbenchfmbus/MasterDataValid TRUE 0
run 20ns

force -freeze sim:/testbenchfmbus/MasterDataValid FALSE 0
run 20ns


force -freeze sim:/testbenchFMbus/SlaveDataIn1 9'h0BE 0
run 180ns

force -freeze sim:/testbenchFMbus/SlaveDataIn1 9'h15D 0
run 180ns

force -freeze sim:/testbenchFMbus/SlaveDataIn1 9'h0BF 0
run 180ns

force -freeze sim:/testbenchFMbus/SlaveDataIn1 9'h019 0
run 180ns