module keycode_map(

input logic[23:0] keycode,
output logic w_key, a_key, d_key
);



always_comb begin

	w_key = (keycode[23:16] == 8'h1A || keycode[15:8] == 8'h1A || keycode[7:0] == 8'h1A);
	a_key = (keycode[23:16] == 8'h04 || keycode[15:8] == 8'h04 || keycode[7:0] == 8'h04);
	d_key = (keycode[23:16] == 8'h07 || keycode[15:8] == 8'h07 || keycode[7:0] == 8'h07);


end 


endmodule










