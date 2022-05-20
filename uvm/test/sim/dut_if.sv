//
interface dut_if #(parameter PIXEL_WIDTH = 8) (input bit clk);

    bit [PIXEL_WIDTH-1:0] r_i;
    bit [PIXEL_WIDTH-1:0] g_i;
    bit [PIXEL_WIDTH-1:0] b_i;
    bit de_i;
    bit hs_i;
    bit vs_i;

    bit [PIXEL_WIDTH-1:0] y_o;
    bit [PIXEL_WIDTH-1:0] cb_o;
    bit [PIXEL_WIDTH-1:0] cr_o;
    bit de_o;
    bit hs_o;
    bit vs_o;

endinterface