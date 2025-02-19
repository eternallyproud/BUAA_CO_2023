`timescale 1ns / 1ps
module mips(
   input clk,
   input reset
);
//stop
wire stop;
//forward
wire [31:0] D_Forward_RD2,D_Forward_RD1,E_Forward_RD2,E_Forward_RD1,M_Forward_RD2;
//****************************** F ******************************
//IFU
wire [31:0] F_NPC;
wire [31:0] F_PC;
wire [31:0] F_command;
wire PC_WE;
assign F_NPC = (D_zero === 1) ?(D_PC + 4 + {{14{D_imm15[15]}},D_imm15,2'b00})://beq
               (D_PC_op === 2)?({D_PC[31:28],D_imm25,2'b00})://jal
               (D_PC_op === 3)?(D_Forward_RD1)://jr
               (F_PC + 4);//???
assign PC_WE = (stop == 0); 
IFU IFUuut (
	.res(reset), //input
	.clk(clk), 
	.NPC(F_NPC),
    .PC_WE(PC_WE),
	.PC(F_PC), //output
	.command(F_command)
	);

//****************************** D ******************************
wire D_WE;
assign D_WE = (stop == 0);
wire [31:0] D_PC;
wire [31:0] D_command;
//D_REG
D_REG D (
	.clk(clk), //input
	.res(reset), //delay branching will carry out the next command anyway!
	.F_command(F_command), 
	.F_PC(F_PC), 
    .D_WE(D_WE), 
	.D_command(D_command),//output 
	.D_PC(D_PC)
	);
//D_CTR
wire [4:0] D_rs,D_rt;
wire [15:0] D_imm15;
wire [25:0] D_imm25;
wire [1:0] D_EXT_op,D_PC_op;
wire [1:0] T_use_rs,T_use_rt;
CTR D_CTR (
    .stage(2'b00), //input
	.command(D_command),
	.rs(D_rs), //output
	.rt(D_rt), 
	.imm15(D_imm15), 
	.imm25(D_imm25), 
	.EXT_op(D_EXT_op),
    .PC_op(D_PC_op),
    .T_use_rs(T_use_rs),
    .T_use_rt(T_use_rt)
	);
//GRF
wire [4:0] D_A1;
wire [4:0] D_A2;
wire [31:0] D_RD1;
wire [31:0] D_RD2;
assign D_A1 = D_rs;
assign D_A2 = D_rt;
//CMP
wire D_zero;
CMP CMPuut (
    .RD1(D_Forward_RD1),
    .RD2(D_Forward_RD2),
    .PC_op(D_PC_op),
    .zero(D_zero)
    );
wire W_GRF_WE;//W!!!
wire [4:0] W_A3;
wire [31:0] W_WD;
GRF GRFuut (
	.GRF_WE(W_GRF_WE), //input
	.res(reset), 
	.clk(clk), 
	.A1(D_A1), 
	.A2(D_A2), 
	.A3(W_A3), 
	.WD(W_WD), 
	.RD1(D_RD1), //output
	.RD2(D_RD2)
    );
wire [31:0] D_EXT_out;
EXT EXTuut (
	.imm(D_imm15), //input
	.EXT_op(D_EXT_op), 
	.EXT_out(D_EXT_out) //output
    );
//****************************** E ******************************
wire E_WE;
assign E_WE = 1;//???
wire [31:0] E_PC;
wire [31:0] E_command;
wire [31:0] E_EXT_out;
wire [31:0] E_RD1,E_RD2,E_WD;
//E_REG
E_REG E (
	.clk(clk), 
	.res(reset|stop), //clear when stopped
	.E_WE(E_WE), 
	.D_command(D_command), 
	.D_PC(D_PC), 
	.D_EXT_out(D_EXT_out), 
	.D_RD1(D_Forward_RD1), 
	.D_RD2(D_Forward_RD2), 
	.E_command(E_command), 
	.E_PC(E_PC), 
	.E_EXT_out(E_EXT_out), 
	.E_RD1(E_RD1), 
	.E_RD2(E_RD2)
	);
//E_CRT
wire E_ALU_src;
wire [1:0] E_ALU_op,E_T_new,E_GRF_data;
wire [4:0] E_rs,E_rt,E_A3,E_A3_target;
CTR E_CTR (
    .stage(2'b01),
	.command(E_command), 
	.ALU_op(E_ALU_op), 
    .GRF_data(E_GRF_data),
	.ALU_src(E_ALU_src),
    .T_new(E_T_new),
    .A3(E_A3),
    .A3_target(E_A3_target),
    .rs(E_rs),
    .rt(E_rt)
	);
//ALU
wire [31:0] E_A;
wire [31:0] E_B;
wire [31:0] E_ALU_result;
assign E_A = E_Forward_RD1;
assign E_B = (E_ALU_src == 0)?E_Forward_RD2:E_EXT_out;
ALU ALUuut (
	.A(E_A), //input
	.B(E_B), 
	.ALU_op(E_ALU_op), 
	.result(E_ALU_result) //output
	);
assign E_WD = (E_GRF_data == 2)?(E_PC + 8):0;
//****************************** M ******************************
wire M_WE;
assign M_WE = 1;//???
wire [31:0] M_PC;
wire [31:0] M_command;
wire [31:0] M_EXT_out;
wire [31:0] M_ALU_result;
wire [31:0] M_RD2,M_WD;
//M_REG
M_REG M (
	.clk(clk), 
	.res(reset), 
	.M_WE(M_WE), 
	.E_command(E_command), 
	.E_PC(E_PC), 
	.E_EXT_out(E_EXT_out), 
	.E_ALU_result(E_ALU_result), 
	.E_RD2(E_Forward_RD2), 
	.M_command(M_command), 
	.M_PC(M_PC), 
	.M_EXT_out(M_EXT_out), 
	.M_ALU_result(M_ALU_result), 
	.M_RD2(M_RD2)
	);
//M_CRT
wire M_DM_WE;
wire [1:0] M_T_new,M_GRF_data;
wire [4:0] M_rs,M_rt,M_A3,M_A3_target;
CTR M_CRT (
    .stage(2'b10),
	.command(M_command), 
	.DM_WE(M_DM_WE),
    .T_new(M_T_new),
    .GRF_data(M_GRF_data),
    .A3(M_A3),
    .A3_target(M_A3_target),
    .rs(M_rs),
    .rt(M_rt)
	);
//DM
wire [15:0] M_DM_addr;
wire [31:0] M_DM_data;
wire [31:0] M_DM_out;
assign M_DM_addr = M_ALU_result[15:0];
assign M_DM_data = M_Forward_RD2;
DM DMuut (
	.DM_WE(M_DM_WE), //input
	.res(reset), 
	.clk(clk), 
	.DM_addr(M_DM_addr), 
	.DM_data(M_DM_data), 
	.DM_out(M_DM_out)//output
    );
assign M_WD = (M_GRF_data == 0)?M_ALU_result:
              (M_GRF_data == 2)?(M_PC + 8):0;
//****************************** W ******************************
wire W_WE;
assign W_WE = 1;//???
wire [31:0] W_PC;
wire [31:0] W_command;
wire [31:0] W_ALU_result;
wire [31:0] W_DM_out;
wire [1:0] W_GRF_addr,W_GRF_data;
wire [4:0] W_rt,W_rd;
W_REG W (
	.clk(clk), 
	.res(reset), 
	.W_WE(W_WE), 
    .M_command(M_command), 
	.M_PC(M_PC), 
	.M_DM_out(M_DM_out), 
	.M_ALU_result(M_ALU_result), 
	.W_command(W_command), 
	.W_PC(W_PC), 
	.W_DM_out(W_DM_out), 
	.W_ALU_result(W_ALU_result)
	);
wire [1:0] W_T_new;
CTR W_CTR (
    .stage(2'b11),
	.command(W_command), 
	.GRF_WE(W_GRF_WE), 
	.GRF_data(W_GRF_data),
    .T_new(W_T_new),
    .A3(W_A3)
	);

assign W_WD = (W_GRF_data == 0)?W_ALU_result:
              (W_GRF_data == 1)?W_DM_out:
              (W_GRF_data == 2)?(W_PC + 8):0;//???


wire [31:0] dm_addr;
assign dm_addr = {{16'b0},M_DM_addr};
always @(posedge clk) begin
	if (reset == 0) begin
		if (W_GRF_WE) begin
			$display("@%h: $%d <= %h", W_PC, W_A3, W_WD);
		end
		if (M_DM_WE) begin
			$display("@%h: *%h <= %h", M_PC, dm_addr, M_DM_data);
		end
	end
end
//****************************** Stop ******************************
STOP STOP_judge (
	.T_use_rs(T_use_rs), 
	.T_use_rt(T_use_rt), 
	.E_T_new(E_T_new), 
	.M_T_new(M_T_new), 
	.W_T_new(W_T_new), 
	.D_rs(D_rs), 
	.D_rt(D_rt), 
	.E_A3(E_A3_target), 
	.M_A3(M_A3_target), 
	.stop(stop)
	);
//****************************** Forward ******************************
//E/M-->D
assign D_Forward_RD1 = (D_rs == 0)? 0:
                       (D_rs == E_A3)? E_WD:
                       (D_rs == M_A3)? M_WD:D_RD1;
assign D_Forward_RD2 = (D_rt == 0)? 0:
                       (D_rt == E_A3)? E_WD:
                       (D_rt == M_A3)? M_WD:D_RD2;
//M/W-->E
assign E_Forward_RD1 = (E_rs == 0)?0:
                       (E_rs == M_A3)? M_WD:
                       (E_rs == W_A3)? W_WD:E_RD1;
assign E_Forward_RD2 = (E_rt == 0)?0:
                       (E_rt == M_A3)? M_WD:
                       (E_rt == W_A3)? W_WD:E_RD2;
//W-->M
assign M_Forward_RD2 = (M_rt == 0)?0:
                       (M_rt == W_A3)? W_WD:M_RD2;

endmodule