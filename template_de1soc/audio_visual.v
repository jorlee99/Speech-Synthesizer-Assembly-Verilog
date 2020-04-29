module audio_visual(clk,start,audio_signal,ledon,state);

input clk,start;
input [7:0] audio_signal;

output reg [7:0] ledon;

output reg [2:0]state;
reg [7:0] audio_store;
reg [15:0] total_sum;
reg [7:0] output_value;
reg [7:0] counter;

parameter idle = 3'b000;
parameter abs_value = 3'b001;
parameter summation = 3'b010;
parameter average = 3'b011;
parameter visual_code = 3'b100;
parameter reset_state = 3'b101;

always @(posedge clk)
begin

case(state)

	idle:
		if (start) state <= abs_value;

	abs_value:
	begin
		if (audio_signal < 8'h80)
			begin
				audio_store <= audio_signal;
				state <= summation;
			end

		else 
			begin
				audio_store <= (~audio_signal) + 1'b1;
				state <= summation;
			end
	end
	
	summation:
	begin
		if (counter == 8'd255)begin
			state <= visual_code;
			output_value <= (total_sum>>8);
			end
		else if (audio_signal == 8'hBC)
			begin
				counter <= counter + 1'b1;
				total_sum <= total_sum + 0;
				state <= idle;
			end
		else
			begin
			counter <= counter + 1'b1;
			total_sum <= total_sum + audio_store;
			state <= idle;
		end
	end
			
	
	visual_code:
	begin
	state <= reset_state;
		if (output_value > 8'h80)
			ledon <= 8'b1111_1111;
		else if (output_value > 8'h40)
			ledon <= 8'b1111_1110;
		else if (output_value > 8'h20)
			ledon <= 8'b1111_1100;
		else if (output_value > 8'h10)
			ledon <= 8'b1111_1000;
		else if (output_value > 8'h08)
			ledon <= 8'b1111_0000;
		 else if (output_value > 8'h04)
			ledon <= 8'b1110_0000;
		 else if (output_value > 8'h02)
			ledon <= 8'b1100_0000;
		 else if (output_value > 8'h01)
			ledon <= 8'b1000_0000;
		else 
			ledon <= 8'b0000_0000;
	end
	
	reset_state:
		begin
			counter <= 8'b0;
			total_sum <= 16'b0;
			audio_store <= 8'b0;
			state <= idle;
		end
		
	default: state<=idle;
	
	endcase
end
		
			
endmodule
