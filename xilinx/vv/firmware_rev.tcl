#
# author: Golovachenko Victor
#
proc generateFirmwareRevisionUpdate {} {

    # Get the timestamp (see: http://www.altera.com/support/examples/tcl/tcl-date-time-stamp.html)
    set firmware_Date [ clock format [ clock seconds ] -format %d%m%Y ]
    set firmware_Time [ clock format [ clock seconds ] -format %H%M%S ]

    # Create a Verilog file for output at dir ./prj/frame_grabber.runs/synth_1
    set outputFileName "../../../src/firmware_rev.v"
    set outputFile [open $outputFileName "w"]

    # Output the Verilog source
    puts $outputFile "// Build ID Verilog Module"
    puts $outputFile "//"
    puts $outputFile "// Date:             $firmware_Date"
    puts $outputFile "// Time:             $firmware_Time"
    puts $outputFile ""
    puts $outputFile "module firmware_rev"
    puts $outputFile "("
    puts $outputFile "   output \[31:0\]  firmware_date,"
    puts $outputFile "   output \[31:0\]  firmware_time"
    puts $outputFile ");"
    puts $outputFile ""
    puts $outputFile "   assign firmware_date = 32'h$firmware_Date;"
    puts $outputFile "   assign firmware_time = 32'h$firmware_Time;"
    puts $outputFile ""
    puts $outputFile "endmodule"
    close $outputFile

    # Send confirmation message to the Messages window
    puts "Generated firmware_rev identification Verilog module: [pwd]/$outputFileName"
    puts "Date:  $firmware_Date"
    puts "Time:  $firmware_Time"
}

proc convert_2_hfile {} {

    set rfile [open "../../../src/fpga_reg.vhd" r]
    set wfile [open "../../../src/fpga_reg.h" w]

    set rfile_data [read $rfile]
#    puts "$rfile_data"

    set wfile_data [string map {"library ieee;" "#ifndef __FPGA_REG_H__"} $rfile_data]
    set wfile_data [string map {"use ieee.std_logic_1164.all;" "#define __FPGA_REG_H__"} $wfile_data]
    set wfile_data [string map {"package fpga_reg is" " "} $wfile_data]
    set wfile_data [string map {"end fpga_reg;" "#endif //__FPGA_REG_H__"} $wfile_data]

    set wfile_data [string map {"constant" "#define"} $wfile_data]
    set wfile_data [string map {": natural := 16#" "0x"} $wfile_data]
    set wfile_data [string map {"#;" " "} $wfile_data]
    set wfile_data [string map {": natural := " " "} $wfile_data]
    set wfile_data [string map {";" " "} $wfile_data]
    set wfile_data [string map {"--" "//"} $wfile_data]

#    puts "$wfile_data"
    puts $wfile $wfile_data

    close $rfile
    close $wfile

    puts "Created fpga_reg.h  from  fpga_reg.vhd"
}

proc convert_2_verilog {} {

    set rfile [open "../../../src/fpga_reg.vhd" r]
    set wfile [open "../../../sim/fpga_reg.v" w]

    set rfile_data [read $rfile]
#    puts "$rfile_data"

    set wfile_data [string map {"library ieee;" "//"} $rfile_data]
    set wfile_data [string map {"use ieee.std_logic_1164.all;" "//"} $wfile_data]
    set wfile_data [string map {"package fpga_reg is" "//"} $wfile_data]
    set wfile_data [string map {"end fpga_reg;" "//"} $wfile_data]

    set wfile_data [string map {"constant" "`define"} $wfile_data]
    set wfile_data [string map {": natural := 16#" "32'h"} $wfile_data]
    set wfile_data [string map {"#;" " "} $wfile_data]
    set wfile_data [string map {": natural := " " "} $wfile_data]
    set wfile_data [string map {";" " "} $wfile_data]
    set wfile_data [string map {"--" "//"} $wfile_data]

#    puts "$wfile_data"
    puts $wfile $wfile_data

    close $rfile
    close $wfile

    puts "Created ./sim/fpga_reg.v  from  fpga_reg.vhd"
}


# Comment out this line to prevent the process from automatically executing when the file is sourced:
generateFirmwareRevisionUpdate

convert_2_hfile

convert_2_verilog
