#-----------------------------------------------------------------------
# Author : Golovachenko Victor
#------------------------------------------------------------------------

source ./i2c_hw_usr.tcl
source ./ov4689_cfg.tcl


# Get the Cse DLL's and globals
if {[info exists env(XIL_CSE_TCL)]} {
    if {[string length $env(XIL_CSE_TCL)] > 0} {
        puts "Sourcing from XIL_CSE_TCL: $env(XIL_CSE_TCL) ..."
        source $env(XIL_CSE_TCL)/csejtag.tcl
        source $env(XIL_CSE_TCL)/csefpga.tcl
        source $env(XIL_CSE_TCL)/csecore.tcl
        source $env(XIL_CSE_TCL)/csevio.tcl
    } else {
        puts "Sourcing from XILINX: $env(XILINX)/cse/tcl ..."
        source $env(XILINX)/cse/tcl/csejtag.tcl
        source $env(XILINX)/cse/tcl/csefpga.tcl
        source $env(XILINX)/cse/tcl/csecore.tcl
        source $env(XILINX)/cse/tcl/csevio.tcl
    }
} else {
    puts "Sourcing from XILINX: $env(XILINX)/cse/tcl ..."
    source $env(XILINX)/cse/tcl/csejtag.tcl
    source $env(XILINX)/cse/tcl/csefpga.tcl
    source $env(XILINX)/cse/tcl/csecore.tcl
    source $env(XILINX)/cse/tcl/csevio.tcl
}

namespace import ::chipscope::*

# Create global variables
set ILA_STATUS_WORD_BIT_LEN  512

# Parallel IV Cable
set PARALLEL_CABLE_ARGS [list "port=LPT1" \
                              "frequency=2500000"]
                              # "frequency=5000000 | 2500000 | 1250000 | 625000 | 200000"

# Platform USB Cable
set PLATFORM_USB_CABLE_ARGS [list "port=USB2" \
                                  "frequency=3000000"]
                                  # frequency="12000000 | 6000000 | 3000000 | 1500000 | 750000"

# Digilent Cable
# Digilent Cables have default arguments, if there is only one cable
# connected it will automatically connect to it.
set DIGILENT_CABLE_ARGS {}

set CABLE_NAME $CSEJTAG_TARGET_PLATFORMUSB
set CABLE_ARGS $PLATFORM_USB_CABLE_ARGS
set debug 0

proc main {argc argv} {
    global debug
    global PLATFORM_USB_CABLE_ARGS
    global CSEJTAG_TARGET_PLATFORMUSB
    global PARALLEL_CABLE_ARGS
    global CSEJTAG_TARGET_PARALLEL
    global DIGILENT_CABLE_ARGS
    global CSEJTAG_TARGET_DIGILENT
    global CABLE_NAME
    global CABLE_ARGS
    global CSE_MSG_INFO

    if {[expr ($argc > 0) && [string equal "-h" [lindex $argv 0]]]} {
        set scriptname [info script]
        writeMessage 0 $CSE_MSG_INFO "\
Usage: xtclsh $scriptname \[-usb\] \[-par\] \[-dig\]\
\n  -usb    Open Platform USB cable, default cable without any flag\
\n  -par    Open Parallel IV cable\
\n  -dig    Open Digilent cable\n"
        exit
    }

    # Checks to see if usb or debug flag is set
    for {set i 0} {$i < $argc} {incr i} {
        if {[string equal "-usb" [lindex $argv $i]]} {
            set CABLE_NAME $CSEJTAG_TARGET_PLATFORMUSB
            set CABLE_ARGS $PLATFORM_USB_CABLE_ARGS
        } elseif {[string equal "-par" [lindex $argv $i]]} {
            set CABLE_NAME $CSEJTAG_TARGET_PARALLEL
            set CABLE_ARGS $PARALLEL_CABLE_ARGS
        } elseif {[string equal "-dig" [lindex $argv $i]]} {
            set CABLE_NAME $CSEJTAG_TARGET_DIGILENT
            set CABLE_ARGS $DIGILENT_CABLE_ARGS
        } elseif {[string equal "-d" [lindex $argv $i]]} {
            set debug 1
        }
    }

    # Create Session. Pass location of idcode.lst to override default.
    set handle [csejtag_session create "writeMessage" $argv]

    # Scan the JTAG chain
    scanChain $handle

    csejtag_session destroy $handle
}

proc scanChain {handle} {
    global CABLE_NAME
    global CABLE_ARGS
    global CSE_MSG_ERROR
    global CSE_MSG_INFO
    global CSEJTAG_SCAN_DEFAULT
    global CSEJTAG_LOCKED_ME

    # Open cable
    csejtag_target open $handle \
                        $CABLE_NAME \
                        0 \
                        $CABLE_ARGS

    # CseJtag_session sendMessage will call the messageRouter
    # function specified in csejtag_session create
    csejtag_session send_message $handle $CSE_MSG_INFO "Open Cable successfully\n"

    # Need to lock cable before actually accessing JTAG chain
    set cablelock [csejtag_target lock $handle 5000]
    if {$cablelock != $CSEJTAG_LOCKED_ME} {
        csejtag_session send_message $handle $CSE_MSG_ERROR "cse_lock_target failed"
        csejtag_target close $handle
        return
    }

    csejtag_session send_message $handle $CSE_MSG_INFO "Obtained cable lock\n"

    # Catch all errors that may occur when using the CSE commands.  This should be done
    # so that the cable can be unlocked and closed correctly.
    if {[catch {

        # Scan the JTAG chain, reading idcodes,
        # setting IR lengths for known devices in the CseJtag
        # data structures.
        # CseJtag needs to know in order to do JTAG shifts.
        csejtag_tap autodetect_chain $handle $CSEJTAG_SCAN_DEFAULT

        # Get number of devices
        set deviceCount [csejtag_tap get_device_count $handle]

        set str [format "Found %u devices\n" $deviceCount]
        csejtag_session send_message $handle $CSE_MSG_INFO $str

        for {set deviceIndex 0} {$deviceIndex < $deviceCount} {incr deviceIndex} {
            scanDevice $handle $deviceIndex
        }

    #  End of catch statement
    } result]} {
        global errorCode
        global errorInfo
        puts stderr "\nCaught error: $result"
        puts stderr "**** Error Code ***"
        puts stderr $errorCode
        puts stderr "**** Tcl Trace ****"
        puts stderr $errorInfo
        puts stderr "*******************"
    }

    csejtag_target unlock $handle
    csejtag_target close $handle
    csejtag_session send_message $handle $CSE_MSG_INFO "Closed cable successfully\n"
}

