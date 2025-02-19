`timescale 1ns / 1ps
module COMMAND(
    input [31:0] command,
    output [4:0] rs,
    output [4:0] rt,
    output [4:0] rd,
    output [5:0] funct,
    output [5:0] opcode,
    output [15:0] imm15,
    output [25:0] imm25
);
assign rs = command[25:21];
assign rt = command[20:16];
assign rd = command[15:11];
assign funct = command[5:0];
assign opcode = command[31:26];
assign imm15 = command[15:0];
assign imm25 = command[25:0];

endmodule
