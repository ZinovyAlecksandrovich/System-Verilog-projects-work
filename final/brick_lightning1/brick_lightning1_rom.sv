module brick_lightning1_rom (
	input logic clock,
	input logic [12:0] address,
	output logic [3:0] q
);

logic [3:0] memory [0:4999] /* synthesis ram_init_file = "./brick_lightning1/brick_lightning1.mif" */;

assign q = memory[address];

endmodule
