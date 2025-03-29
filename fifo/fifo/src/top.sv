`default_nettype none

module top(
  input wire clkIn,
  input wire writeEnableIn,
  input wire sysResetIn,
  output reg [5:0] ledOut
);
  fifo #(
    .FIFO_WIDTH(2),
    .FIFO_DEPTH(6)
  ) fifo_led (
    .clkIn(clkIn),
    .writeEnableIn(writeEnableIn),
    .dataIn(6'b000001),
    .readEnableIn(1'b0),
    .loadEnableIn(1'b0),
    .load({6'b101010, 6'b010101}),
    .resetIn(sysResetIn),
    .dataOut(ledOut),
    .full(),
    .empty(),
    .tail()
  );
endmodule
