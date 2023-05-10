
//-------------------------------------------------------------------------
//    Player.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf 03-01-2006                               --
//                              03-12-2007                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Fall 2014 Distribution                                             --
//                                                                       --
//    For use with ECE 298 Lab 7                                         --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------


module  Player ( input Reset, frame_clk,
				 input [7:0] keycode,
				 input [9:0] BossX, BossY, BossS, boss_health,
				 output [9:0]  PlayerX, PlayerY, PlayerS,
				 output [9:0]  bulletX, bulletY, bulletS,
				 output logic [1:0] walk_frame,
				 output logic is_walking,
				 output logic direction,
				 output logic[3:0] player_lives,
				 output logic player_hurt, elec_frame, boss_special_attack,
				 output logic game_over, menu
					);
    
    logic [9:0] PlayerX_Pos, PlayerX_Motion, PlayerY_Pos, PlayerY_Motion, Player_Size;
	logic on_ground, bottom_collision, top_collision, right_collision, left_collision;
	logic barrmid_top_collision, barrmid_bottom_collision, barrmid_left_collision, barrmid_right_collision;
	logic [9:0] walk_delay, jump_delay, hurt_delay, special_delay, elec_delay, intro_delay;
	logic jumping_up;
	logic bullet_spawn;
	logic [9:0] bulletX_Pos, bulletY_Pos;
	int bulletX_Motion;
	logic [9:0] bullet_Size;

	logic special_on;


	 
    parameter [9:0] PlayerX_Center= 200;  // Center position on the X axis
    parameter [9:0] PlayerY_Center = 384;  // 429Center position on the Y axis
    parameter [9:0] LevelX_Min=1;       // Leftmost point on the X axis
    parameter [9:0] LevelX_Max=639;     // Rightmost point on the X axis
    parameter [9:0] LevelY_Min=1;       // Topmost point on the Y axis
    parameter [9:0] LevelY_Max=419;     // Bottommost point on the Y axis
    parameter [9:0] PlayerX_Step=5;      // Step size on the X axis
    parameter [9:0] PlayerY_Step=5;      // Step size on the Y axis

    assign Player_Size = 35;  // assigns the value 4 as a 10-digit binary number, ie "0000000100"                   
	
    always_ff @ (posedge Reset or posedge frame_clk or posedge game_over or posedge menu)
    begin: Move_Player
        if (Reset || game_over)  // Asynchronous Reset
        begin 
            PlayerY_Motion <= 10'd0; //Player_Y_Step;
				PlayerX_Motion <= 10'd0; //Player_X_Step;
				PlayerY_Pos <= PlayerY_Center;
				PlayerX_Pos <= PlayerX_Center;

				walk_delay <= 0;
				direction <= 1;
				jumping_up <= 0;
				jump_delay <= 1;
				player_lives <= 5;
				player_hurt <= 0;
				special_delay <= 1;
				special_on <= 0;
				boss_special_attack <= 0;
				menu <= 1;
				game_over <= 0;
	


				
        end

		else if (menu) begin

			if (keycode) begin
				menu <= 0;
			end
				
		end


        else 
        begin 

				//WALK TIMER
				is_walking <= 0;

				if(walk_delay > 500)
					walk_delay <= 0;
				else
					walk_delay <= walk_delay + 1'd1;
		
				if(walk_delay % 5 == 0) begin
					if (is_walking) begin
						if(walk_frame < 2) 
							walk_frame <= walk_frame + 1;
						else if (walk_frame == 2)
							walk_frame <= 0;
					end
				end
			


				PlayerY_Pos <= (PlayerY_Pos + PlayerY_Motion);  // Update Player position
				PlayerX_Pos <= (PlayerX_Pos + PlayerX_Motion);


				//COLISSION
				if (bottom_collision) begin
					PlayerY_Pos <= 384; 
					PlayerY_Motion <= 0;
				end
				if (left_collision || barrmid_left_collision)
					PlayerX_Motion <= 0;
				if (right_collision || barrmid_right_collision)
					PlayerX_Motion <= 0;
				if (top_collision || barrmid_bottom_collision)
					PlayerY_Motion <= 0;
				
			


				 case (keycode)
					8'h04 : begin
						if (!left_collision) begin
								PlayerX_Motion <= -5;//A
								is_walking <= 1;
								direction <= 0;

							if (barrmid_top_collision) 
								PlayerY_Motion <= 0;
							else
								PlayerY_Motion <= 7;
						end
								
					end
					        
					8'h07 : begin
						if (!right_collision) begin
					        PlayerX_Motion <= 5;//D
							is_walking <= 1;
							direction <= 1;
							PlayerY_Motion <= 7;
						end
					end
							  
					8'h1A : begin
						if ((bottom_collision || barrmid_top_collision) &&
							!barrmid_bottom_collision &&
							!top_collision &&
							!jumping_up) begin //W
							jumping_up <= 1;
						end	  
						else 
							PlayerY_Motion <= 7;

					end

					default: begin
							  PlayerY_Motion <= 7;
							  PlayerX_Motion <= 0;
							end

					
			   endcase 

				//JUMP TIMER
			   	if (jumping_up) begin
					PlayerY_Motion <= -10;
					if (jump_delay % 20 == 0) begin
						jumping_up <= 0;
						jump_delay <= 1;
					end
					else
						jump_delay <= jump_delay + 1;
				end

			if (((PlayerX_Pos + Player_Size) >= BossX - BossS + 30) &&
				((PlayerX_Pos - Player_Size) <= BossX + BossS - 30) &&
				(PlayerY_Pos+Player_Size) >= (BossY-BossS) ) begin
					player_hurt <= 1;
					hurt_delay <= 1;
				end

			

			if (player_hurt) begin
				if (hurt_delay % 80 == 0) begin
						player_lives <= player_lives - 1;
						player_hurt <= 0;
						hurt_delay <= 1;
					end
					else
						hurt_delay <= hurt_delay + 1;
				end
			
			
			if (special_on) begin
				if (special_delay % 160 == 0 && barrmid_top_collision) begin
						boss_special_attack <= 1;
						special_delay <= 1;
						special_on <= 0;
					end
					else
						special_delay <= special_delay + 1;

			end

				if(elec_delay > 500)
					elec_delay <= 0;
				else
					elec_delay <= elec_delay + 1'd1;
		

				if(elec_delay % 5 == 0) begin
					if (boss_special_attack) begin
						if(elec_frame == 0) 
							elec_frame <= 1;
						else if (elec_frame == 1) begin
							player_hurt <= 1;
							elec_frame <= 0;
							end
						if (elec_delay % 120 == 0)
							boss_special_attack <= 0;
					end
				end


			//PLATFORM COLLISION
			if (barrmid_top_collision) begin
				if (!special_on && !boss_special_attack) begin
					special_on <= 1;
					special_delay <= 1;
				end
				PlayerY_Motion <= 0;
			end

			if (player_lives == 0)
				game_over <= 1;
			else if (boss_health == 0)
				game_over <= 1;

		end

	end

