// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module sram_32b_w128 (CLK, D, Q, CEN, WEN, A);

  parameter bw = 32;
  parameter idx_bits = 7;
  input  CLK;
  input  WEN;
  input  CEN;
  input  [bw-1:0] D;
  input  [idx_bits-1:0] A;
  output [bw-1:0] Q;
  parameter num = 128;

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
