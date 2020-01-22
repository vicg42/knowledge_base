#-----------------------------------------------------------------------
# Author : Golovachenko Victor
#
# Description :
#------------------------------------------------------------------------
namespace eval i2c_hw_usr \
{
    variable I2C_WRITE_CMD    0x00
    variable I2C_READ_CMD     0x01
    variable I2C_DEV_ADDR     0x36

    variable FPGA_MEM_WR      0x00
    variable FPGA_MEM_RD      0x01

    variable FPGA_WR_OFFSET     0
    variable FPGA_RD_OFFSET     64

    #Write
    variable FPGA_REG_MEMTEST_CTRL     [format 0x%02x [expr $FPGA_WR_OFFSET + 2]]
        variable FPGA_REG_MEMTEST_CTRL_ADR_LSB_BIT    0
        variable FPGA_REG_MEMTEST_CTRL_ADR_MSB_BIT    28
        variable FPGA_REG_MEMTEST_CTRL_TEST_BIT       29
        variable FPGA_REG_MEMTEST_CTRL_DIR_BIT        30
        variable FPGA_REG_MEMTEST_CTRL_RD_STROB_BIT   31

    variable FPGA_REG_MEMTEST_WDATA    [format 0x%02x [expr $FPGA_WR_OFFSET + 4]]
    variable FPGA_REG_MEM_WRBURST      [format 0x%02x [expr $FPGA_WR_OFFSET + 22]]

    variable FPGA_REG_I2C_CTL          [format 0x%02x [expr $FPGA_WR_OFFSET + 48]]
        variable FPGA_REG_I2C_CTL_ADEV_LSB_BIT     0
        variable FPGA_REG_I2C_CTL_DIR_BIT          8
        variable FPGA_REG_I2C_CTL_START_BIT        9
    variable FPGA_REG_I2C_AREG         [format 0x%02x [expr $FPGA_WR_OFFSET + 49]]
    variable FPGA_REG_I2C_DREG         [format 0x%02x [expr $FPGA_WR_OFFSET + 50]]

    #Read
    variable FPGA_RD_FIRMWARE_REV           [format 0x%02x [expr $FPGA_RD_OFFSET + 0]]

    variable FPGA_RD_REG_MEMTEST_RDATA      [format 0x%02x [expr $FPGA_RD_OFFSET + 6]]
    variable FPGA_RD_REG_MEMTEST_STATUS     [format 0x%02x [expr $FPGA_RD_OFFSET + 8]]
        variable FPGA_RD_REG_MEMTEST_STATUS_CALIB_DONE_BIT    0
        variable FPGA_RD_REG_MEMTEST_STATUS_CMD_EMPTY_BIT     1
        variable FPGA_RD_REG_MEMTEST_STATUS_WR_EMPTY_BIT      2
        variable FPGA_RD_REG_MEMTEST_STATUS_RD_EMPTY_BIT      3
        variable FPGA_RD_REG_MEMTEST_STATUS_CMD_FULL_BIT      4
        variable FPGA_RD_REG_MEMTEST_STATUS_WR_FULL_BIT       5
        variable FPGA_RD_REG_MEMTEST_STATUS_RD_FULL_BIT       6
        variable FPGA_RD_REG_MEMTEST_STATUS_WR_UNDERRUN_BIT   7
        variable FPGA_RD_REG_MEMTEST_STATUS_WR_ERROR_BIT      8
        variable FPGA_RD_REG_MEMTEST_STATUS_RD_OVERFLOW_BIT   9
        variable FPGA_RD_REG_MEMTEST_STATUS_RD_ERROR_BIT      10
        variable FPGA_RD_REG_MEMTEST_STATUS_BUSY_BIT          11
        variable FPGA_RD_REG_MEMTEST_STATUS_ERR_BIT           12

    variable FPGA_RD_REG_MEM_WRBURST   [format 0x%02x [expr $FPGA_RD_OFFSET + 50]]

    variable FPGA_RD_REG_I2C_CTL       [format 0x%02x [expr $FPGA_RD_OFFSET + 54]]
    variable FPGA_RD_REG_I2C_STATUS    [format 0x%02x [expr $FPGA_RD_OFFSET + 55]]
        variable FPGA_RD_REG_I2C_STATUS_BUSY_BIT        0
        variable FPGA_RD_REG_I2C_STATUS_ERR_BIT         1
    variable FPGA_RD_REG_I2C_AREG      [format 0x%02x [expr $FPGA_RD_OFFSET + 56]]
    variable FPGA_RD_REG_I2C_DREG      [format 0x%02x [expr $FPGA_RD_OFFSET + 57]]

}; #namespace eval i2c_hw_usr
