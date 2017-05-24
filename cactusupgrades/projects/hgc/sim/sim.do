

#restart -f

add wave -label "CLK" -position insertpoint sim:/testbench/e_MainProcessor/clk
add wave -position insertpoint sim:/testbench/e_MainProcessor/linksIn(0)
add wave -position insertpoint sim:/testbench/e_MainProcessor/flaggedData(0)
add wave -position insertpoint sim:/testbench/linksOut(0)
add wave -position insertpoint sim:/e_MainProcessor/linksOut(0)
#add wave -position insertpoint sim:/testbench/e_MainProcessor/sdist_flaggedDataOut(0)
#add wave -position insertpoint sim:/testbench/e_MainProcessor/sdist_bxCounter(0)

######  Data variable Delay  ######
set groupName "DataVariableDelay"

set signals {}
lappend signals "flaggedWordIn"
lappend signals "flaggedWordOut"
lappend signals "wordToRam"
lappend signals "wordFromRam"
lappend signals "data_ram_addr_wr"
lappend signals "data_ram_addr_rd"
#lappend signals "data_ram_ena"
#lappend signals "data_ram_dina"
#lappend signals "data_ram_addr_wr"
#lappend signals "data_ram_wea(0)"
#lappend signals "data_ram_enb"
#lappend signals "data_ram_addr_rd"
#lappend signals "data_ram_doutb"
#
#lappend signals "rp_fifo_empty"
#lappend signals "rp_fifo_wr_en"
#lappend signals "rp_fifo_din"
#lappend signals "rp_fifo_rd_en"
#lappend signals "rp_fifo_dout"

foreach {signal} $signals {
    if { $signal == "data_ram_dina" || $signal == "data_ram_doutb" } { 
        add wave -group $groupName -color "Gold" -label $signal -position insertpoint sim:/testbench/e_MainProcessor/g_data_delay_links(0)/e_DataVariableDelay/$signal
    } else {
        add wave -group $groupName -label $signal -position insertpoint sim:/testbench/e_MainProcessor/g_data_delay_links(0)/e_DataVariableDelay/$signal
    }
}


######  SeedDistribution  ######
set groupName "SeedDistributor"

set signals {}
lappend signals "flaggedWordIn"
lappend signals "flaggedWordOut"
lappend signals "rst"
lappend signals "enaClusters"
#lappend signals ""
#lappend signals ""

foreach {signal} $signals {
    add wave -group $groupName -label $signal -position insertpoint sim:/testbench/e_MainProcessor/g_data_delay_links(0)/e_seedDistributor/$signal
}

######  Cluster  ######
set groupName_0 "Cluster 0"
#set groupName_1 "Cluster 1"

set signals {}
lappend signals "flaggedWordIn"
lappend signals "flaggedWordIn_1"
lappend signals "flaggedWordSeed"
lappend signals "state"
lappend signals "data_flaggedWordOut"
## lappend signals "enaSeed"
## lappend signals "detectedEOE"
## 
lappend signals "flaggedWordIn.word.address.row"
lappend signals "flaggedWordSeed.word.address.row"
 
lappend signals "flaggedWordIn.word.address.col"
lappend signals "flaggedWordSeed.word.address.col"

lappend signals "col"
lappend signals "row"
 
lappend signals "p_acquisition/weSeed"
lappend signals "p_acquisition/weWord"

lappend signals "occupancy"
lappend signals "occupancyComputed"


#lappend signals "seedingFlaggedWordIn"
#lappend signals "delayedFlaggedWordIn"

#lappend signals "flaggedDataOut"
#lappend signals "flaggedWordOut"
#lappend signals "row_flaggedDataOut"
#lappend signals "row_dataValid"
#lappend signals "seedAcquired"
#lappend signals "detectedEOE"
#lappend signals "readyToAcquire"
#lappend signals "readyToSend"
#lappend signals "send"
#lappend signals "row_send"
#lappend signals "sent"
#lappend signals "flaggedWordIn.bxId"

#lappend signals "g_rows(0)/cluster_row/flaggeSeedWordIn"


#lappend signals "p_acquisition/weSeed"
#lappend signals "p_acquisition/weWord"
#lappend signals "flaggedWordSeed.bxId"
#lappend signals "flaggedWordIn.word.address.row"
#lappend signals "p_acquisition/row_addr"
#lappend signals "flaggedWordIn.word.address.col"
#lappend signals "p_acquisition/col_addr"
#lappend signals "occupancy"
#lappend signals "occupancyComputed"

#lappend signals "flaggedWordInForSeeding" 
#lappend signals "weSeed"
#lappend signals "EOE"
#lappend signals "seedAcquired"

foreach {signal} $signals {
    add wave -group $groupName_0 -label $signal -position insertpoint sim:/testbench/e_MainProcessor/g_data_delay_links(0)/g_clusters(0)/e_cluster/$signal
#    add wave -group $groupName_1 -label $signal -position insertpoint sim:/testbench/e_MainProcessor/g_data_delay_links(0)/g_clusters(1)/e_cluster/$signal
}


set groupName "Clu0 data"
set signals {}

lappend signals "we"
lappend signals "row"
lappend signals "col"
lappend signals "send"
lappend signals "sent"
lappend signals "flaggedWordIn"
lappend signals "addrA"
lappend signals "dataA_in"
lappend signals "dataA_out"
lappend signals "addrB"
lappend signals "dataB_out"
lappend signals "ramFlaggedWordOut"
lappend signals "flaggedWordOut"
lappend signals "dataValid"
lappend signals "occupancy"


foreach {signal} $signals {
    add wave -group $groupName -label $signal -position insertpoint sim:/testbench/e_MainProcessor/g_data_delay_links(0)/g_clusters(0)/e_cluster/e_cluster_data/$signal
#    add wave -group $groupName_1 -label $signal -position insertpoint sim:/testbench/e_MainProcessor/g_data_delay_links(0)/g_clusters(1)/e_cluster/$signal
}


set addr_group_name addr 

add wave -group $addr_group_name -position insertpoint /testbench/e_MainProcessor/g_data_delay_links(0)/g_clusters(0)/e_cluster/p_acquisition/seed_row
add wave -group $addr_group_name -position insertpoint /testbench/e_MainProcessor/g_data_delay_links(0)/g_clusters(0)/e_cluster/p_acquisition/seed_col
add wave -group $addr_group_name -position insertpoint /testbench/e_MainProcessor/g_data_delay_links(0)/g_clusters(0)/e_cluster/p_acquisition/data_row
add wave -group $addr_group_name -position insertpoint /testbench/e_MainProcessor/g_data_delay_links(0)/g_clusters(0)/e_cluster/p_acquisition/data_col
add wave -group $addr_group_name -position insertpoint /testbench/e_MainProcessor/g_data_delay_links(0)/g_clusters(0)/e_cluster/p_acquisition/clu_row
add wave -group $addr_group_name -position insertpoint /testbench/e_MainProcessor/g_data_delay_links(0)/g_clusters(0)/e_cluster/p_acquisition/clu_col
add wave -group $addr_group_name -position insertpoint sim:/testbench/e_MainProcessor/g_data_delay_links(0)/g_clusters(0)/e_cluster/flaggedWordIn_1.word.address




run 1000 ns

