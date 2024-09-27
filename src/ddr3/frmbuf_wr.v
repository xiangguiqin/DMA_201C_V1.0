module frmbuf_wr #(
 parameter p_debug_en = 0
)(
 input                 i_rst_n
,input                 i_ddr3_clk
,input                 i_system_init 
,input                 i_src_vsyn
,input                 i_fifo_almost_empty
,output                o_fifo_rst
                       
,output reg            o_request
,input                 i_response
,output                o_app_en
,output	     [2:0]     o_app_cmd
,output reg  [26:0]    o_addr
,output reg            o_bust_end
                       
,input                 i_app_rdy
,input                 i_app_wdf_rdy
,output                o_app_wdf_wren
,input	     [26:0]    i_addr_inital
,output                o_fifo_rd
,output                o_wr_busy

,input	      [255:0]  i_wrfifo_data
,output	      [2:0]    o_cs
,output	      [2:0]    o_ns
);

 parameter			S_idle 		= 'd0
;parameter			S_sate_buf	= 'd1
;parameter			S_arb_req   = 'd2
;parameter			S_fifo_rd	= 'd3
;parameter			S_data_wr	= 'd4
;
 parameter			p_wr_num    = 'd32
;parameter			p_addr_add	= 'd8 // 'd256/'d32
;

 reg	[2:0]		r_cs
;reg	[2:0]		r_ns
;

 reg	[9:0]	    r_src_vsyn			
;reg			    r_src_vsyn_pos
;reg			    r_app_en
;reg			    r_app_wdf_wren
;reg	[9:0]	    r_write_number
;


 assign o_app_en       = r_app_en && i_app_rdy && i_app_wdf_rdy
;assign o_app_wdf_wren = r_app_wdf_wren && i_app_rdy && i_app_wdf_rdy
;assign o_fifo_rst     = r_src_vsyn_pos	
;assign o_app_cmd      = 3'd0
;assign o_fifo_rd      = (r_cs==S_fifo_rd) || (i_app_rdy && i_app_wdf_rdy && r_app_wdf_wren && (r_write_number<p_wr_num-1))
;assign o_cs           = r_cs
;assign o_ns           = r_ns
;

