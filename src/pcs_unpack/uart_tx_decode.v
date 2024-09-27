
`timescale 1 ns / 1 ps
module uart_tx_decode(
 input 					i_clk             
,input 					i_rst_n  
,output reg				o_uart_txd 
,output 				o_uart_drive 
,input 		[31:0]		i_data     
,output reg				o_fifo_rd_en
); 

reg [31:0] 	r_data_shit              ;
reg [6:0] 	r_clk_div_cnt            ;
reg [4:0] 	rdata_shift_cnt          ;
reg			r_fifo_rd_en             ;
reg [17:0]  r_data_change_cnt        ;

assign o_uart_drive = ~(&r_data_change_cnt);

always @(posedge i_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1) 
		r_fifo_rd_en <= 1'b0;
	else
		r_fifo_rd_en <= o_fifo_rd_en;
end

always @(posedge i_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1) 
		r_data_change_cnt 	<= 'd0;
	else if(r_data_shit[31] != r_data_shit[30])
		r_data_change_cnt	<= 'd0;
	else if(&r_data_change_cnt)
		r_data_change_cnt 	<= r_data_change_cnt;
	else 
		r_data_change_cnt 	<= r_data_change_cnt + 'd1;
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
		rdata_shift_cnt <= 5'd0;
	else if(r_clk_div_cnt == 'd15)
		rdata_shift_cnt <= rdata_shift_cnt + 5'd1;
	else ;
end

always @(posedge i_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1)
		r_data_shit <= 32'hffffffff;
	else if(r_fifo_rd_en == 1'b1)
		r_data_shit <= i_data;
	else if(r_clk_div_cnt == 'd15)
		r_data_shit <= {r_data_shit[30:0],r_data_shit[0]};
	else ;
end

always @(posedge i_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1) 
		o_uart_txd <= 1'b1;
	else if(r_clk_div_cnt == 'd15)
		o_uart_txd <= r_data_shit[31];
	else ;
end

always @(posedge i_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1) 
		o_fifo_rd_en <= 1'b0;
	else if((r_clk_div_cnt == 'd15) && (&rdata_shift_cnt == 1'b1))
		o_fifo_rd_en <= 1'b1;
	else 
		o_fifo_rd_en <= 1'b0;
end



endmodule


