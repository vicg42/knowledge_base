#-----------------------------------------------------------------------
# Author : Golovachenko Victor
#
# Description :
#------------------------------------------------------------------------
namespace eval hw_usr \
{
    variable AURORA_CHCOUNT              2

    variable MODULE_ZYNQ_ETHCOUNT        3
    variable MODULE_ZYNQ_ETHCOUNT_MAX    3

    variable MODULE_ARTIX_COUNT          2
    variable MODULE_ARTIX_ETHCOUNT       4
    variable MODULE_ARTIX_ETHCOUNT_MAX   4

    variable BASE_ADDR 0x44A00000

    variable UREG_FIRMWARE_DATE    0x00000000
    variable UREG_FIRMWARE_TIME    0x00000004
    variable UREG_CTRL             0x00000008
        variable UREG_CTRL_SEL_ARTIX_ETH_BIT     8
        variable UREG_CTRL_SEL_ZYNQ_ETH_BIT      12
    variable UREG_TEST0            0x0000000C
    variable UREG_TEST1            0x00000010
    variable UREG_STATUS_AURORA    0x00000014
    variable UREG_STATUS_ETH       0x00000018

}; #namespace eval hw_usr