# Note that this function (with the exception of the call to
# scanUserReg() ) does not get any information
# which requires a new scan of the device chain.
# It is just lookup in the 'idcode.lst' file or
# information which CseJtag data structures already has such as:
# deviceCount and device idcodes.
proc scanDevice {handle deviceIndex} {
    global CSE_MSG_INFO

    # Get idcode without scanning the JTAG chain
    set idcode [csejtag_tap get_device_idcode $handle $deviceIndex]

    # Convert to an integer
    set idcodeInt [binaryStringToInt $idcode]

    # Get IR length without scanning JTAG chain
    set irLength 0
    set irLength [csejtag_db get_irlength_for_idcode $handle $idcode]

    # NOTE If (irLength == 0) an application program needs to set it,
    #     ( using function csejtag_tap_set_irlength $handle $deviceIndex $irLength)
    #     perhaps after asking the user or looking it up someway.
    #     Without irLength known for all devices in the chain,
    #     JTAG communication will fail.

    # Check if api supports cores for device
    set coreSupported 0
    set coreSupported [csecore_is_cores_supported $handle $idcode]

    # Check if api supports configuration of device
    set configurationSupported 0
    set configurationSupported [csefpga_is_config_supported $handle $idcode]

    # Get how many user chains the device has
    set userChainCount [csefpga_get_user_chain_count $handle $idcode]

    # Get device name
    set deviceName [csejtag_db get_device_name_for_idcode $handle $idcode]

    # print out device info
    set str [format "\nDEVICE %u, idcode:%x, IRLength:%u, chains:%u, coreSupport:%u, config support:%u, %s\n" \
                    $deviceIndex $idcodeInt $irLength $userChainCount $coreSupported \
                    $configurationSupported $deviceName]
    csejtag_session send_message $handle $CSE_MSG_INFO $str

    # Scan user chains
    for {set userChain  1} {$userChain <= $userChainCount} {incr userChain} {
        scanUserReg $handle $deviceIndex $userChain
    }
}

proc scanUserReg {handle deviceIndex userRegNumber} {
    global CSE_MSG_INFO

    #  NOTE!
    #  Use csecore_get_core_count before accessing any core.
    #  Otherwise you may upset other non ChipScope cores.

    set coreCount 0
    set coreCount [csecore_get_core_count $handle $deviceIndex $userRegNumber]

    set str [format "Found %u cores, for device %u, user register %u\n" \
		            $coreCount $deviceIndex $userRegNumber]
    csejtag_session send_message $handle $CSE_MSG_INFO $str

    # Scan cores
    for {set coreIndex 0} {$coreIndex < $coreCount} {incr coreIndex} {
        scanCore $handle $deviceIndex $userRegNumber $coreIndex
    }
}

proc scanCore { handle deviceIndex userRegNumber coreIndex } {
    global ILA_STATUS_WORD_BIT_LEN
    global CSE_MSG_INFO

    set coreRef [list $deviceIndex $userRegNumber $coreIndex]

    # Read core status
    set coreStatus [csecore_get_core_status $handle \
                                            $coreRef \
                                            $ILA_STATUS_WORD_BIT_LEN]
    set coreInfo [lindex $coreStatus 0]
    set statusWord [lindex $coreStatus 1]

    # # Dump status word
    # set str [format "\n\nDevice %u, user reg. %u, core index %u, status word:\n" \
    #                 $deviceIndex $userRegNumber $coreIndex]
    # csejtag_session send_message $handle $CSE_MSG_INFO $str
    # dumpInHex $statusWord

    # # Print CSE_CORE_INFO values
    # set str [format \
    #                 "\nCSE_CORE_INFO: manufacturerId:%u, coreType:%u, coreMajorVersion:%u, coreMinorVersion:%u, coreRevision:%u\n\n" \
    #                 [lindex $coreInfo 0] \
    #                 [lindex $coreInfo 1] \
    #                 [lindex $coreInfo 2] \
    #                 [lindex $coreInfo 3] \
    #                 [lindex $coreInfo 4] ]
    # csejtag_session send_message $handle $CSE_MSG_INFO $str

    set isviocore [csevio_is_vio_core $handle \
                                      $coreRef]
    if {$isviocore} {
        set viocoreanswer "YES"
    } else {
        set viocoreanswer "NO"
    }
    set str [format \
                    "\nIs VIO Core? %s\n"\
                    $viocoreanswer]
    csejtag_session send_message $handle $CSE_MSG_INFO $str

    if {$isviocore} {
        scanVIOCore $handle $coreRef
    }
}

proc reg_wr { handle coreRef adr_val data_val } {
    set outputTclArray(reg_addr) $adr_val
    set outputTclArray(reg_txd) $data_val
    set outputTclArray(reg_wen) 1
    # puts "addr: $adr_val (hex),[format %03d $adr_val](dec); wdata: $data_val"
    csevio_write_values $handle $coreRef outputTclArray
    set outputTclArray(reg_wen) 0
    csevio_write_values $handle $coreRef outputTclArray
}

proc reg_rd { handle coreRef adr_val } {
    set outputTclArray(reg_addr) $adr_val
    set outputTclArray(reg_ren) 1
    csevio_write_values $handle $coreRef outputTclArray
    set outputTclArray(reg_ren) 0
    csevio_write_values $handle $coreRef outputTclArray
    csevio_read_values $handle $coreRef inputTclArray
    set reg_rdata 0x$inputTclArray(reg_rxd.value)
    # puts "addr: $adr_val (hex),[format %03d $adr_val](dec); rdata: $reg_rdata"
    return $reg_rdata
}

proc fifo_rd { handle coreRef } {
    csevio_read_values $handle $coreRef inputTclArray
    set fifo_rdata 0x$inputTclArray(fifo_rxd.value)
    set outputTclArray(fifo_ren) 1
    csevio_write_values $handle $coreRef outputTclArray
    set outputTclArray(fifo_ren) 0
    csevio_write_values $handle $coreRef outputTclArray
    # puts "addr: $adr_val (hex),[format %03d $adr_val](dec); rdata: $fifo_rdata"
    return $fifo_rdata
}

