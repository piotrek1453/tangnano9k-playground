`default_nettype none

typedef enum logic [1:0] {
  IDLE,
  START_BIT,
  DATA,
  STOP_BIT
} uart_tx_state_t;

module uart_tx #(
    parameter integer PRESCALER_COUNT = 234  //! Assuming 27MHz clock, baud rate 115200
) (
    input wire clk,                           //! Clock signal
    input wire [7:0] dataIn,                  //! Data word input
    input wire start,                         //! Transmission start strobe
    output reg dataOut,                       //! Current data bit output
    output reg busy                           //! Done flag
);
  reg [$clog2(PRESCALER_COUNT)-1:0] prescaler = 0;  //! Prescaler counter
  reg [3:0] numBits = 0;                           //! Payload data bit counter
  reg [7:0] dataReg;                               //! Data word register
  uart_tx_state_t state;                           //! State register

  initial begin
    dataOut = 1'b1;  //! Set idle state for UART
    busy = 1'b0;     //! Clear busy flag
    state = IDLE;    //! Set initial state
    prescaler = 0;   //! Reset prescaler
    numBits = 0;     //! Reset bit counter
    dataReg = 8'b0;  //! Clear data register
  end

  always @(posedge clk) begin : uart_tx_fsm
    case (state)
      IDLE: begin
        dataOut <= 1'b1;  //! Set idle state for UART
        if (start) begin
          state <= START_BIT;  //! Go to start bit state
          dataReg <= dataIn;   //! Load data to be sent
          busy <= 1'b1;        //! Set busy flag
          prescaler <= 0;      //! Reset prescaler
          numBits <= 0;        //! Reset bit counter
        end
      end

      START_BIT: begin
        if (prescaler >= PRESCALER_COUNT) begin
          prescaler <= 0;  //! Reset prescaler
          state <= DATA;   //! Go to data state
          dataOut <= 1'b0; //! Set start bit
        end else begin
          prescaler <= prescaler + 1;
        end
      end

      DATA: begin
        if (prescaler >= PRESCALER_COUNT) begin
          if (numBits < 8) begin
            prescaler <= 0;  //! Reset prescaler
            dataOut <= dataReg[0];  //! Send the LSB
            dataReg <= dataReg >> 1; //! Shift right
            numBits <= numBits + 1; //! Increment bit counter
          end else begin
            state <= STOP_BIT;    //! Go to stop bit state
          end
        end else begin
          prescaler <= prescaler + 1;
        end
      end

      STOP_BIT: begin
        dataOut <= 1'b1;  //! Set stop bit
        if (prescaler >= PRESCALER_COUNT) begin
          dataOut <= 1'b1;  //! Set stop bit
          prescaler <= 0;  //! Reset prescaler
          state <= IDLE;   //! Return to idle state
          busy <= 1'b0;    //! Clear busy flag
        end else begin
          prescaler <= prescaler + 1;
        end
      end

      default: begin
        state <= IDLE;  //! Default to idle state
        busy <= 1'b0;   //! Clear busy flag
        dataOut <= 1'b1; //! Set idle output
      end
    endcase
  end
endmodule
