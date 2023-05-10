module  Boss ( input Reset, frame_clk,
				 input [9:0]  PlayerX, PlayerY, PlayerS,
				 input [9:0]  bulletX, bulletY, bulletS,
				 input logic menu, intro, game_over,
				 output logic [9:0]  BossX, BossY, BossS,
				 output logic [1:0] walk_frame,
				 output logic is_walking,
				 output logic direction,
				 output logic [9:0] health
					);
					
					
	logic [9:0] BossX_Pos, BossX_Motion, BossY_Pos, BossY_Motion, Boss_Size;
	logic on_ground, bottom_collision, top_collision, right_collision, left_collision;
	logic [9:0] walk_delay;
	logic jumping_up;
	logic [9:0] bullet_Size;


	 
    parameter [9:0] BossX_Center=500;  // Center position on the X axis
    parameter [9:0] BossY_Center=389;  // Center position on the Y axis
    parameter [9:0] LevelX_Min=1;       // Leftmost point on the X axis
    parameter [9:0] LevelX_Max=639;     // Rightmost point on the X axis
    parameter [9:0] LevelY_Min=1;       // Topmost point on the Y axis
    parameter [9:0] LevelY_Max=419;     // Bottommost point on the Y axis

    assign Boss_Size = 50;  // assigns the value 4 as a 10-digit binary number, ie "0000000100"                   
					
					
					
		
    always_ff @ (posedge Reset or posedge frame_clk or posedge menu or posedge game_over)
    begin: Move_Player
        if (Reset || menu || game_over)  // Asynchronous Reset
        begin 



				BossX_Motion <= 10'd0;
				BossY_Motion <= 10'd0;
				BossY_Pos <= BossY_Center;
				BossX_Pos <= BossX_Center;
				walk_delay <= 0;
				direction <= 1;
				is_walking <= 0;
				health <= 350;

				
        end
           
        else 
        begin 


			if(walk_delay > 500)
					walk_delay <= 0;
				else
					walk_delay <= walk_delay + 1'd1;
		
				if(walk_delay % 15 == 0) begin
					if (is_walking) begin
						if(walk_frame < 2) 
							walk_frame <= walk_frame + 1;
						else if (walk_frame == 2)
							walk_frame <= 0;
					end
				end
			

			BossX_Pos <= (BossX_Pos + BossX_Motion);
			BossY_Pos <= (BossY_Pos + BossY_Motion);

			if (top_collision || bottom_collision)
				BossY_Motion <= 0;
			if (left_collision || right_collision)
				BossX_Motion <= 0;
				
			//Movement AI
			if (BossX_Pos < PlayerX - PlayerS) begin
				BossX_Motion <= 1;
				direction <= 1;
				is_walking <= 1;
			end
			else if (BossX_Pos > PlayerX + PlayerS) begin
				BossX_Motion <= -1;
				direction <= 0;
				is_walking <= 1;
			end
			else begin
				BossX_Motion <= 0;
				is_walking <= 0;
				direction <= direction;
			end






			//health mechanics
			if ((int'(bulletX - 2) >= BossX_Pos - Boss_Size) &&
				(PlayerX <= BossX_Pos - Boss_Size) &&
				(BossX_Pos != PlayerX) &&
				(bulletY >= BossY_Pos - (Boss_Size+30)) &&
				(bulletY <= BossY_Pos + (Boss_Size+30))	&&
				bulletX < 640) //boss left side
				health <= health - 10;
			else if (($signed(bulletX + 2) <= BossX_Pos + Boss_Size) &&
					(PlayerX >= BossX_Pos + Boss_Size) &&
					(BossX_Pos != PlayerX) &&
					(bulletY >= BossY_Pos - (Boss_Size+30)) &&
					(bulletY <= BossY_Pos + (Boss_Size+30))	) //boss right side
				health <= health - 10;
			else	
				health <= health;

			
		end

	end	
					
always_comb begin
	if ( (BossY_Pos + Boss_Size + BossY_Motion) >= LevelY_Max ) begin
		bottom_collision = 1;
	end
	else 
		bottom_collision = 0;

	if ( ((BossY_Pos - Boss_Size + BossY_Motion)) <= (LevelY_Min) )  // Player is at the top edge, BOUNCE!
		top_collision = 1;
	else
		top_collision = 0;
					  
	if ((BossX_Pos + Boss_Size + BossX_Motion) >= (LevelX_Max ))  // Player is at the Right edge, BOUNCE!
		right_collision = 1;
	else
		right_collision = 0;
					  
	if ( (BossX_Pos - Boss_Size - 90 + BossX_Motion) <= (LevelX_Min) )  // Player is at the Left edge, BOUNCE!
		left_collision = 1;
	else
		left_collision = 0;


	BossX = BossX_Pos;
	BossY = BossY_Pos;
	BossS = Boss_Size;

end		
					
					
					
endmodule

