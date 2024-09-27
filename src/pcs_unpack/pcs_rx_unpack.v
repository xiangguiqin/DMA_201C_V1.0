module pcs_rx_unpack #(
 parameter p_debug_en = 0
) (
 input 				 i_rst_n	
,input				 i_pcs_clk

,input		 		 i_data_valid
,input		 		 i_pcs_head
,input	     [63:0]  i_pcs_data
,output		 		 o_data_rd_en
,input		 		 i_empty
,output		 		 o_syn

,output	reg  		 o_video_vsyn
,output	reg  		 o_video_de
,output	reg  [63:0]  o_video_data

,output	reg	 	     o_video_lock
,output reg  [ 7:0]	 o_resolution 
,output reg  [12:0]	 o_vs_total_num		 
,output reg  [12:0]	 o_hs_total_num 
,output reg  [12:0]	 o_vsyn_num 
,output reg  [12:0]	 o_hsyn_num 
,output reg  [12:0]	 o_video_start_pixel 
,output reg  [12:0]	 o_video_end_pixel 
,output reg  [12:0]	 o_video_start_H 
,output reg  [12:0]	 o_video_end_H 	

,output	reg	 		 o_uart_en
,output	     [31:0]  o_uart_data
,output	reg	 		 o_audio0_en
,output	     [63:0]	 o_audio0_data
,output	reg	 		 o_audio1_en
,output	     [63:0]	 o_audio1_data
);
//`define VedioS 'd4
//`define VedioLEN 'd480
//`define TOTALLEN 'd528
//`define VALID 'd512
`define VedioS 'd8
`define VedioLEN 'd480
`define TOTALLEN 'd528
`define VALID 'd512

reg    [11:0]    r_unpack_cnt    ;
reg    [19:0]    r_syn_cnt       ;
reg    [7:0]     r_check_sum     ;

reg    [63:0]    r_auxi_data     ;
reg    [63:0]    r_video_ready   ;
reg    [7:0]     r_resolution    ;
reg    [9:0]     r_para_bit_map  ;
reg    [13:0]    r_para          ;


assign o_syn 		 = &r_syn_cnt           ;
assign o_audio0_data = r_auxi_data          ;
assign o_audio1_data = r_auxi_data          ;
assign o_uart_data	 = r_auxi_data[31:0]    ;

assign o_data_rd_en  = r_unpack_cnt < `VALID;
//-------------------------------------------------------------------------------
always @(posedge i_pcs_clk or negedge i_rst_n) begin
	if(i_rst_n!=1'b1)
		o_video_de <= 'd0;
	else if(r_video_ready==1 && r_unpack_cnt>`VedioS && (r_unpack_cnt <= `VedioS+`VedioLEN))
		o_video_de <= 'd1;
	else
		o_video_de <= 'd0;
end	

