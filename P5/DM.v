`timescale 1ns / 1ps
module DM(
    input DM_WE,
    input res,
    input clk,
    input [15:0] DM_addr,
    input [31:0]DM_data,
    output [31:0]DM_out
);
wire [11:0] addr;
reg [31:0] DM_reg [3071:0];
integer i;

assign addr = DM_addr[15:2];

always @(posedge clk) begin
    if (res == 0) begin
        if (DM_WE) begin
            DM_reg[addr] <= DM_data;
        end
    end
    else begin
        for(i = 0;i < 3072;i = i + 1) begin
            DM_reg[i] <= 0;
        end
    end
end

assign DM_out = DM_reg[addr];

endmodule
