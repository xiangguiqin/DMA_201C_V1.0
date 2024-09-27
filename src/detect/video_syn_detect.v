`timescale 1 ns / 1 ps
module video_syn_detect(
 input				i_clk
,input				i_rst_n
,input				i_low_more_flag
,input				i_video_vsyn
,output	reg			o_video_vsyn
);

reg    [23:0]   vsyn_detect_high_cnt   ;
reg    [3:0]    vsyn_detect_high_large ;
reg    [23:0]   vsyn_detect_low_cnt    ;
reg    [3:0]    vsyn_detect_low_large  ;
reg             r_video_vsyn           ;
reg             r_video_vsyn_dly1      ;
reg             r_video_vsyn_dly2      ;
wire            w_video_vsyn_pos       ;
reg             r_syn_pority_flag      ;

assign w_video_vsyn_pos = (r_video_vsyn_dly1 == 1'b1 && r_video_vsyn_dly2 == 1'b0);
always @(posedge i_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1) begin 
		r_video_vsyn      <= 1'b0;
		r_video_vsyn_dly1 <= 1'b0;
		r_video_vsyn_dly2 <= 1'b0;
	end else begin
		r_video_vsyn      <= i_video_vsyn     ;
		r_video_vsyn_dly1 <= r_video_vsyn     ;
		r_video_vsyn_dly2 <= r_video_vsyn_dly1;
	end
end


always @(posedge i_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1)  
		vsyn_detect_high_cnt <= 24'b0;
	else if(w_video_vsyn_pos == 1'b1)
		vsyn_detect_high_cnt <= 24'd0;
	else if(r_video_vsyn_dly1 == 1'b1)
		vsyn_detect_high_cnt <= vsyn_detect_high_cnt + 24'd1;
	else ;
end

always @(posedge i_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1)  
		vsyn_detect_low_cnt <= 24'b0;
	else if(w_video_vsyn_pos == 1'b1)
		vsyn_detect_low_cnt <= 24'd0;
	else if(r_video_vsyn_dly1 == 1'b0)
		vsyn_detect_low_cnt <= vsyn_detect_low_cnt + 24'd1;
	else ;
end

always @(posedge i_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1)  
		vsyn_detect_high_large <= 4'd0;
	else if(vsyn_detect_high_large == 4'd3 || vsyn_detect_low_large == 4'd3)
		vsyn_detect_high_large <= 4'd0;
	else if(w_video_vsyn_pos == 1'b1 && vsyn_detect_high_cnt > vsyn_detect_low_cnt)
		vsyn_detect_high_large <= vsyn_detect_high_large + 4'd1;
	else ;
end

always @(posedge i_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1)  
		vsyn_detect_low_large <= 4'd0;
	else if(vsyn_detect_high_large == 4'd3 || vsyn_detect_low_large == 4'd3)
		vsyn_detect_low_large <= 4'd0;
	else if(w_video_vsyn_pos == 1'b1 && vsyn_detect_high_cnt < vsyn_detect_low_cnt)
		vsyn_detect_low_large <= vsyn_detect_low_large + 4'd1;
	else ;
end

always @(posedge i_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1)  
		r_syn_pority_flag <= 1'b0;
	else if(vsyn_detect_low_large == 4'd3)
		r_syn_pority_flag <= 1'b0;
	else if(vsyn_detect_high_large == 4'd3)
		r_syn_pority_flag <= 1'b1;
	else ;
end

always @(posedge i_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1)  
		o_video_vsyn <= 1'b0;
	else if(r_syn_pority_flag == 1'b1 && i_low_more_flag == 1'b1)
		o_video_vsyn <= ~r_video_vsyn;
	else 
		o_video_vsyn <= r_video_vsyn;
end
		
endmodule



