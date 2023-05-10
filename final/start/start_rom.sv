module start_rom (
	input logic clock,
	input logic [14:0] address,
	output logic [3:0] q
);

logic [3:0] memory [0:31499] /* synthesis ram_init_file = "./start/start.mif" */;

	assign q = memory[address];
endmodule
