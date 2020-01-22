//-----------------------------------------------------------------------
// Engineer    : Golovachenko Victor
//
// Create Date : 20.08.2018 9:43:43
// Module Name :
//
// Description :
//
//------------------------------------------------------------------------
`define FPGA_REG_COUNT        (128)
`define FPGA_REG_DWIDTH       (16) //Data Width
`define FPGA_REG_AWIDTH       (8)  //Address Width

`define FPGA_WR_OFFSET        (0)
`define FPGA_RD_OFFSET        (64)

//----------------------------------------
// Bit map and address map registers (WR), 16 bit width
//----------------------------------------

`define FPGA_REG_MEMTEST_CTRL      (`FPGA_WR_OFFSET + 2) //default value: 0
    `define FPGA_REG_MEMTEST_CTRL_ADR_LSB_BIT    (0)
    `define FPGA_REG_MEMTEST_CTRL_ADR_MSB_BIT    (28)
    `define FPGA_REG_MEMTEST_CTRL_TEST_BIT       (29) //Hardware detect rising edge
    `define FPGA_REG_MEMTEST_CTRL_DIR_BIT        (30) //0/1 - MEM Write/Read (if hardware support user write/read)
    `define FPGA_REG_MEMTEST_CTRL_RD_STROB_BIT   (31) //if hardware support user write/read

`define FPGA_REG_MEMTEST_WDATA     (`FPGA_WR_OFFSET + 4) //default x4000000(64MB).

`define FPGA_REG_IMG_SENSOR        (`FPGA_WR_OFFSET + 6)  //default value: x01
    `define FPGA_REG_IMG_SENSOR_nRST_BIT   (0)

`define FPGA_REG_IR_LED_PWM        (`FPGA_WR_OFFSET + 7) //default value: 0 (value > 0 - LED ON; 0 - LED OFF)
    `define FPGA_REG_IR_LED_PWM_LSB_BIT    (0)
    `define FPGA_REG_IR_LED_PWM_MSB_BIT    (8)

`define FPGA_REG_IR_FILTER_CTRL    (`FPGA_WR_OFFSET + 8) //default value: 0
    `define FPGA_REG_IR_FILTER_CTRL_IN1_BIT     (0)
    `define FPGA_REG_IR_FILTER_CTRL_IN2_BIT     (1)
    `define FPGA_REG_IR_FILTER_CTRL_EN_BIT      (4)

`define FPGA_REG_FR_XSIZE          (`FPGA_WR_OFFSET + 10) //default value: 1280
`define FPGA_REG_FR_YSIZE          (`FPGA_WR_OFFSET + 11) //default value: 720

`define FPGA_REG_ROI_X1            (`FPGA_WR_OFFSET + 14) //default value: 0
`define FPGA_REG_ROI_X2            (`FPGA_WR_OFFSET + 15) //default value: 1279
`define FPGA_REG_ROI_Y1            (`FPGA_WR_OFFSET + 16) //default value: 0
`define FPGA_REG_ROI_Y2            (`FPGA_WR_OFFSET + 17) //default value: 719

`define FPGA_REG_MEM_WBURST        (`FPGA_WR_OFFSET + 20) //default value: x1010
    `define FPGA_REG_MEM_WBURST_CH0_LSB  (0)
    `define FPGA_REG_MEM_WBURST_CH0_MSB  (7)
    `define FPGA_REG_MEM_WBURST_CH1_LSB  (8)
    `define FPGA_REG_MEM_WBURST_CH1_MSB  (15)

`define FPGA_REG_MEM_RBURST        (`FPGA_WR_OFFSET + 21) //default value: x0018
    `define FPGA_REG_MEM_RBURST_CH0_LSB  (0)
    `define FPGA_REG_MEM_RBURST_CH0_MSB  (7)
    `define FPGA_REG_MEM_RBURST_CH1_LSB  (8)
    `define FPGA_REG_MEM_RBURST_CH1_MSB  (15)

`define FPGA_REG_MEM_WRBURST       (`FPGA_WR_OFFSET + 22) //default value: 0
    `define FPGA_REG_MEM_WRBURST_WCH_LSB  (0)
    `define FPGA_REG_MEM_WRBURST_WCH_MSB  (7)
    `define FPGA_REG_MEM_WRBURST_RCH_LSB  (8)
    `define FPGA_REG_MEM_WRBURST_RCH_MSB  (15)

