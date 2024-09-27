module video_judgement(
 input           i_local_clk
,input           i_rst_n
,input  [25:0]   i_total_pix_num
,input  [12:0]   i_h_num
,input  [12:0]   i_v_num
,input  [7:0]    i_refresh_rate
,input           i_vsyn
,output [7:0]    o_resolution
,output          o_video_valid
);

reg    [3:0]    r_vsyn        ;
reg    [7:0]    r_vsyn_cnt    ;
reg    [7:0]    r_refresh_rate;
reg    [7:0]    r_resolution  ;
reg             r_video_valid ;


assign o_resolution  = r_video_valid ? r_resolution : 'h0;
assign o_video_valid = r_video_valid;//(r_resolution > 0);


always @(posedge i_local_clk or negedge i_rst_n) begin
	if(!i_rst_n)
		r_vsyn <= 'd0;
	else
		r_vsyn <= {r_vsyn[2:0],i_vsyn};
end

always @(posedge i_local_clk or negedge i_rst_n) begin
	if(!i_rst_n)
		r_refresh_rate <= 'd0;
	else
		r_refresh_rate <= i_refresh_rate;
end

always @(posedge i_local_clk or negedge i_rst_n) begin
	if(!i_rst_n)
		r_vsyn_cnt <= 'd0;
	else if(r_resolution == 'd0)
		r_vsyn_cnt <= 'd0;
	else if(&r_vsyn_cnt)
		r_vsyn_cnt <= r_vsyn_cnt;
	else if(r_resolution>'d0 && r_vsyn[3:2]==2'b01)
		r_vsyn_cnt <= r_vsyn_cnt + 'd1;
	else ;
end

always @(posedge i_local_clk or negedge i_rst_n) begin
	if(!i_rst_n)
		r_video_valid <= 'd0;
	else if(r_resolution == 'd0)
		r_video_valid <= 'd0;
	else if(r_resolution>'d0 && r_vsyn[3:2]==2'b01 && r_vsyn_cnt>'d16)
		r_video_valid <= 'd1;
	else ;
end

always @(posedge i_local_clk or negedge i_rst_n) begin
	if(!i_rst_n)
		r_resolution <= 'h00;
	else if(i_h_num>2190 && i_h_num<2210 && i_v_num>1115 && i_v_num<1135 && r_refresh_rate>55 && r_refresh_rate<65 && i_total_pix_num>2073100 && i_total_pix_num<2074100)//1920x1080P60 148.5MHz
		r_resolution <= 'h16;
	else
		r_resolution <= 'h00;
end




endmodule


