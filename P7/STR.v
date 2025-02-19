`timescale 1ns / 1ps
module STR(
    input exc_stOv,
	 input [1:0] STR_op,
	 input [15:0] addr,
	 input [31:0] data,
    output exc_AdES,
    output [3:0] STR_WE,
    output [31:0] STR_out
);

assign STR_WE[0] = (STR_op == 1)|((STR_op == 2)&(addr[1] == 0))|((STR_op == 3)&(addr[1:0] == 0));
assign STR_WE[1] = (STR_op == 1)|((STR_op == 2)&(addr[1] == 0))|((STR_op == 3)&(addr[1:0] == 1));
assign STR_WE[2] = (STR_op == 1)|((STR_op == 2)&(addr[1] == 1))|((STR_op == 3)&(addr[1:0] == 2));
assign STR_WE[3] = (STR_op == 1)|((STR_op == 2)&(addr[1] == 1))|((STR_op == 3)&(addr[1:0] == 3));

assign STR_out = (STR_op == 1) ? data :
				 (STR_op == 2) ? ((addr[1] == 1) ? {data[15:0],16'b0} : {16'b0,data[15:0]}) :
				 (STR_op == 3) ? ((addr[1:0] == 0) ? {24'b0,data[7:0]} :
				 				  (addr[1:0] == 1) ? {16'b0,data[7:0],8'b0} :
								  (addr[1:0] == 2) ? {8'b0,data[7:0],16'b0} :
								  (addr[1:0] == 3) ? {data[7:0],24'b0} : 0) : 0;
								  
wire error_align = ((STR_op == 1) & (addr[1]|addr[0])) |
                   ((STR_op == 2) & (addr[0]));
    
wire error_range = !(((addr >= 16'h0000) & (addr <= 16'h2fff)) |
                     ((addr >= 16'h7f00) & (addr <= 16'h7f0b)) |
                     ((addr >= 16'h7f10) & (addr <= 16'h7f1b)) |
							((addr >= 16'h7f20) & (addr <= 16'h7f23)));
    
wire error_timer = (addr >= 16'h7f08 && addr <= 16'h7f0b) ||
                   (addr >= 16'h7f18 && addr <= 16'h7f1b) ||//store to count
                   (STR_op != 1 && addr >= 16'h7f00);
assign exc_AdES = (STR_op != 0) && (error_align || error_range || error_timer || exc_stOv);

endmodule
