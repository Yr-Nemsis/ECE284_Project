`timescale 1ns/1ps

module chip(clk1, clk2, reset1, reset2, inst1, inst2, mem1, mem2, sfp_out1, sfp_out2);

  parameter bw = 4;
  parameter psum_bw = 16;
  parameter col = 8;
  parameter row = 8;

  input clk1, reset1;
  input [33:0] inst1;
  input [bw*row-1:0] mem1;
  output [col*psum_bw-1:0] sfp_out1;

  input clk2, reset2;
  input [33:0] inst2;
  input [bw*row-1:0] mem2;
  output [col*psum_bw-1:0] sfp_out2; 



core  #(.bw(bw), .col(col), .row(row)) core_instance0 (
	.clk(clk1), 
	.inst(inst1),
  .D_xmem(mem1), 
  .sfp_out(sfp_out1), 
	.reset(reset1)
);

core  #(.bw(bw), .col(col), .row(row)) core_instance1 (
	.clk(clk2), 
	.inst(inst2),
  .D_xmem(mem2), 
  .sfp_out(sfp_out2), 
	.reset(reset2)
);



endmodule