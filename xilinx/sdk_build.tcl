#
# author: Golovachenko Victor
#

set sdk_workspace $argv
puts "sdk workspace path: $sdk_workspace"

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

set hdfile_src $script_folder/firmware/system.hdf

set vv_path $::env(XILINX_SDK)
if {![file exist $vv_path/data/boards/board_files/microzed_7010/1.1]} {
    file copy -force $script_folder/board/microzed_7010 $vv_path/data/boards/board_files
}

#main
if {[file exist $sdk_workspace]} {
    puts "cleanup $sdk_workspace/"
    file delete -force $sdk_workspace/.metadata
    file delete -force $sdk_workspace/device_tree_bsp
    file delete -force $sdk_workspace/fsbl
    file delete -force $sdk_workspace/fsbl_bsp
    file delete -force $sdk_workspace/main_hw_platform_0
    file delete -force $sdk_workspace/system.hdf
} else {
    file mkdir $sdk_workspace
}

##covert to main.hdf
puts "firmware copy from [file normalize $hdfile_src] to [file normalize $sdk_workspace]"
file copy -force $hdfile_src $sdk_workspace

# Set SDK workspace
setws $sdk_workspace
repo -set ../device-tree-xlnx
# Create a HW project
createhw -name main_hw_platform_0 -hwspec $sdk_workspace/system.hdf
#Create a Zynq FSBL project with name 'fsbl' and also creates a BSP 'fsbl_bsp' for processor 'ps7_cortexa9_0' and default OS 'standalone'.
createapp -name fsbl -app {Zynq FSBL} -hwproject main_hw_platform_0 -proc ps7_cortexa9_0
configapp -app fsbl define-compiler-symbols FSBL_DEBUG

#Create a BSP project with name device_tree_bsp from the hardware project main_hw_platform_0 for processor 'ps7_cortexa9_0'
createbsp -name device_tree_bsp -hwproject main_hw_platform_0 -proc ps7_cortexa9_0 -os device_tree

projects -build
