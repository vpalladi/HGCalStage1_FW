
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
## MP7 infrastructure
#
	vcom -explicit  $(CACTUS_COMPONENTS)/mp7_datapath/firmware/hdl/mp7_data_types.vhd
	vcom -explicit  $(CACTUS_COMPONENTS)/ipbus_core/firmware/hdl/ipbus_package.vhd

#
## IPs
#
#	vcom -explicit  $(IP_SOURCES)/variable_data_delay/sim/variable_data_delay.vhd
#	vcom -explicit  $(IP_SOURCES)/fifo_read_pointers_delay_ram/sim/fifo_read_pointers_delay_ram.vhd
#	vcom -explicit  $(IP_SOURCES)/clu_data_ram/sim/clu_data_ram.vhd	
#	vlog  $(IP_SOURCES)/variable_data_delay/sim/variable_data_delay.v
#	vlog  $(IP_SOURCES)/fifo_read_pointers_delay_ram/sim/fifo_read_pointers_delay_ram.v
#	vlog  $(IP_SOURCES)/clu_data_ram/sim/clu_data_ram.v
#	vlog  $(IP_SOURCES)/fifo_merge/sim/fifo_merge.v
	vlog  $(IP_SOURCES)/blk_ram_merge/sim/blk_ram_merge.v
	vlog  $(IP_SOURCES)/fifo_addresses/sim/fifo_addresses.v
	vlog  $(IP_SOURCES)/fifo_output_stage/sim/fifo_output_stage.v


#
## common 
#
	vcom -explicit $(HDL_SOURCES)/common/FunkyMiniBus.vhd
	vcom -explicit $(HDL_SOURCES)/common/GenRomClocked.vhd

#
## IO
#
	vcom -explicit $(HDL_SOURCES)/IO/MP7CaptureFileReader.vhd
	vcom -explicit $(HDL_SOURCES)/IO/MP7CaptureFileWriter.vhd


#
## project (data formats and conversions)
#
	vcom -explicit $(HDL_SOURCES)/dataFormats/types_pkg.vhd
	vcom -explicit $(HDL_SOURCES)/dataFormats/hgc_data_types.vhd

#
## project (algo)
#
	vcom -explicit $(HDL_SOURCES)/linkConcentrator.vhd
	vcom -explicit $(HDL_SOURCES)/inputStage.vhd	
	vcom -explicit $(HDL_SOURCES)/outputStage.vhd
	vcom -explicit $(HDL_SOURCES)/retmux.vhd

#
## top
#
	vcom -explicit  $(HDL_SOURCES)/top.vhd


#########################################################################################################################
#
# testbench related
#
	vcom -explicit  $(HDL_SOURCES)/testbench/LinkTypes_pkg.vhd
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
	vmap fifo_generator_v13_1_3 $(VIVADO_SIM_LIBS_PATH)/fifo_generator_v13_1_3
	vmap fifo_generator_v13_0_5 $(VIVADO_SIM_LIBS_PATH)/fifo_generator_v13_0_5
	vmap dist_mem_gen_v8_0_11   $(VIVADO_SIM_LIBS_PATH)/dist_mem_gen_v8_0_11


clean: FORCE
	rm -f *txt
	rm -f modelsim.ini
	rm -rf $(LIB_NAME)
	rm -f *wlf
	rm -f transcript

sim:
	vsim -gsourcefile="out.mp7"  -L $(LIB_NAME) -t 1ps -L fifo_generator_v13_1_3 -L fifo_generator_v13_0_5 -L dist_mem_gen_v8_0_11 -L blk_mem_gen_v8_3_5 -L unisims_ver -L unimacro_ver -L secureip -lib $(LIB_NAME) -novopt $(LIB_NAME).TestBench

sim_no_gui:
	vsim -c -gsourcefile="out.mp7" -gdestinationfile="out.mp7" -L $(LIB_NAME) -t 1ps -L dist_mem_gen_v8_0_11 -L blk_mem_gen_v8_3_5 -L unisims_ver -L unimacro_ver -L secureip -lib $(LIB_NAME) -novopt $(LIB_NAME).TestBench

FORCE:
