

#restart -f

add wave -label "CLK" -position insertpoint sim:/testbench/p_MainProcessor/clk
add wave -position insertpoint sim:/testbench/p_MainProcessor/linksIn(0)
add wave -position insertpoint sim:/testbench/p_MainProcessor/flaggedData(0)
#add wave -position insertpoint sim:/testbench/p_MainProcessor/sdist_flaggedDataOut(0)
#add wave -position insertpoint sim:/testbench/p_MainProcessor/sdist_bxCounter(0)

######  Cluster  ######
set groupName_0 "Cluster 0"
set groupName_1 "Cluster 1"

set signals {}
lappend signals "state" 
lappend signals "flaggedWordIn" 
lappend signals "flaggedWordInForSeeding" 
lappend signals "weSeed"
lappend signals "EOE"
lappend signals "seedAcquired"

foreach {signal} $signals {
    add wave -group $groupName_0 -label $signal -position insertpoint sim:/testbench/p_MainProcessor/gen_data_delay_links(0)/gen_clusters(0)/e_cluster/$signal
    add wave -group $groupName_1 -label $signal -position insertpoint sim:/testbench/p_MainProcessor/gen_data_delay_links(0)/gen_clusters(1)/e_cluster/$signal
}

######  Data variable Delay  ######
set groupName "DataVariableDelay"

set signals {}
lappend signals "flaggedWordIn"
lappend signals "mp7WordToRam"

lappend signals "data_ram_ena"
lappend signals "data_ram_dina"
lappend signals "data_ram_addr_wr"
lappend signals "data_ram_wea(0)"
lappend signals "data_ram_enb"
lappend signals "data_ram_addr_rd"
lappend signals "data_ram_doutb"

lappend signals "rp_fifo_empty"
lappend signals "rp_fifo_wr_en"
lappend signals "rp_fifo_din"
lappend signals "rp_fifo_rd_en"
lappend signals "rp_fifo_dout"

foreach {signal} $signals {
    if { $signal == "data_ram_dina" || $signal == "data_ram_doutb" } { 
        add wave -group $groupName -color "Gold" -label $signal -position insertpoint sim:/testbench/p_MainProcessor/gen_data_delay_links(0)/e_DataVariableDelay/$signal
    } else {
        add wave -group $groupName -label $signal -position insertpoint sim:/testbench/p_MainProcessor/gen_data_delay_links(0)/e_DataVariableDelay/$signal
    }

}


run 100 ns

