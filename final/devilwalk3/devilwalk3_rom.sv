module devilwalk3_rom (
	input logic clock,
	input logic [13:0] address,
	output logic [3:0] q
);

logic [3:0] memory [0:9999] /* synthesis ram_init_file = "./devilwalk3/devilwalk3.mif" */;

assign q = memory[address];

endmodule
