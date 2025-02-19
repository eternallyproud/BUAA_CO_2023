`timescale 1ns / 1ps
module CONTROL(
    input [5:0] opcode,
    input [5:0] funct,
	 input [1:0] stage,
	 input [4:0] rt,
	 input [4:0] rd,
    output [1:0] EXT_op,
    output [2:0] ALU_op,
    output [1:0] PC_op,
    output [0:0] GRF_WE,
    output [1:0] STR_op,
	 output [1:0] LOAD_op,
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
	 output md,
	 output mf,
	 output mt
);
	wire add;
	wire addi;
	wire sub;
	wire _and;
	wire andi;
	wire _or;
	wire ori;
	wire slt;
	wire sltu;
	wire mult;
	wire multu;
	wire div;
	wire divu;
	wire mfhi;
	wire mflo;
	wire mthi;
	wire mtlo;
	wire lw;
	wire lh;
	wire lb;
	wire sw;
	wire sh;
	wire sb;
	wire beq;
	wire bne;
	wire lui;
	wire jal;
	wire jr;
	wire nop;
AND ANDuut (
	.opcode(opcode), 
	.funct(funct), 
	.add(add),
	.addi(addi),
	.sub(sub), 
	._and(_and),
	.andi(andi),
	._or(_or),
	.ori(ori), 
	.slt(slt),
	.sltu(sltu),
	.mult(mult),
	.multu(multu),
	.div(div),
	.divu(divu),
	.mfhi(mfhi),
	.mflo(mflo),
	.mthi(mthi),
	.mtlo(mtlo),
	.lw(lw), 
	.lh(lh),
	.lb(lb),
	.sw(sw), 
	.sh(sh),
	.sb(sb),
	.beq(beq), 
	.bne(bne),
	.lui(lui), 
	.jal(jal), 
	.jr(jr),
	.nop(nop)
	);
OR ORuut (
	.add(add),
	.addi(addi),
	.sub(sub), 
	._and(_and),
	.andi(andi),
	._or(_or),
	.ori(ori), 
	.slt(slt),
	.sltu(sltu), 
	.mult(mult),
	.multu(multu),
	.div(div),
	.divu(divu),
	.mfhi(mfhi),
	.mflo(mflo),
	.mthi(mthi),
	.mtlo(mtlo),
	.lw(lw), 
	.lh(lh),
	.lb(lb),
	.sw(sw), 
	.sh(sh),
	.sb(sb),
 	.beq(beq),
	.bne(bne),
 	.lui(lui), 
 	.jal(jal), 
 	.jr(jr), 
	.nop(nop),
	.stage(stage),
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
	.MDU_op(MDU_op),
	.md(md),
	.mf(mf),
	.mt(mt)
);
wire enable;
assign enable = (stage == 1)?(jal):
					 (stage == 2)?(add | addi | sub | _and | andi | _or | ori | slt | sltu | mf | lui | jal):
					 (stage == 3)?(add | addi | sub | _and | andi | _or | ori | slt | sltu | mf | lw | lh | lb | lui | jal):0;
assign A3_target = (GRF_addr == 0)?rt:
						 (GRF_addr == 1)?rd:
						 (GRF_addr == 2)?5'b11111:0;
assign A3 = (enable)?A3_target:0;
endmodule