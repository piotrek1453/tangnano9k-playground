`default_nettype none

//! wrapper module that includes the asynchronous modulo counter and binary->7
//! segment display decoder (common cathode configuration by default)
module display #(
    parameter unsigned MAX_NUMBER = 9,  //! max value of displayed digit. 9 is the highest value that makes sense
    parameter logic INVERT_SEGMENT_OUT = 'b1 //! for choosing between common cathode and common anode configuration
) (
    input wire resetIn,
    input wire incrementIn,
    input wire dotIn,
    output reg [7:0] segmentEnableOut,
    output reg [3:0] decimalOut,
    output reg overflowOut
);

  reg [3:0] count;

  modulo_counter #(
      .MODULO(MAX_NUMBER + 1)
  ) digit (
      .countIn(incrementIn),
      .resetIn(resetIn),
      .countOut(count),
      .overflowOut(overflowOut)
  );


  // a, b, c, d, e, f, g
  generate
    if (INVERT_SEGMENT_OUT) begin
      always_comb begin
        segmentEnableOut[0] = ~dotIn;
        case (count)
          'd0: segmentEnableOut[7:1] = ~7'b1111110;
          'd1: segmentEnableOut[7:1] = ~7'b0110000;
          'd2: segmentEnableOut[7:1] = ~7'b1101101;
          'd3: segmentEnableOut[7:1] = ~7'b1111001;
          'd4: segmentEnableOut[7:1] = ~7'b0110011;
          'd5: segmentEnableOut[7:1] = ~7'b1011011;
          'd6: segmentEnableOut[7:1] = ~7'b1011111;
          'd7: segmentEnableOut[7:1] = ~7'b1110000;
          'd8: segmentEnableOut[7:1] = ~7'b1111111;
          'd9: segmentEnableOut[7:1] = ~7'b1111011;
          default: segmentEnableOut[7:1] = ~7'b1111110;
        endcase
      end
    end else begin
      always_comb begin
        segmentEnableOut[0] = ~dotIn;
        case (count)
          'd0: segmentEnableOut[7:1] = 7'b1111110;
          'd1: segmentEnableOut[7:1] = 7'b0110000;
          'd2: segmentEnableOut[7:1] = 7'b1101101;
          'd3: segmentEnableOut[7:1] = 7'b1111001;
          'd4: segmentEnableOut[7:1] = 7'b0110011;
          'd5: segmentEnableOut[7:1] = 7'b1011011;
          'd6: segmentEnableOut[7:1] = 7'b1011111;
          'd7: segmentEnableOut[7:1] = 7'b1110000;
          'd8: segmentEnableOut[7:1] = 7'b1111111;
          'd9: segmentEnableOut[7:1] = 7'b1111011;
          default: segmentEnableOut[7:1] = 7'b1111110;
        endcase
      end
    end
  endgenerate

endmodule
