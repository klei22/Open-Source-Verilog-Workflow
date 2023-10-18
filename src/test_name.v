`default_nettype none

module test_name (
    input wire clk,
    input wire P1A1,
    output wire LED1
);
 parameter COUNTER_WIDTH = 2;

  reg [COUNTER_WIDTH-1:0] counter;
  reg buffer = 1'b1;

  always @(posedge clk) begin
    buffer <= P1A1;
    counter <= counter + buffer;
  end

  assign LED1 = counter[COUNTER_WIDTH-1];
endmodule
