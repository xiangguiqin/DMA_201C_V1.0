
`timescale 1 ns / 1 ps
module iis_audio_CS4334_handle(
 input 				i_clk             
,input 				i_rst_n  
,input				i_i2s_sclk
,input  			i_i2s_rlclk
,output 	    	o_i2s_data
,output	reg			o_fifo_rd_en
,input 		[63:0]  i_data
); 

reg           r_i2s_rlclk         ;
reg           r_i2s_rlclk_pos     ;
reg           r_i2s_rlclk_pos_dly1;
wire          w_i2s_rlclk_pos     ;
reg    [63:0] r_i2s_shift_data    ;

reg           r_i2s_sclk          ;
reg           r_i2s_sclk_pos      ;

assign w_i2s_rlclk_pos = (i_i2s_rlclk == 1'b1 && r_i2s_rlclk == 1'b0);
assign o_i2s_data      = r_i2s_shift_data[63];

always @(posedge i_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1) begin
		r_i2s_rlclk          <= 1'b0;
		r_i2s_sclk           <= 1'b0;
		r_i2s_rlclk_pos      <= 1'b0;
		r_i2s_sclk_pos       <= 1'b0;
		r_i2s_rlclk_pos_dly1 <= 1'b0;
	end else begin
		r_i2s_rlclk          <= i_i2s_rlclk;
		r_i2s_sclk           <= i_i2s_sclk;
		r_i2s_sclk_pos       <= (r_i2s_sclk == 1) && (i_i2s_sclk == 0);
		r_i2s_rlclk_pos      <= w_i2s_rlclk_pos;
		r_i2s_rlclk_pos_dly1 <= r_i2s_rlclk_pos;
	end
end

always @(posedge i_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1)
		o_fifo_rd_en <= 1'b0;
	else if(w_i2s_rlclk_pos == 1'b1) 
		o_fifo_rd_en <= 1'b1;
	else 
		o_fifo_rd_en <= 1'b0;
end

always @(posedge i_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1)
		r_i2s_shift_data <= 64'd0;
	else if(r_i2s_rlclk_pos_dly1 == 1'b1)
		r_i2s_shift_data <= i_data;
	else if(r_i2s_sclk_pos)
		r_i2s_shift_data <= {r_i2s_shift_data[62:0],1'b0};
	else ;
end



endmodule


