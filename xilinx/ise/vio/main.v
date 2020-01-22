//-----------------------------------------------------------------------
// Engineer    : Golovachenko Victor
//
// Create Date : 27.04.2018 15:40:36
// Module Name :
//
// Description :
//
//------------------------------------------------------------------------

`include "fpga_regs.v"

module main #(
    parameter FIRMWARE = {8'd00, 8'd01, 8'd78},

`ifdef DBG_CLAMP_0
    parameter FR_SIZE_X_DEFAULT = 16'd256,
    parameter FR_SIZE_Y_DEFAULT = 16'd384,
`elsif DBG_CLAMP_1
    parameter FR_SIZE_X_DEFAULT = 16'd1284,
    parameter FR_SIZE_Y_DEFAULT = 16'd18,
`elsif DBG_CLAMP_2
    parameter FR_SIZE_X_DEFAULT = 16'd1284,
    parameter FR_SIZE_Y_DEFAULT = 16'd18,
`else
    parameter FR_SIZE_X_DEFAULT = 16'd1280,
    parameter FR_SIZE_Y_DEFAULT = 16'd720,
`endif

    parameter MEM_WBURST_DEFAULT = 16'h1010,
    parameter MEM_RBURST_DEFAULT = 16'h3828,
    parameter MEM_WRBURST_DEFAULT= 16'h1010,

    parameter C3_NUM_DQ_PINS        = 16, // External memory data width
    parameter C3_MEM_ADDR_WIDTH     = 13, // External memory address width
    parameter C3_MEM_BANKADDR_WIDTH = 3,  // External memory bank address width

    parameter DLANE_COUNT = 2,
    parameter LINE_SIZE_MAX = 4096,
    parameter SENSOR_PIXEL_WIDTH = 10,
    parameter PIXEL_WIDTH = 8
)(
    //CSI_RX
    input [3:0] csi_rx_hs_dp,
    input [3:0] csi_rx_hs_dn,
    input       csi_rx_hs_cp,
    input       csi_rx_hs_cn,

    input [3:0] csi_rx_lp_dp,
    input [3:0] csi_rx_lp_dn,
    input       csi_rx_lp_cp,
    input       csi_rx_lp_cn,

    //parallel video interface
    output [7:0] pv_do,
    output       pv_de,
    output       pv_hs,
    output       pv_vs,
    output       pv_cl,

    // //CSI_TX
    // inout [3:0] csi_tx_hs_dp,
    // inout [3:0] csi_tx_hs_dn,
    // inout       csi_tx_hs_cp,
    // inout       csi_tx_hs_cn,

    // inout [3:0] csi_tx_lp_dp,
    // inout [3:0] csi_tx_lp_dn,
    // inout       csi_tx_lp_cp,
    // inout       csi_tx_lp_cn,

    inout   i2c_scl,
    inout   i2c_sda,

    // input   spi_ss,
    // input   spi_sclk,
    // input   spi_mosi,
    // output  spi_miso,

    input   cpu_img_sensor_pwr_on,
    input   cpu_img_sensor_clk_en, //1-clk on; 0 - clk off
    input   cpu_img_sensor_rst, //1-reset off; 0 - reset on
    output  img_sensor_clk,
    output  img_sensor_rst,
    input   img_sensor_hsyn,
    input   img_sensor_vsyn,
    input   img_sensor_fsin,
    output  reg img_sensor_1V2_on = 1'b0,
    output  reg img_sensor_1V8_on = 1'b0,
    output  reg img_sensor_2V8_on = 1'b0,

    input   cpu_ir_sensor_spi_clk,
    input   cpu_ir_sensor_spi_cs,
    output  cpu_ir_sensor_spi_miso,
    input   cpu_ir_sensor_nrst,
    input   cpu_ir_sensor_mclk_en, //1-clk on; 0 - clk off
    input   cpu_ir_sensor_en,
    output  ir_sensor_spi_clk,
    output  ir_sensor_spi_cs,
    input   ir_sensor_spi_miso,
    output  ir_sensor_mclk_25m,
    output  ir_sensor_nrst,
    output  ir_sensor_en,

    input   cpu_irled_on,
    output  irled_on,
    output  irled_pwm, //max - 0; min -1

    input   cpu_irflt_on,

    output irflt_en,
    output irflt_in1,
    output irflt_in2,
    output irflt_nsleep,

    inout  [C3_NUM_DQ_PINS-1:0]        mcb3_dram_dq     ,
    output [C3_MEM_ADDR_WIDTH-1:0]     mcb3_dram_a      ,
    output [C3_MEM_BANKADDR_WIDTH-1:0] mcb3_dram_ba     ,
    output                             mcb3_dram_ras_n  ,
    output                             mcb3_dram_cas_n  ,
    output                             mcb3_dram_we_n   ,
    output                             mcb3_dram_odt    ,
    output                             mcb3_dram_reset_n,
    output                             mcb3_dram_cke    ,
    output                             mcb3_dram_dm     ,
    inout                              mcb3_dram_udqs   ,
    inout                              mcb3_dram_udqs_n ,
    inout                              mcb3_rzq         ,
    inout                              mcb3_zio         ,
    output                             mcb3_dram_udm    ,
    inout                              mcb3_dram_dqs    ,
    inout                              mcb3_dram_dqs_n  ,
    output                             mcb3_dram_ck     ,
    output                             mcb3_dram_ck_n   ,


`ifdef SIM_DBG
    output [(PIXEL_WIDTH*3)-1:0] dbg_pv_do,
    output                       dbg_pv_de,
    output                       dbg_pv_hs,
    output                       dbg_pv_vs,
    output                       dbg_pv_cl,

    output [(PIXEL_WIDTH*1)-1:0] dbg_edge_do,
    output                       dbg_edge_de,
    output                       dbg_edge_hs,
    output                       dbg_edge_vs,
    output                       dbg_edge_cl,

    output [(PIXEL_WIDTH*1)-1:0] dbg_binning_do,
    output                       dbg_binning_de,
    output                       dbg_binning_hs,
    output                       dbg_binning_vs,
    output                       dbg_binning_cl,

    output [(PIXEL_WIDTH*1)-1:0] dbg_csi_rx_do,
    output                       dbg_csi_rx_de,
    output                       dbg_csi_rx_hs,
    output                       dbg_csi_rx_vs,
    output                       dbg_csi_rx_cl,

    output [15:0] dbg_fr0_roi_xsize,
    output [15:0] dbg_fr0_roi_ysize,
`endif

    output       dbg_spi_clk,
    input        dbg_spi_mosi,
    output       dbg_spi_miso,
    output       dbg_spi_cs,

    output [4:0] dbg,
    output [1:0] dbg_led,

    input   sysclk_p,
    input   sysclk_n
);


wire cfgmclk;
reg glob_rst = 1'b0;
reg [7:0] glob_rst_cnt = 0;
wire subsys_rst;
wire sysclk;
wire img_sensor_clkg;
wire img_sensor_plllocked;
wire ir_sensor_mclkg;
wire reg_clk;
wire en1us;
wire en1ms;

reg [`FPGA_REG_DWIDTH-1:0] reg_img_sensor = (1 << `FPGA_REG_IMG_SENSOR_nRST_BIT);//default
reg [`FPGA_REG_DWIDTH-1:0] reg_debeyer_ctl = 0;

reg [`FPGA_REG_DWIDTH-1:0] reg_irled_pwm = 0;

wire [`FPGA_REG_AWIDTH-1:0] reg_wr_addr;
wire [`FPGA_REG_DWIDTH-1:0] reg_wr_data;
wire [(`FPGA_REG_DWIDTH * `FPGA_REG_COUNT)-1:0] reg_rd_data;
wire reg_wr_en;

reg [`FPGA_REG_DWIDTH-1:0] reg_irflt_ctrl = 0;


reg [`FPGA_REG_DWIDTH-1:0] reg_fr_xsize = FR_SIZE_X_DEFAULT;
reg [`FPGA_REG_DWIDTH-1:0] reg_fr_ysize = FR_SIZE_Y_DEFAULT;

reg [`FPGA_REG_DWIDTH-1:0] reg_roi_x1 = 0;
reg [`FPGA_REG_DWIDTH-1:0] reg_roi_x2 = FR_SIZE_X_DEFAULT - 1;
reg [`FPGA_REG_DWIDTH-1:0] reg_roi_y1 = 0;
reg [`FPGA_REG_DWIDTH-1:0] reg_roi_y2 = FR_SIZE_Y_DEFAULT - 1;


reg [`FPGA_REG_DWIDTH-1:0] reg_mem_wburst = MEM_WBURST_DEFAULT;
reg [`FPGA_REG_DWIDTH-1:0] reg_mem_rburst = MEM_RBURST_DEFAULT;
reg [`FPGA_REG_DWIDTH-1:0] reg_mem_wrburst = MEM_WRBURST_DEFAULT;

reg [`FPGA_REG_DWIDTH-1:0] reg_ctrl = 0;

reg [`FPGA_REG_DWIDTH-1:0] reg_r_gain = 16'h400;
reg [`FPGA_REG_DWIDTH-1:0] reg_g_gain = 16'h400;
reg [`FPGA_REG_DWIDTH-1:0] reg_b_gain = 16'h400;
reg [(16*3)-1:0] rgb_gain = 48'h040004000400;

reg [`FPGA_REG_DWIDTH-1:0] i2c_ctl = 0;
reg [`FPGA_REG_DWIDTH-1:0] i2c_areg = 0;
reg [7:0] i2c_txd = 0;
wire [7:0] i2c_rxd;
wire i2c_err;
wire i2c_busy;

