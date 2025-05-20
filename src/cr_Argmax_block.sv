
module Argmax_Block #(
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
  input logic [DOT_PROD_WIDTH - 1:0] adj_fm_wm_row [0:WEIGHT_COLS-1], // Row Data from Comb Block's ADJ Mem
  
  output logic done,
  output logic [WEIGHT_COLS-1:0] index_for_read_row,  // Read Index value to Comb Block's ADJ Mem
  output logic [MAX_ADDRESS_WIDTH - 1:0] max_addi_ans [0:FEATURE_ROWS - 1]
);


	// Internal Signals for FSM
	logic [2:0] argmax_row_count;
	logic enable_argmax_row_counter;
	logic enable_read_calc_save;

    // Instantiate the FSM
    Argmax_FSM argmax_fsm (
        .clk(clk),
        .reset(reset),
        .argmax_row_count(argmax_row_count),
		.done_comb(done_comb),
		
		.enable_argmax_row_counter(enable_argmax_row_counter),
		.enable_read_calc_save(enable_read_calc_save),
		.done(done)
    );
	
	
	// Instantiate the Argmax Row Counter for Reading Row from ADJ Mem
    Argmax_ROW_Counter argmax_row_counter (
        .clk(clk),
        .reset(reset),
        .enable_argmax_row_counter(enable_argmax_row_counter),
        .argmax_row_count(argmax_row_count)
    );


	// Instantiate the Read Calculation & Save Module
	Argmax_Max_Value_Calc argmax_max_value_calc (
		.clk(clk),
		.reset(reset),
		.adj_fm_wm_row(adj_fm_wm_row),
		.enable_read_calc_save(enable_read_calc_save),
        .argmax_row_count(argmax_row_count),	
		
		.index_for_read_row(index_for_read_row),
		.max_addi_ans(max_addi_ans)
    );		

endmodule
