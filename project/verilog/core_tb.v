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


reg clk1 = 0;
reg reset1 = 1;

wire [33:0] inst_q1; 

reg [1:0]  inst_w_q1 = 0; 
reg [bw*row-1:0] D_xmem_q1 = 0;
reg CEN_xmem1 = 1;
reg WEN_xmem1 = 1;
reg [10:0] A_xmem1 = 0;
reg CEN_xmem_q1 = 1;
reg WEN_xmem_q1 = 1;
reg [10:0] A_xmem_q1 = 0;
reg CEN_pmem1 = 1;
reg WEN_pmem1 = 1;
reg [10:0] A_pmem1 = 0;
reg CEN_pmem_q1 = 1;
reg WEN_pmem_q1 = 1;
reg [10:0] A_pmem_q1 = 0;
reg ofifo_rd_q1 = 0;
reg relu_q1 = 0;
reg ififo_rd_q1 = 0;
reg l0_rd_q1 = 0;
reg l0_wr_q1 = 0;
reg execute_q1 = 0;
reg load_q1 = 0;
reg acc_q1 = 0;
reg acc1 = 0;

reg [1:0]  inst_w1; 
reg [bw*row-1:0] D_xmem1;
reg [psum_bw*col-1:0] answer1;


reg ofifo_rd1;
reg relu1;
reg ififo_rd1;
reg l0_rd1;
reg l0_wr1;
reg execute1;
reg load1;
reg [8*30:1] stringvar1;
reg [8*30:1] w_file_name1;
wire [col*psum_bw-1:0] sfp_out1;


integer x_file1, x_scan_file1 ; // file_handler
integer w_file1, w_scan_file1 ; // file_handler
integer acc_file1, acc_scan_file1 ; // file_handler
integer out_file1, out_scan_file1 ; // file_handler
integer captured_data1; 
integer t1, i1, j1, k1, kij1;
integer error1;

integer psum_file1, psum_scan_file1;
reg [psum_bw*col-1:0] psum_check1;
integer psum_chk_kij1 = 8;
reg [8*30:1] psum_file_name1;

