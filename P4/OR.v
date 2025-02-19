`timescale 1ns / 1ps
module OR(
    input add,
    input sub,
    input ori,
    input lw,
    input sw,
    input beq,
    input lui,
    input jal,
    input jr,
    output [1:0] EXT_op,
    output [1:0] ALU_op,
    output [1:0] PC_op,
    output [0:0] DM_WE,
    output [0:0] GRF_WE,
    output [1:0] GRF_addr,
    output [1:0] GRF_data,
    output [0:0] ALU_src
);
assign EXT_op[0] = lw | sw;
assign EXT_op[1] = lui;
assign ALU_op[0] = sub | beq;
assign ALU_op[1] = ori;
assign PC_op[0] = beq | jr;
assign PC_op[1] = jal | jr;
assign DM_WE = sw;
assign GRF_WE = add | sub | ori | lw | lui | jal;
assign GRF_addr[0] = add | sub;
assign GRF_addr[1] = jal;
assign GRF_data[0] = lw;
assign GRF_data[1] = jal;
assign ALU_src = ori | lw | sw | lui;

endmodule