localparam REG_TEST_ARRAY_COUNT = 16;
reg [`FPGA_REG_DWIDTH-1:0] reg_test_array [0:REG_TEST_ARRAY_COUNT-1];

wire [15:0] csi_tx_xsize;

wire [2:0]  csi_rx_err;
wire [39:0] csi_rx_do;
wire        csi_rx_de;
wire        csi_rx_hs;
wire        csi_rx_vs;
wire        csi_rx_fs;
wire        csi_rx_ce;
(* keep *) wire        csi_rx_cl;

wire [15:0] csi_rx_8b_do;
wire        csi_rx_8b_de;
wire        csi_rx_8b_hs;
wire        csi_rx_8b_vs;
wire        csi_rx_8b_cl;
wire        csi_rx_8b_cl_x2;
wire        csi_rx_pll_locked;
wire        csi_tx_ser_ioclk;
wire        csi_tx_ser_serdesstrobe;
wire        csi_tx_ser_gclk;

wire [(PIXEL_WIDTH*3)-1:0] rgb_do;
wire                       rgb_de;
wire                       rgb_hs;
wire                       rgb_vs;

localparam MEM_WCH_COUNT = 3;
wire [(MEM_WCH_COUNT*32)-1:0] csi_tx_do;
wire [ MEM_WCH_COUNT-1:0]     csi_tx_de;
wire [ MEM_WCH_COUNT-1:0]     csi_tx_hs;
wire [ MEM_WCH_COUNT-1:0]     csi_tx_vs;

wire [31:0] csi_txmem_do;
wire        csi_txmem_de;
wire        csi_txmem_hs;
wire        csi_txmem_vs;
wire        csi_txmem_fifo_empty;
wire        csi_txmem_fifo_full;

wire [31:0] fifo_fr_do;
reg        fifo_fr_rd = 1'b0;
reg        fifo_nrst = 1'b0;
reg        fr_line_rd = 1'b0;
// wire        fifo_fr_rd;
// wire        fifo_nrst;
// wire        fr_line_rd;

reg         usr_mem_cmd_en = 0;
reg [2:0]   usr_mem_cmd_instr = 0;
reg [29:0]  usr_mem_cmd_byte_addr = 0;
reg         usr_mem_wr_en = 0;
reg [31:0]  usr_mem_wr_data = 32'h4000000;//64MB
reg         usr_mem_rd_en = 0;

reg         sr_mcb3_calib_done = 0;
wire        mcb3_calib_done;

reg          ddr_test_start = 1'b0;
wire         ddr_test_busy;
wire         ddr_test_err ;

localparam C3_P0_DATA_SIZE = 64;
wire         c3_p0_cmd_en       ;
wire [2:0]   c3_p0_cmd_instr    ;
wire [5:0]   c3_p0_cmd_bl       ;
wire [29:0]  c3_p0_cmd_byte_addr;
wire         c3_p0_cmd_empty    ;
wire         c3_p0_cmd_full     ;
wire         c3_p0_wr_en        ;
wire [(C3_P0_DATA_SIZE/4)-1:0]  c3_p0_wr_mask;
wire [C3_P0_DATA_SIZE-1:0]  c3_p0_wr_data;
wire         c3_p0_wr_full      ;
wire         c3_p0_wr_empty     ;
wire [6:0]   c3_p0_wr_count     ;
wire         c3_p0_wr_underrun  ;
wire         c3_p0_wr_error     ;
wire         c3_p0_rd_en        ;
wire [C3_P0_DATA_SIZE-1:0]  c3_p0_rd_data;
wire         c3_p0_rd_full      ;
wire         c3_p0_rd_empty     ;
wire [6:0]   c3_p0_rd_count     ;
wire         c3_p0_rd_overflow  ;
wire         c3_p0_rd_error     ;

localparam C3_P1_DATA_SIZE = 32;
wire         c3_p1_cmd_en       ;
wire [2:0]   c3_p1_cmd_instr    ;
wire [5:0]   c3_p1_cmd_bl       ;
wire [29:0]  c3_p1_cmd_byte_addr;
wire         c3_p1_cmd_empty    ;
wire         c3_p1_cmd_full     ;
wire         c3_p1_wr_en        ;
wire [(C3_P1_DATA_SIZE/4)-1:0]  c3_p1_wr_mask;
wire [C3_P1_DATA_SIZE-1:0]  c3_p1_wr_data;
wire         c3_p1_wr_full      ;
wire         c3_p1_wr_empty     ;
wire [6:0]   c3_p1_wr_count     ;
wire         c3_p1_wr_underrun  ;
wire         c3_p1_wr_error     ;
wire         c3_p1_rd_en        ;
wire [C3_P1_DATA_SIZE-1:0]  c3_p1_rd_data;
wire         c3_p1_rd_full      ;
wire         c3_p1_rd_empty     ;
wire [6:0]   c3_p1_rd_count     ;
wire         c3_p1_rd_overflow  ;
wire         c3_p1_rd_error     ;

localparam C3_P2_DATA_SIZE = 32;
wire         c3_p2_cmd_en       ;
wire [2:0]   c3_p2_cmd_instr    ;
wire [5:0]   c3_p2_cmd_bl       ;
wire [29:0]  c3_p2_cmd_byte_addr;
wire         c3_p2_cmd_empty    ;
wire         c3_p2_cmd_full     ;
wire         c3_p2_wr_en        ;
wire [(C3_P2_DATA_SIZE/4)-1:0]  c3_p2_wr_mask;
wire [C3_P2_DATA_SIZE-1:0]  c3_p2_wr_data;
wire         c3_p2_wr_full      ;
wire         c3_p2_wr_empty     ;
wire [6:0]   c3_p2_wr_count     ;
wire         c3_p2_wr_underrun  ;
wire         c3_p2_wr_error     ;
wire         c3_p2_rd_en        ;
wire [C3_P2_DATA_SIZE-1:0]  c3_p2_rd_data;
wire         c3_p2_rd_full      ;
wire         c3_p2_rd_empty     ;
wire [6:0]   c3_p2_rd_count     ;
wire         c3_p2_rd_overflow  ;
wire         c3_p2_rd_error     ;

localparam C3_P3_DATA_SIZE = 32;
wire         c3_p3_cmd_en       ;
wire [2:0]   c3_p3_cmd_instr    ;
wire [5:0]   c3_p3_cmd_bl       ;
wire [29:0]  c3_p3_cmd_byte_addr;
wire         c3_p3_cmd_empty    ;
wire         c3_p3_cmd_full     ;
wire         c3_p3_wr_en        ;
wire [(C3_P3_DATA_SIZE/4)-1:0]  c3_p3_wr_mask;
wire [C3_P3_DATA_SIZE-1:0]  c3_p3_wr_data;
wire         c3_p3_wr_full      ;
wire         c3_p3_wr_empty     ;
wire [6:0]   c3_p3_wr_count     ;
wire         c3_p3_wr_underrun  ;
wire         c3_p3_wr_error     ;
wire         c3_p3_rd_en        ;
wire [C3_P3_DATA_SIZE-1:0]  c3_p3_rd_data;
wire         c3_p3_rd_full      ;
wire         c3_p3_rd_empty     ;
wire [6:0]   c3_p3_rd_count     ;
wire         c3_p3_rd_overflow  ;
wire         c3_p3_rd_error     ;

localparam C3_P4_DATA_SIZE = 32;
wire         c3_p4_cmd_en       ;
wire [2:0]   c3_p4_cmd_instr    ;
wire [5:0]   c3_p4_cmd_bl       ;
wire [29:0]  c3_p4_cmd_byte_addr;
wire         c3_p4_cmd_empty    ;
wire         c3_p4_cmd_full     ;
wire         c3_p4_wr_en        ;
wire [(C3_P4_DATA_SIZE/4)-1:0]  c3_p4_wr_mask;
wire [C3_P4_DATA_SIZE-1:0]  c3_p4_wr_data;
wire         c3_p4_wr_full      ;
wire         c3_p4_wr_empty     ;
wire [6:0]   c3_p4_wr_count     ;
wire         c3_p4_wr_underrun  ;
wire         c3_p4_wr_error     ;
wire         c3_p4_rd_en        ;
wire [C3_P4_DATA_SIZE-1:0]  c3_p4_rd_data;
wire         c3_p4_rd_full      ;
wire         c3_p4_rd_empty     ;
wire [6:0]   c3_p4_rd_count     ;
wire         c3_p4_rd_overflow  ;
wire         c3_p4_rd_error     ;

localparam C3_P5_DATA_SIZE = 32;
wire         c3_p5_cmd_en       ;
wire [2:0]   c3_p5_cmd_instr    ;
wire [5:0]   c3_p5_cmd_bl       ;
wire [29:0]  c3_p5_cmd_byte_addr;
wire         c3_p5_cmd_empty    ;
wire         c3_p5_cmd_full     ;
wire         c3_p5_wr_en        ;
wire [(C3_P5_DATA_SIZE/4)-1:0]  c3_p5_wr_mask;
wire [C3_P5_DATA_SIZE-1:0]  c3_p5_wr_data;
wire         c3_p5_wr_full      ;
wire         c3_p5_wr_empty     ;
wire [6:0]   c3_p5_wr_count     ;
wire         c3_p5_wr_underrun  ;
wire         c3_p5_wr_error     ;
wire         c3_p5_rd_en        ;
wire [C3_P5_DATA_SIZE-1:0]  c3_p5_rd_data;
wire         c3_p5_rd_full      ;
wire         c3_p5_rd_empty     ;
wire [6:0]   c3_p5_rd_count     ;
wire         c3_p5_rd_overflow  ;
wire         c3_p5_rd_error     ;


wire frbuf_num;

wire [3:0] csi_tx_dbg_o;

reg [31:0] r_acc = 0;
reg [31:0] g_acc = 0;
reg [31:0] b_acc = 0;
reg [31:0] r_acc_o = 0;
reg [31:0] g_acc_o = 0;
reg [31:0] b_acc_o = 0;
reg [0:1] sr_rgb_vs = 0;
reg rgb_vs_edge = 1'b0;
reg [15:0] reg_rgb_acc_ctrl = 0;
reg [15:0] sr0_reg_rgb_acc_ctrl = 0;
reg [15:0] sr1_reg_rgb_acc_ctrl = 0;
reg [15:0] sr2_reg_rgb_acc_ctrl = 0;

wire [1:0] dbg_irspi;

wire pv_hs_;
wire pv_vs_;

reg [31:0] sv_csi_rx_do = 0;
reg [63:0] sr_csi_rx_do = 0;
reg sr_csi_rx_de = 1'b0;
reg sr_csi_rx_hs = 1'b0;
reg sr_csi_rx_vs = 1'b0;
reg csi_rx_de_cnt = 1'b0;



reg uart_en_16_x_baud = 1'b0;
reg [7:0] uart_baud_cnt = 0;
wire uart_tx;
wire uart_rx;
wire uart_rxdrdy;
wire uart_txfull;
wire [7:0] uart_rxdata;
reg [7:0] uart_txdata = 0;
reg uart_write = 1'b0;
reg uart_read = 1'b0;
reg uart_write_fifo = 1'b0;


STARTUP_SPARTAN6 startup_spartan6(
   .CFGCLK(),         // 1-bit output: Configuration logic main clock output.
   .CFGMCLK(cfgmclk), // 1-bit output: Configuration internal oscillator clock output.
   .EOS(),            // 1-bit output: Active high output signal indicates the End Of Configuration.
   .CLK(1'b0),        // 1-bit input: User startup-clock input
   .GSR(1'b0),        // 1-bit input: Global Set/Reset input (GSR cannot be used for the port name)
   .GTS(1'b0),        // 1-bit input: Global 3-state input (GTS cannot be used for the port name)
   .KEYCLEARB(1'b0)   // 1-bit input: Clear AES Decrypter Key input from Battery-Backed RAM (BBRAM)
);

always @(posedge cfgmclk) begin
    if (&glob_rst_cnt) glob_rst = 1;
    else               glob_rst_cnt <= glob_rst_cnt + 1'b1;
end


time_gen #(
    .G_T05us(50)
) time_gen (
    .p_out_en05us (),
    .p_out_en1us  (en1us),
    .p_out_en1ms  (en1ms),
    .p_out_en1sec (),
    .p_out_en1min (),

    .p_in_clken   (1'b1),
    .p_in_clk     (reg_clk),
    .p_in_rst     (1'b0)
);

wire dcm_sysclk_locked;
dcm_sysclk dcm_sysclk (
    .CLK_IN1(sysclk),
    .CLK_OUT1(reg_clk),
    .RESET(1'b0),
    .LOCKED(dcm_sysclk_locked)
);
reg [7:0] sr_dcm_sysclk_locked = 0;
always @(posedge reg_clk) begin
    sr_dcm_sysclk_locked <= {sr_dcm_sysclk_locked[6:0], dcm_sysclk_locked};
end

dcm_imgsens dcm_imgsens (
    .CLK_IN1(sysclk),
    .CLK_OUT1(img_sensor_clkg),
    .RESET(1'b0),
    .LOCKED(img_sensor_plllocked)
);

ODDR2 #(
    .DDR_ALIGNMENT("NONE"),
    .INIT(1'b0),
    .SRTYPE("SYNC")
) img_sensor_clk_bufo (
    .Q(img_sensor_clk),
    .C0(img_sensor_clkg),
    .C1(~img_sensor_clkg),
    .CE(1'b1),
    .D0(1'b1),
    .D1(1'b0),
    .R(1'b0),
    .S(1'b0)
);


localparam IMG_SENSOR_POWER_SEQ_STEP = 32;
reg [31:0] img_sensor_pwrseq_cnt = 0;
reg img_sensor_pwron = 1'b0;
always @ (posedge img_sensor_clkg) begin
    if (img_sensor_plllocked) begin
        if (!img_sensor_pwrseq_cnt[31]) begin
            img_sensor_pwrseq_cnt <= img_sensor_pwrseq_cnt + 1;
        end

        if (img_sensor_pwrseq_cnt == (IMG_SENSOR_POWER_SEQ_STEP*1)) img_sensor_2V8_on <= 1'b1;
        if (img_sensor_pwrseq_cnt == (IMG_SENSOR_POWER_SEQ_STEP*2)) img_sensor_1V8_on <= 1'b1;
        if (img_sensor_pwrseq_cnt == (IMG_SENSOR_POWER_SEQ_STEP*3)) img_sensor_1V2_on <= 1'b1;
        if (img_sensor_pwrseq_cnt == (IMG_SENSOR_POWER_SEQ_STEP*4)) img_sensor_pwron <= 1'b1;
    end
end
assign img_sensor_rst = reg_img_sensor[`FPGA_REG_IMG_SENSOR_nRST_BIT] & cpu_img_sensor_rst & img_sensor_pwron;// & mcb3_calib_done;

