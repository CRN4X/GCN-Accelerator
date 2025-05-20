
module Coo_To_ADJ_FM_WM_Prod #(
    parameter NUM_OF_NODES = 6,
    parameter DOT_PROD_WIDTH = 16,
    parameter WEIGHT_COLS = 3,
	parameter COO_NUM_OF_COLS = 6,			
    parameter COO_NUM_OF_ROWS = 2,			
    parameter COO_BW = $clog2(COO_NUM_OF_COLS),
	parameter FEATURE_WIDTH = 5
)
(
    input logic clk,
    input logic reset,
	input logic [COO_BW - 1:0] coo_in [0:1],  // coo_in = [item1, item2]
	input logic enable_coo_node_r_c,  //  signal to enable node 1 as r and node 2 as c from fsm
	input logic enable_coo_node_c_r, //  signal to enable node 2 as r and node 1 as c from fsm
	input logic enable_adj_fm_wm_mem, // signal to ensure that memory is enable to write
	input logic [DOT_PROD_WIDTH-1:0] fm_wm_row_data [0:WEIGHT_COLS-1], // from trans block
	input logic [DOT_PROD_WIDTH - 1:0] fm_wm_adj_row_data [0:WEIGHT_COLS-1], // from adj mem
	input logic [2:0] comb_row_count,  // Index used to incerment coo address = 0 + comb_row_count
	input logic read_coo_addr,  // Read Coo Address
    
    output logic [WEIGHT_COLS - 1:0] read_FM_WM_row_index,  // index to read from FM_WM memory
	//output logic wr_en_adj_mem, // signal to enable the adj memory	
	output logic [COO_BW-1:0] coo_address,  // coo address to read the data from coo_in	
    output logic [DOT_PROD_WIDTH-1:0] adj_fm_wm_data [0:WEIGHT_COLS-1],  // final row to be saved to adj memory post doing the necessary operation
	
	output logic [WEIGHT_COLS-1:0] write_row_adj_index, // index to adj_memory to save computed row
	output logic [WEIGHT_COLS-1:0] read_row_adj_index // index to adj_memory to read from adj mem
);
	
	// Register the result when enabled
	always_ff @(posedge clk or posedge reset) begin
	   if (reset) begin
	      coo_address <= '0;
	   end else if (read_coo_addr) begin  // Now this is a proper enable signal
	      coo_address <= comb_row_count;
	   end
	end
	
	// Perform element-wise multiplication
    always_comb begin
	    if (enable_coo_node_c_r) begin			
		    // Read col from the adj mem based on node 1
		    read_row_adj_index = coo_in[1] - 3'b001;
		   
		    // Read row from the adj mem based on node 0
		    read_FM_WM_row_index = coo_in[0] - 3'b001;
			
			// index for adj fm wm memory	
			write_row_adj_index = coo_in[1] - 3'b001;

			// Write the computed data to adj memory
            for (int i = 0; i < WEIGHT_COLS; i++) begin
              adj_fm_wm_data[i] = fm_wm_adj_row_data[i] + fm_wm_row_data[i];
            end

	    end 
		
		else begin			 
			// Read row from the adj mem based on node 0
		    read_row_adj_index = coo_in[0] - 3'b001;
		   
		    // Read col from the adj mem based on node 1
		    read_FM_WM_row_index = coo_in[1] - 3'b001;
			 
			// index for adj fm wm memory	
			write_row_adj_index = coo_in[0] - 3'b001; // index for adj fm wm memory

			// Write computed data to adj memory
            for (int i = 0; i < WEIGHT_COLS; i++) begin
              adj_fm_wm_data[i] = fm_wm_adj_row_data[i] + fm_wm_row_data[i];
            end

          end
	   end
    
endmodule
