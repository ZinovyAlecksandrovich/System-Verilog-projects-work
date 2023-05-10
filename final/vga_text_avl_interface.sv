/************************************************************************
Avalon-MM Interface VGA Text mode display

Register Map:
0x000-0x0257 : VRAM, 80x30 (2400 byte, 600 word) raster order (first column then row)
0x258        : control register

VRAM Format:
X->
[ 31  30-24][ 23  22-16][ 15  14-8 ][ 7    6-0 ]
[IV3][CODE3][IV2][CODE2][IV1][CODE1][IV0][CODE0]

IVn = Draw inverse glyph
CODEn = Glyph code from IBM codepage 437

Control Register Format:
[[31-25][24-21][20-17][16-13][ 12-9][ 8-5 ][ 4-1 ][   0    ] 
[[RSVD ][FGD_R][FGD_G][FGD_B][BKG_R][BKG_G][BKG_B][RESERVED]

VSYNC signal = bit which flips on every Vsync (time for new frame), used to synchronize software
BKG_R/G/B = Background color, flipped with foreground when IVn bit is set
FGD_R/G/B = Foreground color, flipped with background when Inv bit is set

************************************************************************/
`define NUM_REGS 601 //80*30 characters / 4 characters per register
`define CTRL_REG 600 //index of control register

module vga_text_avl_interface (
	// Avalon Clock Input, note this clock is also used for VGA, so this must be 50Mhz
	// We can put a clock divider here in the future to make this IP more generalizable
	input logic CLK,
	
	// Avalon Reset Input
	input logic RESET,
	
	// Avalon-MM Slave Signals
	input  logic AVL_READ,					// Avalon-MM Read
	input  logic AVL_WRITE,					// Avalon-MM Write
	input  logic AVL_CS,					// Avalon-MM Chip Select
	input  logic [3:0] AVL_BYTE_EN,			// Avalon-MM Byte Enable
	input  logic [11:0] AVL_ADDR,			// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,		// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,		// Avalon-MM Read Data
	
	// Exported Conduit (mapped to VGA port - make sure you export in Platform Designer)
	output logic [3:0]  red, green, blue,	// VGA color channels (mapped to output pins in top-level)
	output logic hs, vs						// VGA HS/VS
);

logic [31:0] PALETTE [8]; // Registers
//put other local variables here
logic [9:0] DrawX, DrawY;
logic [10:0] address;
logic [7:0] data_rom;
logic [11:0] char_idx;
logic [10:0] reg_idx;
logic [1:0] cur_char;
logic Bit;
logic [15:0] CHAR;
logic blank;
logic pixel_clk;


//Declare submodules..e.g. VGA controller, ROMS, etc
vga_controller vga(   .Clk(CLK),       
                      .Reset(Reset_h),     
                      .hs(hs),        
							 .vs(vs),        
							 .pixel_clk(pixel_clk), 
							 .blank(blank),    
							 .sync(),      		             
							 .DrawX(DrawX),     
							 .DrawY(DrawY));
							 
							 

   
// Read and write from AVL interface to register block, note that READ waitstate = 1, so this should be in always_ff



logic [3:0] FG_idx, BG_idx;
logic [3:0] FG_red, FG_blue, FG_green;
logic [3:0] BG_red, BG_blue, BG_green;
logic [31:0] B_READDATA, ramout_a;
//handle drawing (may either be combinational or sequential - or both).



always_ff@(posedge CLK)
	begin
		if(AVL_ADDR[11] && AVL_WRITE && AVL_CS)
			begin
				PALETTE[AVL_ADDR[2:0]] <= AVL_WRITEDATA;
			end
		else if(AVL_ADDR[11] && AVL_READ && AVL_CS)
			begin
				AVL_READDATA <= PALETTE[AVL_ADDR[2:0]];
			end
//		else if(AVL_READ && AVL_CS)
//			begin
//				AVL_READDATA <= ramout_a;
//			end


	end




always_comb begin

	
	char_idx = DrawX[9:3] + (DrawY[9:4] * 80);
	reg_idx = char_idx[11:1];
	case (char_idx[0])
	
	1'b1 : 
		CHAR = B_READDATA[31:16];
	
	1'b0 : 
		CHAR = B_READDATA[15:0];
	
	
	endcase
	
	
	
	address =  CHAR[14:8] * 16 + DrawY[3:0]; 
	Bit = data_rom[7 - DrawX[2:0]];
	FG_idx = CHAR[7:4];
	BG_idx = CHAR[3:0];


	
end
	
	always_comb begin
		
		if (FG_idx[0]) begin
			FG_red = PALETTE[FG_idx[3:1]][24:21];
			FG_green = PALETTE[FG_idx[3:1]][20:17];
			FG_blue = PALETTE[FG_idx[3:1]][16:13];
		end
		else begin
			FG_red = PALETTE[FG_idx[3:1]][12:9];
			FG_green = PALETTE[FG_idx[3:1]][8:5];
			FG_blue = PALETTE[FG_idx[3:1]][4:1];
		end
		
		if(BG_idx[0]) begin
			BG_red = PALETTE[BG_idx[3:1]][24:21];
			BG_green = PALETTE[BG_idx[3:1]][20:17];
			BG_blue = PALETTE[BG_idx[3:1]][16:13];
		end
		else begin
			BG_red = PALETTE[BG_idx[3:1]][12:9];
			BG_green = PALETTE[BG_idx[3:1]][8:5];
			BG_blue = PALETTE[BG_idx[3:1]][4:1];
		end
		
	end
	
	
always_ff@(posedge pixel_clk) begin	
	
	
	if(~blank) begin
		red <= 4'b0;
		green <= 4'b0;
		blue <= 4'b0;
	end
	
	else begin
		if(CHAR[15] ^ Bit) begin
			red <= FG_red;
			green <= FG_green;
			blue <= FG_blue;
			end
		
			
	else begin 
			red <= BG_red;
			green <= BG_green;
			blue <= BG_blue;
			end
		
	end

end
		

endmodule
