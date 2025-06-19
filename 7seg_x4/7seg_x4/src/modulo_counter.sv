`default_nettype none

typedef enum logic [1:0] {
  RESET,    // initial state
  COUNT,    // usual incrementation state
  OVERFLOW  // increment and set overflow flag
} counter_state_t;

//! asynchronous modulo counter
module modulo_counter #(
    parameter unsigned MODULO = 10  //! max number of possible states of the counter (max decimal value-1)
) (
    input wire countIn,  //! input causing the counter to go to next state
    input wire resetIn,  //! set state to default
    output reg [$clog2(MODULO)-1:0] countOut,  //! decimal output
    output reg overflowOut  //! flag set when counter rolls over
);

  counter_state_t current_state, next_state;

  //! sequential logic
  always @(posedge countIn, negedge resetIn) begin : counter_sm_seq
    if (!resetIn) begin
      current_state <= RESET;
      countOut <= 'd0;
      overflowOut <= 1'b0;
    end else begin
      current_state <= next_state;

      //! registered outputs
      if (next_state == OVERFLOW) begin
        countOut <= 'd0;
        overflowOut <= 1'b1;
      end else if (next_state == COUNT) begin
        countOut <= countOut + 1;
        overflowOut <= 1'b0;
      end
    end
  end

  //! ombinational next-state logic
  always_comb begin : counter_sm_comb
    next_state = current_state;  //! default to current state

    case (current_state)
      RESET: next_state = COUNT;
      COUNT: if (countOut >= MODULO - 1) next_state = OVERFLOW;
      OVERFLOW: next_state = COUNT;
      default: next_state = current_state;
    endcase
  end

endmodule