proc fr_line_rd_ctl { handle coreRef data_val} {
    set outputTclArray(fr_line_rd) $data_val
    csevio_write_values $handle $coreRef outputTclArray
}

proc fifo_nrst_ctl { handle coreRef data_val} {
    set outputTclArray(fifo_nrst) $data_val
    csevio_write_values $handle $coreRef outputTclArray
}

proc fifo_empty_ctl { handle coreRef } {
    csevio_read_values $handle $coreRef inputTclArray
    return $inputTclArray(fifo_empfy.value)
}


proc i2c_read { handle coreRef reg_adr_val } {
    #check status i2c module
    set status [ reg_rd $handle $coreRef ${::i2c_hw_usr::FPGA_RD_REG_I2C_STATUS} ];
    set busy_bit [ expr { ( $status >> ${::i2c_hw_usr::FPGA_RD_REG_I2C_STATUS_BUSY_BIT} ) & 0x01 } ];
    if { $busy_bit == 1 } {
        return -code error "i2c module status: busy bit - 1";
    }

    #set addr of user register
    reg_wr $handle $coreRef ${::i2c_hw_usr::FPGA_REG_I2C_AREG} $reg_adr_val

    #start read operation of i2c module.(read register)
    set ctrl [ format 0x%04x [ expr { ( ${::i2c_hw_usr::I2C_DEV_ADDR} << ${::i2c_hw_usr::FPGA_REG_I2C_CTL_ADEV_LSB_BIT} ) | \
                                    ( ${::i2c_hw_usr::I2C_READ_CMD} << ${::i2c_hw_usr::FPGA_REG_I2C_CTL_DIR_BIT} ) } ] ];
    reg_wr $handle $coreRef ${::i2c_hw_usr::FPGA_REG_I2C_CTL} $ctrl

    set ctrl [ format 0x%04x [ expr { ( ${::i2c_hw_usr::I2C_DEV_ADDR} << ${::i2c_hw_usr::FPGA_REG_I2C_CTL_ADEV_LSB_BIT} ) | \
                                    ( ${::i2c_hw_usr::I2C_READ_CMD} << ${::i2c_hw_usr::FPGA_REG_I2C_CTL_DIR_BIT} ) | \
                                    ( 0x01 << ${::i2c_hw_usr::FPGA_REG_I2C_CTL_START_BIT} ) } ] ];
    reg_wr $handle $coreRef ${::i2c_hw_usr::FPGA_REG_I2C_CTL} $ctrl

    #wait end of operation
    set busy_bit  1;
    while { $busy_bit == 1 } {
        set status [ reg_rd $handle $coreRef ${::i2c_hw_usr::FPGA_RD_REG_I2C_STATUS} ];
        set busy_bit [ expr { ($status >> ${::i2c_hw_usr::FPGA_RD_REG_I2C_STATUS_BUSY_BIT} ) & 0x01 } ];
    }
    set err_bit [ expr { ($status >> ${::i2c_hw_usr::FPGA_RD_REG_I2C_STATUS_ERR_BIT} ) & 0x01 } ];
    if { $err_bit == 1 } {
        return -code error "i2c module status: error bit - 1";
    }

    #read recieve data
    return [ reg_rd $handle $coreRef ${::i2c_hw_usr::FPGA_RD_REG_I2C_DREG} ];
}

proc i2c_write { handle coreRef reg_adr_val reg_data_val } {
    #check status i2c module
    set status [ reg_rd $handle $coreRef ${::i2c_hw_usr::FPGA_RD_REG_I2C_STATUS} ];
    set busy_bit [ expr { ( $status >> ${::i2c_hw_usr::FPGA_RD_REG_I2C_STATUS_BUSY_BIT} ) & 0x01 } ];
    if { $busy_bit == 1 } {
        return -code error "i2c module status: busy bit - 1";
    }

    #set addr of user register
    reg_wr $handle $coreRef ${::i2c_hw_usr::FPGA_REG_I2C_AREG} $reg_adr_val

    #set data of write to user register
    reg_wr $handle $coreRef ${::i2c_hw_usr::FPGA_REG_I2C_DREG} $reg_data_val

    #start write operation of i2c module.(write register)
    set ctrl [ format 0x%04x [ expr { ( ${::i2c_hw_usr::I2C_DEV_ADDR} << ${::i2c_hw_usr::FPGA_REG_I2C_CTL_ADEV_LSB_BIT} ) | \
                                    ( ${::i2c_hw_usr::I2C_WRITE_CMD} << ${::i2c_hw_usr::FPGA_REG_I2C_CTL_DIR_BIT} ) } ] ];
    reg_wr $handle $coreRef ${::i2c_hw_usr::FPGA_REG_I2C_CTL} $ctrl

    set ctrl [ format 0x%04x [ expr { ( ${::i2c_hw_usr::I2C_DEV_ADDR} << ${::i2c_hw_usr::FPGA_REG_I2C_CTL_ADEV_LSB_BIT} ) | \
                                    ( ${::i2c_hw_usr::I2C_WRITE_CMD} << ${::i2c_hw_usr::FPGA_REG_I2C_CTL_DIR_BIT} ) | \
                                    ( 0x01 << ${::i2c_hw_usr::FPGA_REG_I2C_CTL_START_BIT} ) } ] ];
    reg_wr $handle $coreRef ${::i2c_hw_usr::FPGA_REG_I2C_CTL} $ctrl

    #wait end of operation
    set busy_bit  1;
    while { $busy_bit == 1 } {
        set status [ reg_rd $handle $coreRef ${::i2c_hw_usr::FPGA_RD_REG_I2C_STATUS} ];
        set busy_bit [ expr { ( $status >> ${::i2c_hw_usr::FPGA_RD_REG_I2C_STATUS_BUSY_BIT} ) & 0x01 } ];
    }
    set err_bit [ expr { ($status >> ${::i2c_hw_usr::FPGA_RD_REG_I2C_STATUS_ERR_BIT} ) & 0x01 } ];
    if { $err_bit == 1 } {
        return -code error "i2c module status: error bit - 1";
    }

    return -code ok;
}

