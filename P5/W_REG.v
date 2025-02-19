`timescale 1ns / 1ps
module W_REG(
    input clk,
    input res,
    input W_WE,
    input [31:0] M_command,
    input [31:0] M_PC,
    input [31:0] M_DM_out,
    input [31:0] M_ALU_result,
    output [31:0] W_command,
    output [31:0] W_PC,
    output [31:0] W_DM_out,
    output [31:0] W_ALU_result
    );
reg [31:0] PC,command,DM_out,ALU_result;

always @(posedge clk) begin
    if (res == 0) begin
		  if (W_WE) begin
				command <= M_command;
				PC <= M_PC;
				DM_out <= M_DM_out;
				ALU_result <= M_ALU_result;
		  end
    end
    else begin
        command <= 0;
        PC <= 0;
        DM_out <= 0;
        ALU_result <= 0;
    end
end

assign W_command = command;
assign W_PC = PC;
assign W_DM_out = DM_out;
assign W_ALU_result = ALU_result;

endmodule