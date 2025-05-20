
module Argmax_ROW_Counter #(
  parameter FEATURE_ROWS = 6
)
(
  input  logic clk,
  input  logic reset,
  input  logic enable_argmax_row_counter,      // signal from FSM to increment counter
  output logic [2:0] argmax_row_count  // Current column index
);

  // Counter register
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      argmax_row_count <= '0;
    end 
    else if (enable_argmax_row_counter) begin
      if (argmax_row_count == FEATURE_ROWS - 1) begin
        argmax_row_count <= '0;
      end 
      else begin
        argmax_row_count <= argmax_row_count + 1'b1;
      end
    end
  end

endmodule
