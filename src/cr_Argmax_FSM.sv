
module Argmax_FSM #(
  parameter MAX_ADDRESS_WIDTH = 2,
  parameter WEIGHT_COLS = 3,
  parameter FEATURE_WIDTH = 5,
  parameter FEATURE_ROWS = 6,
  parameter int DOT_PROD_WIDTH = 16
)
(
    input logic clk,
    input logic reset,
    input logic done_comb,
    input logic [2:0] argmax_row_count,  // Counter value from the argmax counter module

	output logic enable_argmax_row_counter,  // signal to enable argmax counter
	output logic enable_read_calc_save, // enable signal to perform reading, calculation & save oper
	output logic done
);

// Argmax FSM states
  typedef enum logic [2:0] {
	START,
	READ_CALC_SAVE,
	INCR_ROW_COUNTER,
	DONE
  } state_t;

  state_t current_state, next_state;

  always_ff @(posedge clk or posedge reset)
    if (reset)
      current_state <= START;
    else
      current_state <= next_state;

  always_comb begin
    case (current_state)

      START: begin
		enable_argmax_row_counter = 1'b0;
		enable_read_calc_save = 1'b0;
		done = 1'b0;

		if (done_comb) begin
			next_state = READ_CALC_SAVE;
		end 
		else begin 
			next_state = START;
		end  	
      end
	  
	  READ_CALC_SAVE: begin
		enable_argmax_row_counter = 1'b0;
		enable_read_calc_save = 1'b1;
		done = 1'b0;

		next_state = INCR_ROW_COUNTER;
      end
	  
	  INCR_ROW_COUNTER: begin
		enable_argmax_row_counter = 1'b1;
		enable_read_calc_save = 1'b0;
		done = 1'b0;
		
		if (argmax_row_count == FEATURE_ROWS - 1) begin
			next_state = DONE;
		end 
		else  begin
			next_state = READ_CALC_SAVE;
		end
	  end

      DONE: begin
		enable_argmax_row_counter = 1'b0;
		enable_read_calc_save = 1'b0;
		done = 1'b1;

		next_state = DONE;
      end

	  default: begin
		enable_argmax_row_counter = 1'b0;
		enable_read_calc_save = 1'b0;
		done = 1'b0;
		
		next_state = START;
      end

    endcase
  end

endmodule
