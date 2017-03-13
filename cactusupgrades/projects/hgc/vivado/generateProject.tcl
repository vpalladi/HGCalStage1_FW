##
## This script generates the HGC FW in vivado 
##   Vito Palladino (vito.palladino@cern.ch) 
##   10/03/2017
##

# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir "."

# Use origin directory path location variable, if specified in the tcl shell
if { [info exists ::origin_dir_loc] } {
  set origin_dir $::origin_dir_loc
}

variable script_file
set script_file "generateProject.tcl"

# Help information for this script
proc help {} {
  variable script_file
  puts "\nDescription:"
  puts ""
  puts ""
  puts "Syntax:"
  puts "$script_file"
  puts "$script_file -tclargs \[--origin_dir <path>\]"
  puts "$script_file -tclargs \[--help\]\n"
  puts "Usage:"
  puts "Name                   Description"
  puts "-------------------------------------------------------------------------"
  puts "\[--origin_dir <path>\]  Determine source file paths wrt this path. Default"
  puts "                       origin_dir path value is \".\", otherwise, the value"
  puts "                       that was set with the \"-paths_relative_to\" switch"
  puts "                       when this script was generated.\n"
  puts "\[--help\]               Print help information for this script"
  puts "-------------------------------------------------------------------------\n"
  exit 0
}

if { $::argc > 0 } {
  for {set i 0} {$i < [llength $::argc]} {incr i} {
    set option [string trim [lindex $::argv $i]]
    switch -regexp -- $option {
      "--origin_dir" { incr i; set origin_dir [lindex $::argv $i] }
      "--help"       { help }
      default {
        if { [regexp {^-} $option] } {
          puts "ERROR: Unknown option '$option' specified, please type '$script_file -tclargs --help' for usage info.\n"
          return 1
        }
      }
    }
  }
}

##################
# Create project #
##################
create_project top ./top

# Set project properties
set obj [get_projects top]
set_property "compxlib.modelsim_compiled_library_dir" "../sim/vivado_libs" $obj
set_property "default_lib" "xil_defaultlib" $obj
set_property "part" "xc7vx690tffg1927-2" $obj
set_property "sim.ip.auto_export_scripts" "1" $obj
set_property "simulator_language" "Mixed" $obj
set_property "target_language" "VHDL" $obj
set_property "target_simulator" "ModelSim" $obj


#############################################
# Create 'sources_1' fileset (if not found) #
#############################################
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}

# Set 'sources_1' fileset object
set obj [get_filesets sources_1]

set file_vhd [open "vhd" r]
set vhd_files [read $file_vhd]

foreach f $vhd_files {
    puts "HGCINFO: adding file $f"
    add_files -norecurse -fileset $obj "[file normalize "$origin_dir$f"]"
}

# adding the ips and generating the targets 
set file_ip [open "ip" r]
set ip_files [read $file_ip]

foreach f $ip_files {
    puts "HGCINFO: adding file $origin_dir$f"
    add_files -norecurse -fileset $obj "[file normalize "$origin_dir$f"]"
    import_ip "[file normalize "$origin_dir$f"]"


    set ip_name [lindex [ split [lindex [split $f /] end] .] 0 ]
    
    set a "/top/top.srcs/sources_1/ip/"
    set b "/" 
    set c ".xci"

    set ip_local $origin_dir$a$ip_name$b$ip_name$c
    generate_target all [get_files $ip_local]
    export_ip_user_files -of_objects [get_files $ip_local] -no_script -force -quiet
    create_ip_run [get_files -of_objects [get_fileset sources_1] $ip_local]
    set c "_synth_1"
    set synth $ip_name$c
    launch_run -jobs 6 $synth 
    set sim_scripts_dir "/top/top.ip_user_files/sim_scripts"
    export_simulation -of_objects [get_files $ip_local] -directory $origin_dir$sim_scripts_dir -force -quiet

}

set_property "top" "top" $obj


#############################################
# Create 'constrs_1' fileset (if not found) #
#############################################
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}

# Set 'constrs_1' fileset object
set obj [get_filesets constrs_1]

# Add/Import constrs file and set constrs file properties
set file "[file normalize "$origin_dir/../../../boards/mp7/base_fw/common/firmware/ucf/mp7_mgt.tcl"]"
set file_added [add_files -fileset constrs_1 $file]
set file "ucf/mp7_mgt.tcl"
set file_obj [get_files -of_objects [get_filesets constrs_1] [list "*$file"]]
set_property "file_type" "TCL" $file_obj
set_property "used_in" "implementation" $file_obj
set_property "used_in_simulation" "0" $file_obj
set_property "used_in_synthesis" "0" $file_obj

