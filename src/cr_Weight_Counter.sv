
module Weight_Counter
#(
  parameter int WEIGHT_COLS = 3,
  parameter int COUNTER_WEIGHT_WIDTH = $clog2(WEIGHT_COLS)
)
(
  input  logic clk,
  input  logic reset,
  input  logic enable,      // Enable signal from FSM to increment counter
  output logic [COUNTER_WEIGHT_WIDTH-1:0] weight_counter  // Current column index
  //output logic rollover_weight     // Indicates when counter wraps around (completes one cycle)
);

  // Counter register
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      weight_counter <= '0;
      //rollover_weight <= 1'b0;
    end 
    else if (enable) begin
      if (weight_counter == WEIGHT_COLS - 1) begin
        weight_counter <= '0;
        //rollover_weight <= 1'b1;  // Signal rollover_weight when we complete a full cycle
      end 
      else begin
        weight_counter <= weight_counter + 1'b1;
        //rollover_weight <= 1'b0;
      end
    end/*
    else begin
      rollover_weight <= 1'b0;  // Reset rollover_weight when not enabled
    end*/
  end

endmodule
