module video_detect #(
 parameter p_debug_en       = "FALSE"
,parameter p_local_clk_freq = 'd74_250_000
) (
 input					i_video_clk
,input					i_local_clk
,input					i_rst_n      
,input					i_vsyn
,input					i_hsyn
,input					i_de		        
,output    	[25:0]		o_total_pix_num
,output reg	[12:0]		o_vs_total_num		 
,output reg	[12:0]		o_hs_total_num 
,output reg	[12:0]		o_vsyn_num 
,output reg	[12:0]		o_hsyn_num 
,output reg	[12:0]		o_video_start_pixel 
,output reg	[12:0]		o_video_end_pixel 
,output reg	[12:0]		o_video_start_H 
,output reg	[12:0]		o_video_end_H
,output	reg	[7:0]		o_refresh_rate
,output	reg				o_actual_vs_rise
,output	reg				o_bit_rate
);

reg             r_vsyn_dly1         ;
reg             r_vsyn_dly2         ;
reg             r_hsyn_dly1         ;
reg             r_hsyn_dly2         ;
reg             r_de_dly1           ;
reg             r_de_dly2           ;

reg    [31:0]	r_frame_len         ;
reg    [25:0]	r_de_total_cnt      ;
reg    [12:0]	r_hs_cnt            ;
reg    [12:0]	r_vs_cnt            ;
       
reg    [12:0]   r_vs_cnt1           ;
reg             r_de_rised          ;
reg             r_de_rised_dly1     ;

wire            w_de_pos            ;
wire            w_de_neg            ;
wire            w_hs_pos            ;
wire            w_hs_neg            ;
wire            w_vs_pos            ;
wire            w_vs_neg            ;

reg    [25:0]   r_total_pix_num     ;
reg    [31:0]	r_timeout1s_cnt     ;
reg    [7:0] 	r_vsyn_cnt          ;
reg    [2:0] 	r_vsyn              ;
wire			w_vsyn_pos          ;
wire 			w_onesecond_timeout ;

assign w_onesecond_timeout = (r_timeout1s_cnt == p_local_clk_freq);
assign w_vsyn_pos          = (r_vsyn[2] == 1'b0)  && (r_vsyn[1] == 1'b1);

assign w_de_pos = (r_de_dly2 == 0)   && (r_de_dly1 == 1);
assign w_de_neg = (r_de_dly2 == 1)   && (r_de_dly1 == 0);
assign w_hs_pos = (r_hsyn_dly2 == 0) && (r_hsyn_dly1 == 1);
assign w_hs_neg = (r_hsyn_dly2 == 1) && (r_hsyn_dly1 == 0);
assign w_vs_pos = (r_vsyn_dly2 == 0) && (r_vsyn_dly1 == 1);
assign w_vs_neg = (r_vsyn_dly2 == 1) && (r_vsyn_dly1 == 0);


assign o_total_pix_num = r_total_pix_num;


always @(posedge i_video_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1) begin
		r_vsyn_dly1     <=  1'b0;
		r_vsyn_dly2     <=  1'b0;
		r_hsyn_dly1     <=  1'b0;
		r_hsyn_dly2     <=  1'b0;
		r_de_dly1 	    <=  1'b0;
		r_de_dly2 	    <=  1'b0;
		r_de_rised_dly1 <=  1'b0;
	end else begin
		r_vsyn_dly1     <=  i_vsyn;
		r_vsyn_dly2     <=  r_vsyn_dly1;
		r_hsyn_dly1     <=  i_hsyn;
		r_hsyn_dly2     <=  r_hsyn_dly1;
		r_de_dly1 	    <=  i_de;
		r_de_dly2 	    <=  r_de_dly1;
		r_de_rised_dly1 <=  r_de_rised;
	end
end

