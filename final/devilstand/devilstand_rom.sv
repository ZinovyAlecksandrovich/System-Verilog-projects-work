module devilstand_rom (
	input logic [15:0] address,
	output logic [3:0] q
);

logic [3:0] memory [0:39999] /* synthesis ram_init_file = "./devilstand/devilstand.mif" */;
	
	assign q = memory[address];


endmodule
