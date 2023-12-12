// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission
`timescale 1ns/1ps
module mac_tile (clk, out_s, in_w, out_e, in_n, inst_w, inst_e, reset);

parameter bw = 4;
parameter psum_bw = 16;

output [psum_bw-1:0] out_s;
input  [bw-1:0] in_w; // inst[1]:execute, inst[0]: kernel loading
output [bw-1:0] out_e;
input  [1:0] inst_w;
output [1:0] inst_e;
input  [psum_bw-1:0] in_n;
input  clk;
input  reset;

reg [1:0]inst_q;
reg [bw-1:0] a_q,b_q;
reg [bw-1:0] w_1,w_2;
reg [psum_bw-1:0] c_q;
reg load_ready_q;
reg w_cnt;
reg Int_acc_cnt;
reg [psum_bw-1:0] temp_psum;

wire [psum_bw-1:0] mac_out;

// FFs
always @(posedge clk) begin
    if(reset)begin
        // default values
        a_q <= 'b0;
        b_q <= 'b0;
        c_q <= 'b0;
        inst_q = 'b0;
        load_ready_q <= 'b1;
        w_1 <= 'b0;
        w_2 <= 'b0;
        w_cnt <= 'b0;
        Int_acc_cnt <= 'b0;
    end
    else begin
        inst_q[1] <= inst_w[1];
        
        if(inst_w[0] | inst_w[1]) begin
            a_q <= in_w;
        end

        if(inst_w[0] & load_ready_q & !w_cnt) begin
            w_1 <= in_w;
            w_cnt <= 'b1;
	    end

        if(inst_w[0] & load_ready_q & w_cnt) begin
            w_2 <= in_w;
            w_cnt <= 'b0;
            load_ready_q <= 'b0;
        end

        if (inst_w[1] & !Int_acc_cnt) begin
            b_q <= w_1;
        end

        if (inst_w[1] & Int_acc_cnt) begin
            b_q <= w_2;
            Int_acc_cnt <= 'b0;
        end

        if(!load_ready_q) begin
            inst_q[0] <= inst_w[0];
        end
       
	if (!Int_acc_cnt) begin
	    c_q <= in_n;
	    temp_psum <= mac_out;
        end
	else begin
	    c_q <= temp_psum;
	end
    end
end


mac #(.bw(bw), .psum_bw(psum_bw)) mac_instance (
        .a(a_q),
        .b(b_q),
        .c(c_q),
        .out(mac_out)
);

// Connect 
assign inst_e = inst_q;
assign out_e = a_q;
assign out_s = (Int_acc_cnt) ? mac_out : 'b0;

endmodule
