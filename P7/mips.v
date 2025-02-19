`timescale 1ns / 1ps
module mips(
    input clk,                    // 时钟信号
    input reset,                  // 同步复位信号
    input interrupt,              // 外部中断信号
    output [31:0] macroscopic_pc, // 宏观 PC

    output [31:0] i_inst_addr,    // IM 读取地址（取指 PC）
    input  [31:0] i_inst_rdata,   // IM 读取数据

    output [31:0] m_data_addr,    // DM 读写地址
    input  [31:0] m_data_rdata,   // DM 读取数据
    output [31:0] m_data_wdata,   // DM 待写入数据
    output [3 :0] m_data_byteen,  // DM 字节使能信号

    output [31:0] m_int_addr,     // 中断发生器待写入地址
    output [3 :0] m_int_byteen,   // 中断发生器字节使能信号

    output [31:0] m_inst_addr,    // M 级 PC

    output w_grf_we,              // GRF 写使能信号
    output [4 :0] w_grf_addr,     // GRF 待写入寄存器编号
    output [31:0] w_grf_wdata,    // GRF 待写入数据

    output [31:0] w_inst_addr     // W 级 PC
);
wire [31:0] m_data_rdata_tmp,m_data_addr_tmp,m_data_wdata_tmp,T1_addr,T2_addr,T1_in,T2_in,T1_out,T2_out;
wire T1_WE,T2_WE;
wire [3:0] m_data_byteen_tmp;
wire [5:0] HWInt;

assign m_int_addr = response ? 32'h0000_7f20 : 0;
assign m_int_byteen = response ? 1 : 0;

//wire did_int;
//assign did_int = (|m_data_byteen) & (m_data_addr >= 32'h0000_7f20) & (m_data_addr <= 32'h0000_7f23);
//assign m_int_addr = did_int ? 32'h0000_7f20 : 0;
//assign m_int_byteen = did_int ? 1 : 0;

CPU CPUuut(
	.clk(clk), 
	.reset(reset), 
	.HWInt(HWInt), 
   .macroscopic_pc(macroscopic_pc),
	.i_inst_addr(i_inst_addr), 
	.i_inst_rdata(i_inst_rdata), 
	.m_data_rdata(m_data_rdata_tmp), 
	.m_data_byteen(m_data_byteen_tmp), 
	.m_data_addr(m_data_addr_tmp), 
	.m_data_wdata(m_data_wdata_tmp), 
	.m_inst_addr(m_inst_addr), 
	.w_grf_we(w_grf_we), 
	.w_grf_addr(w_grf_addr), 
	.w_grf_wdata(w_grf_wdata), 
	.w_inst_addr(w_inst_addr),
	.response(response)
);

Bridge Bridge (
	.m_data_addr(m_data_addr), 
	.m_data_wdata(m_data_wdata), 
	.m_data_byteen(m_data_byteen), 
	.m_data_rdata(m_data_rdata), 
	.m_data_addr_tmp(m_data_addr_tmp), 
	.m_data_wdata_tmp(m_data_wdata_tmp), 
	.m_data_byteen_tmp(m_data_byteen_tmp), 
	.m_data_rdata_tmp(m_data_rdata_tmp), 
	.T1_addr(T1_addr), 
	.T1_in(T1_in), 
	.T1_WE(T1_WE), 
	.T1_out(T1_out), 
	.T2_addr(T2_addr), 
	.T2_in(T2_in), 
	.T2_WE(T2_WE), 
	.T2_out(T2_out)
);

TC Timer1 (
	.clk(clk), 
	.reset(reset), 
	.Addr(T1_addr[31:2]), 
	.WE(T1_WE), 
	.Din(T1_in), 
	.Dout(T1_out), 
	.IRQ(T1_IRQ)
);

TC Timer2 (
	.clk(clk), 
	.reset(reset), 
	.Addr(T2_addr[31:2]), 
	.WE(T2_WE), 
	.Din(T2_in), 
	.Dout(T2_out), 
	.IRQ(T2_IRQ)
);

assign HWInt = {3'b0,{interrupt},{T2_IRQ},{T1_IRQ}};

endmodule