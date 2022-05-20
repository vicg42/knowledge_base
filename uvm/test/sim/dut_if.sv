//
interface dut_if (input bit     clk);
    bit [7:0] r_i;
    bit [7:0] g_i;
    bit [7:0] b_i;
    bit de_i;
    bit hs_i;
    bit vs_i;

    bit [7:0] y_o;
    bit [7:0] cb_o;
    bit [7:0] cr_o;
    bit de_o;
    bit hs_o;
    bit vs_o;

endinterface