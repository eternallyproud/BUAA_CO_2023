`timescale 1ns / 1ps
module mips(
	input clk,
	input reset,

	output [31:0] i_inst_addr,
   input [31:0] i_inst_rdata,

	input [31:0] m_data_rdata,
	output [3:0] m_data_byteen,
   output [31:0] m_data_addr,
   output [31:0] m_data_wdata,
   output [31:0] m_inst_addr,

   output w_grf_we,
   output [4:0] w_grf_addr,
   output [31:0] w_grf_wdata,

   output [31:0] w_inst_addr
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
	.PC(F_PC) //output
	);
assign i_inst_addr = F_PC;
assign F_command = i_inst_rdata;
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
wire [1:0] D_EXT_op,D_PC_op,D_branch;
wire [1:0] T_use_rs,T_use_rt;
wire D_md,D_mf,D_mt;
CTR D_CTR (
    .stage(2'b00), //input
	.command(D_command),
	.rs(D_rs), //output
	.rt(D_rt), 
	.imm15(D_imm15), 
	.imm25(D_imm25), 
	.EXT_op(D_EXT_op),
    .PC_op(D_PC_op),
	.branch(D_branch),
    .T_use_rs(T_use_rs),
    .T_use_rt(T_use_rt),
	.md(D_md),
	.mf(D_mf),
	.mt(D_mt)
	);
assign MD = D_md | D_mf | D_mt;
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
	.branch(D_branch),
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
assign w_grf_we = W_GRF_WE;
assign w_grf_addr = W_A3;
assign w_grf_wdata = W_WD;
assign w_inst_addr = W_PC;

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
wire [1:0] E_T_new;
wire [2:0] E_GRF_data,E_MDU_op,E_ALU_op;
wire [4:0] E_rs,E_rt,E_A3,E_A3_target;
wire E_md;
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
    .rt(E_rt),
	.MDU_op(E_MDU_op),
	.md(E_md),
	.mt(E_mt)
	);
//ALU
wire [31:0] E_A, E_B,E_ALU_result;
wire E_mt;
assign E_A = E_Forward_RD1;
assign E_B = (E_ALU_src == 0)?E_Forward_RD2:E_EXT_out;
ALU ALUuut (
	.A(E_A), //input
	.B(E_B), 
	.ALU_op(E_ALU_op), 
	.result(E_ALU_result) //output
	);
assign E_WD = (E_GRF_data == 2)?(E_PC + 8):
			  (E_GRF_data == 3)?(E_HI):
			  (E_GRF_data == 4)?(E_LO):0;
//MDU
wire busy;
wire [31:0] E_HI,E_LO;
MDU MDUuut (
	.clk(clk), 
	.res(reset), 
	.mt(E_mt),
	.start(E_md),
	.MDU_op(E_MDU_op), 
	.A(E_Forward_RD1), 
	.B(E_Forward_RD2), 
	.HI(E_HI), 
	.LO(E_LO), 
	.busy(busy)
);
//****************************** M ******************************
wire M_WE;
assign M_WE = 1;//???
wire [31:0] M_PC,M_command,M_EXT_out,M_ALU_result,M_HI,M_LO;
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
	.E_HI(E_HI),
	.E_LO(E_LO),
	.M_command(M_command), 
	.M_PC(M_PC), 
	.M_EXT_out(M_EXT_out), 
	.M_ALU_result(M_ALU_result), 
	.M_RD2(M_RD2),
	.M_HI(M_HI),
	.M_LO(M_LO)
	);
//M_CRT
wire M_DM_WE;
wire [1:0] M_T_new,M_STR_op,M_LD_op;
wire [2:0] M_GRF_data;
wire [4:0] M_rs,M_rt,M_A3,M_A3_target;
CTR M_CRT (
    .stage(2'b10),
	 .command(M_command), 
    .T_new(M_T_new),
	 .STR_op(M_STR_op),
	 .LOAD_op(M_LD_op),
    .GRF_data(M_GRF_data),
    .A3(M_A3),
    .A3_target(M_A3_target),
    .rs(M_rs),
    .rt(M_rt)
	);
//DM
wire [31:0] M_DM_out;
STR STRuut(
	.STR_op(M_STR_op),
	.addr(m_data_addr[15:0]),
	.data(M_Forward_RD2),
	.STR_WE(m_data_byteen),
	.STR_out(m_data_wdata)
);
LOAD LDuut(
	.data(m_data_rdata),
	.addr(m_data_addr[15:0]),
	.LOAD_op(M_LD_op),
	.LOAD_out(M_DM_out)
);
assign m_inst_addr = M_PC;
assign m_data_addr = M_ALU_result[15:0];
//GRF forward
assign M_WD = (M_GRF_data == 0)?M_ALU_result:
              (M_GRF_data == 2)?(M_PC + 8):
			  (M_GRF_data == 3)?(M_HI):
			  (M_GRF_data == 4)?(M_LO):0;
//****************************** W ******************************
wire W_WE;
assign W_WE = 1;//???
wire [31:0] W_PC,W_command,W_ALU_result,W_DM_out,W_HI,W_LO;
wire [1:0] W_GRF_addr;
wire [2:0] W_GRF_data;
wire [4:0] W_rt,W_rd;
W_REG W (
	.clk(clk), 
	.res(reset), 
	.W_WE(W_WE), 
    .M_command(M_command), 
	.M_PC(M_PC), 
	.M_DM_out(M_DM_out), 
	.M_ALU_result(M_ALU_result), 
	.M_HI(M_HI),
	.M_LO(M_LO),
	.W_command(W_command), 
	.W_PC(W_PC), 
	.W_DM_out(W_DM_out), 
	.W_ALU_result(W_ALU_result),
	.W_HI(W_HI),
	.W_LO(W_LO)
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
              (W_GRF_data == 2)?(W_PC + 8):
			  (W_GRF_data == 3)?(W_HI):
			  (W_GRF_data == 4)?(W_LO):0;

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
	.stop(stop),
	.busy(busy|E_md),
	.MD(MD)
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