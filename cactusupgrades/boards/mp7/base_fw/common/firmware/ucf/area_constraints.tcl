# Area constraints for MP7

# Control region (X1Y9)

create_pblock ctrl
resize_pblock [get_pblocks ctrl] -add {CLOCKREGION_X0Y9:CLOCKREGION_X1Y9}
add_cells_to_pblock [get_pblocks ctrl] [get_cells -quiet [list infra ttc ctrl readout]]

# There area  few exceptions to the area constraints above due to resource availability
# In the past overwrote main constraint with "LOC" constraint in ISE.  Does not work
# in Vivado.  Use another pblock instead.

create_pblock mmcm_ttc
add_cells_to_pblock [get_pblocks mmcm_ttc] [get_cells ttc/clocks/mmcm]
resize_pblock [get_pblocks mmcm_ttc] -add {CLOCKREGION_X0Y9}

create_pblock mmcm_infra_clocks
add_cells_to_pblock [get_pblocks mmcm_infra_clocks] [get_cells infra/clocks/mmcm]
resize_pblock [get_pblocks mmcm_infra_clocks] -add {CLOCKREGION_X1Y7}

create_pblock mmcm_infra_eth
add_cells_to_pblock [get_pblocks mmcm_infra_eth] [get_cells infra/eth/mmcm]
resize_pblock [get_pblocks mmcm_infra_eth] -add {CLOCKREGION_X1Y9}

# Basic payload area

create_pblock payload
resize_pblock [get_pblocks payload] -add {SLICE_X30Y0:SLICE_X191Y449}
resize_pblock [get_pblocks payload] -add {RAMB18_X2Y0:RAMB18_X12Y179}
resize_pblock [get_pblocks payload] -add {RAMB36_X2Y0:RAMB36_X12Y89}

# Quad and per-region area constraints

set q_coords {
	{SLICE_X192Y400:SLICE_X221Y449 RAMB18_X14Y160:RAMB18_X14Y179 RAMB18_X13Y170:RAMB18_X13Y179}
	{SLICE_X192Y350:SLICE_X221Y399 RAMB18_X14Y140:RAMB18_X14Y159 RAMB18_X13Y140:RAMB18_X13Y149}
	{SLICE_X192Y300:SLICE_X221Y349 RAMB18_X13Y120:RAMB18_X14Y139}
	{SLICE_X192Y250:SLICE_X221Y299 RAMB18_X14Y100:RAMB18_X14Y119 RAMB18_X13Y110:RAMB18_X13Y119}
	{SLICE_X192Y200:SLICE_X221Y249 RAMB18_X14Y80:RAMB18_X14Y99 RAMB18_X13Y80:RAMB18_X13Y89}
	{SLICE_X192Y150:SLICE_X221Y199 RAMB18_X13Y60:RAMB18_X14Y79}
	{SLICE_X192Y100:SLICE_X221Y149 RAMB18_X14Y40:RAMB18_X14Y59 RAMB18_X13Y50:RAMB18_X13Y59}
	{SLICE_X192Y50:SLICE_X221Y99 RAMB18_X14Y20:RAMB18_X14Y39 RAMB18_X13Y20:RAMB18_X13Y29}
	{SLICE_X192Y0:SLICE_X221Y49 RAMB18_X13Y0:RAMB18_X14Y19}
	{SLICE_X0Y0:SLICE_X29Y49 RAMB18_X0Y0:RAMB18_X1Y19}
	{SLICE_X0Y50:SLICE_X29Y99 RAMB18_X0Y20:RAMB18_X1Y39}	
	{SLICE_X0Y100:SLICE_X29Y149 RAMB18_X0Y40:RAMB18_X1Y59}	
	{SLICE_X0Y150:SLICE_X29Y199 RAMB18_X0Y60:RAMB18_X1Y79}	
	{SLICE_X0Y200:SLICE_X29Y249 RAMB18_X0Y80:RAMB18_X1Y99}	
	{SLICE_X0Y250:SLICE_X29Y299 RAMB18_X0Y100:RAMB18_X1Y119}	
	{SLICE_X0Y300:SLICE_X29Y349 RAMB18_X0Y120:RAMB18_X1Y139}	
	{SLICE_X0Y350:SLICE_X29Y399 RAMB18_X0Y140:RAMB18_X1Y159}	
	{SLICE_X0Y400:SLICE_X29Y449 RAMB18_X0Y160:RAMB18_X1Y179}	
}

