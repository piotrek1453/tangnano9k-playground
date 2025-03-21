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
    input wire [7:0] dataIn,
    //! Current data bit output
    output reg dataOut,
    //! Done flag
    output reg busy
);
  //! Prescaler counter
  reg [$bits(PRESCALER_COUNT)-1:0] prescaler = 0;
  //! Payload data bit counter
  reg [3:0] numBits = 0;
  //! Data word register
  reg [7:0] dataReg;

  uart_tx_state_t state;

  always @(posedge clk) begin : uart_tx_fsm
    case (state)
      IDLE: begin
        dataOut <= 1'b1;  //! Idle state is high
        busy <= 1'b0;  //! Clear busy flag
        if (dataIn != 8'h00) begin  //! If there's a word to be sent...
          dataReg <= dataIn;  //! Load the data word
          busy <= 1'b1;  //! Set busy flag
          state <= START_BIT;
        end
      end

      START_BIT: begin
        dataOut <= 1'b0;  //! Set start bit
        prescaler <= 0;  //! Reset prescaler
        numBits <= 0;  //! Reset bit counter
        state <= DATA;
      end

      DATA: begin
        if (prescaler == PRESCALER_COUNT) begin  //! delay for 1 bit time
          if (numBits < 8) begin  //! If there are still bits to send...
            dataOut   <= dataReg[0];  //! Send the LSB
            dataReg   <= {1'b0, dataReg[7:1]};  // Shift right
            numBits   <= numBits + 1;  //! Increment bit counter
            prescaler <= 0;  //! Reset prescaler
          end else begin  //! If all bits have been sent...
            prescaler <= 0;  //! Reset prescaler
            state <= PARITY_BIT;
          end
        end else begin
          prescaler <= prescaler + 1;
        end
      end

      PARITY_BIT: begin
        if (prescaler == PRESCALER_COUNT) begin  //! delay for 1 bit time
          case (PARITY) //! Match parity setting and either transmit the parity bit or skip it
            'b01: dataOut <= ^dataIn;  //! Odd parity
            'b10: dataOut <= ~^dataIn;  //! Even parity
            default: dataOut <= 1'b1;  //! No parity
          endcase
          prescaler <= 0;
          state <= STOP_BIT;
        end else begin
          prescaler <= prescaler + 1;
        end
      end

      STOP_BIT: begin
        //! delay for 1 or 2 bit periods
        if (prescaler == PRESCALER_COUNT * ({31'b0, STOP_BITS} + 1)) begin
          dataOut <= 1'b1;  //! Set stop bit
          state <= IDLE;  //! Return to idle state
          prescaler <= 0;  //! Reset prescaler
        end else begin
          prescaler <= prescaler + 1;
        end
      end

      default: state <= IDLE;  //! Default to idle state
    endcase
  end
endmodule
