module GCN
  #(parameter FEATURE_COLS = 96,
    parameter WEIGHT_ROWS = 96,
    parameter FEATURE_ROWS = 6,
    parameter WEIGHT_COLS = 3,
    parameter FEATURE_WIDTH = 5,
    parameter WEIGHT_WIDTH = 5,
    parameter DOT_PROD_WIDTH = 16,
    parameter ADDRESS_WIDTH = 13,
    parameter COUNTER_WEIGHT_WIDTH = $clog2(WEIGHT_COLS),
    parameter COUNTER_FEATURE_WIDTH = $clog2(FEATURE_ROWS),
    parameter MAX_ADDRESS_WIDTH = 2,
    parameter NUM_OF_NODES = 6,			 
    parameter COO_NUM_OF_COLS = 6,			
    parameter COO_NUM_OF_ROWS = 2,			
    parameter COO_BW = $clog2(COO_NUM_OF_COLS)	
)
(
  input logic clk,	// Clock
  input logic reset,	// Reset 
  input logic start,
  input logic [WEIGHT_WIDTH-1:0] data_in [0:WEIGHT_ROWS-1], //FM and WM Data
  input logic [COO_BW - 1:0] coo_in [0:1], //row 0 and row 1 of the COO Stream

  output logic [COO_BW - 1:0] coo_address, // The column of the COO Matrix 
  output logic [ADDRESS_WIDTH-1:0] read_address, // The Address to read the FM and WM Data
  output logic enable_read, // Enabling the Read of the FM and WM Data
  output logic done, // Done signal indicating that all the calculations have been completed
  output logic [MAX_ADDRESS_WIDTH - 1:0] max_addi_answer [0:FEATURE_ROWS - 1] // The answer to the argmax and matrix multiplication 
); 


logic [DOT_PROD_WIDTH - 1:0] fm_wm_row_out [0:WEIGHT_COLS-1];
//logic [ADDRESS_WIDTH-1:0] read_addres_mem;
logic done_trans;
logic [COUNTER_FEATURE_WIDTH-1:0] read_FM_WM_row_index;

Transformation_Block transform
(
  .clk(clk),
  .reset(reset),
  .start(start),
  .data_in(data_in),
  .read_row(read_FM_WM_row_index),
  
  .enable_read(enable_read),
  .done_trans(done_trans),
  .read_address(read_address), // The Address to read the FM and WM Data
  .fm_wm_row_out(fm_wm_row_out)
  
  );


// Internal signals
	logic [DOT_PROD_WIDTH-1:0] adj_fm_wm_row_data [0:WEIGHT_COLS-1];
	logic write_enable;
	logic done_comb;
	logic [WEIGHT_COLS-1:0] index_for_read_row;

combination_block comb
(
	.clk(clk),
	.reset(reset),
	.done_trans(done_trans),
	.coo_in(coo_in),
	.fm_wm_row_data(fm_wm_row_out),
	.index_for_read_row_out(index_for_read_row),

    .coo_address(coo_address),
    .read_FM_WM_row_index(read_FM_WM_row_index),  //  Map to Transformation_Block's read_row input
    .adj_fm_wm_row_data(adj_fm_wm_row_data),    // This will connect to Argmax input
	.done_comb(done_comb)
);


logic [WEIGHT_COLS-1:0] arg_index_for_read_row;

Argmax_Block argmax
(
	.clk(clk),
	.reset(reset),
	.done_comb(done_comb),
	.adj_fm_wm_row(adj_fm_wm_row_data),
	
	.done(done),
	.index_for_read_row(index_for_read_row),
	.max_addi_ans(max_addi_answer)
);

endmodule

