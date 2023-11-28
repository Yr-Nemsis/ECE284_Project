module corelet(clk, reset, in, out, inst);

  parameter bw = 4;
  parameter psum_bw = 16;
  parameter col = 8;
  parameter row = 8;

  input clk, reset;
  input [33:0] inst;
  input [col*bw-1:0] in;
  input [col*bw-1:0] out;




  // inst[4] == 1 then read from L0
  // inst[5] == 1 write to L0
  L0 #(.bw(bw)) L0_instance(
    .clk(clk),
    .wr(inst[5]),
    .rd(inst[4]),
    .reset(reset),
    .in(in),
    .out(out),
    .o_full(),
    .o_ready()
  );
/*
  mac_array #(.bw(bw), .psum_bw(psum_bw)) mac_array_instance(
    .clk(clk),
    .reset(reset),
    .in_w(),
    .inst_w(),
    .in_n(),
    .valid(),
    .out_s()
  );

  ofifo #(.bw(psum_bw), .psum_bw(psum_bw)) ofifo_instance(
   
  );

  sfp  #(.bw(bw), .psum_bw(psum_bw)) sfp_instance(

  );
*/

endmodule