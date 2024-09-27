module LinkTx(
 input 			iRstN	
,input			iPclk 
,output	[19:0]	oD_Link
);



//-------------------------------------------------------------------------------

//-------------------------------------------------------------------------------
reg	[11:0]		rCntP		        	;
reg	[19:0]		rD_Link		            ;

assign 			oD_Link	 = rD_Link	    ;

//-------------------------------------------------------------------------------

always @ (posedge iPclk or negedge iRstN)
begin
	if (iRstN!=1'b1)
		rCntP					<= 'd0;
	else if (rCntP=='d2000-1)
		rCntP					<= 'd0;
	else 	
		rCntP					<= rCntP + 1'b1;
end		

//-------------------------------------------------------------------------------

always @ (posedge iPclk or negedge iRstN)
begin
	if (iRstN!=1'b1)
		rD_Link					<= 'h0;
	else if (rCntP=='d0)	
		rD_Link					<= 'hFFFFF;
	else 
		rD_Link					<= {4'd0,rCntP,4'd0};
end

endmodule 		