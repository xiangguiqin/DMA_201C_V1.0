module one_audio_pack #(
 parameter p_debug_en = 0
) (
 input			i_clk148p5M
,input			i_pcs_clk
,input			i_rst_n
,input 			i_i2s_sclk
,input 			i_i2s_rlclk
,input			i_i2s_data
,output			o_almostempty
,input			i_fifo_rd_en
,output	[63:0]	o_fifo_data
);

 wire              w_data_valid
;wire    [63:0]    w_data
;                  
 wire              w_almostfull
;wire              w_almostempty
;wire              w_full
;wire              w_empty
;

 assign o_almostempty = w_almostempty
;

iis_audio_IT6604_handle u0_iis_audio_IT6604_handle(
 .i_clk       (i_clk148p5M  )
,.i_rst_n     (i_rst_n      )
,.i_i2s_sclk  (i_i2s_sclk   )
,.i_i2s_rlclk (i_i2s_rlclk  )
,.i_i2s_data  (i_i2s_data   )
,.o_valid     (w_data_valid )
,.o_data      (w_data       )
);

fifo_w64_r64 u0_fifo_w64_r64(
 .rst                      (~i_rst_n                  )
,.wr_clk                   (i_clk148p5M               )
,.rd_clk                   (i_pcs_clk                 )
,.din                      (w_data                    )
,.wr_en                    (w_data_valid & (~w_full)  )
,.rd_en                    (i_fifo_rd_en & (~w_empty) )
,.prog_empty_thresh_assert (3                         )
,.prog_empty_thresh_negate (3                         )
,.prog_full_thresh_assert  (30                        )
,.prog_full_thresh_negate  (30                        )
,.dout                     (o_fifo_data               )
,.full                     (w_full                    )
,.empty                    (w_empty                   )
,.prog_full                (w_almostempty             )
,.prog_empty               (w_almostfull              )
);

/* generate 

	if(p_debug_en) begin
		
		ila_128 u0_ila_128(
			 .clk    (i_clk148p5M)
			,.probe0 ({
				 w_almostempty
				,w_almostfull
				,w_full
				,w_data_valid
				,w_empty
				,w_data
			})
		);   
		
		ila_128 u1_ila_128(
			 .clk    (i_pcs_clk)
			,.probe0 ({
				 w_almostempty
				,w_almostfull
				,w_full
				,i_fifo_rd_en
				,o_almostempty
				,w_empty
				,o_fifo_data
			})
		);   

	end
endgenerate */



endmodule


