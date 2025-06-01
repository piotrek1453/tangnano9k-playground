`default_nettype none

module wishbone_led #(
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
    output reg [DATA_WIDTH-1:0] o_wb_data,
    output reg [DATA_WIDTH-1:0] o_led
);
  localparam ADDR_LED = 'h00;  // Address for LED control

  reg [DATA_WIDTH-1:0] led_reg;
  reg ack_next;

  always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
      o_wb_ack  <= 'b0;
      ack_next  <= 'b0;
      led_reg   <= 'b0;
      o_wb_data <= 'b0;
    end else begin
      // Update the Ack
      o_wb_ack <= ack_next;
      ack_next <= 1'b0;

      // No stall condition in this simple example
      o_wb_stall = 1'b0;

      // Update the LED output
      o_led <= led_reg;

      if (i_wb_cyc && i_wb_stb && !o_wb_ack) begin
        ack_next <= 1'b1;  // Acknowledge the request

        case (i_wb_addr)
          ADDR_LED: begin
            if (i_wb_we) begin
              // Write opration
              led_reg <= i_wb_data;
            end
            // Read operation
            o_wb_data <= led_reg;
          end
          default: o_wb_data <= 'b0;
        endcase
      end
    end
  end

endmodule
