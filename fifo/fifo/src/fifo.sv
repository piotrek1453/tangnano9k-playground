`default_nettype none

module fifo
#(
  parameter integer FIFO_WIDTH = 16,
  parameter integer FIFO_DEPTH = 8
)(
  input wire clkIn,
  input wire writeEnableIn,
  input wire [FIFO_DEPTH-1:0] dataIn,
  input wire readEnableIn,
  input wire loadEnableIn,
  input reg [FIFO_WIDTH-1:0][FIFO_DEPTH-1:0] load,
  input wire resetIn,

  output reg [FIFO_DEPTH-1:0] dataOut,
  output reg full,
  output reg empty,
  output reg [$clog2(FIFO_WIDTH)-1:0] tail
);

  assign dataOut = dataIn;

endmodule
