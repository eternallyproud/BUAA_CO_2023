`timescale 1ns / 1ps
module D_REG(
    input clk,
    input res,
    input D_WE,
    input [31:0] F_command,
    input [31:0] F_PC,
	 input [31:0] F_EPC,
	 input [4:0] F_exc,
	 input [0:0] F_BD,
    output [31:0] D_command,
    output [31:0] D_PC,
	 output [31:0] D_EPC,
	 output [4:0] D_exc,
	 output [0:0] D_BD
    );
reg [31:0] PC,EPC,command;
reg [4:0] exc;
reg BD;

always @(posedge clk) begin
    if (res == 0) begin
		  if(D_WE) begin
				command <= F_command;
				PC <= F_PC;
				EPC <= F_EPC;
				exc <= F_exc;
				BD <= F_BD;
		  end
    end
    else begin
        command <= 0;
        PC <= 0;
		  EPC <= 0;
		  exc <= 0;
		  BD <= 0;
    end
end

assign D_command = command;
assign D_PC = PC;
assign D_EPC = EPC;
assign D_exc = exc;
assign D_BD = BD;

endmodule