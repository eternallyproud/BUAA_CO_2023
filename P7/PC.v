`timescale 1ns / 1ps
module PC(
	input clk,
   input res,
	input WE,
	input Req,
	input [31:0] pc,
	output [31:0] PC
);
reg [31:0] regPC;

always @(posedge clk) begin
	if (res == 0 && Req == 0) begin
		if (WE) regPC <= pc;
	end
	else begin
		if (res) regPC <= 32'h0000_3000;//res > Req > stop
		else regPC <= 32'h0000_4180;
	end
end

assign PC = regPC;


endmodule
