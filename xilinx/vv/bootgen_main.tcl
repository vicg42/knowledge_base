#
# author: Golovachenko Victor
#
# create system.bit.bin for next load it from linux with module fpga manager.
# for more info watch link:
# https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/18841645/Solution+Zynq+PL+Programming+With+FPGA+Manager
#

set cur_path [pwd]

set bif_file $cur_path/system.bif
set fpga_bit $cur_path/system.bit

if {[file exists "$fpga_bit"] != 1} {
   puts "error - file $fpga_bit not exists!";
   return 1
}

#Create BIF file
if {[file exists "$bif_file"] != 1} {
    set file_out [open $bif_file w]

    puts $file_out "all:"
    puts $file_out "\{"
    puts $file_out "\tsystem.bit"
    puts $file_out "\}"

    close $file_out
}

exec bootgen -image $bif_file -arch zynq -process_bitstream bin -w
