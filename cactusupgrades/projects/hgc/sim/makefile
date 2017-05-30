
############################################################################################################

VIVADO_PROJECT_NAME = top_2016

PROJECT = ../vivado/$(VIVADO_PROJECT_NAME)

CACTUS_COMPONENTS = ../../../components
IP_SOURCES = $(PROJECT)/$(VIVADO_PROJECT_NAME).srcs/sources_1/ip
HDL_SOURCES = ../firmware/hdl

SIM_SCRIPTS = $(PROJECT)/$(VIVADO_PROJECT_NAME).ip_user_files/sim_scripts
VIVADO_SIM_LIBS_PATH = $(PROJECT)/$(VIVADO_PROJECT_NAME).sim/vivado_msim_libs


SIM_PATH = ${shell pwd}

LIB_NAME = work

#
## ip cores that needs to genereate their own sim lib
#
#IPs = variable_data_delay
#IPs += fifo_read_pointers_delay_ram
#IPs += clu_dist_mem_row

############################################################################################################

all:

	vcom -explicit  ../../calol2/algorithm_components/firmware/hdl/common/constants_pkg.vhd

#
## INFOSTRUCTURE
#
	vcom -explicit  $(CACTUS_COMPONENTS)/mp7_datapath/firmware/hdl/mp7_data_types.vhd
	vcom -explicit  $(CACTUS_COMPONENTS)/ipbus_core/firmware/hdl/ipbus_package.vhd

#
## IPs
#
#	vcom -explicit  $(IP_SOURCES)/variable_data_delay/sim/variable_data_delay.vhd
#	vcom -explicit  $(IP_SOURCES)/fifo_read_pointers_delay_ram/sim/fifo_read_pointers_delay_ram.vhd
#	vcom -explicit  $(IP_SOURCES)/clu_data_ram/sim/clu_data_ram.vhd	
	vlog  $(IP_SOURCES)/variable_data_delay/sim/variable_data_delay.v
	vlog  $(IP_SOURCES)/fifo_read_pointers_delay_ram/sim/fifo_read_pointers_delay_ram.v
	vlog  $(IP_SOURCES)/clu_data_ram/sim/clu_data_ram.v

#
## project (common) 
#
	vcom -explicit  $(HDL_SOURCES)/FunkyMiniBus.vhd

	vcom -explicit  $(HDL_SOURCES)/GenRomClocked.vhd

	vcom -explicit  $(HDL_SOURCES)/MP7CaptureFileReader.vhd
	vcom -explicit  $(HDL_SOURCES)/MP7CaptureFileWriter.vhd

#
## project (data formats and conversions)
#
	vcom -explicit $(HDL_SOURCES)/dataFormats/hgc_data_types.vhd

	vcom -explicit $(HDL_SOURCES)/types_pkg.vhd

	vcom -explicit $(HDL_SOURCES)/dataFormats/hgc_constants.vhd

	vcom -explicit $(HDL_SOURCES)/dataFormats/mp72hgc.vhd
	vcom -explicit $(HDL_SOURCES)/dataFormats/hgc2mp7.vhd
	vcom -explicit $(HDL_SOURCES)/dataFormats/hgc2ram.vhd
	vcom -explicit $(HDL_SOURCES)/dataFormats/ram2hgc.vhd

#
## project (HGC specific)
#

	vcom -explicit  $(HDL_SOURCES)/DataVariableDelay.vhd

	vcom -explicit  $(HDL_SOURCES)/SeedDistributor.vhd

	vcom -explicit  $(HDL_SOURCES)/SeedingLink.vhd
	vcom -explicit  $(HDL_SOURCES)/SeedingLinks.vhd


# cluster 
	vcom -explicit  $(HDL_SOURCES)/ComputeClustering.vhd
#	vcom -explicit  $(HDL_SOURCES)/ClusterRow.vhd
	vcom -explicit  $(HDL_SOURCES)/ClusterData.vhd
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

#ip_libs : FORCE 
#
#

#clean_ip_libs : FORCE 
#	@for ip in $(IPs) ; do cd $(SIM_SCRIPTS)/$$ip/modelsim ; ./$$ip.sh -reset_run ; cd - ; done

map_libs: clean

	vlib $(LIB_NAME)

	@echo ""
	@echo " --- Mapping : generic Vivado libs"
	@vmap secureip $(VIVADO_SIM_LIBS_PATH)/secureip
	@vmap unifast  $(VIVADO_SIM_LIBS_PATH)/unifast  
	@vmap unimacro $(VIVADO_SIM_LIBS_PATH)/unimacro
	@vmap unimacro_ver $(VIVADO_SIM_LIBS_PATH)/unimacro_ver
	@vmap unisim   $(VIVADO_SIM_LIBS_PATH)/unisim
	@vmap unisims_ver   $(VIVADO_SIM_LIBS_PATH)/unisims_ver

	@echo ""
	@echo " --- Mapping : specific IP libs"
	vmap blk_mem_gen_v8_3_5     $(VIVADO_SIM_LIBS_PATH)/blk_mem_gen_v8_3_5
	vmap fifo_generator_v13_0_5 $(VIVADO_SIM_LIBS_PATH)/fifo_generator_v13_0_5
	vmap dist_mem_gen_v8_0_11   $(VIVADO_SIM_LIBS_PATH)/dist_mem_gen_v8_0_11

#	@echo ""
#	@echo " --- Mapping : IP libs "
#	@echo $(IPs)
#	@for ip in $(IPs) ; do \
#	vmap secureip $(VIVADO_SIM_LIBS_PATH)/secureip ; \
#	vmap unifast  $(VIVADO_SIM_LIBS_PATH)/unifast  ; \
#	vmap unimacro $(VIVADO_SIM_LIBS_PATH)/unimacro ; \
#	vmap unimacro_ver $(VIVADO_SIM_LIBS_PATH)/unimacro_ver ; \
#	vmap unisim   $(VIVADO_SIM_LIBS_PATH)/unisim ; \
#	vmap unisims_ver   $(VIVADO_SIM_LIBS_PATH)/unisims_ver ; \
#	echo $(SIM_SCRIPTS)/$$ip/modelsim ; \
#	cd $(SIM_SCRIPTS)/$$ip/modelsim ; \
#	ls ; \
#	./$$ip.sh ; \
#	cd - ; \
#	done

clean: FORCE
	rm -f *txt
	rm -f modelsim.ini
	rm -rf $(LIB_NAME)
	rm -f *wlf
	rm -f transcript

sim:
	vsim -gsourcefile="data/out.mp7" -gdestinationfile="results/out.mp7" -L $(LIB_NAME) -t 1ps -L dist_mem_gen_v8_0_11 -L blk_mem_gen_v8_3_5 -L unisims_ver -L unimacro_ver -L secureip -lib $(LIB_NAME) -novopt $(LIB_NAME).TestBench
#	vsim -voptargs=""+acc"" -L xil_defaultlib -L xpm -L dist_mem_gen_v8_0_11 -L blk_mem_gen_v8_3_5 -L unisims_ver -L unimacro_ver -L secureip -lib xil_defaultlib xil_defaultlib.TestBench xil_defaultlib.glbl -novopt 
#	vsim -novopt work.testbench
#	vsim work.testbench

sim_no_gui:
	vsim -c -gsourcefile="data/outR_0.mp7" -gdestinationfile="results/outR_0.mp7" -L $(LIB_NAME) -t 1ps -L dist_mem_gen_v8_0_11 -L blk_mem_gen_v8_3_5 -L unisims_ver -L unimacro_ver -L secureip -lib $(LIB_NAME) -novopt $(LIB_NAME).TestBench

FORCE:
