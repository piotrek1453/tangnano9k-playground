`timescale 1ns / 1ps

module fifo_tb;

  // Parametry FIFO
  parameter DATA_WIDTH = 8;
  parameter FIFO_DEPTH = 16;

  // Sygnaly testowe
  reg clkIn;
  reg resetIn;
  reg writeEnableIn;
  reg readEnableIn;
  reg loadEnableIn;
  reg [DATA_WIDTH-1:0] dataIn;
  reg [DATA_WIDTH-1:0] load[FIFO_DEPTH-1:0];
  wire [DATA_WIDTH-1:0] serialDataOut;
  wire fullOut;
  wire emptyOut;
  wire writeReadyOut;
  wire readReadyOut;
  wire [$clog2(FIFO_DEPTH)-1:0] tailPointerOut;

  // Instancja modułu FIFO
  fifo #(
      .DATA_WIDTH(DATA_WIDTH),
      .FIFO_DEPTH(FIFO_DEPTH)
  ) uut (
      .clkIn(clkIn),
      .resetIn(resetIn),
      .writeEnableIn(writeEnableIn),
      .readEnableIn(readEnableIn),
      .loadEnableIn(loadEnableIn),
      .dataIn(dataIn),
      .load(load),
      .serialDataOut(serialDataOut),
      .fullOut(fullOut),
      .emptyOut(emptyOut),
      .writeReadyOut(writeReadyOut),
      .readReadyOut(readReadyOut),
      .tailPointerOut(tailPointerOut)
  );

  // Generowanie zegara
  initial begin
    clkIn = 0;
    forever #5 clkIn = ~clkIn;  // 100 MHz clock
  end

  // Testowanie FIFO
  initial begin
    // Inicjalizacja sygnałów
    resetIn = 1;
    writeEnableIn = 0;
    readEnableIn = 0;
    loadEnableIn = 0;
    dataIn = 0;

    // Reset
    #10 resetIn = 0;
    #10 resetIn = 1;
    #10 resetIn = 0;

    // Zapis danych do FIFO
    writeEnableIn = 1;
    dataIn = 8'hA5;  // Pierwszy bajt
    #10;
    dataIn = 8'h5A;  // Drugi bajt
    #10;
    writeEnableIn = 0;

    // Odczyt danych z FIFO
    readEnableIn  = 1;
    #10;
    readEnableIn = 0;

    // Ładowanie danych równoległych
    loadEnableIn = 1;
    load[0] = 8'h01;
    load[1] = 8'h02;
    load[2] = 8'h03;
    load[3] = 8'h04;
    #10;
    loadEnableIn = 0;

    // Odczyt danych po załadowaniu
    readEnableIn = 1;
    #40;
    readEnableIn = 0;

    // Koniec symulacji
    #50 $finish;
  end

  // Generowanie przebiegów czasowych
  initial begin
    $dumpfile("fifo_tb.vcd");
    $dumpvars(0, fifo_tb);
  end

endmodule
