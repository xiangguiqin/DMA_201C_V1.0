// Generate global rst
`timescale 1ns/1ps
module BFM_RST(
 input				i_rst_n
,input				i_local_clk
,output				o_global_rst_n
);
reg    [15:0]    r_cnt = 0      ;
reg              r_global_rst_n ;

assign 	o_global_rst_n = r_global_rst_n;

always@(posedge i_local_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1)
		r_cnt <= 'd0;
	else if(r_cnt == 16'hffff)
		r_cnt <= r_cnt;
	else 
		r_cnt <= r_cnt + 1'b1;
end		

always@(posedge i_local_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1)
		r_global_rst_n <= 'd0;
	else if(r_cnt <= 16'h8000)
		r_global_rst_n <= 1'b1;
	else if(r_cnt == 16'hffff)
		r_global_rst_n <= 1'b1;
	else 
		r_global_rst_n <= 1'b0;
end	




endmodule
