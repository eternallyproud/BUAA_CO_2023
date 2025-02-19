`timescale 1ns / 1ps
module ALU(
	input aluOv,
	input stOv,
   input [31:0] A,
   input [31:0] B,
   input [2:0] ALU_op,
   output [31:0] result,
	output exc_aluOv,
	output exc_stOv
);
assign result = (ALU_op == 0)? (A + B):
                (ALU_op == 1)? (A - B):
                (ALU_op == 2)? (A | B):
                (ALU_op == 3)? (A & B):
					 (ALU_op == 4)? {{31'b0},{($signed(A) < $signed(B))}}:
					 (ALU_op == 5)? {{31'b0},{{1'b0},A}<{{1'b0},B}}: 0;

wire [32:0] ext_A,ext_B,ext_add,ext_sub;
assign ext_A = {A[31], A};
assign ext_B = {B[31], B};

assign ext_add = ext_A + ext_B;
assign ext_sub = ext_A - ext_B;
assign exc_aluOv = (aluOv) & 
                   (((ALU_op == 0) & (ext_add[32] != ext_add[31])) |
                    ((ALU_op == 1) & (ext_sub[32] != ext_sub[31])));
assign exc_stOv = (stOv) & ((ALU_op == 0) & (ext_add[32] != ext_add[31])) ;
endmodule
