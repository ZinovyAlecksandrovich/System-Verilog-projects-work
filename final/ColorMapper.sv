module ColorMapper (
	input logic [9:0] DrawX, DrawY,
	input logic pixel_clk,
	input logic [9:0] PlayerX, PlayerY, PlayerSize,
	input logic [9:0] bulletX, bulletY, bulletSize,
	input logic blank,
	input logic [1:0] player_walk_frame,
	input logic player_is_walking, player_direction, player_hurt,
	input logic [9:0] BossX, BossY, BossSize, boss_health,
	input logic [1:0] walk_frame_boss,
	input logic is_walking_boss, boss_direction, boss_special_attack, elec_frame,
	input logic game_over, menu, intro,
	output logic [3:0] red, green, blue
	
);


int DistX, DistY;
assign DistX = DrawX - (PlayerX-PlayerSize);
assign DistY = DrawY - (PlayerY-PlayerSize);

int boss_DistX, boss_DistY;
assign boss_DistX = DrawX - (BossX-BossSize);
assign boss_DistY = DrawY - (BossY-BossSize);

logic [3:0] boss_red, boss_green, boss_blue;
logic [13:0] boss_address;
logic is_boss;


logic [3:0] player_stand_red, player_stand_green, player_stand_blue;
logic [3:0] player_walk1_red, player_walk1_green, player_walk1_blue;
logic [3:0] player_walk2_red, player_walk2green, player_walk2_blue;
logic [3:0] player_walk3_red, player_walk3_green, player_walk3_blue;
logic [3:0] player_hurt_red, player_hurt_green, player_hurt_blue;

logic [3:0] devil_still_red, devil_still_green, devil_still_blue;
logic [3:0] devil_walk1_red, devil_walk1_green, devil_walk1_blue;
logic [3:0] devil_walk2_red, devil_walk2_green, devil_walk2_blue;
logic [3:0] devil_walk3_red, devil_walk3_green, devil_walk3_blue;

logic [3:0] player_red, player_green, player_blue;
logic is_player;
logic [13:0] player_address;


logic [14:0] background_address;
logic [3:0] background_red, background_green, background_blue;
assign background_address = ((DrawX * 210) / 640) + (((DrawY * 120) / 480) * 210);


logic [6:0] bullet_address;
logic [3:0] bullet_red, bullet_green, bullet_blue;
logic is_bullet;


int bullet_DistX, bullet_DistY;
assign bullet_DistX = DrawX - (bulletX - bulletSize);
assign bullet_DistY = DrawY - (bulletY - bulletSize);

logic is_health;

 logic [12:0] title_address;
 assign title_address = (DrawX - 230) + (DrawY - 42) * 185;
 logic [3:0] title_red, title_green, title_blue;
 logic is_title;


logic [12:0] brick_address;
logic [3:0] brick_red, brick_green, brick_blue;
logic [3:0] brick_normal_red, brick_normal_green, brick_normal_blue;
logic [3:0] brick_elec1_red, brick_elec1_green, brick_elec1_blue;
logic [3:0] brick_elec2_red, brick_elec2_green, brick_elec2_blue;
logic is_platform, is_floor;
assign brick_address = (DrawX-220) + (DrawY - 250) * 100;


logic [14:0] menu_address, intro_address;
logic [12:0] gameover_address;
logic is_menu, is_gameover, is_intro;

assign menu_address = (DrawX - 215) + (DrawY - 200) * 210;



logic [3:0] menu_red, menu_green, menu_blue;
logic [3:0] intro_red, intro_green, intro_blue;
logic [3:0] go_red, go_green, go_blue;

