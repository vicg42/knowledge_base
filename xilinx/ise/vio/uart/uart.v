//-----------------------------------------------------------------------
// Author : Golovachenko Victor
//-----------------------------------------------------------------------
module uart (
    output tx,
    input  rx,

    output [7:0] rxdata,
    output       rxdrdy,
    input        rd,

    input  [7:0] txdata,
    output       full,
    input        wr,

    input en_16_x_baud,
    input clk,
    input rst
);

uart_rx6  uart_rx (
    .serial_in           (rx),//input

    .data_out            (rxdata),//output [7:0]
    .buffer_read         (rd),//input
    .buffer_data_present (rxdrdy),//output
    .buffer_half_full    (),//output
    .buffer_full         (),//output
    .buffer_reset        (rst),//input

    .en_16_x_baud        (en_16_x_baud),//input
    .clk                 (clk) //input
);

uart_tx6 uart_tx (
    .serial_out         (tx),//output

    .data_in            (txdata),//input [7:0]
    .buffer_write       (wr),//input
    .buffer_data_present(),//output
    .buffer_half_full   (full),//output
    .buffer_full        (),//output
    .buffer_reset       (rst),//input

    .en_16_x_baud       (en_16_x_baud),//input
    .clk                (clk) //input
);


endmodule
