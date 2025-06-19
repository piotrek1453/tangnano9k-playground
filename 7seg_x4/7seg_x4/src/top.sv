`default_nettype none

module top #(
    parameter CLK_FREQUENCY = 27000000
) (
    input wire clkIn,
    input wire resetIn,
    output reg [3:0] digitEnableOut,
    output reg [7:0] segmentEnableOut,
    output reg ledOut
);
  localparam CLK_SWEEP = int'(CLK_FREQUENCY / 100000);  // digit refreshing

  reg [$clog2(CLK_FREQUENCY)-1:0] delay_1s = 0;
  reg [$clog2(CLK_SWEEP)-1:0] delay_sweep = 0;
  reg tick_1s, tick_sweep;
  reg [3:0] overflow;

  reg [7:0] displayReg[3:0];
  reg [1:0] currentDigitIndex;

  initial begin
    digitEnableOut = 'b0001;
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
    ledOut <= ~ledOut;
    digitEnableOut <= {digitEnableOut[2:0], digitEnableOut[3]};
    segmentEnableOut <= displayReg[one_hot_to_binary(digitEnableOut)];
  end

  display #(
      .MAX_NUMBER(9)
  ) display0 (
      .dotIn(tick_1s),
      .incrementIn(tick_1s),
      .resetIn(resetIn),
      .overflowOut(overflow[0]),
      .segmentEnableOut(displayReg[0])
  );

  display #(
      .MAX_NUMBER(5)
  ) display1 (
      .dotIn(overflow[0]),
      .resetIn(resetIn),
      .incrementIn(overflow[0]),
      .overflowOut(overflow[1]),
      .segmentEnableOut(displayReg[1])
  );

  display #(
      .MAX_NUMBER(9)
  ) display2 (
      .dotIn(overflow[1]),
      .resetIn(resetIn),
      .incrementIn(overflow[1]),
      .overflowOut(overflow[2]),
      .segmentEnableOut(displayReg[2])
  );

  display #(
      .MAX_NUMBER(1)
  ) display3 (
      .dotIn(overflow[2]),
      .resetIn(resetIn),
      .incrementIn(overflow[2]),
      .overflowOut(overflow[3]),
      .segmentEnableOut(displayReg[3])
  );

endmodule

function automatic [1:0] one_hot_to_binary;
  input [3:0] one_hot;
  begin
    case (one_hot)
      4'b1000: one_hot_to_binary = 2'd0;
      4'b0001: one_hot_to_binary = 2'd1;
      4'b0010: one_hot_to_binary = 2'd2;
      4'b0100: one_hot_to_binary = 2'd3;
      default: one_hot_to_binary = 2'd0;
    endcase
  end
endfunction
