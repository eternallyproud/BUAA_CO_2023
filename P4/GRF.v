`timescale 1ns / 1ps
module GRF(
    input GRF_WE,
    input res,
    input clk,
    input [4:0] A1,
    input [4:0] A2,
    input [4:0] A3,
    input [31:0] WD,
    output [31:0] RD1,
    output [31:0] RD2

);
reg [31:0] REG [31:1];
integer i;

always @(posedge clk) begin
    if(res == 0) begin
        if(GRF_WE) begin
            REG[A3] <= WD;
        end
    end
    else begin
        for(i = 1;i < 32;i = i + 1) begin
            REG[i] <= 0;
        end
    end
end

assign RD1 = (A1 == 0) ? 32'b0 : REG[A1];
assign RD2 = (A2 == 0) ? 32'b0 : REG[A2];

endmodule
