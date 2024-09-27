module pcs_tx_process(
 input 					i_rst_n	
,input					i_local_clk
,input					i_pcs_clk

,input					i_video_clk
,input					i_video_vsyn
,input					i_video_hsyn
,input					i_video_de
,input	    [23:0]		i_video_data

,input	    [7:0] 		i_resolution
,input					i_video_lock
,input 		[12:0]		i_vs_total_num     
,input 		[12:0]		i_hs_total_num     
,input 		[12:0]		i_vsyn_num         
,input 		[12:0]		i_hsyn_num         
,input 		[12:0]		i_video_start_pixel
,input 		[12:0]		i_video_end_pixel  
,input 		[12:0]		i_video_start_H    
,input 		[12:0]		i_video_end_H      

,input 					i_video_i2s_sclk 
,input 					i_video_i2s_rlclk
,input					i_video_i2s_data 

,input					i_external_i2s_sclk 
,input					i_external_i2s_rlclk
,input					i_external_i2s_data 

,input					i_uart_rxd

,output					o_pcs_rst
,input					i_pcs_rd_en
,output		[63:0]		o_pcs_data 
,output					o_pcs_head 
);



wire 			    w_pack_K_link		    ;
wire 	[63:0]	    w_pack_D_link		    ;
wire 			    w_pack_valid	        ;
wire 				w_empty                 ;
wire 				w_full                  ;

wire				w_video_almostfull      ;
wire				w_video_rd_en           ;
wire	[63:0]  	w_video_data            ;

wire 				w_audio0_almostempty    ;
wire 				w_audio0_rd_en          ;
wire    [63:0]      w_audio0_data           ;
                                            
wire 				w_audio1_almostempty    ;
wire 				w_audio1_rd_en          ;
wire    [63:0] 		w_audio1_data           ;
                                            
wire 				w_uart_almostempty      ;
wire 				w_uart_rd_en            ;
wire    [31:0] 		w_uart_data             ;

wire 				w_vsyn_flag             ;

wire    [12:0]      w_width                 ;
wire    [12:0]      w_heigh                 ;

assign w_width = (i_video_lock==1) ? i_video_end_pixel-i_video_start_pixel : 'd0;
assign w_heigh = (i_video_lock==1) ? i_video_end_H - i_video_start_H + 1   : 'd0;

video_in_buf #(
 .p_debug_en(1)
) u0_video_in_buf(
 .i_video_clk  (i_video_clk        )
,.i_pcs_clk    (i_pcs_clk          )
,.i_rst_n      (i_rst_n            )
,.i_width      (w_width            )
,.i_heigh      (w_heigh            )
,.i_vsyn       (i_video_vsyn       )
,.i_hsyn       (i_video_hsyn       )
,.i_de		   (i_video_de         )
,.i_video_data (i_video_data       )
,.i_fifo_rd_en (w_video_rd_en      )
,.o_almostfull (w_video_almostfull )
,.o_fifo_data  (w_video_data       )
,.o_vsyn_flag  (w_vsyn_flag        )
);

one_audio_pack u0_one_audio_pack(
 .i_clk148p5M   (i_local_clk          )
,.i_pcs_clk     (i_pcs_clk            )
,.i_rst_n       (i_rst_n              )
,.i_i2s_sclk    (i_video_i2s_sclk     )
,.i_i2s_rlclk   (i_video_i2s_rlclk    )
,.i_i2s_data    (i_video_i2s_data     )
,.o_almostempty (w_audio0_almostempty )
,.i_fifo_rd_en  (w_audio0_rd_en       )
,.o_fifo_data   (w_audio0_data        )
);

one_audio_pack u1_one_audio_pack(
 .i_clk148p5M   (i_local_clk          )
,.i_pcs_clk     (i_pcs_clk            )
,.i_rst_n       (i_rst_n              )
,.i_i2s_sclk    (i_external_i2s_sclk  )
,.i_i2s_rlclk   (i_external_i2s_rlclk )
,.i_i2s_data    (i_external_i2s_data  )
,.o_almostempty (w_audio1_almostempty )
,.i_fifo_rd_en  (w_audio1_rd_en       )
,.o_fifo_data   (w_audio1_data        )
);

one_uart_pack u0_one_uart_pack(
 .i_clk148p5M   (i_local_clk        )
,.i_pcs_clk     (i_pcs_clk          )
,.i_rst_n       (i_rst_n            )
,.i_uart_rxd    (i_uart_rxd         )
,.o_almostempty (w_uart_almostempty )
,.i_fifo_rd_en  (w_uart_rd_en       )
,.o_fifo_data   (w_uart_data        )
);

pcs_tx_pack #(
 .p_debug_en(1)
) u_pcs_tx_pack(
 .i_rst_n              (i_rst_n              )
,.i_pcs_clk            (i_pcs_clk            )

,.i_video_vsyn         (i_video_vsyn         )
,.i_video_almostfull   (w_video_almostfull   )
,.o_video_rd_en        (w_video_rd_en        )
,.i_video_data         (w_video_data         )

,.i_uart_almostempty   (w_uart_almostempty   )
,.o_uart_rd_en         (w_uart_rd_en         )
,.i_uart_data          (w_uart_data          )

,.i_audio0_almostempty (w_audio0_almostempty )
,.o_audio0_rd_en       (w_audio0_rd_en       )
,.i_audio0_data        (w_audio0_data        )
,.i_audio1_almostempty (w_audio1_almostempty )
,.o_audio1_rd_en       (w_audio1_rd_en       )
,.i_audio1_data        (w_audio1_data        )

,.i_resolution         (i_resolution         )
,.i_video_lock         (i_video_lock         )
,.i_vs_total_num       (i_vs_total_num       )
,.i_hs_total_num       (i_hs_total_num       )
,.i_vsyn_num           (i_vsyn_num           )
,.i_hsyn_num           (i_hsyn_num           )
,.i_video_start_pixel  (i_video_start_pixel  )
,.i_video_end_pixel    (i_video_end_pixel    )
,.i_video_start_H      (i_video_start_H      )
,.i_video_end_H        (i_video_end_H        )

,.o_pcs_data           (w_pack_D_link        )
,.o_pcs_head           (w_pack_K_link        )
,.o_data_valid         (w_pack_valid         )
);

fifo_512x65 u0_fifo_512x65(
 .srst  (~i_rst_n                      )
,.clk   (i_pcs_clk                     )
,.din   ({w_pack_K_link,w_pack_D_link} )
,.wr_en (w_pack_valid & (~w_full)      )
,.rd_en (i_pcs_rd_en & (~w_empty)      )
,.dout  ({o_pcs_head,o_pcs_data}       )
,.full  (w_full                        )
,.empty (w_empty                       )
);



endmodule


