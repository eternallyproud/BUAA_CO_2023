`timescale 1ns / 1ps
module D_REG(
    input clk,
    input res,
    input D_WE,
    input [31:0] F_command,
    input [31:0] F_PC,
    output [31:0] D_command,
    output [31:0] D_PC
    );
reg [31:0] PC,command;

always @(posedge clk) begin
    if (res == 0) begin
		  if(D_WE) begin
				command <= F_command;
				PC <= F_PC;
		  end
    end
    else begin
        command <= 0;
        PC <= 0;
    end
end

assign D_command = command;
assign D_PC = PC;

endmodule