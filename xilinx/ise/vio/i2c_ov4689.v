//-----------------------------------------------------------------------
// Author : Golovachenko Victor
//
// Description : protocol between I2C/Master & I2C/Slave
//-----------------------------------------------------------------------
`include "i2c_core_master.vh"

module i2c_ov4689 #(
    G_CLK_FREQ = 150000000,
    G_BAUD = 100000
)(
    //I2C
    inout sda_io,
    inout scl_io,

    //CTRL
    input [6:0] dev_adr_i,
    input [15:0] reg_adr_i,
    input [7:0] reg_txd_i,
    output [7:0] reg_rxd_o,
    input start_i,
    input dir_i, //Write = 0 /Read = 1
    output reg err_o,
    output reg busy_o,

    //System
    input clk,
    input rst
);

localparam CI_DIR_WR = 1'b0;

`ifdef SIM_FSM
    enum int unsigned {
        S_IDLE     ,
        S_DAW      ,
        S_DAW_DONE ,
        S_DAB_RD   ,
        S_RA_MSB   ,
        S_RA_LSB   ,
        S_RA_DONE  ,
        S_TXD      ,
        S_TXD_DONE ,
        S_RXD      ,
        S_RXD_DONE ,
        S_RESTART  ,
        S_ERR
    } fsm_pi2c_cs = S_IDLE;
`else
    localparam S_IDLE     =0;
    localparam S_DAW      =1;
    localparam S_DAW_DONE =2;
    localparam S_DAB_RD   =3;
    localparam S_RA_MSB   =4;
    localparam S_RA_LSB   =5;
    localparam S_RA_DONE  =6;
    localparam S_TXD      =7;
    localparam S_TXD_DONE =8;
    localparam S_RXD      =9;
    localparam S_RXD_DONE =10;
    localparam S_RESTART  =11;
    localparam S_ERR      =12;
    reg [3:0] fsm_pi2c_cs = S_IDLE;
`endif

reg [2:0]   core_cmd;
reg         core_start;
wire        core_done;
reg         core_txack;
wire        core_rxack;
reg [7:0]   core_txd;

