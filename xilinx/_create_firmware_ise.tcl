#-----------------------------------------------------------------------
# Engineer    : Golovachenko Victor
#
# Create Date : 02.11.2018 12:23:01
# Module Name :
#
# Description :
#
#------------------------------------------------------------------------

set firmware_src ./prj/main.bit
set firmware_dst ../fpga-firmware/fpga_firmware_juno.bit

#main
puts "firmware copy from [file normalize $firmware_src] to [file normalize $firmware_dst]"
file copy -force $firmware_src $firmware_dst
