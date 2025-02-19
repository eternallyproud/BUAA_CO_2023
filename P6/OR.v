`timescale 1ns / 1ps
module OR(
	 input add,
	 input addi,
    input sub,
	 input _and,
	 input andi,
	 input _or,
    input ori,
	 input slt,
	 input sltu,
	 input mult,
	 input multu,
	 input div,
	 input divu,
	 input mfhi,
	 input mflo,
	 input mthi,
	 input mtlo,
    input lw,
	 input lh,
	 input lb,
    input sw,
	 input sh,
	 input sb,
    input beq,
	 input bne,
    input lui,
    input jal,
    input jr,
	 input nop,
	 input [1:0] stage,
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
	 output [2:0] MDU_op,
	 output md,
	 output mf,
	 output mt
);
wire alu,alu_imm,load,save,ls,mdu;
assign alu = alu_imm | alu_R;
assign alu_imm = addi | andi | ori;
assign alu_R = add | sub | _and | _or | slt | sltu;
assign load = lw | lh | lb;
assign save = sw | sh | sb;
assign ls = load | save;
assign br = beq | bne; 
assign mdu = md | mt | mf;

assign EXT_op[0] = addi | ls;
assign EXT_op[1] = lui;
assign ALU_op[0] = sub | _and | andi | sltu;
assign ALU_op[1] = _and | andi | _or | ori;
assign ALU_op[2] = slt | sltu;
assign PC_op[0] = br | jr;
assign PC_op[1] = jal | jr;
assign STR_op[0] = sw | sb;
assign STR_op[1] = sh | sb;
assign LOAD_op[0] = lw | lb;
assign LOAD_op[1] = lh | lb;
assign GRF_WE = alu | load | lui | jal | mf;
assign GRF_addr[0] = alu_R | mf;
assign GRF_addr[1] = jal;
assign GRF_data[0] = load | mfhi;
assign GRF_data[1] = jal | mfhi;
assign GRF_data[2] = mflo;
assign ALU_src = alu_imm | ls | lui;
assign branch[1] = bne;
assign branch[0] = beq;
assign T_use_rs[0] = alu | ls | mdu | lui | jal | nop;
assign T_use_rs[1] = mf | lui | jal | nop;
assign T_use_rt[0] = alu | load | mdu | lui | jal | jr | nop;
assign T_use_rt[1] = alu_imm | ls | mt | mf | lui | jal | jr | nop;
// alu ls md mt mf br lui jal jr nop
//jr j->rs
//lui imm->rt
//ls rs->base;rt->content/target
//11 -> no usage rs:lui/jal/nop rt:ori/lw/jr/nop
assign T_new[0] = (stage == 1)?(alu | lui | mf):
						(stage == 2)?(load):0;
assign T_new[1] = (stage == 1)?(load):0;

assign MDU_op[0] = mult | div | mthi;
assign MDU_op[1] = mult | multu;
assign MDU_op[2] = div | divu;

assign md = mult | multu | div | divu;
assign mf = mfhi | mflo;
assign mt = mthi | mtlo;

endmodule
