`timescale 1ns/1ps
module huffman_w (clk, reset, in, valid_in, out, valid);

parameter num_words = 8; //determined by the 8 by 8 MAC array
parameter bw = 4; //number of bits per word, which is fixed

input clk;
input reset; //assumes posedge reset
input in;
input valid_in; //allows for pausing, else just set to true
output wire [bw*num_words-1: 0] out;
output valid;
// Define states, leaf node states are encoded with their preencoded data

localparam S_ERROR = 5'd31;
localparam S_ROOT =  5'd25;
localparam S0 =  5'd27;
localparam S00 =  5'd29;
localparam S000 =  5'd22;
localparam S0000 =  5'd16;
localparam S00000 =  5'd5; //leaf
localparam S00001 =  5'd12; //leaf
localparam S0001 =  5'd4; //leaf
localparam S001 =  5'd18; 
localparam S0010 =  5'd13; //leaf
localparam S0011 =  5'd21; 
localparam S00110 =  5'd30;
localparam S00111 =  5'd14; //leaf
localparam S001101 =  5'd23;
localparam S0011010 =  5'd9; //leaf
localparam S001100 =  5'd6; //leaf
localparam S0011011 =  5'd17;
localparam S00110110 =  5'd10; //leaf
localparam S00110111 =  5'd19; 
localparam S001101110 =  5'd20; 
localparam S001101111 =  5'd11; //leaf
localparam S0011011100 =  5'd8; //leaf
localparam S0011011101 =  5'd15; //leaf
localparam S01 =  5'd24; 
localparam S010 =  5'd1; //leaf
localparam S011 =  5'd26; 
localparam S0110 =  5'd2; //leaf
localparam S0111 =  5'd28;
localparam S01110 =  5'd3; //leaf
localparam S01111 =  5'd7; //leaf
localparam S1 =  5'd0; //leaf


// Current state register
reg [4:0] state; //5 bits to represent 31 states
reg [4:0] next_state; //5 bits to represent 31 states, should act as a wire

reg [bw*num_words-1: 0] buffered_outputs; //store words until full then send valid
reg valid_reg; //so we can delay valid single by 1 cycle
reg isLeaf; //if next state is leaf, should act as wire
reg [2:0] buffer_ptr;  //curr slot we write to in buffer

assign valid = valid_reg;
assign out = buffered_outputs;

// Always FF
always @(posedge clk) begin
    if (reset) begin
        state <= S_ROOT;
        buffered_outputs <= 32'b00000000000000000000000000000000;
        buffer_ptr <= 3'b111;
    end
    else begin
        state <= next_state;
        valid_reg <= (isLeaf & (buffer_ptr == 3'b000)); //if writing to last element
        if (isLeaf) begin
            buffered_outputs[(buffer_ptr + 1)*bw - 1 -: bw] <= next_state; 
            if (buffer_ptr == 3'b000) begin
                buffer_ptr <= 3'b111;
            end else
                buffer_ptr <= buffer_ptr - 1;
        end
        
    end
end

// Comb logic
always @(*) begin
    if (reset) begin
        next_state = S_ROOT;
        isLeaf = 1'b0; 
    end
    else if (!valid_in) begin
        next_state = state;
        isLeaf = 1'b0; 
    end
    else 
        case (state)
            S_ROOT:
            begin
                if (in == 1'b1) begin
                    isLeaf = 1'b1;
                    next_state = S1;
                end else begin
                    isLeaf = 1'b0;
                    next_state = S0;
                end
            end
            S0:
            begin
                isLeaf = 1'b0;
                if (in == 1'b1) 
                    next_state = S01;
                else
                    next_state = S00;                
            end
            S00:
            begin
                isLeaf = 1'b0;
                if (in == 1'b1) 
                    next_state = S001;
                else
                    next_state = S000;  
            end
            S000:
            begin
                if (in == 1'b1) begin
                    isLeaf = 1'b1;
                    next_state = S0001;
                end else begin
                    isLeaf = 1'b0;
                    next_state = S0000;  
                end
            end
            S0000:
            begin
                isLeaf = 1'b1;
                if (in == 1'b1)
                    next_state = S00001;
                else
                    next_state = S00000;  
            end
            S00000: //leaf
            begin
                if (in == 1'b1) begin
                    next_state = S1;
                    isLeaf = 1'b1;
                end else begin
                    next_state = S0;  
                    isLeaf = 1'b0;
                end
            end
            S00001: //leaf
            begin
                if (in == 1'b1) begin
                    next_state = S1;
                    isLeaf = 1'b1;
                end else begin
                    next_state = S0;  
                    isLeaf = 1'b0;
                end
            end
            S0001: //leaf
            begin
                if (in == 1'b1) begin
                    next_state = S1;
                    isLeaf = 1'b1;
                end else begin
                    next_state = S0;  
                    isLeaf = 1'b0;
                end
            end
            S001:
            begin
                if (in == 1'b1) begin
                    isLeaf = 1'b0;
                    next_state = S0011;
                end else begin
                    isLeaf = 1'b1;
                    next_state = S0010; 
                end
            end
            S0010: //leaf
            begin
                if (in == 1'b1) begin
                    next_state = S1;
                    isLeaf = 1'b1;
                end else begin
                    next_state = S0;  
                    isLeaf = 1'b0;
                end
            end
            S0011:
            begin
                if (in == 1'b1) begin
                    isLeaf = 1'b1;
                    next_state = S00111;
                end else begin
                    isLeaf = 1'b0;
                    next_state = S00110;
                end  
            end
            S00110:
            begin
                if (in == 1'b1) begin
                    isLeaf = 1'b0;
                    next_state = S001101;
                end else begin
                    isLeaf = 1'b1;
                    next_state = S001100;
                end  
            end
            S00111: //leaf
            begin
               if (in == 1'b1) begin
                    next_state = S1;
                    isLeaf = 1'b1;
                end else begin
                    next_state = S0;  
                    isLeaf = 1'b0;
                end  
            end
            S001101:
            begin
                if (in == 1'b1) begin
                    isLeaf = 1'b0;
                    next_state = S0011011;
                end else begin
                    isLeaf = 1'b1;
                    next_state = S0011010;  
                end
            end
            S0011010: //leaf
            begin
                if (in == 1'b1) begin
                    next_state = S1;
                    isLeaf = 1'b1;
                end else begin
                    next_state = S0;  
                    isLeaf = 1'b0;
                end
            end
            S001100: //leaf
            begin
               if (in == 1'b1) begin
                    next_state = S1;
                    isLeaf = 1'b1;
                end else begin
                    next_state = S0;  
                    isLeaf = 1'b0;
                end
            end
            S0011011:
            begin
                if (in == 1'b1) begin
                    isLeaf = 1'b0;
                    next_state = S00110111;
                end else begin
                    isLeaf = 1'b1;
                    next_state = S00110110;  
                end
            end
            S00110110: //leaf
            begin
                if (in == 1'b1) begin
                    next_state = S1;
                    isLeaf = 1'b1;
                end else begin
                    next_state = S0;  
                    isLeaf = 1'b0;
                end
            end
            S00110111:
            begin
                if (in == 1'b1) begin 
                    isLeaf = 1'b1;
                    next_state = S001101111;
                end else begin
                    isLeaf = 1'b0;
                    next_state = S001101110;
                end
            end
            S001101110:
            begin
                if (in == 1'b1) begin
                    next_state = S0011011101;
                    isLeaf = 1'b1;
                end else begin
                    next_state = S0011011100;
                    isLeaf = 1'b1;
                end
            end 
            S001101111: //leaf
            begin
                if (in == 1'b1) begin
                    next_state = S1;
                    isLeaf = 1'b1;
                end else begin
                    next_state = S0;  
                    isLeaf = 1'b0;
                end
            end
            S0011011100: //leaf 
            begin
                if (in == 1'b1) begin
                    next_state = S1;
                    isLeaf = 1'b1;
                end else begin
                    next_state = S0;  
                    isLeaf = 1'b0;
                end
            end
            S0011011101: //leaf
            begin
                if (in == 1'b1) begin
                    next_state = S1;
                    isLeaf = 1'b1;
                end else begin
                    next_state = S0;  
                    isLeaf = 1'b0;
                end
            end
            S01:
            begin
                if (in == 1'b1) begin
                    isLeaf = 1'b0;
                    next_state = S011;
                end else begin
                    isLeaf = 1'b1;
                    next_state = S010; 
                end
            end
            S010: //leaf
            begin
               if (in == 1'b1) begin
                    next_state = S1;
                    isLeaf = 1'b1;
                end else begin
                    next_state = S0;  
                    isLeaf = 1'b0;
                end
            end
            S011:
            begin
                if (in == 1'b1) begin 
                    isLeaf = 1'b0;
                    next_state = S0111;    
                end else begin
                    isLeaf = 1'b1;
                    next_state = S0110;
                end  
            end
            S0110: //leaf
            begin
                if (in == 1'b1) begin
                    next_state = S1;
                    isLeaf = 1'b1;
                end else begin
                    next_state = S0;  
                    isLeaf = 1'b0;
                end
            end
            S0111:
            begin
                isLeaf = 1'b1;
                if (in == 1'b1) 
                    next_state = S01111;
                else
                    next_state = S01110;  
            end
            S01110: //leaf
            begin
                if (in == 1'b1) begin
                    next_state = S1;
                    isLeaf = 1'b1;
                end else begin
                    next_state = S0;  
                    isLeaf = 1'b0;
                end
            end
            S01111: //leaf
            begin
               if (in == 1'b1) begin
                    next_state = S1;
                    isLeaf = 1'b1;
                end else begin
                    next_state = S0;  
                    isLeaf = 1'b0;
                end
            end
            S1: //leaf
            begin
               if (in == 1'b1) begin
                    next_state = S1;
                    isLeaf = 1'b1;
                end else begin
                    next_state = S0;  
                    isLeaf = 1'b0;
                end
            end
            default: begin
                isLeaf = 1'b0;
                next_state = S_ERROR; //illegal transistion not in tree 
            end
        endcase
end
endmodule
