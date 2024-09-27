//-------------------------------------------------------------------
//                                                                 
//  Microsemi Corporation Proprietary and Confidential
//  Copyright 2017 Microsemi Corporation. All rights reserved.
//                                                                  
//  ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN 
//  ACCORDANCE WITH THE MICROSEMI LICENSE AGREEMENT AND MUST BE APPROVED 
//  IN ADVANCE IN WRITING.
//
//-------------------------------------------------------------------
// Title       : pattern_gen
// Created     : June-2017
// Description : This module generates counter pattern generator to transmitter  
//               
// Hierarchy   : PF_64b66b_TX_RX
//               -- pattern_generator        <-- This module   
//-------------------------------------------------------------------
`timescale 1ns/1ps

module pcs_tx_pack #(
 parameter p_debug_en = 0
) (
 input 					i_rst_n  // reset input
,input 					i_pcs_clk  // clock input

,input                  i_video_vsyn
,input                  i_video_almostfull
,output                 o_video_rd_en
,input      [63:0]      i_video_data

,input                  i_uart_almostempty
,output                 o_uart_rd_en
,input      [31:0]      i_uart_data

,input                  i_audio0_almostempty
,output                 o_audio0_rd_en
,input      [63:0]      i_audio0_data
,input                  i_audio1_almostempty
,output                 o_audio1_rd_en
,input      [63:0]      i_audio1_data

,input      [7:0]       i_resolution
,input                  i_video_lock
,input      [12:0]      i_vs_total_num
,input      [12:0]      i_hs_total_num
,input      [12:0]      i_vsyn_num
,input      [12:0]      i_hsyn_num 
,input      [12:0]      i_video_start_pixel 
,input      [12:0]      i_video_end_pixel 
,input      [12:0]      i_video_start_H 
,input      [12:0]      i_video_end_H 

,output     [63:0]      o_pcs_data
,output                 o_pcs_head
,output                 o_data_valid
	
)/* synthesis syn_preserve=1 */;
//`define Vedio_S 'd30
//`define VideoLEN 'd275
//`define TOTALLEN 'd1650
`define VideoS    'd8
`define VideoLEN  'd480
`define TOTALLEN  'd528
`define VALID     'd512



 reg            sos
;reg   [63:0]   dataout
;reg            hdr
;reg            r_video_ready
;reg            r_video_rd
;reg            r_data_valid
;reg   [63:0]   r_video_data
;reg            r_audio0_en
;reg            r_audio1_en
;reg            r_uart_en
;
 reg   [4:0]    r_vsyn_dly
;reg   [9:0]    r_pack_cnt
;
 reg   [26:0]   rcnt_de
;reg            r_video_lock
;reg   [7:0]    r_resolution
;
 reg   [3:0]    r_para_cnt
;reg   [9:0]    r_para_bit_map
;reg   [15:0]   r_para
;
 reg   [7:0]    r_check_sum
;


 assign o_video_rd_en   = r_video_rd
;assign o_uart_rd_en    = r_uart_en
;assign o_audio0_rd_en  = r_audio0_en
;assign o_audio1_rd_en  = r_audio1_en
;assign o_pcs_data     = dataout
;assign o_pcs_head     = hdr
;assign o_data_valid   = sos
;


always @(posedge i_pcs_clk or negedge i_rst_n) begin
	if(!i_rst_n)
		r_pack_cnt <= 'd0;
	else if(r_pack_cnt == `TOTALLEN-1)
		r_pack_cnt <= 'd0;
	else
        r_pack_cnt <= r_pack_cnt + 'd1;
end

always @ (posedge i_pcs_clk) begin
	r_vsyn_dly   <= {r_vsyn_dly[3:0],i_video_vsyn};
	r_video_data <= i_video_data;
	r_resolution <= i_resolution;
	r_video_lock <= i_video_lock;	
	r_data_valid <= r_video_rd;
end

always @(posedge i_pcs_clk or negedge i_rst_n) begin
	if (i_rst_n != 1'b1) begin
		r_audio0_en <= 'd0;
		r_audio1_en <= 'd0;
		r_uart_en   <= 'd0;
	end else if (r_pack_cnt == 'd1) begin
		r_audio0_en <= ~i_audio0_almostempty;
		r_audio1_en <= ~i_audio1_almostempty;
		r_uart_en   <= ~i_uart_almostempty ;
	end else begin
		r_audio0_en <= 'd0;
		r_audio1_en <= 'd0;
		r_uart_en   <= 'd0;
	end
end
//--------------------------------------------------------

always @(posedge i_pcs_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1)
		r_para_cnt <= 4'b0;
	else if(r_pack_cnt == `TOTALLEN-1)
		r_para_cnt <= r_para_cnt+1;
	else ;
end

