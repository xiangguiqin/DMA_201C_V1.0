//`include "parameter.v"
//`define dRGB24             ('d1 )
`define dYUV444            ('d1 )
//`define dYUV422            ('d1 )
module yuv2rgb(
 input			iRstN
,input			iSclk 
`ifdef dYUV422
,input	[15:0]	iD
`else	//dYUV444
,input	[23:0]	iD
`endif
,input			iV 
,input			iH 
,input			iE 
,input			iflag  
,output	[7:0]	oDesR 
,output	[7:0]	oDesG 
,output	[7:0]	oDesB 
,output			oDesV 
,output			oDesH 
,output			oDesDE
);

//--------------------------YCbCr2RGB----------------------------

wire        	ly2rCh1_outvalid     ;
wire [8-1:0]	ly2rCh1_R         	 ;
wire [8-1:0]	ly2rCh1_G         	 ;
wire [8-1:0]	ly2rCh1_B         	 ;
wire [3-1:0]	ly2rCh1_tags_out     ;

reg [7:0] rY    	;
reg [7:0] rCbCr   	;
reg [7:0] rYD1    	;
reg [7:0] rCbCrD1   ;
reg [7:0] rYD2    ;
reg [7:0] rCbD2   ;
reg [7:0] rCrD2   ;
reg	[2:0]	rY2R_V	;
reg	[2:0]	rY2R_H	;
reg	[2:0]	rY2R_De	;
reg			rCFlag;

reg [2:0] rY2rCh1_tags_in        ;
//---------------------------------------------------------------
reg  [20:0] rNumcut  ;
reg  [20:0] routcut  ;

always @ (posedge iSclk or negedge iRstN)
begin	
	if (iRstN!=1'b1)
        rNumcut       <=   'd0   ;
	else if(iV==1)
	    rNumcut       <=   'd0   ;
    else if(iE==1)
	    rNumcut       <=  rNumcut +1 ;
	else ;
end 

always @ (posedge iSclk or negedge iRstN)
begin	
	if (iRstN!=1'b1)
        routcut       <=   'd0   ;
	else if(oDesV==1)
	    routcut       <=   'd0   ;
    else if(oDesDE==1)
	    routcut       <=  routcut +1 ;
	else ;
end 

//------------------------------------------------------------
always @ (posedge iSclk or negedge iRstN)
begin	
	if (iRstN!=1'b1)
	begin
		rY2R_V					<= 'd0	;
		rY2R_H					<= 'd0	;
		rY2R_De					<= 'd0	;
	end
	else
	begin
		rY2R_V					<= {rY2R_V[1:0],iV}			;
		rY2R_H					<= {rY2R_H[1:0],iH}			;
		rY2R_De					<= {rY2R_De[1:0],iE}		;
	end
end

`ifdef dYUV422
always @ (posedge iSclk or negedge iRstN)
begin	
	if (iRstN!=1'b1)
		rCFlag				<= 'd0	;
//	else if(rY2R_De[0] == 0)
	else if(rY2R_V[0] == 1)
		rCFlag				<= 'd0	;
	else if(rY2R_De[0] == 1)
		rCFlag				<= ~rCFlag	;
	else
		rCFlag				<= rCFlag	;
end             
always @ (posedge iSclk or negedge iRstN)
begin	
	if (iRstN!=1'b1)
	begin
		rY						<= 'd0          ;
		rCbCr					<= 'd0          ;
		rYD1					<= 'd0          ;
		rCbCrD1					<= 'd0          ;
	end
	else if(rY2R_De[0] == 1)
	begin
		rY					<= iD[15:8]     ;
		rCbCr				<= iD[7:0]      ;
		rYD1				<= rY    		;
		rCbCrD1				<= rCbCr      	;
	end	
end          
always @ (posedge iSclk or negedge iRstN)
begin	
	if (iRstN!=1'b1)
	begin
		rYD2				<= 'd0              ;
		rCbD2				<= 'd0              ;
		rCrD2				<= 'd0              ;
	end
	else if(rY2R_De[0] == 1) begin
		if(rCFlag == 1)
		begin
			rYD2				<= rY               ;
			rCbD2				<= rCbCrD1          ;//iD[7:0]          ;//rCbCr            ;
			rCrD2				<= rCbCr            ;//iD[7:0]          ;
		end
		else
		begin
			rYD2				<= rY               ;
			rCbD2				<= rCbCr            ;//rCbCrD1          ;
			rCrD2				<= iD[7:0]          ;//rCbCr            ;
		end	
	end
	else ;
end
`elsif dYUV444
reg [7:0] rCb,rCr   	;
always @ (posedge iSclk or negedge iRstN) begin	
	if(iRstN!=1'b1) begin
		rYD1 <= 'd0       ;
		rCb  <= 'd0       ;
		rCr  <= 'd0       ;
	end
	else begin
		rYD1 <= iD[23:16] ;
		rCb  <= iD[15: 8] ;
	    rCr  <= iD[ 7: 0] ;
	end
end
always @ (posedge iSclk or negedge iRstN) begin	
	if(iRstN!=1'b1) begin
		rYD2				<= 'd0           ;
		rCbD2				<= 'd0           ;
		rCrD2				<= 'd0           ;
	end
	else/* if(rY2R_De[0] == 1) */begin
		rYD2				<= iD[23:16]     ;
		rCbD2				<= iD[15: 8]     ;
		rCrD2				<= iD[ 7: 0]     ;
	end
//	else ;
end
`endif


always @ (posedge iSclk or negedge iRstN)
begin	
	if (iRstN!=1'b1)
	begin
		rY2rCh1_tags_in				<= 'd0              ;
	end
	else 
	begin
//		rY2rCh1_tags_in				<= {rY2R_V[1],rY2R_H[1],rY2R_De[1]}       ;
		rY2rCh1_tags_in				<= {rY2R_V[0],rY2R_H[0],rY2R_De[0]}       ;
	end
end


ycbcr2rgb u0_y2r(
 .iResetN(iRstN           )
,.iClk   (iSclk           )
,.iValid (1'b1            )
,.oValid (ly2rCh1_outvalid)
,.iY     (rYD2            )
,.iCb    (rCbD2           )
,.iCr    (rCrD2           )
,.oR     (ly2rCh1_R       )
,.oG     (ly2rCh1_G       )
,.oB     (ly2rCh1_B       )
,.iTags  (rY2rCh1_tags_in )
,.oTags  (ly2rCh1_tags_out)
);
//---------------------------------------------------------------------------


reg [7:0]  	rRCh1   ;
reg [7:0]  	rGCh1   ;
reg [7:0]  	rBCh1   ;
reg   		rVCh1	;
reg   		rHCh1	;
reg   		rECh1	;

assign oDesR   = rRCh1	;
assign oDesG   = rGCh1	;
assign oDesB   = rBCh1	;
assign oDesV   = rVCh1 ;
assign oDesH   = rHCh1 ;
assign oDesDE   = rECh1 ;

always @ (posedge iSclk or negedge iRstN)
begin
	if (iRstN!=1'b1)
	begin	
		rRCh1			<= 'd0	 	;
		rGCh1          	<= 'd0   	;
		rBCh1          	<= 'd255    ;
	end
	else  if(iflag == 1)
	begin
		rRCh1			<= ly2rCh1_R       ;
		rGCh1          	<= ly2rCh1_G       ;
		rBCh1          	<= ly2rCh1_B       ;
	end
	else	
	begin	
		rRCh1			<= 'd0     	;
		rGCh1          	<= 'd0     	;
		rBCh1          	<= 'd255   	;
	end
end

always @ (posedge iSclk or negedge iRstN)
begin
	if (iRstN!=1'b1)
	begin 
    rVCh1             <=    0 ;
    rHCh1             <=    0 ;
	rECh1             <=    0 ;
	end
    else begin
	rVCh1             <=     ly2rCh1_tags_out[2]     ;
	rHCh1             <=     ly2rCh1_tags_out[1]     ;
    rECh1             <=     ly2rCh1_tags_out[0]     ;
  end
end




endmodule 
//---------------------------------------------------------------------
