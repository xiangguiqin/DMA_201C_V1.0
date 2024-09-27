module frmbuf_arb#(
 parameter p_debug_en = 0
) (
 input				        i_rst_n
,input				        i_ddr3_clk 
,input				        i_system_init

,input	     [2*  1-1:0]	i_request
,output   [2*  1-1:0]    o_response
,input	     [2*  1-1:0]	i_bust_end
,input	     [2* 27-1:0]	i_req_addr
,input	     [2*  1-1:0]	i_cmd_valid
,input	     [2*  3-1:0]	i_rdwr_cmd
,input	                    i_wr_en
,input	     [  256-1:0]    i_wr_data
,output                     o_wrfifo_rd

,output	                 o_app_en
,output	  [      2:0]    o_app_cmd
,output	  [     26:0]    o_app_addr
,output                     o_app_wdf_wren
,output	     [  256-1:0]    o_app_wdf_data

,output	           [2:0]    o_cs
,output	           [2:0]    o_ns
);

 parameter			S_idle		= 'd0
;parameter			S_ch0_req   = 'd1
;parameter		    S_ch0_proc	= 'd2
;parameter		    S_ch1_req	= 'd3
;parameter		    S_ch1_proc	= 'd4
;	

 reg    [2:0]       r_cs
;reg    [2:0]       r_ns
;

 assign o_app_wdf_wren = i_wr_en
;assign o_app_wdf_data = i_wr_data
;assign o_cs           = r_cs
;assign o_ns           = r_ns
;

always @(posedge i_ddr3_clk or negedge i_rst_n) begin
	if(i_rst_n!=1'b1)
		r_cs <= S_idle;
	else
		r_cs <= r_ns;
end

always @(*) begin
	if(i_rst_n!=1'b1)
		r_ns = S_idle;
	else if(i_system_init!=1'b1)
		r_ns = S_idle;
	else case(r_cs)
		S_idle :	
			if(i_system_init==1'b1)
				r_ns = S_ch0_req;
			else
				r_ns = S_idle;
			
		S_ch0_req :
			if(i_request[0])
				r_ns = S_ch0_proc;
			else 
				r_ns = S_ch1_req;
				
		S_ch0_proc :
			if(i_bust_end[0]==1'b1)
				r_ns = S_ch1_req;
			else
				r_ns = S_ch0_proc;
				
		S_ch1_req :
			if(i_request[1])
				r_ns = S_ch1_proc;
			else 
				r_ns = S_ch0_req;
		
		S_ch1_proc :
			if(i_bust_end[1]==1'b1)
				r_ns = S_ch0_req;
			else
				r_ns = S_ch1_proc;
		
		default:r_ns = S_idle;
	endcase
end




 assign o_response = (r_cs == S_ch0_proc) ? 2'b01 : ((r_cs == S_ch1_proc) ? 2'b10 : 2'b00)
;assign o_app_en   = (r_cs == S_ch0_proc) ? i_cmd_valid[0] : ((r_cs == S_ch1_proc) ? i_cmd_valid[1] : 'b0)
;assign o_app_cmd  = (r_cs == S_ch0_proc) ? i_rdwr_cmd[1*3-1:0*3] : ((r_cs == S_ch1_proc) ? i_rdwr_cmd[2*3-1:1*3] : 'b0)
;assign o_app_addr = (r_cs == S_ch0_proc) ? i_req_addr[1*27-1:0*27] :  i_req_addr[2*27-1:1*27]
;


/* always @(*) begin
	if(i_rst_n!=1'b1)begin
		o_response = 2'b00					;
		o_app_en   = 1'b0                   ;
		o_app_cmd  = 3'b0                   ;
		o_app_addr = 27'b0                  ;
	end else case(r_cs)
		S_ch0_proc	: begin
			o_response = 2'b01					;
			o_app_en   = i_cmd_valid[0]			;
			o_app_cmd  = i_rdwr_cmd[1*3-1:0*3]	;
			o_app_addr = i_req_addr[1*27-1:0*27];
		end
		
		S_ch1_proc	: begin
			o_response = 2'b10					;
			o_app_en   = i_cmd_valid[1]			;
			o_app_cmd  = i_rdwr_cmd[2*3-1:1*3]  ;
			o_app_addr = i_req_addr[2*27-1:1*27];
		end
		
		default: begin
			o_response = 2'b00					;
			o_app_en   = 1'b0                   ;
			o_app_cmd  = 3'b0                   ;
			o_app_addr = 27'b0                  ;
		end
	endcase
end */



/* generate
	if(p_debug_en) begin
	
		ila_0 uarb_ila_0(
		 .clk    (i_ddr3_clk)
		,.probe0 ({
				 i_request
				,i_bust_end
				,o_response
				,o_app_en
				,o_app_cmd
				,o_app_addr
				,r_cs
				,r_ns
				,i_wr_en
				,i_wr_data
				,o_app_wdf_wren
				,o_app_wdf_data
				,i_rdwr_cmd
				,i_cmd_valid
				,i_req_addr
				,i_system_init
			})
		);
	end
endgenerate */



endmodule 	
	