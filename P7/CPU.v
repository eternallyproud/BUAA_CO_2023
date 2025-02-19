`timescale 1ns / 1ps
`define None 0
`define AdEL 4
`define AdES 5
`define Syscall 8
`define RI 10
`define Ov 12
module CPU(
	input clk,
	input reset,
	
	output [31:0] macroscopic_pc,
	input [5:0] HWInt,

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
	
	output [31:0] w_inst_addr,
	
	output response
);

//stop
wire stop;
//CP0
wire Req;
wire response;
//forward
wire [31:0] D_Forward_RD2,D_Forward_RD1,E_Forward_RD2,E_Forward_RD1,M_Forward_RD2;
//****************************** F ******************************
//IFU
wire [31:0] F_NPC,F_PC,F_PC_tmp,F_EPC;
wire [31:0] F_command;
wire [4:0] F_exc;
wire PC_WE,F_exc_AdEL,F_BD;
assign F_NPC = (Req) ? 32'h0000_4180 :
               (D_eret) ? M_EPC_out + 4:
					(D_zero === 1) ? (D_PC + 4 + {{14{D_imm15[15]}},D_imm15,2'b00})://beq
               (D_PC_op === 2) ? ({D_PC[31:28],D_imm25,2'b00})://jal
               (D_PC_op === 3) ? (D_Forward_RD1)://jr
               (F_PC + 4);//???
assign PC_WE = (stop == 0); 
IFU IFUuut (
	.res(reset), //input
	.clk(clk), 
	.NPC(F_NPC),//add req !!!
    .Req(Req),
    .PC_WE(PC_WE),
	.PC(F_PC_tmp) //output
	);
assign F_PC = (D_eret == 1) ? M_EPC_out : F_PC_tmp;//?????
assign i_inst_addr = F_PC;
assign F_exc_AdEL = ((| F_PC[1:0]) | (F_PC < 32'h0000_3000) | (F_PC > 32'h0000_6ffc)) && !D_eret;
assign F_command = (F_exc_AdEL == 1) ? 32'd0 : i_inst_rdata;
assign F_exc = F_exc_AdEL? `AdEL : `None;
assign F_EPC = F_PC;
//****************************** D ******************************
wire D_WE;
assign D_WE = (stop == 0);
wire [31:0] D_PC,D_command,D_EPC;
wire [4:0] D_exc,D_exc_tmp;
wire D_BD,D_eret;
//D_REG
D_REG D (
	.clk(clk), //input
	.res(reset|Req), //delay branching will carry out the next command anyway!
	.F_command(F_command), 
	.F_PC(F_PC), 
	.F_exc(F_exc),
	.F_EPC(F_EPC),
	.F_BD(F_BD),
    .D_WE(D_WE), 
	.D_command(D_command),//output 
	.D_PC(D_PC),
	.D_exc(D_exc_tmp),
	.D_EPC(D_EPC),
	.D_BD(D_BD)
	);
//D_CTR
wire [4:0] D_rs,D_rt;
wire [15:0] D_imm15;
wire [25:0] D_imm25;
wire [1:0] D_EXT_op,D_PC_op,D_branch;
wire [1:0] T_use_rs,T_use_rt;
wire D_md,D_mf,D_mt,D_exc_RI,D_exc_SYS;
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
	.mt(D_mt),
	.eret(D_eret),
	.exc_RI(D_exc_RI),
	.exc_SYS(D_exc_SYS),
	.BD(F_BD)
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

assign D_exc = (D_exc_tmp != `None) ? D_exc_tmp : 
			   (D_exc_RI) ? `RI : 
			   (D_exc_SYS) ? `Syscall : `None;
//****************************** E ******************************
wire E_WE;
assign E_WE = 1;//???
wire [31:0] E_PC,E_command,E_EXT_out,E_RD1,E_RD2,E_WD,E_EPC;
wire [4:0] E_exc,E_exc_tmp;
wire E_BD;
//E_REG
E_REG E (
	.clk(clk), 
	.res(reset|Req), //clear when stopped
	.E_WE(E_WE), 
	.D_command(D_command), 
	.D_PC(D_PC), 
	.D_EXT_out(D_EXT_out), 
	.D_RD1(D_Forward_RD1), 
	.D_RD2(D_Forward_RD2), 
	.D_exc(D_exc),
	.D_EPC(D_EPC),
	.D_BD(D_BD),
	.E_command(E_command), 
	.E_PC(E_PC), 
	.E_EXT_out(E_EXT_out), 
	.E_RD1(E_RD1), 
	.E_RD2(E_RD2),
	.E_exc(E_exc_tmp),
	.E_EPC(E_EPC),
	.E_BD(E_BD),
	.stop(stop)
	);
//E_CRT
wire E_ALU_src;
wire [1:0] E_T_new;
wire [2:0] E_GRF_data,E_MDU_op,E_ALU_op;
wire [4:0] E_rs,E_rt,E_rd,E_A3,E_A3_target;
wire E_md,E_mt,E_mtc0;
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
	 .rd(E_rd),
	.MDU_op(E_MDU_op),
	.md(E_md),
	.mt(E_mt),
	.aluOv(E_aluOv),
	.stOv(E_stOv),
	.mtc0(E_mtc0)
	);
//ALU
wire [31:0] E_A,E_B,E_ALU_result;
assign E_A = E_Forward_RD1;
assign E_B = (E_ALU_src == 0)?E_Forward_RD2:E_EXT_out;
ALU ALUuut (
	.aluOv(E_aluOv),
	.stOv(E_stOv),
	.A(E_A), //input
	.B(E_B), 
	.ALU_op(E_ALU_op), 
	.result(E_ALU_result), //output
	.exc_aluOv(E_exc_Ov),
	.exc_stOv(E_exc_stOv)
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
	.Req(Req),
	.HI(E_HI), 
	.LO(E_LO), 
	.busy(busy)
);

assign E_exc = (E_exc_tmp != `None) ? E_exc_tmp :
			   (E_exc_Ov) ? `Ov : `None;