# Add/Import constrs file and set constrs file properties
set file "[file normalize "$origin_dir/../../../boards/mp7/base_fw/common/firmware/ucf/area_constraints.tcl"]"
set file_added [add_files -fileset constrs_1 $file]
set file "ucf/area_constraints.tcl"
set file_obj [get_files -of_objects [get_filesets constrs_1] [list "*$file"]]
set_property "file_type" "TCL" $file_obj
set_property "used_in" "implementation" $file_obj
set_property "used_in_simulation" "0" $file_obj
set_property "used_in_synthesis" "0" $file_obj

# Add/Import constrs file and set constrs file properties
set file "[file normalize "$origin_dir/../../../boards/mp7/base_fw/common/firmware/ucf/clock_constraints.tcl"]"
set file_added [add_files -fileset constrs_1 $file]
set file "ucf/clock_constraints.tcl"
set file_obj [get_files -of_objects [get_filesets constrs_1] [list "*$file"]]
set_property "file_type" "TCL" $file_obj
set_property "used_in" "implementation" $file_obj
set_property "used_in_simulation" "0" $file_obj
set_property "used_in_synthesis" "0" $file_obj

# Add/Import constrs file and set constrs file properties
set file "[file normalize "$origin_dir/../../../boards/mp7/base_fw/common/firmware/ucf/pins_xe.tcl"]"
set file_added [add_files -fileset constrs_1 $file]
set file "ucf/pins_xe.tcl"
set file_obj [get_files -of_objects [get_filesets constrs_1] [list "*$file"]]
set_property "file_type" "TCL" $file_obj
set_property "used_in" "implementation" $file_obj
set_property "used_in_simulation" "0" $file_obj
set_property "used_in_synthesis" "0" $file_obj

# Add/Import constrs file and set constrs file properties
set file "[file normalize "$origin_dir/../../../boards/mp7/base_fw/common/firmware/ucf/pins.tcl"]"
set file_added [add_files -fileset constrs_1 $file]
set file "ucf/pins.tcl"
set file_obj [get_files -of_objects [get_filesets constrs_1] [list "*$file"]]
set_property "file_type" "TCL" $file_obj
set_property "used_in" "implementation" $file_obj
set_property "used_in_simulation" "0" $file_obj
set_property "used_in_synthesis" "0" $file_obj

# Add/Import constrs file and set constrs file properties
set file "[file normalize "$origin_dir/../../../boards/mp7/base_fw/common/firmware/ucf/impl_settings.tcl"]"
set file_added [add_files -fileset constrs_1 $file]
set file "ucf/impl_settings.tcl"
set file_obj [get_files -of_objects [get_filesets constrs_1] [list "*$file"]]
set_property "file_type" "TCL" $file_obj
set_property "used_in" "implementation" $file_obj
set_property "used_in_simulation" "0" $file_obj
set_property "used_in_synthesis" "0" $file_obj

# Set 'constrs_1' fileset properties
#set obj [get_filesets constrs_1]

#########################################
# Create 'sim_1' fileset (if not found) #
#########################################
if {[string equal [get_filesets -quiet sim_1] ""]} {
  create_fileset -simset sim_1
}

# Set 'sim_1' fileset properties
set obj [get_filesets sim_1]
set_property "modelsim.log_all_signals" "0" $obj
set_property "modelsim.use_explicit_decl" "1" $obj
set_property "modelsim.vhdl_syntax" "93" $obj
set_property "top" "rxdata_simple_cdc_buf_asymmetric" $obj

#######################################
# Create 'synth_1' run (if not found) #
#######################################
if {[string equal [get_runs -quiet synth_1] ""]} {
  create_run -name synth_1 -part xc7vx690tffg1927-2 -flow {Vivado Synthesis 2015} -strategy "Vivado Synthesis Defaults" -constrset constrs_1
} else {
  set_property strategy "Vivado Synthesis Defaults" [get_runs synth_1]
  set_property flow "Vivado Synthesis 2015" [get_runs synth_1]
}
set obj [get_runs synth_1]
set_property "needs_refresh" "1" $obj
set_property "part" "xc7vx690tffg1927-2" $obj
set_property "steps.synth_design.args.flatten_hierarchy" "none" $obj

# set the current synth run
current_run -synthesis [get_runs synth_1]

######################################
# Create 'impl_1' run (if not found) #
######################################
if {[string equal [get_runs -quiet impl_1] ""]} {
  create_run -name impl_1 -part xc7vx690tffg1927-2 -flow {Vivado Implementation 2015} -strategy "Vivado Implementation Defaults" -constrset constrs_1 -parent_run synth_1
} else {
  set_property strategy "Vivado Implementation Defaults" [get_runs impl_1]
  set_property flow "Vivado Implementation 2015" [get_runs impl_1]
}
set obj [get_runs impl_1]
set_property "needs_refresh" "1" $obj
set_property "part" "xc7vx690tffg1927-2" $obj
set_property "steps.write_bitstream.args.readback_file" "0" $obj
set_property "steps.write_bitstream.args.verbose" "0" $obj

# set the current impl run
current_run -implementation [get_runs impl_1]


puts "INFO: Project created:top"
