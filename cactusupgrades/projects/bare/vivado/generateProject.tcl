##
## This script generates the HGC FW in vivado 
##   Vito Palladino (vito.palladino@cern.ch) 
##   10/03/2017
##
##   modified 02/08/2017 : al the sources are in ./src
##

# Set the reference directory for source file relative paths (by default the value is script directory path)
set project_name "top"
set origin_dir "."
set vivado_sim_libs_path "./$project_name/$project_name.sim/vivado_msim_libs"

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
create_project $project_name ./$project_name

# Set project properties
set current_project [get_projects $project_name]
set_property "compxlib.modelsim_compiled_library_dir" $vivado_sim_libs_path $current_project
set_property "default_lib" "xil_defaultlib" $current_project
set_property "part" "xc7vx690tffg1927-2" $current_project
set_property "sim.ip.auto_export_scripts" "1" $current_project
set_property "simulator_language" "Mixed" $current_project
set_property "target_language" "VHDL" $current_project
set_property "target_simulator" "ModelSim" $current_project

# compile the simulation libraries
#vito compile_simlib -simulator modelsim -directory $vivado_sim_libs_path


####################################################################################
# Create 'sources_1' fileset and add common&project sources and IPs (if not found) #
####################################################################################
set sources {"common_sources.txt" "project_sources.txt" "ip.txt"} 

set dataset "sources_1"
if {[string equal [get_filesets -quiet $dataset] ""]} {
  create_fileset -srcset $dataset
}
set fileset_sources [get_filesets $dataset]

foreach srcs $sources {

    set file_src [open "src/$srcs" r]
    set files [read $file_src]

    foreach f $files {
        puts "HGCINFO: adding file $f"
        add_files -norecurse -fileset $fileset_sources [file normalize "./$f"]

        ## generate all the IPs components in case is an IP
        set file_extension [lindex [ split [lindex [split $f /] end] .] 1 ]
        if { $file_extension == "xci" } {

            puts "HGCINFO: Importing IP: $f"
            import_ip [file normalize "./$f"]

            set ip_name [lindex [ split [lindex [split $f /] end] .] 0 ]
            set local_ip "./$project_name/$project_name.srcs/$dataset/ip/$ip_name/$ip_name.xci"

            generate_target all [get_files $local_ip]
            export_ip_user_files -of_objects [get_files $local_ip] -no_script -force -quiet
            create_ip_run [get_files -of_objects [get_fileset $dataset] $local_ip]
            set sim_scripts_dir "/$project_name/$project_name.ip_user_files/sim_scripts"
            export_simulation -of_objects [get_files $local_ip] -directory $origin_dir$sim_scripts_dir -force -quiet
        }
    }

}
    
puts "HGCINFO: setting the top as top"
set_property "top" "top" $fileset_sources


#############################################
# Create 'constrs_1' fileset (if not found) #
#############################################
set constrains {"common_constraints.txt" "project_constraints.txt"}

set constrs_dataset "constrs_1"
if {[string equal [get_filesets -quiet $constrs_dataset] ""]} {
  create_fileset -constrset $constrs_dataset
}
set fileset_constrs [get_filesets $constrs_dataset]

foreach constrs $constrains {

    set file_src [open "src/$constrs" r]
    set files [read $file_src]

    foreach f $files {
        add_files -norecurse -fileset $fileset_constrs [file normalize "./$f"]
    }
    
}

#        set file "ucf/$f"
#set file_obj [get_files -of_objects [get_filesets $fileset_constrs] [list "*$file"]]
#set_property "file_type" "TCL" $file_obj
#set_property "used_in" "implementation" $file_obj
#set_property "used_in_simulation" "0" $file_obj
#set_property "used_in_synthesis" "0" $file_obj



###################################################
## Create 'constrs_common' fileset (if not found) #
###################################################
#if {[string equal [get_filesets -quiet constrs_project] ""]} {
#  create_fileset -constrset constrs_project
#}
#
#set fileset_constrs_project [get_filesets constrs_project]
#
#set file_src [open "src/project_constraint_file.txt" r]
#set files [read $file_src]
#
#foreach f $files {
#
#    set file "[file normalize "$origin_dir/../firmware/ucf/$f"]"
#    set file_added [add_files -fileset $fileset_constrs_project $file]
#    set file "ucf/$f"
#    set file_obj [get_files -of_objects [get_filesets $fileset_constrs_project] [list "*$file"]]
#    set_property "file_type" "TCL" $file_obj
#    set_property "used_in" "implementation" $file_obj
#    set_property "used_in_simulation" "0" $file_obj
#    set_property "used_in_synthesis" "0" $file_obj
#
#}


###vito   ##vito   #########################################
###vito   ##vito   # Create 'sim_1' fileset (if not found) #
###vito   ##vito   #########################################
###vito   ##vito   if {[string equal [get_filesets -quiet sim_1] ""]} {
###vito   ##vito     create_fileset -simset sim_1
###vito   ##vito   }
###vito   ##vito   
###vito   ##vito   # Set 'sim_1' fileset properties
###vito   ##vito   set obj [get_filesets sim_1]
###vito   ##vito   set_property "modelsim.log_all_signals" "0" $obj
###vito   ##vito   set_property "modelsim.use_explicit_decl" "1" $obj
###vito   ##vito   set_property "modelsim.vhdl_syntax" "93" $obj
###vito   ##vito   set_property "top" "rxdata_simple_cdc_buf_asymmetric" $obj
###vito   ##vito   
###vito   
###vito   #######################################
###vito   # Create 'synth_1' run (if not found) #
###vito   #######################################
###vito   if {[string equal [get_runs -quiet synth_1] ""]} {
###vito     create_run -name synth_1 -part xc7vx690tffg1927-2 -flow {Vivado Synthesis 2015} -strategy "Vivado Synthesis Defaults" -constrset constrs_1
###vito   } else {
###vito     set_property strategy "Vivado Synthesis Defaults" [get_runs synth_1]
###vito     set_property flow "Vivado Synthesis 2015" [get_runs synth_1]
###vito   }
###vito   set obj [get_runs synth_1]
###vito   set_property "needs_refresh" "1" $obj
###vito   set_property "part" "xc7vx690tffg1927-2" $obj
###vito   set_property "steps.synth_design.args.flatten_hierarchy" "none" $obj
###vito   
###vito   # set the current synth run
###vito   current_run -synthesis [get_runs synth_1]
###vito   
###vito   
###vito   ######################################
###vito   # Create 'impl_1' run (if not found) #
###vito   ######################################
###vito   if {[string equal [get_runs -quiet impl_1] ""]} {
###vito     create_run -name impl_1 -part xc7vx690tffg1927-2 -flow {Vivado Implementation 2015} -strategy "Vivado Implementation Defaults" -constrset constrs_1 -parent_run synth_1
###vito   } else {
###vito     set_property strategy "Vivado Implementation Defaults" [get_runs impl_1]
###vito     set_property flow "Vivado Implementation 2015" [get_runs impl_1]
###vito   }
###vito   set obj [get_runs impl_1]
###vito   set_property "needs_refresh" "1" $obj
###vito   set_property "part" "xc7vx690tffg1927-2" $obj
###vito   set_property "steps.write_bitstream.args.readback_file" "0" $obj
###vito   set_property "steps.write_bitstream.args.verbose" "0" $obj
###vito   
###vito   # set the current impl run
###vito   current_run -implementation [get_runs impl_1]


puts "INFO: Project created: $project_name"
