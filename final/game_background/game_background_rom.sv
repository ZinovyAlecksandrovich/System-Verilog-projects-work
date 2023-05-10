module game_background_rom (
	input logic clock,
	input logic [14:0] address,
	output logic [3:0] q
);

logic [3:0] memory [0:25199] /* synthesis ram_init_file = "./game_background/game_background.mif" */;

assign q = memory[address];


endmodule
