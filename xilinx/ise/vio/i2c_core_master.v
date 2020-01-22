//-----------------------------------------------------------------------
// Author : Golovachenko Victor
//
// Description : module execute atomic operation(i2c_core_master.vh):
//               1 - start condition
//               2 - restart condition
//               3 - stop condition
//               4 - txbyte (msb first)
//               5 - rxbyte (msb first)
//-----------------------------------------------------------------------
`include "i2c_core_master.vh"

module i2c_core_master #(
    G_CLK_FREQ = 150000000,
    G_BAUD = 100000
)(
    input [2:0] cmd_i  , //Type operation
    input      start_i , //Start operation
    output reg done_o , //Operation done
    input      txack_i , //Set level for acknowlege to slave device
    output reg rxack_o, //Recieve acknowlege from slave device

    input [7:0] txd_i, //FPGA -> I2C
    output reg [7:0] rxd_o, //FPGA <- I2C

    //I2C
    inout sda_io,
    inout scl_io,

    //System
    input clk,
    input rst
);

//-----------------------------------------------------------------------
`ifdef SIM_FSM
    enum int unsigned {
        S_IDLE     ,
        S_START_0  ,
        S_START_1  ,
        S_START_2  ,
        S_START_3  ,
        S_RESTART_0,
        S_RESTART_1,
        S_RESTART_2,
        S_RESTART_3,
        S_STOP_0   ,
        S_STOP_1   ,
        S_STOP_2   ,
        S_STOP_3   ,
        S_TXBIT_0  ,
        S_TXBIT_1  ,
        S_TXBIT_2  ,
        S_TXBIT_3  ,
        S_RXACK_0  ,
        S_RXACK_1  ,
        S_RXACK_2  ,
        S_RXACK_3  ,
        S_RXBIT_0  ,
        S_RXBIT_1  ,
        S_RXBIT_2  ,
        S_RXBIT_3  ,
        S_TXACK_0  ,
        S_TXACK_1  ,
        S_TXACK_2  ,
        S_TXACK_3
    } fsm_i2c_cs = S_IDLE;
`else
    localparam S_IDLE      =0;
    localparam S_START_0   =1;
    localparam S_START_1   =2;
    localparam S_START_2   =3;
    localparam S_START_3   =4;
    localparam S_RESTART_0 =5;
    localparam S_RESTART_1 =6;
    localparam S_RESTART_2 =7;
    localparam S_RESTART_3 =8;
    localparam S_STOP_0    =9;
    localparam S_STOP_1    =10;
    localparam S_STOP_2    =11;
    localparam S_STOP_3    =12;
    localparam S_TXBIT_0   =13;
    localparam S_TXBIT_1   =14;
    localparam S_TXBIT_2   =15;
    localparam S_TXBIT_3   =16;
    localparam S_RXACK_0   =17;
    localparam S_RXACK_1   =18;
    localparam S_RXACK_2   =19;
    localparam S_RXACK_3   =20;
    localparam S_RXBIT_0   =21;
    localparam S_RXBIT_1   =22;
    localparam S_RXBIT_2   =23;
    localparam S_RXBIT_3   =24;
    localparam S_TXACK_0   =25;
    localparam S_TXACK_1   =26;
    localparam S_TXACK_2   =27;
    localparam S_TXACK_3   =28;
    reg [5:0] fsm_i2c_cs = S_IDLE;
`endif


localparam integer CI_COUNT_1DEV4 = (G_CLK_FREQ / G_BAUD) / 4;

reg cntf_en = 1'b0;
reg cntf_clr = 1'b0;
reg cntb_clr = 1'b0;
reg [31:0] cntf = 0;
reg [2:0]  cntb = 0;
reg        i_sda;
reg        i_scl;
reg [7:0]  sr_txd = 0;
reg [7:0]  sr_rxd = 0;

assign scl_io = i_scl ? 1'hz : 1'h0;
assign sda_io = i_sda ? 1'hz : 1'h0;

