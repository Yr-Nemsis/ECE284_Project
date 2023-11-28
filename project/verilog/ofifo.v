// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module ofifo (clk, in, out, rd, wr, o_full, reset, o_ready, o_valid);

  parameter col  = 8;
  parameter bw = 16;

  input  clk;
  input  [col-1:0] wr;
  input  rd;
  input  reset;
  input  [bw*col-1:0] in;
  output [bw*col-1:0] out;
  output o_full;
  output o_ready;
  output o_valid;

  wire [col-1:0] empty;
  wire [col-1:0] full;
  reg  rd_en;
  
  genvar i;

  wire [col-1:0] fifo_full;
  wire [col-1:0] fifo_empty;

  assign o_ready = (|fifo_full)? 1'b0: 1'b1; // when all fifo's are not full
  assign o_full  = ~o_ready ; // When any fifo is full 
  assign o_valid = fifo_full[0] ; // when i have a vector to output (fifo0 is full)

  for (i=0; i<col ; i=i+1) begin : col_num
      fifo_depth8 #(.bw(bw)) fifo_instance (
	      .rd_clk(clk),
	      .wr_clk(clk),
	      .rd(rd),
	      .wr(wr[i]),
        .o_empty(fifo_empty[i]),
        .o_full(fifo_full),
	      .in(in[bw*(i+1)-1:bw*i]),
	      .out(out[bw*(i+1)-1:bw*i]),
        .reset(reset)
      );
  end


  always @ (posedge clk) begin
   if (reset) begin
      rd_en <= 0;
   end
   else
    if(rd)
    begin
      rd_en <= 'b1;
    end
 
  end


 

endmodule
