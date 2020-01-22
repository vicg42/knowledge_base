//-----------------------------------------------------------------------
// Author : Golovachenko Victor
//-----------------------------------------------------------------------
module jtag_reg_wr #(
    parameter RD_OFFSET = 8'd32,
    parameter REG_RD_DATA_WIDTH = 128
)(
    inout [35 : 0] icon_control,
    input [31:0] fifo_data,
    output reg fifo_rd,
    output fr_line_rd,
    output fifo_nrst,
    input fifo_empty,

    //User IF
    input [(REG_RD_DATA_WIDTH - 1):0] reg_rd_data,
    output reg [7:0]  reg_wr_addr = 0,
    output reg [15:0] reg_wr_data = 0,
    output reg        reg_wr_en = 0,
    input             reg_clk,
    input             rst
);

// -------------------------------------------------------------------------

// wire [35 : 0] icon_control0;
// wire [35 : 0] icon_control1;
// icon_dbg icon(
//     .CONTROL0(icon_control0)
// );

wire [15 : 0] sync_in;
wire [7:0] addr;
wire [15:0] wdata;
reg [15:0] rdata = 0;
wire wr;
wire rd;
reg reg_rd_en = 1'b0;
wire cs;
wire fifo_rd_mnl;
vio_dbg vio(
    .CLK(reg_clk),
    .SYNC_IN({fifo_empty, fifo_data[31:0], rdata}),
    .SYNC_OUT({
        fifo_nrst,
        fr_line_rd,
        fifo_rd_mnl,
        rd,
        wr,
        wdata[15:0],
        addr[7:0]
    }), //wire [26 : 0] sync_out;
    .CONTROL(icon_control)
);

reg sr_wr = 1'b0;
reg sr_rd = 1'b0;
reg sr_fifo_rd_mnl = 1'b0;
always @(posedge reg_clk) begin
    reg_wr_addr = addr;
    reg_wr_data = wdata;
    sr_wr <= wr;
    reg_wr_en <= !sr_wr & wr;
    sr_rd <= rd;
    reg_rd_en <= !sr_rd & rd;

    sr_fifo_rd_mnl <= fifo_rd_mnl;
    fifo_rd <= !sr_fifo_rd_mnl & fifo_rd_mnl;
end

always @(posedge reg_clk) begin
    if (reg_rd_en) begin
        rdata <= reg_rd_data[(addr[7:0] * 16) +: 16];
    end
end

// ila_0 ila (
//     .CLK(reg_clk),
//     .TRIG0({
//             rdata[15:0],
//             reg_rd_en,
//             reg_wr_en,
//             reg_wr_data[15:0],
//             reg_wr_addr[7:0]
//     }),
//     .CONTROL(icon_control1)
// );

endmodule