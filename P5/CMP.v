`timescale 1ns / 1ps
module CMP(
    input [31:0] RD1,
    input [31:0] RD2,
    input [1:0] PC_op,
    output zero
);

assign zero = ((PC_op == 1)&(RD1 == RD2))? 1:0;

endmodule