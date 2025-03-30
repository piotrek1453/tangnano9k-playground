`default_nettype none

module top(
  input wire clkIn,
  input wire writeEnableIn,
  input wire sysResetIn,
  output reg [5:0] ledOut
);

  reg clkSlow = 0;
  reg [5:0] dataReg = 6'b101010;
  reg [5:0] ledReg;

  always @(posedge writeEnableIn) begin
    dataReg <= ~dataReg;
  end

  always @(posedge clkIn) begin
    ledOut <= ledReg;
  end

  fifo #(
    .DATA_WIDTH(6),
    .FIFO_DEPTH(1)
  ) fifo_led (
    .clkIn(clkIn),
    .writeEnableIn(writeEnableIn),
    .dataIn(dataReg),
    .readEnableIn(sysResetIn),
    .loadEnableIn(1'b0),
    // .load(dataReg),
    // .resetIn(sysResetIn),
    .serialDataOut(ledReg),
    // .fullOut(),
    // .emptyOut(),
    .tailPointerOut()
  );
endmodule
