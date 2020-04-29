module clock_sync(main_clock,clock_in,out_clk);

input main_clock,clock_in;
output out_clk;

reg ff1,ff2,ff3;
wire reset;

always @ (posedge main_clock)
begin
	ff2 <= ff1;
end

always @ (posedge main_clock)
begin
	ff3 <= ff2;
end

always @ (posedge clock_in or posedge reset)
begin
	if(reset) ff1 <= 1'b0;
	else ff1 <= 1'b1;
end

always @ (negedge main_clock)
begin
	reset <= ff3;
	
end


assign out_clk = ff3;

endmodule
