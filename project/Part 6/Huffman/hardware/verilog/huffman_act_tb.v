module huffman_act_tb;

parameter num_words = 8; //determined by the 8 by 8 MAC array
parameter bw = 4; //number of bits per word, which is fixed

reg clk = 0;
reg reset = 0;
reg in;
reg valid_in = 1'b1;
wire [bw*num_words-1: 0] out;
wire valid;

integer counter = 0;
integer curr_cycles = 2;
integer w_file ; // file handler
integer w_scan_file ; // file handler

integer captured_data;

huffman_act huff_instance (
        .clk(clk),
        .reset(reset), 
        .valid_in(valid_in),
        .in(in), 
        .out(out),
        .valid(valid));

initial begin 

  w_file = $fopen("encoded_activations.txt", "r");  //weight data

  $dumpfile("huffman_act_tb.vcd");
  $dumpvars(0,huffman_act_tb);
 

  #1 clk = 1'b0;  reset = 1;
  #1 clk = 1'b1;  
  #1 clk = 1'b0;  
  #1 clk = 1'b1; reset = 0;  
  $display("-------------------- Computation start --------------------");
  
  while (!$feof(w_file)) begin

    w_scan_file = $fscanf(w_file, "%c\n", captured_data);
    //if (captured_data == "1")
      //$display("%c", captured_data);
    //else
    if (captured_data == "1")
      in = 1'b1;
    else
      in = 1'b0;
    if (valid) begin
      $display("%b", out);
      counter = counter + 1;
      //if (counter % 8 == 0)
        //$display("\n");
    end

    //$display("%c", captured_data);
      #1 clk = 1'b0;
      #1 clk = 1'b1;
      curr_cycles = curr_cycles + 2;
  end

  #1 clk = 1'b0;
  #1 clk = 1'b1;
  if (valid) begin
      $display("%b", out);
      counter = counter + 1;
      //if (counter % 8 == 0)
        //$display("\n");
    end

  #10 $finish;


end

endmodule