//===================================================== SPRITES ==============================================================================================================
  always_comb
    begin:Player_on_proc
        if ((DrawX >= PlayerX - PlayerSize) &&
       (DrawX <= PlayerX + PlayerSize) &&
       (DrawY >= PlayerY - PlayerSize) &&
       (DrawY <= PlayerY + PlayerSize) &&
		 ({player_red, player_green, player_blue} != 12'hF0D)  ) begin//transparency
            is_player = 1'b1;
		end
		else begin
			is_player = 1'b0; 
		end 
	end
always_comb 
	begin: Bullet_on_proc
		if ((DrawX >= bulletX - 2) &&
		(DrawX <= bulletX + 2) &&
		(DrawY >= bulletY - 2) &&
		(DrawY <= bulletY + 2) ) begin 
				is_bullet = 1'b1;
			end
		else begin
			is_bullet = 1'b0;
		end
	end
	
always_comb 
	begin: Boss_on_proc
		if ((DrawX >= BossX - BossSize) &&
			 (DrawX <= BossX + BossSize) &&
			 (DrawY >= BossY - BossSize) &&
			 (DrawY <= BossY + BossSize) &&
			 ({boss_red, boss_green, boss_blue} != 12'hF0D)  ) begin//transparency
				is_boss = 1'b1;
			 end
		
		else begin
			is_boss = 1'b0;
		end
	
	end
//===================================================== GAME ATTRIBUTES ==========================================================================================
always_comb	
	begin: HealthBar_on_proc
		if ((DrawX >= 160) &
			 (DrawX <= 160 + boss_health) &&
			 (DrawY >= 30) &&
			 (DrawY <= 38)) begin
				is_health = 1'b1;
			 end
		
		else begin
			is_health = 1'b0;
		end

	end

always_comb	
	begin: Title_on_proc
			if ((DrawX >= 230) &&
			 (DrawX <= 410) &&
			 (DrawY >= 42) &&
			 (DrawY <= 68) &&
			 ({title_red, title_green, title_blue} != 12'hF09)) 
			 begin
				is_title = 1'b1;
			 end
		
		else begin
			is_title = 1'b0;
		end

	end

always_comb	
	begin: Platform_on_proc
			if ((DrawX >= 220) &&
			 (DrawX <= 420) &&
			 (DrawY >= 250) &&
			 (DrawY <= 280) )
			 begin
				is_platform = 1'b1;
			 end
			 else 
			 begin
				is_platform = 1'b0;
			 end
	end
	
	
	always_comb	
	begin: Floor_on_proc
			if ((DrawY >= 420) &&
			 (DrawY <= 450))
			 begin
				is_floor = 1'b1;
			 end
			 else 
			 begin
				is_floor = 1'b0;
			 end
	end
	
always_comb	
	begin: Menu_on_proc
			if ((DrawX >= 215) &&
			 (DrawX <= 425) &&
			 (DrawY >= 200) &&
			 (DrawY <= 350))
			 begin
				is_menu = 1'b1;
			 end
			 else 
			 begin
				is_menu = 1'b0;
			 end
	end

	 

	always_ff @ (posedge pixel_clk)
       
    begin:RGB_Display
		if(blank)
			begin
			if (menu) begin
				if (is_menu) begin
					red <= menu_red;
					green <= menu_green;
					blue <= menu_blue;
				end
				else
				begin
					red <= 4'h0;
					green <= 4'h0;
					blue <= 4'h0;
				end
			end 
			else begin
			if (is_player == 1'b1)
				begin 
				red <= player_red;
				green <= player_green;
				blue <= player_blue;
				end   

			else if(is_bullet == 1'b1) 
				begin
				red <= 4'h1;
				green <= 4'hF;
				blue <= 4'h0;
				end    
			
			else if (is_boss == 1'b1)
				begin

				if (boss_special_attack &&
				{boss_red, boss_green, boss_blue} == 12'hAA0) begin
					red <= 4'h0;
					green <= 4'hE;
					blue <= 4'hD;
					end
				else begin
					red <= boss_red;
					green <= boss_green; 
					blue <= boss_blue;
					end

				end
			
			else if (is_health == 1'b1)
			begin
			red <= 4'hF;
			green <= 4'hF;
			blue <= 4'h0;
			end

			else if (is_title == 1'b1)
			begin
			red <= title_red;
			green <= title_green;
			blue <= title_blue;
			end

			else if (is_platform == 1'b1)
			begin
			red <= brick_red;
			green <= brick_green;
			blue <= brick_blue;
			end

			else if (is_floor == 1'b1)
			begin
			red <= brick_normal_red;
			green <= brick_normal_green;
			blue <= brick_normal_blue;
			end

			else 
				begin 
						red <= background_red; 
						green <= background_green; //CHANGE TO BACKGROUND
						blue <= background_blue;
				end   
			end

		end	  

	 
	 
	 else 
	 begin 
		red <= 4'h0; 
		green <= 4'h0;
		blue <= 4'h0;
	end 
	
end

//============================================== PLAYER WALKING =================================================================================================================
	always_comb begin: Player_walk
		if (player_is_walking) begin

			case (player_walk_frame) 

			0 : begin 
				player_red = player_walk1_red;
				player_green = player_walk1_green;
				player_blue = player_walk1_blue;
			end

			1 : begin
				player_red = player_walk2_red;
				player_green = player_walk2_green;
				player_blue = player_walk2_blue;
			end

			2 : begin
				player_red = player_walk3_red;
				player_green = player_walk3_green;
				player_blue = player_walk3_blue;
			end
			
			default : begin
				player_red = player_stand_red;
				player_green = player_stand_green;
				player_blue = player_stand_blue;
			end

			endcase

		end
		else if (player_hurt) begin
			player_red = player_hurt_red;
			player_green = player_hurt_green;
			player_blue = player_hurt_blue;
		end
		else begin
			player_red = player_stand_red;
			player_green = player_stand_green;
			player_blue = player_stand_blue;
		end
		
		
		
		if (player_direction == 0)
			if (DistX < PlayerSize)
				player_address = (PlayerSize*2-DistX) + DistY * PlayerSize*2;
			else if (DistX > PlayerSize)
				player_address = (0-DistX) + (DistY+1) * PlayerSize*2;
			else
				player_address = DistX + DistY * PlayerSize*2;
		else
			player_address = DistX + DistY * PlayerSize*2;
		
		
	end
//========================================================================== ELECTRICITY =========================================================================================
	always_comb begin : block_electricity_animation
		if (boss_special_attack) begin
			case (elec_frame) 

			0: begin
				brick_red = brick_elec1_red;
				brick_green = brick_elec1_red;
				brick_blue = brick_elec1_red;
			end

			1: begin
				brick_red = brick_elec2_red;
				brick_green = brick_elec2_red;
				brick_blue = brick_elec2_red;
			end

			endcase
		end

		else begin
			brick_red = brick_normal_red;
			brick_green = brick_normal_green;
			brick_blue = brick_normal_blue;
		end
	end

//======================================= BOSS WALKING ====================================================================================================================== 

	always_comb begin: Boss_walk
		if (is_walking_boss) begin

			case (walk_frame_boss) 

			0 : begin 
				boss_red = devil_walk1_red;
				boss_green = devil_walk1_green;
				boss_blue = devil_walk1_blue;
			end

			1 : begin
				boss_red = devil_walk2_red;
				boss_green = devil_walk2_green;
				boss_blue = devil_walk2_blue;
			end

			2 : begin
				boss_red = devil_walk3_red;
				boss_green = devil_walk3_green;
				boss_blue = devil_walk3_blue;
			end
			
			default : begin
				boss_red = devil_still_red;
				boss_green = devil_still_green;
				boss_blue = devil_still_blue;
			end

			endcase

		end
		else begin
			boss_red = devil_still_red;
			boss_green = devil_still_green;
			boss_blue = devil_still_blue;
		end
		
		
		
		if (boss_direction == 0)
			if (boss_DistX < BossSize)
				boss_address = (BossSize*2-boss_DistX) + boss_DistY * (BossSize*2);
			else if (boss_DistX > BossSize)
				boss_address = (0-boss_DistX) + (boss_DistY+1) * (BossSize*2);
			else
				boss_address = boss_DistX + boss_DistY * (BossSize*2);
		else
			boss_address = boss_DistX + boss_DistY * (BossSize*2);
		
		
	end



//===============================================================PLAYER SPRITES=================================================================================

		hatman1 player_stand(
			//IN
			.address(player_address),
			//OUT
		   .red(player_stand_red), 
			.green(player_stand_green), 
			.blue(player_stand_blue) );

		hatman2 player_walk1(
			//IN
			.address(player_address),
			//OUT
		   .red(player_walk1_red), 
			.green(player_walk1_green), 
			.blue(player_walk1_blue) );

		hatman3 player_walk2(
			//IN
			.address(player_address),
			//OUT
		   .red(player_walk2_red), 
			.green(player_walk2_green), 
			.blue(player_walk2_blue) );

		hatman4 player_walk3(
			//IN
			.address(player_address),
			//OUT
		   .red(player_walk3_red), 
			.green(player_walk3_green), 
			.blue(player_walk3_blue) );	

		hatman_hurt hatman1_hurt(
			//IN
			.address(player_address),
			//OUT
		    .red(player_hurt_red), 
			.green(player_hurt_green), 
			.blue(player_hurt_blue) );	

//=============================================================DUNGEON BACKGROUND===================================================================================

		brick br(
			//IN
			.address(brick_address),
			//OUT
		   .red(brick_normal_red), 
			.green(brick_normal_green), 
			.blue(brick_normal_blue) );
		
		brick_elec1 bre1(
			//IN
			.address(brick_address),
			//OUT
		   .red(brick_elec1_red), 
			.green(brick_elec1_green), 
			.blue(brick_elec1_blue) );
		
		brick_elec2 bre2(
			//IN
			.address(brick_address),
			//OUT
		   .red(brick_elec2_red), 
			.green(brick_elec2_green), 
			.blue(brick_elec2_blue) );

		game_background gb(
			//IN
			.address(background_address),
			//OUT
		   .red(background_red), 
			.green(background_green), 
			.blue(background_blue) );

		
		start menuu(
			//IN
			.address(menu_address),
			//OUT
		   .red(menu_red), 
			.green(menu_green), 
			.blue(menu_blue) );



//=========================================================== BOSS SPRITES ==================================================================================================

// devil_stand devilstand (
// 	.address(boss_address),
// 	.red(boss_red),
// 	.green(boss_green),
// 	.blue(boss_blue)
// );             

		devil1 devil_still(
			//IN
			.address(boss_address),
			//OUT
		   .red(devil_still_red), 
			.green(devil_still_green), 
			.blue(devil_still_blue) );

		devil2 devil_walk1(
			//IN
			.address(boss_address),
			//OUT
		   .red(devil_walk1_red), 
			.green(devil_walk1_green), 
			.blue(devil_walk1_blue) );

		devil3 devil_walk2(
			//IN
			.address(boss_address),
			//OUT
		   .red(devil_walk2_red), 
			.green(devil_walk2_green), 
			.blue(devil_walk2_blue) );

		devil4 devil_walk3(
			//IN
			.address(boss_address),
			//OUT
		   .red(devil_walk3_red), 
			.green(devil_walk3_green), 
			.blue(devil_walk3_blue) );		
		

//=========================================================== BOSS TEXT ===================================================================================================================================

		BossTitle bosstitle(
			//IN
			.address(title_address),
			//OUT
		   .red(title_red), 
			.green(title_green), 
			.blue(title_blue) );	


endmodule
