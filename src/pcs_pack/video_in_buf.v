module video_in_buf #(
 parameter p_debug_en = 0
) (
 input					i_video_clk      		
,input					i_pcs_clk
,input					i_rst_n     
,input					i_vsyn    	
,input					i_hsyn    	
,input					i_de		        
,input		[23:0]		i_video_data         
,input					i_fifo_rd_en     
,output					o_almostfull
,output		[63:0]		o_fifo_data
,input	    [12:0]   	i_width
,input	    [12:0]   	i_heigh

,output					o_vsyn_flag
	
);

 reg    [23:0] 	r_data
;reg    	    r_de
;reg    [2:0] 	r_vsyn
;reg    [2:0] 	r_hsyn
;
 wire 		    w_empty
;wire 		    w_full
;wire 		    w_almostempty
;wire 		    w_almostfull
;
 wire   [63:0]	w_wr_fifo_data
;wire   		w_wr_fifo_de
;
 reg    [12:0] 	r_width_dly1
;reg    [12:0] 	r_heigh_dly1
;reg    [11:0] 	r_col_cnt
;reg    [11:0] 	r_row_cnt
;reg            r_frm_end_en
;reg    [12:0]	r_frm_end_replenish_cnt
;

 assign o_vsyn_flag    = i_vsyn//rOutVFlag
;assign w_wr_fifo_data = r_de ? {32'h0,8'h0,r_data} : 64'h0
;assign w_wr_fifo_de   = r_de ? r_de          : r_frm_end_en
;assign o_almostfull   = w_almostfull
;


always @(posedge i_video_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1) begin
		r_vsyn					<= 'd0;
		r_hsyn					<= 'd0;
		r_data					<= 'd0;
		r_de 					<= 'd0;
	end else begin 
		r_vsyn					<= {r_vsyn[1:0],i_vsyn};
		r_hsyn					<= {r_hsyn[1:0],i_hsyn};
		r_data					<= i_video_data;
		r_de 					<= i_de;		
	end 
end		

always @(posedge i_video_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1) begin
		r_width_dly1 <= 'd0 ;
		r_heigh_dly1 <= 'd0 ;
	end else begin  
		r_width_dly1 <= i_width;
		r_heigh_dly1 <= i_heigh	;
	end 
end 

always @(posedge i_video_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1)
		r_col_cnt <= 'd0;
	else if(r_vsyn == 3'b011)
		r_col_cnt <= 'd0;
	else if((r_de == 1) && (r_col_cnt == r_width_dly1-1))
		r_col_cnt <= 'd0;
	else if(r_de == 1)
		r_col_cnt <= r_col_cnt + 1;
	else ;
end

always @(posedge i_video_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1)
		r_row_cnt <= 'd0;
	else if(r_vsyn == 3'b011)
		r_row_cnt <= 'd0;
	else if(r_de == 1 && (r_col_cnt == r_width_dly1-1))
		r_row_cnt <= r_row_cnt + 1;
	else ;
end

always @(posedge i_video_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1)
		r_frm_end_replenish_cnt <= 'd0;
	else if(r_vsyn == 3'b011)
		r_frm_end_replenish_cnt <= 'd0;
	else if(r_row_cnt == r_heigh_dly1+1)
		r_frm_end_replenish_cnt <= 'd0;
	else if(&r_frm_end_replenish_cnt)
		r_frm_end_replenish_cnt <= r_frm_end_replenish_cnt;
	else if(r_row_cnt == r_heigh_dly1)
		r_frm_end_replenish_cnt <= r_frm_end_replenish_cnt + 1;
	else ;
end

always @(posedge i_video_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1)
		r_frm_end_en <= 'd0;
	else if(r_vsyn == 3'b011)
		r_frm_end_en <= 'd0;
	else if((r_frm_end_replenish_cnt > r_width_dly1) && (r_frm_end_replenish_cnt <= r_width_dly1+'d480))
		r_frm_end_en <= 'd1;
	else
		r_frm_end_en <= 'd0;
end

fifo_w64_r64 u0_fifo_w64_r64(
 .rst                      (~i_rst_n || (r_vsyn == 3'b011) )
,.wr_clk                   (i_video_clk                    )
,.rd_clk                   (i_pcs_clk                      )
,.din                      (w_wr_fifo_data                 )
,.wr_en                    (w_wr_fifo_de & (~w_full)       )
,.rd_en                    (i_fifo_rd_en  & (~w_empty)     )
,.prog_empty_thresh_assert (10                             )
,.prog_empty_thresh_negate (12                             )
,.prog_full_thresh_assert  (480                            )
,.prog_full_thresh_negate  (479                            )
,.dout                     (o_fifo_data                    )
,.full                     (w_full                         )
,.empty                    (w_empty                        )
,.prog_full                (w_almostfull                   )
,.prog_empty               (w_almostempty                  )
);


generate 

	if(p_debug_en) begin
		
		reg  [25:0]    r_in_cnt ;   
		reg  [25:0]    r_out_cnt;
		
		always @(posedge i_video_clk or negedge i_rst_n) begin
			if(i_rst_n != 1'b1)
				r_in_cnt <= 'd0;
			else if(i_vsyn)
				r_in_cnt <= 'd0;
			else if(r_de)
				r_in_cnt <= r_in_cnt + 'd1;
			else ;
		end	

		always @(posedge i_pcs_clk or negedge i_rst_n) begin
			if(i_rst_n != 1'b1)
				r_out_cnt <= 'd0;
			else  if(i_vsyn)
				r_out_cnt <= 'd0;
			else if(i_fifo_rd_en)
				r_out_cnt <= r_out_cnt + 'd1;
			else ;
		end

		ila_128 u0_ila_128(
			 .clk    (i_video_clk)
			,.probe0 ({
				 r_in_cnt
				,r_frm_end_en
				,r_heigh_dly1
				,r_width_dly1
				,r_de
				,i_vsyn
				,r_vsyn
				,i_hsyn
				,r_row_cnt
				,r_col_cnt
				,r_frm_end_replenish_cnt
				,w_wr_fifo_de
				,w_wr_fifo_data
				,w_almostempty
				,w_almostfull
				,w_full
				,w_empty
			})
		);   
		
		ila_128 u1_ila_128(
			 .clk    (i_pcs_clk)
			,.probe0 ({
				 r_out_cnt
				,r_vsyn
				,w_almostempty
				,w_almostfull
				,w_full
				,w_empty
				,i_fifo_rd_en
				,o_fifo_data
			})
		);   

	end
endgenerate



endmodule

