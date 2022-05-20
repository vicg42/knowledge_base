`timescale 1ns / 1ns

module main_tb #(
    parameter PIXEL_WIDTH = 8
);

real a00_real = 0.299;
real a01_real = 0.587;
real a02_real = 0.114;

real a10_real = -0.169;
real a11_real = -0.331;
real a12_real =  0.5  ;

real a20_real =  0.5  ;
real a21_real = -0.419;
real a22_real = -0.081;

reg signed [15:0] rgb2ycbcr_a00 = int'(a00_real * 1024);
reg signed [15:0] rgb2ycbcr_a01 = int'(a01_real * 1024);
reg signed [15:0] rgb2ycbcr_a02 = int'(a02_real * 1024);

reg signed [15:0] rgb2ycbcr_a10 = int'(a10_real * 1024);
reg signed [15:0] rgb2ycbcr_a11 = int'(a11_real * 1024);
reg signed [15:0] rgb2ycbcr_a12 = int'(a12_real * 1024);

reg signed [15:0] rgb2ycbcr_a20 = int'(a20_real * 1024);
reg signed [15:0] rgb2ycbcr_a21 = int'(a21_real * 1024);
reg signed [15:0] rgb2ycbcr_a22 = int'(a22_real * 1024);

reg signed [15:0] rgb2ycbcr_c0  =  15'd0  ; //  0
reg signed [15:0] rgb2ycbcr_c1  =  (2**PIXEL_WIDTH)/2; //  128
reg signed [15:0] rgb2ycbcr_c2  =  (2**PIXEL_WIDTH)/2; //  128

bit clk = 0;          // simple clock
always #5 clk = ~clk; // 100 MHz

dut_if dut_if_h(clk); // connect clk to dut_if.clk

rgb_2_ycbcr #(
    .PIXEL_WIDTH(PIXEL_WIDTH),
    .BYPASS_WIDTH(8)
) dut (
    .CI_A00 (rgb2ycbcr_a00),
    .CI_A01 (rgb2ycbcr_a01),
    .CI_A02 (rgb2ycbcr_a02),

    .CI_A10 (rgb2ycbcr_a10),
    .CI_A11 (rgb2ycbcr_a11),
    .CI_A12 (rgb2ycbcr_a12),

    .CI_A20 (rgb2ycbcr_a20),
    .CI_A21 (rgb2ycbcr_a21),
    .CI_A22 (rgb2ycbcr_a22),

    .CI_C0  (rgb2ycbcr_c0) ,
    .CI_C1  (rgb2ycbcr_c1) ,
    .CI_C2  (rgb2ycbcr_c2) ,

    .r_i  (dut_if_h.r_i),
    .g_i  (dut_if_h.g_i),
    .b_i  (dut_if_h.b_i),
    .de_i (dut_if_h.de_i),
    .hs_i (dut_if_h.hs_i),
    .vs_i (dut_if_h.vs_i),
    .bypass_i({8{1'b0}}),

    .y_o  (dut_if_h.y_o),
    .cb_o (dut_if_h.cb_o),
    .cr_o (dut_if_h.cr_o),
    .de_o (dut_if_h.de_o),
    .hs_o (dut_if_h.hs_o),
    .vs_o (dut_if_h.vs_o),
    .bypass_o(),

    .clk (dut_if_h.clk)
);

initial begin

end


endmodule