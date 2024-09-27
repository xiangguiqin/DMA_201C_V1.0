module one_audio_unpack(
 input			i_clk148p5M
,input			i_pcs_clk          
,input			i_rst_n
,input 			i_i2s_sclk 
,input 			i_i2s_rlclk
,output			o_i2s_data 
,input			i_valid
,input	[63:0]	i_data       
);

wire              w_almostempty ;	
wire              w_almostfull  ;	
wire              w_empty       ;	
wire              w_full        ;
wire              w_fifo_rd_en  ;
wire    [63:0]    w_fifo_Q      ;


fifo_w64_r64 u0_fifo_w64_r64(
 .prog_empty_thresh_assert (3                         )
,.prog_empty_thresh_negate (3                         )
,.prog_full_thresh_assert  (30                        )
,.prog_full_thresh_negate  (30                        )
,.din                      (i_data                    )
,.wr_clk                   (i_pcs_clk                 )
,.rd_clk                   (i_clk148p5M               )
,.wr_en                    (i_valid & (~w_full)       )
,.rd_en                    (w_fifo_rd_en & (~w_empty) )
,.rst                      (~i_rst_n                  )
,.dout                     (w_fifo_Q                  )
,.prog_empty               (w_almostempty             )
,.prog_full                (w_almostfull              )
,.empty                    (w_empty                   )
,.full                     (w_full                    )
);

iis_audio_CS4334_handle u0_iis_audio_CS4334_handle(
 .i_clk        (i_clk148p5M  )
,.i_rst_n      (i_rst_n      )
,.i_i2s_sclk   (i_i2s_sclk   )
,.i_i2s_rlclk  (i_i2s_rlclk  )
,.o_i2s_data   (o_i2s_data   )
,.o_fifo_rd_en (w_fifo_rd_en )
,.i_data       (w_fifo_Q     )
); 



endmodule


