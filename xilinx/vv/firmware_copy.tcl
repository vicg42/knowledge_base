#
# author: Golovachenko Victor
#

#
puts "run copy main.bit to ../../../firmware/ and rename it to system.bit"
file copy -force ./main.bit ../../../firmware/system.bit

#
puts "run create ../../../firmware/system.hdf"
#create system.hdf + main.bit into one file
#write_sysdef -force -hwdef ./main.hwdef -bitfile ./main.bit ../../../firmware/system.hdf

#create only system.hdf
write_hwdef -force  -file ../../../firmware/system.hdf
