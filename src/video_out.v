`timescale 1ns/1ps
module video_out(
 input					i_video_clk
,input					i_rst_n     
,input					i_frm_gen_enable
,input		[7:0]		i_resolution  
,input 		[12:0]		i_vs_total_num
,input 		[12:0]		i_hs_total_num 
,input 		[12:0]		i_vsyn_num 
,input 		[12:0]		i_hsyn_num 
,input 		[12:0]		i_video_start_pixel
,input 		[12:0]		i_video_end_pixel
,input 		[12:0]		i_video_start_H
,input 		[12:0]		i_video_end_H
,output					o_hsyn
,output					o_vsyn
,output					o_de
,output					o_rd
);

 reg              r_frm_gen_enable   , r_frm_gen_enable_dly1
;reg    [12:0]    r_vs_total_num     , r_vs_total_num_dly1
;reg    [12:0]    r_hs_total_num     , r_hs_total_num_dly1
;reg    [12:0]    r_vsyn_num         , r_vsyn_num_dly1
;reg    [12:0]    r_hsyn_num         , r_hsyn_num_dly1
;reg    [12:0]    r_video_start_pixel, r_video_start_pixel_dly1
;reg    [12:0]    r_video_end_pixel  , r_video_end_pixel_dly1
;reg    [12:0]    r_video_start_H    , r_video_start_H_dly1
;reg    [12:0]    r_video_end_H      , r_video_end_H_dly1
;reg    [7:0]     r_resolution       , r_resolution_dly1
;reg              r_interlaced
;

frame_timming_gen frame_timming_gen_u0(
 .i_clk               (i_video_clk              )
,.i_rst_n             (i_rst_n                  )
,.i_frm_gen_enable    (r_frm_gen_enable_dly1    )
,.i_resolution        (r_resolution_dly1        )
,.i_vs_total_num      (r_vs_total_num_dly1      )
,.i_hs_total_num      (r_hs_total_num_dly1      )
,.i_vsyn_num          (r_vsyn_num_dly1          )
,.i_hsyn_num          (r_hsyn_num_dly1          )
,.i_video_start_pixel (r_video_start_pixel_dly1 )
,.i_video_end_pixel   (r_video_end_pixel_dly1   )
,.i_video_start_H     (r_video_start_H_dly1     )
,.i_video_end_H       (r_video_end_H_dly1       )
,.o_vsyn              (o_vsyn                   )
,.o_hsyn              (o_hsyn                   )
,.o_de                (o_de                     )
,.o_rd                (o_rd                     )
);


always @(posedge i_video_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1) begin
		r_frm_gen_enable         <=  1'b0 ;
		r_vs_total_num           <=  13'b0;
		r_hs_total_num           <=  13'b0;
		r_vsyn_num               <=  13'b0;
		r_hsyn_num               <=  13'b0;
		r_video_start_pixel      <=  13'b0;
		r_video_end_pixel        <=  13'b0;
		r_video_start_H          <=  13'b0;
		r_video_end_H            <=  13'b0;
		r_frm_gen_enable_dly1    <=  1'b0 ;
		r_vs_total_num_dly1      <=  13'b0;
		r_hs_total_num_dly1      <=  13'b0;
		r_vsyn_num_dly1          <=  13'b0;
		r_hsyn_num_dly1          <=  13'b0;
		r_video_start_pixel_dly1 <=  13'b0;
		r_video_end_pixel_dly1   <=  13'b0;
		r_video_start_H_dly1     <=  13'b0;
		r_video_end_H_dly1       <=  13'b0;
		r_resolution             <=  5'b0 ;
		r_resolution_dly1        <=  5'b0 ;
	end else begin
		r_frm_gen_enable         <= i_frm_gen_enable                          ;
		r_vs_total_num           <= i_vs_total_num                            ;
		r_hs_total_num           <= i_hs_total_num                            ;
		r_vsyn_num               <= i_vsyn_num                                ;
		r_hsyn_num               <= i_hsyn_num                                ;
		r_video_start_pixel      <= i_video_start_pixel                       ;
		r_video_end_pixel        <= i_video_end_pixel                         ;
		r_video_start_H          <= i_video_start_H                           ;
		r_video_end_H            <= i_video_end_H                             ;
		r_frm_gen_enable_dly1    <= r_frm_gen_enable                          ;
		r_vs_total_num_dly1      <= (r_interlaced) ? 13'd1125 : r_vs_total_num;
		r_hs_total_num_dly1      <= r_hs_total_num                            ;
		r_vsyn_num_dly1          <= r_vsyn_num                                ;
		r_hsyn_num_dly1          <= r_hsyn_num                                ;
		r_video_start_pixel_dly1 <= r_video_start_pixel                       ;
		r_video_end_pixel_dly1   <= r_video_end_pixel                         ;
		r_video_start_H_dly1     <= r_video_start_H                           ;
		r_video_end_H_dly1       <= (r_interlaced) ? 13'd1123 : r_video_end_H ;
		r_resolution             <= i_resolution	                          ;
		r_resolution_dly1        <= r_resolution		                      ;
	end
end


always @(posedge i_video_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1)
		r_interlaced <= 1'b0;
	else if(r_resolution_dly1 == 5'h12 || r_resolution_dly1 == 5'h13)
		r_interlaced <= 1'b1;
	else
		r_interlaced <= 1'b0;
end

endmodule

