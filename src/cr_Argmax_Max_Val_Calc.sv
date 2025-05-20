
module Argmax_Max_Value_Calc #(
    parameter MAX_ADDRESS_WIDTH = 2,
    parameter WEIGHT_COLS = 3,
    parameter FEATURE_ROWS = 6,
    parameter int DOT_PROD_WIDTH = 16
) (
    input logic clk,
    input logic reset,
    input logic [DOT_PROD_WIDTH - 1:0] adj_fm_wm_row [0:WEIGHT_COLS-1],
    input logic enable_read_calc_save,
    input logic [2:0] argmax_row_count,
    
    output logic [WEIGHT_COLS-1:0] index_for_read_row,
    output logic [MAX_ADDRESS_WIDTH - 1:0] max_addi_ans [0:FEATURE_ROWS - 1]
);

    // Internal Signal to hold max index
  logic [MAX_ADDRESS_WIDTH:0] max_index;

  always_comb begin
  //max_index = '0;
  //index_for_read_row = '0;
  //max_addi_ans = '{default: '0};

    if (enable_read_calc_save) begin
      // Assign the current row index for reading
      index_for_read_row = argmax_row_count;

      // Calculate the max index
      if (adj_fm_wm_row[0] > adj_fm_wm_row[1]) begin
        max_index = 2'b00;
      end else begin
        max_index = 2'b01;
      end

      if (adj_fm_wm_row[max_index] < adj_fm_wm_row[2]) begin
        max_index = 2'b10;
      end

      // Save the Max index to the array
      max_addi_ans[argmax_row_count] = max_index;
    end
  end

endmodule
