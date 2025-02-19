`timescale 1ns / 1ps
module CONTROL(
    input [5:0] opcode,
    input [5:0] funct,
    output [1:0] EXT_op,
    output [1:0] ALU_op,
    output [1:0] PC_op,
    output [0:0] DM_WE,
    output [0:0] GRF_WE,
    output [1:0] GRF_addr,
    output [1:0] GRF_data,
    output [0:0] ALU_src
);
	wire add;
	wire sub;
	wire ori;
	wire lw;
	wire sw;
	wire beq;
	wire lui;
	wire jal;
	wire jr;
AND ANDuut (
	.opcode(opcode), 
	.funct(funct), 
	.add(add), 
	.sub(sub), 
	.ori(ori), 
	.lw(lw), 
	.sw(sw), 
	.beq(beq), 
	.lui(lui), 
	.jal(jal), 
	.jr(jr)
	);
OR ORuut (
 	.add(add), 
 	.sub(sub), 
 	.ori(ori), 
 	.lw(lw), 
 	.sw(sw), 
 	.beq(beq), 
 	.lui(lui), 
 	.jal(jal), 
 	.jr(jr), 
 	.EXT_op(EXT_op), 
 	.ALU_op(ALU_op), 
 	.PC_op(PC_op), 
 	.DM_WE(DM_WE), 
 	.GRF_WE(GRF_WE), 
 	.GRF_addr(GRF_addr), 
 	.GRF_data(GRF_data), 
 	.ALU_src(ALU_src)
);
endmodule