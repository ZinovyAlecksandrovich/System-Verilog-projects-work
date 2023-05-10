module FPGAFANATIC_rom (
	input logic [12:0] address,
	output logic [3:0] q
);

logic [3:0] memory [0:4624] /* synthesis ram_init_file = "./FPGAFANATIC/FPGAFANATIC.mif" */;


	assign q = memory[address];


endmodule
