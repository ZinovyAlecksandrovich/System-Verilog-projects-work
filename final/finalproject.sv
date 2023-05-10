

//-------------------------------------------------------------------------
//                                                                       --
//                                                                       --
//      For use with ECE 385 Lab 62                                       --
//      UIUC ECE Department                                              --
//-------------------------------------------------------------------------


module finalproject (

      ///////// Clocks /////////
      input     MAX10_CLK1_50, 

      ///////// KEY /////////
      input    [ 1: 0]   KEY,

      ///////// SW /////////
      input    [ 9: 0]   SW,

      ///////// LEDR /////////
      output   [ 9: 0]   LEDR,

      ///////// HEX /////////
      output   [ 7: 0]   HEX0,
      output   [ 7: 0]   HEX1,
      output   [ 7: 0]   HEX2,
      output   [ 7: 0]   HEX3,
      output   [ 7: 0]   HEX4,
      output   [ 7: 0]   HEX5,

      ///////// SDRAM /////////
      output             DRAM_CLK,
      output             DRAM_CKE,
      output   [12: 0]   DRAM_ADDR,
      output   [ 1: 0]   DRAM_BA,
      inout    [15: 0]   DRAM_DQ,
      output             DRAM_LDQM,
      output             DRAM_UDQM,
      output             DRAM_CS_N,
      output             DRAM_WE_N,
      output             DRAM_CAS_N,
      output             DRAM_RAS_N,

      ///////// VGA /////////
      output             VGA_HS,
      output             VGA_VS,
      output   [ 3: 0]   VGA_R,
      output   [ 3: 0]   VGA_G,
      output   [ 3: 0]   VGA_B,


      ///////// ARDUINO /////////
      inout    [15: 0]   ARDUINO_IO,
      inout              ARDUINO_RESET_N 

);




logic Reset_h, vssig, blank, sync, VGA_Clk;


//=======================================================
//  REG/WIRE declarations
//=======================================================
	logic SPI0_CS_N, SPI0_SCLK, SPI0_MISO, SPI0_MOSI, USB_GPX, USB_IRQ, USB_RST;
	logic [3:0] hex_num_4, hex_num_3, hex_num_1, hex_num_0; //4 bit input hex digits
	logic [1:0] signs;
	logic [1:0] hundreds;

