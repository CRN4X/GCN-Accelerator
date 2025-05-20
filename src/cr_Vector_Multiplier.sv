// Instead of doing 96 products at once, do 24 multiplciations and then
// store it in the register, continue for the remaining 3 groups
// This will help us save area if we do in 4 steps, saved for milestone 2
module Vector_Multiplier
#(
  parameter int FEATURE_COLS = 96,  // Length of feature vector (row)
  parameter int WEIGHT_WIDTH = 5,     // Width of each weight element
  parameter int DOT_PROD_WIDTH = 16   // Width of dot product result
)
(
  input logic clk,
  input logic reset,
  
  // Control signals from FSM
  input logic enable_calc,            // Signal to start calculation (from FSM)
  input logic read_feature_or_weight,  // If value is asserted then perform multiplication
  
  // Data inputs
  input [WEIGHT_WIDTH-1:0] feature_row [0:FEATURE_COLS-1],  // Row from feature matrix
  input [WEIGHT_WIDTH-1:0] weight_col [0:FEATURE_COLS-1],   // Column from weight matrix
  
  // Result output (to FM_WM_Memory)
  output logic [DOT_PROD_WIDTH-1:0] dot_product_result
);

  // Internal signals for calculation
  logic [DOT_PROD_WIDTH-1:0] product_terms [0:FEATURE_COLS-1];
  logic [DOT_PROD_WIDTH-1:0] sum;
  
  // Perform element-wise multiplication
  always_comb begin
    for (int i = 0; i < FEATURE_COLS; i++) begin
      product_terms[i] = feature_row[i] * weight_col[i];
    end
  end
  
  // Sum up all products to get dot product
  always_comb begin
    sum = '0;
    for (int i = 0; i < FEATURE_COLS; i++) begin
      sum = sum + product_terms[i];
    end
  end
  
  // Register the result when enabled
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      dot_product_result <= '0;
    end else if (enable_calc && read_feature_or_weight) begin
      dot_product_result <= sum;
    end
  end

endmodule
