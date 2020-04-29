
module ipod_fsm(clock, aud_clk_22khz, start_read, direction, reset, timer_finish, address, byteenable,
 read_data_request/*start read*/, audio_finish, mem_read/*flash_mem_read*/, read_data, aud_data_out,
 addr_reset, pause, state); 

input clock,direction, reset,aud_clk_22khz,start_read, timer_finish,addr_reset,pause;  
input [31:0] read_data;

output read_data_request,audio_finish,mem_read; 
output [22:0] address; 
output [7:0] aud_data_out; 
output [3:0] byteenable; 

output reg [6:0] state;

parameter idle_state = 7'b0000_000; 
parameter read_state = 7'b0001_001; 
parameter finished = 7'b1111_010;

//data states
parameter data_left_prep = 7'b0010_000; 
parameter data_left_get = 7'b0011_000;
parameter data_right_prep = 7'b0100_000; 
parameter data_right_get = 7'b0101_000;  

// lag states 
parameter clock_wait1 = 7'b1010_000; 
parameter clock_wait2 = 7'b1011_000;

//address states
parameter address_check = 7'b0110_000; 
parameter address_incr = 7'b0111_000; 
parameter address_decr = 7'b1000_000;
parameter pause_state = 7'b1001_000;  

assign read_data_request = state[0]; //flag 
assign mem_read = state[0];  //output
assign audio_finish = state[1];  

assign byteenable = 4'b1111; //always read all data 
		
always_ff@(posedge clock) begin 
	case(state) 
		
		idle_state:if(start_read) state <= read_state; //idle
			  
		read_state:if(timer_finish) state <= data_left_prep; //if fsm_timer done
				   
		data_left_prep: if(aud_clk_22khz) state <= data_left_get; //sync clock 
				  
		data_left_get: begin
			state <= clock_wait1;
			address <= address;
			if (direction) aud_data_out <= read_data [31:16]; 
			else aud_data_out <= read_data [15:0]; 
		end

		clock_wait1: state <= data_right_prep;
		
		data_right_prep: if(aud_clk_22khz) state <= data_right_get; //sync clock
		
		data_right_get:begin
			state <= clock_wait2;
			address <= address;
			if(direction) aud_data_out <= read_data [15:0]; 
			else aud_data_out <= read_data [31:16]; 
		end
		clock_wait2: state <= address_check; 
				   
		address_check: begin 
				  if(direction) state <= address_decr; //direction check
				  else state <= address_incr; 
				  end 
				  
		address_decr: begin
		aud_data_out <= aud_data_out;	//audio output
			state <= finished;
			if (addr_reset) address <= 1'b0;
			else if (pause) state <= pause_state;	
				else 
				begin
					address <= address - 23'd1; 
							if (address == 0) 
								address <= 23'h7FFFF;  
						end

 		end 	
	 
		
		address_incr: begin 
		aud_data_out <= aud_data_out;
			state <= finished;
			if(addr_reset) address <= 1'b0;
			else if (pause) state <= pause_state;
				else 
				begin
						address <= address + 23'd1; 
						if (address == 23'h7FFFF) 
							address <= 0; 
						end					
		end 
		
		pause_state: begin //stay in pause state
		
		if (!pause) state<= address_check; //pause drops go back to address check
		
		end
		
		finished: state <= idle_state; 
		
		default:begin
		state <= idle_state;
		address <= address; 
		aud_data_out <= aud_data_out;	
		end
	endcase 
end
endmodule
