module levels(
	input [9:0] DrawX, DrawY,
	output is_barrier
);








always_comb begin

	if((DrawX < 0) || (DrawX >= 640) || (DrawY < 0) || (DrawY >= 480)) begin
		is_barrier = 1'b1;
		end
	else
		is_barrier = 1'b0;
			
end












endmodule 





