assign ir_sensor_spi_clk = cpu_ir_sensor_spi_clk;
assign ir_sensor_spi_cs = cpu_ir_sensor_spi_cs;
assign cpu_ir_sensor_spi_miso = ir_sensor_spi_miso;
assign ir_sensor_mclk_25m = cpu_ir_sensor_mclk_en;
assign ir_sensor_en = cpu_ir_sensor_en;
assign ir_sensor_nrst = cpu_ir_sensor_nrst;


//IRLED
wire irled_pwm_tmp;
assign irled_on = |reg_irled_pwm[`FPGA_REG_IR_LED_PWM_MSB_BIT:`FPGA_REG_IR_LED_PWM_LSB_BIT];
assign irled_pwm = ~irled_pwm_tmp;
delta_sigma #(
   .FULL_RANGE(1)
) ir_led (
    .din  (reg_irled_pwm[`FPGA_REG_IR_LED_PWM_MSB_BIT:`FPGA_REG_IR_LED_PWM_LSB_BIT]),
    .dout (irled_pwm_tmp),
    .clken(en1us),
    .clk  (reg_clk)
);


//IRFILTER
assign irflt_in1 = reg_irflt_ctrl[`FPGA_REG_IR_FILTER_CTRL_IN1_BIT];
assign irflt_in2 = reg_irflt_ctrl[`FPGA_REG_IR_FILTER_CTRL_IN2_BIT];
assign irflt_en  = reg_irflt_ctrl[`FPGA_REG_IR_FILTER_CTRL_EN_BIT];
assign irflt_nsleep = reg_irflt_ctrl[`FPGA_REG_IR_FILTER_CTRL_EN_BIT];


