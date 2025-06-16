`default_nettype none

module display (
    input wire clkIn,
    input wire resetIn,
    input wire incrementIn,
    input wire dotClkIn,
    output reg [7:0] segmentEnableOut,
    output reg overflowOut
);

  reg [3:0] count;

  counter digit (
      .clkIn(incrementIn),
      .resetIn(resetIn),
      .countOut(count),
      .overflowOut(overflowOut)
  );

  always @(posedge dotClkIn) begin
    segmentEnableOut[0] <= ~segmentEnableOut[0];
  end

  always @(posedge clkIn) begin
    // a, b, c, d, e, f, g
    case (count)
      'd0: segmentEnableOut[7:1] <= ~7'b1111110;
      'd1: segmentEnableOut[7:1] <= ~7'b0110000;
      'd2: segmentEnableOut[7:1] <= ~7'b1101101;
      'd3: segmentEnableOut[7:1] <= ~7'b1111001;
      'd4: segmentEnableOut[7:1] <= ~7'b0110011;
      'd5: segmentEnableOut[7:1] <= ~7'b1011011;
      'd6: segmentEnableOut[7:1] <= ~7'b1011111;
      'd7: segmentEnableOut[7:1] <= ~7'b1110000;
      'd8: segmentEnableOut[7:1] <= ~7'b1111111;
      'd9: segmentEnableOut[7:1] <= ~7'b1111011;
      default: segmentEnableOut[7:1] <= ~7'b1111110;
    endcase

  end

endmodule
