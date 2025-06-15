`default_nettype none

module top #(
    parameter CLK_FREQUENCY = 27000000
) (
    input wire clkIn,
    input wire resetIn,
    output reg [3:0] digitEnable,
    output reg [7:0] segmentEnable
);
  localparam CLK_SWEEP = int'(CLK_FREQUENCY / 1000);  // 1kHz digit sweeping

  reg [$clog2(CLK_FREQUENCY)-1:0] delay_1s = 0;
  reg [$clog2(CLK_SWEEP)-1:0] delay_sweep = 0;
  reg tick_1s, tick_sweep;
  reg [3:0] overflow;

  reg [7:0] displayReg[3:0];

  initial begin
    digitEnable = 'b1000;
  end

  always @(posedge clkIn) begin
    if (delay_1s >= int'(CLK_FREQUENCY / 2)) begin  // 1s delay
      delay_1s <= 'd0;
      tick_1s  <= ~tick_1s;
    end else begin
      delay_1s <= delay_1s + 'd1;
    end
  end

  always @(posedge clkIn) begin
    if (delay_sweep >= int'(CLK_SWEEP / 2)) begin
      delay_sweep <= 'd0;
      tick_sweep  <= ~tick_sweep;
    end else begin
      delay_sweep <= delay_sweep + 'd1;
    end
  end

  always @(posedge tick_sweep) begin
    digitEnable   <= {digitEnable[2:0], digitEnable[3]};
    segmentEnable <= displayReg[one_hot_to_binary(digitEnable)];
  end

  display display0 (
      .clkIn(clkIn),
      .increment(tick_1s),
      .resetIn(resetIn),
      .overflow(overflow[0]),
      .segmentEnable(displayReg[0])
  );

  display display1 (
      .clkIn(clkIn),
      .resetIn(resetIn),
      .increment(overflow[0]),
      .overflow(overflow[1]),
      .segmentEnable(displayReg[1])
  );

  display display2 (
      .clkIn(clkIn),
      .resetIn(resetIn),
      .increment(overflow[1]),
      .overflow(overflow[2]),
      .segmentEnable(displayReg[2])
  );

  display display3 (
      .clkIn(clkIn),
      .resetIn(resetIn),
      .increment(overflow[2]),
      .overflow(overflow[3]),
      .segmentEnable(displayReg[3])
  );

endmodule

function automatic [1:0] one_hot_to_binary;
  input [3:0] one_hot;
  begin
    case (one_hot)
      'b0001:  one_hot_to_binary = 'd0;
      'b0010:  one_hot_to_binary = 'd1;
      'b0100:  one_hot_to_binary = 'd2;
      'b1000:  one_hot_to_binary = 'd3;
      default: one_hot_to_binary = 'd0;
    endcase
  end
endfunction
