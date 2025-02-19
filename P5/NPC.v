`timescale 1ns / 1ps
module NPC(
	input [31:0] PC,
    input [25:0] imm,
    input [31:0] A,
    input [1:0] PC_op,
    input zero,
    output [31:0] NPC
);
wire [31:0] OP0,OP1,OP2,OP3,ADD;
assign OP0 = PC + 4;
assign OP1 = zero?(ADD+OP0):OP0;
assign OP2 = {PC[31:28],imm,2'b00};
assign OP3 = A;
assign ADD = {{14{imm[15]}},imm[15:0],2'b00};
assign NPC = (PC_op==0)?OP0:
             (PC_op==1)?OP1:
             (PC_op==2)?OP2:
                        OP3;

endmodule
