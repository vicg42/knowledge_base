#
# author: Golovachenko Victor
#
proc convert_2_hfile {} {

    set current_path [pwd]
    set rfile [open "$current_path/fpga_reg.vhd" r]
    set wfile [open "$current_path/fpga_reg.h" w]

    set rfile_data [read $rfile]
    puts "$rfile_data"

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

    puts "$wfile_data"
    puts $wfile $wfile_data

    close $rfile
    close $wfile
}

proc convert_2_verilog {} {

    set current_path [pwd]
    set rfile [open "$current_path/fpga_reg.vhd" r]
    set wfile [open "../sim/fpga_reg.v" w]

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
}

proc main {} {

   if { [llength $::argv] == 0 } {
      return true
   }

   foreach option $::argv {
      switch $option {
         "convert_2_hfile"    { convert_2_hfile }
         "convert_2_verilog"  { convert_2_verilog }
         default              { puts "unrecognized option" }
      }
   }
}

if {[catch {main} result]} {
  puts "failed: $result."
}

