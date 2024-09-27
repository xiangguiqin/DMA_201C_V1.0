module rgb2yuv422 #(
 parameter p_debug_en = 0
) (
 input			i_rst_n
,input			i_sclk 
,input	[7:0]	i_src_R 
,input	[7:0]	i_src_G 
,input	[7:0]	i_src_B 
,input			i_src_vsync 
,input			i_src_hsync 
,input			i_src_de
,input			i_valid

,output	[15:0]	o_data 
,output			o_vsync 
,output			o_hsync 
,output			o_de 
);

 wire          	w_r2y_ivalid
;wire          	w_r2y_ovalid
;wire  [8-1:0]  w_r2y_R 
;wire  [8-1:0] 	w_r2y_G     
;wire  [8-1:0] 	w_r2y_B     
;wire  [7:0] 	w_r2y_Y     
;wire  [7:0] 	w_r2y_Cb    
;wire  [7:0] 	w_r2y_Cr    
;wire  [3-1:0] 	w_r2y_tags_in 
;wire  [3-1:0] 	w_r2y_tags_out
;wire           w_r2y_rstn
;
 reg   [7:0]    r_src_R
;reg   [7:0]    r_src_G
;reg   [7:0]    r_src_B
;reg   [2:0]    r_r2y_tags_in
;reg   [7:0]    r_src_R_dly1
;reg   [7:0]    r_src_G_dly1
;reg   [7:0]    r_src_B_dly1
;reg   [2:0]    r_r2y_tags_in_dly1
;

 assign w_r2y_ivalid  = i_valid
;assign w_r2y_R       = r_src_R_dly1
;assign w_r2y_G       = r_src_G_dly1
;assign w_r2y_B       = r_src_B_dly1
;assign w_r2y_tags_in = r_r2y_tags_in_dly1
;assign w_r2y_rstn    = i_rst_n
;

rgb2ycbcr u0_r2y(
 .i_rst_n (w_r2y_rstn     )
,.i_pclk  (i_sclk         )
,.i_valid (w_r2y_ivalid   )
,.o_valid (w_r2y_ovalid   )
,.i_R     (w_r2y_R        )
,.i_G     (w_r2y_G        )
,.i_B     (w_r2y_B        )
,.o_Y     (w_r2y_Y        )
,.o_Cb    (w_r2y_Cb       )
,.o_Cr    (w_r2y_Cr       )
,.i_tags  (w_r2y_tags_in  )
,.o_tags  (w_r2y_tags_out )
);

 reg [2:0]	r_r2y_hsync
;reg [2:0]	r_r2y_vsync
;reg [2:0]	r_r2y_de
;reg [7:0]	r_r2y_Y0
;reg [7:0]	r_r2y_Y1
;reg [7:0]	r_r2y_Y2
//;reg [7:0]	r_r2y_Y3
;reg [7:0]	r_r2y_Cb0
;reg [7:0]	r_r2y_Cb1
;reg [7:0]	r_r2y_Cr0
;reg [7:0]	r_r2y_Cr1
;reg [7:0]	r_r2y_Cr2
;reg [8:0]	r_r2y_CbCr
;reg [7:0]	r_r2y_CbCr_dly1
;reg        r_odd_flag
;

;assign o_data  = {r_r2y_Y2,r_r2y_CbCr[8:1]}
;assign o_vsync =  r_r2y_vsync[2]
;assign o_hsync =  r_r2y_hsync[2]
;assign o_de    =  r_r2y_de[2]
;

always @(posedge i_sclk) begin
	r_src_R            <= i_src_R;
	r_src_G            <= i_src_G;
	r_src_B            <= i_src_B;
	r_src_R_dly1       <= r_src_R;
	r_src_G_dly1       <= r_src_G;
	r_src_B_dly1       <= r_src_B;
	
	r_r2y_tags_in      <= {i_src_vsync,i_src_hsync,i_src_de};
	r_r2y_tags_in_dly1 <= r_r2y_tags_in;
end

always @(posedge i_sclk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1)	
		r_odd_flag <= 'b0			;
	else if(r_r2y_vsync[0] == 1)
		r_odd_flag <= 'b0			;
	// else if(r_r2y_de[0] == 0)
		// r_odd_flag <= 'b0			;
	else if(r_r2y_de[0] == 1)
		r_odd_flag <= ~r_odd_flag	;
	else
		r_odd_flag <= r_odd_flag	;
end

always @(posedge i_sclk) begin
	r_r2y_vsync <= {r_r2y_vsync[1:0],w_r2y_tags_out[2]} ; 
	r_r2y_hsync <= {r_r2y_hsync[1:0],w_r2y_tags_out[1]} ;
	r_r2y_de    <= {r_r2y_de[1:0],w_r2y_tags_out[0]};
	r_r2y_Y0    <= w_r2y_Y   ;
	r_r2y_Y1    <= r_r2y_Y0  ;
	r_r2y_Cb0   <= w_r2y_Cb  ;
	r_r2y_Cb1   <= r_r2y_Cb0 ;
	r_r2y_Cr0   <= w_r2y_Cr  ;
	r_r2y_Cr1   <= r_r2y_Cr0 ;
	r_r2y_Cr2   <= r_r2y_Cr1 ;
end	

always @(posedge i_sclk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1) begin	
		r_r2y_Y2   <= 'd0;
		r_r2y_CbCr <= 'd0;
	end	else if(r_odd_flag == 1) begin	
		r_r2y_Y2   <= r_r2y_Y1;
		r_r2y_CbCr <= r_r2y_Cb1 + r_r2y_Cb0;
	end else begin
		r_r2y_Y2   <= r_r2y_Y1;
		r_r2y_CbCr <= r_r2y_Cr2 + r_r2y_Cr1;	
	end
end	



generate 

	if(p_debug_en) begin

		reg [23:0] r_frm_pixel_cnt;

		always @(posedge i_sclk or negedge i_rst_n) begin
			if(i_rst_n!=1'b1)	
				r_frm_pixel_cnt <= 'd0;
			else if(i_src_vsync == 1)
				r_frm_pixel_cnt <= 'd0;
			else if(i_src_de)
				r_frm_pixel_cnt <= r_frm_pixel_cnt + 1;	
			else ;
		end
	end
endgenerate



endmodule 
//---------------------------------------------------------------------