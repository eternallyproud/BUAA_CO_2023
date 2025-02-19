`timescale 1ns / 1ps
module CTR(
    input [31:0] command,
	 input [1:0] stage,//00-D,01-E,10-M,11-W
    output [4:0] rs,
    output [4:0] rt,
    output [4:0] rd,
    output [15:0] imm15,
    output [25:0] imm25,
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

wire [5:0] opcode,funct;
wire [4:0] rt,rd;

COMMAND COMMANDuut (
	.command(command), 
	.rs(rs), 
	.rt(rt), 
	.rd(rd), 
	.funct(funct), 
	.opcode(opcode), 
	.imm15(imm15), 
	.imm25(imm25)
	);
CONTROL CONTROLuut (
	.stage(stage),
	.opcode(opcode), 
	.funct(funct), 
	.rt(rt),
	.rd(rd),
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
	.T_new(T_new),
	.A3(A3),
	.A3_target
	);
endmodule