
`timescale 1 ns / 1 ps
module uart_rx_collect(
 input              i_clk      
,input              i_rst_n   
,input              i_uart_rxd
,output reg         o_valid 
,output reg	[31:0]  o_data     
);

 reg            r_uart_rxd
;reg            r_uart_rxd_dly1
;reg    [31:0]  r_uart_rxd_shift
;reg 	[4:0]   r_uart_rx_data_shift_cnt
;reg    [6:0]   r_clk_div_cnt
;

always @(posedge i_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1) begin
		r_uart_rxd      <= 1'b1;
		r_uart_rxd_dly1 <= 1'b1;
	end else begin
		r_uart_rxd      <= i_uart_rxd;
		r_uart_rxd_dly1 <= r_uart_rxd;
	end
end

always @(posedge i_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1) 
		r_clk_div_cnt <= 'd0;
	else if(r_clk_div_cnt == 'd15)
		r_clk_div_cnt <= 'd0;
	else
		r_clk_div_cnt <= r_clk_div_cnt + 'd1;
end

always @(posedge i_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1) 
		r_uart_rx_data_shift_cnt <= 5'b0;
	else if(r_clk_div_cnt == 'd15)
		r_uart_rx_data_shift_cnt <= r_uart_rx_data_shift_cnt + 5'b1;
	else ;
end

always @(posedge i_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1) 
		r_uart_rxd_shift <= 32'hffffffff;
	else if(r_clk_div_cnt == 'd15)
		r_uart_rxd_shift <= {r_uart_rxd_shift[30:0],r_uart_rxd_dly1};
	else ;
end

always @(posedge i_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1) begin
		o_valid <= 1'b0;
		o_data  <= 32'hffffffff;
	end else if((r_clk_div_cnt == 'd15) && (&r_uart_rx_data_shift_cnt == 1'b1)) begin
		o_valid <= 1'b1;
		o_data  <= r_uart_rxd_shift;
	end else begin
		o_valid <= 1'b0;
		o_data  <= 32'hffffffff;
	end
end



endmodule


