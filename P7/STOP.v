`timescale 1ns / 1ps
module STOP(
    input [1:0] T_use_rs,
    input [1:0] T_use_rt,
    input [1:0] E_T_new,
    input [1:0] M_T_new,
    input [1:0] W_T_new,
    input [4:0] D_rs,
    input [4:0] D_rt,
    input [4:0] E_A3,
	 input [4:0] E_rd,
    input [4:0] M_A3,
	 input [4:0] M_rd,
	 input busy,
	 input MD,
	 input D_eret,
	 input E_mtc0,
	 input M_mtc0,
    output [0:0] stop
);
wire E_stop_rs,E_stop_rt,M_stop_rs,M_stop_rt,D_stop_eret;
assign E_stop_rs = (E_A3 == D_rs) && (D_rs != 0) && (E_T_new > T_use_rs);
assign E_stop_rt = (E_A3 == D_rt) && (D_rt != 0) && (E_T_new > T_use_rt);
assign M_stop_rs = (M_A3 == D_rs) && (D_rs != 0) && (M_T_new > T_use_rs);
assign M_stop_rt = (M_A3 == D_rt) && (D_rt != 0) && (M_T_new > T_use_rt);
assign E_stop_MDU = busy & MD;
assign D_stop_eret = (D_eret) && ((E_mtc0 && E_rd == 5'd14) || (M_mtc0 && M_rd == 5'd14));


assign stop = E_stop_rs | E_stop_rt | M_stop_rs | M_stop_rt | E_stop_MDU | D_stop_eret;

endmodule
