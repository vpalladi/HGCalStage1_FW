
############################################################################################################

VIVADO_PROJECT_NAME = top

PROJECT = ../vivado/$(VIVADO_PROJECT_NAME)

CACTUS_COMPONENTS = ../../../components
IP_SOURCES = ../vivado/top/top.srcs/sources_1/ip/
HDL_SOURCES = ../firmware/hdl

SIM_SCRIPTS = $(PROJECT)/$(VIVADO_PROJECT_NAME).ip_user_files/sim_scripts

SIM_PATH = ${shell pwd}

#IPs = ${shell ls $(SIM_SCRIPTS)}
IPs = variable_data_delay
IPs += fifo_read_pointers_delay_ram
IPs += clu_dist_mem_row

############################################################################################################

all:
#
## common components
#
	vcom -explicit  $(CACTUS_COMPONENTS)/mp7_datapath/firmware/hdl/mp7_data_types.vhd
	vcom -explicit  $(CACTUS_COMPONENTS)/hgc_datapath/firmware/hdl/hgc_data_types.vhd
	vcom -explicit  $(CACTUS_COMPONENTS)/ipbus_core/firmware/hdl/ipbus_package.vhd

	vcom -explicit  $(CACTUS_COMPONENTS)/hgc_datapath/firmware/hdl/mp72hgc.vhd
	vcom -explicit  $(CACTUS_COMPONENTS)/hgc_datapath/firmware/hdl/hgc2mp7.vhd

#
## project specific constants and types 
#
	vcom -explicit  $(HDL_SOURCES)/constants_pkg.vhd
	vcom -explicit  $(HDL_SOURCES)/types_pkg.vhd

#
## IPs
#
	vcom -explicit  $(IP_SOURCES)/variable_data_delay/sim/variable_data_delay.vhd
	vcom -explicit  $(IP_SOURCES)/fifo_read_pointers_delay_ram/sim/fifo_read_pointers_delay_ram.vhd
	vcom -explicit  $(IP_SOURCES)/clu_dist_mem_row/sim/clu_dist_mem_row.vhd

#
## project 
#

	vcom -explicit  $(HDL_SOURCES)/FunkyMiniBus.vhd

	vcom -explicit  $(HDL_SOURCES)/GenRomClocked.vhd

	vcom -explicit  $(HDL_SOURCES)/SeedingLink.vhd
	vcom -explicit  $(HDL_SOURCES)/SeedingLinks.vhd
	vcom -explicit  $(HDL_SOURCES)/DataVariableDelay.vhd


#vcom -explicit  /home/vpalladi/FW/MP7/cactusupgrades/boards/mp7/base_fw/mp7xe_690/firmware/hdl/mp7_brd_decl.vhd
#vcom -explicit  /home/vpalladi/FW/MP7/cactusupgrades/boards/mp7/base_fw/common/firmware/hdl/mp7_top_decl.vhd
#vcom -explicit  /home/vpalladi/FW/MP7/cactusupgrades/projects/hgc/firmware/hdl/top_decl.trunk.vhd
#vcom -explicit  /home/vpalladi/FW/MP7/cactusupgrades/components/mp7_ttc/firmware/hdl/mp7_ttc_decl.vhd

#vcom -explicit  /home/vpalladi/FW/MP7/cactusupgrades/projects/hgc/firmware/hdl/mp7_payload.trunk.vhd
	vcom -explicit  $(HDL_SOURCES)/MP7CaptureFileReader.vhd
	vcom -explicit  $(HDL_SOURCES)/MP7CaptureFileWriter.vhd

# seed distributor
	vcom -explicit  $(HDL_SOURCES)/SeedDistributor.vhd

# cluster 
	vcom -explicit  $(HDL_SOURCES)/ComputeClustering.vhd
	vcom -explicit  $(HDL_SOURCES)/ClusterRow.vhd
	vcom -explicit  $(HDL_SOURCES)/Cluster.vhd

#
## top
#
	vcom -explicit  $(HDL_SOURCES)/top.vhd


#########################################################################################################################
#
# testbench related
#
	vcom -explicit  $(HDL_SOURCES)/testbench/LinkTypes_pkg.vhd
	vcom -explicit  $(HDL_SOURCES)/testbench/helpers_pkg.vhd
	vcom -explicit  $(HDL_SOURCES)/testbench/LinkReference_pkg.vhd

#
# test benches
#
	vcom -explicit  $(HDL_SOURCES)/testbench/TestBench.vhd
#	vcom -explicit  $(PROJECT)/firmware/hdl/testbench/TestBench_clu.vhd



# generates the IP cores libs 
ip_libs: 
	@for ip in $(IPs) ; do \
	cd $(SIM_SCRIPTS)/$$ip/modelsim ; \
	./$$ip.sh ; \
	cd - ; \
	done

clean_ip_libs: 
	@for ip in $(IPs) ; do cd $(SIM_SCRIPTS)/$$ip/modelsim ; ./$$ip.sh -reset_run ; cd - ; done

libs: clean_ip_libs ip_libs

	vlib work
	mkdir -p ip_libs
	vlib ip_libs/blk_mem_gen_v8_3_1
	vlib ip_libs/fifo_generator_v13_0_1
	vlib ip_libs/dist_mem_gen_v8_0_9

	vmap blk_mem_gen_v8_3_1     $(SIM_SCRIPTS)/variable_data_delay/modelsim/msim/blk_mem_gen_v8_3_1
	vmap fifo_generator_v13_0_1 $(SIM_SCRIPTS)/fifo_read_pointers_delay_ram/modelsim/msim/fifo_generator_v13_0_1
	vmap dist_mem_gen_v8_0_9    $(SIM_SCRIPTS)/clu_dist_mem_row/modelsim/msim/dist_mem_gen_v8_0_9

	vmap secureip ./vivado_libs/secureip
	vmap unifast  ./vivado_libs/unifast  
	vmap unimacro ./vivado_libs/unimacro
	vmap unisim   ./vivado_libs/unisim

clean_libs:
	rm -rf ip_libs
	rm -rf work