proc print_memstatus { status } {
    puts "status value: $status"
    puts "\t CALIB_DONE_BIT: [ expr { ( $status >> ${::i2c_hw_usr::FPGA_RD_REG_MEMTEST_STATUS_CALIB_DONE_BIT} ) & 0x01 } ] "
    puts "\t CMD_EMPTY_BIT: [ expr { ( $status >> ${::i2c_hw_usr::FPGA_RD_REG_MEMTEST_STATUS_CMD_EMPTY_BIT} ) & 0x01 } ] "
    puts "\t WR_EMPTY_BIT: [ expr { ( $status >> ${::i2c_hw_usr::FPGA_RD_REG_MEMTEST_STATUS_WR_EMPTY_BIT} ) & 0x01 } ] "
    puts "\t RD_EMPTY_BIT: [ expr { ( $status >> ${::i2c_hw_usr::FPGA_RD_REG_MEMTEST_STATUS_RD_EMPTY_BIT} ) & 0x01 } ] "
    puts "\t CMD_FULL_BIT: [ expr { ( $status >> ${::i2c_hw_usr::FPGA_RD_REG_MEMTEST_STATUS_CMD_FULL_BIT} ) & 0x01 } ] "
    puts "\t WR_FULL_BIT: [ expr { ( $status >> ${::i2c_hw_usr::FPGA_RD_REG_MEMTEST_STATUS_WR_FULL_BIT} ) & 0x01 } ] "
    puts "\t RD_FULL_BIT: [ expr { ( $status >> ${::i2c_hw_usr::FPGA_RD_REG_MEMTEST_STATUS_RD_FULL_BIT} ) & 0x01 } ] "
    puts "\t WR_UNDERRUN_BIT: [ expr { ( $status >> ${::i2c_hw_usr::FPGA_RD_REG_MEMTEST_STATUS_WR_UNDERRUN_BIT} ) & 0x01 } ] "
    puts "\t WR_ERROR_BIT: [ expr { ( $status >> ${::i2c_hw_usr::FPGA_RD_REG_MEMTEST_STATUS_WR_ERROR_BIT} ) & 0x01 } ]"
    puts "\t RD_OVERFLOW_BIT: [ expr { ( $status >> ${::i2c_hw_usr::FPGA_RD_REG_MEMTEST_STATUS_RD_OVERFLOW_BIT} ) & 0x01 } ] "
    puts "\t RD_ERROR_BIT: [ expr { ( $status >> ${::i2c_hw_usr::FPGA_RD_REG_MEMTEST_STATUS_RD_ERROR_BIT} ) & 0x01 } ] "
}

proc mem_read { handle coreRef reg_adr_val } {
    #get mem status
    set status [ reg_rd $handle $coreRef ${::i2c_hw_usr::FPGA_RD_REG_MEMTEST_STATUS} ];
    set mem_clibration_bit [ expr { ( $status >> ${::i2c_hw_usr::FPGA_RD_REG_MEMTEST_STATUS_CALIB_DONE_BIT} ) & 0x01 } ];
    # set mem_clibration_bit 0;
    set mem_bufempty [ expr { ( $status >> ${::i2c_hw_usr::FPGA_RD_REG_MEMTEST_STATUS_CMD_EMPTY_BIT} ) & 0x07 } ];
    set mem_buffull [ expr { ( $status >> ${::i2c_hw_usr::FPGA_RD_REG_MEMTEST_STATUS_CMD_FULL_BIT} ) & 0x07 } ];
    set mem_err [ expr { ( $status >> ${::i2c_hw_usr::FPGA_RD_REG_MEMTEST_STATUS_RD_OVERFLOW_BIT} ) & 0x0F } ];
    if { !($mem_clibration_bit == 1
        && $mem_bufempty == 7
        && $mem_buffull == 0
        && $mem_err == 0) } {
        print_memstatus $status
        return -code error "mem status error";
    }

    #set mem addr and CTL
    set wdata [ format 0x%04x [ expr $reg_adr_val & 0xFFFF ] ]
    reg_wr $handle $coreRef [ format 0x%02x [ expr ${::i2c_hw_usr::FPGA_REG_MEMTEST_CTRL} + 0 ] ] $wdata
    set wdata [ format 0x%04x [ expr { ( $reg_adr_val >> 16 ) | \
                                    ( ${::i2c_hw_usr::FPGA_MEM_RD} << (${::i2c_hw_usr::FPGA_REG_MEMTEST_CTRL_DIR_BIT} - 16) ) } ] ]
    reg_wr $handle $coreRef [ format 0x%02x [ expr ${::i2c_hw_usr::FPGA_REG_MEMTEST_CTRL} + 1 ] ] $wdata

    set status [ reg_rd $handle $coreRef ${::i2c_hw_usr::FPGA_RD_REG_MEMTEST_STATUS} ];

    #wait data
    set mem_bufempty  1;
    while { $mem_bufempty == 1 } {
        set status [ reg_rd $handle $coreRef ${::i2c_hw_usr::FPGA_RD_REG_MEMTEST_STATUS} ];
        set mem_bufempty [ expr { ($status >> ${::i2c_hw_usr::FPGA_RD_REG_MEMTEST_STATUS_RD_EMPTY_BIT} ) & 0x01 } ];
        set mem_err [ expr { ( $status >> ${::i2c_hw_usr::FPGA_RD_REG_MEMTEST_STATUS_RD_OVERFLOW_BIT} ) & 0x0F } ];
        if { $mem_err != 0 } {
            print_memstatus $status
            return -code error "mem status: mem_err=$mem_err";
        }
    }

    #read data from mem
    set rdata_l [ reg_rd $handle $coreRef [ format 0x%02x [ expr ${::i2c_hw_usr::FPGA_RD_REG_MEMTEST_RDATA} + 0 ] ] ];
    set rdata_h [ reg_rd $handle $coreRef [ format 0x%02x [ expr ${::i2c_hw_usr::FPGA_RD_REG_MEMTEST_RDATA} + 1 ] ] ];
    set rdata [ format 0x%04x [ expr {($rdata_h << 16) | $rdata_l} ] ]

    #set strb RD
    set wdata [ format 0x%04x [ expr { ( $reg_adr_val >> 16 ) | \
                                    ( ${::i2c_hw_usr::FPGA_MEM_RD} << (${::i2c_hw_usr::FPGA_REG_MEMTEST_CTRL_DIR_BIT} - 16) ) | \
                                    ( 0x01 << (${::i2c_hw_usr::FPGA_REG_MEMTEST_CTRL_RD_STROB_BIT} - 16) ) } ] ]
    reg_wr $handle $coreRef [ format 0x%02x [ expr ${::i2c_hw_usr::FPGA_REG_MEMTEST_CTRL} + 1 ] ] $wdata

    set status [ reg_rd $handle $coreRef ${::i2c_hw_usr::FPGA_RD_REG_MEMTEST_STATUS} ];
    set mem_bufempty [ expr { ( $status >> ${::i2c_hw_usr::FPGA_RD_REG_MEMTEST_STATUS_RD_EMPTY_BIT} ) & 0x01 } ];
    set mem_buffull [ expr { ( $status >> ${::i2c_hw_usr::FPGA_RD_REG_MEMTEST_STATUS_CMD_FULL_BIT} ) & 0x07 } ];
    set mem_err [ expr { ( $status >> ${::i2c_hw_usr::FPGA_RD_REG_MEMTEST_STATUS_RD_OVERFLOW_BIT} ) & 0x0F } ];
    if { !($mem_bufempty == 1
        && $mem_buffull == 0
        && $mem_err == 0) } {
        print_memstatus $status
        return -code error "mem status error: calibration=$mem_clibration_bit; bufempty=$mem_bufempty; buffull=$mem_buffull; err=$mem_err";
    }

    return $rdata;
}

