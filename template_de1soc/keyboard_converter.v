module keyboard_converter(clk,keyin,key_update,res_song,direction,pause,start_audio,state);

input clk, key_update;
input [7:0] keyin;

output start_audio;

output res_song, direction, pause;

output reg [5:0] state;
reg [8:0] key_values;

parameter lower_upper = 6'b000_000;
parameter check_key = 6'b001_000;
parameter b_state = 6'b010_010;
parameter d_state = 6'b011_100;
parameter e_state = 6'b100_000;
parameter f_state = 6'b101_000;
parameter r_state_for = 6'b110_001;
parameter r_state_back = 6'b111_011;

assign res_song = state[0];
assign direction = state[1];
assign pause = state[2];

always @(posedge clk)
begin
	
	if (key_update) start_audio = 1'b1;
	
	casex(state)
	
	lower_upper:begin
	state <= check_key;

	if (keyin == 8'h42) //check for b key
		state <= b_state;
	else if (keyin == 8'h44)//check for d key
		state <= d_state;
	else if (keyin == 8'h45)//check for e key
		state <= e_state;
	else if (keyin == 8'h46)//check for f key
		state <= f_state;
	else if (keyin == 8'h52) begin//check for r key
		if (direction==1) state <= r_state_back;
		else state <= r_state_for;
		end
		
	end
	
		r_state_for :begin
		if(key_update) state <= lower_upper;//leave whenever a key change
		else state <= state;
		end
		
		f_state:begin
		if(key_update) state <= lower_upper;
		else state <= state;
		end
		
		b_state:begin
		if(key_update) state <= lower_upper;
		else state <= state;
		end
		
		e_state:begin
		if(key_update) state <= lower_upper;
		else state <= state;
		end
		
		d_state:begin
		if(keyin == 8'h45) state <= lower_upper;//only leave d state if e key
		else state <= state;
		end

	default: begin
	state <= d_state;
	end
	
	endcase

end

		
endmodule

	