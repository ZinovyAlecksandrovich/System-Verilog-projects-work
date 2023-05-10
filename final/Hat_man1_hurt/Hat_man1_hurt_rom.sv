module Hat_man1_hurt_rom (
	input logic clock,
	input logic [12:0] address,
	output logic [3:0] q
);

logic [3:0] memory [0:4899] /* synthesis ram_init_file = "./Hat_man1_hurt/Hat_man1_hurt.mif" */;


assign q = memory[address];

endmodule
