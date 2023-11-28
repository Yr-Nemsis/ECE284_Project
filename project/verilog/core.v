module core(clk, inst, ofifo_valid, D_xmem, sfp_out, reset);

  parameter bw = 4;
  parameter psum_bw = 16;
  parameter col = 8;
  parameter row = 8;

  input clk, reset;
  input [33:0] inst;
  output ofifo_valid;
  input [bw*row-1:0] D_xmem;
  output [col*psum_bw-1:0] sfp_out;


  corelet #(#(.bw(bw), .psum_bw(psum_bw))) corelet_instance(

  );

  // TODO:
  // change size of this SRAM. Must fit all the inputs and weights.
  // SRAM should dispcatch 1 vector (32 bits) per cycle
  // 
  sram_32b_w128 weight_input_sram(
    .CLK(clk), 
    .D(D_xmem), 
    .Q(), 
    .CEN(), 
    .WEN(), 
    .A()
  );



  // Don't know how big psum_sram needs to be. Assuming 1024 entries of 12 bits for now.
  sram_12b_w1024 psum_sram(
    .CLK(clk), 
    .D(), 
    .Q(), 
    .CEN(), 
    .WEN(), 
    .A()
  );





endmodule