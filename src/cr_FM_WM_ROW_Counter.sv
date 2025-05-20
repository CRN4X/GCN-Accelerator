
module FM_WM_ROW_Counter
#(
  parameter int COO_NUM_OF_COLS = 6,
  parameter int COO_BW = $clog2(COO_NUM_OF_COLS)
)
(
  input  logic clk,
  input  logic reset,
  input  logic enable_comb_row_counter,      // signal from FSM to increment counter
  output logic [COO_BW-1:0] comb_row_count  // Current column index
);

  // Counter register
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      comb_row_count <= '0;
    end 
    else if (enable_comb_row_counter) begin
      if (comb_row_count == COO_NUM_OF_COLS - 1) begin
        comb_row_count <= '0;
      end 
      else begin
        comb_row_count <= comb_row_count + 1'b1;
      end
    end
  end

endmodule