proc mem_write { handle coreRef reg_adr_val reg_data_val } {
    #get mem status
    set status [ reg_rd $handle $coreRef ${::i2c_hw_usr::FPGA_RD_REG_MEMTEST_STATUS} ];
    set mem_clibration_bit [ expr { ( $status >> ${::i2c_hw_usr::FPGA_RD_REG_MEMTEST_STATUS_CALIB_DONE_BIT} ) & 0x01 } ];
    # set mem_clibration_bit 0;
    set mem_bufempty [ expr {  ($status >> ${::i2c_hw_usr::FPGA_RD_REG_MEMTEST_STATUS_CMD_EMPTY_BIT} ) & 0x07 } ];
    set mem_buffull [ expr { ( $status >> ${::i2c_hw_usr::FPGA_RD_REG_MEMTEST_STATUS_CMD_FULL_BIT} ) & 0x07 } ];
    set mem_err [ expr { ( $status >> ${::i2c_hw_usr::FPGA_RD_REG_MEMTEST_STATUS_RD_OVERFLOW_BIT} ) & 0x0F } ];
    if { !($mem_clibration_bit == 1
        && $mem_bufempty == 7
        && $mem_buffull == 0
        && $mem_err == 0) } {
        print_memstatus $status
        return -code error "mem status error";
    }

    #set mem write data
    reg_wr $handle $coreRef [ format 0x%02x [ expr ${::i2c_hw_usr::FPGA_REG_MEMTEST_WDATA} + 0 ] ] \
                            [ format 0x%04x [ expr $reg_data_val & 0xFFFF ] ]

    reg_wr $handle $coreRef [ format 0x%02x [ expr ${::i2c_hw_usr::FPGA_REG_MEMTEST_WDATA} + 1 ] ] \
                            [ format 0x%04x [ expr ($reg_data_val >> 16) & 0xFFFF ] ]

    set status [ reg_rd $handle $coreRef ${::i2c_hw_usr::FPGA_RD_REG_MEMTEST_STATUS} ];
    # print_memstatus $status

    #set meme addr and CTL
    set wdata [ format 0x%04x [ expr $reg_adr_val & 0xFFFF ] ]
    reg_wr $handle $coreRef [ format 0x%02x [ expr ${::i2c_hw_usr::FPGA_REG_MEMTEST_CTRL} + 0 ] ] $wdata
    set wdata [ format 0x%04x [ expr { ( $reg_adr_val >> 16 ) | \
                                    ( ${::i2c_hw_usr::FPGA_MEM_WR} << (${::i2c_hw_usr::FPGA_REG_MEMTEST_CTRL_DIR_BIT} - 16) ) } ] ]
    reg_wr $handle $coreRef [format 0x%02x [ expr ${::i2c_hw_usr::FPGA_REG_MEMTEST_CTRL} + 1 ] ] $wdata

    #wait end of operation
    set mem_bufempty  1;
    while { $mem_bufempty == 1 } {
        set status [ reg_rd $handle $coreRef ${::i2c_hw_usr::FPGA_RD_REG_MEMTEST_STATUS} ];
        set mem_bufempty [ expr { ( $status >> ${::i2c_hw_usr::FPGA_RD_REG_MEMTEST_STATUS_WR_FULL_BIT} ) & 0x01 } ];
        set mem_err [ expr { ( $status >> ${::i2c_hw_usr::FPGA_RD_REG_MEMTEST_STATUS_WR_UNDERRUN_BIT} ) & 0x0F } ];
        if { $mem_err != 0 } {
            print_memstatus $status
            return -code error "mem status: mem_err=$mem_err";
        }
    }

    return -code ok;
}

