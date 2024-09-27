module pcs_rx_process(
 input 			    i_rst_n	
,input			    i_local_clk
,input			    i_video_clk
,input			    i_pcs_clk
,input			    i_data_valid
,input			    i_pcs_head
,input	[63:0]	    i_pcs_data

,output			    o_syn
,output			    o_pcs_lock
,output			    o_pcs_rst

,output			    o_uart_txd
,output			    o_uart_drive

,input 			    i_video_i2s_sclk 
,input 			    i_video_i2s_rlclk
,output 		    i_video_i2s_data 

,input 			    i_external_i2s_sclk 
,input 			    i_external_i2s_rlclk
,output 		    o_external_i2s_data 

,output	 		    o_video_vsyn
,output	 		    o_video_de  
,output	 [63:0]     o_video_data

,output	 	  	    o_video_lock
,output  [7:0]		o_resolution
,output  [12:0]		o_vs_total_num
,output  [12:0]		o_hs_total_num
,output  [12:0]		o_vsyn_num
,output  [12:0]		o_hsyn_num
,output  [12:0]		o_video_start_pixel
,output  [12:0]		o_video_end_pixel  
,output  [12:0]		o_video_start_H
,output  [12:0]		o_video_end_H  

);

 wire               w_unpack_uart_en
;wire    [31:0]     w_unpack_uart_data
;wire               w_unpack_audio0_en
;wire               w_unpack_audio1_en
;wire    [63:0]     w_unpack_audio0_data
;wire    [63:0]     w_unpack_audio1_data
;
 wire               w_fifo_rd_en
;wire               w_pcs_head_Q
;wire    [63:0]	    w_pcs_data_Q
;wire               w_full
;wire               w_empty
;reg     [25:0]     r_err_cnt
;reg     [1:0]      r_syn
;

assign o_pcs_lock = o_syn;
assign o_pcs_rst  = (r_err_cnt > 26'h3ffff00) ? 1 : 0;


always @(posedge i_local_clk or negedge i_rst_n) begin
	if(i_rst_n != 1)
		r_err_cnt <= 'd0;
	else if(r_syn[1])
		r_err_cnt <= 'd0;
	else
		r_err_cnt <= r_err_cnt + 1;
end

always @(posedge i_local_clk or negedge i_rst_n) begin
	if(i_rst_n != 1)
		r_syn <= 'd0;
	else
		r_syn <= {r_syn[0],o_syn};
end



fifo_512x65 u0_fifo_512x65(
 .srst  (~i_rst_n                    )
,.clk   (i_pcs_clk                   )
,.din   ({i_pcs_head,i_pcs_data}     )
,.wr_en (i_data_valid & (~w_full)    )
,.rd_en (w_fifo_rd_en & (~w_empty)   )
,.dout  ({w_pcs_head_Q,w_pcs_data_Q} )
,.full  (w_full                      )
,.empty (w_empty                     )
);

pcs_rx_unpack #(
 .p_debug_en(1)
) u0_pcs_rx_unpack(
 .i_rst_n             (i_rst_n              )
,.i_pcs_clk           (i_pcs_clk            )
,.i_data_valid        (i_data_valid         )
,.i_pcs_head          (w_pcs_head_Q         )
,.i_pcs_data          (w_pcs_data_Q         )
,.o_data_rd_en        (w_fifo_rd_en         )
,.i_empty             (w_empty              )

,.o_syn               (o_syn                )

,.o_video_vsyn        (o_video_vsyn         )
,.o_video_de          (o_video_de           )
,.o_video_data        (o_video_data         )

,.o_video_lock        (o_video_lock         )
,.o_resolution        (o_resolution         )
,.o_vs_total_num      (o_vs_total_num       )
,.o_hs_total_num      (o_hs_total_num       )
,.o_vsyn_num          (o_vsyn_num           )
,.o_hsyn_num          (o_hsyn_num           )
,.o_video_start_pixel (o_video_start_pixel  )
,.o_video_end_pixel   (o_video_end_pixel    )
,.o_video_start_H     (o_video_start_H      )
,.o_video_end_H       (o_video_end_H        )

,.o_uart_en           (w_unpack_uart_en     )
,.o_uart_data         (w_unpack_uart_data   )
,.o_audio0_en         (w_unpack_audio0_en   )
,.o_audio0_data       (w_unpack_audio0_data )
,.o_audio1_en         (w_unpack_audio1_en   )
,.o_audio1_data       (w_unpack_audio1_data )
);

one_audio_unpack u0_one_audio_unpack(
 .i_clk148p5M  (i_pcs_clk            )
,.i_pcs_clk    (i_pcs_clk            )
,.i_rst_n      (i_rst_n              )
,.i_i2s_sclk   (i_video_i2s_sclk     )
,.i_i2s_rlclk  (i_video_i2s_rlclk    )
,.o_i2s_data   (i_video_i2s_data     )
,.i_valid      (w_unpack_audio0_en   )
,.i_data       (w_unpack_audio0_data )
);

one_audio_unpack u1_one_audio_unpack(
 .i_clk148p5M  (i_pcs_clk            )
,.i_pcs_clk    (i_pcs_clk            )
,.i_rst_n      (i_rst_n              )
,.i_i2s_sclk   (i_external_i2s_sclk  )
,.i_i2s_rlclk  (i_external_i2s_rlclk )
,.o_i2s_data   (o_external_i2s_data  )
,.i_valid      (w_unpack_audio1_en   )
,.i_data       (w_unpack_audio1_data )
);

one_uart_unpack u0_one_uart_unpack(
 .i_clk148p5M  (i_pcs_clk          )
,.i_pcs_clk    (i_pcs_clk          )
,.i_rst_n      (i_rst_n            )
,.o_uart_txd   (o_uart_txd         )
,.o_uart_drive (o_uart_drive       )
,.i_valid      (w_unpack_uart_en   )
,.i_data       (w_unpack_uart_data )
);


endmodule