always @(posedge i_video_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1)
		r_de_total_cnt <= 26'h0;
	else if(w_vs_pos == 1'b1)
		r_de_total_cnt <= 26'h0;
	else if(r_de_dly1)
		r_de_total_cnt <= r_de_total_cnt + 26'h1;
	else ;
end

always @(posedge i_video_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1)
		r_total_pix_num <=  'h0;
	else if(w_vs_pos == 1'b1)
		r_total_pix_num <=  r_de_total_cnt;
	else;
end

always @(posedge i_video_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1)
		r_hs_cnt <= 13'h0;
	else if(w_hs_pos == 1'b1)
		r_hs_cnt <= 13'h0;
	else
		r_hs_cnt <= r_hs_cnt + 13'h1;
end

always @(posedge i_video_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1)
		o_hs_total_num <= 13'h0;
	else if(w_hs_pos == 1'b1)
		o_hs_total_num <= r_hs_cnt;
	else;
end

always @(posedge i_video_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1)
		o_hsyn_num <= 13'h0;
	else if(w_hs_neg == 1'b1)
		o_hsyn_num <= r_hs_cnt;
	else;
end

always @(posedge i_video_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1)
		o_video_start_pixel <= 13'h0;
	else if(w_de_pos == 1'b1)
		o_video_start_pixel <= r_hs_cnt;
	else;
end

always @(posedge i_video_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1)
		o_video_end_pixel <= 13'h0;
	else if(w_de_neg == 1'b1)
		o_video_end_pixel <= r_hs_cnt;
	else;
end

always @(posedge i_video_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1)
		r_vs_cnt <= 13'h0;
	else if(w_vs_pos == 1'b1)
		r_vs_cnt <= 13'h0;
	else if(w_hs_neg == 1'b1)
		r_vs_cnt <= r_vs_cnt + 13'h1;
	else;
end

always @(posedge i_video_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1)
		o_vs_total_num <= 13'h0;
	else if(w_vs_pos == 1'b1)
		o_vs_total_num <= r_vs_cnt;
	else;
end


always @(posedge i_video_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1)
		o_vsyn_num <= 13'h0;
	else if(w_vs_neg == 1'b1)
		o_vsyn_num <= r_vs_cnt;
	else;
end

always @(posedge i_video_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1)
		r_de_rised <= 1'b0;
	else if(w_vs_neg == 1'b1)
		r_de_rised <= 1'b0;
	else if(w_de_pos == 1'b1)
		r_de_rised <= 1'b1;
	else;
end

always @(posedge i_video_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1)
		o_video_start_H <= 13'h0;
	else if(r_de_rised == 1'b1 && r_de_rised_dly1 == 0)
		o_video_start_H <= r_vs_cnt;
	else;
end

always @(posedge i_video_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1)
		r_vs_cnt1 <= 13'h0;
	else if(w_de_neg == 1'b1)
		r_vs_cnt1 <= r_vs_cnt;
	else;
end

always @(posedge i_video_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1)
		o_video_end_H <= 13'h0;
	else if(w_vs_pos == 1'b1)
		o_video_end_H <= r_vs_cnt1;
	else;
end

// o_refresh_rate opra
always @(posedge i_local_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1) 
		r_vsyn_cnt <= 8'h0;
	else if(w_onesecond_timeout == 1'b1)
		r_vsyn_cnt <= 8'h0;
	else if(w_vsyn_pos == 1'b1) 
		r_vsyn_cnt <= r_vsyn_cnt + 8'h1;
	else ;
end

always @(posedge i_local_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1) 
		o_refresh_rate <= 8'h0;
	else if(w_onesecond_timeout == 1'b1)
		o_refresh_rate <= r_vsyn_cnt;
	else ;
end

always @(posedge i_local_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1) 
		r_timeout1s_cnt <= 32'h0;
	else if(w_onesecond_timeout == 1'b1)
		r_timeout1s_cnt <= 32'h0;
	else 
		r_timeout1s_cnt <= r_timeout1s_cnt + 32'd1;
end

always @(posedge i_local_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1) 
		r_vsyn <= 3'h0;
	else
		r_vsyn <= {r_vsyn[1:0],i_vsyn};
end

always @(posedge i_local_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1) 
		o_actual_vs_rise <= 'b0;
	else if(r_vsyn == 3'b011 && (r_hs_cnt < 100 || r_hs_cnt > o_hs_total_num-100))
		o_actual_vs_rise <= 1'b1;
	else 
		o_actual_vs_rise <= 1'b0;
end

//检测图像速率是148.5MHz/1或者148.5MHz/1.001
always @(posedge i_local_clk or negedge i_rst_n) begin //148.5MHz
	if(i_rst_n != 1'b1) 
		r_frame_len <= 32'b0;
	else if(r_vsyn == 3'b011)
		r_frame_len <= 32'b0;
	else 
		r_frame_len <= r_frame_len + 'b1;
end

always @(posedge i_local_clk or negedge i_rst_n) begin //148.5MHz
	if(i_rst_n != 1'b1) 
		o_bit_rate <= 'b0;
	else if(r_vsyn == 3'b011 && ((r_frame_len > 32'd2_477_423 && r_frame_len < 32'd2_479_901)// 59.94
							 ||  (r_frame_len > 32'd4_954_845 && r_frame_len < 32'd4_959_803)// 29.97
							 ||  (r_frame_len > 32'd6_190_458 && r_frame_len < 32'd6_202_839)))// 23.98
		o_bit_rate <= 'b1;
	else 
		o_bit_rate <= 'b0;
end


generate

	if(p_debug_en == "TRUE") begin : ila
		
		ila_256 u_ila_256(
			 .clk    (i_video_clk)
			,.probe0 ({
				 i_vsyn
				,i_hsyn
				,i_de
				,o_actual_vs_rise
				,o_video_start_H
				,r_vs_cnt
				,r_hs_cnt
				,r_de_total_cnt
				,o_vsyn_num
				,o_video_end_pixel
				,o_hsyn_num
				,o_video_start_pixel
				,o_total_pix_num
				,o_vs_total_num
				,o_hs_total_num
				,o_refresh_rate
			})
		
		); 

	end
endgenerate



endmodule