`define FPGA_REG_DEBAYER_CTL       (`FPGA_WR_OFFSET + 23)  //default value: x00
    `define FPGA_REG_DEBAYER_CTL_MODE_LSB_BIT  (0)
    `define FPGA_REG_DEBAYER_CTL_MODE_MSB_BIT  (2)
            `define FPGA_REG_DEBAYER_CTL_MODE_0  (0)
            `define FPGA_REG_DEBAYER_CTL_MODE_1  (1)
            `define FPGA_REG_DEBAYER_CTL_MODE_2  (2)
            `define FPGA_REG_DEBAYER_CTL_MODE_3  (3)

`define FPGA_REG_TEST_ARRAY        (`FPGA_WR_OFFSET + 26) //array(16 x 16bit)

`define FPGA_REG_RGB_ACC_CTRL      (`FPGA_WR_OFFSET + 43) //default value: 0
    `define FPGA_REG_RGB_ACC_CTRL_LATCH_BIT   (0)

`define FPGA_REG_CTRL              (`FPGA_WR_OFFSET + 44) //default value: 0
    `define FPGA_REG_CTRL_PV_SRC_L_BIT         (0) //select mode output (YUV422) for Parallel Video Interface
    `define FPGA_REG_CTRL_PV_SRC_H_BIT         (1)
        `define FPGA_REG_CTRL_PV_SRC_YUV422         (0) //YUV422 - color frame (default value)
        `define FPGA_REG_CTRL_PV_SRC_GRAY           (1) //YUV422 - gray frame
    `define FPGA_REG_CTRL_CSI_8B_SEL_L_BIT        (2)
    `define FPGA_REG_CTRL_CSI_8B_SEL_H_BIT        (3)
        `define FPGA_REG_CTRL_CSI_8B_SEL_0          (2'd0) //d[9:0] -> d[9:2]
        `define FPGA_REG_CTRL_CSI_8B_SEL_1          (2'd1) //d[9:0] -> d[8:1]
        `define FPGA_REG_CTRL_CSI_8B_SEL_2          (2'd2) //d[8:0] -> d[8:0]
//        `define FPGA_REG_CTRL_BINNING_OFF           (0) //default value
//        `define FPGA_REG_CTRL_BINNING_2             (1)
//        `define FPGA_REG_CTRL_BINNING_4             (2)
//    `define FPGA_REG_CTRL_CSI_TX_BYPASS_BIT    (4) //Select Data source for mem_wch0 - 0/1 - edge_detect frame/raw data frame
//    `define FPGA_REG_CTRL_MEM_WCH0_TEST_BIT    (8) //1/0 - On/Off test mode for mem_wch0
//    `define FPGA_REG_CTRL_MEM_WCH1_TEST_BIT    (9) //1/0 - On/Off test mode for mem_wch1
    `define FPGA_REG_CTRL_CPU_FR_SEL_BIT       (11) //0 - Gray / 1 -Edge Detect - select for first frame into big frame for CPU
    `define FPGA_REG_CTRL_TP_SRC_L_BIT         (12) //select signals on TP
    `define FPGA_REG_CTRL_TP_SRC_H_BIT         (14)
    `define FPGA_REG_CTRL_MEMTEST_DBG_BIT      (15) //debug memory testing

`define FPGA_REG_R_GAIN            (`FPGA_WR_OFFSET + 45) //default value: 0x400 is 1x gain
`define FPGA_REG_G_GAIN            (`FPGA_WR_OFFSET + 46) //default value: 0x400 is 1x gain
`define FPGA_REG_B_GAIN            (`FPGA_WR_OFFSET + 47) //default value: 0x400 is 1x gain

`define FPGA_REG_I2C_CTL           (`FPGA_WR_OFFSET + 48) //default value: 0x00
    `define FPGA_REG_I2C_CTL_ADEV_LSB     (0)
    `define FPGA_REG_I2C_CTL_ADEV_MSB     (7)
    `define FPGA_REG_I2C_CTL_DIR          (8) //Write = 0 /Read = 1
    `define FPGA_REG_I2C_CTL_START        (9)
`define FPGA_REG_I2C_AREG          (`FPGA_WR_OFFSET + 49)
`define FPGA_REG_I2C_DREG          (`FPGA_WR_OFFSET + 50) //valid data [7:0]



//----------------------------------------
// Address map registers (RD), 16 bit width
//---------------------------------    -------
`define FPGA_RD_FIRMWARE_REV           (`FPGA_RD_OFFSET + 0) //32bit

