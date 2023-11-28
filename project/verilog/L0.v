module L0(clk, wr, rd, reset, in, out, o_full, o_ready);

  parameter col  = 8;
  parameter bw = 4;

  input  clk;
  input  wr;
  input  rd;
  input  reset;
  input  [bw*col-1:0] in;
  output [bw*col-1:0] out;
  output o_full;
  output o_ready;

  wire [col-1:0] empty;
  wire [col-1:0] full;
  reg  rd_en;
  
  genvar i;

  wire [col-1:0] fifo_full;
  wire [col-1:0] fifo_empty;

  reg [col-1:0] rd_temp;

  reg [bw*col-1:0] out_temp;
  wire [bw*col-1:0] out_wire;

  assign o_ready = (|fifo_full)? 1'b0: 1'b1; // when all fifo's are not full
  assign o_full  = ~o_ready ; // When any fifo is full 

  for (i=0; i<col ; i=i+1) begin : col_num
      fifo_depth8 #(.bw(bw)) fifo_instance (
	      .rd_clk(clk),
	      .wr_clk(clk),
	      .rd(rd_temp[i]),
	      .wr(wr),
        .o_empty(fifo_empty[i]),
        .o_full(fifo_full[i]),
	      .in(in[bw*(i+1)-1:bw*i]),
	      .out(out_wire[bw*(i+1)-1:bw*i]),
        .reset(reset)
      );
  end


  always @ (posedge clk) begin
    if(reset)
    begin
      rd_temp <= 'b0;
    end
    else
    begin
      rd_temp[0] <= rd; 
      rd_temp[1] <= rd_temp[0]; 
      rd_temp[2] <= rd_temp[1]; 
      rd_temp[3] <= rd_temp[2]; 
      rd_temp[4] <= rd_temp[3]; 
      rd_temp[5] <= rd_temp[4]; 
      rd_temp[6] <= rd_temp[5]; 
      rd_temp[7] <= rd_temp[6]; 

      out_temp <= out_wire;
    end

  end

  assign out = out_temp;


endmodule