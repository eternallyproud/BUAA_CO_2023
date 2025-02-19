`timescale 1ns / 1ps
module ALU(
    input [31:0] A,
    input [31:0] B,
    input [1:0] ALU_op,
    output [31:0] result,
    output [0:0] zero
);
assign result = (ALU_op == 0)? (A + B):
                (ALU_op == 1)? (A - B):
                (ALU_op == 2)? (A | B):
                               0;
assign zero = (A == B);


endmodule
