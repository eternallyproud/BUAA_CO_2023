`timescale 1ns / 1ps
module M_REG(
    input clk,
    input res,
    input M_WE,
    input [31:0] E_command,
    input [31:0] E_PC,
	 input [31:0] E_EPC,
    input [31:0] E_EXT_out,
    input [31:0] E_ALU_result,
    input [31:0] E_RD2,
	 input [31:0] E_HI,
	 input [31:0] E_LO,
	 input [0:0] E_exc_stOv,
	 input [4:0] E_exc,
	 input [0:0] E_BD,
    output [31:0] M_command,
    output [31:0] M_PC,
	 output [31:0] M_EPC,
    output [31:0] M_EXT_out,
    output [31:0] M_ALU_result,
    output [31:0] M_RD2,
	 output [31:0] M_HI,
	 output [31:0] M_LO,
	 output [0:0] M_exc_stOv,
	 output [4:0] M_exc,
	 output [0:0] M_BD
    );
reg [31:0] PC,EPC,command,EXT_out,ALU_result,RD2,HI,LO;
reg [4:0] exc;
reg [0:0] exc_stOv,BD;

always @(posedge clk) begin
    if (res == 0) begin
		  if (M_WE) begin
				command <= E_command;
				PC <= E_PC;
				EPC <= E_EPC;
				EXT_out <= E_EXT_out;
				ALU_result <= E_ALU_result;
				RD2 <= E_RD2;
				HI <= E_HI;
				LO <= E_LO;
				exc <= E_exc;
				exc_stOv <= E_exc_stOv;
				BD <= E_BD;
		  end
    end
    else begin
        command <= 0;
        PC <= 0;
		  EPC <= 0;
        EXT_out <= 0;
        ALU_result <= 0;
        RD2 <= 0;
		  HI <= 0;
		  LO <= 0;
		  exc <= 0;
		  exc_stOv <= 0;
		  BD <= 0;
    end
end

assign M_command = command;
assign M_PC = PC;
assign M_EPC = EPC;
assign M_EXT_out = EXT_out;
assign M_ALU_result = ALU_result;
assign M_RD2 = RD2;
assign M_HI = HI;
assign M_LO = LO;
assign M_exc = exc;
assign M_exc_stOv = exc_stOv;
assign M_BD = BD;
endmodule