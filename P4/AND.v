`timescale 1ns / 1ps
`define add   6'b100000
`define sub   6'b100010
`define ori   6'b001101
`define lw    6'b100011
`define sw    6'b101011
`define beq   6'b000100
`define lui   6'b001111
`define jal   6'b000011
`define jr    6'b001000
`define R     6'b000000
module AND(
    input [5:0] opcode,
    input [5:0] funct,
    output add,
    output sub,
    output ori,
    output lw,
    output sw,
    output beq,
    output lui,
    output jal,
    output jr
    );
assign R = (opcode == `R);
assign add = (funct == `add) & R;
assign sub = (funct == `sub) & R;
assign ori = (opcode == `ori);
assign lw = (opcode == `lw);
assign sw = (opcode == `sw);
assign beq = (opcode == `beq);
assign lui = (opcode == `lui);
assign jal = (opcode == `jal);
assign jr = (funct == `jr) & R;

endmodule