// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module sram_12b_w1024 (CLK, D, Q, CEN, WEN, A);

  parameter bw = 12;
  parameter num = 1024;

  parameter idx_bits = 10
  input  CLK;
  input  WEN;
  input  CEN;
  input  [bw-1:0] D;
  input  [idx_bits-1:0] A;
  output [bw-1:0] Q;


  reg [bw-1:0] memory [num-1:0];
  reg [idx_bits-1:0] add_q;
  assign Q = memory[add_q];

  always @ (posedge CLK) begin

   if (!CEN && WEN) // read 
      add_q <= A;
   if (!CEN && !WEN) // write
      memory[A] <= D; 

  end

endmodule
