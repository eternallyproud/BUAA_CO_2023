`timescale 1ns / 1ps
module E_REG(
    input clk,
    input res,
    input E_WE,
    input [31:0] D_command,
    input [31:0] D_PC,
    input [31:0] D_EXT_out,
    input [31:0] D_RD1,
    input [31:0] D_RD2,
    output [31:0] E_command,
    output [31:0] E_PC,
    output [31:0] E_EXT_out,
    output [31:0] E_RD1,
    output [31:0] E_RD2
    );
reg [31:0] PC,command,EXT_out,RD1,RD2;

always @(posedge clk) begin
    if (res == 0) begin
		  if(E_WE) begin
				command <= D_command;
				PC <= D_PC;
				EXT_out <= D_EXT_out;
				RD1 <= D_RD1;
				RD2 <= D_RD2;
		  end
    end
    else begin
        command <= 0;
        PC <= 0;
        EXT_out <= 0;
        RD1 <= 0;
        RD2 <= 0;
    end
end

assign E_command = command;
assign E_PC = PC;
assign E_EXT_out = EXT_out;
assign E_RD1 = RD1;
assign E_RD2 = RD2;

endmodule
