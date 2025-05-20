
module Feature_Counter
#(
  parameter int FEATURE_ROWS = 6,
  parameter int COUNTER_FEATURE_WIDTH = $clog2(FEATURE_ROWS)
)
(
  input  logic clk,
  input  logic reset,
  input  logic enable,      // Enable signal from FSM to increment counter
  output logic [COUNTER_FEATURE_WIDTH-1:0] counter_feature  // Current row index
  //output logic rollover_feature     // Indicates when counter wraps around (completes one cycle)
);

  // Counter register
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      counter_feature <= '0;
      //rollover_feature <= 1'b0;
    end 
    else if (enable) begin
      if (counter_feature == FEATURE_ROWS - 1) begin
        counter_feature <= '0;
        //rollover_feature <= 1'b1;  // Signal rollover when we complete a full cycle
      end 
      else begin
        counter_feature <= counter_feature + 1'b1;
        //rollover_feature <= 1'b0;
      end
    end
    /*else begin
      rollover_feature <= 1'b0;  // Reset rollover when not enabled
    end*/
  end

endmodule
