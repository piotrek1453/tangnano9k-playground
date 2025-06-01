`default_nettype none

module wishbone_counter #(
    parameter integer ADDR_WIDTH = 8,
    parameter integer DATA_WIDTH = 6
) (
    input wire i_clk,
    input wire i_rst,
    input wire i_wb_cyc,
    input wire i_wb_stb,
    input wire i_wb_we,
    input wire [ADDR_WIDTH-1:0] i_wb_addr,
    input wire [DATA_WIDTH-1:0] i_wb_data,
    output reg o_wb_ack,
    output reg o_wb_stall,
    output reg [DATA_WIDTH-1:0] o_wb_data
);
  localparam ADDR_COUNTER = 'h00;  // Address for counter control

  reg [DATA_WIDTH-1:0] counter_reg = 'b0;
  reg [31:0] prescaler = 0;
  reg ack_next;

  always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
      o_wb_ack <= 'b0;
      ack_next <= 'b0;
      o_wb_data <= 'b0;
      counter_reg <= 'b0;
    end else begin
      // Update the Ack
      o_wb_ack <= ack_next;
      ack_next <= 1'b0;

      // No stall condition in this simple example
      o_wb_stall = 1'b0;

      prescaler <= prescaler + 1;
      if (prescaler == 32'hFFFFFFFF) begin
        counter_reg <= counter_reg + 1;
        prescaler   <= 0;
      end

      if (i_wb_cyc && i_wb_stb && !o_wb_ack) begin
        ack_next <= 1'b1;  // Acknowledge the request

        case (i_wb_addr)
          ADDR_COUNTER: begin
            if (i_wb_we) begin
              // Write opration
              counter_reg <= i_wb_data;
            end
            // Read operation
            o_wb_data <= counter_reg;
          end
          default: o_wb_data <= 'b0;
        endcase
      end
    end
  end
endmodule
