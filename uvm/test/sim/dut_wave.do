onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /main_tb/dut_if_h/clk
add wave -noupdate /main_tb/dut_if_h/r_i
add wave -noupdate /main_tb/dut_if_h/g_i
add wave -noupdate /main_tb/dut_if_h/b_i
add wave -noupdate /main_tb/dut_if_h/de_i
add wave -noupdate /main_tb/dut_if_h/hs_i
add wave -noupdate /main_tb/dut_if_h/vs_i
add wave -noupdate /main_tb/dut_if_h/y_o
add wave -noupdate /main_tb/dut_if_h/cb_o
add wave -noupdate /main_tb/dut_if_h/cr_o
add wave -noupdate /main_tb/dut_if_h/de_o
add wave -noupdate /main_tb/dut_if_h/hs_o
add wave -noupdate /main_tb/dut_if_h/vs_o
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 250
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update
WaveRestoreZoom {4999050 ps} {4999982 ps}
