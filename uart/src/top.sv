`default_nettype none

module top (
    input  wire clk,
    output reg  dataOut,
    output reg  done
);

  localparam integer PRESCALER = 600;
  reg [$bits(PRESCALER)-1:0] prescaler = 0;

  reg [7:0] dataIn = 0;

  always @(posedge clk) begin
    if (prescaler == PRESCALER) begin
      prescaler <= 0;
      dataIn <= dataIn + 1;
    end else begin
      prescaler <= prescaler + 1;
    end
  end
  uart_tx #(
      .PRESCALER_COUNT(234),
      .PARITY(2'b00),
      .STOP_BITS(1'b0)
  ) tx (
      .clk(clk),
      .dataIn(dataIn),
      .dataOut(dataOut),
      .busy(done)
  );
endmodule
