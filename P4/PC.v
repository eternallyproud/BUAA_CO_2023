`timescale 1ns / 1ps
module PC(
	input clk,
   input res,
	input [31:0] pc,
	output [31:0] PC
);
reg [31:0] regPC;

always @(posedge clk) begin
	if (res == 0) begin
		regPC <= pc;
	end
	else begin
		regPC <= 0;
	end
end

assign PC = (regPC == 0)? 32'h3000:regPC;


endmodule