//-----------------------------------
//Protocol
//-----------------------------------
always @ (posedge clk) begin
    if (rst) begin
        fsm_pi2c_cs <= S_IDLE;

        core_cmd <= 0;
        core_start <= 1'b0;
        core_txack <= 1'b0;
        err_o <= 1'b0;
        busy_o <= 1'b0;

        core_txd <= 0;

    end else begin
        core_start <= 1'b0;

        case (fsm_pi2c_cs)
            //-----------------------------------
            //
            //-----------------------------------
            S_IDLE : begin
                core_cmd <= `C_I2C_MASTER_CORE_IDLE;
                if (start_i) begin
                    busy_o <= 1'b1;
                    err_o <= 1'b0;
                    fsm_pi2c_cs <= S_DAW;
                end
            end

            //-----------------------------------
            //SET ADR DEV + CMD
            //-----------------------------------
            S_DAW : begin
                core_cmd <= `C_I2C_MASTER_CORE_START;
                core_start <= 1'b1;
                fsm_pi2c_cs <= S_DAW_DONE;
            end

            S_DAW_DONE : begin
                if (core_done) begin
                    core_cmd <= `C_I2C_MASTER_CORE_TXBYTE;
                    core_start <= 1'b1;
                    core_txd <= {dev_adr_i, 1'b0}; //ADEV + CMD WR
                    fsm_pi2c_cs <= S_RA_MSB;
                end
            end

            //-----------------------------------
            //SET REG ADR
            //-----------------------------------
            S_RA_MSB : begin
                if (core_done) begin
                    if (!core_rxack) begin
                        core_cmd <= `C_I2C_MASTER_CORE_TXBYTE;
                        core_start <= 1'b1;
                        core_txd <= reg_adr_i[15:8];
                        fsm_pi2c_cs <= S_RA_LSB;
                    end else begin
                        //Bad acknowlege!!!!
                        core_cmd <= `C_I2C_MASTER_CORE_STOP;
                        core_start <= 1'b1;
                        fsm_pi2c_cs <= S_ERR;
                    end
                end
            end

            S_RA_LSB : begin
                if (core_done) begin
                    if (!core_rxack) begin
                        core_cmd <= `C_I2C_MASTER_CORE_TXBYTE;
                        core_start <= 1'b1;
                        core_txd <= reg_adr_i[7:0];
                        fsm_pi2c_cs <= S_RA_DONE;
                    end else begin
                        //Bad acknowlege!!!!
                        core_cmd <= `C_I2C_MASTER_CORE_STOP;
                        core_start <= 1'b1;
                        fsm_pi2c_cs <= S_ERR;
                    end
                end
            end

            S_RA_DONE : begin
                if (core_done) begin
                    if (!core_rxack) begin
                        if (dir_i == CI_DIR_WR) begin
                            //mode REG WRITE
                            core_cmd <= `C_I2C_MASTER_CORE_TXBYTE;
                            core_start <= 1'b1;
                            core_txd <= reg_txd_i;
                            fsm_pi2c_cs <= S_TXD;
                        end else begin
                            //mode REG READ
                            core_cmd <= `C_I2C_MASTER_CORE_RESTART;
                            core_start <= 1'b1;
                            fsm_pi2c_cs <= S_RESTART;
                        end
                    end
                end
            end

            //-----------------------------------
            //SET REG DATA
            //-----------------------------------
            S_TXD : begin
                if (core_done) begin
                    if (!core_rxack) begin
                        core_cmd <= `C_I2C_MASTER_CORE_STOP;
                        core_start <= 1'b1;
                        fsm_pi2c_cs <= S_TXD_DONE;
                    end
                end
            end

            S_TXD_DONE : begin
                if (core_done) begin
                    busy_o <= 1'b0;
                    fsm_pi2c_cs <= S_IDLE;
                end
            end

            //-----------------------------------
            //GET REG DATA
            //-----------------------------------
            S_RESTART : begin
                if (core_done) begin
                    core_cmd <= `C_I2C_MASTER_CORE_TXBYTE;
                    core_start <= 1'b1;
                    core_txd <= {dev_adr_i, 1'b1}; //ADEV + CMD RD
                    fsm_pi2c_cs <= S_DAB_RD;
                end
            end

            S_DAB_RD : begin
                if (core_done) begin
                    if (!core_rxack) begin
                        core_cmd <= `C_I2C_MASTER_CORE_RXBYTE;
                        core_start <= 1'b1;
                        core_txack <= 1'b1;//Terminate Read operation
                        fsm_pi2c_cs <= S_RXD;
                    end else begin
                        //Bad acknowlege!!!!
                        core_cmd <= `C_I2C_MASTER_CORE_STOP;
                        core_start <= 1'b1;
                        fsm_pi2c_cs <= S_ERR;
                    end
                end
            end

            S_RXD : begin
                if (core_done) begin
                    core_cmd <= `C_I2C_MASTER_CORE_STOP;
                    core_start <= 1'b1;
                    fsm_pi2c_cs <= S_RXD_DONE;
                end
            end

            S_RXD_DONE : begin
                core_start <= 1'b0;
                if (core_done) begin
                    busy_o <= 1'b0;
                    core_cmd <= `C_I2C_MASTER_CORE_IDLE;
                    fsm_pi2c_cs <= S_IDLE;
                end
            end

            //-----------------------------------
            //
            //-----------------------------------
            S_ERR : begin
                core_start <= 1'b0;
                if (core_done) begin
                    busy_o <= 1'b0;
                    err_o <= 1'b1;
                    core_cmd <= `C_I2C_MASTER_CORE_IDLE;
                    fsm_pi2c_cs <= S_IDLE;
                end
            end
        endcase
    end
end

i2c_core_master #(
    .G_CLK_FREQ (G_CLK_FREQ),
    .G_BAUD     (G_BAUD)
) m_i2c_core_master (
    .cmd_i   (core_cmd  ),
    .start_i (core_start),
    .done_o  (core_done ),
    .txack_i (core_txack),
    .rxack_o (core_rxack),

    .txd_i   (core_txd),
    .rxd_o   (reg_rxd_o),

    //I2C
    .sda_io (sda_io),
    .scl_io (scl_io),

    //System
    .clk (clk),
    .rst (rst)
);


endmodule