always @(posedge i_pcs_clk or negedge i_rst_n) begin
	if(i_rst_n!=1'b1)
		o_video_vsyn <= 'h0;
	else if(r_unpack_cnt==3 && o_syn==1)
		o_video_vsyn <= i_pcs_data[4];
	else if(o_syn == 0)
		o_video_vsyn <= 'h0;
	else ;
end

always @(posedge i_pcs_clk or negedge i_rst_n) begin
	if(i_rst_n!=1'b1)
		r_video_ready <= 'h0;
	else if(r_unpack_cnt==3 && o_syn==1)
		r_video_ready <= i_pcs_data[3];
	else if(o_syn == 0)
		r_video_ready <= 'h0;
	else ;
end

always @(posedge i_pcs_clk or negedge i_rst_n) begin
	if(i_rst_n!=1'b1)
		o_uart_en <= 'h0;
	else if(r_unpack_cnt==3 && o_syn==1)
		o_uart_en <= i_pcs_data[0];
	else if(o_syn == 0)
		o_uart_en <= 'h0;
	else ;
end

always @(posedge i_pcs_clk or negedge i_rst_n) begin
	if(i_rst_n!=1'b1)
		o_audio0_en <= 'h0;
	else if(r_unpack_cnt==3 && o_syn==1)
		o_audio0_en <= i_pcs_data[1];
	else if(o_syn == 0)
		o_audio0_en <= 'h0;
	else ;
end

always @(posedge i_pcs_clk or negedge i_rst_n) begin
	if(i_rst_n!=1'b1)
		o_audio1_en <= 'h0;
	else if(r_unpack_cnt==3 && o_syn==1)
		o_audio1_en <= i_pcs_data[2];
	else if(o_syn == 0)
		o_audio1_en <= 'h0;
	else ;
end


always @(posedge i_pcs_clk or negedge i_rst_n) begin
	if(i_rst_n!=1'b1) begin
		o_video_data <= 'd0;
		r_auxi_data  <= 'd0;
	end else begin
		o_video_data <= i_pcs_data[63:0];
		r_auxi_data  <= i_pcs_data;
	end
end

always @(posedge i_pcs_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1) begin
		o_video_lock   <= 'h0;
		r_resolution   <= 'h0;
		r_para_bit_map <= 'h0;
	end else if(r_unpack_cnt==2 && o_syn==1) begin
		o_video_lock   <= i_pcs_data[8];
		r_resolution   <= i_pcs_data[7:0];
		r_para_bit_map <= i_pcs_data[18:9];
	end else if(o_syn == 0) begin
		o_video_lock   <= 'd0;
		r_resolution   <= 'd0;
		r_para_bit_map <= 'd0;
	end else ;
end	

always @(posedge i_pcs_clk or negedge i_rst_n) begin
	if (i_rst_n!=1'b1)
		r_para <= 'h0;
	else if(r_unpack_cnt==3 && o_syn==1)
		r_para <= i_pcs_data[20:5];
	else if(o_syn == 0)
		r_para <= 'h0;
	else ;
end

/* always @(posedge i_pcs_clk or negedge i_rst_n)begin
	if(i_rst_n != 1'b1)
		r_check_sum <= 8'd0;
	else if(i_pcs_head==1'b1 && i_pcs_data[15:0]=='hfb)
		r_check_sum <= 8'd0;
	else if(r_unpack_cnt < `VALID )
		r_check_sum <= r_check_sum + i_pcs_data[63:56]+
									 i_pcs_data[55:48]+
									 i_pcs_data[47:40]+
									 i_pcs_data[39:32]+
									 i_pcs_data[31:24]+
									 i_pcs_data[23:16]+
									 i_pcs_data[15: 8]+
									 i_pcs_data[ 7: 0];
end */

always @(posedge i_pcs_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1) begin
		o_resolution        <= 8'b0 ;
		o_vs_total_num      <= 13'd0;
		o_hs_total_num      <= 13'd0;
		o_vsyn_num          <= 13'd0;
		o_hsyn_num          <= 13'd0;
		o_video_start_pixel <= 13'd0;
		o_video_end_pixel   <= 13'd0;
		o_video_start_H     <= 13'd0;
		o_video_end_H       <= 13'd0;
	end else if(r_unpack_cnt == 0 && (o_syn == 1)) begin
		case(r_para_bit_map)
			10'b0000000001: o_resolution        <= r_para[7:0] ;
			10'b0000000010: o_vs_total_num      <= r_para[12:0];
			10'b0000000100: o_hs_total_num      <= r_para[12:0];
			10'b0000001000: o_vsyn_num          <= r_para[12:0];
			10'b0000010000: o_hsyn_num          <= r_para[12:0];
			10'b0000100000: o_video_start_pixel <= r_para[12:0];
			10'b0001000000: o_video_end_pixel   <= r_para[12:0];
			10'b0010000000: o_video_start_H     <= r_para[12:0];
			10'b0100000000: o_video_end_H       <= r_para[12:0];
			default       :;
		endcase
	end else if(o_syn == 0) begin
		o_resolution        <= 8'b0 ;
		o_vs_total_num      <= 13'd0;
		o_hs_total_num      <= 13'd0;
		o_vsyn_num          <= 13'd0;
		o_hsyn_num          <= 13'd0;
		o_video_start_pixel <= 13'd0;
		o_video_end_pixel   <= 13'd0;
		o_video_start_H     <= 13'd0;
		o_video_end_H       <= 13'd0;
	end else ;
end

//-------------------------------------------------------------------------------
always @(posedge i_pcs_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1)
		r_unpack_cnt <= 'd0;
	else if(i_pcs_data[53:0] == 'hfb && i_pcs_head == 'b1)
		r_unpack_cnt <= 'd2;
	else if(r_unpack_cnt == `TOTALLEN - 1)
		r_unpack_cnt <= 'd0;
	else 	
		r_unpack_cnt <= r_unpack_cnt + 1'b1;
end

always @(posedge i_pcs_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1)
		r_syn_cnt <= 'd0;
	else if(r_unpack_cnt == 1 && (i_pcs_head != 1))
		r_syn_cnt <= 'd0;
	else
		r_syn_cnt <= (&r_syn_cnt) ? r_syn_cnt : r_syn_cnt + 'd1;
end	

//always @(posedge i_pcs_clk or negedge i_rst_n) begin
//	if(i_rst_n != 1'b1)
//		r_syn_cnt <= 'd0;
//	else if (r_unpack_cnt == 1 && i_pcs_data[31:24] == r_check_sum )
//		r_syn_cnt <= (&r_syn_cnt) ? r_syn_cnt : r_syn_cnt + 'd1;
//	else if(r_unpack_cnt == 1 && i_pcs_data[31:24] != r_check_sum)
//		r_syn_cnt <= 'd0;
//	else ;
//end

generate 

	if(p_debug_en) begin


		ila_256 upcsrxunpack_ila_256(
			 .clk      (i_pcs_clk)
			,.probe0   ({
				 o_data_rd_en
				,o_video_vsyn
				,i_pcs_head
				,o_video_de
				,r_check_sum
				,o_uart_en
				,o_audio0_en
				,o_audio1_en
				,o_syn
				,r_unpack_cnt
				,i_data_valid
				,r_para_bit_map
				,o_video_lock
				,r_syn_cnt
				,o_video_data
				,r_auxi_data
				,i_pcs_data
				,i_empty
			})
		);


	end
endgenerate



endmodule


