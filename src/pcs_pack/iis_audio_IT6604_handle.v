`timescale 1 ns / 1 ps
module iis_audio_IT6604_handle(
 input                   i_clk
,input                   i_rst_n
,input                   i_i2s_sclk
,input                   i_i2s_rlclk
,input                   i_i2s_data
,output reg              o_valid
,output reg    [63:0]    o_data
);

 reg              r_i2s_sclk
;reg              r_i2s_sclk_dly1
;reg              r_i2s_sclk_dly2
;reg              r_i2s_sclk_dly3
;wire             w_i2s_sclk_pos
;reg              r_i2s_sclk_pos_dly1
;reg              r_i2s_rlclk
;reg              r_i2s_rlclk_dly1
;reg              r_i2s_rlclk_dly2
;	
 reg              r_data
;reg              r_data_dly1
;reg              r_data_dly2
;reg              r_data_dly3
;
 reg              r_i2s_rlclk_recover
;reg              r_i2s_rlclk_recover_dly1
;wire             w_i2s_rlclk_pos
;reg    [63:0]    r_data_shift
;

 assign w_i2s_sclk_pos  = (r_i2s_sclk_dly2==1'b1 && r_i2s_sclk_dly3==1'b0)
;assign w_i2s_rlclk_pos = (r_i2s_rlclk_recover==1'b1 && r_i2s_rlclk_recover_dly1==1'b0)
;

always @(posedge i_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1) begin
		r_i2s_sclk               <= 1'b0;
		r_i2s_sclk_dly1          <= 1'b0;
		r_i2s_sclk_dly2          <= 1'b0;
		r_i2s_sclk_dly3          <= 1'b0;
		r_i2s_rlclk              <= 1'b0;
		r_i2s_rlclk_dly1         <= 1'b0;
		r_i2s_rlclk_dly2         <= 1'b0;
		r_data                   <= 1'b0;
		r_data_dly1              <= 1'b0;
		r_data_dly2              <= 1'b0;
		r_data_dly3              <= 1'b0;
		r_i2s_rlclk_recover_dly1 <= 1'b0;
		r_i2s_sclk_pos_dly1      <= 1'b0;		
	end else begin
		r_i2s_sclk               <= i_i2s_sclk;
		r_i2s_sclk_dly1          <= r_i2s_sclk;
		r_i2s_sclk_dly2          <= r_i2s_sclk_dly1;
		r_i2s_sclk_dly3          <= r_i2s_sclk_dly2;
		r_i2s_rlclk              <= i_i2s_rlclk;
		r_i2s_rlclk_dly1         <= r_i2s_rlclk;
		r_i2s_rlclk_dly2         <= r_i2s_rlclk_dly1;
		r_data                   <= i_i2s_data;
		r_data_dly1              <= r_data;
		r_data_dly2              <= r_data_dly1;
		r_data_dly3              <= r_data_dly2;
		r_i2s_rlclk_recover_dly1 <= r_i2s_rlclk_recover;
		r_i2s_sclk_pos_dly1      <= w_i2s_sclk_pos;
	end
end

always @(posedge i_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1)
		r_i2s_rlclk_recover <= 1'b0;
	else if(w_i2s_sclk_pos == 1'b1)
		r_i2s_rlclk_recover <= r_i2s_rlclk_dly2;
	else ;
end

always @(posedge i_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1) 
		r_data_shift <= 64'd0;
	else if(r_i2s_sclk_pos_dly1 == 1'b1)
		r_data_shift <= {r_data_shift[62:0],r_data_dly3};
	else ;
end

always @(posedge i_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1) begin
		o_valid <= 1'b0;
		o_data  <= 64'd0;
	end else if(w_i2s_rlclk_pos == 1'b1) begin
		o_valid <= 1'b1;
		o_data  <= r_data_shift;
	end else begin
		o_valid <= 1'b0;
		o_data  <= 64'd0;
	end
end




endmodule


