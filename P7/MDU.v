`timescale 1ns / 1ps
module MDU(
	input clk,
	input res,
    input mt,
	input start,
	input [2:0] MDU_op,
	input [31:0] A,
	input [31:0] B,
	input Req,
	output reg [31:0] HI,
	output reg [31:0] LO,
	output reg busy
);

reg [3:0] count;
reg [31:0] regHI,regLO;

always @(posedge clk) begin
	if(res) begin
		regHI <= 0;
		regLO <= 0;
		HI <= 0;
		LO <= 0;
		count <= 0;
		busy <= 0;
	end
	else begin
		if ((count == 0)&(start == 1)&(Req == 0)) begin
			busy <= 1;
			if (MDU_op[1] == 1) begin//01x mul
				count <= 5;
				if (MDU_op[0] == 0) begin//unsigned mul
					{ regHI , regLO } <= A * B;
				end
				else begin//signed mul
					{ regHI , regLO } <= $signed(A) * $signed(B);
				end
			end
			if (MDU_op[2] == 1) begin//10x div
				count <= 10;
				if (MDU_op[0] == 0) begin//unsigned div
					regLO <= A / B;
					regHI <= A % B;
				end
				else begin//signed div
					regLO <= $signed(A) / $signed(B);
					regHI <= $signed(A) % $signed(B);
				end
			end
		end
		if (count != 0) begin
			if (count == 1) begin
				HI <= regHI;
				LO <= regLO;
				count <= 0;
				busy <= 0;
			end
			else begin
				count <= count - 1;
			end
		end
        if ((mt == 1) & (Req == 0)) begin
		    if(MDU_op == 0) begin
			    LO <= A;
		    end
		    if(MDU_op == 1) begin
			    HI <= A;
		    end
        end
	end
end

endmodule
