// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
`timescale 1ns/1ps
module ofifo (clk, in, out, wr, rd, o_full, reset, o_ready, o_valid);

  parameter col  = 8;
  parameter psum_bw = 16;

  input  clk;
  input  [col-1:0] wr;
  input  rd;
  input  reset;
  input  [psum_bw*col-1:0] in;
  output [psum_bw*col-1:0] out;
  output o_full;
  output o_ready;
  output o_valid;

  wire [col-1:0] empty;
  wire [col-1:0] full;
  
  reg rd_en;
  reg  [col-1:0] wr_en;
  reg  [col-1:0] wr_cnt;

  
  
  
  genvar i;

  wire [col-1:0] fifo_full;
  wire [col-1:0] fifo_empty;

  integer ii;

  assign o_ready = (|fifo_full)? 1'b0: 1'b1; // when all fifo's are not full
  assign o_full  = ~o_ready ; // When any fifo is full 
  assign o_valid = ~(|fifo_empty) ; // when i have a vector to output (all fifos are not empty)

  for (i=0; i<col ; i=i+1) begin : col_num
      fifo_depth64 #(.bw(psum_bw)) fifo_instance (
	      .rd_clk(clk),
	      .wr_clk(clk),
	      .rd(rd_en),
	      .wr(wr_en[i]),
        .o_empty(fifo_empty[i]),
        .o_full(fifo_full[i]),
	      .in(in[psum_bw*(i+1)-1:psum_bw*i]),
	      .out(out[psum_bw*(i+1)-1:psum_bw*i]),
        .reset(reset)
      );
  end


  always @ (posedge clk) begin
    if (reset) 
    begin
      wr_en <= 0;
      rd_en <= 0;
      wr_cnt <= 0;
    end
    else
    begin
      for (ii=0; ii<col; ii++) begin
        if (wr[ii]) begin
          wr_cnt[ii] <= !wr_cnt[ii];
        end
      end
      wr_en <= wr_cnt;
      rd_en <= rd;
    end
  end



endmodule
