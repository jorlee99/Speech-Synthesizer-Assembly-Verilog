module ipod_fsm_timer(clock, wait_request, read_valid, read_request, start, finish,state); 

input clock, start, read_valid, wait_request, read_request; 
output finish;  


output reg [4:0] state;    

parameter idle = 5'b000_00; 
parameter read_check_state = 5'b001_00; 
parameter read_ready_state = 5'b010_00; 
parameter wait_state = 5'b011_00; 
parameter finished = 5'b111_01; 

assign finish = state[0]; 

always @(posedge clock)
	case(state)   
		
		idle: if(start) state <= read_check_state; 
			
		read_check_state:if(read_request) state <= read_ready_state; //wait for read_request
			
		read_ready_state: if(!wait_request) state <= wait_state; //wait for wait to end
			
		wait_state: if(!read_valid) state <= finished; //wait for read_valid to end
			
		finished: state <= idle;

		default: state <= idle; 
		
	endcase 
	
endmodule 
