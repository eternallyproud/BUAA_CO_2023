`timescale 1ns / 1ps

module MDU_uut;

	// Inputs
	reg clk;
	reg res;
	reg start;
	reg [2:0] MDU_op;
	reg [31:0] A;
	reg [31:0] B;

	// Outputs
	wire [31:0] HI;
	wire [31:0] LO;
	wire busy;

	// Instantiate the Unit Under Test (UUT)
	MDU uut (
		.clk(clk), 
		.res(res), 
		.start(start), 
		.MDU_op(MDU_op), 
		.A(A), 
		.B(B), 
		.HI(HI), 
		.LO(LO), 
		.busy(busy)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		res = 1;
		start = 0;
		MDU_op = 0;
		A = 0;
		B = 0;

		// Wait 100 ns for global reset to finish
		#10;
      res = 0;
		MDU_op = 3'b101;
		A = 126;
		B = -8;
		start = 1;
		#10;
		start = 0;
		// Add stimulus here

	end
   always #5 clk = ~clk;
endmodule

