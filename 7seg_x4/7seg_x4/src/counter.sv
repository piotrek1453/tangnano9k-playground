`default_nettype none

module counter #(
    parameter unsigned MODULO = 10
) (
    input wire clkIn,
    input wire resetIn,
    output reg [$clog2(MODULO)-1:0] countOut,
    output reg overflow
);

  always @(posedge clkIn, negedge resetIn) begin
    if (resetIn == 0) begin
      countOut <= 'd0;
      overflow <= 'b0;
    end else if (countOut >= MODULO - 1) begin
      countOut <= 'd0;
      overflow <= 'b1;
    end else if (countOut == 0) begin
      countOut <= countOut + 'd1;
      overflow <= 'b1;
    end else begin
      countOut <= countOut + 'd1;
      overflow <= 'b0;
    end
  end

endmodule
