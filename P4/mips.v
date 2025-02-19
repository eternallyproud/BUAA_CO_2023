`timescale 1ns / 1ps
module mips(
   input clk,
   input reset
);
//IFU
wire [31:0] PC_addr;
wire [31:0] PC;
wire [31:0] command;
assign PC_addr = RD1;

//COMMAND
wire [4:0] rs;
wire [4:0] rt;
wire [4:0] rd;
wire [5:0] funct;
wire [5:0] opcode;
wire [15:0] imm15;
wire [25:0] imm25;

//CONTROL
wire [1:0] EXT_op;
wire [1:0] ALU_op;
wire [1:0] PC_op;
wire [0:0] DM_WE;
wire [0:0] GRF_WE;
wire [1:0] GRF_addr;
wire [1:0] GRF_data;
wire [0:0] ALU_src;


//GRF
wire [4:0] A1;
wire [4:0] A2;
wire [4:0] A3;
wire [31:0] RD1;
wire [31:0] RD2;
wire [31:0] WD;
assign A1 = rs;
assign A2 = rt;
assign A3 = (GRF_addr == 0)?rt:
            (GRF_addr == 1)?rd:
            (GRF_addr == 2)?5'b11111:0;
assign WD = (GRF_data == 0)?result:
            (GRF_data == 1)?DM_out:
            (GRF_data == 2)?(PC + 4):0;

//ALU
wire [31:0] A;
wire [31:0] B;
wire [31:0] result;
wire [0:0] zero;
assign A = RD1;
assign B = (ALU_src == 0)?RD2:EXT_out;

//DM
wire [15:0] DM_addr;
wire [31:0] DM_data;
wire [31:0] DM_out;
assign DM_addr = result[15:0];
assign DM_data = RD2;

//EXT
wire [31:0] EXT_out;

IFU IFUuut (
	.res(reset), //input
	.clk(clk), 
	.imm(imm25), 
	.A(PC_addr), 
	.PC_op(PC_op), 
	.zero(zero), 
	.PC(PC), //output
	.command(command)
	);
COMMAND COMMANDuut (
	.command(command), //input
	.rs(rs), //output
	.rt(rt), 
	.rd(rd), 
	.funct(funct), 
	.opcode(opcode), 
	.imm15(imm15), 
	.imm25(imm25)
    );
GRF GRFuut (
	.GRF_WE(GRF_WE), //input
	.res(reset), 
	.clk(clk), 
	.A1(A1), 
	.A2(A2), 
	.A3(A3), 
	.WD(WD), 
	.RD1(RD1), //output
	.RD2(RD2)
    );
ALU ALUuut (
	.A(A), //input
	.B(B), 
	.ALU_op(ALU_op), 
	.result(result), //output
	.zero(zero)
	);
EXT EXTuut (
	.imm(imm15), //input
	.EXT_op(EXT_op), 
	.EXT_out(EXT_out) //output
    );
CONTROL CONTROLuut (
	.opcode(opcode), //input
	.funct(funct), 
	.EXT_op(EXT_op), //output
	.ALU_op(ALU_op), 
	.PC_op(PC_op), 
	.DM_WE(DM_WE), 
	.GRF_WE(GRF_WE), 
	.GRF_addr(GRF_addr), 
	.GRF_data(GRF_data), 
	.ALU_src(ALU_src)
    );
DM DMuut (
	.DM_WE(DM_WE), //input
	.res(reset), 
	.clk(clk), 
	.DM_addr(DM_addr), 
	.DM_data(DM_data), 
	.DM_out(DM_out)//output
    );
wire [31:0] dm_addr;
assign dm_addr = {{16'b0},DM_addr};
always @(posedge clk) begin
	if (reset == 0) begin
		if (GRF_WE) begin
			$display("@%h: $%d <= %h", PC, A3, WD);
		end
		if (DM_WE) begin
			$display("@%h: *%h <= %h", PC, dm_addr, DM_data);
		end
	end
end

endmodule