
############################################################################################################

VIVADO_PROJECT_NAME = top

PROJECT = ../vivado/$(VIVADO_PROJECT_NAME)

CACTUS_COMPONENTS = ../../../components
IP_SOURCES = $(PROJECT)/$(VIVADO_PROJECT_NAME).srcs/sources_1/ip
HDL_SOURCES = ../firmware/hdl

SIM_SCRIPTS = $(PROJECT)/$(VIVADO_PROJECT_NAME).ip_user_files/sim_scripts
VIVADO_SIM_LIBS_PATH = $(PROJECT)/$(VIVADO_PROJECT_NAME).sim/vivado_msim_libs


SIM_PATH = ${shell pwd}

#
## ip cores that needs to genereate their own sim lib
#
IPs = variable_data_delay
IPs += fifo_read_pointers_delay_ram
IPs += clu_dist_mem_row

############################################################################################################

all:

	vcom -explicit  ../../calol2/algorithm_components/firmware/hdl/common/constants_pkg.vhd

#
## project specific constants and types 
#

	vcom -explicit  $(CACTUS_COMPONENTS)/hgc_datapath/firmware/hdl/hgc_constants.vhd

	vcom -explicit  $(CACTUS_COMPONENTS)/mp7_datapath/firmware/hdl/mp7_data_types.vhd
	vcom -explicit  $(CACTUS_COMPONENTS)/hgc_datapath/firmware/hdl/hgc_data_types.vhd
	vcom -explicit  $(CACTUS_COMPONENTS)/ipbus_core/firmware/hdl/ipbus_package.vhd

	vcom -explicit  $(CACTUS_COMPONENTS)/hgc_datapath/firmware/hdl/mp72hgc.vhd
	vcom -explicit  $(CACTUS_COMPONENTS)/hgc_datapath/firmware/hdl/hgc2mp7.vhd
#	vcom -explicit  $(CACTUS_COMPONENTS)/hgc_datapath/firmware/hdl/hgc_functions.vhd
#	vcom -explicit  $(CACTUS_COMPONENTS)/hgc_datapath/firmware/hdl/hgc_procedures.vhd

#
## common components
#
	vcom -explicit  $(HDL_SOURCES)/types_pkg.vhd


#
## IPs
#
	vcom -explicit  $(IP_SOURCES)/variable_data_delay/sim/variable_data_delay.vhd
	vcom -explicit  $(IP_SOURCES)/fifo_read_pointers_delay_ram/sim/fifo_read_pointers_delay_ram.vhd
	vcom -explicit  $(IP_SOURCES)/clu_dist_mem_row/sim/clu_dist_mem_row.vhd

#
## project (common) 
#
	vcom -explicit  $(HDL_SOURCES)/FunkyMiniBus.vhd

	vcom -explicit  $(HDL_SOURCES)/GenRomClocked.vhd

	vcom -explicit  $(HDL_SOURCES)/MP7CaptureFileReader.vhd
	vcom -explicit  $(HDL_SOURCES)/MP7CaptureFileWriter.vhd

#
## project (HGC specific)
#

	vcom -explicit  $(HDL_SOURCES)/DataVariableDelay.vhd

	vcom -explicit  $(HDL_SOURCES)/SeedDistributor.vhd

	vcom -explicit  $(HDL_SOURCES)/SeedingLink.vhd
	vcom -explicit  $(HDL_SOURCES)/SeedingLinks.vhd


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
ip_libs: FORCE
	echo $(IPs)
	@for ip in $(IPs) ; do \
	echo $(SIM_SCRIPTS)/$$ip/modelsim ; \
	cd $(SIM_SCRIPTS)/$$ip/modelsim ; \
	ls ; \
	./$$ip.sh ; \
	cd - ; \
	done

clean_ip_libs: 
	@for ip in $(IPs) ; do cd $(SIM_SCRIPTS)/$$ip/modelsim ; ./$$ip.sh -reset_run ; cd - ; done

libs: clean_ip_libs ip_libs

	vlib work
#	mkdir -p ip_libs
#	vlib ip_libs/blk_mem_gen_v8_3_1
#	vlib ip_libs/fifo_generator_v13_0_1
#	vlib ip_libs/dist_mem_gen_v8_0_9
#
	vmap blk_mem_gen_v8_3_1     $(SIM_SCRIPTS)/variable_data_delay/modelsim/msim/blk_mem_gen_v8_3_1
	vmap fifo_generator_v13_0_1 $(SIM_SCRIPTS)/fifo_read_pointers_delay_ram/modelsim/msim/fifo_generator_v13_0_1
	vmap dist_mem_gen_v8_0_9    $(SIM_SCRIPTS)/clu_dist_mem_row/modelsim/msim/dist_mem_gen_v8_0_9

	vmap secureip $(VIVADO_SIM_LIBS_PATH)/secureip
	vmap unifast  $(VIVADO_SIM_LIBS_PATH)/unifast  
	vmap unimacro $(VIVADO_SIM_LIBS_PATH)/unimacro
	vmap unisim   $(VIVADO_SIM_LIBS_PATH)/unisim

clean_libs: clean_ip_libs
	rm -rf ip_libs
	rm -rf work

deep_clean: clean_libs
	rm -f *txt
	rm -f modelsim.ini
	rm -rf work
	rm -f *wlf
	rm -f transcript
sim:
	vsim -novopt work.testbench

sim_no_gui:
	vsim -c work.testbench

FORCE:
