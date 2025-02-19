`timescale 1ns / 1ps
module EXT(
    input [15:0] imm,
    input [1:0] EXT_op,
    output [31:0] EXT_out
);
assign EXT_out = (EXT_op == 0)?{{16'b0},imm}:
                 (EXT_op == 1)?{{16{imm[15]}},imm}:
                 (EXT_op == 2)?{imm,16'b0}:0;

endmodule