`timescale 1ns / 1ps
`define IM SR[15:10]
`define EXL SR[1]
`define IE SR[0]
`define BD Cause[31]
`define IP Cause[15:10]
`define ExcCode Cause[6:2]
module CP0(
    input clk,
    input res,
    input CP0_WE,
    input EXL_clr,
    input BD,
    input [4:0] A1,
    input [4:0] A2,
    input [31:0] CP0_in,
    input [31:0] EPC_in,
    input [4:0] exc_in,
    input [5:0] HWInt,
    output Req,
    output [31:0] CP0_out,
    output [31:0] EPC_out,
	 output response
);
reg [31:0] EPC,SR,Cause,PrID;
wire exc,Int;

assign exc = (|exc_in) & !`EXL;
assign Int = (|(HWInt & `IM)) & !`EXL & `IE;//eret Ê±ÖÐ¶Ï£¿
assign Req = exc | Int;

assign CP0_out = (A1 == 12) ? SR:
                 (A1 == 13) ? Cause:
                 (A1 == 14) ? EPC:
                 (A1 == 15) ? PrID:0;
					  
assign response = Int;

always @(posedge clk) begin
    if(res == 1) begin
        EPC <= 0;
        SR <= 0;
        Cause <= 0;
        PrID <= 0;
    end
    else begin
        if (Req) begin // int|exc
            `ExcCode <= Int ? 5'b0 : exc_in;//Int comes first!!!
            `EXL <= 1'b1;
            `BD <= BD;
            EPC <= EPC_out;
        end
        else begin 
            if (EXL_clr == 1) begin
                `EXL <= 0;
            end
            if (CP0_WE == 1)begin
                if (A2 == 12) begin
                    SR <= CP0_in;
						  //$display("%d: Status <= %h", $time, CP0_in);
                end
                if (A2 == 14) begin
                    EPC <= CP0_in;
						  //$display("%d: EPC <= %h", $time, CP0_in);
                end
            end
        end
        `IP <= HWInt;
    end
end

assign EPC_out = (Req) ? (BD ? EPC_in[31:0]-4 : EPC_in[31:0]) : EPC[31:0];
///???
endmodule
