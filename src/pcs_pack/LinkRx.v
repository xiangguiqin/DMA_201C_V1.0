module LinkRx(
 input			iRstN
,input			iSclk
,input	[19:0]	iD_Link 
,output	reg		oSync
);

 reg	[12:0]	rCntP		;
 reg	[15:0]	rSyncCnt	;
 reg 		rErr;
//assign oSync = &rSyncCnt	;
always @ (posedge iSclk or negedge iRstN)
begin
	if (iRstN!=1'b1)
		rCntP <= 'd0 ;
	else if(iD_Link == 'hFFFFF)
		rCntP <= 'd1 ;
	else 
	    rCntP <= rCntP+1 ; 
end	

always @ (posedge iSclk or negedge iRstN)
begin
	if (iRstN!=1'b1)
		rErr						<= 'd0;
	else if (iD_Link == 'hFFFFF && rCntP != 'd3900)	
		rErr						<= 'd1;
	else if (iD_Link != 'hFFFFF && rCntP == 'd3900)	
		rErr						<= 'd1;
	else if (iD_Link == 'hFFFFF && rCntP == 'd3900)
		rErr						<= 'd0;
	else ;
end		

always @ (posedge iSclk or negedge iRstN)
begin
	if (iRstN!=1'b1)
		rSyncCnt					<= 'd0;
	else if (rErr=='d1)	
		rSyncCnt					<= 'd0;
	else if (&rSyncCnt)
		rSyncCnt					<= rSyncCnt;
	else 
		rSyncCnt					<= rSyncCnt + 1'b1;
end		
always @ (posedge iSclk or negedge iRstN)
begin
	if (iRstN!=1'b1)
		oSync					<= 'd0;
	else if (&rSyncCnt)
		oSync					<= 'd1;
	else 
		oSync					<= 'd0;
end		


endmodule 