proc scanVIOCore { handle coreRef } {
    global CSE_MSG_INFO
    global CSEVIO_MANUFACTURER_ID
    global CSEVIO_CORE_TYPE
    global CSEVIO_CORE_MAJOR_VERSION
    global CSEVIO_CORE_MINOR_VERSION
    global CSEVIO_CORE_REVISION
    global CSEVIO_CG_MAJOR_VERSION
    global CSEVIO_CG_MINOR_VERSION
    global CSEVIO_CG_MINOR_VERSION_ALPHA
    global CSEVIO_ASYNC_INPUT_COUNT
    global CSEVIO_SYNC_INPUT_COUNT
    global CSEVIO_ASYNC_OUTPUT_COUNT
    global CSEVIO_SYNC_OUTPUT_COUNT


    # csevio_get_core_info $handle \
    #                      $coreRef \
    #                      coreInfoTclArray
    # set str [format \
    #                 "\CSEVIO_CORE_INFO: \n manufacturerId:%u, \n\
    #                 coreType:%u, coreMajorVersion:%u, coreMinorVersion:%u, coreRevision:%u, \n\
    #                 cgMajorVersion:%u, cgMinorVersion:%u, cgMinorVersionAlpha:%u, \n\
    #                 asyncInputCount:%u, syncInputCount:%u, asyncOutputCount:%u, syncOutputCount:%u\n\n" \
    #                 $coreInfoTclArray($CSEVIO_MANUFACTURER_ID) \
    #                 $coreInfoTclArray($CSEVIO_CORE_TYPE) \
    #                 $coreInfoTclArray($CSEVIO_CORE_MAJOR_VERSION) \
    #                 $coreInfoTclArray($CSEVIO_CORE_MINOR_VERSION) \
    #                 $coreInfoTclArray($CSEVIO_CORE_REVISION) \
    #                 $coreInfoTclArray($CSEVIO_CG_MAJOR_VERSION) \
    #                 $coreInfoTclArray($CSEVIO_CG_MINOR_VERSION) \
    #                 $coreInfoTclArray($CSEVIO_CG_MINOR_VERSION_ALPHA) \
    #                 $coreInfoTclArray($CSEVIO_ASYNC_INPUT_COUNT) \
    #                 $coreInfoTclArray($CSEVIO_SYNC_INPUT_COUNT) \
    #                 $coreInfoTclArray($CSEVIO_ASYNC_OUTPUT_COUNT) \
    #                 $coreInfoTclArray($CSEVIO_SYNC_OUTPUT_COUNT) ]
    # csejtag_session send_message $handle $CSE_MSG_INFO $str

    #Some CseVIO functions to try...
    global CSEVIO_SYNC_OUTPUT
    global CSEVIO_SYNC_INPUT
    # global CSEVIO_ASYNC_OUTPUT
    # global CSEVIO_ASYNC_INPUT

    csevio_init_core $handle \
                     $coreRef

    csevio_define_signal $handle $coreRef "reg_wen" $CSEVIO_SYNC_OUTPUT 24
    csevio_define_signal $handle $coreRef "reg_ren" $CSEVIO_SYNC_OUTPUT 25
    csevio_define_signal $handle $coreRef "fifo_ren" $CSEVIO_SYNC_OUTPUT 26
    csevio_define_signal $handle $coreRef "fr_line_rd" $CSEVIO_SYNC_OUTPUT 27
    csevio_define_signal $handle $coreRef "fifo_nrst" $CSEVIO_SYNC_OUTPUT 28
    csevio_define_bus $handle $coreRef "reg_addr" $CSEVIO_SYNC_OUTPUT [list 0 1 2 3 4 5 6 7]
    csevio_define_bus $handle $coreRef "reg_txd" $CSEVIO_SYNC_OUTPUT [list 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23]
    csevio_define_bus $handle $coreRef "reg_rxd" $CSEVIO_SYNC_INPUT [list 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15]
    csevio_define_bus $handle $coreRef "fifo_rxd" $CSEVIO_SYNC_INPUT [list 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 \
                                                                           32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47]
    csevio_define_signal $handle $coreRef "fifo_empfy" $CSEVIO_SYNC_INPUT 48

    # set mem_adr 1
    # set mem_rdata 1
    # set mem_rdata 1
    while (1) {
        eval exec >&@stdout <@stdin [auto_execok cls]
        # puts "--- [ i2c_read $handle $coreRef 0x300A ]"
        puts "------ test v0.1------\n"
        set fpga_firmware [ reg_rd $handle $coreRef [format 0x%02x [ expr ${::i2c_hw_usr::FPGA_RD_FIRMWARE_REV} + 0]] ]
        puts "fpga firmware: [ expr [ expr $fpga_firmware >> 8 ] & 0x0FF ].[ expr [ expr $fpga_firmware >> 0 ] & 0x0FF ] \n"

        reg_wr $handle $coreRef ${::i2c_hw_usr::FPGA_REG_MEM_WRBURST} 0x0000
        puts "mem burst: [reg_rd $handle $coreRef ${::i2c_hw_usr::FPGA_RD_REG_MEM_WRBURST}] "

        puts "0 - quit"
        puts "1 - continue"
        puts "2 - ov4689 configuration"
        puts "3 - save to file"
        puts "4 - mem wr"
        puts "5 - mem rd"
        puts "6 - mem status"
        puts "7 - get frame(mem)"
        puts "8 - get frame(fifo)"
        puts "9 - reg wr"
        puts "10 - ov4689 juno_test_setting_001"
        puts "11 - ov4689 juno_test_setting_002"
        puts "12 - ov4689 juno_test_setting_003"
        puts "13 - ov4689 juno_test_setting_004"
        puts "14 - ov4689 juno_test_setting_005"
        puts "15 - ov4689 juno_test_setting_006"
        puts "16 - ov4689 juno_test_setting_007"
        puts -nonewline "Enter key: "
        flush stdout
        set usr_key [gets stdin]
        if { [string compare $usr_key "0"] == 0 } {
            break;

        } elseif {[string compare $usr_key "2"] == 0} {
            puts "ov4689_cfg: count regs write = [ llength ${::ov4689_cfg::regs} ]"
            foreach list_val ${::ov4689_cfg::regs} {
                if { [ catch { i2c_write $handle $coreRef [ lindex $list_val 0 ] [format 0x%04x [ lindex $list_val 1 ]] } result ] } {
                    puts "$result"
                    break;
                } else {
                    puts "addr: [ lindex $list_val 0 ] (hex); wdata: [ lindex $list_val 1 ]"
                }
            }

        } elseif { [string compare $usr_key "3"] == 0 } {
            set fp [open test.bin w]
            fconfigure $fp -translation binary
            for {set y 0} {$y < 1} {incr y} {
                for {set x 0} {$x < 8} {incr x} {
                    set ssss 0x00050004
                    set tttt [ expr $ssss + $x ]
                    set outBinData [binary format i $tttt ]
                    puts "fr: [ format %04d $y ] x [ format %04d $x ], mem_adr: $mem_adr, rdata: $mem_rdata"
                    puts -nonewline $fp $outBinData
                }
            }
            close $fp

        } elseif { [string compare $usr_key "4"] == 0 } {
            set mem_adr 1
            set mem_wdata 1
            while (1) {
                eval exec >&@stdout <@stdin [auto_execok cls]
                puts "mem write: addr=$mem_adr; wdata=$mem_wdata\n"
                puts "0 - exit"
                puts "1 - addr"
                puts "2 - data"
                puts "3 - write"
                puts -nonewline "Enter key: "
                flush stdout
                set usr_key [gets stdin]
                if { [string compare $usr_key "0"] == 0 } {
                    break;
                } elseif { [string compare $usr_key "1"] == 0 } {
                    puts -nonewline "mem_addr: "
                    flush stdout
                    set mem_adr [gets stdin]
                } elseif { [string compare $usr_key "2"] == 0 } {
                    puts -nonewline "mem_wdata: "
                    flush stdout
                    set mem_wdata [gets stdin]
                } elseif { [string compare $usr_key "3"] == 0 } {
                    mem_write $handle $coreRef $mem_adr $mem_wdata
                }
            }

        } elseif { [string compare $usr_key "5"] == 0 } {
            set mem_adr 1
            set mem_rdata 1
            while (1) {
                eval exec >&@stdout <@stdin [auto_execok cls]
                puts "mem read: addr=$mem_adr; rdata=$mem_rdata\n"
                puts "0 - exit"
                puts "1 - addr"
                puts "2 - read"
                puts -nonewline "Enter key: "
                flush stdout
                set usr_key [gets stdin]
                if { [string compare $usr_key "0"] == 0 } {
                    break;
                } elseif { [string compare $usr_key "1"] == 0 } {
                    puts -nonewline "mem_addr: "
                    flush stdout
                    set mem_adr [gets stdin]
                } elseif { [string compare $usr_key "2"] == 0 } {
                    set mem_rdata [ mem_read $handle $coreRef $mem_adr ]
                    # puts " rdata= [ mem_read $handle $coreRef $mem_adr ]"
                }
            }

        } elseif { [string compare $usr_key "6"] == 0 } {
            set mem_adr 1
            set mem_rdata 1
            while (1) {
                eval exec >&@stdout <@stdin [auto_execok cls]
                #get mem status
                set status [ reg_rd $handle $coreRef ${::i2c_hw_usr::FPGA_RD_REG_MEMTEST_STATUS} ];
                print_memstatus $status
                puts "0 - exit"
                puts -nonewline "Enter key: "
                flush stdout
                set usr_key [gets stdin]
                if { [string compare $usr_key "0"] == 0 } {
                    break;
                }
            }

        } elseif { [string compare $usr_key "7"] == 0 } {
            set fp [open juno_fr8bit.bin w]
            fconfigure $fp -translation binary
            for {set y 0} {$y < 4} {incr y} {
                set mem_adr_base [ format 0x%04x [ expr ($y << 13) & 0xFFFFE000 ] ]
                for {set x 0} {$x < 32} {incr x} {
                    set mem_adr [ format 0x%04x [ expr $mem_adr_base + $x ] ]
                    set mem_rdata [ mem_read $handle $coreRef $mem_adr ]
                    # if { !($x % 128) } {
                    puts "fr: [ format %04d $y ] x [ format %04d $x ], mem_adr: $mem_adr, rdata: $mem_rdata"
                    # }
                    set mem_rdata_l [ expr $mem_rdata & 0xFFFF ]
                    set mem_rdata_h [ expr { ( $mem_rdata >> 16 ) & 0xFFFF } ]
                    set outBinData [ binary format s $mem_rdata_l ]
                    set outBinData [ binary format s $mem_rdata_h ]
                    puts -nonewline $fp $outBinData
                }
            }
            close $fp
            puts -nonewline "Enter key: "
            flush stdout
            set usr_key [gets stdin]

        } elseif { [string compare $usr_key "8"] == 0 } {
            fifo_nrst_ctl $handle $coreRef 1
            set fp [open juno_fr16bit.bin w]
            fconfigure $fp -translation binary
            for {set n 0} {$n < 1} {incr n} {
                for {set y 0} {$y < 720} {incr y} {
                    fr_line_rd_ctl $handle $coreRef 0
                    fr_line_rd_ctl $handle $coreRef 1
                    for {set x 0} {$x < 640} {incr x} {
                        if { $x == 0 } {
                        puts "fr($n): [ format %04d $y ] x [ format %04d $x ]"
                        }
                        set outBinData [ binary format i [ fifo_rd $handle $coreRef ] ]
                        puts -nonewline $fp $outBinData
                    }
                }
            }
            close $fp
            fifo_nrst_ctl $handle $coreRef 0
            puts -nonewline "Enter key: "
            flush stdout
            set usr_key [gets stdin]

        } elseif { [string compare $usr_key "9"] == 0 } {
            set reg_adr 1
            set reg_write_data 1
            set reg_read_data 1
            while (1) {
                eval exec >&@stdout <@stdin [auto_execok cls]
                puts "reg_addr=$reg_adr; wdata=$reg_write_data; rdata=$reg_read_data\n"
                puts "0 - exit"
                puts "1 - addr"
                puts "2 - wrdata"
                puts "3 - write"
                puts "4 - read"
                puts -nonewline "Enter key: "
                flush stdout
                set usr_key [gets stdin]
                if { [string compare $usr_key "0"] == 0 } {
                    break;

                } elseif { [string compare $usr_key "1"] == 0 } {
                    puts -nonewline "reg_addr: "
                    flush stdout
                    set reg_adr [gets stdin]

                } elseif { [string compare $usr_key "2"] == 0 } {
                    puts -nonewline "reg_wdata: "
                    flush stdout
                    set reg_write_data [gets stdin]

                } elseif { [string compare $usr_key "3"] == 0 } {
                    reg_wr $handle $coreRef $reg_adr $reg_write_data

                } elseif { [string compare $usr_key "4"] == 0 } {
                    set reg_read_data [reg_rd $handle $coreRef $reg_adr ]
                }
            }

        } elseif { [string compare $usr_key "10"] == 0 } {
            puts "ov4689_cfg: juno_test_setting_001:"
            foreach list_val ${::ov4689_cfg::juno_test_setting_001} {
                if { [ catch { i2c_write $handle $coreRef [ lindex $list_val 0 ] [format 0x%04x [ lindex $list_val 1 ]] } result ] } {
                    puts "$result"
                    break;
                } else {
                    puts "addr: [ lindex $list_val 0 ] (hex); wdata: [ lindex $list_val 1 ]"
                }
            }
            while (1) {
                puts "0 - exit"
                puts -nonewline "Enter key: "
                flush stdout
                set usr_key [gets stdin]
                if { [string compare $usr_key "0"] == 0 } {
                    break;
                }
            }

        } elseif { [string compare $usr_key "11"] == 0 } {
            puts "ov4689_cfg: juno_test_setting_002:"
            foreach list_val ${::ov4689_cfg::juno_test_setting_002} {
                if { [ catch { i2c_write $handle $coreRef [ lindex $list_val 0 ] [format 0x%04x [ lindex $list_val 1 ]] } result ] } {
                    puts "$result"
                    break;
                } else {
                    puts "addr: [ lindex $list_val 0 ] (hex); wdata: [ lindex $list_val 1 ]"
                }
            }
            while (1) {
                puts "0 - exit"
                puts -nonewline "Enter key: "
                flush stdout
                set usr_key [gets stdin]
                if { [string compare $usr_key "0"] == 0 } {
                    break;
                }
            }

        } elseif { [string compare $usr_key "12"] == 0 } {
            puts "ov4689_cfg: juno_test_setting_003:"
            foreach list_val ${::ov4689_cfg::juno_test_setting_003} {
                if { [ catch { i2c_write $handle $coreRef [ lindex $list_val 0 ] [format 0x%04x [ lindex $list_val 1 ]] } result ] } {
                    puts "$result"
                    break;
                } else {
                    puts "addr: [ lindex $list_val 0 ] (hex); wdata: [ lindex $list_val 1 ]"
                }
            }
            while (1) {
                puts "0 - exit"
                puts -nonewline "Enter key: "
                flush stdout
                set usr_key [gets stdin]
                if { [string compare $usr_key "0"] == 0 } {
                    break;
                }
            }

        } elseif { [string compare $usr_key "13"] == 0 } {
            puts "ov4689_cfg: juno_test_setting_004:"
            foreach list_val ${::ov4689_cfg::juno_test_setting_004} {
                if { [ catch { i2c_write $handle $coreRef [ lindex $list_val 0 ] [format 0x%04x [ lindex $list_val 1 ]] } result ] } {
                    puts "$result"
                    break;
                } else {
                    puts "addr: [ lindex $list_val 0 ] (hex); wdata: [ lindex $list_val 1 ]"
                }
            }
            while (1) {
                puts "0 - exit"
                puts -nonewline "Enter key: "
                flush stdout
                set usr_key [gets stdin]
                if { [string compare $usr_key "0"] == 0 } {
                    break;
                }
            }

        } elseif { [string compare $usr_key "14"] == 0 } {
            puts "ov4689_cfg: juno_test_setting_005:"
            foreach list_val ${::ov4689_cfg::juno_test_setting_005} {
                if { [ catch { i2c_write $handle $coreRef [ lindex $list_val 0 ] [format 0x%04x [ lindex $list_val 1 ]] } result ] } {
                    puts "$result"
                    break;
                } else {
                    puts "addr: [ lindex $list_val 0 ] (hex); wdata: [ lindex $list_val 1 ]"
                }
            }
            while (1) {
                puts "0 - exit"
                puts -nonewline "Enter key: "
                flush stdout
                set usr_key [gets stdin]
                if { [string compare $usr_key "0"] == 0 } {
                    break;
                }
            }

        } elseif { [string compare $usr_key "15"] == 0 } {
            puts "ov4689_cfg: juno_test_setting_006:"
            foreach list_val ${::ov4689_cfg::juno_test_setting_006} {
                if { [ catch { i2c_write $handle $coreRef [ lindex $list_val 0 ] [format 0x%04x [ lindex $list_val 1 ]] } result ] } {
                    puts "$result"
                    break;
                } else {
                    puts "addr: [ lindex $list_val 0 ] (hex); wdata: [ lindex $list_val 1 ]"
                }
            }
            while (1) {
                puts "0 - exit"
                puts -nonewline "Enter key: "
                flush stdout
                set usr_key [gets stdin]
                if { [string compare $usr_key "0"] == 0 } {
                    break;
                }
            }

        } elseif { [string compare $usr_key "16"] == 0 } {
            puts "ov4689_cfg: juno_test_setting_007:"
            foreach list_val ${::ov4689_cfg::juno_test_setting_007} {
                if { [ catch { i2c_write $handle $coreRef [ lindex $list_val 0 ] [format 0x%04x [ lindex $list_val 1 ]] } result ] } {
                    puts "$result"
                    break;
                } else {
                    puts "addr: [ lindex $list_val 0 ] (hex); wdata: [ lindex $list_val 1 ]"
                }
            }
            while (1) {
                puts "0 - exit"
                puts -nonewline "Enter key: "
                flush stdout
                set usr_key [gets stdin]
                if { [string compare $usr_key "0"] == 0 } {
                    break;
                }
            }

        } elseif { [string compare $usr_key "1"] == 0 } {
            puts "Key: $usr_key"
        }
    }

    csevio_terminate_core $handle $coreRef
}

