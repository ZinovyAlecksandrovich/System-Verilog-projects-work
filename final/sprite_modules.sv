



//============================================================= PLAYER SPRITES ==================================================================================



module hatman1(                               //stand still
		input logic [13:0] address,
		output logic [3:0] red, green, blue 

);


logic [3:0] rom_q;
logic [3:0] palette_red, palette_green, palette_blue;



Hat_man1_out_rom Hat_man1_rom (
	.address (address),
	.q       (rom_q)
);

Hat_man1_out_palette Hat_man1_palette (
	.index (rom_q),
	.red   (palette_red),
	.green (palette_green),
	.blue  (palette_blue)
);

always_comb begin
	red = palette_red;
	green = palette_green;
	blue = palette_blue;
end


endmodule

//===========================================================================================================================================================================================

module hatman2(								//walk 1
		input logic [13:0] address,
		output logic [3:0] red, green, blue 

);


logic [3:0] rom_q;
logic [3:0] palette_red, palette_green, palette_blue;



Hat_man2_out_rom Hat_man1_rom (
	.address (address),
	.q       (rom_q)
);

Hat_man2_out_palette Hat_man2_palette (
	.index (rom_q),
	.red   (palette_red),
	.green (palette_green),
	.blue  (palette_blue)
);

always_comb begin
	red = palette_red;
	green = palette_green;
	blue = palette_blue;
end


endmodule

//===========================================================================================================================================================================================

module hatman3(								//walk 2
		input logic [13:0] address,
		output logic [3:0] red, green, blue 

);


logic [3:0] rom_q;
logic [3:0] palette_red, palette_green, palette_blue;



Hat_man3_out_rom Hat_man1_rom (
	.address (address),
	.q       (rom_q)
);

Hat_man3_out_palette Hat_man1_palette (
	.index (rom_q),
	.red   (palette_red),
	.green (palette_green),
	.blue  (palette_blue)
);

always_comb begin
	red = palette_red;
	green = palette_green;
	blue = palette_blue;
end


endmodule
//===========================================================================================================================================================================================
module hatman4(								//walk 3
		input logic [13:0] address,
		output logic [3:0] red, green, blue 

);


logic [3:0] rom_q;
logic [3:0] palette_red, palette_green, palette_blue;



Hat_man4_out_rom Hat_man4_rom (
	.address (address),
	.q       (rom_q)
);

Hat_man4_out_palette Hat_man4_palette (
	.index (rom_q),
	.red   (palette_red),
	.green (palette_green),
	.blue  (palette_blue)
);

always_comb begin
	red = palette_red;
	green = palette_green;
	blue = palette_blue;
end


endmodule

//====================================================================================================================

module hatman_hurt(								//walk 3
		input logic [13:0] address,
		output logic [3:0] red, green, blue 

);


logic [3:0] rom_q;
logic [3:0] palette_red, palette_green, palette_blue;



Hat_man1_hurt_rom Hat_man4_rom (
	.address (address),
	.q       (rom_q)
);

Hat_man1_hurt_palette Hat_man4_palette (
	.index (rom_q),
	.red   (palette_red),
	.green (palette_green),
	.blue  (palette_blue)
);

always_comb begin
	red = palette_red;
	green = palette_green;
	blue = palette_blue;
end


endmodule


//============================================================== BACKGROUNDS =======================================================================================
 
 module brick(								//walk 3
		input logic [12:0] address,
		output logic [3:0] red, green, blue 

);


logic [3:0] rom_q;
logic [3:0] palette_red, palette_green, palette_blue;



brick_rom b_rom (
	.address (address),
	.q       (rom_q)
);

brick_palette b_palette (
	.index (rom_q),
	.red   (palette_red),
	.green (palette_green),
	.blue  (palette_blue)
);

always_comb begin
	red = palette_red;
	green = palette_green;
	blue = palette_blue;
end


endmodule
//=====================================================================================================================================================
 module brick_elec1(								//walk 3
		input logic [12:0] address,
		output logic [3:0] red, green, blue 

);


logic [3:0] rom_q;
logic [3:0] palette_red, palette_green, palette_blue;



brick_lightning1_rom b_rom (
	.address (address),
	.q       (rom_q)
);

brick_lightning1_palette b_palette (
	.index (rom_q),
	.red   (palette_red),
	.green (palette_green),
	.blue  (palette_blue)
);

always_comb begin
	red = palette_red;
	green = palette_green;
	blue = palette_blue;
end


endmodule
//==================================================================================================================================
 module brick_elec2(								//walk 3
		input logic [12:0] address,
		output logic [3:0] red, green, blue 

);


logic [3:0] rom_q;
logic [3:0] palette_red, palette_green, palette_blue;



brick_lightning2_rom b_rom (
	.address (address),
	.q       (rom_q)
);

brick_lightning2_palette b_palette (
	.index (rom_q),
	.red   (palette_red),
	.green (palette_green),
	.blue  (palette_blue)
);

always_comb begin
	red = palette_red;
	green = palette_green;
	blue = palette_blue;
end


endmodule


//==================================================================================================================================================================================

 module game_background(								//walk 3
		input logic [14:0] address,
		output logic [3:0] red, green, blue 

);


logic [3:0] rom_q;
logic [3:0] palette_red, palette_green, palette_blue;



game_background_rom gb_rom (
	.address (address),
	.q       (rom_q)
);

game_background_palette gb_palette (
	.index (rom_q),
	.red   (palette_red),
	.green (palette_green),
	.blue  (palette_blue)
);

