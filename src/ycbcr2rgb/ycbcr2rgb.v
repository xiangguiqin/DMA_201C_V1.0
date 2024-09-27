module ycbcr2rgb(
 input               iResetN
,input               iClk
,input               iValid
,output reg          oValid
,input       [7:0]   iY
,input       [7:0]   iCb    
,input       [7:0]   iCr
,output      [7:0]   oR
,output      [7:0]   oG
,output      [7:0]   oB
,input       [2:0]   iTags
,output reg  [2:0]   oTags
);
//[R] = [1.000,  0.000,  1.400][  Y   ]
//[G] = [1.000, -0.343, -0.711][Cb-128]
//[B] = [1.000,  1.765,  0.000][Cr-128]
parameter pRKcr = 17'd 91_750;// 1.400 * 2^16

parameter pGKcb = 16'd 22_478;//-0.343 * 2^16
parameter pGKcr = 16'd 46_596;//-0.711 * 2^16

parameter pBKcb = 17'd115_671;// 1.765 * 2^16


wire [24:0] lrcr ;


wire [23:0] lgcb ;
wire [23:0] lgcr ;

wire [24:0] lbcb ;

reg  [7:0]  rY     ;
reg  [7:0]  rCb    ;
reg  [7:0]  rCr    ;

reg  [7:0]  rR     ;
reg  [7:0]  rG     ;
reg  [7:0]  rB     ;

reg  [2:0]  rTagsD0;
reg  [2:0]  rTagsD1;
reg  [1:0]  rValid ;

reg [9:0] rR_sum;
reg [9:0] rG_sum;
reg [9:0] rB_sum;

always @(posedge iClk or negedge iResetN) begin
	if(iResetN!=1'b1) begin
		rY  <= 'd0;
		rCb <= 'd0;
		rCr <= 'd0;
	end else begin
		rY  <= iY ;
		rCb <= iCb;
		rCr <= iCr;
	end
end

mult_gen_17x8 urcr_mult_gen_17x8(iClk, pRKcr, iCr, lrcr);

mult_gen_16x8 ugcb_mult_gen_16x8(iClk, pGKcb, iCb, lgcb);
mult_gen_16x8 ugcr_mult_gen_16x8(iClk, pGKcr, iCr, lgcr);

mult_gen_17x8 ubcb_mult_gen_17x8(iClk, pBKcb, iCb, lbcb);

always @(posedge iClk or negedge iResetN) begin
	if(iResetN!=1'b1) begin
		rR_sum <= 'd0;
		rG_sum <= 'd0;
		rB_sum <= 'd0;
		
		rTagsD0<= 'd0;
	end else if(iValid)begin
		rR_sum <= rY + lrcr[24:16] - 9'd179;//R = Y+1.400*(Cr-128)
		rG_sum <= 9'd135 + rY - lgcb[23:16] -lgcr[23:16];//G = Y-0.343*(Cb-128)-0.711*(Cr-128)
		rB_sum <= rY + lbcb[24:16] - 9'd226;//B = Y-1.765*(Cb-128)
		
		rTagsD0<= iTags;
	end else begin
		rR_sum <= 'd0;
		rG_sum <= 'd0;
		rB_sum <= 'd0;
		
		rTagsD0<= 'd0;
	end
end



always @(posedge iClk or negedge iResetN) begin
	if(iResetN!=1'b1)
		rR <= 8'd0;
	else if(rR_sum[9])//最高位为1，负值，RGB为无符号数，直接取0
		rR <= 8'd0;
	else if(rR_sum[9:8] == 2'b01)//次高位为1，溢出(大于255)，RGB为无符号8bit数，直接取255
		rR <= 8'd255;
	else//0~255范围，正常取数
		rR <= rR_sum[7:0];
end

always @(posedge iClk or negedge iResetN) begin
	if(iResetN!=1'b1)
		rG <= 8'd0;
	else if(rG_sum[9])//最高位为1，负值，RGB为无符号数，直接取0
		rG <= 8'd0;
	else if(rG_sum[9:8] == 2'b01)//次高位为1，溢出(大于255)，RGB为无符号8bit数，直接取255
		rG <= 8'd255;
	else//0~255范围，正常取数
		rG <= rG_sum[7:0];
end

always @(posedge iClk or negedge iResetN) begin
	if(iResetN!=1'b1)
		rB <= 8'd0;
	else if(rB_sum[9])//最高位为1，负值，RGB为无符号数，直接取0
		rB <= 8'd0;
	else if(rB_sum[9:8] == 2'b01)//次高位为1，溢出(大于255)，RGB为无符号8bit数，直接取255
		rB <= 8'd255;
	else//0~255范围，正常取数
		rB <= rB_sum[7:0];
end

always @(posedge iClk or negedge iResetN) begin
	if(iResetN!=1'b1) begin
		rValid <= 'd0;
		oValid <= 'd0;
		rTagsD1<= 'd0;
		oTags  <= 'd0;
	end else begin
		rValid <= {rValid[0],iValid};
		oValid <= rValid[1];
		rTagsD1<= rTagsD0 ;
		oTags  <= rTagsD1 ;
	end
end

assign oR    = rR  ;
assign oG    = rG  ;
assign oB    = rB  ;

// assign oValid = rValid ;
// assign oTags  = rTags  ;

endmodule


