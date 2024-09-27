`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/02 11:13:02
// Design Name: 
// Module Name: led
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module led #(
	parameter p_local_clk_freq = 'd74_250_000
)(
 input              i_rst_n
,input              i_local_clk

,output reg         o_run_led
);




reg [31:0] r_cnt;

always @(posedge i_local_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1)
		r_cnt <= 'd0;
	else if(r_cnt == p_local_clk_freq-1)
		r_cnt <= 'd0;
	else
		r_cnt <= r_cnt+'d1;
end

always @(posedge i_local_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1)
		o_run_led <= 'd0;
	else if(r_cnt <= p_local_clk_freq/2-1)
		o_run_led <= 'd1;
	else
		o_run_led <= 'd0;
end




endmodule