always_comb begin
	red = palette_red;
	green = palette_green;
	blue = palette_blue;
end


endmodule
 
//====================================================================================================================================================================================

 module start(								//walk 3
		input logic [14:0] address,
		output logic [3:0] red, green, blue 

);


logic [3:0] rom_q;
logic [3:0] palette_red, palette_green, palette_blue;



start_rom gb_rom (
	.address (address),
	.q       (rom_q)
);

start_palette gb_palette (
	.index (rom_q),
	.red   (palette_red),
	.green (palette_green),
	.blue  (palette_blue)
);

always_comb begin
	red = palette_red;
	green = palette_green;
	blue = palette_blue;
end


endmodule
//====================================================================================================================================================
 module introo(								//walk 3
		input logic [14:0] address,
		output logic [3:0] red, green, blue 

);


logic [3:0] rom_q;
logic [3:0] palette_red, palette_green, palette_blue;



intro_rom gb_rom (
	.address (address),
	.q       (rom_q)
);

intro_palette gb_palette (
	.index (rom_q),
	.red   (palette_red),
	.green (palette_green),
	.blue  (palette_blue)
);

always_comb begin
	red = palette_red;
	green = palette_green;
	blue = palette_blue;
end


endmodule

//====================================================================================================================================================
 module gameover(								//walk 3
		input logic [12:0] address,
		output logic [3:0] red, green, blue 

);


logic [3:0] rom_q;
logic [3:0] palette_red, palette_green, palette_blue;



gameover_rom gb_rom (
	.address (address),
	.q       (rom_q)
);

gameover_palette gb_palette (
	.index (rom_q),
	.red   (palette_red),
	.green (palette_green),
	.blue  (palette_blue)
);

always_comb begin
	red = palette_red;
	green = palette_green;
	blue = palette_blue;
end


endmodule

//========================================================== BOSS SPRITES =================================================================================================

module devil_stand(                               //stand still
		input logic [15:0] address,
		output logic [3:0] red, green, blue 

);


logic [3:0] rom_q;
logic [3:0] palette_red, palette_green, palette_blue;



devilstand_rom devilstand_rom (
	.address (address),
	.q       (rom_q)
);

devilstand_palette devilstand_palette (
	.index (rom_q),
	.red   (palette_red),
	.green (palette_green),
	.blue  (palette_blue)
);

always_comb begin
	red = palette_red;
	green = palette_green;
	blue = palette_blue;
end


endmodule

//================================================================================================================================================

module devil1(                               //stand still
		input logic [13:0] address,
		output logic [3:0] red, green, blue 

);


logic [3:0] rom_q;
logic [3:0] palette_red, palette_green, palette_blue;



devilwalk1_rom dw1_rom (
	.address (address),
	.q       (rom_q)
);

devilwalk1_palette dw1_palette (
	.index (rom_q),
	.red   (palette_red),
	.green (palette_green),
	.blue  (palette_blue)
);

always_comb begin
	red = palette_red;
	green = palette_green;
	blue = palette_blue;
end


endmodule

//===========================================================================================================================================================================================

module devil2(								//walk 1
		input logic [13:0] address,
		output logic [3:0] red, green, blue 

);


logic [3:0] rom_q;
logic [3:0] palette_red, palette_green, palette_blue;



devilwalk2_rom dw2_rom (
	.address (address),
	.q       (rom_q)
);

devilwalk2_palette dw2_palette (
	.index (rom_q),
	.red   (palette_red),
	.green (palette_green),
	.blue  (palette_blue)
);

always_comb begin
	red = palette_red;
	green = palette_green;
	blue = palette_blue;
end


endmodule

//===========================================================================================================================================================================================

module devil3(								//walk 2
		input logic [13:0] address,
		output logic [3:0] red, green, blue 

);


logic [3:0] rom_q;
logic [3:0] palette_red, palette_green, palette_blue;



devilwalk3_rom dw3_rom (
	.address (address),
	.q       (rom_q)
);

devilwalk3_palette dw3_palette (
	.index (rom_q),
	.red   (palette_red),
	.green (palette_green),
	.blue  (palette_blue)
);

always_comb begin
	red = palette_red;
	green = palette_green;
	blue = palette_blue;
end


endmodule
//===========================================================================================================================================================================================
module devil4(								//walk 3
		input logic [13:0] address,
		output logic [3:0] red, green, blue 

);


logic [3:0] rom_q;
logic [3:0] palette_red, palette_green, palette_blue;



devilwalk4_rom dw4_rom (
	.address (address),
	.q       (rom_q)
);

devilwalk4_palette dw4_palette (
	.index (rom_q),
	.red   (palette_red),
	.green (palette_green),
	.blue  (palette_blue)
);

always_comb begin
	red = palette_red;
	green = palette_green;
	blue = palette_blue;
end


endmodule

//============================================================== BOSS TEXT ===================================================================================================

module BossTitle(								//walk 3
		input logic [12:0] address,
		output logic [3:0] red, green, blue 

);


logic [3:0] rom_q;
logic [3:0] palette_red, palette_green, palette_blue;



FPGAFANATIC_rom FFR_rom (
	.address (address),
	.q       (rom_q)
);

FPGAFANATIC_palette FFP_palette (
	.index (rom_q),
	.red   (palette_red),
	.green (palette_green),
	.blue  (palette_blue)
);

always_comb begin
	red = palette_red;
	green = palette_green;
	blue = palette_blue;
end


endmodule




