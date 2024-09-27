`timescale 1ns/1ps
module frame_timming_gen(
 input 	        i_clk 
,input 	        i_rst_n 
,input			i_frm_gen_enable
,input	[4:0]	i_resolution
,input 	[12:0]	i_vs_total_num		 
,input 	[12:0]	i_hs_total_num 
,input 	[12:0]	i_vsyn_num 
,input 	[12:0]	i_hsyn_num 
,input 	[12:0]	i_video_start_pixel 
,input 	[12:0]	i_video_end_pixel 
,input 	[12:0]	i_video_start_H 
,input 	[12:0]	i_video_end_H 

,output			o_vsyn
,output			o_hsyn
,output			o_de
,output			o_rd
);

//{-------------------------------------------------------------
reg     [12:0]  r_hor_cnt  			    ;
reg     [12:0]  r_ver_cnt  			    ;

reg             r_hsyn  				;
reg             r_vsyn  				;
reg             r_de  				    ;
reg             r_hsyn_dly1  			;
reg             r_vsyn_dly1  			;
reg             r_de_dly1  				;
reg             r_hsyn_dly2  			;
reg             r_vsyn_dly2  			;
reg             r_de_dly2  				;
reg             r_I60_vsyn_flag		    ;

reg             r_I60_de_stop_flag		;

reg             r_frm_gen_enable        ;

assign o_vsyn = r_vsyn_dly2;
assign o_hsyn = r_hsyn_dly2;
assign o_de	  = r_de_dly2  ;
assign o_rd	  = r_de_dly1  ;

//{-------------------------------------------------------------
always @(posedge i_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1) begin
		r_frm_gen_enable  <= 	 1'b0		;
		r_de_dly1		  <= 	 1'b0		;
		r_hsyn_dly1		  <= 	 1'b0		;
		r_vsyn_dly1		  <= 	 1'b0		;
		r_de_dly2		  <= 	 1'b0		;
		r_hsyn_dly2		  <= 	 1'b0		;
		r_vsyn_dly2		  <= 	 1'b0		;
	end else begin
		r_frm_gen_enable  <= i_frm_gen_enable        ;
		r_de_dly1		  <= r_de                    ;
		r_hsyn_dly1		  <= r_hsyn                  ;
		r_vsyn_dly1		  <= r_vsyn | r_I60_vsyn_flag;
		r_de_dly2		  <= r_de_dly1		  		 ;
		r_hsyn_dly2		  <= r_hsyn_dly1             ;
		r_vsyn_dly2		  <= r_vsyn_dly1             ;
	end
end
//}-------------------------------------------------------------
//{-------------------------------------------------------------
always @(posedge i_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1)
		r_hor_cnt <= #1 13'h0					;
	else if(r_frm_gen_enable != 1)
		r_hor_cnt <= #1 13'h0					;
	else if(r_hor_cnt == i_hs_total_num)
		r_hor_cnt <= #1 13'h0					;
	else
		r_hor_cnt <= #1 r_hor_cnt + 13'h1		;
end

always @(posedge i_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1)
		r_ver_cnt <= #1 13'h0					;
	else if(r_frm_gen_enable != 1)
		r_ver_cnt <= #1 13'h0					;		
	else if((r_hor_cnt == i_hs_total_num) && (r_ver_cnt == i_vs_total_num-1))
		r_ver_cnt <= #1 13'h0					;
	else if((r_hor_cnt == i_hs_total_num))
		r_ver_cnt <= #1 r_ver_cnt + 13'h1		;
	else;
end
//}-------------------------------------------------------------
//{-------------------------------------------------------------
always @(posedge i_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1)
		r_hsyn <= #1 1'b0					;
	else if(r_frm_gen_enable != 1)
		r_hsyn <= #1 1'b0					;		
	else if(r_hor_cnt <= i_hsyn_num)
		r_hsyn <= #1 1'b1					;
	else
		r_hsyn <= #1 1'b0					;
end

always @(posedge i_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1)
		r_vsyn <= #1 1'b0					;
	else if(r_frm_gen_enable != 1)
		r_vsyn <= #1 1'b0					;		
	else if(r_ver_cnt < i_vsyn_num)
		r_vsyn <= #1 1'b1					;
	else
		r_vsyn <= #1 1'b0					;
end

always @(posedge i_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1)
		r_de <= #1 1'b0;
	else if(i_frm_gen_enable != 1)
		r_de <= #1 1'b1;
	else if((r_hor_cnt > i_video_start_pixel && r_hor_cnt <= i_video_end_pixel) && 
			(r_ver_cnt >= i_video_start_H-1 && r_ver_cnt < i_video_end_H)       && 
			(r_I60_de_stop_flag==0))
		r_de <= #1 1'b1;
	else
		r_de <= #1 1'b0;
end
//}-------------------------------------------------------------
//{-------------------------------------------------------------
always @(posedge i_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1)
		r_I60_de_stop_flag <= #1 1'b0;
	else if((i_resolution == 5'h12 || i_resolution == 5'h13) && r_ver_cnt > 13'd559 && r_ver_cnt < 13'd583)
		r_I60_de_stop_flag <= #1 1'b1;
	else
		r_I60_de_stop_flag <= #1 1'b0;
end

always @(posedge i_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1)
		r_I60_vsyn_flag <= #1 1'b0;
	else if(i_resolution != 5'h12 || i_resolution != 5'h13)
		r_I60_vsyn_flag <= #1 1'b0;
	else if(i_resolution == 5'h13) begin	//1080I60
		if(r_ver_cnt == 13'd562 && r_hor_cnt == 13'd1099)
			r_I60_vsyn_flag <= #1 1'b1;
		else if(r_ver_cnt == 13'd567 && r_hor_cnt == 13'd1099)
			r_I60_vsyn_flag <= #1 1'b0;
		else ;
	end else if(i_resolution == 5'h12) begin	//1080I50
		if(r_ver_cnt == 13'd562 && r_hor_cnt == 13'd1319)
			r_I60_vsyn_flag <= #1 1'b1;
		else if(r_ver_cnt == 13'd567 && r_hor_cnt == 13'd1319)
			r_I60_vsyn_flag <= #1 1'b0;
		else ;
	end else ;
end



/* generate 

	if(p_debug_en) begin
	
		ila_256 u0_ila_256(
			.clk     (i_clk)
			,.probe0 ({
				 r_vsyn
				,r_hsyn
				,r_de
				,r_ver_cnt
				,r_hor_cnt
				,r_I60_de_stop_flag
				,r_I60_vsyn_flag
				,i_resolution
				,i_vs_total_num
				,i_hs_total_num
				,i_vsyn_num
				,i_hsyn_num
				,i_video_start_pixel
				,i_video_end_pixel
				,i_video_start_H
				,i_video_end_H
				
			})
		);

	end
endgenerate */



endmodule


