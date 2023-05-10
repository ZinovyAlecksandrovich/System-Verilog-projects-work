module intro_rom (
	input logic clock,
	input logic [14:0] address,
	output logic [3:0] q
);

logic [3:0] memory [0:17499] /* synthesis ram_init_file = "./intro/intro.mif" */;


	assign q = memory[address];


endmodule
