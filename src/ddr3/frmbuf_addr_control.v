module frmbuf_addr_control(
 input 				i_rst_n
,input				i_ddr3_clk 
,input				i_src_valid
,input				i_src_vsyn
,input				i_dst_vsyn
,output	[26:0]		o_wr_addr_inital
,output	[26:0]		o_rd_addr_inital
);

reg	[26:0]	r_ch0_addr_inital  ;
reg	[26:0]	r_ch1_addr_inital  ;

reg [1:0]   r_wr_frm_cnt       ;
reg [1:0]   r_rd_frm_cnt       ;

reg         r_src_vsyn_pos_dly0;
reg         r_src_vsyn_pos_dly1;
reg         r_dst_vsyn_pos_dly0;
reg         r_dst_vsyn_pos_dly1;

wire        w_src_vsyn_pos     ;
wire        w_dst_vsyn_pos     ;

/***************************************************************************/
reg			rSrcFrmValidRise	;
reg			r_src_valid		    ;
reg			r_src_valid_dly0	;
reg			r_src_vsyn_temp1	;
reg			r_src_vsyn_temp2	;
reg			r_src_vsyn_temp3	;
reg			r_dst_vsyn_temp1	;
reg			r_dst_vsyn_temp2	;
reg			r_dst_vsyn_temp3	;

always @(posedge i_ddr3_clk or negedge i_rst_n) begin
	if(i_rst_n!=1'b1) begin
		r_src_vsyn_temp1  <= 'd0;
	    r_src_vsyn_temp2  <= 'd0;
	    r_src_vsyn_temp3  <= 'd0;
		r_dst_vsyn_temp1  <= 'd0;
        r_dst_vsyn_temp2  <= 'd0;
        r_dst_vsyn_temp3  <= 'd0;
        r_src_valid       <= 'd0;
        r_src_valid_dly0  <= 'd0;
	end else begin
		r_src_vsyn_temp1  <= i_src_vsyn		    ;
	    r_src_vsyn_temp2  <= r_src_vsyn_temp1	;
	    r_src_vsyn_temp3  <= r_src_vsyn_temp2	;
		r_dst_vsyn_temp1  <= i_dst_vsyn		;
        r_dst_vsyn_temp2  <= r_dst_vsyn_temp1	;
        r_dst_vsyn_temp3  <= r_dst_vsyn_temp2	;
		r_src_valid       <= i_src_valid        ;
        r_src_valid_dly0  <= r_src_valid        ;
	end	
end		


/***************************************************************************/

always @(posedge i_ddr3_clk or negedge i_rst_n) begin
	if(i_rst_n!=1'b1) begin
		r_src_vsyn_pos_dly0 <= 1'd0	;
		r_src_vsyn_pos_dly1 <= 1'd0	;
		r_dst_vsyn_pos_dly0 <= 1'd0	;
		r_dst_vsyn_pos_dly1 <= 1'd0	;
	end else begin
		r_src_vsyn_pos_dly0 <= w_src_vsyn_pos		;
		r_src_vsyn_pos_dly1 <= r_src_vsyn_pos_dly0	;
		r_dst_vsyn_pos_dly0 <= w_dst_vsyn_pos		;
		r_dst_vsyn_pos_dly1 <= r_dst_vsyn_pos_dly0	;
	end
end

always @(posedge i_ddr3_clk or negedge i_rst_n) begin
	if(i_rst_n!=1'b1)
		r_wr_frm_cnt <= 2'd0;
	else if((r_src_vsyn_pos_dly0 == 1'b1) && (r_src_valid_dly0 == 1'b1))
		r_wr_frm_cnt <= r_wr_frm_cnt + 2'd1;
	else ;
end

always @(posedge i_ddr3_clk or negedge i_rst_n) begin
	if(i_rst_n!=1'b1)
		r_rd_frm_cnt <= 2'd2;
	else if(r_dst_vsyn_pos_dly0 == 1'b1)
		r_rd_frm_cnt <= r_wr_frm_cnt - 2'd2;
	else ;
end


always @(posedge i_ddr3_clk or negedge i_rst_n) begin
	if(i_rst_n!=1'b1)
		r_ch0_addr_inital <= 27'd0	;
	else if(r_src_vsyn_pos_dly1 == 1'b1)
		r_ch0_addr_inital <= {r_wr_frm_cnt,23'b0};
		//r_ch0_addr_inital <= r_wr_frm_cnt*1920*1080*32/32;
	else ;
end

always @(posedge i_ddr3_clk or negedge i_rst_n) begin
	if(i_rst_n!=1'b1)
		r_ch1_addr_inital <= 27'd0;
	else if(r_dst_vsyn_pos_dly1 == 1'b1)
		r_ch1_addr_inital <= {r_rd_frm_cnt,23'b0};
		//r_ch1_addr_inital <= r_rd_frm_cnt*1920*1080*32/32 + 0;
	else ;
end

assign o_wr_addr_inital      = r_ch0_addr_inital;
assign o_rd_addr_inital      = r_ch1_addr_inital;

assign w_src_vsyn_pos = (r_src_vsyn_temp3 == 1'b1) && (r_src_vsyn_temp2 == 1'b0);
assign w_dst_vsyn_pos = (r_dst_vsyn_temp3 == 1'b1) && (r_dst_vsyn_temp2 == 1'b0);



endmodule 


