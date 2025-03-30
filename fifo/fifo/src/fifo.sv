`default_nettype none

typedef enum logic [2:0] {
  EMPTY,              // FIFO is empty, no data is stored
  SEQUENTIAL_INPUT,   // Writing data sequentially into the FIFO
  MEMORIZE,           // Holding data without any read/write operations
  SEQUENTIAL_OUTPUT,  // Reading data sequentially from the FIFO
  LOAD,               // Loading data into the FIFO in parallel
  FULL                // FIFO is full, no more data can be written
} fifo_state_t;

module fifo
#(
  parameter integer DATA_WIDTH = 8,  // Bit-width of each word
  parameter integer FIFO_DEPTH = 16  // Number of words
)(
  input wire clkIn, //! Clock signal
  input wire writeEnableIn, //! Write to FIFO enable signal
  input wire [DATA_WIDTH-1:0] dataIn, //! Sequential data word input
  input wire readEnableIn, //! Read from FIFO enable signal
  input wire loadEnableIn, //! Load FIFO enable signal
  input wire [DATA_WIDTH-1:0][FIFO_DEPTH-1:0] load, //! Load data parallel input
  input wire resetIn, //! Reset signal

  output reg [DATA_WIDTH-1:0] serialDataOut, //! Serial data word output
  output reg fullOut, //! FIFO full flag
  output reg emptyOut, //! FIFO empty flag
  output reg writeReadyOut, //! FIFO write ready flag
  output reg readReadyOut, //! FIFO read ready flag
  output reg [$clog2(FIFO_DEPTH)-1:0] tailPointerOut //! FIFO tail pointer
);

  reg [$clog2(FIFO_DEPTH) - 1:0] tailPointerReg;
  reg [DATA_WIDTH - 1:0][FIFO_DEPTH-1:0] dataReg;
  fifo_state_t state;

  always @(*) begin
    serialDataOut = dataReg[0];
  end

  //! Initialize module for EMPTY state: sets all internal registers and outputs to their default values
  initial begin : fifo_init
    fullOut = 'b0;
    emptyOut = 'b1;
    tailPointerOut = 'b0;

    tailPointerReg = 'd0;
    dataReg = 'b0;
    state = EMPTY;
  end

  always @(posedge clkIn) begin : fifo_fsm

    if (resetIn) begin
      fullOut <= 'b0;
      emptyOut <= 'b1;
      tailPointerOut <= 'b0;

      tailPointerReg <= 'd0;
      dataReg = 'b0;
      state <= EMPTY;
    end

    case (state)
      EMPTY: begin
        fullOut <= 'b0;
        emptyOut <= 'b1;
        tailPointerOut <= tailPointerReg;
        writeReadyOut <= 'b1;
        readReadyOut <= 'b0;

        if (writeEnableIn) begin
          state <= SEQUENTIAL_INPUT;
        end
        if (loadEnableIn) begin
          state <= LOAD;
        end
      end

      SEQUENTIAL_INPUT: begin
        writeReadyOut <= 'b0;
        readReadyOut <= 'b0;
        dataReg[tailPointerReg] <= dataIn;
        tailPointerReg <= tailPointerReg + 1;
        fullOut <= 'b0;
        emptyOut <= 'b0;
        if (!writeEnableIn) begin
          state <= MEMORIZE;
        end
      end

      MEMORIZE: begin
        if (tailPointerReg == FIFO_DEPTH - 1) begin
          state <= FULL;
        end
        if (readEnableIn) begin
          state <= SEQUENTIAL_OUTPUT;
        end
        else begin
          writeReadyOut <= 'b1;
          readReadyOut <= 'b1;
          fullOut <= 'b0;
          emptyOut <= 'b0;
        end
      end

      SEQUENTIAL_OUTPUT: begin
        writeReadyOut <= 'b0;
        readReadyOut <= 'b1;
        dataReg <= dataReg >> 1;
        tailPointerReg <= tailPointerReg - 1;
        fullOut <= 'b0;
        emptyOut <= 'b0;
        if (tailPointerReg == 0) begin
          state <= EMPTY;
        end
        if (!readEnableIn) begin
          state <= MEMORIZE;
        end
      end

      LOAD: begin
        writeReadyOut <= 'b0;
        readReadyOut <= 'b0;
        dataReg <= load;
        tailPointerReg <= FIFO_DEPTH - 1;
        state <= FULL;
      end

      FULL: begin
        writeReadyOut <= 'b0;
        readReadyOut <= 'b1;
        emptyOut <= 'b0;
        fullOut <= 'b1;
        tailPointerReg <= DATA_WIDTH - 1;
        if (readEnableIn) begin
          state <= SEQUENTIAL_OUTPUT;
        end
        if (loadEnableIn) begin
          state <= LOAD;
        end
      end

      default: state <= EMPTY;
    endcase

  end

endmodule