set p_coords {
	SLICE_X106Y400:SLICE_X191Y449
	SLICE_X106Y350:SLICE_X191Y399
	SLICE_X106Y300:SLICE_X191Y349
	SLICE_X106Y250:SLICE_X191Y299
	SLICE_X106Y200:SLICE_X191Y249
	SLICE_X106Y150:SLICE_X191Y199
	SLICE_X106Y100:SLICE_X191Y149
	SLICE_X106Y50:SLICE_X191Y99
	SLICE_X106Y0:SLICE_X191Y49
	SLICE_X30Y0:SLICE_X105Y49
	SLICE_X30Y50:SLICE_X105Y99
	SLICE_X30Y100:SLICE_X105Y149
	SLICE_X30Y150:SLICE_X105Y199
	SLICE_X30Y200:SLICE_X105Y249
	SLICE_X30Y250:SLICE_X105Y299
	SLICE_X30Y300:SLICE_X105Y349
	SLICE_X30Y350:SLICE_X105Y399
	SLICE_X30Y400:SLICE_X105Y449
}

for {set i 0} {$i < 18} {incr i} {
	set bq [create_pblock quad_$i]
	resize_pblock $bq -add [lindex $q_coords $i]
	add_cells_to_pblock $bq "datapath/rgen\[$i\].region"
	set br [create_pblock payload_$i]
	resize_pblock $br -add [lindex $p_coords $i]
}

# "Cross-device" registers for readout and TTC path

add_cells_to_pblock [get_pblocks payload_8] [get_cells -quiet datapath/rgen[8].region/pgen.*]


# vito

