#-----------------------------------------------------------------------
# Engineer    : Golovachenko Victor
#
# Create Date : 20.08.2018 12:17:00
# Module Name :
#
# Description :
#
#------------------------------------------------------------------------
proc convert_2_hfile {} {

    set current_path [pwd]
    set rfile [open "$current_path/src/fpga_regs.v" r]
    set wfile [open "$current_path/src/fpga_regs.h" w]

    set rfile_data [read $rfile]

    puts "$rfile_data"

    set wfile_data [string map {"`define" "#define"} $rfile_data]
    set wfile_data [string map {"`FPGA" "FPGA"} $wfile_data]

    puts "$wfile_data"
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
         default              { puts "unrecognized option" }
      }
   }
}

if {[catch {main} result]} {
  puts "failed: $result."
}

