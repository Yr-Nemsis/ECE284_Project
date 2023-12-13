// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
`timescale 1ns/1ps

module core_tb;

parameter bw = 4;
parameter psum_bw = 16;
parameter len_kij = 9;
parameter len_onij = 64;
parameter col = 8;
parameter row = 8;
parameter len_nij = 100;

reg clk = 0;
reg reset = 1;

wire [33:0] inst_q; 

reg [1:0]  inst_w_q = 0; 
reg [bw*row-1:0] D_xmem_q = 0;
reg CEN_xmem = 1;
reg WEN_xmem = 1;
reg [10:0] A_xmem = 0;
reg CEN_xmem_q = 1;
reg WEN_xmem_q = 1;
reg [10:0] A_xmem_q = 0;
reg CEN_pmem = 1;
reg WEN_pmem = 1;
reg [10:0] A_pmem = 0;
reg CEN_pmem_q = 1;
reg WEN_pmem_q = 1;
reg [10:0] A_pmem_q = 0;
reg ofifo_rd_q = 0;
reg relu_q = 0;
reg ififo_rd_q = 0;
reg l0_rd_q = 0;
reg l0_wr_q = 0;
reg execute_q = 0;
reg load_q = 0;
reg acc_q = 0;
reg acc = 0;

reg [1:0]  inst_w; 
reg [bw*row-1:0] D_xmem;
reg [psum_bw*col-1:0] answer;


reg ofifo_rd;
reg relu;
reg ififo_rd;
reg l0_rd;
reg l0_wr;
reg execute;
reg load;
reg [8*30:1] stringvar;
reg [8*30:1] w_file_name;
wire ofifo_valid;
wire [col*psum_bw-1:0] sfp_out;


integer x_file, x_scan_file ; // file_handler
integer w_file, w_scan_file ; // file_handler
integer acc_file, acc_scan_file ; // file_handler
integer out_file, out_scan_file ; // file_handler
integer captured_data; 
integer t, i, j, k, kij;
integer error;

integer psum_file, psum_scan_file;
reg [psum_bw*col-1:0] psum_check;
integer psum_chk_kij = 8;
reg [8*30:1] psum_file_name;

assign inst_q[33] = acc_q;
assign inst_q[32] = CEN_pmem_q;
assign inst_q[31] = WEN_pmem_q;
assign inst_q[30:20] = A_pmem_q;
assign inst_q[19]   = CEN_xmem_q;
assign inst_q[18]   = WEN_xmem_q;
assign inst_q[17:7] = A_xmem_q;
assign inst_q[6]   = ofifo_rd_q;
assign inst_q[5]   = relu_q;
assign inst_q[4]   = ififo_rd_q;
assign inst_q[3]   = l0_rd_q;
assign inst_q[2]   = l0_wr_q;
assign inst_q[1]   = execute_q; 
assign inst_q[0]   = load_q; 


core  #(.bw(bw), .col(col), .row(row)) core_instance (
	  .clk(clk), 
	  .inst(inst_q),
	  .ofifo_valid(ofifo_valid),
    .D_xmem(D_xmem_q), 
    .sfp_out(sfp_out), 
	  .reset(reset)
); 

reg act_in;
reg act_start;
wire act_valid;
wire [bw*row-1:0] act_out;
reg act_first = 1'b0;

reg w_in;
reg w_start;
wire w_valid;
wire [bw*row-1:0] w_out;
reg w_first = 1'b0;

huffman_act act_decoder(
  .clk(clk),
  .reset(reset),
  .in(act_in),
  .valid_in(act_start),
  .out(act_out),
  .valid(act_valid)
);

huffman_w w_decoder(
  .clk(clk),
  .reset(reset),
  .in(w_in),
  .valid_in(w_start),
  .out(w_out),
  .valid(w_valid)
);


initial begin 

  inst_w   = 0; 
  D_xmem   = 0;
  CEN_xmem = 1;
  WEN_xmem = 1;
  A_xmem   = 0;
  ofifo_rd = 0;
  relu = 0;
  ififo_rd = 0;
  l0_rd    = 0;
  l0_wr    = 0;
  execute  = 0;
  load     = 0;

  act_in = 0;
  act_start = 0;

  w_in = 0;
  w_start = 0;


  $dumpfile("core_tb.vcd");
  $dumpvars(0,core_tb);

  x_file = $fopen("encoded_activations.txt", "r");


  //////// Reset /////////
  #0.5 clk = 1'b0;   reset = 1;
  #0.5 clk = 1'b1; 

  for (i=0; i<10 ; i=i+1) begin
    #0.5 clk = 1'b0;
    #0.5 clk = 1'b1;  
  end

  #0.5 clk = 1'b0;   reset = 0;
  #0.5 clk = 1'b1; 

  #0.5 clk = 1'b0; WEN_xmem = 0; CEN_xmem = 0; 
  #0.5 clk = 1'b1;   
  /////////////////////////


  A_xmem = 11'b0; 
  
  ////// Decode activation and write to memory ///////
  while (!$feof(x_file)) begin

    x_scan_file = $fscanf(x_file, "%c\n", captured_data);
    act_start = 1'b1;

    if (captured_data == "1")
      act_in = 1'b1;
    else
      act_in = 1'b0;
    if (act_valid) begin
      D_xmem = act_out;
      if(act_first) begin
        A_xmem = A_xmem + 1;
      end
      else begin
        act_first = 1'b1;
      end
      
    end

    #0.5 clk = 1'b0;
    #0.5 clk = 1'b1;
     
  end

  #0.5 clk = 1'b0;
  #0.5 clk = 1'b1;
  if (act_valid) begin
    D_xmem = act_out;
    A_xmem = A_xmem + 1; 
  end
  #0.5 clk = 1'b0;
  #0.5 clk = 1'b1;

  #0.5 clk = 1'b0;  WEN_xmem = 1;  CEN_xmem = 1; A_xmem = 0;
  #0.5 clk = 1'b1; 

  $fclose(x_file);

  
  /////////////////////////////////////////////////

  /////// Decoding weights and writing to memory /////
  #0.5 clk = 1'b0;   reset = 1;
  #0.5 clk = 1'b1; 


  #0.5 clk = 1'b0;   reset = 0; WEN_xmem = 0; CEN_xmem = 0; 
  #0.5 clk = 1'b1;

  w_file = $fopen("encoded_weights.txt", "r"); 

  A_xmem = 11'b10000000000;

  w_start = 1'b1;
  while (!$feof(w_file)) begin

    w_scan_file = $fscanf(w_file, "%c\n", captured_data);
    

    if (captured_data == "1")
      w_in = 1'b1;
    else
      w_in = 1'b0;

    if (w_valid) begin
      D_xmem = w_out;
      if(w_first) begin
        A_xmem = A_xmem + 1;
      end
      else begin
        w_first = 1'b1;
      end
      
    end

    #0.5 clk = 1'b0;
    #0.5 clk = 1'b1;
     
  end

  #0.5 clk = 1'b0;
  #0.5 clk = 1'b1;
  if (w_valid) begin
    D_xmem = w_out;
    A_xmem = A_xmem + 1; 
  end
  #0.5 clk = 1'b0;
  #0.5 clk = 1'b1;

  #0.5 clk = 1'b0;  WEN_xmem = 1;  CEN_xmem = 1; A_xmem = 0;
  #0.5 clk = 1'b1;

  $fclose(w_file);

  ///////////////////////////////////////////////////


  A_pmem = 11'b00000000000;

  for (kij=0; kij<9; kij=kij+1) begin  // kij loop

  //////////////////// reset ////////////
    #0.5 clk = 1'b0;   reset = 1;
    #0.5 clk = 1'b1; 

    for (i=0; i<5 ; i=i+1) begin
      #0.5 clk = 1'b0;
      #0.5 clk = 1'b1;  
    end

    #0.5 clk = 1'b0;   reset = 0;
    #0.5 clk = 1'b1; 

    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   


    /////////////////////////////////////
    

    /////// Kernel data writing to L0 ///////
    A_xmem = 11'b10000000000 + kij * 8;

    for (t=0; t<col; t=t+1) begin  
      #0.5 clk = 1'b0;   WEN_xmem = 1; CEN_xmem = 0;
      if (t>0) begin
        A_xmem = A_xmem + 1;
        l0_wr = 1'b1;
        l0_rd = 1'b1;
        load = 1'b1;
      end
      #0.5 clk = 1'b1;  
    end

    
    // Finish writing data to L0 needs 8 more cycles
    for(t = 0; t < 8; t = t + 1) begin
      #0.5 clk = 1'b0; 
      if(t>0) begin
        l0_wr = 1'b0;
      end
      #0.5 clk = 1'b1; 
    end

    /////////////////////////////////////


    
    ////// provide some intermission to clear up the kernel loading and clean up l0///
    #0.5 clk = 1'b0;  load = 0; l0_rd =  1'b1;
    #0.5 clk = 1'b1;  
    

    for (i=0; i < 10 ; i=i+1) begin
      #0.5 clk = 1'b0;
      #0.5 clk = 1'b1;  
    end

    // turn off l0 reading
    l0_rd = 1'b0;
    for (i=0; i < 7 ; i=i+1) begin
      #0.5 clk = 1'b0;
      #0.5 clk = 1'b1;  
    end
    /////////////////////////////////////

    
    
    /////// Activation data writing to L0 and all other steps ///////
    //A_xmem = 11'd11;
    A_xmem = 11'd00000000000;

    case(kij)
      0: psum_file_name = "psum_pruned_kij0.txt";
      1: psum_file_name = "psum_pruned_kij1.txt";
      2: psum_file_name = "psum_pruned_kij2.txt";
      3: psum_file_name = "psum_pruned_kij3.txt";
      4: psum_file_name = "psum_pruned_kij4.txt";
      5: psum_file_name = "psum_pruned_kij5.txt";
      6: psum_file_name = "psum_pruned_kij6.txt";
      7: psum_file_name = "psum_pruned_kij7.txt";
      8: psum_file_name = "psum_pruned_kij8.txt";
    endcase

    psum_file = $fopen(psum_file_name, "r");
    psum_scan_file = $fscanf(psum_file,"%s", captured_data);
    psum_scan_file = $fscanf(psum_file,"%s", captured_data);
    psum_scan_file = $fscanf(psum_file,"%s", captured_data);


    // Write to fifo and execute
    for(t = 0; t < len_nij; t = t + 1) begin
      #0.5 clk = 1'b0; WEN_xmem = 1; CEN_xmem = 0;  WEN_pmem = 0; CEN_pmem = 0;
      if(t < len_nij) begin
        l0_wr = 1'b1;
        A_xmem = A_xmem + 1; 
      end
      else begin
        l0_wr = 1'b0;
      end
      if(t > 0) begin
        l0_rd = 1'b1;
        execute = 1'b1;
      end
      if(t > 16) begin
        ofifo_rd = 1'b1;
      end

      if(t > 18) begin
      psum_scan_file = $fscanf(psum_file,"%128b", psum_check);
       if(psum_check != core_instance.psum_sram.D) begin
          $display("ERROR: psum mismatch at t = %d, kij = %d", t, kij);
          $display("Expected: %h", psum_check);
          $display("Recieved: %h", core_instance.psum_sram.D); 
        end
      end

      if(t > 18) begin
        A_pmem = A_pmem + 1;
      end

      #0.5 clk = 1'b1; 
    end

    // Finish execution
   for(t = 0; t < 18; t = t + 1) begin
      #0.5 clk = 1'b0;
      l0_wr = 1'b0;
      l0_rd = 1'b1;
      execute = 1'b1;
      ofifo_rd = 1'b1;
      A_pmem = A_pmem + 1;
      psum_scan_file = $fscanf(psum_file,"%128b", psum_check);
      if(psum_check != core_instance.psum_sram.D) begin
        $display("ERROR: psum mismatch at t = %d, kij = %d", t, kij);
        $display("Expected: %h", psum_check);
        $display("Recieved: %h", core_instance.psum_sram.D); 
      end
      #0.5 clk = 1'b1; 
    end

    #0.5 clk = 1'b0;
    l0_wr = 1'b0;
    l0_rd = 1'b0;
    execute = 1'b0;
    ofifo_rd = 1'b0;
    A_pmem = A_pmem + 1;
    WEN_pmem = 1; CEN_pmem = 1; 
    #0.5 clk = 1'b1; 

    // $finish();
  end  // end of kij loop

 
  ////////// Accumulation /////////
  acc_file = $fopen("acc_address_pruned.txt", "r");
  out_file = $fopen("out_pruned.txt", "r");  /// out.txt file stores the address sequence to read out from psum memory for accumulation
                                      /// This can be generated manually or in
                                      /// pytorch automatically

  // Following three lines are to remove the first three comment lines of the file
  // out_scan_file = $fscanf(out_file,"%s", answer); 
  // out_scan_file = $fscanf(out_file,"%s", answer); 
  // out_scan_file = $fscanf(out_file,"%s", answer); 

  error = 0;



  $display("############ Verification Start during accumulation #############"); 

  for (i=0; i<len_onij+1; i=i+1) begin 

    #0.5 clk = 1'b0; relu=0;
    #0.5 clk = 1'b1; 
    #0.5 clk = 1'b0; relu=0;
    #0.5 clk = 1'b1; 

    if (i>0) begin
     out_scan_file = $fscanf(out_file,"%128b", answer); // reading from out file to answer
       if (sfp_out == answer)
         $display("%2d-th output featuremap Data matched! :D", i); 
       else begin
         $display("%2d-th output featuremap Data ERROR!!", i); 
         $display("sfpout: %h", sfp_out);
         $display("answer: %h", answer);
         error = 1;
       end
    end
   

    #0.5 clk = 1'b0; reset = 1;
    #0.5 clk = 1'b1;  
    #0.5 clk = 1'b0; reset = 0; 
    #0.5 clk = 1'b1;  

    for (j=0; j<len_kij+1; j=j+1) begin 

      #0.5 clk = 1'b0;   
        if (j<len_kij) begin CEN_pmem = 0; WEN_pmem = 1; acc_scan_file = $fscanf(acc_file,"%11b", A_pmem); end
                       else  begin CEN_pmem = 1; WEN_pmem = 1; end

        if (j>0)  acc = 1;  
      #0.5 clk = 1'b1;   
    end

    #0.5 clk = 1'b0; acc = 0;
    #0.5 clk = 1'b1; 
    #0.5 clk = 1'b0; relu = 1;
    #0.5 clk = 1'b1; 
  end


  if (error == 0) begin
  	$display("############ No error detected ##############"); 
  	$display("########### Project Completed !! ############"); 

  end

  $fclose(acc_file);
  //////////////////////////////////

  for (t=0; t<10; t=t+1) begin  
    #0.5 clk = 1'b0;  
    #0.5 clk = 1'b1;  
  end

  #10 $finish;

end

always @ (posedge clk) begin
   inst_w_q   <= inst_w; 
   D_xmem_q   <= D_xmem;
   CEN_xmem_q <= CEN_xmem;
   WEN_xmem_q <= WEN_xmem;
   A_pmem_q   <= A_pmem;
   CEN_pmem_q <= CEN_pmem;
   WEN_pmem_q <= WEN_pmem;
   A_xmem_q   <= A_xmem;
   ofifo_rd_q <= ofifo_rd;
   acc_q      <= acc;
   relu_q     <= relu;
   ififo_rd_q <= ififo_rd;
   l0_rd_q    <= l0_rd;
   l0_wr_q    <= l0_wr ;
   execute_q  <= execute;
   load_q     <= load;
end


endmodule




