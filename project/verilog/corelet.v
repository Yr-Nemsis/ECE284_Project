module corelet(clk, reset, in, out, inst, l0_status);

  parameter bw = 4;
  parameter psum_bw = 16;
  parameter col = 8;
  parameter row = 8;

  input clk, reset;
  input [33:0] inst;
  input [col*bw-1:0] in;
  input [col*bw-1:0] out;
  output [1:0] l0_status; // l0_status[0] => full, l0_status_[1] => ready



  // inst[4] == 1 then read from L0
  // inst[5] == 1 write to L0
  l0 #(.bw(bw), .row(row)) L0_instance(
    .clk(clk),
    .wr(inst[5]),
    .rd(inst[4]),
    .reset(reset),
    .in(in),
    .out(out),
    .o_full(l0_status[0]),
    .o_ready(l0_status[1])
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