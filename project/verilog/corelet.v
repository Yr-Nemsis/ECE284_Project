module corelet();


  sram_4b_w64 L0(
    .CLK(clk), 
    .D(), 
    .Q(), 
    .CEN(), 
    .WEN(), 
    .A()
  );

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


endmodule