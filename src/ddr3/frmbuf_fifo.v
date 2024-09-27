module frmbuf_fifo #(
 parameter p_debug_en = 0
) (
 input  		i_rst_n
,input 		 	i_ddr3_clk

,input 		 	i_src_clk         
,input 		 	i_src_vsyn    
,input 		 	i_src_de    
,input  [23:0]	i_src_data

,input			i_wrfifo_rst
,output			o_wrfifo_almost_empty
,input			i_wrfifo_rd_en
,output	[255:0] o_wrfifo_data

,input			i_rdfifo_rst
,output			o_rdfifo_almost_full
,input			i_rdfifo_wr_en
,input	[255:0] i_rdfifo_data

,input			i_dst_clk
,input			i_dst_vsyn
,input			i_rdfifo_rd_en
,output			o_dst_de
,output	[23:0]	o_rdfifo_data
);
 reg r_src_vsyn
;reg r_src_vsyn_pos
;reg r_dst_vsyn
;reg r_dst_vsyn_pos
;reg r_in_rst
;reg r_out_rst
;reg r_dst_de

;
 wire 	[31:0]	w_in_data			
;wire 			w_in_wr_clk       
;wire 			w_in_rd_clk       
;wire 			w_in_wr_en          
;wire 			w_in_rd_en          
;wire 			w_in_rst
;wire 	[255:0]	w_in_Q
;wire 			w_in_empty
;wire 			w_in_full
;wire 			w_in_almost_empty
;wire 			w_in_almost_full
;
 wire 	[255:0]	w_out_data			
;wire 			w_out_wr_clk       
;wire 			w_out_rd_clk       
;wire 			w_out_wr_en          
;wire 			w_out_rd_en          
;wire 			w_out_rst
;wire 	[31:0]	w_out_Q             
;wire 			w_out_empty         
;wire 			w_out_full          
;wire 			w_out_almost_empty   
;wire 			w_out_almost_full      
;



assign o_dst_de = r_dst_de;

always @(posedge i_src_clk or negedge i_rst_n) begin
	if(i_rst_n != 1)
		r_src_vsyn <= 1'b0;
	else
		r_src_vsyn <= i_src_vsyn;
end

always @(posedge i_src_clk or negedge i_rst_n) begin
	if(i_rst_n != 1)
		r_src_vsyn_pos <= 1'b0;
	else if(r_src_vsyn == 1 && i_src_vsyn == 0)
		r_src_vsyn_pos <= 1'b1;
	else 
		r_src_vsyn_pos <= 1'b0;
end

always @(posedge i_dst_clk or negedge i_rst_n) begin
	if(i_rst_n != 1)
		r_dst_vsyn <= 1'b0;
	else
		r_dst_vsyn <= i_dst_vsyn;
end

always @(posedge i_dst_clk or negedge i_rst_n) begin
	if(i_rst_n != 1)
		r_dst_de <= 1'b0;
	else
		r_dst_de <= i_rdfifo_rd_en;
end

always @(posedge i_dst_clk or negedge i_rst_n) begin
	if(i_rst_n != 1)
		r_dst_vsyn_pos <= 1'b0;
	else if(r_dst_vsyn == 1 && i_dst_vsyn == 0)
		r_dst_vsyn_pos <= 1'b1;
	else 
		r_dst_vsyn_pos <= 1'b0;
end

always @(posedge i_ddr3_clk or negedge i_rst_n) begin
	if(i_rst_n != 1)
		r_in_rst <= 1'b0;
	else
		r_in_rst <= i_wrfifo_rst;
end

always @(posedge i_ddr3_clk or negedge i_rst_n) begin
	if(i_rst_n != 1)
		r_out_rst <= 1'b0;
	else
		r_out_rst <= i_rdfifo_rst;
end


