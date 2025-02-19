`timescale 1ns / 1ps
module E_REG(
    input clk,
    input res,
	 input stop,
    input E_WE,
    input [31:0] D_command,
    input [31:0] D_PC,
	 input [31:0] D_EPC,
    input [31:0] D_EXT_out,
    input [31:0] D_RD1,
    input [31:0] D_RD2,
	 input [4:0] D_exc,
	 input [0:0] D_BD,
    output [31:0] E_command,
    output [31:0] E_PC,
	 output [31:0] E_EPC,
    output [31:0] E_EXT_out,
    output [31:0] E_RD1,
    output [31:0] E_RD2,
	 output [4:0] E_exc,
	 output [0:0] E_BD
    );
reg [31:0] PC,EPC,command,EXT_out,RD1,RD2;
reg [4:0] exc;
reg BD;

always @(posedge clk) begin
    if ((res == 0) && (stop == 0)) begin
		  if(E_WE) begin
				command <= D_command;
				PC <= D_PC;
				EPC <= D_EPC;
				EXT_out <= D_EXT_out;
				RD1 <= D_RD1;
				RD2 <= D_RD2;
				exc <= D_exc;
				BD <= D_BD;
		  end
    end
    else begin
        command <= 0;
		  if (res) begin
		      PC <= 0;
				EPC <= 0;
				BD <= 0;
		  end
		  else begin
		      PC <= D_PC;
				EPC <= D_EPC;
				BD <= D_BD;
		  end
        EXT_out <= 0;
        RD1 <= 0;
        RD2 <= 0;
		  exc <= 0;
    end
end

assign E_command = command;
assign E_PC = PC;
assign E_EPC = EPC;
assign E_EXT_out = EXT_out;
assign E_RD1 = RD1;
assign E_RD2 = RD2;
assign E_exc = exc;
assign E_BD = BD;

endmodule