//=======================================================
//  Structural coding
//=======================================================
	assign ARDUINO_IO[10] = SPI0_CS_N;
	assign ARDUINO_IO[13] = SPI0_SCLK;
	assign ARDUINO_IO[11] = SPI0_MOSI;
	assign ARDUINO_IO[12] = 1'bZ;
	assign SPI0_MISO = ARDUINO_IO[12];
	
	assign ARDUINO_IO[9] = 1'bZ; 
	assign USB_IRQ = ARDUINO_IO[9];
		
	//Assignments specific to Circuits At Home UHS_20
	assign ARDUINO_RESET_N = USB_RST;
	assign ARDUINO_IO[7] = USB_RST;//USB reset 
	assign ARDUINO_IO[8] = 1'bZ; //this is GPX (set to input)
	assign USB_GPX = 1'b0;//GPX is not needed for standard USB host - set to 0 to prevent interrupt
	
	//Assign uSD CS to '1' to prevent uSD card from interfering with USB Host (if uSD card is plugged in)
	assign ARDUINO_IO[6] = 1'b1;
	
	//HEX drivers to convert numbers to HEX output
	
	HexDriver hex_driver3 (hex_num_3, HEX3[6:0]);
	assign HEX3[7] = 1'b1;
	
	HexDriver hex_driver1 (hex_num_1, HEX1[6:0]);
	assign HEX1[7] = 1'b1;
	
	HexDriver hex_driver0 (hex_num_0, HEX0[6:0]);
	assign HEX0[7] = 1'b1;
	
	//fill in the hundreds digit as well as the negative sign
	assign HEX5 = {1'b1, ~signs[1], 3'b111, ~hundreds[1], ~hundreds[1], 1'b1};
	assign HEX4 = {1'b1, ~signs[1], 3'b111, ~hundreds[1], ~hundreds[1], 1'b1};
	assign HEX2 = {1'b1, ~signs[0], 3'b111, ~hundreds[0], ~hundreds[0], 1'b1};
	
	
	//Assign one button to reset
	assign {Reset_h}=~ (KEY[0]);
	
//	assign VGA_R = Red[7:4];
//	assign VGA_B = Blue[7:4];
//	assign VGA_G = Green[7:4];

	//Our A/D converter is only 12 bit

	
	
	logic [9:0] DrawX, DrawY, playerx, playery, players;
	logic [9:0] bossx, bossy, bosss, boss_health;
	logic boss_is_walking, boss_direction, boss_special_attack, elec_frame;
	logic [1:0] boss_walk_frame;

	logic [9:0] drawxsig, drawysig, ballxsig, ballysig, ballsizesig;
	logic [7:0] Red, Blue, Green;
	logic [15:0] keycode;
	logic w_pressed, a_pressed, d_pressed;

	logic [1:0] player_walk_frame;
	logic player_is_walking, player_direction;
	logic [9:0] bullX, bullY, bullS;
	logic [3:0] player_lives;
	logic player_hurt;

	logic game_over, menu, intro;
	
	
	assign hex_num_3 = player_lives;

	
	
	
	lab62_soc u0 (
		.clk_clk                           (MAX10_CLK1_50),  //clk.clk
		.reset_reset_n                     (1'b1),           //reset.reset_n
		.altpll_0_locked_conduit_export    (),               //altpll_0_locked_conduit.export
		.altpll_0_phasedone_conduit_export (),               //altpll_0_phasedone_conduit.export
		.altpll_0_areset_conduit_export    (),               //altpll_0_areset_conduit.export
		.key_external_connection_export    (KEY),            //key_external_connection.export

		//SDRAM
		.sdram_clk_clk(DRAM_CLK),                            //clk_sdram.clk
		.sdram_wire_addr(DRAM_ADDR),                         //sdram_wire.addr
		.sdram_wire_ba(DRAM_BA),                             //.ba
		.sdram_wire_cas_n(DRAM_CAS_N),                       //.cas_n
		.sdram_wire_cke(DRAM_CKE),                           //.cke
		.sdram_wire_cs_n(DRAM_CS_N),                         //.cs_n
		.sdram_wire_dq(DRAM_DQ),                             //.dq
		.sdram_wire_dqm({DRAM_UDQM,DRAM_LDQM}),              //.dqm
		.sdram_wire_ras_n(DRAM_RAS_N),                       //.ras_n
		.sdram_wire_we_n(DRAM_WE_N),                         //.we_n

		//USB SPI	
		.spi0_SS_n(SPI0_CS_N),
		.spi0_MOSI(SPI0_MOSI),
		.spi0_MISO(SPI0_MISO),
		.spi0_SCLK(SPI0_SCLK),
		
		//USB GPIO
		.usb_rst_export(USB_RST),
		.usb_irq_export(USB_IRQ),
		.usb_gpx_export(USB_GPX),
		
		//LEDs and HEX
		.hex_digits_export({4'b0000, 4'b0000, hex_num_1, hex_num_0}),
		.leds_export({hundreds, signs, LEDR}),
		.keycode_export(keycode),
		
	 );


//instantiate a vga_controller, ball, and color_mapper here with the ports.


	vga_controller vga(
		.Clk          (MAX10_CLK1_50),
		.Reset        (Reset_h),
		.hs			  (VGA_HS),
		.vs           (VGA_VS),
		.pixel_clk    (VGA_Clk),
		.blank        (blank),
		.sync         (sync),
		.DrawX        (drawxsig),
		.DrawY        (drawysig)
	
	);
	

	
ColorMapper cm (
	.DrawX(drawxsig), 
	.blank(blank),
	.DrawY(drawysig),
	.pixel_clk(VGA_Clk),
	.PlayerX(playerx), 
	.PlayerY(playery), 
	.PlayerSize(players),
	.bulletX(bullX), 
	.bulletY(bullY), 
	.bulletSize(bulls),
	.player_walk_frame(player_walk_frame),
	.player_is_walking(player_is_walking),
	.player_direction (player_direction),
	.player_hurt(player_hurt),
	.red(VGA_R), 
	.green(VGA_G), 
	.blue(VGA_B),
	.BossX(bossx),
	.BossY(bossy),
	.BossSize(bosss),
	.walk_frame_boss(boss_walk_frame),
	.is_walking_boss(boss_is_walking),
	.boss_direction(boss_direction),
	.boss_health(boss_health),
	.boss_special_attack(boss_special_attack),
	.elec_frame(elec_frame),
	.game_over(game_over),
	.menu(menu),
	.intro(into)
);


Player hatman ( 
			.Reset(Reset_h), 
			.frame_clk(VGA_VS),
			.keycode(keycode),
			.BossX(bossx),
			.BossY(bossy),
			.BossS(bosss),
			.elec_frame(elec_frame),
			.boss_special_attack(boss_special_attack),
			.boss_health(boss_health),
         	.PlayerX(playerx), 
			.PlayerY(playery), 
			.PlayerS(players),
			.bulletX(bullX), 
			.bulletY(bullY), 
			.bulletS(bullS),
			.walk_frame(player_walk_frame),
			.is_walking(player_is_walking),
			.direction(player_direction),
			.player_lives(player_lives),
			.player_hurt(player_hurt),
			.menu(menu),
			.game_over(game_over)

);


Boss The_FPGA_Fanatic ( 
				.Reset(Reset_h), 
				.frame_clk(VGA_VS),
				.PlayerX(playerx), 
				.PlayerY(playery), 
				.PlayerS(players),
				.bulletX(bullX), 
				.bulletY(bullY), 
				.bulletS(bullS),
				.BossX(bossx), 
				.BossY(bossy), 
				.BossS(bosss),
				.walk_frame(boss_walk_frame),
				.is_walking(boss_is_walking),
				.direction(boss_direction),
				.health(boss_health),
				.menu(menu),
				.game_over(game_over)
					);


















//	color_mapper cm(
//		
//		.BallX            (ballxsig),
//		.BallY				(ballysig),
//		.DrawX				(drawxsig),
//		.DrawY				(drawysig),
//		.Ball_size			(ballsizesig),
//		.Red              (Red),
//		.Green  				(Green),
//		.Blue					(Blue)
//	);



endmodule


























































































































////-------------------------------------------------------------------------
////                                                                       --
////                                                                       --
////      For use with ECE 385 Lab 62                                       --
////      UIUC ECE Department                                              --
////-------------------------------------------------------------------------
//
//
//module finalproject (
//
//      ///////// Clocks /////////
//      input     MAX10_CLK1_50, 
//
//      ///////// KEY /////////
//      input    [ 1: 0]   KEY,
//
//      ///////// SW /////////
//      input    [ 9: 0]   SW,
//
//      ///////// LEDR /////////
//      output   [ 9: 0]   LEDR,
//
//      ///////// HEX /////////
//      output   [ 7: 0]   HEX0,
//      output   [ 7: 0]   HEX1,
//      output   [ 7: 0]   HEX2,
//      output   [ 7: 0]   HEX3,
//      output   [ 7: 0]   HEX4,
//      output   [ 7: 0]   HEX5,
//
//      ///////// SDRAM /////////
//      output             DRAM_CLK,
//      output             DRAM_CKE,
//      output   [12: 0]   DRAM_ADDR,
//      output   [ 1: 0]   DRAM_BA,
//      inout    [15: 0]   DRAM_DQ,
//      output             DRAM_LDQM,
//      output             DRAM_UDQM,
//      output             DRAM_CS_N,
//      output             DRAM_WE_N,
//      output             DRAM_CAS_N,
//      output             DRAM_RAS_N,
//
//      ///////// VGA /////////
//      output             VGA_HS,
//      output             VGA_VS,
//      output   [ 3: 0]   VGA_R,
//      output   [ 3: 0]   VGA_G,
//      output   [ 3: 0]   VGA_B,
//
//
//      ///////// ARDUINO /////////
//      inout    [15: 0]   ARDUINO_IO,
//      inout              ARDUINO_RESET_N 
//
//);
//
//
//
//
//logic Reset_h, vssig, blank, sync, VGA_Clk, Run_h;
//logic w_key, a_key, d_key;
//
//
////=======================================================
////  REG/WIRE declarations
////=======================================================
//	logic SPI0_CS_N, SPI0_SCLK, SPI0_MISO, SPI0_MOSI, USB_GPX, USB_IRQ, USB_RST;
//	logic [3:0] hex_num_4, hex_num_3, hex_num_1, hex_num_0; //4 bit input hex digits
//	logic [1:0] signs;
//	logic [1:0] hundreds;
//	logic [9:0] drawxsig, drawysig;
//	logic [7:0] Red, Blue, Green;
//	logic [7:0] keycode;
//	logic [9:0] Player_X, Player_Y;
//	logic is_player, player_on_ground, player_is_walking;
//	logic [9:0] player_address;
//	logic [1:0] player_walk_frame;
//
////=======================================================
////  Structural coding
////=======================================================
//	assign ARDUINO_IO[10] = SPI0_CS_N;
//	assign ARDUINO_IO[13] = SPI0_SCLK;
//	assign ARDUINO_IO[11] = SPI0_MOSI;
//	assign ARDUINO_IO[12] = 1'bZ;
//	assign SPI0_MISO = ARDUINO_IO[12];
//	
//	assign ARDUINO_IO[9] = 1'bZ; 
//	assign USB_IRQ = ARDUINO_IO[9];
//		
//	//Assignments specific to Circuits At Home UHS_20
//	assign ARDUINO_RESET_N = USB_RST;
//	assign ARDUINO_IO[7] = USB_RST;//USB reset 
//	assign ARDUINO_IO[8] = 1'bZ; //this is GPX (set to input)
//	assign USB_GPX = 1'b0;//GPX is not needed for standard USB host - set to 0 to prevent interrupt
//	
//	//Assign uSD CS to '1' to prevent uSD card from interfering with USB Host (if uSD card is plugged in)
//	assign ARDUINO_IO[6] = 1'b1;
//	
//	
//	//Assign one button to reset
//	assign {Reset_h}=~ (KEY[0]);
//	assign {Run_h}= 0;                                   //change this
//
//
//	
//	
//	//==========================================================================================================================================
//
//	
//	
//	
//	
//	
//	
//	lab62_soc u0 (
//		.clk_clk                           (MAX10_CLK1_50),  //clk.clk
//		.reset_reset_n                     (1'b1),           //reset.reset_n
//		.altpll_0_locked_conduit_export    (),               //altpll_0_locked_conduit.export
//		.altpll_0_phasedone_conduit_export (),               //altpll_0_phasedone_conduit.export
//		.altpll_0_areset_conduit_export    (),               //altpll_0_areset_conduit.export
//		.key_external_connection_export    (KEY),            //key_external_connection.export
//
//		//SDRAM
//		.sdram_clk_clk(DRAM_CLK),                            //clk_sdram.clk
//		.sdram_wire_addr(DRAM_ADDR),                         //sdram_wire.addr
//		.sdram_wire_ba(DRAM_BA),                             //.ba
//		.sdram_wire_cas_n(DRAM_CAS_N),                       //.cas_n
//		.sdram_wire_cke(DRAM_CKE),                           //.cke
//		.sdram_wire_cs_n(DRAM_CS_N),                         //.cs_n
//		.sdram_wire_dq(DRAM_DQ),                             //.dq
//		.sdram_wire_dqm({DRAM_UDQM,DRAM_LDQM}),              //.dqm
//		.sdram_wire_ras_n(DRAM_RAS_N),                       //.ras_n
//		.sdram_wire_we_n(DRAM_WE_N),                         //.we_n
//
//		//USB SPI	
//		.spi0_SS_n(SPI0_CS_N),
//		.spi0_MOSI(SPI0_MOSI),
//		.spi0_MISO(SPI0_MISO),
//		.spi0_SCLK(SPI0_SCLK),
//		
//		//USB GPIO
//		.usb_rst_export(USB_RST),
//		.usb_irq_export(USB_IRQ),
//		.usb_gpx_export(USB_GPX),
//		
//		//LEDs and HEX
//		
//		.keycode_export(keycode)
//		
//	 );
//
//
////instantiate a vga_controller, ball, and color_mapper here with the ports.
//
//
//	vga_controller vga(
//		.Clk          (MAX10_CLK1_50),
//		.Reset        (Reset_h),
//		.hs			  (VGA_HS),
//		.vs           (VGA_VS),
//		.pixel_clk    (VGA_Clk),
//		.blank        (blank),
//		.sync         (sync),
//		.DrawX        (drawxsig),
//		.DrawY        (drawysig)
//	
//	);
//	
//	
////color_mapper cm(
////			.VGACLK(VGA_Clk),
////		  .is_player(is_player),
////		  .player_on_ground(player_on_ground), 
////		  .player_is_walking(player_is_walking),
////		  .player_walk_frame(player_walk_frame), 
////		  .player_address(player_address),
////		  .DrawX(drawxsig),
////		  .DrawY(drawysig),
////        .Red(VGA_R), 
////		  .Green(VGA_G), 
////		  .Blue(VGA_B)
////	);
//
//	
//	
//
//	
//	keycode_map keycodemap(
//	
//		.keycode(keycode),
//		.w_key (w_key),
//		.a_key (a_key),
//		.d_key (d_key)
//	);
//	
//	
//	
//	
//	
//	
//player HatMan(
//	 .clk(MAX10_CLK1_50), 
//	 .reset(Reset_h), 
//	 .run(Run_h), 
//	 .frame_clk(VGA_VS),
//	 .DrawX(drawxsig), 
//	 .DrawY(drawysig),
//	 .w_pressed(w_key), 
//	 .a_pressed(a_key), 
//	 .d_pressed(d_key),
//	 .player_X(Player_X), 
//	 .player_Y(player_Y), 
//	 .is_player(is_player),
//	 .player_address(player_address),
//	 .on_ground(player_on_ground), 
//	 .is_walking(player_is_walking), 
//	 .walk_frame(player_walk_frame),
//);
//
//Hat_man1_example hatman1(
//		.vga_clk(VGACLK),
//		.DrawX(DrawX), 
//		.DrawY(DrawY),
//		.blank(blank),
//		.red(VGA_R), 
//		.green(VGA_G), 
//		.blue(VGA_B)
//);
//		 
//	 
//
//
//
//endmodule
