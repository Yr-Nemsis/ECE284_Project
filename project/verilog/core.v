module core(clk, inst, ofifo_valid, L0_full, D_xmem, sfp_out, reset, user_mode);

  parameter bw = 4;
  parameter psum_bw = 16;
  parameter col = 8;
  parameter row = 8;

  input clk, reset;
  input [33:0] inst;
  output ofifo_valid;
  output L0_full;
  input [bw*row-1:0] D_xmem;
  output [col*psum_bw-1:0] sfp_out;

  wire [31:0] L1_out; // connect weight & act SRAM to corelet

  wire [psum_bw*col-1:0] ofifo_out;
  wire [psum_bw*col-1:0] sfp_in;

  input user_mode;

  reg [10:0] ctr; 

  corelet #(.bw(bw), .psum_bw(psum_bw)) corelet_instance(
    .clk(clk), 
    .reset(reset),
    .in_mac(L1_out),
    .in_sfp(sfp_in),
    .out_mac(ofifo_out),
    .out_sfp(sfp_out),
    .inst(inst),
    .ofifo_valid(ofifo_valid),
    .L0_full(L0_full)
  );


  sram_32b_w2048 weight_input_sram(
    .CLK(clk), 
    .D(D_xmem), 
    .Q(L1_out), 
    .CEN(inst[19]), // inst[19] is CEN_xmem
    .WEN(inst[18]), // inst[18] is WEN_xmem 
    .A(inst[17:7]) // 11 bit address 
  );
  
  wire [10:0] A_psum;
  always @ (posedge clk) begin
    if(reset) begin
      ctr <= 0;
    end
    else begin
      if(ofifo_valid) begin
        ctr <= ctr + 1;
      end
    end
  end

  assign A_psum = (user_mode)? inst[30:20] : ctr;

  sram_128b_w2048 psum_sram(
    .CLK(clk), 
    .D(ofifo_out), 
    .Q(sfp_in), 
    .CEN(inst[32]), 
    .WEN(inst[31]), 
    .A(A_psum)
  );





endmodule