always @(posedge i_ddr3_clk or negedge i_rst_n) begin
	if (i_rst_n!=1'b1)
		r_src_vsyn <= 'd0;
	else 
		r_src_vsyn <= {r_src_vsyn[8:0],i_src_vsyn};
end		

always @(posedge i_ddr3_clk or negedge i_rst_n)begin
	if (i_rst_n!=1'b1)
		r_src_vsyn_pos <= 'd0;
	else if(r_src_vsyn[9:8]==2'b10)	
		r_src_vsyn_pos <= 'd1;
	else 
		r_src_vsyn_pos <= 'd0;
end				
//----------------------------------------------------------------------------
always @(posedge i_ddr3_clk or negedge i_rst_n) begin
	if(i_rst_n!=1'b1)
		r_cs <= S_idle;
	else 
		r_cs <= r_ns;
end

always @(*) begin
	if(i_rst_n!=1'b1)
		r_ns = S_idle;
	else if(r_src_vsyn_pos==1'b1)
		r_ns = S_idle;
	else case(r_cs)
		S_idle     :	
			if(i_system_init==1'b1)
				r_ns = S_sate_buf;
			else 
				r_ns = S_idle;
		S_sate_buf :
			if(~i_fifo_almost_empty)
				r_ns = S_arb_req;
			else 
				r_ns = S_sate_buf;
		S_arb_req  :
			if(i_response==1'b1)
				r_ns = S_fifo_rd;
			else
				r_ns = S_arb_req;
		S_fifo_rd  :
				r_ns = S_data_wr;
		S_data_wr  :
			if(r_write_number == p_wr_num-1 && i_app_rdy && i_app_wdf_rdy)
				r_ns = S_idle;
			else 
				r_ns = S_data_wr;
		default    :
			r_ns = S_idle;
	endcase
end

//----------------------------------------------------------------------------	
always @(posedge i_ddr3_clk or negedge i_rst_n) begin
	if(i_rst_n!=1'b1)
		o_request <= 'd0;
	else if(r_cs == S_arb_req)
		o_request <= 'd1;
	else 
		o_request <= 'd0;
end

always @(posedge i_ddr3_clk or negedge i_rst_n) begin
	if(i_rst_n!=1'b1)		
		r_app_en <= 'd0;
	else if(r_cs == S_data_wr)
		if(i_app_rdy && i_app_wdf_rdy && r_write_number==p_wr_num-1)
			r_app_en <= 'd0;
		else
			r_app_en <= 'd1;
	else
		r_app_en <= 'd0;
end

always @(posedge i_ddr3_clk or negedge i_rst_n) begin
	if(i_rst_n!=1'b1)	
		o_addr <= 'd0;
	else if(r_src_vsyn_pos == 1'b1)
		o_addr <= i_addr_inital;
	else if(r_app_en && i_app_rdy && i_app_wdf_rdy)
		o_addr <= o_addr + p_addr_add;
	else ;
end

always @(posedge i_ddr3_clk or negedge i_rst_n) begin
	if(i_rst_n!=1'b1)
		o_bust_end <= 'd0;
	else if(r_write_number==p_wr_num-1 && r_cs==S_data_wr && i_app_rdy && i_app_wdf_rdy)
		o_bust_end <= 'd1;
	else 
		o_bust_end <= 'd0;
end

always @(posedge i_ddr3_clk or negedge i_rst_n) begin
	if(i_rst_n!=1'b1)
		r_write_number <= 'd0;
	else if(r_ns == S_data_wr)
		if(i_app_rdy && i_app_wdf_rdy && r_app_wdf_wren)
			r_write_number <= r_write_number + 1'b1;
		else ;
	else 
		r_write_number <= 'd0;
end

always @(posedge i_ddr3_clk or negedge i_rst_n) begin
	if(i_rst_n!=1'b1)
		r_app_wdf_wren <= 'd0;
	else if(r_cs == S_data_wr)
		if(i_app_rdy && i_app_wdf_rdy && r_write_number==p_wr_num-1)
			r_app_wdf_wren <= 'd0;
		else
			r_app_wdf_wren <= 'd1;
	else
		r_app_wdf_wren <= 'd0;
end

/* generate
	if(p_debug_en) begin
		
		reg [31:0] r_wrddr_cnt;
		reg        r_unequ    ;
		always @(posedge i_ddr3_clk or negedge i_rst_n) begin
			if(i_rst_n!=1'b1)
				r_wrddr_cnt <= 'd0;
			else if(r_src_vsyn_pos)
				r_wrddr_cnt <= 'd0;
			else if(i_app_rdy && i_app_wdf_rdy && r_app_wdf_wren)
				r_wrddr_cnt <= r_wrddr_cnt + 'd8;
			else ;
		end
		
		always @(posedge i_ddr3_clk or negedge i_rst_n) begin
			if(i_rst_n != 1)
				r_unequ <= 'd0;
			else if(r_src_vsyn_pos)
				r_unequ <= 'd0;
			else if(i_app_rdy && i_app_wdf_rdy && r_app_wdf_wren && ((r_wrddr_cnt+8) != i_wrfifo_data[31:0]))
				r_unequ <= 'd1;
			else ;
		end

		ila_512 uwr_ila_512(
		 .clk    (i_ddr3_clk)
		,.probe0 ({
				 i_app_rdy
				,o_app_en
				,r_app_en
				,i_app_wdf_rdy
				,o_app_wdf_wren
				,r_app_wdf_wren
				,i_wrfifo_data
				,r_unequ
				,r_cs
				,r_ns
				,r_src_vsyn_pos
				,o_bust_end
				,o_request
				,i_response
				,i_fifo_almost_empty
				,i_system_init
				,r_wrddr_cnt
				,r_write_number
				,o_addr
				,o_fifo_rd
			})//512
		);
	end
endgenerate */


endmodule 





	

