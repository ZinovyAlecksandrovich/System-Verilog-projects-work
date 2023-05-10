module Hat_man3_out_rom (
	input logic [12:0] address,
	output logic [3:0] q
);

logic [3:0] memory [0:4899] /* synthesis ram_init_file = "./Hat_man3_out/Hat_man3_out.mif" */;

assign q = memory[address];

endmodule
