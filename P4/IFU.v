`timescale 1ns / 1ps
module IFU(
    input res,
    input clk,
    input [25:0] imm,
    input [31:0] A,
    input [1:0] PC_op,
    input zero,
    output [31:0] PC,
    output [31:0] command
);
wire [31:0] wirePC,wirepc,addr;
reg [31:0] IM[4095:0];
PC PCuut (
	.clk(clk), 
	.res(res), 
	.pc(wirepc), 
	.PC(wirePC)
);
NPC NPCuut (
	.PC(wirePC), 
	.imm(imm), 
	.A(A), 
	.PC_op(PC_op), 
	.zero(zero), 
	.NPC(wirepc)
	);
assign addr = wirePC - 32'h3000;
assign PC = wirePC;
assign command = IM[addr[13:2]];

initial begin
    $readmemh("code.txt", IM);
end

endmodule