always @(posedge i_pcs_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1)
		r_para_bit_map <=  10'b0;
	else if(r_pack_cnt == `TOTALLEN-1)
		if(r_para_cnt == 0)
			r_para_bit_map <=  10'b1;
		else
			r_para_bit_map <= {r_para_bit_map[8:0],1'b0};
	else ;
end

always @(posedge i_pcs_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1)
		r_para <=  16'b0;
	else if(r_pack_cnt == `TOTALLEN-1)
		case(r_para_cnt)
			4'd0   : r_para <= r_resolution       ;
			4'd1   : r_para <= i_vs_total_num     ;
			4'd2   : r_para <= i_hs_total_num     ;
			4'd3   : r_para <= i_vsyn_num         ;
			4'd4   : r_para <= i_hsyn_num         ;
			4'd5   : r_para <= i_video_start_pixel;
			4'd6   : r_para <= i_video_end_pixel  ;
			4'd7   : r_para <= i_video_start_H    ;
			4'd8   : r_para <= i_video_end_H      ;
			default: r_para <= 16'b0              ;
		endcase
	else ;
end



//-------------------------------------------------------
always @(posedge i_pcs_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1) 
		r_video_ready <= 'd0;
	else if(r_pack_cnt==0 && i_video_almostfull==1 && r_vsyn_dly==5'b00000)
		r_video_ready <= 'd1;
	else if(r_pack_cnt == 0)
		r_video_ready <= 'd0;
	else ;
end

always @ (posedge i_pcs_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1) 
		r_video_rd <= 'd0;
	else if(r_video_ready==1 && r_pack_cnt>=`VideoS-3 && r_pack_cnt<=`VideoS+`VideoLEN-1-3)
		r_video_rd <= 1'b1;
	else 
		r_video_rd <= 1'b0;
end	

always @(posedge i_pcs_clk or negedge i_rst_n) begin
	if(!i_rst_n)
		hdr <= 1'b0;
	else if(r_pack_cnt == 'd0)
		hdr <= 1'b1;
	else
        hdr <= 1'b0;
end


always @(posedge i_pcs_clk or negedge i_rst_n) begin
	if(!i_rst_n)
		sos <= 'd0;
	else if(r_pack_cnt < `VALID)
		sos <= 'd1;
	else
        sos <= 'd0;
end

always @(posedge i_pcs_clk or negedge i_rst_n) begin
	if(!i_rst_n)
		dataout <= 64'h0000_0000_0000_0000;
	else if(r_pack_cnt>=`VideoS && r_pack_cnt<=`VideoS+`VideoLEN-1)
		dataout <= r_video_data;
	else case(r_pack_cnt)
		'd0    : dataout <= {10'h2a,54'hfb};
		'd1    : dataout <= {10'h2a,27'd0,r_check_sum,r_para_bit_map,r_video_lock,r_resolution};
		'd2    : dataout <= {10'h2a,34'd0,r_para,r_vsyn_dly[0],r_video_ready,r_audio1_en,r_audio0_en,r_uart_en};
		'd3    : dataout <= i_audio0_data;
		'd4    : dataout <= i_audio1_data;
		'd5    : dataout <= {32'h0,i_uart_data};
		'd6    : dataout <= {10'h2a,54'h2a_5a5a_5a5a_5a5a};
		'd7    : dataout <= {10'h2a,54'h2a_5a5a_5a5a_5a5a};
		default: dataout <= {10'h2a,54'h2a_5a5a_5a5a_5a5a};
	endcase
end

always @(posedge i_pcs_clk or negedge i_rst_n) begin
	if(!i_rst_n)
		r_check_sum <= 64'h0000_0000_0000_0000;
	else if(r_pack_cnt == 0)
		r_check_sum <= 64'h0000_0000_0000_0000;
	else if(r_pack_cnt > 1 && r_pack_cnt <= `VALID)
		r_check_sum <= r_check_sum + dataout[63:56] + dataout[55:48] + 
									 dataout[47:40] + dataout[39:32] +
									 dataout[31:24] + dataout[23:16] + 
									 dataout[15:8]  + dataout[7:0];
	else ;
end	


generate 

	if(p_debug_en) begin
		reg [23:0] r_frm_pixel_cnt;

		always @(posedge i_pcs_clk or negedge i_rst_n) begin
			if(i_rst_n != 1'b1)	
				r_frm_pixel_cnt <= 'd0;
			else if(r_vsyn_dly == 5'b0)
				r_frm_pixel_cnt <= 'd0;
			else if(r_data_valid == 0 && r_video_rd == 1)
				r_frm_pixel_cnt <= r_frm_pixel_cnt + 1;	
			else ;
		end
		
		ila_128 upcstxpack_ila_128(
			 .clk    (i_pcs_clk)
			,.probe0 ({
				 r_vsyn_dly
				,r_pack_cnt
				,r_audio0_en
				,r_audio1_en
				,i_video_almostfull
				,i_audio0_almostempty
				,i_audio1_almostempty
				,i_uart_almostempty
				,sos
				,hdr
				,r_video_ready
				,r_video_rd
				,r_video_lock
				,r_check_sum
				,dataout
			})
		);

	end
endgenerate

		

endmodule 