always @ (posedge clk) begin
    done_o <= 1'b0;
    cntf_clr <= 1'b0;
    cntb_clr <= 1'b0;

    if (rst) begin
        fsm_i2c_cs <= S_IDLE;

        i_sda <= 1'b1;
        i_scl <= 1'b1;

        cntf_en <= 1'b0;

        rxack_o <= 1'b0;
        rxd_o <= 0;

    end else begin

        case (fsm_i2c_cs)
            //-----------------------------------
            //
            //-----------------------------------
            S_IDLE : begin
                if (start_i) begin
                    cntf_en <= 1'b1;
                    if (cmd_i == `C_I2C_MASTER_CORE_START) begin
                        fsm_i2c_cs <= S_START_0;
                    end else if (cmd_i == `C_I2C_MASTER_CORE_RESTART) begin
                        fsm_i2c_cs <= S_RESTART_0;
                    end else if (cmd_i == `C_I2C_MASTER_CORE_STOP) begin
                        fsm_i2c_cs <= S_STOP_0;
                    end else if (cmd_i == `C_I2C_MASTER_CORE_TXBYTE) begin
                        fsm_i2c_cs <= S_TXBIT_0;
                    end else if (cmd_i == `C_I2C_MASTER_CORE_RXBYTE) begin
                        fsm_i2c_cs <= S_RXBIT_0;
                    end
                end
            end

            //-----------------------------------
            //START CONDITION
            //-----------------------------------
            S_START_0 : begin
                i_sda <= 1'b1;
                i_scl <= 1'b1;
                if (cntf == (CI_COUNT_1DEV4 - 1)) begin
                    cntf_clr <= 1'b1;
                    fsm_i2c_cs <= S_START_1;
                end
            end

            S_START_1 : begin
                i_sda <= 1'b1;
                i_scl <= 1'b1;
                if (cntf == (CI_COUNT_1DEV4 - 1)) begin
                    cntf_clr <= 1'b1;
                    fsm_i2c_cs <= S_START_2;
                end
            end

            S_START_2 : begin
                i_sda <= 1'b0;
                i_scl <= 1'b1;
                if (cntf == (CI_COUNT_1DEV4 - 1)) begin
                    cntf_clr <= 1'b1;
                    fsm_i2c_cs <= S_START_3;
                end
            end

            S_START_3 : begin
                i_sda <= 1'b0;
                i_scl <= 1'b0;
                if (cntf == (CI_COUNT_1DEV4 - 1)) begin
                    cntf_clr <= 1'b1; cntf_en <= 1'b0;
                    done_o <= 1'b1;
                    fsm_i2c_cs <= S_IDLE;
                end
            end

            //-----------------------------------
            //RESTART CONDITION
            //-----------------------------------
            S_RESTART_0 : begin
                i_sda <= 1'b1;
                i_scl <= 1'b0;
                if (cntf == (CI_COUNT_1DEV4 - 1)) begin
                    cntf_clr <= 1'b1;
                    fsm_i2c_cs <= S_RESTART_1;
                end
            end

            S_RESTART_1 : begin
                i_sda <= 1'b1;
                i_scl <= 1'b1;
                if (cntf == (CI_COUNT_1DEV4 - 1)) begin
                    cntf_clr <= 1'b1;
                    fsm_i2c_cs <= S_RESTART_2;
                end
            end

            S_RESTART_2 : begin
                i_sda <= 1'b0;
                i_scl <= 1'b1;
                if (cntf == (CI_COUNT_1DEV4 - 1)) begin
                    cntf_clr <= 1'b1;
                    fsm_i2c_cs <= S_RESTART_3;
                end
            end

            S_RESTART_3 : begin
                i_sda <= 1'b0;
                i_scl <= 1'b0;
                if (cntf == (CI_COUNT_1DEV4 - 1)) begin
                    cntf_clr <= 1'b1; cntf_en <= 1'b0;
                    done_o <= 1'b1;
                    fsm_i2c_cs <= S_IDLE;
                end
            end

            //-----------------------------------
            //STOP CONDITION
            //-----------------------------------
            S_STOP_0 : begin
                i_sda <= 1'b0;
                i_scl <= 1'b0;
                if (cntf == (CI_COUNT_1DEV4 - 1)) begin
                    cntf_clr <= 1'b1;
                    fsm_i2c_cs <= S_STOP_1;
                end
            end

            S_STOP_1 : begin
                i_sda <= 1'b0;
                i_scl <= 1'b1;
                if (cntf == (CI_COUNT_1DEV4 - 1)) begin
                    cntf_clr <= 1'b1;
                    fsm_i2c_cs <= S_STOP_2;
                end
            end

            S_STOP_2 : begin
                i_sda <= 1'b1;
                i_scl <= 1'b1;
                if (cntf == (CI_COUNT_1DEV4 - 1)) begin
                    cntf_clr <= 1'b1;
                    fsm_i2c_cs <= S_STOP_3;
                end
            end

            S_STOP_3 : begin
                i_sda <= 1'b1;
                i_scl <= 1'b1;
                if (cntf == (CI_COUNT_1DEV4 - 1)) begin
                    cntf_clr <= 1'b1; cntf_en <= 1'b0;
                    done_o <= 1'b1;
                    fsm_i2c_cs <= S_IDLE;
                end
            end

            //-----------------------------------
            //TXBYTE
            //-----------------------------------
            S_TXBIT_0 : begin
                i_sda <= sr_txd[7];
                i_scl <= 1'b0;
                if (cntf == (CI_COUNT_1DEV4 - 1)) begin
                    cntf_clr <= 1'b1;
                    fsm_i2c_cs <= S_TXBIT_1;
                end
            end

            S_TXBIT_1 : begin
                i_sda <= sr_txd[7];
                i_scl <= 1'b1;
                if (cntf == (CI_COUNT_1DEV4 - 1)) begin
                    cntf_clr <= 1'b1;
                    fsm_i2c_cs <= S_TXBIT_2;
                end
            end

            S_TXBIT_2 : begin
                i_sda <= sr_txd[7];
                i_scl <= 1'b1;
                if (cntf == (CI_COUNT_1DEV4 - 1)) begin
                    cntf_clr <= 1'b1;
                    fsm_i2c_cs <= S_TXBIT_3;
                end
            end

            S_TXBIT_3 : begin
                i_scl <= 1'b0;
                i_sda <= sr_txd[7];
                if (cntf == (CI_COUNT_1DEV4 - 1)) begin
                    cntf_clr <= 1'b1;
                    if (cntb == 8'h7) begin
                        cntb_clr <= 1'b1;
                        fsm_i2c_cs <= S_RXACK_0;
                    end else begin
                        fsm_i2c_cs <= S_TXBIT_0;
                    end
                end
            end

            S_RXACK_0 : begin
                i_sda <= 1'b1;
                i_scl <= 1'b0;
                if (cntf == (CI_COUNT_1DEV4 - 1)) begin
                    cntf_clr <= 1'b1;
                    fsm_i2c_cs <= S_RXACK_1;
                end
            end

            S_RXACK_1 : begin
                i_sda <= 1'b1;
                i_scl <= 1'b1;
                if (cntf == (CI_COUNT_1DEV4 - 1)) begin
                    cntf_clr <= 1'b1;
                    rxack_o <= sda_io;
                    fsm_i2c_cs <= S_RXACK_2;
                end
            end

            S_RXACK_2 : begin
                i_sda <= 1'b1;
                i_scl <= 1'b1;
                if (cntf == (CI_COUNT_1DEV4 - 1)) begin
                    cntf_clr <= 1'b1;
                    fsm_i2c_cs <= S_RXACK_3;
                end
            end

            S_RXACK_3 : begin
                i_sda <= 1'b1;
                i_scl <= 1'b0;
                if (cntf == (CI_COUNT_1DEV4 - 1)) begin
                    cntf_clr <= 1'b1; cntf_en <= 1'b0;
                    done_o <= 1'b1;
                    fsm_i2c_cs <= S_IDLE;
                end
            end

            //-----------------------------------
            //RXBYTE
            //-----------------------------------
            S_RXBIT_0 : begin
                i_sda <= 1'b1;
                i_scl <= 1'b0;
                if (cntf == (CI_COUNT_1DEV4 - 1)) begin
                    cntf_clr <= 1'b1;
                    fsm_i2c_cs <= S_RXBIT_1;

                end
            end

            S_RXBIT_1 : begin
                i_sda <= 1'b1;
                i_scl <= 1'b1;
                if (cntf == (CI_COUNT_1DEV4 - 1)) begin
                    cntf_clr <= 1'b1;
                    fsm_i2c_cs <= S_RXBIT_2;
                end
            end

            S_RXBIT_2 : begin
                i_sda <= 1'b1;
                i_scl <= 1'b1;
                if (cntf == (CI_COUNT_1DEV4 - 1)) begin
                    cntf_clr <= 1'b1;
                    fsm_i2c_cs <= S_RXBIT_3;
                end
            end

            S_RXBIT_3 : begin
                i_sda <= 1'b1;
                i_scl <= 1'b0;
                if (cntf == (CI_COUNT_1DEV4 - 1)) begin
                    cntf_clr <= 1'b1;
                    if (cntb == 8'h7) begin
                        cntb_clr <= 1'b1;
                        rxd_o <= sr_rxd;
                        fsm_i2c_cs <= S_TXACK_0;
                    end else begin
                        fsm_i2c_cs <= S_RXBIT_0;
                    end
                end
            end

            S_TXACK_0 : begin
                i_sda <= txack_i;
                i_scl <= 1'b0;
                if (cntf == (CI_COUNT_1DEV4 - 1)) begin
                    cntf_clr <= 1'b1;
                    fsm_i2c_cs <= S_TXACK_1;
                end
            end

            S_TXACK_1 : begin
                i_sda <= txack_i;
                i_scl <= 1'b1;
                if (cntf == (CI_COUNT_1DEV4 - 1)) begin
                    cntf_clr <= 1'b1;
                    rxack_o <= sda_io;
                    fsm_i2c_cs <= S_TXACK_2;
                end
            end

            S_TXACK_2 : begin
                i_sda <= txack_i;
                i_scl <= 1'b1;
                if (cntf == (CI_COUNT_1DEV4 - 1)) begin
                    cntf_clr <= 1'b1;
                    fsm_i2c_cs <= S_TXACK_3;
                end
            end

            S_TXACK_3 : begin
                i_sda <= txack_i;
                i_scl <= 1'b0;
                if (cntf == (CI_COUNT_1DEV4 - 1)) begin
                    cntf_clr <= 1'b1; cntf_en <= 1'b0;
                    done_o <= 1'b1;
                    fsm_i2c_cs <= S_IDLE;
                end
            end

        endcase
    end
end


//ferq cnt
always @ (posedge clk) begin
    if (cntf_clr || (!cntf_en)) begin
        cntf <= 0;
    end else begin
        cntf <= cntf + 1'b1;
    end
end

//bit cnt
always @ (posedge clk) begin
    if (cntb_clr) begin
        cntb <= 0;
    end else if ( (cntf == (CI_COUNT_1DEV4 - 1)) &&
                  ((fsm_i2c_cs == S_TXBIT_3) || (fsm_i2c_cs == S_RXBIT_3)) ) begin
        cntb <= cntb + 1'b1;
    end
end

//Shift reg (I2C/Master -> I2C/Slave)
always @ (posedge clk) begin
    if (start_i) begin
        sr_txd <= txd_i; //txdata update
    end else if ( (fsm_i2c_cs == S_TXBIT_3) && (cntf == (CI_COUNT_1DEV4 - 1)) ) begin
        sr_txd <= {sr_txd[6:0], 1'b0};
    end
end

//Shift reg (I2C/Master <- I2C/Slave)
always @ (posedge clk) begin
    if ( (fsm_i2c_cs == S_RXBIT_1) && (cntf == (CI_COUNT_1DEV4 - 1)) ) begin
        sr_rxd <= {sr_rxd[6:0], sda_io};
    end
end


endmodule
