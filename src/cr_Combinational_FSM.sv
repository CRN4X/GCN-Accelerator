
module Combinational_FSM #(
  parameter FEATURE_ROWS = 6
)
(
    input logic clk,
    input logic reset,
    input logic done_trans,
    input logic [2:0] comb_row_count,

    output logic read_coo_addr,
	output logic enable_comb_row_counter,
	output logic enable_coo_node_r_c,
	output logic enable_coo_node_c_r,
	output logic enable_adj_fm_wm_mem,
	output logic done

);

    // FSM state definitions
  typedef enum logic [2:0] {
	START,
	READ_COO_ADDRESS,
	COO_NODES_R_C,  // Node 1 is from Result Matrix, Node 2 is from FM_WM Matrix and then swap the nodes
	COO_NODES_C_R,
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
	    read_coo_addr = 1'b0;
		enable_comb_row_counter = 1'b0;
		enable_coo_node_r_c = 1'b0;
	    enable_coo_node_c_r = 1'b0;
		enable_adj_fm_wm_mem = 1'b0;
		done = 1'b0;

		if (done_trans) begin
			next_state = READ_COO_ADDRESS;
		end 
		else begin 
			next_state = START;
		end  	
      end
	  
	  READ_COO_ADDRESS: begin
	    read_coo_addr = 1'b1;
	    enable_comb_row_counter = 1'b0;
		enable_coo_node_r_c = 1'b0;  // Node 1 is from Result Matrix, Node 2 is from FM_WM Matrix
	    enable_coo_node_c_r = 1'b0; 
		enable_adj_fm_wm_mem = 1'b0;
		done = 1'b0;

		next_state = COO_NODES_R_C;
      end

      COO_NODES_R_C: begin
	    read_coo_addr = 1'b0;
	    enable_comb_row_counter = 1'b0;
		enable_coo_node_r_c = 1'b1;  // Node 1 is from Result Matrix, Node 2 is from FM_WM Matrix
	    enable_coo_node_c_r = 1'b0; 
		enable_adj_fm_wm_mem = 1'b1;
		done = 1'b0;

		next_state = COO_NODES_C_R;
      end
	  
	  COO_NODES_C_R: begin
	    read_coo_addr = 1'b0;
	    enable_comb_row_counter = 1'b0;
	    enable_coo_node_r_c = 1'b0;  // Node 1 is from Result Matrix, Node 2 is from FM_WM Matrix
	    enable_coo_node_c_r = 1'b1; 
		enable_adj_fm_wm_mem = 1'b1;
		done = 1'b0;

		next_state = INCR_ROW_COUNTER;
      end
	  
	  
	  INCR_ROW_COUNTER: begin
	    read_coo_addr = 1'b0;
		enable_comb_row_counter = 1'b1;
	    enable_coo_node_r_c = 1'b0;  // Node 1 is from Result Matrix, Node 2 is from FM_WM Matrix
	    enable_coo_node_c_r = 1'b0; 
		enable_adj_fm_wm_mem = 1'b0;
		done = 1'b0;
		
		if (comb_row_count == FEATURE_ROWS - 1) begin
			next_state = DONE;
		end 
		else  begin
			next_state = READ_COO_ADDRESS;
		end
	  end

      DONE: begin
	    read_coo_addr = 1'b0;
		enable_comb_row_counter = 1'b0;
		enable_coo_node_r_c = 1'b0;  // Node 1 is from Result Matrix, Node 2 is from FM_WM Matrix
	    enable_coo_node_c_r = 1'b0; 
		enable_adj_fm_wm_mem = 1'b0;
		done = 1'b1;

		next_state = DONE;
      end

      default: begin
	    read_coo_addr = 1'b0;
		enable_comb_row_counter = 1'b0;
		enable_coo_node_r_c = 1'b0;  // Node 1 is from Result Matrix, Node 2 is from FM_WM Matrix
	    enable_coo_node_c_r = 1'b0; 
		enable_adj_fm_wm_mem = 1'b0;
		done = 1'b0;
		
		next_state = START;
      end

    endcase
  end

endmodule
