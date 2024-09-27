module i2s_clock_gen(
 input          i_clk
,input	        i_rst_n
,output reg     o_mclk
,output reg     o_sclk
,output reg     o_rlclk

);

reg [15:0] 	r_mclk_div_cnt ;
reg [15:0] 	r_sclk_div_cnt ;
reg [15:0] 	r_rlclk_div_cnt;
reg         r_hold         ;


always @(posedge i_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1) 
		r_rlclk_div_cnt <= 16'd0;
	else if(r_rlclk_div_cnt == 16'd3071)
		r_rlclk_div_cnt <= 1'b0;
	else if(r_hold)
		r_rlclk_div_cnt <= r_rlclk_div_cnt;
	else
		r_rlclk_div_cnt <= r_rlclk_div_cnt + 8'd1;
end

always @(posedge i_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1) 
		r_hold <= 'd0;
	else if((&r_rlclk_div_cnt[6:0]) && (r_hold==0))
		r_hold <= 1'b1;
	else
		r_hold <= 1'b0;
end


always @(posedge i_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1) 
		o_rlclk <= 1'b0;
	else if(r_rlclk_div_cnt < 16'd1536)
		o_rlclk <= 1'b1;
	else 
		o_rlclk <= 1'b0;
end

//SCLK generate 
always @(posedge i_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1) 
		r_sclk_div_cnt <= 8'd0;
	else if(r_rlclk_div_cnt == 16'd23 || (r_rlclk_div_cnt - r_sclk_div_cnt == 16'd24))
		r_sclk_div_cnt <= r_rlclk_div_cnt;
	else ;
end
always @(posedge i_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1) 
		o_sclk <= 1'b0;
	else if(r_rlclk_div_cnt == 16'd23) 
		o_sclk <= 1'b1;
	else if(r_rlclk_div_cnt - r_sclk_div_cnt == 16'd24)
		o_sclk <= ~o_sclk;
	else ;
end


//MCLK generate 
always @(posedge i_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1) 
		r_mclk_div_cnt <= 16'd0;
	else if(r_rlclk_div_cnt == 16'd0 || r_rlclk_div_cnt - r_mclk_div_cnt == 16'd6)
		r_mclk_div_cnt <= r_rlclk_div_cnt;
	else  ;
end
always @(posedge i_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1) 
		o_mclk <= 1'b0;
	else if(r_rlclk_div_cnt == 16'd0)
		o_mclk <= 1'b1;
	else if(r_rlclk_div_cnt - r_mclk_div_cnt == 16'd6)
		o_mclk <= ~o_mclk;
	else ;
end



endmodule