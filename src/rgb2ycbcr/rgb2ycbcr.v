module rgb2ycbcr(
 input               i_rst_n
,input               i_pclk
,input               i_valid
,output reg          o_valid
,input       [7:0]   i_R       
,input       [7:0]   i_G       
,input       [7:0]   i_B       
,output      [7:0]   o_Y       
,output      [7:0]   o_Cb      
,output      [7:0]   o_Cr      
,input       [2:0]   i_tags
,output reg  [2:0]   o_tags
);
//[Y ] = [ 0 ] + [ 0.2990,  0.5870,  0.1140][R]
//[Cb] = [128] + [-0.1687, -0.3313,  0.5000][G]
//[Cr] = [128] + [ 0.5000, -0.4187, -0.0813][B]
parameter p_YKr  = 16'd19_595;//0.299 * 2^16
parameter p_YKg  = 16'd38_469;//0.587 * 2^16
parameter p_YKb  = 16'd 7_471;//0.114 * 2^16

parameter p_CbKr = 16'd11_056;//-0.1687 * 2^16
parameter p_CbKg = 16'd21_712;//-0.3313 * 2^16
parameter p_CbKb = 16'd32_768;// 0.5000 * 2^16

parameter p_CrKr = 16'd32_768;// 0.5000 * 2^16
parameter p_CrKg = 16'd27_440;//-0.4187 * 2^16
parameter p_CrKb = 16'd 5_328;//-0.0813 * 2^16

wire    [23:0]    w_yr    ;
wire    [23:0]    w_yg    ;
wire    [23:0]    w_yb    ;

wire    [23:0]    w_cb_r  ;
wire    [23:0]    w_cb_g  ;
wire    [23:0]    w_cb_b  ;

wire    [23:0]    w_cr_r  ;
wire    [23:0]    w_cr_g  ;
wire    [23:0]    w_cr_b  ;

reg     [9:0]     r_Y     ;
reg     [9:0]     r_Cb    ;
reg     [9:0]     r_Cr    ;

reg     [2:0]     r_tags  ;
reg               r_valid ;



mult_gen_16x8 uyr_mult_gen_16x8 (i_pclk, p_YKr, i_R, w_yr);
mult_gen_16x8 uyg_mult_gen_16x8 (i_pclk, p_YKg, i_G, w_yg);
mult_gen_16x8 uyb_mult_gen_16x8 (i_pclk, p_YKb, i_B, w_yb);

mult_gen_16x8 ucbr_mult_gen_16x8(i_pclk, p_CbKr, i_R, w_cb_r);
mult_gen_16x8 ucbg_mult_gen_16x8(i_pclk, p_CbKg, i_G, w_cb_g);
mult_gen_16x8 ucbb_mult_gen_16x8(i_pclk, p_CbKb, i_B, w_cb_b);

mult_gen_16x8 ucrr_mult_gen_16x8(i_pclk, p_CrKr, i_R, w_cr_r);
mult_gen_16x8 ucrg_mult_gen_16x8(i_pclk, p_CrKg, i_G, w_cr_g);
mult_gen_16x8 ucrb_mult_gen_16x8(i_pclk, p_CrKb, i_B, w_cr_b);


always @(posedge i_pclk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1) begin
		r_Y    <= 'd0;
		r_Cb   <= 'd0;
		r_Cr   <= 'd0;
		
		r_tags <= 'd0;
	end else if(i_valid) begin
		r_Y    <= w_yr[23:16] + w_yg[23:16] + w_yb[23:16];
		r_Cb   <= 8'd128 + w_cb_b[23:16] - w_cb_r[23:16] - w_cb_g[23:16];
		r_Cr   <= 8'd128 + w_cr_r[23:16] - w_cr_g[23:16] - w_cr_b[23:16];
		
		r_tags <= i_tags;
	end else begin
		r_Y    <= 'd0;
		r_Cb   <= 'd0;
		r_Cr   <= 'd0;
		
		r_tags <= 'd0;
	end
end

always @(posedge i_pclk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1) begin
		r_valid <= 'd0;
		o_valid <= 'd0;
		o_tags  <= 'd0;
	end else begin
		r_valid <= i_valid;
		o_valid <= r_valid;
		o_tags  <= r_tags ;
	end
end

assign o_Y  = (r_Y [9:8]>0) ? 8'd255 : r_Y [7:0]  ;
assign o_Cb = (r_Cb[9:8]>0) ? 8'd255 : r_Cb[7:0]  ;
assign o_Cr = (r_Cr[9:8]>0) ? 8'd255 : r_Cr[7:0]  ;

// assign o_valid = r_valid ;
// assign o_tags  = r_tags  ;

endmodule


