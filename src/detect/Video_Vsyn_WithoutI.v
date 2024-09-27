
module Video_Vsyn_WithoutI(
	 input			iClk         			
	,input			iResetN           
	,input			iVsyn             
	,input			iHsyn                  
	,output	reg		oVsyn                     
);
reg [2:0] rVsyn;
always @(posedge iClk or negedge iResetN)
begin
	if(iResetN != 1'b1) 
		rVsyn <=  3'b0;
	else
		rVsyn <=  {rVsyn[1:0],iVsyn};
end

always @(posedge iClk or negedge iResetN)
begin
	if(iResetN != 1'b1) 
		oVsyn <=  1'b0;
	else if(rVsyn[2:1] == 2'b01 && iHsyn == 1'b1)
		oVsyn <=  1'b1;
	else if(iVsyn == 0)
		oVsyn <=  1'b0;
	else ;
end

endmodule


