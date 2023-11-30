// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module sfp (out, in, thres, acc, relu, clk, reset);

parameter bw = 8;
parameter psum_bw = 16;

input clk;
input acc;
input relu;
input reset;

input signed [psum_bw-1:0] in;
input signed [psum_bw-1:0] thres;

output  signed [psum_bw-1:0] out;

reg  signed [psum_bw-1:0] psum_q;

assign out = psum_q;

always @(posedge clk) begin
    if(reset) begin
        psum_q <= 0;
    end
    else begin
        if(acc) begin
            psum_q <= psum_q + in;
        end
        else if(relu) begin
            if(psum_q < thres) begin
                psum_q <= 0;
            end
        end
        
    end
end

endmodule