//===========================================SHOOTING MECHANICS ===============================================


always_ff @ (posedge Reset or posedge frame_clk) begin


		if(Reset) begin
			bulletX_Motion <= 0;

		end

		else begin
		

		case (keycode) 
			8'h2C : begin
				if (bulletX_Motion == 0) begin
					if (direction == 1) 
						bulletX_Motion <= 10;
					else 
						bulletX_Motion <= -10;
					end
				end
		endcase
		



		if (bulletX_Motion != 0) begin
			bulletX_Pos <= bulletX_Pos + bulletX_Motion;
			bulletY_Pos <= bulletY_Pos;

			if ($signed(bulletX_Pos + 2 + bulletX_Motion) >= LevelX_Max) begin//right edge
				bulletX_Motion <= 0;
			end
			else if ($signed(bulletX_Pos - 2 + bulletX_Motion <= LevelX_Min)) begin //left edge
				bulletX_Motion <= 0;
			end
			else if (($signed(bulletX_Pos - 2 + bulletX_Motion) >= BossX - BossS) &&
					(PlayerX_Pos <= BossX - BossS) ) //boss left side
				bulletX_Motion <= 0;
			else if (($signed(bulletX_Pos + 2 + bulletX_Motion) <= BossX + BossS) &&
					(PlayerX_Pos >= BossX + BossS)) //boss right side
				bulletX_Motion <= 0;
			else
				bulletX_Motion <= bulletX_Motion;

		end
		else begin
			bulletX_Pos <= PlayerX_Pos;
			bulletY_Pos <= PlayerY_Pos+17;
		end
		  
	end