//****************************** M ******************************
wire M_WE = 1;//???
wire [31:0] M_PC,M_command,M_EXT_out,M_ALU_result,M_HI,M_LO,M_EPC;
wire [31:0] M_RD2,M_WD;
wire M_exc_stOv,M_BD;
wire [4:0] M_exc,M_exc_tmp;
//M_REG
M_REG M (
	.clk(clk), 
	.res(reset|Req), 
	.M_WE(M_WE), 
	.E_command(E_command), 
	.E_PC(E_PC), 
	.E_EXT_out(E_EXT_out), 
	.E_ALU_result(E_ALU_result), 
	.E_RD2(E_Forward_RD2), 
	.E_HI(E_HI),
	.E_LO(E_LO),
	.E_exc_stOv(E_exc_stOv),
	.E_exc(E_exc),
	.E_EPC(E_EPC),
	.E_BD(E_BD),
	.M_command(M_command), 
	.M_PC(M_PC), 
	.M_EXT_out(M_EXT_out), 
	.M_ALU_result(M_ALU_result), 
	.M_RD2(M_RD2),
	.M_HI(M_HI),
	.M_LO(M_LO),
	.M_exc_stOv(M_exc_stOv),
	.M_exc(M_exc_tmp),
	.M_EPC(M_EPC),
	.M_BD(M_BD)
	);
//M_CRT
wire M_DM_WE;
wire [1:0] M_T_new,M_STR_op,M_LD_op;
wire [2:0] M_GRF_data;
wire [4:0] M_rs,M_rt,M_rd,M_A3,M_A3_target;
wire M_eret,M_mtc0;
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
    .rt(M_rt),
	.rd(M_rd),
	.eret(M_eret),
	.CP0_WE(M_CP0_WE),
	.mtc0(M_mtc0)
	);
//DM
wire [31:0] M_DM_out;
wire M_exc_AdES,M_exc_AdEL;
wire [3:0] m_data_byteen_tmp;
STR STRuut(
	.exc_stOv(M_exc_stOv),
	.STR_op(M_STR_op),
	.addr(m_data_addr[15:0]),
	.data(M_Forward_RD2),
	.exc_AdES(M_exc_AdES),
	.STR_WE(m_data_byteen_tmp),
	.STR_out(m_data_wdata)
);
assign m_data_byteen = (m_data_byteen_tmp & {4{!Req}} );
LOAD LDuut(
	.exc_stOv(M_exc_stOv),
	.data(m_data_rdata),
	.addr(m_data_addr[15:0]),
	.exc_AdEL(M_exc_AdEL),
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
//CP0
wire [31:0] M_CP0_out,M_EPC_out;
CP0 CP0 (
	.clk(clk), 
	.res(reset), 
	.CP0_WE(M_CP0_WE), //mtc0 ¡Ì
	.EXL_clr(M_eret), 
	.BD(M_BD), 
	.A1(M_rd), 
	.A2(M_rd), 
	.CP0_in(M_Forward_RD2), 
	.EPC_in(M_EPC), //???
	.exc_in(M_exc), 
	.HWInt(HWInt),
	.Req(Req), 
	.CP0_out(M_CP0_out), 
	.EPC_out(M_EPC_out),
	.response(response)
);
assign macroscopic_pc = M_EPC;
assign M_exc = (M_exc_tmp != `None) ? M_exc_tmp :
			   (M_exc_AdES) ? `AdES :
			   (M_exc_AdEL) ? `AdEL : `None;
//****************************** W ******************************
wire W_WE;
assign W_WE = 1;//???
wire [31:0] W_PC,W_command,W_ALU_result,W_DM_out,W_HI,W_LO,W_CP0_out;
wire [1:0] W_GRF_addr;
wire [2:0] W_GRF_data;
wire [4:0] W_rt,W_rd;
W_REG W (
	.clk(clk), 
	.res(reset|Req), 
	.W_WE(W_WE), 
    .M_command(M_command), 
	.M_PC(M_PC), 
	.M_DM_out(M_DM_out), 
	.M_ALU_result(M_ALU_result), 
	.M_HI(M_HI),
	.M_LO(M_LO),
    .M_CP0_out(M_CP0_out),
	.W_command(W_command), 
	.W_PC(W_PC), 
	.W_DM_out(W_DM_out), 
	.W_ALU_result(W_ALU_result),
	.W_HI(W_HI),
	.W_LO(W_LO),
    .W_CP0_out(W_CP0_out)
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
				  (W_GRF_data == 4)?(W_LO):
				  (W_GRF_data == 5)?(W_CP0_out):0;

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
	.E_rd(E_rd),
	.M_A3(M_A3_target), 
	.M_rd(M_rd),
	.stop(stop),
	.busy(busy|E_md),
	.MD(MD),
	.D_eret(D_eret),
	.E_mtc0(E_mtc0),
	.M_mtc0(M_mtc0)
	);
	
reg [31:0] count_pc;
always @(posedge clk) begin
	if (W_PC == 32'h3548) count_pc <= count_pc + 1;
	else if (reset) count_pc <= 0;
	W1_command <= W_command;
	W2_command <= W1_command;
	W1_PC <= W_PC;
	W2_PC <= W1_PC;
end
reg [31:0] W1_command,W2_command,W1_PC,W2_PC;
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