assign inst_q1[33] = acc_q1;
assign inst_q1[32] = CEN_pmem_q1;
assign inst_q1[31] = WEN_pmem_q1;
assign inst_q1[30:20] = A_pmem_q1;
assign inst_q1[19]   = CEN_xmem_q1;
assign inst_q1[18]   = WEN_xmem_q1;
assign inst_q1[17:7] = A_xmem_q1;
assign inst_q1[6]   = ofifo_rd_q1;
assign inst_q1[5]   = relu_q1;
assign inst_q1[4]   = ififo_rd_q1;
assign inst_q1[3]   = l0_rd_q1;
assign inst_q1[2]   = l0_wr_q1;
assign inst_q1[1]   = execute_q1; 
assign inst_q1[0]   = load_q1; 

  chip #(.bw(bw), .col(col), .row(row)) chip_instance (
	  .clk1(clk), 
	  .inst1(inst_q),
    .mem1(D_xmem_q), 
    .sfp_out1(sfp_out), 
	  .reset1(reset),

    .clk2(clk1), 
	  .inst2(inst_q1),
    .mem2(D_xmem_q1), 
    .sfp_out2(sfp_out1), 
	  .reset2(reset1)
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


  $dumpfile("core_tb.vcd");
  $dumpvars(0,core_tb);

  x_file = $fopen("activation_tile0.txt", "r");
  // Following three lines are to remove the first three comment lines of the file
  x_scan_file = $fscanf(x_file,"%s", captured_data);
  x_scan_file = $fscanf(x_file,"%s", captured_data);
  x_scan_file = $fscanf(x_file,"%s", captured_data);

  //////// Reset /////////
  #0.5 clk = 1'b0;   reset = 1;
  #0.5 clk = 1'b1; 

  for (i=0; i<10 ; i=i+1) begin
    #0.5 clk = 1'b0;
    #0.5 clk = 1'b1;  
  end

  #0.5 clk = 1'b0;   reset = 0;
  #0.5 clk = 1'b1; 

  #0.5 clk = 1'b0;   
  #0.5 clk = 1'b1;   
  /////////////////////////

  /////// Activation data writing to memory ///////
  for (t=0; t<len_nij; t=t+1) begin  
    #0.5 clk = 1'b0;  x_scan_file = $fscanf(x_file,"%32b", D_xmem); WEN_xmem = 0; CEN_xmem = 0; if (t>0) A_xmem = A_xmem + 1;
    #0.5 clk = 1'b1;   
  end

  #0.5 clk = 1'b0;  WEN_xmem = 1;  CEN_xmem = 1; A_xmem = 0;
  #0.5 clk = 1'b1; 

  $fclose(x_file);
  /////////////////////////////////////////////////

   A_pmem = 11'b00000000000;
  for (kij=0; kij<9; kij=kij+1) begin  // kij loop

    case(kij)
     0: w_file_name = "weight_itile0_otile0_kij0.txt";
     1: w_file_name = "weight_itile0_otile0_kij1.txt";
     2: w_file_name = "weight_itile0_otile0_kij2.txt";
     3: w_file_name = "weight_itile0_otile0_kij3.txt";
     4: w_file_name = "weight_itile0_otile0_kij4.txt";
     5: w_file_name = "weight_itile0_otile0_kij5.txt";
     6: w_file_name = "weight_itile0_otile0_kij6.txt";
     7: w_file_name = "weight_itile0_otile0_kij7.txt";
     8: w_file_name = "weight_itile0_otile0_kij8.txt";
    endcase
    

    w_file = $fopen(w_file_name, "r");
    // Following three lines are to remove the first three comment lines of the file
    w_scan_file = $fscanf(w_file,"%s", captured_data);
    w_scan_file = $fscanf(w_file,"%s", captured_data);
    w_scan_file = $fscanf(w_file,"%s", captured_data);

    #0.5 clk = 1'b0;   reset = 1;
    #0.5 clk = 1'b1; 

    for (i=0; i<10 ; i=i+1) begin
      #0.5 clk = 1'b0;
      #0.5 clk = 1'b1;  
    end

    #0.5 clk = 1'b0;   reset = 0;
    #0.5 clk = 1'b1; 

    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   





    /////// Kernel data writing to memory ///////

    A_xmem = 11'b10000000000;

    for (t=0; t<col; t=t+1) begin  
      #0.5 clk = 1'b0;  w_scan_file = $fscanf(w_file,"%32b", D_xmem); WEN_xmem = 0; CEN_xmem = 0; if (t>0) A_xmem = A_xmem + 1; 
      #0.5 clk = 1'b1;  
    end

    #0.5 clk = 1'b0;  WEN_xmem = 1;  CEN_xmem = 1; A_xmem = 0;
    #0.5 clk = 1'b1; 
    /////////////////////////////////////
    



    /////// Kernel data writing to L0 ///////
    A_xmem = 11'b10000000000;
    
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
      0: psum_file_name = "psum_kij0.txt";
      1: psum_file_name = "psum_kij1.txt";
      2: psum_file_name = "psum_kij2.txt";
      3: psum_file_name = "psum_kij3.txt";
      4: psum_file_name = "psum_kij4.txt";
      5: psum_file_name = "psum_kij5.txt";
      6: psum_file_name = "psum_kij6.txt";
      7: psum_file_name = "psum_kij7.txt";
      8: psum_file_name = "psum_kij8.txt";
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
       if(psum_check != chip_instance.core_instance0.psum_sram.D) begin
          $display("ERROR: psum mismatch at t = %d, kij = %d", t, kij);
          $display("Expected: %h", psum_check);
          $display("Recieved: %h", chip_instance.core_instance0.psum_sram.D); 
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
      if(psum_check != chip_instance.core_instance0.psum_sram.D) begin
        $display("ERROR: psum mismatch at t = %d, kij = %d", t, kij);
        $display("Expected: %h", psum_check);
        $display("Recieved: %h", chip_instance.core_instance0.psum_sram.D); 
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
  acc_file = $fopen("acc_address.txt", "r");
  out_file = $fopen("out.txt", "r");  /// out.txt file stores the address sequence to read out from psum memory for accumulation
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
         $display("Core 0: %2d-th output featuremap Data matched! :D", i); 
       else begin
         $display("Core 0: %2d-th output featuremap Data ERROR!!", i); 
         $display("Core 0: sfpout: %h", sfp_out);
         $display("Core 0: answer: %h", answer);
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
  	$display("############ Core 0: No error detected ##############"); 
  	$display("########### Core 0: Project Completed !! ############"); 

  end

  $fclose(acc_file);
  //////////////////////////////////

  for (t=0; t<10; t=t+1) begin  
    #0.5 clk = 1'b0;  
    #0.5 clk = 1'b1;  
  end

  #10 $finish;

