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
    output [2:0] ALU_op,
    output [1:0] PC_op,
    output [1:0] STR_op,
	 output [1:0] LOAD_op,
    output [0:0] GRF_WE,
    output [1:0] GRF_addr,
    output [2:0] GRF_data,
    output [0:0] ALU_src,
	 output [1:0] branch,
	 output [1:0] T_use_rs,
	 output [1:0] T_use_rt,
	 output [1:0] T_new,
	 output [4:0] A3,
	 output [4:0] A3_target,
	 output [2:0] MDU_op,
	 output [0:0] CP0_WE,
	 output md,
	 output mf,
	 output mt,
	 output exc_RI,
	 output exc_SYS,
	 output eret,
	 output aluOv,
	 output stOv,
	 output BD,
	 output mtc0
    );

wire [5:0] opcode,funct;
wire nop;
assign nop = (command == 32'b0);

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
	.nop(nop),
	.stage(stage),
	.opcode(opcode), 
	.funct(funct), 
	.rs(rs),
	.rt(rt),
	.rd(rd),
	.EXT_op(EXT_op), 
   .ALU_op(ALU_op), 
	.PC_op(PC_op), 
	.STR_op(STR_op),
	.LOAD_op(LOAD_op), 
	.GRF_WE(GRF_WE),
	.GRF_addr(GRF_addr), 
	.GRF_data(GRF_data), 
	.ALU_src(ALU_src),
	.branch(branch),
	.T_use_rs(T_use_rs),
	.T_use_rt(T_use_rt),
	.T_new(T_new),
	.CP0_WE(CP0_WE),
	.A3(A3),
	.A3_target,
	.MDU_op(MDU_op),
	.md(md),
	.mf(mf),
	.mt(mt),
	.none(exc_RI),
	.sys(exc_SYS),
	.eret(eret),
	.aluOv(aluOv),
	.stOv(stOv),
	.BD(BD),
	.mtc0(mtc0)
	);
endmodule