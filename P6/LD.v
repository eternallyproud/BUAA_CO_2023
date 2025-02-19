`timescale 1ns / 1ps
module LOAD(
	input [31:0] data,
	inout [15:0] addr,
	input [1:0] LOAD_op,
	output [31:0] LOAD_out
);

assign LOAD_out = (LOAD_op == 1) ? data :
				  (LOAD_op == 2) ? ((addr[1] == 1) ? {{16{data[31]}},data[31:16]} : {{16{data[15]}},data[15:0]}) : 
				  (LOAD_op == 3) ? ((addr[1:0] == 3) ? {{24{data[31]}},data[31:24]} :
				  					(addr[1:0] == 2) ? {{24{data[23]}},data[23:16]} :
									(addr[1:0] == 1) ? {{24{data[15]}},data[15:8]} :
				  					(addr[1:0] == 0) ? {{24{data[7]}},data[7:0]} : 0) : 0;

endmodule