end


// Second core controller
initial begin 

  inst_w1   = 0; 
  D_xmem1   = 0;
  CEN_xmem1 = 1;
  WEN_xmem1 = 1;
  A_xmem1   = 0;
  ofifo_rd1 = 0;
  relu1 = 0;
  ififo_rd1 = 0;
  l0_rd1    = 0;
  l0_wr1    = 0;
  execute1  = 0;
  load1     = 0;


  // $dumpfile("core_tb.vcd");
  // $dumpvars(0,core_tb);

  x_file1 = $fopen("activation_tile0.txt", "r");
  // Following three lines are to remove the first three comment lines of the file
  x_scan_file1 = $fscanf(x_file1,"%s", captured_data1);
  x_scan_file1 = $fscanf(x_file1,"%s", captured_data1);
  x_scan_file1 = $fscanf(x_file1,"%s", captured_data1);

  //////// Reset /////////
  #0.5 clk1 = 1'b0;   reset1 = 1;
  #0.5 clk1 = 1'b1; 

  for (i1=0; i1<10 ; i1=i1+1) begin
    #0.5 clk1 = 1'b0;
    #0.5 clk1 = 1'b1;  
  end

  #0.5 clk1 = 1'b0;   reset1 = 0;
  #0.5 clk1 = 1'b1; 

  #0.5 clk1 = 1'b0;   
  #0.5 clk1 = 1'b1;   
  /////////////////////////

  /////// Activation data writing to memory ///////
  for (t1=0; t1<len_nij; t1=t1+1) begin  
    #0.5 clk1 = 1'b0;  x_scan_file1 = $fscanf(x_file1,"%32b", D_xmem1); WEN_xmem1 = 0; CEN_xmem1 = 0; if (t1>0) A_xmem1 = A_xmem1+ 1;
    #0.5 clk1 = 1'b1;   
  end

  #0.5 clk1 = 1'b0;  WEN_xmem1 = 1;  CEN_xmem1 = 1; A_xmem1 = 0;
  #0.5 clk1 = 1'b1; 

  $fclose(x_file1);
  /////////////////////////////////////////////////

   A_pmem1 = 11'b00000000000;
  for (kij1=0; kij1<9; kij1=kij1+1) begin  // kij loop

    case(kij1)
     0: w_file_name1 = "weight_itile0_otile0_kij0.txt";
     1: w_file_name1 = "weight_itile0_otile0_kij1.txt";
     2: w_file_name1 = "weight_itile0_otile0_kij2.txt";
     3: w_file_name1 = "weight_itile0_otile0_kij3.txt";
     4: w_file_name1 = "weight_itile0_otile0_kij4.txt";
     5: w_file_name1 = "weight_itile0_otile0_kij5.txt";
     6: w_file_name1 = "weight_itile0_otile0_kij6.txt";
     7: w_file_name1 = "weight_itile0_otile0_kij7.txt";
     8: w_file_name1 = "weight_itile0_otile0_kij8.txt";
    endcase
    

    w_file1 = $fopen(w_file_name1, "r");
    // Following three lines are to remove the first three comment lines of the file
    w_scan_file1 = $fscanf(w_file1,"%s", captured_data1);
    w_scan_file1 = $fscanf(w_file1,"%s", captured_data1);
    w_scan_file1 = $fscanf(w_file1,"%s", captured_data1);

    #0.5 clk1 = 1'b0;   reset1 = 1;
    #0.5 clk1 = 1'b1; 

    for (i1=0; i1<10 ; i1=i1+1) begin
      #0.5 clk1 = 1'b0;
      #0.5 clk1 = 1'b1;  
    end

    #0.5 clk1 = 1'b0;   reset1 = 0;
    #0.5 clk1 = 1'b1; 

    #0.5 clk1 = 1'b0;   
    #0.5 clk1 = 1'b1;   





    /////// Kernel data writing to memory ///////

    A_xmem1 = 11'b10000000000;

    for (t1=0; t1<col; t1=t1+1) begin  
      #0.5 clk1 = 1'b0;  w_scan_file1 = $fscanf(w_file1,"%32b", D_xmem1); WEN_xmem1 = 0; CEN_xmem1 = 0; if (t1>0) A_xmem1 = A_xmem1 + 1; 
      #0.5 clk1 = 1'b1;  
    end

    #0.5 clk1 = 1'b0;  WEN_xmem1 = 1;  CEN_xmem1 = 1; A_xmem1 = 0;
    #0.5 clk1 = 1'b1; 
    /////////////////////////////////////
    



    /////// Kernel data writing to L0 ///////
    A_xmem1 = 11'b10000000000;
    
    for (t1=0; t1<col; t1=t1+1) begin  
      #0.5 clk1 = 1'b0;   WEN_xmem1 = 1; CEN_xmem1 = 0;
      if (t1>0) begin
        A_xmem1 = A_xmem1 + 1;
        l0_wr1 = 1'b1;
        l0_rd1 = 1'b1;
        load1 = 1'b1;
      end
      #0.5 clk1 = 1'b1;  
    end
    
    // Finish writing data to L0 needs 8 more cycles
    for(t1 = 0; t1 < 8; t1 = t1 + 1) begin
      #0.5 clk1 = 1'b0; 
      if(t1>0) begin
        l0_wr1 = 1'b0;
      end
      #0.5 clk1 = 1'b1; 
    end

    /////////////////////////////////////


    
    ////// provide some intermission to clear up the kernel loading and clean up l0///
    #0.5 clk1 = 1'b0;  load1 = 0; l0_rd1 =  1'b1;
    #0.5 clk1 = 1'b1;  
    

    for (i1=0; i1 < 10 ; i1=i1+1) begin
      #0.5 clk1 = 1'b0;
      #0.5 clk1 = 1'b1;  
    end

    // turn off l0 reading
    l0_rd1 = 1'b0;
    for (i1=0; i1 < 7 ; i1=i1+1) begin
      #0.5 clk1 = 1'b0;
      #0.5 clk1 = 1'b1;  
    end
    /////////////////////////////////////

    
    
    /////// Activation data writing to L0 and all other steps ///////
    //A_xmem = 11'd11;
    A_xmem1 = 11'd00000000000;

    case(kij1)
      0: psum_file_name1 = "psum_kij0.txt";
      1: psum_file_name1 = "psum_kij1.txt";
      2: psum_file_name1 = "psum_kij2.txt";
      3: psum_file_name1 = "psum_kij3.txt";
      4: psum_file_name1 = "psum_kij4.txt";
      5: psum_file_name1 = "psum_kij5.txt";
      6: psum_file_name1 = "psum_kij6.txt";
      7: psum_file_name1 = "psum_kij7.txt";
      8: psum_file_name1 = "psum_kij8.txt";
    endcase
    psum_file1 = $fopen(psum_file_name1, "r");
    psum_scan_file1 = $fscanf(psum_file1,"%s", captured_data1);
    psum_scan_file1 = $fscanf(psum_file1,"%s", captured_data1);
    psum_scan_file1 = $fscanf(psum_file1,"%s", captured_data1);


    // Write to fifo and execute
    for(t1 = 0; t1 < len_nij; t1 = t1 + 1) begin
      #0.5 clk1 = 1'b0; WEN_xmem1 = 1; CEN_xmem1 = 0;  WEN_pmem1 = 0; CEN_pmem1 = 0;
      if(t1 < len_nij) begin
        l0_wr1 = 1'b1;
        A_xmem1 = A_xmem1 + 1; 
      end
      else begin
        l0_wr1 = 1'b0;
      end
      if(t1 > 0) begin
        l0_rd1 = 1'b1;
        execute1 = 1'b1;
      end
      if(t1 > 16) begin
        ofifo_rd1 = 1'b1;
      end

      if(t1 > 18) begin
      psum_scan_file1 = $fscanf(psum_file1,"%128b", psum_check1);
       if(psum_check1 != chip_instance.core_instance1.psum_sram.D) begin
          $display("ERROR: psum mismatch at t = %d, kij = %d", t1, kij1);
          $display("Expected: %h", psum_check1);
          $display("Recieved: %h", chip_instance.core_instance1.psum_sram.D); 
        end
      end

      if(t1 > 18) begin
        A_pmem1 = A_pmem1 + 1;
      end

      #0.5 clk1 = 1'b1; 
    end
    
    // Finish execution
   for(t1 = 0; t1 < 18; t1 = t1 + 1) begin
      #0.5 clk1 = 1'b0;
      l0_wr1 = 1'b0;
      l0_rd1 = 1'b1;
      execute1 = 1'b1;
      ofifo_rd1 = 1'b1;
      A_pmem1 = A_pmem1 + 1;
      psum_scan_file1 = $fscanf(psum_file1,"%128b", psum_check1);
      if(psum_check1 != chip_instance.core_instance1.psum_sram.D) begin
        $display("ERROR: psum mismatch at t = %d, kij = %d", t1, kij1);
        $display("Expected: %h", psum_check1);
        $display("Recieved: %h", chip_instance.core_instance1.psum_sram.D); 
      end
      #0.5 clk1 = 1'b1; 
    end

    #0.5 clk1 = 1'b0;
    l0_wr1 = 1'b0;
    l0_rd1 = 1'b0;
    execute1 = 1'b0;
    ofifo_rd1 = 1'b0;
    A_pmem1 = A_pmem1 + 1;
    WEN_pmem1 = 1; CEN_pmem1= 1; 
    #0.5 clk1 = 1'b1; 

    // $finish();
  end  // end of kij loop

 
  ////////// Accumulation /////////
  acc_file1 = $fopen("acc_address.txt", "r");
  out_file1 = $fopen("out.txt", "r");  /// out.txt file stores the address sequence to read out from psum memory for accumulation
                                      /// This can be generated manually or in
                                      /// pytorch automatically

  // Following three lines are to remove the first three comment lines of the file
  // out_scan_file = $fscanf(out_file,"%s", answer); 
  // out_scan_file = $fscanf(out_file,"%s", answer); 
  // out_scan_file = $fscanf(out_file,"%s", answer); 

  error1 = 0;



  $display("############ Verification Start during accumulation #############"); 

  for (i1=0; i1<len_onij+1; i1=i1+1) begin 

    #0.5 clk1 = 1'b0; relu1=0;
    #0.5 clk1 = 1'b1; 
    #0.5 clk1 = 1'b0; relu1=0;
    #0.5 clk1 = 1'b1; 

    if (i1>0) begin
     out_scan_file1 = $fscanf(out_file1,"%128b", answer1); // reading from out file to answer
       if (sfp_out1 == answer1)
         $display("Core 1: %2d-th output featuremap Data matched! :D", i1); 
       else begin
         $display("Core 1: %2d-th output featuremap Data ERROR!!", i1); 
         $display("Core 1: sfpout: %h", sfp_out1);
         $display("Core 1: answer: %h", answer1);
         error = 1;
       end
    end
   

    #0.5 clk1 = 1'b0; reset1 = 1;
    #0.5 clk1 = 1'b1;  
    #0.5 clk1 = 1'b0; reset1 = 0; 
    #0.5 clk1 = 1'b1;  

    for (j1=0; j1<len_kij+1; j1=j1+1) begin 

      #0.5 clk1 = 1'b0;   
        if (j1<len_kij) begin CEN_pmem1 = 0; WEN_pmem1 = 1; acc_scan_file1 = $fscanf(acc_file1,"%11b", A_pmem1); end
                       else  begin CEN_pmem1 = 1; WEN_pmem1 = 1; end

        if (j1>0)  acc1 = 1;  
      #0.5 clk1 = 1'b1;   
    end

    #0.5 clk1 = 1'b0; acc1 = 0;
    #0.5 clk1 = 1'b1; 
    #0.5 clk1 = 1'b0; relu1 = 1;
    #0.5 clk1 = 1'b1; 
  end


  if (error1 == 0) begin
  	$display("############ Core 1: No error detected ##############"); 
  	$display("########### Core 1: Project Completed !! ############"); 

  end

  $fclose(acc_file1);
  //////////////////////////////////

  for (t1=0; t1<10; t1=t1+1) begin  
    #0.5 clk1 = 1'b0;  
    #0.5 clk1 = 1'b1;  
  end

  // #10 $finish;

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

always @ (posedge clk1) begin
   inst_w_q1   <= inst_w1; 
   D_xmem_q1   <= D_xmem1;
   CEN_xmem_q1 <= CEN_xmem1;
   WEN_xmem_q1 <= WEN_xmem1;
   A_pmem_q1   <= A_pmem1;
   CEN_pmem_q1 <= CEN_pmem1;
   WEN_pmem_q1 <= WEN_pmem1;
   A_xmem_q1   <= A_xmem1;
   ofifo_rd_q1 <= ofifo_rd1;
   acc_q1      <= acc1;
   relu_q1     <= relu1;
   ififo_rd_q1 <= ififo_rd1;
   l0_rd_q1    <= l0_rd1;
   l0_wr_q1    <= l0_wr1;
   execute_q1  <= execute1;
   load_q1     <= load1;
end

endmodule




