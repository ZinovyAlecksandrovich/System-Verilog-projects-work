module Hat_man4_out_rom (
	input logic [12:0] address,
	output logic [3:0] q
);

logic [3:0] memory [0:4899] /* synthesis ram_init_file = "./Hat_man4_out/Hat_man4_out.mif" */;


	assign q = memory[address];

endmodule
