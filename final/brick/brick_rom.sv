module brick_rom (
	input logic clock,
	input logic [12:0] address,
	output logic [3:0] q
);

logic [3:0] memory [0:4999] /* synthesis ram_init_file = "./brick/brick.mif" */;

assign q = memory[address];

endmodule
