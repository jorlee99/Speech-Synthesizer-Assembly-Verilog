
module ipod_fsm(clock, aud_clk_22khz, start_read, direction, reset, timer_finish, address, byteenable,
 read_data_request/*start read*/, audio_finish, mem_read/*flash_mem_read*/, read_data, aud_data_out,
 addr_reset, pause, state,silent,start_address,end_address,visual_start,pico_flag,pico_done); 

input clock,direction, reset,aud_clk_22khz,start_read, timer_finish,addr_reset,pause,pico_done;  
input [31:0] read_data;
input [23:0] start_address,end_address;
input silent;

output read_data_request,audio_finish,mem_read,pico_flag,visual_start; 
output [22:0] address; 
output [7:0] aud_data_out; 
output [3:0] byteenable; 

output reg [7:0] state;

parameter idle_state = 8'b00000_000; 
parameter read_state = 8'b00001_001; 
parameter finished = 8'b11111_010;

//data states
parameter data_1_prep = 8'b00010_000; 
parameter data_1_get = 8'b00011_100;
parameter data_2_prep = 8'b00100_000; 
parameter data_2_get = 8'b00101_100;  

// lag states 
parameter clock_wait1 = 8'b00110_000; 
parameter clock_wait2 = 8'b00111_000;

//address states
parameter address_check = 8'b01000_000; 
parameter address_incr = 8'b01001_000; 
parameter address_decr = 8'b01010_000;
parameter pause_state = 8'b01011_000;  

//newstates
parameter data_3_get = 8'b01100_100;
parameter data_3_prep =8'b01101_000;
parameter data_4_get = 8'b01110_100;
parameter data_4_prep = 8'b01111_000;

parameter clock_wait3  = 8'b10000_000;
parameter clock_wait4 = 8'b10001_000;

parameter  get_new_addr  = 8'b10010_000;

parameter flag_high = 8'b10011_000;
parameter get_select = 8'b10100_000;
parameter get_strt_address = 8'b10101_000;

assign read_data_request = state[0]; //flag 
assign mem_read = state[0];  //output
assign audio_finish = state[1];  
assign visual_start = state[2];
assign byteenable = 4'b1111; //always read all data 
		
always_ff@(posedge clock) begin 
	case(state) 
		
		idle_state:if(start_read) state <= read_state; //idle
			  
		read_state:if(timer_finish) state <= data_1_prep; //if fsm_timer done
				   
		data_1_prep: if(aud_clk_22khz) state <= data_1_get; //sync clock 
				  
		data_1_get: begin
			state <= clock_wait1;
			address <= address;
		if (silent)
			aud_data_out <= 8'hBC;
		else
			aud_data_out <= read_data [7:0]; 
		end

		clock_wait1: /*state<=address_check;*/  state <= data_2_prep;
		
		data_2_prep: if(aud_clk_22khz) state <= data_2_get; //sync clock
		
		data_2_get:begin
			state <= clock_wait2;
			address <= address;
		if (silent)
			aud_data_out <= 8'hBC;
		else
			aud_data_out <= read_data [15:8]; 
		end
		clock_wait2: state <= data_3_prep;
		
		data_3_prep: if(aud_clk_22khz) state <= data_3_get; //sync clock
		
		data_3_get:begin
			state <= clock_wait3;
			address <= address;
		if (silent)
			aud_data_out <= 8'hBC;
		else
			aud_data_out <= read_data [23:16]; 
		end
		clock_wait3: state <= data_4_prep;
		
		data_4_prep: if(aud_clk_22khz) state <= data_4_get; //sync clock
		
		data_4_get:begin
			state <= clock_wait4;
			address <= address;
		if (silent)
			aud_data_out <= 8'hBC;
		else
			aud_data_out <= read_data [31:24]; 
		end
		clock_wait4: state <= address_check;
		
		address_check: begin
			if(address  == (end_address/4))
			begin
				state <= get_select;
				pico_flag <= 1'b1;
			end
			else
			state  <= address_incr;
		end
		
		address_incr:begin
			address <= address + 1'b1;
		if (pause) state  <= pause_state;
		else state <= finished;
		end
		
		
		get_select:begin
			if  (pico_done)begin
				address <= (start_address/4);
				state  <= finished;
				pico_flag  <= 1'b0;
			end
		end
		
		pause_state: if(!pause) state<= finished;
		
		finished:begin
		state <= idle_state; 
		end
		
		default:begin
		state <= idle_state;
		address <= (start_address/4); 
		aud_data_out <= aud_data_out;	
		end
	endcase 
end
endmodule