proc writeMessage {handle msgFlags msg} {
    global debug
    global CSE_MSG_ERROR
    global CSE_MSG_WARNING
    global CSE_MSG_STATUS
    global CSE_MSG_INFO
    global CSE_MSG_NOISE
    global CSE_MSG_DEBUG
    if {[expr $debug || ($msgFlags != $CSE_MSG_DEBUG)]} {
        if {$msgFlags == $CSE_MSG_ERROR}      {
            puts -nonewline "Error:"
        } elseif {$msgFlags == $CSE_MSG_WARNING}         {
            puts -nonewline "Warning:"
        } elseif {$msgFlags == $CSE_MSG_INFO}            {
            puts -nonewline "Info:"
        } elseif {$msgFlags == $CSE_MSG_STATUS}          {
            puts -nonewline "Status:"
        } elseif {$msgFlags == $CSE_MSG_DEBUG}           {
            puts -nonewline "Debug:"
        }
        puts -nonewline $msg
        flush stdout
    }
}

proc binaryStringToInt {binarystring} {
    set len [string length $binarystring]
    set retval 0
    for {set i 0} {$i < $len} {incr i} {
        set retval [expr $retval << 1]
        if {[string index $binarystring $i] == "1"} {
            set retval [expr $retval | 1]
        }
    }
    return $retval
}

proc dumpInHex {buffer} {
    global CSE_MSG_NOISE
    set start 0
    set end 15

    while {$end < [string length $buffer]} {
        set buf [string range $buffer $start $end]
        writeMessage 0 $CSE_MSG_NOISE "$buf\n"
        set start [expr $start + 16]
        set end [expr $end + 16]
    }
}

# Start the program
main $argc $argv
