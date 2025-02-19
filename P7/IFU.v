`timescale 1ns / 1ps
module IFU(
    input res,
    input clk,
    input [31:0] NPC,
	 input [0:0] PC_WE,
	 input Req,
    output [31:0] PC,
    output [31:0] command
);
wire [31:0] wirePC,wirepc,addr;
reg [31:0] IM[4095:0];
PC PCuut (
	.clk(clk), 
	.res(res), 
	.Req(Req),
	.pc(NPC), 
	.PC(wirePC),
	.WE(PC_WE)
);
assign addr = wirePC - 32'h3000;
assign PC = wirePC;
assign command = IM[addr[13:2]];

initial begin
    $readmemh("code.txt", IM);
end

endmodule
