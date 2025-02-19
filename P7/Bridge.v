`timescale 1ns / 1ps
module Bridge(
	output [31:0] m_data_addr,
    output [31:0] m_data_wdata,
    output [3:0] m_data_byteen,
    input [31:0] m_data_rdata,

    input [31:0] m_data_addr_tmp,
    input [31:0] m_data_wdata_tmp,
    input [3:0] m_data_byteen_tmp,
    output [31:0] m_data_rdata_tmp,

    output [31:0] T1_addr,
    output [31:0] T1_in,
    output [0:0] T1_WE,
    input [31:0] T1_out,

    output [31:0] T2_addr,
    output [31:0] T2_in,
    output [0:0] T2_WE,
    input [31:0] T2_out
);

assign T1_WE = (m_data_addr_tmp >= 16'h7f00) & (m_data_addr_tmp <= 16'h7f0b) & (|m_data_byteen_tmp);
assign T2_WE = (m_data_addr_tmp >= 16'h7f10) & (m_data_addr_tmp <= 16'h7f1b) & (|m_data_byteen_tmp);
assign T1_in = m_data_wdata_tmp;
assign T2_in = m_data_wdata_tmp;
assign T1_addr = m_data_addr_tmp;
assign T2_addr = m_data_addr_tmp;

assign m_data_rdata_tmp = ((m_data_addr_tmp >= 16'h7f00) & (m_data_addr_tmp <= 16'h7f0b)) ? T1_out :
                          ((m_data_addr_tmp >= 16'h7f10) & (m_data_addr_tmp <= 16'h7f1b)) ? T2_out : 
                          m_data_rdata;

wire DM_WE = (m_data_addr_tmp >= 16'h0000) & (m_data_addr_tmp <= 16'h2fff);
assign m_data_byteen = m_data_byteen_tmp & {4{DM_WE}};
assign m_data_wdata = m_data_wdata_tmp;
assign m_data_addr = m_data_addr_tmp;

endmodule
