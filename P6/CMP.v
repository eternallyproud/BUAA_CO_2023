`timescale 1ns / 1ps
module CMP(
    input [31:0] RD1,
    input [31:0] RD2,
    input [1:0] PC_op,
	 input [1:0] branch,
    output zero
);
wire beq,bne;
assign beq = (branch == 1)&(RD1 == RD2);
assign bne = (branch == 2)&(RD1 != RD2);
assign zero = (PC_op == 1)&(beq | bne);
endmodule