for {set i_link 0} {$i_link < 1} {incr i_link} {
    set id_0 [expr 0+4*$i_link]
    set id_1 [expr 1+4*$i_link]
    set id_2 [expr 2+4*$i_link]
    set id_3 [expr 3+4*$i_link]
    add_cells_to_pblock [get_pblocks payload_$i_link] [get_cells -quiet payload/AlgorithmInstance/g_links[$id_0].e_link/*]
    add_cells_to_pblock [get_pblocks payload_$i_link] [get_cells -quiet payload/AlgorithmInstance/g_links[$id_1].e_link/*]
    add_cells_to_pblock [get_pblocks payload_$i_link] [get_cells -quiet payload/AlgorithmInstance/g_links[$id_2].e_link/*]
    add_cells_to_pblock [get_pblocks payload_$i_link] [get_cells -quiet payload/AlgorithmInstance/g_links[$id_3].e_link/*]

###    set id [expr 0+4*$i_link]
###    puts "payload/AlgorithmInstance/g_links[$id].e_link/*"
}


#add_cells_to_pblock [get_pblocks payload_0] [get_cells -quiet payload/AlgorithmInstance/g_links[0].e_link/*]
#add_cells_to_pblock [get_pblocks payload_0] [get_cells -quiet payload/AlgorithmInstance/g_links[1].e_link/*]
#add_cells_to_pblock [get_pblocks payload_0] [get_cells -quiet payload/AlgorithmInstance/g_links[2].e_link/*]
#add_cells_to_pblock [get_pblocks payload_0] [get_cells -quiet payload/AlgorithmInstance/g_links[3].e_link/*]

#add_cells_to_pblock [get_pblocks payload_1] [get_cells -quiet payload/AlgorithmInstance/g_links[4].e_link/*]
#add_cells_to_pblock [get_pblocks payload_1] [get_cells -quiet payload/AlgorithmInstance/g_links[5].e_link/*]
#add_cells_to_pblock [get_pblocks payload_1] [get_cells -quiet payload/AlgorithmInstance/g_links[6].e_link/*]
#add_cells_to_pblock [get_pblocks payload_1] [get_cells -quiet payload/AlgorithmInstance/g_links[7].e_link/*]

#add_cells_to_pblock [get_pblocks payload_2] [get_cells -quiet payload/AlgorithmInstance/g_links[8].e_link/*]
#add_cells_to_pblock [get_pblocks payload_2] [get_cells -quiet payload/AlgorithmInstance/g_links[9].e_link/*]
#add_cells_to_pblock [get_pblocks payload_2] [get_cells -quiet payload/AlgorithmInstance/g_links[10].e_link/*]
#add_cells_to_pblock [get_pblocks payload_2] [get_cells -quiet payload/AlgorithmInstance/g_links[11].e_link/*]

#add_cells_to_pblock [get_pblocks payload_3] [get_cells -quiet payload/AlgorithmInstance/g_links[12].e_link/*]
#add_cells_to_pblock [get_pblocks payload_3] [get_cells -quiet payload/AlgorithmInstance/g_links[13].e_link/*]
#add_cells_to_pblock [get_pblocks payload_3] [get_cells -quiet payload/AlgorithmInstance/g_links[14].e_link/*]
#add_cells_to_pblock [get_pblocks payload_3] [get_cells -quiet payload/AlgorithmInstance/g_links[15].e_link/*]

#add_cells_to_pblock [get_pblocks payload_4] [get_cells -quiet payload/AlgorithmInstance/g_links[16].e_link/*]
#add_cells_to_pblock [get_pblocks payload_4] [get_cells -quiet payload/AlgorithmInstance/g_links[17].e_link/*]
#add_cells_to_pblock [get_pblocks payload_4] [get_cells -quiet payload/AlgorithmInstance/g_links[18].e_link/*]
#add_cells_to_pblock [get_pblocks payload_4] [get_cells -quiet payload/AlgorithmInstance/g_links[19].e_link/*]

#add_cells_to_pblock [get_pblocks payload_5] [get_cells -quiet payload/AlgorithmInstance/g_links[20].e_link/*]
#add_cells_to_pblock [get_pblocks payload_5] [get_cells -quiet payload/AlgorithmInstance/g_links[21].e_link/*]
#add_cells_to_pblock [get_pblocks payload_5] [get_cells -quiet payload/AlgorithmInstance/g_links[22].e_link/*]
#add_cells_to_pblock [get_pblocks payload_5] [get_cells -quiet payload/AlgorithmInstance/g_links[23].e_link/*]

#add_cells_to_pblock [get_pblocks payload_6] [get_cells -quiet payload/AlgorithmInstance/g_links[24].e_link/*]
#add_cells_to_pblock [get_pblocks payload_6] [get_cells -quiet payload/AlgorithmInstance/g_links[25].e_link/*]
#add_cells_to_pblock [get_pblocks payload_6] [get_cells -quiet payload/AlgorithmInstance/g_links[26].e_link/*]
#add_cells_to_pblock [get_pblocks payload_6] [get_cells -quiet payload/AlgorithmInstance/g_links[27].e_link/*]

#add_cells_to_pblock [get_pblocks payload_7] [get_cells -quiet payload/AlgorithmInstance/g_links[28].e_link/*]
#add_cells_to_pblock [get_pblocks payload_7] [get_cells -quiet payload/AlgorithmInstance/g_links[29].e_link/*]
#add_cells_to_pblock [get_pblocks payload_7] [get_cells -quiet payload/AlgorithmInstance/g_links[30].e_link/*]
#add_cells_to_pblock [get_pblocks payload_7] [get_cells -quiet payload/AlgorithmInstance/g_links[31].e_link/*]

#add_cells_to_pblock [get_pblocks payload_8] [get_cells -quiet payload/AlgorithmInstance/g_links[32].e_link/*]
#add_cells_to_pblock [get_pblocks payload_8] [get_cells -quiet payload/AlgorithmInstance/g_links[33].e_link/*]
#add_cells_to_pblock [get_pblocks payload_8] [get_cells -quiet payload/AlgorithmInstance/g_links[34].e_link/*]
#add_cells_to_pblock [get_pblocks payload_8] [get_cells -quiet payload/AlgorithmInstance/g_links[35].e_link/*]


#add_cells_to_pblock [get_pblocks payload_9] [get_cells -quiet payload/AlgorithmInstance/g_links[36].e_link/*]
#add_cells_to_pblock [get_pblocks payload_9] [get_cells -quiet payload/AlgorithmInstance/g_links[37].e_link/*]
#add_cells_to_pblock [get_pblocks payload_9] [get_cells -quiet payload/AlgorithmInstance/g_links[38].e_link/*]
#add_cells_to_pblock [get_pblocks payload_9] [get_cells -quiet payload/AlgorithmInstance/g_links[39].e_link/*]

#add_cells_to_pblock [get_pblocks payload_10] [get_cells -quiet payload/AlgorithmInstance/g_links[40].e_link/*]
#add_cells_to_pblock [get_pblocks payload_10] [get_cells -quiet payload/AlgorithmInstance/g_links[41].e_link/*]
#add_cells_to_pblock [get_pblocks payload_10] [get_cells -quiet payload/AlgorithmInstance/g_links[42].e_link/*]
#add_cells_to_pblock [get_pblocks payload_10] [get_cells -quiet payload/AlgorithmInstance/g_links[43].e_link/*]

#add_cells_to_pblock [get_pblocks payload_11] [get_cells -quiet payload/AlgorithmInstance/g_links[44].e_link/*]
#add_cells_to_pblock [get_pblocks payload_11] [get_cells -quiet payload/AlgorithmInstance/g_links[45].e_link/*]
#add_cells_to_pblock [get_pblocks payload_11] [get_cells -quiet payload/AlgorithmInstance/g_links[46].e_link/*]
#add_cells_to_pblock [get_pblocks payload_11] [get_cells -quiet payload/AlgorithmInstance/g_links[47].e_link/*]

#add_cells_to_pblock [get_pblocks payload_12] [get_cells -quiet payload/AlgorithmInstance/g_links[48].e_link/*]
#add_cells_to_pblock [get_pblocks payload_12] [get_cells -quiet payload/AlgorithmInstance/g_links[49].e_link/*]
#add_cells_to_pblock [get_pblocks payload_12] [get_cells -quiet payload/AlgorithmInstance/g_links[50].e_link/*]
#add_cells_to_pblock [get_pblocks payload_12] [get_cells -quiet payload/AlgorithmInstance/g_links[51].e_link/*]

#add_cells_to_pblock [get_pblocks payload_15] [get_cells -quiet payload/AlgorithmInstance/g_links[60].e_link/*]
#add_cells_to_pblock [get_pblocks payload_15] [get_cells -quiet payload/AlgorithmInstance/g_links[61].e_link/*]
#add_cells_to_pblock [get_pblocks payload_15] [get_cells -quiet payload/AlgorithmInstance/g_links[62].e_link/*]
#add_cells_to_pblock [get_pblocks payload_15] [get_cells -quiet payload/AlgorithmInstance/g_links[63].e_link/*]

#add_cells_to_pblock [get_pblocks payload_16] [get_cells -quiet payload/AlgorithmInstance/g_links[64].e_link/*]
#add_cells_to_pblock [get_pblocks payload_16] [get_cells -quiet payload/AlgorithmInstance/g_links[65].e_link/*]
#add_cells_to_pblock [get_pblocks payload_16] [get_cells -quiet payload/AlgorithmInstance/g_links[66].e_link/*]
#add_cells_to_pblock [get_pblocks payload_16] [get_cells -quiet payload/AlgorithmInstance/g_links[67].e_link/*]

#add_cells_to_pblock [get_pblocks payload_17] [get_cells -quiet payload/AlgorithmInstance/g_links[68].e_link/*]
#add_cells_to_pblock [get_pblocks payload_17] [get_cells -quiet payload/AlgorithmInstance/g_links[69].e_link/*]
#add_cells_to_pblock [get_pblocks payload_17] [get_cells -quiet payload/AlgorithmInstance/g_links[70].e_link/*]
#add_cells_to_pblock [get_pblocks payload_17] [get_cells -quiet payload/AlgorithmInstance/g_links[71].e_link/*]

#add_cells_to_pblock [get_pblocks payload_13] [get_cells -quiet payload/AlgorithmInstance/g_links[52].e_link/*]
#add_cells_to_pblock [get_pblocks payload_13] [get_cells -quiet payload/AlgorithmInstance/g_links[53].e_link/*]
#add_cells_to_pblock [get_pblocks payload_13] [get_cells -quiet payload/AlgorithmInstance/g_links[54].e_link/*]
#add_cells_to_pblock [get_pblocks payload_13] [get_cells -quiet payload/AlgorithmInstance/g_links[55].e_link/*]

#add_cells_to_pblock [get_pblocks payload_14] [get_cells -quiet payload/AlgorithmInstance/g_links[56].e_link/*]
#add_cells_to_pblock [get_pblocks payload_14] [get_cells -quiet payload/AlgorithmInstance/g_links[57].e_link/*]
#add_cells_to_pblock [get_pblocks payload_14] [get_cells -quiet payload/AlgorithmInstance/g_links[58].e_link/*]
#add_cells_to_pblock [get_pblocks payload_14] [get_cells -quiet payload/AlgorithmInstance/g_links[59].e_link/*]