`define FPGA_RD_REG_MEMTEST_RDATA      (`FPGA_RD_OFFSET + 6)
`define FPGA_RD_REG_MEMTEST_STATUS     (`FPGA_RD_OFFSET + 8)
    `define FPGA_RD_REG_MEMTEST_STATUS_CALIB_DONE_BIT    (0)
    `define FPGA_RD_REG_MEMTEST_STATUS_CMD_EMPTY_BIT     (1)
    `define FPGA_RD_REG_MEMTEST_STATUS_WR_EMPTY_BIT      (2)
    `define FPGA_RD_REG_MEMTEST_STATUS_RD_EMPTY_BIT      (3)
    `define FPGA_RD_REG_MEMTEST_STATUS_CMD_FULL_BIT      (4)
    `define FPGA_RD_REG_MEMTEST_STATUS_WR_FULL_BIT       (5)
    `define FPGA_RD_REG_MEMTEST_STATUS_RD_FULL_BIT       (6)
    `define FPGA_RD_REG_MEMTEST_STATUS_WR_UNDERRUN_BIT   (7)
    `define FPGA_RD_REG_MEMTEST_STATUS_WR_ERROR_BIT      (8)
    `define FPGA_RD_REG_MEMTEST_STATUS_RD_OVERFLOW_BIT   (9)
    `define FPGA_RD_REG_MEMTEST_STATUS_RD_ERROR_BIT      (10)
    `define FPGA_RD_REG_MEMTEST_STATUS_BUSY_BIT          (11)
    `define FPGA_RD_REG_MEMTEST_STATUS_ERR_BIT           (12)

`define FPGA_RD_REG_IR_LED_PWM         (`FPGA_RD_OFFSET + 9)
`define FPGA_RD_REG_IR_FILTER_CTRL     (`FPGA_RD_OFFSET + 10)

`define FPGA_RD_REG_FR_XSIZE           (`FPGA_RD_OFFSET + 13)
`define FPGA_RD_REG_FR_YSIZE           (`FPGA_RD_OFFSET + 14)

`define FPGA_RD_REG_TEST_ARRAY         (`FPGA_RD_OFFSET + 15) //array(16 x 16bit)

`define FPGA_RD_REG_DEBAYER_CTL        (`FPGA_RD_OFFSET + 33)

`define FPGA_RD_REG_MEM_WBURST         (`FPGA_RD_OFFSET + 34)
`define FPGA_RD_REG_MEM_RBURST         (`FPGA_RD_OFFSET + 35)

`define FPGA_RD_REG_ROI_X1             (`FPGA_RD_OFFSET + 36)
`define FPGA_RD_REG_ROI_X2             (`FPGA_RD_OFFSET + 37)
`define FPGA_RD_REG_ROI_Y1             (`FPGA_RD_OFFSET + 38)
`define FPGA_RD_REG_ROI_Y2             (`FPGA_RD_OFFSET + 39)

`define FPGA_RD_REG_IMG_SENSOR         (`FPGA_RD_OFFSET + 41)

`define FPGA_RD_REG_R_ACC              (`FPGA_RD_OFFSET + 42) //32bit - the sum of all pixels(accumulator) in the red channel for the frame
`define FPGA_RD_REG_G_ACC              (`FPGA_RD_OFFSET + 44) //32bit - the sum of all pixels(accumulator) in the green channel for the frame
`define FPGA_RD_REG_B_ACC              (`FPGA_RD_OFFSET + 46) //32bit - the sum of all pixels(accumulator) in the blue channel for the frame

`define FPGA_RD_REG_RGB_ACC_CTRL       (`FPGA_RD_OFFSET + 48)

`define FPGA_RD_REG_CTRL               (`FPGA_RD_OFFSET + 49)

`define FPGA_RD_REG_MEM_WRBURST        (`FPGA_RD_OFFSET + 50)

`define FPGA_RD_REG_R_GAIN             (`FPGA_RD_OFFSET + 51)
`define FPGA_RD_REG_G_GAIN             (`FPGA_RD_OFFSET + 52)
`define FPGA_RD_REG_B_GAIN             (`FPGA_RD_OFFSET + 53)

`define FPGA_RD_REG_I2C_CTL            (`FPGA_RD_OFFSET + 54)
`define FPGA_RD_REG_I2C_STATUS         (`FPGA_RD_OFFSET + 55)
    `define FPGA_RD_REG_I2C_STATUS_BUSY         (0) //only read
    `define FPGA_RD_REG_I2C_STATUS_ERR          (1) //only read
`define FPGA_RD_REG_I2C_AREG           (`FPGA_RD_OFFSET + 56)
`define FPGA_RD_REG_I2C_DREG           (`FPGA_RD_OFFSET + 57)  //valid data [7:0]
