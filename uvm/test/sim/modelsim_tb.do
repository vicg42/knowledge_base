#-----------------------------------------------------------------------
# Author : Viktor Golovachenko
#-----------------------------------------------------------------------

if [file exists work] {
    vdel -all
}
vlib work

vlog ../src/rgb_2_ycbcr.v
vlog ./dut_if.sv -sv
vlog ./main_tb.sv -sv

vsim -t 1ps -novopt +notimingchecks -lib work main_tb

do dut_wave.do
view wave
config wave -timelineunits us
view structure
view signals
run 3us