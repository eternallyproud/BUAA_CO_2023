`timescale 1ns / 1ps
module PC(
	input clk,
   input res,
	input WE,
	input [31:0] pc,
	output [31:0] PC
);
reg [31:0] regPC;

always @(posedge clk) begin
	if (res == 0) begin
		if (WE) regPC <= pc;
	end
	else begin
		regPC <= 32'h3000;
	end
end

assign PC = regPC;


endmodule
