`default_nettype none

module top (
    input  wire clk,          //! System clock
    output wire dataOut,      //! UART data output
    output wire done          //! UART busy flag
);

  reg [7:0] dataIn = 'b01000001;     //! data to send ("A")
  reg start = 1'b0;           //! Start signal for UART transmission

  always @(posedge done) begin
    dataIn <= dataIn + 1;  //! Increment data to send
  end

  // Generate the start signal when the UART is not busy
  always @(posedge clk) begin
    if (!done) begin
      start <= 1'b1;          //! Trigger the start signal
    end else begin
      start <= 1'b0;          //! Clear the start signal
    end
  end

  // Instantiate the UART transmitter
  uart_tx
  tx (
      .clk(clk),
      .dataIn(dataIn),
      .dataOut(dataOut),
      .start(start),
      .busy(done)
  );

endmodule
