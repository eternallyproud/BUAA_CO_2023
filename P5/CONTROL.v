`timescale 1ns / 1ps
module CONTROL(
    input [5:0] opcode,
    input [5:0] funct,
	 input [1:0] stage,
	 input [4:0] rt,
	 input [4:0] rd,
    output [1:0] EXT_op,
    output [1:0] ALU_op,
    output [1:0] PC_op,
    output [0:0] DM_WE,
    output [0:0] GRF_WE,
    output [1:0] GRF_addr,
    output [1:0] GRF_data,
    output [0:0] ALU_src,
	 output [1:0] T_use_rs,
	 output [1:0] T_use_rt,
	 output [1:0] T_new,
	 output [4:0] A3,
	 output [4:0] A3_target
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
	wire nop;
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
	.jr(jr),
	.nop(nop)
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
	.nop(nop),
	.stage(stage),
 	.EXT_op(EXT_op), 
 	.ALU_op(ALU_op), 
 	.PC_op(PC_op), 
 	.DM_WE(DM_WE), 
 	.GRF_WE(GRF_WE), 
 	.GRF_addr(GRF_addr), 
 	.GRF_data(GRF_data), 
 	.ALU_src(ALU_src),
	.T_use_rs(T_use_rs),
	.T_use_rt(T_use_rt),
	.T_new(T_new)
);
wire enable;
assign enable = (stage == 1)?(jal):
					 (stage == 2)?(add | sub | ori | lui | jal):
					 (stage == 3)?(add | sub | ori | lw | lui | jal):0;
assign A3_target = (GRF_addr == 0)?rt:
						 (GRF_addr == 1)?rd:
						 (GRF_addr == 2)?5'b11111:0;
assign A3 = (enable)?A3_target:0;
endmodule