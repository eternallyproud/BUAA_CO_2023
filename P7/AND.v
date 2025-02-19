`timescale 1ns / 1ps
`define add   6'b100000
`define addi  6'b001000
`define sub   6'b100010
`define _and  6'b100100
`define andi  6'b001100 
`define _or   6'b100101
`define ori   6'b001101
`define slt   6'b101010
`define sltu  6'b101011
`define mult  6'b011000
`define multu 6'b011001
`define div   6'b011010
`define divu  6'b011011
`define mfhi  6'b010000
`define mflo  6'b010010
`define mthi  6'b010001
`define mtlo  6'b010011
`define lw    6'b100011
`define lh    6'b100001
`define lb    6'b100000
`define sw    6'b101011
`define sh	  6'b101001
`define sb    6'b101000 
`define beq   6'b000100
`define bne   6'b000101 
`define lui   6'b001111
`define jal   6'b000011
`define jr    6'b001000
`define R     6'b000000
`define eret  6'b011000
`define sys   6'b001100
`define COP0  6'b010000

`define mfc0  5'b00000
`define mtc0  5'b00100

module AND(
    input [5:0] opcode,
	 input [4:0] rs,
    input [5:0] funct,
    output add,
	 output addi,
    output sub,
	 output _and,
	 output andi,
	 output _or,
    output ori,
	 output slt,
	 output sltu,
	 output mult,
	 output multu,
	 output div,
	 output divu,
	 output mfhi,
	 output mflo,
	 output mthi,
	 output mtlo,
    output lw,
	 output lh,
	 output lb,
    output sw,
	 output sh,
	 output sb,
    output beq,
	 output bne,
    output lui,
    output jal,
    output jr,
	 output eret,
	 output sys,
	 output mfc0,
	 output mtc0
    );
assign COP0 = (opcode == `COP0);
assign R = (opcode == `R);
assign add = (funct == `add) & R;
assign addi = (opcode == `addi);
assign sub = (funct == `sub) & R;
assign _and = (funct == `_and) & R;
assign andi = (opcode == `andi);
assign _or = (funct == `_or) & R;
assign ori = (opcode == `ori);
assign slt = (funct == `slt) & R;
assign sltu = (funct == `sltu) & R;
assign mult = (funct == `mult) & R;
assign multu = (funct == `multu) & R;
assign div = (funct == `div) & R;
assign divu = (funct == `divu) & R;
assign mfhi = (funct == `mfhi) & R;
assign mflo = (funct == `mflo) & R;
assign mthi = (funct == `mthi) & R;
assign mtlo = (funct == `mtlo) & R;
assign lw = (opcode == `lw);
assign lh = (opcode == `lh);
assign lb = (opcode == `lb);
assign sw = (opcode == `sw);
assign sh = (opcode == `sh);
assign sb = (opcode == `sb);
assign beq = (opcode == `beq);
assign bne = (opcode == `bne);
assign lui = (opcode == `lui);
assign jal = (opcode == `jal);
assign jr = (funct == `jr) & R;
assign sys = (funct == `sys) & R;
assign eret = COP0 & (funct == `eret);
assign mfc0 = COP0 & (rs == `mfc0);
assign mtc0 = COP0 & (rs == `mtc0);

endmodule