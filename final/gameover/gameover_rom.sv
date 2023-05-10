module gameover_rom (
	input logic clock,
	input logic [12:0] address,
	output logic [3:0] q
);

logic [3:0] memory [0:6499] /* synthesis ram_init_file = "./gameover/gameover.mif" */;
	assign q = memory[address];

endmodule
