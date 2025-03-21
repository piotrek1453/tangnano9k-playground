`default_nettype none

typedef enum logic [2:0] {
  IDLE,
  START_BIT,
  DATA,
  PARITY_BIT,
  STOP_BIT
} uart_tx_state_t;


module uart_tx #(
    //! assuming 27MHz clock:
    //!
    //! baud rate set to 115200
    parameter integer PRESCALER_COUNT = 234,
    //! 'b00: no parity,
    //!
    //! 'b01: odd parity,
    //!
    //! 'b10: even parity
    parameter logic [1:0] PARITY = 2'b00,
    //! 'b0: 1 stop bit,
    //!
    //! 'b1: 2 stop bits
    parameter logic STOP_BITS = 1'b0
) (
    //! Clock signal
    input wire clk,
    //! Data word input
    input reg [7:0] dataIn,
    //! Current data bit output
    output reg dataOut,
    //! Done flag
    output reg done
);
  //! Prescaler counter
  reg [$bits(PRESCALER_COUNT):0] prescaler = 0;
  //! Payload data bit counter
  reg [2:0] numBits = 0;
  //! Data word register
  reg [7:0] dataReg;

  uart_tx_state_t state;

  always @(posedge clk) begin
    case (state)
      IDLE: begin
        dataOut <= 1'b1;
        done <= 1'b1;
        if (dataIn != 8'h00) begin
          state <= START_BIT;
          done  <= 0;
        end
      end

      START_BIT: begin
        dataOut <= 1'b0;
        prescaler <= 0;
        dataReg <= dataIn;
        numBits <= 0;
        state <= DATA;
      end

      DATA: begin
        prescaler <= prescaler + 1;
        if (prescaler == PRESCALER_COUNT && numBits < 8) begin
          dataOut   <= dataReg[0];
          dataReg   <= {dataReg[6:0], 1'b0};
          numBits   <= numBits + 1;
          prescaler <= 0;
        end else begin
          prescaler <= 0;
          state <= PARITY_BIT;
        end
      end

      PARITY_BIT: begin
        prescaler <= prescaler + 1;
        case (PARITY)
          'b01: begin
            dataOut <= ~^dataReg;
          end
          'b10: begin
            dataOut <= ~^dataReg;
          end
          default: state <= STOP_BIT;
        endcase
        if (prescaler == PRESCALER_COUNT) begin
          state <= STOP_BIT;
          prescaler <= 0;
        end
      end

      STOP_BIT: begin
        prescaler <= prescaler + 1;
        case (STOP_BITS)
          'b1: begin
            if (prescaler == 2 * PRESCALER_COUNT) begin
              dataOut <= 1'b1;
            end
          end
          default: begin
            if (prescaler == PRESCALER_COUNT) begin
              dataOut <= 1'b1;
            end
          end
        endcase
        state <= IDLE;
      end

      default: state <= IDLE;
    endcase
  end
endmodule