end

//================================================= FOUR WALLS =============================================================================================================================================
always_comb begin
 	if ( (PlayerY_Pos + Player_Size + PlayerY_Motion) >= LevelY_Max ) begin
		bottom_collision = 1;
		on_ground = 1;
	end
	else begin
		bottom_collision = 0;
		on_ground = 0;
	end

	if ( ((PlayerY_Pos - Player_Size + PlayerY_Motion)) <= (LevelY_Min) )  // Player is at the top edge, BOUNCE!
		top_collision = 1;
	else
		top_collision = 0;
					  
	if ((PlayerX_Pos + Player_Size + PlayerX_Motion) >= (LevelX_Max ))  // Player is at the Right edge, BOUNCE!
		right_collision = 1;
	else
		right_collision = 0;
					  
	if ( (PlayerX_Pos - Player_Size + PlayerX_Motion) <= (LevelX_Min) )  // Player is at the Left edge, BOUNCE!
		left_collision = 1;
	else
		left_collision = 0;

//======================================== PLATFORMS ===============================================================================================================================

//MIDDLE PLATFORM
//     X: 220 - 420,          Y: 190 - 220
	if (PlayerY_Pos + Player_Size + PlayerY_Motion >= 250 &&
		(PlayerY_Pos - Player_Size + PlayerY_Motion) <= 260 &&
		(PlayerX_Pos + Player_Size + PlayerX_Motion) >= 220 &&
		(PlayerX_Pos - Player_Size*2 + PlayerX_Motion) <= 420 )
		barrmid_top_collision = 1;
	else
		barrmid_top_collision = 0;

	if ( ((PlayerY_Pos - Player_Size + PlayerY_Motion)) <= 280 && 
		PlayerY_Pos + Player_Size + PlayerY_Motion >= 270 &&
		(PlayerX_Pos - Player_Size + PlayerX_Motion) >= 220 && //opposite
		(PlayerX_Pos + Player_Size + PlayerX_Motion) <= 420 )
		barrmid_bottom_collision = 1;
	else
		barrmid_bottom_collision = 0;
					  
	if ((PlayerX_Pos + Player_Size + PlayerX_Motion) >= 220 &&
		PlayerX_Pos - Player_Size + PlayerX_Motion <= 230 &&
		PlayerY_Pos + Player_Size + PlayerY_Motion >= 250 &&
		PlayerY_Pos - Player_Size + PlayerY_Motion <= 280)  
		barrmid_left_collision = 1;
	else
		barrmid_left_collision = 0;
					  
	if ( (PlayerX_Pos - Player_Size + PlayerX_Motion) <= 420 &&
		(PlayerX_Pos + Player_Size + PlayerX_Motion) >= 410 &&
		PlayerY_Pos + Player_Size + PlayerY_Motion >= 250 &&
		PlayerY_Pos - Player_Size + PlayerY_Motion <= 280   )
		barrmid_right_collision = 1;
	else
		barrmid_right_collision = 0;
	



	

					  

		
			 
		PlayerX = PlayerX_Pos;
		
		PlayerY = PlayerY_Pos;
		
		PlayerS = Player_Size;

		bulletX= bulletX_Pos;
		
		bulletY = bulletY_Pos;
		
		bulletS = bullet_Size;

 end




endmodule
	