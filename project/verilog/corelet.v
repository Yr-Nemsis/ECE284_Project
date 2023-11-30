module corelet(clk, reset, in_mac, in_sfp, out_mac, out_sfp, inst, ofifo_valid);

  parameter bw = 4;
  parameter psum_bw = 16;
  parameter col = 8;
  parameter row = 8;

  input clk, reset;
  input [33:0] inst;

  input [col*bw-1:0] in_mac;
  
  
  output [psum_bw*col-1:0] out_mac;
  output ofifo_valid;

  input [col*psum_bw-1:0] in_sfp;
  output [col*psum_bw-1:0] out_sfp;

  //wire [1:0] l0_status; // l0_status[0] => full, l0_status_[1] => ready

  wire [bw*row-1:0] l0_mac;

  wire [col-1:0] out_s_valid;

  wire [psum_bw*col-1:0] mac_out;

  // inst[4] == 1 then read from L0
  // inst[5] == 1 write to L0
  l0 #(.bw(bw), .row(row)) L0_instance(
    .clk(clk),
    .wr(inst[5]),
    .rd(inst[4]),
    .reset(reset),
    .in(in_mac),
    .out(l0_mac),
    .o_full(),
    .o_ready()
  );

  mac_array #(.bw(bw), .psum_bw(psum_bw)) mac_array_instance(
    .clk(clk),
    .reset(reset),
    .in_w(l0_mac),
    .inst_w(inst[1:0]),
    .in_n('b0),
    .valid(out_s_valid),
    .out_s(mac_out)
  );

  ofifo #(.psum_bw(psum_bw), .col(col)) ofifo_instance(
    .clk(clk),
    .reset(reset),
    .wr(out_s_valid),
    .rd(inst[6]),
    .in(mac_out),
    .out(out_mac),
    .o_ready(),
    .o_full(),
    .o_valid(ofifo_valid)
  );

  genvar i;
  for(i = 0; i < col; i = i +1)
  begin
    sfp  #(.bw(bw), .psum_bw(psum_bw)) sfp_instance(
      .clk(clk),
      .acc(inst[33]),
      .relu(),
      .reset(reset),
      .in(in_sfp[psum_bw*(i+1)-1:psum_bw*i]),
      .thres(),
      .out(out_sfp[psum_bw*(i+1)-1:psum_bw*i])
    );
  end
  


endmodule