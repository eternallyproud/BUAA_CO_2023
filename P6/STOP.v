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
    input [4:0] M_A3,
	 input busy,
	 input MD,
    output [0:0] stop
);
wire E_stop_rs,E_stop_rt,M_stop_rs,M_stop_rt;
assign E_stop_rs = (E_A3 == D_rs) && (D_rs != 0) && (E_T_new > T_use_rs);
assign E_stop_rt = (E_A3 == D_rt) && (D_rt != 0) && (E_T_new > T_use_rt);
assign M_stop_rs = (M_A3 == D_rs) && (D_rs != 0) && (M_T_new > T_use_rs);
assign M_stop_rt = (M_A3 == D_rt) && (D_rt != 0) && (M_T_new > T_use_rt);
assign E_stop_MDU = busy & MD;

assign stop = E_stop_rs | E_stop_rt | M_stop_rs | M_stop_rt | E_stop_MDU;

endmodule
