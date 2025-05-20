
module combination_block #(
    parameter NUM_OF_NODES = 6,
    parameter COO_NUM_OF_COLS = 6,
    parameter COO_NUM_OF_ROWS = 2,				
    parameter COO_BW = $clog2(COO_NUM_OF_COLS),
    parameter DOT_PROD_WIDTH = 16,
    parameter WEIGHT_COLS = 3,
	parameter FEATURE_WIDTH = 5
)
(
    input logic clk,
    input logic reset,
    input logic done_trans,
    input logic [COO_BW-1:0] coo_in [0:1],  // 2D array for row and column indices
    input logic [DOT_PROD_WIDTH-1:0] fm_wm_row_data [0:WEIGHT_COLS-1],
	input logic [WEIGHT_COLS-1:0] index_for_read_row_out,
    
    output logic [COO_BW-1:0] coo_address,
    output logic [WEIGHT_COLS - 1:0] read_FM_WM_row_index,
    output logic [DOT_PROD_WIDTH-1:0] adj_fm_wm_row_data [0:WEIGHT_COLS-1],
    output logic done_comb
);


    // Internal Signals for FSM
	logic [2:0] comb_row_count;
	logic read_coo_addr;
	logic enable_comb_row_counter;
	logic enable_coo_node_r_c;
	logic enable_coo_node_c_r;
	logic enable_adj_fm_wm_mem;
	
    // Instantiate the FSM
    Combinational_FSM comb_fsm (
        .clk(clk),
        .reset(reset),
        .comb_row_count(comb_row_count),
		.done_trans(done_trans),
		
		.read_coo_addr(read_coo_addr),
		.enable_comb_row_counter(enable_comb_row_counter),
		.enable_coo_node_r_c(enable_coo_node_r_c),
		.enable_coo_node_c_r(enable_coo_node_c_r),
		.enable_adj_fm_wm_mem(enable_adj_fm_wm_mem),
		.done(done_comb)
    );
    
	
    // Instantiate the COMB_FM_WM_ROW_Counter
    FM_WM_ROW_Counter row_counter (
        .clk(clk),
        .reset(reset),
        .enable_comb_row_counter(enable_comb_row_counter),
        .comb_row_count(comb_row_count)
    );
    
	
    // Instantiate Matrix_FM_WM_ADJ_Memory for storing results
    logic [DOT_PROD_WIDTH-1:0] mem_data_in [0:WEIGHT_COLS-1];
	logic [WEIGHT_COLS-1:0] write_row_adj_index;
	
	logic [WEIGHT_COLS-1:0] index_for_read_row_self;
     logic [WEIGHT_COLS-1:0] index_for_read_row;
	/*
    logic select_comb;  // Control signal to select between Argmax and Combination

    // Control logic to select which module drives index_for_read_row
    always_comb begin
        if (done_trans) begin
            select_comb = 1'b0;  // Use self block
        end else if (done_comb) begin
            select_comb = 1'b1;  // Use Out block
        end else begin
            select_comb = 1'b0;  // Default to Combination block
        end
    end*/
	
    // Multiplexer to select the source of index_for_read_row
    //assign index_for_read_row = select_comb ? index_for_read_row_out : index_for_read_row_self;
	assign  index_for_read_row = (done_comb) ? index_for_read_row_out  : index_for_read_row_self;

    
    Matrix_FM_WM_ADJ_Memory adj_memory (
        .clk(clk),
        .reset(reset),
        .write_row(write_row_adj_index),
        .read_row(index_for_read_row),
        .wr_en(enable_adj_fm_wm_mem),
        .fm_wm_adj_row_in(mem_data_in),
		
        .fm_wm_adj_out(adj_fm_wm_row_data)
    );

	
	// Instantiate Coo_To_ADJ_FM_WM_Prod for converting coo to adj and perform product	
	Coo_To_ADJ_FM_WM_Prod coo_to_adj (
		.clk(clk),
		.reset(reset),
		.coo_in(coo_in),
		.enable_coo_node_r_c(enable_coo_node_r_c),
		.enable_coo_node_c_r(enable_coo_node_c_r),
		.enable_adj_fm_wm_mem(enable_adj_fm_wm_mem),
		.fm_wm_row_data(fm_wm_row_data),  // based on the index row data from fm wm mem
		.comb_row_count(comb_row_count),
		.fm_wm_adj_row_data(adj_fm_wm_row_data), // to get data from adj mem
		.read_coo_addr(read_coo_addr),
		
		.read_FM_WM_row_index(read_FM_WM_row_index),  // index to fm wm mem
		//.wr_en_adj_mem(enable_adj_fm_wm_mem),		
		.write_row_adj_index(write_row_adj_index),
		.read_row_adj_index(index_for_read_row_self),
		.adj_fm_wm_data(mem_data_in),
		.coo_address(coo_address)		
	);
		

endmodule