//---------------------------------------------------------------
 assign w_in_data 		      = {8'd0,i_src_data}
;assign w_in_wr_clk           = i_src_clk
;assign w_in_rd_clk           = i_ddr3_clk
;assign w_in_wr_en		      = i_src_de && (~w_in_full)
;assign w_in_rd_en            = i_wrfifo_rd_en && (~w_in_empty)
;assign w_in_rst              = r_src_vsyn_pos
;                             
 assign o_wrfifo_data		  = w_in_Q
;assign o_wrfifo_almost_empty = w_in_almost_empty 
;

frmbuf_wr_fifo u0_frmbuf_wr_fifo(
 .din					  (w_in_data         )
,.wr_clk       			  (w_in_wr_clk       )
,.rd_clk       			  (w_in_rd_clk       )
,.wr_en          		  (w_in_wr_en        )
,.rd_en          		  (w_in_rd_en        )
,.rst           		  (w_in_rst          )
,.dout             		  (w_in_Q            )
,.empty         		  (w_in_empty        )
,.full          		  (w_in_full         )
,.prog_empty   			  (w_in_almost_empty )
,.prog_full               (w_in_almost_full  )
,.prog_empty_thresh_assert('d31              )
,.prog_empty_thresh_negate('d31              )
,.prog_full_thresh_assert ('d800             )
,.prog_full_thresh_negate ('d800             )
);

//---------------------------------------------------------------
 assign w_out_data            = i_rdfifo_data
;assign w_out_wr_clk          = i_ddr3_clk
;assign w_out_rd_clk          = i_dst_clk
;assign w_out_wr_en           = i_rdfifo_wr_en && (~w_out_full)
;assign w_out_rd_en           = i_rdfifo_rd_en && (~w_out_empty)
;assign w_out_rst             = r_dst_vsyn_pos
;assign o_rdfifo_data         = w_out_Q[23:0]
;assign o_rdfifo_almost_full  = w_out_almost_full
;

frmbuf_rd_fifo u0_frmbuf_rd_fifo(
 .din					  (w_out_data         )
,.wr_clk       			  (w_out_wr_clk       )
,.rd_clk       			  (w_out_rd_clk       )
,.wr_en          		  (w_out_wr_en        )
,.rd_en          		  (w_out_rd_en        )
,.rst           		  (w_out_rst          )
,.dout             		  (w_out_Q            )
,.empty         		  (w_out_empty        )
,.full          		  (w_out_full         )
,.prog_empty   			  (w_out_almost_empty )
,.prog_full               (w_out_almost_full  )
,.prog_empty_thresh_assert('d32               )
,.prog_empty_thresh_negate('d32               )
,.prog_full_thresh_assert ('d800              )
,.prog_full_thresh_negate ('d800              )
);



/* generate
	if(p_debug_en) begin
	
		reg [23:0] r_in_src_cnt   ;
		reg [23:0] r_out_dst_cnt  ;
		reg [23:0] r_in_cnt       ;
		reg [23:0] r_out_cnt      ;
		reg        r_in_unequ     ;
		reg        r_out_unequ    ;
		
		always @(posedge i_src_clk or negedge i_rst_n) begin
			if(i_rst_n != 1)
				r_in_src_cnt <= 'd0;
			else if(r_src_vsyn_pos)
				r_in_src_cnt <= 'd0;
			else if(w_in_wr_en)
				r_in_src_cnt <= r_in_src_cnt + 1;
			else ;
		end
		
		always @(posedge i_src_clk or negedge i_rst_n) begin
			if(i_rst_n != 1)
				r_in_unequ <= 'd0;
			else if(r_src_vsyn_pos)
				r_in_unequ <= 'd0;
			else if(w_in_wr_en && ((r_in_src_cnt+1) != w_in_data))
				r_in_unequ <= 'd1;
			else ;
		end
		
		always @(posedge i_dst_clk or negedge i_rst_n) begin
			if(i_rst_n != 1)
				r_out_dst_cnt <= 'd0;
			else if(r_dst_vsyn_pos)
				r_out_dst_cnt <= 'd0;
			else if(w_out_rd_en)
				r_out_dst_cnt <= r_out_dst_cnt + 1;
			else ;
		end
		
		always @(posedge i_dst_clk or negedge i_rst_n) begin
			if(i_rst_n != 1)
				r_out_unequ <= 'd0;
			else if(r_dst_vsyn_pos)
				r_out_unequ <= 'd0;
			else if(w_out_rd_en && (r_out_dst_cnt != w_out_Q))
				r_out_unequ <= 'd1;
			else ;
		end
		
		always @(posedge i_ddr3_clk or negedge i_rst_n) begin
			if(i_rst_n != 1)
				r_in_cnt <= 'd0;
			else if(r_in_rst)
				r_in_cnt <= 'd0;
			else if(w_in_rd_en)
				r_in_cnt <= r_in_cnt + 1;
			else ;
		end
		
		always @(posedge i_ddr3_clk or negedge i_rst_n) begin
			if(i_rst_n != 1)
				r_out_cnt <= 'd0;
			else if(r_out_rst)
				r_out_cnt <= 'd0;
			else if(w_out_wr_en)
				r_out_cnt <= r_out_cnt + 1;
			else ;
		end
		
		
		
		ila_128 usrc_ila_128(
		 .clk    (i_src_clk)
		,.probe0 ({
				 w_in_rst
				,r_src_vsyn
				,r_src_vsyn_pos
				,i_src_de
				,w_in_wr_en
				,r_in_unequ
				,w_in_data
				,w_in_empty
				,w_in_full
				,w_in_almost_empty
				,w_in_almost_full
				,r_in_src_cnt
			})
		);
		
		ila_128 udst_ila_128(
		 .clk    (i_dst_clk)
		,.probe0 ({
				 w_out_rst
				,r_dst_vsyn
				,r_dst_vsyn_pos
				,o_dst_de
				,i_rdfifo_rd_en
				,w_out_rd_en
				,r_out_unequ
				,w_out_Q
				,w_out_empty
				,w_out_full
				,w_out_almost_empty
				,w_out_almost_full
				,r_out_dst_cnt
				
			})
		);
		
		ila_0 uddr_ila_0(
		 .clk    (i_ddr3_clk)
		,.probe0 ({
				 w_in_rst
				,r_in_rst
				,w_in_rd_en
				,i_wrfifo_rd_en
				,w_in_Q
				,w_in_empty
				,w_in_full
				,w_in_almost_empty
				,w_in_almost_full
				,r_in_cnt
				
				,w_out_rst
				,r_out_rst
				,w_out_wr_en
				,i_rdfifo_wr_en
				,w_out_data
				,w_out_full
				,w_out_empty
				,w_out_almost_empty
				,w_out_almost_full
				,r_out_cnt
			})
		);
	end
endgenerate */



endmodule 


