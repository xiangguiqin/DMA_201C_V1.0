module frmbuf_rd #(
 parameter p_debug_en = 0
) (
 input				i_rst_n
,input				i_ddr3_clk 
,input				i_system_init
//================================================
,input				i_dst_vsync
,input				i_fifo_almost_full
,output				o_fifo_rst
//================================================
,input				i_response
,output	reg			o_request
,output             o_app_en
,output      [2:0]  o_app_cmd
,output	reg  [26:0]	o_addr
,output	reg         o_bust_end
//=================================================
,input              i_app_rdy
,input				i_app_rd_data_valid
,input       [26:0] i_addr_inital
//-----------------------------------------------------------------
,output				o_rd_busy

,input	      [255:0]i_app_rd_data
,output	      [2:0] o_cs
,output	      [2:0] o_ns
);

 parameter			S_idle 		= 'd0
;parameter			S_sate_buf	= 'd1
;parameter			S_arb_req	= 'd2	
;parameter			S_data_rd	= 'd3
;parameter			S_rd_eop	= 'd4
;
 parameter			p_rd_num    = 'd32
;parameter			p_addr_add	= 'd8
;

 reg	[2:0]		r_cs	
;reg	[2:0]		r_ns	
;
 reg	[9:0]	r_dst_vsync			
;reg			r_dst_sync_pos
;reg	 		r_app_en
;reg	 		r_rd_req
;reg	[9:0]	r_addr_number
;reg	[9:0]	r_read_number
;

 assign o_app_en   = r_app_en && i_app_rdy
;assign o_fifo_rst = r_dst_sync_pos
;assign o_app_cmd  = 3'd1
;assign o_cs       = r_cs
;assign o_ns       = r_ns
;

//----------------------------------------------------------------------------
always @(posedge i_ddr3_clk or negedge i_rst_n) begin
	if (i_rst_n!=1'b1)
		r_dst_vsync <= 'd0;
	else 
		r_dst_vsync <= {r_dst_vsync[8:0],i_dst_vsync};
end

always @(posedge i_ddr3_clk or negedge i_rst_n) begin
	if(i_rst_n!=1'b1)
		r_dst_sync_pos <= 'd0;
	else if(r_dst_vsync[9:8] == 2'b10)	
		r_dst_sync_pos <= 'd1;
	else 
		r_dst_sync_pos <= 'd0;
end
//----------------------------------------------------------------------------
always @(posedge i_ddr3_clk or negedge i_rst_n) begin
	if(i_rst_n!=1'b1)
		r_cs <= S_idle;
	else 
		r_cs <= r_ns;
end

always @(*) begin
	if (i_rst_n!=1'b1)
		r_ns = S_idle;
	else if(r_dst_sync_pos)
		r_ns = S_idle;
	else case(r_cs)
		S_idle :
			if(i_system_init == 1'b1)
				r_ns = S_sate_buf;
			else 
				r_ns = S_idle;
		
		S_sate_buf :
			if(~i_fifo_almost_full)
				r_ns = S_arb_req;
			else 
				r_ns = S_sate_buf;
	
		S_arb_req :
			if(i_response == 1'b1)
				r_ns = S_data_rd;
			else 
				r_ns = S_arb_req;
				
		S_data_rd :
			if(r_read_number == p_rd_num)
				r_ns = S_rd_eop;
			else 
				r_ns = S_data_rd;
				
		S_rd_eop  :
			r_ns = S_idle;
			
		default:
			r_ns = S_idle;
	endcase
end

//------------------------------------------------------------------
always @(posedge i_ddr3_clk or negedge i_rst_n) begin
	if(i_rst_n!=1'b1)
		o_request <= 'd0;
	else if(r_ns == S_arb_req)	
		o_request <= 'd1;
	else 
		o_request <= 'd0;
end

always @(posedge i_ddr3_clk or negedge i_rst_n) begin
	if(i_rst_n!=1'b1)		
		r_app_en <= 'd0;
	else if(r_ns == S_data_rd)
		if(r_addr_number==p_rd_num)
			r_app_en <= 'd0;
		else if(r_addr_number==p_rd_num-1 && i_app_rdy)
			r_app_en <= 'd0;
		else
			r_app_en <= 'd1;
	else
		r_app_en <= 'd0;
end

always @(posedge i_ddr3_clk or negedge i_rst_n) begin
	if(i_rst_n!=1'b1)
		 r_addr_number <= 'd0;
	else if(r_ns == S_data_rd) 
		if(r_app_en && i_app_rdy)
			r_addr_number <= r_addr_number + 1'b1;
		else;
	else 
		r_addr_number <= 'd0;
end
		
//-----------------------------------------------------------------
always @(posedge i_ddr3_clk or negedge i_rst_n) begin
	if(i_rst_n!=1'b1)	
		o_addr <= 'd0;
	else if(r_dst_sync_pos == 1'b1)
		o_addr <= i_addr_inital;
	else if(r_app_en && i_app_rdy)
		o_addr <= o_addr + p_addr_add;
	else ;
end

always @(posedge i_ddr3_clk or negedge i_rst_n) begin
	if(i_rst_n!=1'b1)
		o_bust_end <= 'd0;
	else if(r_ns==S_rd_eop)
		o_bust_end <= 'd1;
	else 
		o_bust_end <= 'd0;
end

always @(posedge i_ddr3_clk or negedge i_rst_n) begin
	if(i_rst_n!=1'b1)
		 r_read_number <= 'd0;
	else if(r_ns == S_data_rd) 
		if(i_app_rd_data_valid==1'b1)
			r_read_number <= r_read_number + 1'b1;
		else;
	else 
		r_read_number <= 'd0;
end

assign o_rd_busy = (r_cs==S_data_rd)? 1 : 0 ;


/* generate
	if(p_debug_en) begin
		reg [31:0] r_rdddr_cnt;
		reg        r_unequ    ;
		always @(posedge i_ddr3_clk or negedge i_rst_n) begin
			if(i_rst_n!=1'b1)
				r_rdddr_cnt <= 'd0;
			else if(r_dst_sync_pos)
				r_rdddr_cnt <= 'd0;
			else if(i_app_rd_data_valid)
				r_rdddr_cnt <= r_rdddr_cnt + 'd8;
			else ;
		end
		
		always @(posedge i_ddr3_clk or negedge i_rst_n) begin
			if(i_rst_n != 1)
				r_unequ <= 'd0;
			else if(r_dst_sync_pos)
				r_unequ <= 'd0;
			else if(i_app_rd_data_valid && ((r_rdddr_cnt+8) != i_app_rd_data[31:0]))
				r_unequ <= 'd1;
			else ;
		end
		
		ila_512 urd_ila_512(
		 .clk    (i_ddr3_clk)
		,.probe0 ({
				 i_app_rdy
				,o_app_en
				,r_app_en
				,i_app_rd_data_valid
				,i_app_rd_data
				,r_unequ
				,r_cs
				,r_ns
				,r_dst_sync_pos
				,o_bust_end
				,o_request
				,i_response
				,i_fifo_almost_full
				,i_system_init
				,r_rdddr_cnt
				,r_read_number
				,o_addr
				,r_addr_number
			})//512
		);
	end
endgenerate */





endmodule 