csi_rx_main # (
    .fpga_series("SPARTAN6"),
    .LANE_COUNT (DLANE_COUNT),
    .PIXEL_WIDTH(SENSOR_PIXEL_WIDTH)
) csi_rx (
    .enable (1'b1),
    .refclk (1'b0),
    .reset  (1'b0),

    .dphy_hs_dp (csi_rx_hs_dp[DLANE_COUNT-1:0]),
    .dphy_hs_dn (csi_rx_hs_dn[DLANE_COUNT-1:0]),
    .dphy_hs_cp (csi_rx_hs_cp),
    .dphy_hs_cn (csi_rx_hs_cn),
    .dphy_lp_dp (csi_rx_lp_dp[DLANE_COUNT-1:0]),
    .dphy_lp_dn (csi_rx_lp_dn[DLANE_COUNT-1:0]),
    .dphy_lp_cp (csi_rx_lp_cp),
    .dphy_lp_cn (csi_rx_lp_cn),

    .aux_data   (),

    .pkt_do     (),
    .pkt_do_en  (),
    .err        (csi_rx_err),

    .csi_do_o   (csi_rx_do),
    .csi_de_o   (csi_rx_de),
    .csi_hs_o   (csi_rx_hs),
    .csi_vs_o   (csi_rx_vs),
    .csi_clken_o(csi_rx_ce),
    .csi_clk_o  (csi_rx_cl)
);
reg [31:0] dbg_csi_rx_cntx = 0;
always @ (posedge csi_rx_cl) begin
    if (!csi_rx_hs) begin
        dbg_csi_rx_cntx <= 0;
    end else if (csi_rx_de) begin
        dbg_csi_rx_cntx <= dbg_csi_rx_cntx + 1;
    end
end


assign subsys_rst = ~csi_rx_pll_locked;
csi_rx_d32_d8 #(
    .LANE_COUNT (DLANE_COUNT),
    .IN_PIXEL_WIDTH(SENSOR_PIXEL_WIDTH),
    .OUT_PIXEL_WIDTH(PIXEL_WIDTH)
) csi_rx_d32_d8 (
    .di_i   (csi_rx_do),
    .de_i   (csi_rx_de),
    .hs_i   (csi_rx_hs),
    .vs_i   (csi_rx_vs),
    .fs_i   (csi_rx_fs),
    .clken_i(csi_rx_ce),
    .clk_i  (csi_rx_cl),

    .do_o  (),
    .de_o  (),
    .hs_o  (),
    .vs_o  (),
    .clk_o (csi_rx_8b_cl),
    .clkx2_o(csi_rx_8b_cl_x2),
    .lock_o(csi_rx_pll_locked),

    .csi_tx_ser_serdesstrobe(csi_tx_ser_serdesstrobe),
    .csi_tx_ser_ioclk(csi_tx_ser_ioclk),
    .csi_tx_ser_gclk(csi_tx_ser_gclk),

    .sel_8b(0),

    .rst(1'b0)
);


//-------------------------------------------
//CSI_TX Channel
//-------------------------------------------
assign pv_do = 0;
assign pv_de = 1'b0;
assign pv_hs = 1'b0;
assign pv_vs = 1'b0;
assign pv_cl = 1'b0;

// csi_tx_main csi_tx (
//     .hs_opt_clk  (csi_tx_ser_serdesstrobe),
//     .hs_bit_clk  (csi_tx_ser_ioclk),
//     .hs_word_clk (csi_tx_ser_gclk),
//     .reset       (subsys_rst),

//     .data_clk (csi_tx_ser_gclk),
//     .data_size(csi_tx_xsize)   ,
//     .data     (csi_txmem_do)   ,
//     .data_wr  (csi_txmem_de)   ,
//     .fifo_empty(csi_txmem_fifo_empty),
//     .fifo_full(csi_txmem_fifo_full),
//     .hsyn     (csi_txmem_hs)   ,
//     .vsyn     (csi_txmem_vs)   ,

//     .dbg_o (csi_tx_dbg_o),

//     .dphy_hs_dp (csi_tx_hs_dp),
//     .dphy_hs_dn (csi_tx_hs_dn),
//     .dphy_hs_cp (csi_tx_hs_cp),
//     .dphy_hs_cn (csi_tx_hs_cn),
//     .dphy_lp_dp (csi_tx_lp_dp),
//     .dphy_lp_dn (csi_tx_lp_dn),
//     .dphy_lp_cp (csi_tx_lp_cp),
//     .dphy_lp_cn (csi_tx_lp_cn)
// );


//-------------------------------------------
//User Control
//-------------------------------------------
//Read User resisters
assign reg_rd_data[`FPGA_RD_FIRMWARE_REV * `FPGA_REG_DWIDTH +: (`FPGA_REG_DWIDTH*2)] = {8'd0, FIRMWARE};

assign reg_rd_data[`FPGA_RD_REG_IMG_SENSOR * `FPGA_REG_DWIDTH +: `FPGA_REG_DWIDTH] = reg_img_sensor;
assign reg_rd_data[`FPGA_RD_REG_DEBAYER_CTL * `FPGA_REG_DWIDTH +: `FPGA_REG_DWIDTH] = reg_debeyer_ctl;

genvar a;
generate
    for (a = 0; a < REG_TEST_ARRAY_COUNT; a = a + 1) begin
        assign reg_rd_data[(`FPGA_RD_REG_TEST_ARRAY + a) * `FPGA_REG_DWIDTH +: `FPGA_REG_DWIDTH] = reg_test_array[a];
    end
endgenerate

assign reg_rd_data[`FPGA_RD_REG_MEM_WBURST * `FPGA_REG_DWIDTH +: `FPGA_REG_DWIDTH] = reg_mem_wburst;
assign reg_rd_data[`FPGA_RD_REG_MEM_RBURST * `FPGA_REG_DWIDTH +: `FPGA_REG_DWIDTH] = reg_mem_rburst;
assign reg_rd_data[`FPGA_RD_REG_MEM_WRBURST * `FPGA_REG_DWIDTH +: `FPGA_REG_DWIDTH] = reg_mem_wrburst;
assign reg_rd_data[`FPGA_RD_REG_MEMTEST_RDATA * `FPGA_REG_DWIDTH +: (`FPGA_REG_DWIDTH*2)] = c3_p2_rd_data;
assign reg_rd_data[`FPGA_RD_REG_MEMTEST_STATUS * `FPGA_REG_DWIDTH +: `FPGA_REG_DWIDTH] = { {19{1'b0}}
                                                                             , ddr_test_err
                                                                             , ddr_test_busy
                                                                             , c3_p2_rd_error
                                                                             , c3_p2_rd_overflow
                                                                             , c3_p2_wr_error
                                                                             , c3_p2_wr_underrun
                                                                             , c3_p2_rd_full
                                                                             , c3_p2_wr_full
                                                                             , c3_p2_cmd_full
                                                                             , c3_p2_rd_empty
                                                                             , c3_p2_wr_empty
                                                                             , c3_p2_cmd_empty
                                                                             , sr_mcb3_calib_done};

assign reg_rd_data[`FPGA_RD_REG_IR_LED_PWM  * `FPGA_REG_DWIDTH +: `FPGA_REG_DWIDTH] = {7'd0, reg_irled_pwm};
assign reg_rd_data[`FPGA_RD_REG_IR_FILTER_CTRL * `FPGA_REG_DWIDTH +: `FPGA_REG_DWIDTH] = reg_irflt_ctrl;

assign reg_rd_data[`FPGA_RD_REG_FR_XSIZE * `FPGA_REG_DWIDTH +: `FPGA_REG_DWIDTH] = reg_fr_xsize;
assign reg_rd_data[`FPGA_RD_REG_FR_YSIZE * `FPGA_REG_DWIDTH +: `FPGA_REG_DWIDTH] = reg_fr_ysize;
assign reg_rd_data[`FPGA_RD_REG_ROI_X1 * `FPGA_REG_DWIDTH +: `FPGA_REG_DWIDTH] = reg_roi_x1;
assign reg_rd_data[`FPGA_RD_REG_ROI_X2 * `FPGA_REG_DWIDTH +: `FPGA_REG_DWIDTH] = reg_roi_x2;
assign reg_rd_data[`FPGA_RD_REG_ROI_Y1 * `FPGA_REG_DWIDTH +: `FPGA_REG_DWIDTH] = reg_roi_y1;
assign reg_rd_data[`FPGA_RD_REG_ROI_Y2 * `FPGA_REG_DWIDTH +: `FPGA_REG_DWIDTH] = reg_roi_y2;

assign reg_rd_data[`FPGA_RD_REG_RGB_ACC_CTRL * `FPGA_REG_DWIDTH +: `FPGA_REG_DWIDTH] = sr2_reg_rgb_acc_ctrl;
assign reg_rd_data[`FPGA_RD_REG_R_ACC * `FPGA_REG_DWIDTH +: (`FPGA_REG_DWIDTH*2)] = r_acc_o;
assign reg_rd_data[`FPGA_RD_REG_G_ACC * `FPGA_REG_DWIDTH +: (`FPGA_REG_DWIDTH*2)] = g_acc_o;
assign reg_rd_data[`FPGA_RD_REG_B_ACC * `FPGA_REG_DWIDTH +: (`FPGA_REG_DWIDTH*2)] = b_acc_o;

assign reg_rd_data[`FPGA_RD_REG_CTRL * `FPGA_REG_DWIDTH +: `FPGA_REG_DWIDTH] = reg_ctrl;

assign reg_rd_data[`FPGA_RD_REG_R_GAIN * `FPGA_REG_DWIDTH +: `FPGA_REG_DWIDTH] = reg_r_gain;
assign reg_rd_data[`FPGA_RD_REG_G_GAIN * `FPGA_REG_DWIDTH +: `FPGA_REG_DWIDTH] = reg_g_gain;
assign reg_rd_data[`FPGA_RD_REG_B_GAIN * `FPGA_REG_DWIDTH +: `FPGA_REG_DWIDTH] = reg_b_gain;

assign reg_rd_data[`FPGA_RD_REG_I2C_CTL * `FPGA_REG_DWIDTH +: `FPGA_REG_DWIDTH] = i2c_ctl;
assign reg_rd_data[`FPGA_RD_REG_I2C_STATUS * `FPGA_REG_DWIDTH +: `FPGA_REG_DWIDTH] = {8'd0, 6'd0, i2c_err, i2c_busy};
assign reg_rd_data[`FPGA_RD_REG_I2C_AREG * `FPGA_REG_DWIDTH +: `FPGA_REG_DWIDTH] = i2c_areg;
assign reg_rd_data[`FPGA_RD_REG_I2C_DREG * `FPGA_REG_DWIDTH +: `FPGA_REG_DWIDTH] = {8'd0, i2c_rxd};

integer i;
//Write User resisters
always @ (posedge reg_clk) begin
    if (reg_wr_en && (reg_wr_addr == `FPGA_REG_IMG_SENSOR)) reg_img_sensor <= reg_wr_data;
    if (reg_wr_en && (reg_wr_addr == `FPGA_REG_DEBAYER_CTL)) reg_debeyer_ctl <= reg_wr_data;

    for (i = 0; i < REG_TEST_ARRAY_COUNT; i = i + 1) begin
        if (reg_wr_en && (reg_wr_addr == (`FPGA_REG_TEST_ARRAY + i))) reg_test_array[i] <= reg_wr_data;
    end

    if (reg_wr_en && (reg_wr_addr == `FPGA_REG_IR_LED_PWM)) reg_irled_pwm <= reg_wr_data;

    if (reg_wr_en && (reg_wr_addr == `FPGA_REG_IR_FILTER_CTRL)) reg_irflt_ctrl[15:0] <= reg_wr_data;

    if (reg_wr_en && (reg_wr_addr == `FPGA_REG_MEM_WBURST)) reg_mem_wburst <= reg_wr_data;
    if (reg_wr_en && (reg_wr_addr == `FPGA_REG_MEM_RBURST)) reg_mem_rburst <= reg_wr_data;
    if (reg_wr_en && (reg_wr_addr == `FPGA_REG_MEM_WRBURST)) reg_mem_wrburst <= reg_wr_data;
    usr_mem_cmd_en <= 1'b0;
    usr_mem_rd_en  <= 1'b0;
    if (reg_wr_en && (reg_wr_addr == (`FPGA_REG_MEMTEST_CTRL + 0))) begin
        usr_mem_cmd_byte_addr[15:0] <= reg_wr_data[15:0];
    end
    if (reg_wr_en && (reg_wr_addr == (`FPGA_REG_MEMTEST_CTRL + 1))) begin
        usr_mem_cmd_byte_addr[29:16]<= reg_wr_data[(`FPGA_REG_MEMTEST_CTRL_ADR_MSB_BIT - 16):0];

        usr_mem_cmd_instr[0] <= reg_wr_data[`FPGA_REG_MEMTEST_CTRL_DIR_BIT - 16];//1'b0 - MEM Write; 1'b1 - MEM Read
        usr_mem_cmd_instr[1] <= 1'b0;
        usr_mem_cmd_instr[2] <= 1'b0;

        usr_mem_cmd_en <= (~reg_wr_data[`FPGA_REG_MEMTEST_CTRL_RD_STROB_BIT - 16]);
        usr_mem_rd_en  <= ( reg_wr_data[`FPGA_REG_MEMTEST_CTRL_RD_STROB_BIT - 16]);
        ddr_test_start <= reg_wr_data[`FPGA_REG_MEMTEST_CTRL_TEST_BIT - 16];
    end

    usr_mem_wr_en <= 1'b0;
    if (reg_wr_en && (reg_wr_addr == (`FPGA_REG_MEMTEST_WDATA + 0))) begin
        usr_mem_wr_data[15:0] <= reg_wr_data;
    end
    if (reg_wr_en && (reg_wr_addr == (`FPGA_REG_MEMTEST_WDATA + 1))) begin
        usr_mem_wr_data[31:16] <= reg_wr_data;
        usr_mem_wr_en <= 1'b1;
    end

    if (reg_wr_en && (reg_wr_addr == `FPGA_REG_FR_XSIZE)) reg_fr_xsize <= reg_wr_data;
    if (reg_wr_en && (reg_wr_addr == `FPGA_REG_FR_YSIZE)) reg_fr_ysize <= reg_wr_data;
    if (reg_wr_en && (reg_wr_addr == `FPGA_REG_ROI_X1)) reg_roi_x1 <= reg_wr_data;
    if (reg_wr_en && (reg_wr_addr == `FPGA_REG_ROI_X2)) reg_roi_x2 <= reg_wr_data;
    if (reg_wr_en && (reg_wr_addr == `FPGA_REG_ROI_Y1)) reg_roi_y1 <= reg_wr_data;
    if (reg_wr_en && (reg_wr_addr == `FPGA_REG_ROI_Y2)) reg_roi_y2 <= reg_wr_data;

    if (reg_wr_en && (reg_wr_addr == `FPGA_REG_RGB_ACC_CTRL)) reg_rgb_acc_ctrl <= reg_wr_data;

    if (reg_wr_en && (reg_wr_addr == `FPGA_REG_CTRL)) reg_ctrl <= reg_wr_data;

    if (reg_wr_en && (reg_wr_addr == `FPGA_REG_R_GAIN)) reg_r_gain <= reg_wr_data;
    if (reg_wr_en && (reg_wr_addr == `FPGA_REG_G_GAIN)) reg_g_gain <= reg_wr_data;
    if (reg_wr_en && (reg_wr_addr == `FPGA_REG_B_GAIN)) begin
        reg_b_gain <= reg_wr_data;
        rgb_gain[16*0 +: 16] <= reg_r_gain;
        rgb_gain[16*1 +: 16] <= reg_g_gain;
        rgb_gain[16*2 +: 16] <= reg_wr_data;
    end

    i2c_ctl[`FPGA_REG_I2C_CTL_START] <= 1'b0;
    if (reg_wr_en && (reg_wr_addr == `FPGA_REG_I2C_CTL)) begin
        i2c_ctl[`FPGA_REG_I2C_CTL_ADEV_MSB:`FPGA_REG_I2C_CTL_ADEV_LSB] <= reg_wr_data[`FPGA_REG_I2C_CTL_ADEV_MSB:`FPGA_REG_I2C_CTL_ADEV_LSB];
        i2c_ctl[`FPGA_REG_I2C_CTL_DIR] <= reg_wr_data[`FPGA_REG_I2C_CTL_DIR];
        if (reg_wr_data[`FPGA_REG_I2C_CTL_START]) begin
            i2c_ctl[`FPGA_REG_I2C_CTL_START] <= 1'b1;
        end
    end
    // if (reg_wr_en && (reg_wr_addr == `FPGA_REG_I2C_CTL)) i2c_ctl <= reg_wr_data;
    if (reg_wr_en && (reg_wr_addr == `FPGA_REG_I2C_AREG)) i2c_areg <= reg_wr_data;
    if (reg_wr_en && (reg_wr_addr == `FPGA_REG_I2C_DREG)) i2c_txd <= reg_wr_data[7:0];
end

// spi_slave #(
//     .RD_OFFSET(`FPGA_RD_OFFSET),
//     .REG_RD_DATA_WIDTH(`FPGA_REG_COUNT * `FPGA_REG_DWIDTH)
// ) spi (
//     //SPI port
//     .spi_cs_i  (spi_ss),
//     .spi_clk_i (spi_sclk),
//     .spi_mosi_i(spi_mosi),
//     .spi_miso_o(spi_miso),

//     //User IF
//     .reg_rd_data(reg_rd_data),
//     .reg_wr_addr(reg_wr_addr),
//     .reg_wr_data(reg_wr_data),
//     .reg_wr_en  (reg_wr_en),
//     .reg_clk    (reg_clk),
//     .rst (~sr_dcm_sysclk_locked[7])
// );

wire [35 : 0] icon_control0;
wire [35 : 0] icon_control1;
icon_dbg icon(
    .CONTROL1(icon_control1),
    .CONTROL0(icon_control0)
);

jtag_reg_wr #(
    .RD_OFFSET(`FPGA_RD_OFFSET),
    .REG_RD_DATA_WIDTH(`FPGA_REG_COUNT * `FPGA_REG_DWIDTH)
) jtag_reg_ctrl (
    //L
    .icon_control(icon_control0),

    .fifo_data(fifo_fr_do),
    .fifo_rd(),//(fifo_fr_rd),//
    .fifo_nrst(),//(fifo_nrst),//
    .fifo_empty(csi_txmem_fifo_empty),
    .fr_line_rd(),//(fr_line_rd),//


    //User IF
    .reg_rd_data(reg_rd_data),
    .reg_wr_addr(reg_wr_addr),
    .reg_wr_data(reg_wr_data),
    .reg_wr_en  (reg_wr_en),
    .reg_clk    (reg_clk),
    .rst (~sr_dcm_sysclk_locked[7])
);

i2c_ov4689 #(
    .G_CLK_FREQ(200000000),
    .G_BAUD(50000)
) i2c_ov4689 (
    //I2C
    .sda_io(i2c_sda),
    .scl_io(i2c_scl),

    //CTRL
    .dev_adr_i(i2c_ctl[6:0]), //input [6:0]
    .reg_adr_i(i2c_areg), //input [15:0]
    .reg_txd_i(i2c_txd), //input [7:0]
    .reg_rxd_o(i2c_rxd), //output [7:0]
    .start_i(i2c_ctl[`FPGA_REG_I2C_CTL_START]),
    .dir_i(i2c_ctl[`FPGA_REG_I2C_CTL_DIR]), //Write = 0 /Read = 1
    .err_o(i2c_err),
    .busy_o(i2c_busy),

    //System
    .clk(reg_clk),
    .rst(~sr_dcm_sysclk_locked[7])
);

reg sr_i2c_busy = 1'b0;
reg i2c_busy_edge = 1'b0;
always @ (posedge reg_clk) begin
    sr_i2c_busy <= i2c_busy;
    i2c_busy_edge <= !i2c_busy & sr_i2c_busy;
end


reg tttt = 1'b0;
ila_0 ila (
    .CLK(reg_clk),
    // .TRIG0({
    //         i2c_ctl[`FPGA_REG_I2C_CTL_START],
    //         i2c_ctl[`FPGA_REG_I2C_CTL_DIR],
    //         i2c_busy_edge,
    //         i2c_busy,
    //         i2c_rxd,
    //         i2c_txd,
    //         i2c_areg[15:0],
    //         i2c_ctl[6:0]
    // }),

    .TRIG0({
        uart_write,
        tttt,
        fifo_fr_rd,
        csi_txmem_de,
        sr_csi_rx_vs,
        sr_csi_rx_hs,
        sr_csi_rx_de,
        uart_txdata,
        csi_txmem_do,
        sr_csi_rx_do
    }),

    // //uart.cpj
    // .TRIG0({
    //     tttt,
    //     csi_txmem_fifo_empty,
    //     csi_txmem_de,
    //     fr_line_rd,
    //     fifo_nrst,
    //     uart_txfull,
    //     uart_write,
    //     uart_txdata,
    //     uart_read,
    //     uart_rxdrdy,
    //     uart_rxdata
    // }),

    .CONTROL(icon_control1)
);

//-------------------------------------------
//
//-------------------------------------------
always @ (posedge sysclk) begin
    sr_mcb3_calib_done <= mcb3_calib_done;
end
memctrl #(
`ifdef SIM_DBG
    .C3_SIMULATION("TRUE"),
//    .C3_MEMCLK_PERIOD      (C3_MEMCLK_PERIOD     ),
`endif
    .C3_NUM_DQ_PINS        (C3_NUM_DQ_PINS       ),
    .C3_MEM_ADDR_WIDTH     (C3_MEM_ADDR_WIDTH    ),
    .C3_MEM_BANKADDR_WIDTH (C3_MEM_BANKADDR_WIDTH)
) memctl (

    .mcb3_dram_dq     (mcb3_dram_dq     ),
    .mcb3_dram_a      (mcb3_dram_a      ),
    .mcb3_dram_ba     (mcb3_dram_ba     ),
    .mcb3_dram_ras_n  (mcb3_dram_ras_n  ),
    .mcb3_dram_cas_n  (mcb3_dram_cas_n  ),
    .mcb3_dram_we_n   (mcb3_dram_we_n   ),
    .mcb3_dram_odt    (mcb3_dram_odt    ),
    .mcb3_dram_reset_n(mcb3_dram_reset_n),
    .mcb3_dram_cke    (mcb3_dram_cke    ),
    .mcb3_dram_dm     (mcb3_dram_dm     ),
    .mcb3_dram_udqs   (mcb3_dram_udqs   ),
    .mcb3_dram_udqs_n (mcb3_dram_udqs_n ),
    .mcb3_rzq         (mcb3_rzq         ),
    .mcb3_zio         (mcb3_zio         ),
    .mcb3_dram_udm    (mcb3_dram_udm    ),
    .mcb3_dram_dqs    (mcb3_dram_dqs    ),
    .mcb3_dram_dqs_n  (mcb3_dram_dqs_n  ),
    .mcb3_dram_ck     (mcb3_dram_ck     ),
    .mcb3_dram_ck_n   (mcb3_dram_ck_n   ),

    .c3_sys_clk_p     (sysclk_p),
    .c3_sys_clk_n     (sysclk_n),
    .c3_sys_rst_i     (~glob_rst),
    .c3_calib_done    (mcb3_calib_done ),
    .c3_clk0          (sysclk          ),
    .c3_rst0          (c3_rst0         ),

    .c3_p0_cmd_clk      (csi_rx_cl),//input
    .c3_p0_wr_clk       (csi_rx_cl),//input
    .c3_p0_rd_clk       (csi_rx_cl),//input
    .c3_p0_cmd_en       (c3_p0_cmd_en       ),//input
    .c3_p0_cmd_instr    (c3_p0_cmd_instr    ),//input [2:0]
    .c3_p0_cmd_bl       (c3_p0_cmd_bl       ),//input [5:0]
    .c3_p0_cmd_byte_addr(c3_p0_cmd_byte_addr),//input [29:0]
    .c3_p0_cmd_empty    (c3_p0_cmd_empty    ),//output
    .c3_p0_cmd_full     (c3_p0_cmd_full     ),//output
    .c3_p0_wr_en        (c3_p0_wr_en        ),//input
    .c3_p0_wr_mask      (c3_p0_wr_mask      ),//input [(C3_P0_DATA_SIZE/4)-1:0]
    .c3_p0_wr_data      (c3_p0_wr_data      ),//input [C3_P0_DATA_SIZE-1:0]
    .c3_p0_wr_full      (c3_p0_wr_full      ),//output
    .c3_p0_wr_empty     (c3_p0_wr_empty     ),//output
    .c3_p0_wr_count     (c3_p0_wr_count     ),//output [6:0]
    .c3_p0_wr_underrun  (c3_p0_wr_underrun  ),//output
    .c3_p0_wr_error     (c3_p0_wr_error     ),//output
    .c3_p0_rd_en        (1'b0               ),//c3_p0_rd_en          input
    .c3_p0_rd_data      (                   ),//c3_p0_rd_data        output [C3_P0_DATA_SIZE-1:0]
    .c3_p0_rd_full      (                   ),//c3_p0_rd_full        output
    .c3_p0_rd_empty     (                   ),//c3_p0_rd_empty       output
    .c3_p0_rd_count     (                   ),//c3_p0_rd_count       output [6:0]
    .c3_p0_rd_overflow  (                   ),//c3_p0_rd_overflow    output
    .c3_p0_rd_error     (                   ),//c3_p0_rd_error       output

    .c3_p1_cmd_clk      (reg_clk),//input
    .c3_p1_wr_clk       (reg_clk),//input
    .c3_p1_rd_clk       (reg_clk),//input
    .c3_p1_cmd_en       (c3_p1_cmd_en       ),//(1'b0),////input
    .c3_p1_cmd_instr    (c3_p1_cmd_instr    ),//(0   ),////input [2:0]
    .c3_p1_cmd_bl       (c3_p1_cmd_bl       ),//(0   ),////input [5:0]
    .c3_p1_cmd_byte_addr(c3_p1_cmd_byte_addr),//(0   ),////input [29:0]
    .c3_p1_cmd_empty    (c3_p1_cmd_empty    ),//(    ),////output
    .c3_p1_cmd_full     (c3_p1_cmd_full     ),//(    ),////output
    .c3_p1_wr_en        (1'b0               ),//c3_p1_wr_en          input
    .c3_p1_wr_mask      (0                  ),//c3_p1_wr_mask        input [(C3_P1_DATA_SIZE/4)-1:0]
    .c3_p1_wr_data      (0                  ),//c3_p1_wr_data        input [C3_P1_DATA_SIZE-1:0]
    .c3_p1_wr_full      (                   ),//c3_p1_wr_full        output
    .c3_p1_wr_empty     (                   ),//c3_p1_wr_empty       output
    .c3_p1_wr_count     (                   ),//c3_p1_wr_count       output [6:0]
    .c3_p1_wr_underrun  (                   ),//c3_p1_wr_underrun    output
    .c3_p1_wr_error     (                   ),//c3_p1_wr_error       output
    .c3_p1_rd_en        (c3_p1_rd_en        ),//(1'b0),////c3_p1_rd_en          input
    .c3_p1_rd_data      (c3_p1_rd_data      ),//c3_p1_rd_data        output [C3_P1_DATA_SIZE-1:0]
    .c3_p1_rd_full      (c3_p1_rd_full      ),//c3_p1_rd_full        output
    .c3_p1_rd_empty     (c3_p1_rd_empty     ),//c3_p1_rd_empty       output
    .c3_p1_rd_count     (c3_p1_rd_count     ),//c3_p1_rd_count       output [6:0]
    .c3_p1_rd_overflow  (c3_p1_rd_overflow  ),//c3_p1_rd_overflow    output
    .c3_p1_rd_error     (c3_p1_rd_error     ),//c3_p1_rd_error       output

    .c3_p2_cmd_clk      (reg_clk),//input
    .c3_p2_wr_clk       (reg_clk),//input
    .c3_p2_rd_clk       (reg_clk),//input
    .c3_p2_cmd_en       (1'b0               ),//c3_p2_cmd_en         input
    .c3_p2_cmd_instr    (0                  ),//c3_p2_cmd_instr      input [2:0]
    .c3_p2_cmd_bl       (0                  ),//c3_p2_cmd_bl         input [5:0]
    .c3_p2_cmd_byte_addr(0                  ),//c3_p2_cmd_byte_addr  input [29:0]
    .c3_p2_cmd_empty    (c3_p2_cmd_empty    ),//c3_p2_cmd_empty      output
    .c3_p2_cmd_full     (c3_p2_cmd_full     ),//c3_p2_cmd_full       output
    .c3_p2_wr_en        (1'b0               ),//c3_p2_wr_en          input
    .c3_p2_wr_mask      (0                  ),//c3_p2_wr_mask        input [(C3_P2_DATA_SIZE/4)-1:0]
    .c3_p2_wr_data      (0                  ),//c3_p2_wr_data        input [C3_P2_DATA_SIZE-1:0]
    .c3_p2_wr_full      (c3_p2_wr_full      ),//c3_p2_wr_full        output
    .c3_p2_wr_empty     (c3_p2_wr_empty     ),//c3_p2_wr_empty       output
    .c3_p2_wr_count     (                   ),//c3_p2_wr_count       output [6:0]
    .c3_p2_wr_underrun  (c3_p2_wr_underrun  ),//c3_p2_wr_underrun    output
    .c3_p2_wr_error     (c3_p2_wr_error     ),//c3_p2_wr_error       output
    .c3_p2_rd_en        (1'b0               ),//c3_p2_rd_en          input
    .c3_p2_rd_data      (c3_p2_rd_data      ),//c3_p2_rd_data        output [C3_P2_DATA_SIZE-1:0]
    .c3_p2_rd_full      (c3_p2_rd_full      ),//c3_p2_rd_full        output
    .c3_p2_rd_empty     (c3_p2_rd_empty     ),//c3_p2_rd_empty       output
    .c3_p2_rd_count     (c3_p2_rd_count     ),//c3_p2_rd_count       output [6:0]
    .c3_p2_rd_overflow  (c3_p2_rd_overflow  ),//c3_p2_rd_overflow    output
    .c3_p2_rd_error     (c3_p2_rd_error     ) //c3_p2_rd_error       output

    // .c3_p3_cmd_clk      (csi_rx_8b_cl       ),//input
    // .c3_p3_wr_clk       (csi_rx_8b_cl       ),//input
    // .c3_p3_cmd_en       (c3_p3_cmd_en       ),//input
    // .c3_p3_cmd_instr    (c3_p3_cmd_instr    ),//input [2:0]
    // .c3_p3_cmd_bl       (c3_p3_cmd_bl       ),//input [5:0]
    // .c3_p3_cmd_byte_addr(c3_p3_cmd_byte_addr),//input [29:0]
    // .c3_p3_cmd_empty    (c3_p3_cmd_empty    ),//output
    // .c3_p3_cmd_full     (c3_p3_cmd_full     ),//output
    // .c3_p3_wr_en        (c3_p3_wr_en        ),//input
    // .c3_p3_wr_mask      (c3_p3_wr_mask      ),//input [3:0]
    // .c3_p3_wr_data      (c3_p3_wr_data      ),//input [31:0]
    // .c3_p3_wr_full      (c3_p3_wr_full      ),//output
    // .c3_p3_wr_empty     (c3_p3_wr_empty     ),//output
    // .c3_p3_wr_count     (c3_p3_wr_count     ),//output [6:0]
    // .c3_p3_wr_underrun  (c3_p3_wr_underrun  ),//output
    // .c3_p3_wr_error     (c3_p3_wr_error     ),//output

    // .c3_p4_cmd_clk      (csi_tx_ser_gclk    ),//input
    // .c3_p4_rd_clk       (csi_tx_ser_gclk    ),//input
    // .c3_p4_cmd_en       (c3_p4_cmd_en       ),//(0),//input
    // .c3_p4_cmd_instr    (c3_p4_cmd_instr    ),//(0),//input [2:0]
    // .c3_p4_cmd_bl       (c3_p4_cmd_bl       ),//(0),//input [5:0]
    // .c3_p4_cmd_byte_addr(c3_p4_cmd_byte_addr),//(0),//input [29:0]
    // .c3_p4_cmd_empty    (c3_p4_cmd_empty    ),//() ,//output
    // .c3_p4_cmd_full     (c3_p4_cmd_full     ),//() ,//output
    // .c3_p4_rd_en        (c3_p4_rd_en        ),//(0),//input
    // .c3_p4_rd_data      (c3_p4_rd_data      ),//() ,//output [31:0]
    // .c3_p4_rd_full      (c3_p4_rd_full      ),//() ,//output
    // .c3_p4_rd_empty     (c3_p4_rd_empty     ),//() ,//output
    // .c3_p4_rd_count     (c3_p4_rd_count     ),//() ,//output [6:0]
    // .c3_p4_rd_overflow  (c3_p4_rd_overflow  ),//() ,//output
    // .c3_p4_rd_error     (c3_p4_rd_error     ),//()  //output

    // .c3_p5_cmd_clk      (csi_rx_8b_cl       ),//input
    // .c3_p5_wr_clk       (csi_rx_8b_cl       ),//input
    // .c3_p5_cmd_en       (c3_p5_cmd_en       ),//input
    // .c3_p5_cmd_instr    (c3_p5_cmd_instr    ),//input [2:0]
    // .c3_p5_cmd_bl       (c3_p5_cmd_bl       ),//input [5:0]
    // .c3_p5_cmd_byte_addr(c3_p5_cmd_byte_addr),//input [29:0]
    // .c3_p5_cmd_empty    (c3_p5_cmd_empty    ),//output
    // .c3_p5_cmd_full     (c3_p5_cmd_full     ),//output
    // .c3_p5_wr_en        (c3_p5_wr_en        ),//input
    // .c3_p5_wr_mask      (c3_p5_wr_mask      ),//input [3:0]
    // .c3_p5_wr_data      (c3_p5_wr_data      ),//input [31:0]
    // .c3_p5_wr_full      (c3_p5_wr_full      ),//output
    // .c3_p5_wr_empty     (c3_p5_wr_empty     ),//output
    // .c3_p5_wr_count     (c3_p5_wr_count     ),//output [6:0]
    // .c3_p5_wr_underrun  (c3_p5_wr_underrun  ),//output
    // .c3_p5_wr_error     (c3_p5_wr_error     ) //output
);

reg [15:0] csi_rx_test_d7 = 0;
reg [15:0] csi_rx_test_d6 = 0;
reg [15:0] csi_rx_test_d5 = 0;
reg [15:0] csi_rx_test_d4 = 0;
reg [15:0] csi_rx_test_d3 = 0;
reg [15:0] csi_rx_test_d2 = 0;
reg [15:0] csi_rx_test_d1 = 0;
reg [15:0] csi_rx_test_d0 = 0;

always @(posedge csi_rx_cl) begin
    if (SENSOR_PIXEL_WIDTH == 10) begin
        sr_csi_rx_do[63:48] <= {6'd0,csi_rx_do[39:38],csi_rx_do[37:30]};
        sr_csi_rx_do[47:32] <= {6'd0,csi_rx_do[29:28],csi_rx_do[27:20]};
        sr_csi_rx_do[31:16] <= {6'd0,csi_rx_do[19:18],csi_rx_do[17:10]};
        sr_csi_rx_do[15: 0] <= {6'd0,csi_rx_do[ 9: 8],csi_rx_do[ 7: 0]};
        sr_csi_rx_de <= csi_rx_de;

        // sr_csi_rx_do[48 +: 16] <= csi_rx_test_d3[15:0];
        // sr_csi_rx_do[32 +: 16] <= csi_rx_test_d2[15:0];
        // sr_csi_rx_do[16 +: 16] <= csi_rx_test_d1[15:0];
        // sr_csi_rx_do[0  +: 16] <= csi_rx_test_d0[15:0];

    end else begin
        sr_csi_rx_de <= 1'b0;
        if (!csi_rx_hs) begin
            csi_rx_de_cnt <= 1'b0;
        end else begin
            if (csi_rx_de) begin
                if (csi_rx_de_cnt) begin
                    csi_rx_de_cnt <= 1'b0;
                    sr_csi_rx_do[56 +: 8] <= csi_rx_do[30 +: 8];
                    sr_csi_rx_do[48 +: 8] <= csi_rx_do[20 +: 8];
                    sr_csi_rx_do[40 +: 8] <= csi_rx_do[10 +: 8];
                    sr_csi_rx_do[32 +: 8] <= csi_rx_do[0  +: 8];
                    sr_csi_rx_do[31: 0] <= sv_csi_rx_do;
                    sr_csi_rx_de <= 1'b1;

                    // sr_csi_rx_do[56 +: 8] <= csi_rx_test_d7[7:0];
                    // sr_csi_rx_do[48 +: 8] <= csi_rx_test_d6[7:0];
                    // sr_csi_rx_do[40 +: 8] <= csi_rx_test_d5[7:0];
                    // sr_csi_rx_do[32 +: 8] <= csi_rx_test_d4[7:0];
                    // sr_csi_rx_do[24 +: 8] <= csi_rx_test_d3[7:0];
                    // sr_csi_rx_do[16 +: 8] <= csi_rx_test_d2[7:0];
                    // sr_csi_rx_do[8  +: 8] <= csi_rx_test_d1[7:0];
                    // sr_csi_rx_do[0  +: 8] <= csi_rx_test_d0[7:0];
                end else begin
                    csi_rx_de_cnt <= 1'b1;
                    sv_csi_rx_do[24 +: 8] <= csi_rx_do[30 +: 8];
                    sv_csi_rx_do[16 +: 8] <= csi_rx_do[20 +: 8];
                    sv_csi_rx_do[8  +: 8] <= csi_rx_do[10 +: 8];
                    sv_csi_rx_do[0  +: 8] <= csi_rx_do[0  +: 8];
                end
            end
        end
    end
    sr_csi_rx_hs <= ~csi_rx_hs;
    sr_csi_rx_vs <= csi_rx_vs;
end

reg csi_rx_de_cnt2 = 0;
always @(posedge csi_rx_cl) begin
    if (SENSOR_PIXEL_WIDTH == 10) begin
        if (!csi_rx_hs) begin
            csi_rx_test_d3 <= 16'd3;
            csi_rx_test_d2 <= 16'd2;
            csi_rx_test_d1 <= 16'd1;
            csi_rx_test_d0 <= 16'd0;
        end else begin
            if (csi_rx_de) begin
                csi_rx_test_d3 <= csi_rx_test_d3 + 4;
                csi_rx_test_d2 <= csi_rx_test_d2 + 4;
                csi_rx_test_d1 <= csi_rx_test_d1 + 4;
                csi_rx_test_d0 <= csi_rx_test_d0 + 4;
            end
        end
    end else begin
        if (!csi_rx_hs) begin
            csi_rx_test_d7 <= 16'd7;
            csi_rx_test_d6 <= 16'd6;
            csi_rx_test_d5 <= 16'd5;
            csi_rx_test_d4 <= 16'd4;
            csi_rx_test_d3 <= 16'd3;
            csi_rx_test_d2 <= 16'd2;
            csi_rx_test_d1 <= 16'd1;
            csi_rx_test_d0 <= 16'd0;
            csi_rx_de_cnt2 <= 1'b0;
        end else begin
            if (csi_rx_de) begin
                if (csi_rx_de_cnt2) begin
                    csi_rx_de_cnt2 <= 1'b0;
                    csi_rx_test_d7 <= csi_rx_test_d7 + 8;
                    csi_rx_test_d6 <= csi_rx_test_d6 + 8;
                    csi_rx_test_d5 <= csi_rx_test_d5 + 8;
                    csi_rx_test_d4 <= csi_rx_test_d4 + 8;
                    csi_rx_test_d3 <= csi_rx_test_d3 + 8;
                    csi_rx_test_d2 <= csi_rx_test_d2 + 8;
                    csi_rx_test_d1 <= csi_rx_test_d1 + 8;
                    csi_rx_test_d0 <= csi_rx_test_d0 + 8;
                end else begin
                    csi_rx_de_cnt2 <= 1'b1;
                end
            end
        end
    end
end

frbuf_write_32b #(
    .MEM_DATA_WIDTH(C3_P0_DATA_SIZE)
) mem_wr0 (
    // Video interface
    .di_i(sr_csi_rx_do),
    .de_i(sr_csi_rx_de),
    .hs_i(sr_csi_rx_hs),
    .vs_i(sr_csi_rx_vs),

    .dbg_i(1'b0),
    .wrch_num(2'd0),
    .frbuf_num(frbuf_num),
    .burst(reg_mem_wburst[`FPGA_REG_MEM_WBURST_CH0_MSB:`FPGA_REG_MEM_WBURST_CH0_LSB]),

    // MCB write interface
    .mcb_calib_done    (sr_mcb3_calib_done),

    .mcb_cmd_en        (c3_p0_cmd_en       ),
    .mcb_cmd_instr     (c3_p0_cmd_instr    ),
    .mcb_cmd_bl        (c3_p0_cmd_bl       ),
    .mcb_cmd_byte_addr (c3_p0_cmd_byte_addr),
    .mcb_cmd_empty     (c3_p0_cmd_empty    ),
    .mcb_cmd_full      (c3_p0_cmd_full     ),

    .mcb_wr_en         (c3_p0_wr_en        ),
    .mcb_wr_mask       (c3_p0_wr_mask      ),
    .mcb_wr_data       (c3_p0_wr_data      ),
    .mcb_wr_full       (c3_p0_wr_full      ),
    .mcb_wr_empty      (c3_p0_wr_empty     ),
    .mcb_wr_count      (c3_p0_wr_count     ),
    .mcb_wr_underrun   (c3_p0_wr_underrun  ),
    .mcb_wr_error      (c3_p0_wr_error     ),

    .clk(csi_rx_cl),
    .rst(1'b0)
);


wire [3:0] dbg_mem_rd0;
frbuf_read #(
    .SENSOR_PIXEL_WIDTH(SENSOR_PIXEL_WIDTH)
) mem_rd0 (
    .hs_i(sr_csi_rx_hs),
    .vs_i(fr_line_rd),
    .frbuf_num(1'b0),//(~frbuf_num),
    .burst(reg_mem_rburst[`FPGA_REG_MEM_RBURST_CH0_MSB:`FPGA_REG_MEM_RBURST_CH0_LSB]),

    .dbg(dbg_mem_rd0),

    .fr0_x_size(reg_fr_xsize),
    .fr0_roi_x1(reg_roi_x1),
    .fr0_roi_x2(reg_roi_x2),
    .fr0_roi_y1(reg_roi_y1),
    .fr0_roi_y2(reg_roi_y2),

    .fr1_x_size(reg_fr_xsize),
    .fr1_roi_x1(reg_roi_x1),
    .fr1_roi_x2(reg_roi_x2),
    .fr1_roi_y1(reg_roi_y1),
    .fr1_roi_y2(reg_roi_y2),

    .fr_xsize_o(),
    .do_o(csi_txmem_do),
    .de_o(csi_txmem_de),
    .hs_o(csi_txmem_hs),
    .vs_o(csi_txmem_vs),
    .fifo_empty_i(csi_txmem_fifo_empty),//(1'b1),//

    //MCB read interface
    .mcb_calib_done    (sr_mcb3_calib_done),

    .mcb_cmd_en        (c3_p1_cmd_en       ),
    .mcb_cmd_instr     (c3_p1_cmd_instr    ),
    .mcb_cmd_bl        (c3_p1_cmd_bl       ),
    .mcb_cmd_byte_addr (c3_p1_cmd_byte_addr),
    .mcb_cmd_empty     (c3_p1_cmd_empty    ),
    .mcb_cmd_full      (c3_p1_cmd_full     ),
    .mcb_rd_en         (c3_p1_rd_en        ),
    .mcb_rd_data       (c3_p1_rd_data      ),
    .mcb_rd_full       (c3_p1_rd_full      ),
    .mcb_rd_empty      (c3_p1_rd_empty     ),
    .mcb_rd_count      (c3_p1_rd_count     ),
    .mcb_rd_overflow   (c3_p1_rd_overflow  ),
    .mcb_rd_error      (c3_p1_rd_error     ),

    .clk(reg_clk),
    .rst(1'b0)
);


fifo_32b_32b fifo_out (
  .din(csi_txmem_do),
  .wr_en(csi_txmem_de),

  .dout(fifo_fr_do),
  .rd_en(fifo_fr_rd),//(~reg_ctrl[1]), //

  .full(csi_txmem_fifo_full),
  .empty(csi_txmem_fifo_empty),

  .clk(reg_clk),
  .rst(~fifo_nrst) //(reg_ctrl[0]) //
);

//-------------------------------------------
//DEBUG
//-------------------------------------------
reg [1:0] r_csi_rx_lp_cl;
reg [3:0] r_csi_rx_lp_dp;
reg [3:0] r_csi_rx_lp_dn;
reg [2:0] sr_csi_rx_err;
reg [2:0] st_csi_rx_err;
always @ (posedge csi_rx_cl) begin
    r_csi_rx_lp_cl <= {csi_rx_lp_cp, csi_rx_lp_cn};
    r_csi_rx_lp_dp <= csi_rx_lp_dp;
    r_csi_rx_lp_dn <= csi_rx_lp_dn;

    sr_csi_rx_err <= csi_rx_err;
    st_csi_rx_err[0] <= csi_rx_err[0] & !sr_csi_rx_err[0];
    st_csi_rx_err[1] <= csi_rx_err[1] & !sr_csi_rx_err[1];
    st_csi_rx_err[2] <= csi_rx_err[2] & !sr_csi_rx_err[2];
end

genvar b;
wire [1:0] csi_tx_hs_unuse;
generate
    if (DLANE_COUNT == 2) begin
        for (b=0; b < 2; b=b+1) begin: skip_csi_lane
            IBUFDS ibuf_rx_hs (
                .O(csi_tx_hs_unuse[b]),
                .I (csi_rx_hs_dp[2+b]),
                .IB(csi_rx_hs_dn[2+b])
            );
        end
    end else begin
        assign csi_tx_hs_unuse = 2'd0;
    end
endgenerate

assign dbg_led = 0;

wire dbg_mem_err;
wire dbg_mem_full;
assign dbg_mem_err = c3_p1_rd_error | c3_p1_rd_overflow
                   | c3_p0_wr_error | c3_p0_wr_underrun;

assign dbg_mem_full = c3_p1_rd_full | c3_p1_cmd_full
                    | c3_p0_wr_full | c3_p0_cmd_full;

reg csi_rx_cl_div2_o = 1'b0;
always @ (posedge csi_rx_cl) begin
    csi_rx_cl_div2_o <= ~csi_rx_cl_div2_o;
end

reg [31:0] dbg_csi_txmem_do;
reg dbg_csi_txmem_de;
reg dbg_csi_txmem_hs;
reg dbg_csi_txmem_vs;
reg dbg_csi_txmem_fifo_empty;
reg dbg_csi_txmem_fifo_full;
always @ (posedge csi_tx_ser_gclk) begin
    dbg_csi_txmem_do  <= csi_txmem_do  ;
    dbg_csi_txmem_de  <= csi_txmem_de  ;
    dbg_csi_txmem_hs  <= csi_txmem_hs  ;
    dbg_csi_txmem_vs  <= csi_txmem_vs  ;
    dbg_csi_txmem_fifo_empty<= csi_txmem_fifo_empty;
    dbg_csi_txmem_fifo_full<= csi_txmem_fifo_full;
end

reg dbg_c3_p0_cmd_en;
reg [29:0] dbg_c3_p0_cmd_byte_addr;
reg dbg_c3_p0_cmd_empty;
reg dbg_c3_p0_cmd_full;
reg dbg_c3_p0_wr_en;
reg dbg_c3_p0_wr_full;
reg dbg_c3_p0_wr_empty;
reg dbg_c3_p0_wr_underrun;
reg dbg_c3_p0_wr_error;
reg dbg_c3_p0_error;
always @ (posedge csi_rx_cl) begin
    dbg_c3_p0_cmd_en        <= c3_p0_cmd_en       ;
    dbg_c3_p0_cmd_byte_addr <= c3_p0_cmd_byte_addr;
    dbg_c3_p0_cmd_empty     <= c3_p0_cmd_empty    ;
    dbg_c3_p0_cmd_full      <= c3_p0_cmd_full     ;
    dbg_c3_p0_wr_en         <= c3_p0_wr_en        ;
    dbg_c3_p0_wr_full       <= c3_p0_wr_full      ;
    dbg_c3_p0_wr_empty      <= c3_p0_wr_empty     ;
    dbg_c3_p0_wr_underrun   <= c3_p0_wr_underrun  ;
    dbg_c3_p0_wr_error      <= c3_p0_wr_error     ;

    dbg_c3_p0_error  <= c3_p0_cmd_full | c3_p0_wr_full | c3_p0_wr_underrun | c3_p0_wr_error;
end


always @ (posedge reg_clk) begin
    // if (uart_baud_cnt == 54) begin //reg_clk=100MHz  baudrate 115200
    // if (uart_baud_cnt == 27) begin //reg_clk=100MHz  baudrate 230400

    // if (uart_baud_cnt == 27) begin //reg_clk=200MHz  baudrate 460800
    if (uart_baud_cnt == 26) begin //reg_clk=200MHz  baudrate 921600

    // if (uart_baud_cnt == 163) begin //reg_clk=300MHz baudrate 115200
    // if (uart_baud_cnt == 81) begin //reg_clk=300MHz baudrate 230400
    // if (uart_baud_cnt == 41) begin //reg_clk=300MHz baudrate 460800
        // uart_en_16_x_baud <= 1'b1;
        uart_baud_cnt <= 0;
    end else begin
        // uart_en_16_x_baud <= 1'b0;
        uart_baud_cnt <= uart_baud_cnt + 1;
    end

    if ((uart_baud_cnt == 12) || (uart_baud_cnt == 26)) begin //reg_clk=200MHz  baudrate 921600
        uart_en_16_x_baud <= 1'b1;
    end else begin
        uart_en_16_x_baud <= 1'b0;
    end

end

assign uart_rx = dbg_spi_mosi;
// assign uart_rx = uart_rx;
uart usr_uart (
    .tx(uart_tx), //output
    .rx(uart_rx), //input

    .rxdata(uart_rxdata),//output [7:0]
    .rxdrdy(uart_rxdrdy),//output
    .rd(uart_read),//input

    .txdata(uart_txdata),//input  [7:0]
    .full(uart_txfull),//output
    .wr(uart_write),//input

    .en_16_x_baud(uart_en_16_x_baud),
    .clk(reg_clk),
    .rst(1'b0)
);

`ifdef SIM_FSM
    enum int unsigned {
        S_IDLE     ,
        S_SEND     ,
        S_STATUS
    } fsm_uart_cs = S_IDLE;
`else
    localparam S_IDLE   =0;
    localparam S_SEND   =1;
    localparam S_STATUS =2;
    reg [5:0] fsm_uart_cs = S_IDLE;
`endif

reg [1:0] fifo_cnt_byte = 0;
reg [15:0] fifo_txbyte = 0;

always @ (posedge reg_clk) begin
    uart_read <= 1'b0;
    uart_write <= 1'b0;
    fr_line_rd <= 1'b0;
    fifo_fr_rd <= 1'b0;

    case (fsm_uart_cs)
        S_IDLE : begin
            // if (reg_ctrl[0]) begin
            if (uart_rxdrdy & !uart_read) begin
                if (uart_rxdata[7:6] == 2'b11) begin
                    tttt <= 1'b1;
                    fifo_cnt_byte <= 0;
                    fsm_uart_cs <= S_SEND;

                end else if (uart_rxdata[7:6] == 2'b01) begin
                    fsm_uart_cs <= S_STATUS;

                end else begin
                    fifo_nrst <= uart_rxdata[5];
                    fr_line_rd <= uart_rxdata[4];
                end
                uart_read <= 1'b1;
                uart_txdata <= uart_rxdata;
            end
        end

        S_SEND : begin
            if (!uart_txfull & !uart_write) begin
                if (!csi_txmem_fifo_empty) begin
                    case (fifo_cnt_byte)
                        2'b0 : uart_txdata <= fifo_fr_do[0  +: 8];
                        2'd1 : uart_txdata <= fifo_fr_do[8  +: 8];
                        2'd2 : uart_txdata <= fifo_fr_do[16 +: 8];
                        2'd3 : uart_txdata <= fifo_fr_do[24 +: 8];
                    endcase

                    if (fifo_cnt_byte == 2'd3) begin
                        fifo_cnt_byte <= 0;
                        fifo_fr_rd <= 1'b1;
                    end else begin
                        fifo_cnt_byte <= fifo_cnt_byte + 1'b1;
                    end

                    uart_write <= 1'b1;

                    if (SENSOR_PIXEL_WIDTH == 10) begin
                        if (fifo_txbyte == (2560 - 1)) begin
                            fifo_txbyte <= 0;
                            fsm_uart_cs <= S_IDLE;
                        end else begin
                            fifo_txbyte <= fifo_txbyte + 1;
                        end
                    end else begin
                        if (fifo_txbyte == (1280 - 1)) begin
                            fifo_txbyte <= 0;
                            fsm_uart_cs <= S_IDLE;
                        end else begin
                            fifo_txbyte <= fifo_txbyte + 1;
                        end
                    end
                end
                // uart_write <= 1'b1;
                // fsm_uart_cs <= S_IDLE;
            end
        end

        S_STATUS : begin
            if (!uart_txfull & !uart_write) begin
                uart_txdata[7:5] <= 0;
                uart_txdata[1] <= fifo_nrst;
                uart_txdata[0] <= csi_txmem_fifo_empty;
                uart_write <= 1'b1;
                fsm_uart_cs <= S_IDLE;
            end
        end
    endcase

end


wire dbg_tp_o;
assign dbg_spi_clk  = uart_tx; //csi_rx_hs; //(reg_ctrl[0]) ? dbg_mem_full : dbg_mem_err;//
// assign dbg_spi_mosi = uart_rx;//csi_rx_vs;
assign dbg_spi_miso = 1'b0;//csi_rx_cl_div2_o ;
assign dbg_spi_cs   = dbg_tp_o;


assign dbg[0] = csi_rx_hs ;
assign dbg[1] = csi_rx_vs ;
assign dbg[2] = csi_tx_dbg_o[0];
assign dbg[3] = dbg_tp_o;

assign dbg_tp_o = (reg_ctrl[`FPGA_REG_CTRL_TP_SRC_H_BIT:`FPGA_REG_CTRL_TP_SRC_L_BIT] == 3'b000) ? csi_tx_dbg_o[1] :
                (reg_ctrl[`FPGA_REG_CTRL_TP_SRC_H_BIT:`FPGA_REG_CTRL_TP_SRC_L_BIT] == 3'b001) ? csi_tx_dbg_o[2] :
                (reg_ctrl[`FPGA_REG_CTRL_TP_SRC_H_BIT:`FPGA_REG_CTRL_TP_SRC_L_BIT] == 3'b010) ? dbg_mem_full :
                (reg_ctrl[`FPGA_REG_CTRL_TP_SRC_H_BIT:`FPGA_REG_CTRL_TP_SRC_L_BIT] == 3'b011) ? dbg_mem_err :
                                                                                                ddr_test_busy;

assign ddr_test_busy = 1'b0;

assign dbg[4] = csi_tx_hs_unuse | sr_mcb3_calib_done
              | img_sensor_fsin
              | img_sensor_hsyn
              | img_sensor_vsyn
              | (|r_csi_rx_lp_cl)
              | (|r_csi_rx_lp_dp)
              | (|r_csi_rx_lp_dn)
              | (|st_csi_rx_err)
              | (|dbg_csi_txmem_do) | dbg_csi_txmem_de | dbg_csi_txmem_hs | dbg_csi_txmem_vs | dbg_csi_txmem_fifo_empty | dbg_csi_txmem_fifo_full
              | dbg_c3_p0_cmd_en | (|dbg_c3_p0_cmd_byte_addr) | dbg_c3_p0_cmd_empty | dbg_c3_p0_cmd_full | dbg_c3_p0_wr_en | dbg_c3_p0_wr_full | dbg_c3_p0_wr_empty | dbg_c3_p0_wr_underrun | dbg_c3_p0_wr_error | dbg_c3_p0_error;
//              | (|dbg_mem_rd0)

`ifdef SIM_DBG
assign dbg_fr0_roi_xsize = {1'b0, csi_tx_xsize[15:1]};//div2
assign dbg_fr0_roi_ysize = reg_roi_y2 - reg_roi_y1 + 1;

assign dbg_csi_rx_do = csi_rx_do[7:0];
assign dbg_csi_rx_de = csi_rx_de;
assign dbg_csi_rx_hs = csi_rx_hs;
assign dbg_csi_rx_vs = csi_rx_vs;
assign dbg_csi_rx_cl = csi_rx_cl;

`endif



endmodule
