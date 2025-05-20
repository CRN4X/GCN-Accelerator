
module Transformation_Block
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
    parameter MAX_ADDRESS_WIDTH = 2	
)

(
  input logic clk,
  input logic reset,
  input logic start,
  input logic [WEIGHT_WIDTH-1:0] data_in [0:WEIGHT_ROWS-1],
  input logic [COUNTER_FEATURE_WIDTH-1:0] read_row,
  
  output logic enable_read,
  output logic done_trans,
  output logic [ADDRESS_WIDTH-1:0] read_address, // The Address to read the FM and WM Data
  output logic [DOT_PROD_WIDTH - 1:0] fm_wm_row_out  [0:WEIGHT_COLS-1]
  
  );
  
  
  // Internal Signals for FSM
  logic [COUNTER_WEIGHT_WIDTH-1:0] weight_count;
  logic [COUNTER_FEATURE_WIDTH-1:0] feature_count;
  logic enable_write_fm_wm_prod;
  logic enable_write;
  logic enable_scratch_pad;
  logic enable_weight_counter;
  logic enable_feature_counter;
  logic read_feature_or_weight;
  
    // FSM instance
  Transformation_FSM  fsm (
    .clk(clk),
    .reset(reset),
	.weight_count(weight_count), // will this come from weight_block's output
	.feature_count(feature_count),  // will this come from counter_block's output
    .start(start),
	.enable_write_fm_wm_prod(enable_write_fm_wm_prod),  // goes to fm_wm_mem and enables tht block
    .enable_read(enable_read),
	.enable_write(enable_write),
	.enable_scratch_pad(enable_scratch_pad),
	.enable_weight_counter(enable_weight_counter),
	.enable_feature_counter(enable_feature_counter),
	.read_feature_or_weight(read_feature_or_weight),
	.done(done_trans)
  );


	// Internal Signals for FM_WM Matrix Memory Instance
	logic [FEATURE_WIDTH-1:0] write_row;
	logic [WEIGHT_WIDTH-1:0] write_col;
	logic [DOT_PROD_WIDTH - 1:0] fm_wm_in;
	
    // FM WM Matrix memory instance
  Matrix_FM_WM_Memory  matrix_memory (
    .clk(clk),
    .rst(reset),
    .write_row(feature_count),  /// map to fsm feature_count
    .write_col(weight_count),  /// map to fsm weight_count
    .read_row(read_row),
    .wr_en(enable_write_fm_wm_prod),  //// is provided from the FSM block
    .fm_wm_in(fm_wm_in),
    .fm_wm_row_out(fm_wm_row_out)
  );
  
  
  // Internal Signal for Scratchpad
  logic [WEIGHT_WIDTH-1:0] weight_col_out [0:WEIGHT_ROWS-1];
  
  // Scratchpad memory instance
    Scratch_Pad  scratch_pad (
    .clk(clk),
    .reset(reset),
    .write_enable(enable_scratch_pad),  // comes via fsm
    .weight_col_in(data_in),  
    .weight_col_out(weight_col_out)
  );


  // Internal Signal for Vector_Multiplier
  // N/A
  
  // Vector_Multiplier instance
    Vector_Multiplier  vector_multiplier (
	.clk(clk),
    .reset(reset),
    .enable_calc(enable_read),  // additional condns required here
	.read_feature_or_weight(read_feature_or_weight), // this is the additional condn
	.feature_row(data_in),
	.weight_col(weight_col_out),
	.dot_product_result(fm_wm_in) 
	);
	
	
	// Internal Signal for Feature Counter
	//logic rollover;
  
    // Feature Counter instance
	Feature_Counter  feature_counter (
	.clk(clk),
    .reset(reset),
	.enable(enable_feature_counter),  /// control sginal from fsm
	.counter_feature(feature_count)  // maps to fsm data signal - feature_count
	//.rollover_feature(rollover)
	);
	
	
	// Internal Signal for Weight Counter
	//logic rollover_weight;
  
    // Weight Counter instance
	Weight_Counter  weight_counter (
	.clk(clk),
    .reset(reset),
	.enable(enable_weight_counter),   /// control sginal from fsm
	.weight_counter(weight_count) // maps to fsm data signal - weight_count
	//.rollover_weight(rollover_weight)
	);
	
	
   /// Logic for Read address
   // using the read_feature_or_weight signal along with weight & feature count values
   // read_feature_or_weight weight_count feature_count
   // Check Transformation_Block Testbnech, do we need to write any addtional logic
   // Counter register
//   always_ff @(posedge clk or posedge reset) begin

	   assign read_address = read_feature_or_weight ? 12'h200 + feature_count :12'h000 + weight_count ;
//	end

endmodule
