#
# author: Golovachenko Viktor
#
source ./hw_usr.tcl

proc usr_open {} {
    set fpga_index 1
    open_hw
    connect_hw_server -url localhost:3121
    open_hw_target
    refresh_hw_device [lindex [get_hw_devices] $fpga_index]
    current_hw_device [lindex [get_hw_devices] $fpga_index]
}

proc usr_close {} {
    close_hw
}

proc axi_read { addr } {
    delete_hw_axi_txn axi_read_txn -quiet
    create_hw_axi_txn -type read -address $addr axi_read_txn [get_hw_axis]
    run_hw_axi axi_read_txn -quiet
    return 0x[lindex [report_hw_axi_txn axi_read_txn] 1]
}

proc axi_write { addr data } {
    set data [format %08x $data]
    delete_hw_axi_txn axi_write_txn -quiet
    create_hw_axi_txn -type write -address $addr -data $data axi_write_txn [get_hw_axis]
    run_hw_axi axi_write_txn -quiet
    return -code ok
}

proc main {argc argv} {

    usr_open

    reset_hw_axi [get_hw_axis]

    while (1) {
        eval exec >&@stdout <@stdin [auto_execok cls]

        puts "\nSTATUS:"
        set aurora_status [axi_read [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_STATUS_AURORA}]] ]
        puts "\tinterface aurora:"
        for {set i 0} {$i < ${::hw_usr::AURORA_CHCOUNT}} {incr i} {
            puts "\t\taurora ch($i) - link: [ expr [ expr $aurora_status >> $i ] & 0x01 ]"
        }

        set eth_status [axi_read [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_STATUS_ETH}]] ]
        puts "\n\tmodule ZYNQ: firmware:[string trimleft [axi_read [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_FIRMWARE_DATE}]] ] 0x]:[string\
         trimleft [axi_read [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_FIRMWARE_TIME}]] ] 0x]"
        for {set i 0} {$i < ${::hw_usr::MODULE_ZYNQ_ETHCOUNT}} {incr i} {
            puts "\t\teth ch($i) - link: [ expr { ($eth_status >> $i ) & 0x01} ]"
        }

        set artix_m [expr { ($eth_status >> ${::hw_usr::MODULE_ZYNQ_ETHCOUNT_MAX}) & 0xFF } ]
        for {set i 0} {$i < ${::hw_usr::MODULE_ARTIX_COUNT}} {incr i} {
            puts "\n\tmodule ARTIX($i): "
            set artix_eth [expr { ($artix_m >> ($i*${::hw_usr::MODULE_ARTIX_ETHCOUNT_MAX})) & 0xF } ]
            for {set x 0} {$x < ${::hw_usr::MODULE_ARTIX_ETHCOUNT}} {incr x} {
                puts "\t\teth ch($x) - link: [ expr { ($artix_eth >> $x) & 0x01 } ]"
            }
        }
        puts "\nUSR CTRL:"
        set usr_ctrl [axi_read [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_CTRL}]] ]
        puts "\tval: $usr_ctrl"
        puts "\tzynq eth num(bits[13..12]): [expr { ($usr_ctrl >> ${::hw_usr::UREG_CTRL_SEL_ZYNQ_ETH_BIT}) & 0x3 } ]"
        puts "\tartix eth num(bits[10..8]): [expr { ($usr_ctrl >> ${::hw_usr::UREG_CTRL_SEL_ARTIX_ETH_BIT}) & 0x7 } ]"

        puts "\n0 - quit"
        puts "1 - get status"
        puts "2 - set ctrl"
        puts -nonewline "Enter key: "
        flush stdout
        set usr_key [gets stdin]
        if {[string compare $usr_key "0"] == 0} {
            eval exec >&@stdout <@stdin [auto_execok cls]
            break;
        } elseif {[string compare $usr_key "2"] == 0} {
            # eval exec >&@stdout <@stdin [auto_execok cls]
            puts -nonewline "Enter value(hex): "
            set usr_key [gets stdin]
            axi_write [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_CTRL}]] $usr_key
        }
    }

    usr_close
}


# Start the program
main $argc $argv