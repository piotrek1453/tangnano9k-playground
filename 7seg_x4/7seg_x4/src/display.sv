`default_nettype none

module display (
    input wire clkIn,
    input wire resetIn,
    input wire increment,
    output reg [7:0] segmentEnable,
    output reg overflow
);

  reg [3:0] count;

  counter digit (
      .clkIn(increment),
      .resetIn(resetIn),
      .countOut(count),
      .overflow(overflow)
  );

  always @(posedge clkIn) begin
    segmentEnable[0] <= 1;  // dot
    // a, b, c, d, e, f, g
    case (count)
      'd0: segmentEnable[7:1] <= ~7'b1111110;
      'd1: segmentEnable[7:1] <= ~7'b0110000;
      'd2: segmentEnable[7:1] <= ~7'b1101101;
      'd3: segmentEnable[7:1] <= ~7'b1111001;
      'd4: segmentEnable[7:1] <= ~7'b0110011;
      'd5: segmentEnable[7:1] <= ~7'b1011011;
      'd6: segmentEnable[7:1] <= ~7'b1011111;
      'd7: segmentEnable[7:1] <= ~7'b1110000;
      'd8: segmentEnable[7:1] <= ~7'b1111111;
      'd9: segmentEnable[7:1] <= ~7'b1111011;
      default: segmentEnable <= ~7'b1111110;
    endcase

  end

endmodule
