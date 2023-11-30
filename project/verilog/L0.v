// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module l0 (clk, in, out, rd, wr, o_full, reset, o_ready);

  parameter row  = 8;
  parameter bw = 4;

  input  clk;
  input  wr;
  input  rd;
  input  reset;
  input  [row*bw-1:0] in;
  output [row*bw-1:0] out;
  output o_full;
  output o_ready;

  wire [row-1:0] empty;
  wire [row-1:0] full;
  reg [row-1:0] rd_en;
  
  genvar i;
  integer ii;

  assign o_full  =  |full; // any fifo is full
  assign o_ready =  ~o_full; // all fifos are not full

  for (i=0; i<row ; i=i+1) begin : row_num
    fifo_depth8 #(.bw(bw)) fifo_instance (
      .rd_clk(clk),
      .wr_clk(clk),
      .rd(rd_en[i]),
      .wr(wr),
      .o_empty(empty[i]),
      .o_full(full[i]),
      .in(in[(bw*(i+1))-1:bw*(i)]),
      .out(out[(bw*(i+1))-1:bw*(i)]),
      .reset(reset)
    );
  end


  always @ (posedge clk) begin
   if (reset) begin
      rd_en <= 8'b00000000;
   end
   else

      /////////////// version1: read all row at a time ////////////////
      // for(ii = 0; ii < row; ii = ii +1)
      // begin
      //   rd_en[ii] <= rd;
      // end
      ///////////////////////////////////////////////////////



      //////////////// version2: read 1 row at a time /////////////////
      rd_en[0] <= rd;
      for(ii = 1; ii < row; ii = ii+1)
      begin
        rd_en[ii] <= rd_en[ii-1];
      end 
      ///////////////////////////////////////////////////////
    end

endmodule
