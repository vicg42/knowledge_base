#
# author: Golovachenko Victor
#

set cur_path [pwd]

set boot_file $cur_path/firmware/BOOT.bin
set log_file $cur_path/firmware/BOOT.log
set fpga_bit $cur_path/firmware/main.bit

if {[file exists $fsbl_elf] != 1} {
   puts "error - file $fsbl_elf not exists!";
   return 1
}

if {[file exists "$fpga_bit"] != 1} {
   puts "error - file $fpga_bit not exists!";
   return 1
}

#file copy -force $fpga_bit $cur_path/firmware

#Replace char / to \
set fsbl_elf_edit
regsub -all {/} $fsbl_elf {\\} fsbl_elf_edit
regsub -all {/} $fpga_bit {\\} fpga_bit_edit

#Create BIF file
set file_out [open $bif_file w]

puts $file_out "all:"
puts $file_out "\{"
puts $file_out "\tmain.bit"
puts $file_out "\}"

close $file_out

#Create BOOT file
exec bootgen -arch zynq -image $bif_file -w -o $boot_file -log info
