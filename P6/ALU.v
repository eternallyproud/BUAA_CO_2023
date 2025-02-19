`timescale 1ns / 1ps
module ALU(
    input [31:0] A,
    input [31:0] B,
    input [2:0] ALU_op,
    output [31:0] result
);
assign result = (ALU_op == 0)? (A + B):
                (ALU_op == 1)? (A - B):
                (ALU_op == 2)? (A | B):
                (ALU_op == 3)? (A & B):
					 (ALU_op == 4)? {{31'b0},{($signed(A) < $signed(B))}}:
					 (ALU_op == 5)? {{31'b0},{{1'b0},A}<{{1'b0},B}}: 0;

endmodule
