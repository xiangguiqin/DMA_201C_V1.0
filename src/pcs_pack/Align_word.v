module Align_word(
 input				iRstN
,input				iSclk
,input				iSync
,input		[19:0]	iD_Link 
,output	reg [19:0]	oD_Link1 
,output	reg [19:0]	oD_Link2 
,output	reg [19:0]	oD_Link3 
,output	reg [19:0]	oD_Link4 
,output	reg 		oRst 
);

reg	[2:0]	rCnt			;
reg	[2:0]	rCnt1			;
reg	[2:0]	rCnt2			;
reg	[2:0]	rCnt3			;
reg	[2:0]	rCnt4			;
reg	[20:0]	rTimeCnt		;
reg [19:0]	rD_Link10		;
reg [19:0]	rD_Link11		;
reg [19:0]	rD_Link20		;
reg [19:0]	rD_Link21		;
reg [19:0]	rD_Link30		;
reg [19:0]	rD_Link31		;
reg [19:0]	rD_Link40		;
reg [19:0]	rD_Link41		;
always @ (posedge iSclk or negedge iRstN)
begin
	if (iRstN!=1'b1) begin
		rD_Link10 <= 'd0 ;
		rD_Link11 <= 'd0 ;
		rD_Link20 <= 'd0 ;
		rD_Link21 <= 'd0 ;
		rD_Link30 <= 'd0 ;
		rD_Link31 <= 'd0 ;
		rD_Link40 <= 'd0 ;
		rD_Link41 <= 'd0 ;
		rCnt1	  <= 'd0 ;
		rCnt2	  <= 'd0 ;
		rCnt3	  <= 'd0 ;
		rCnt4	  <= 'd0 ;
	end
	else begin
		rD_Link10 <= iD_Link 	;
		rD_Link11 <= rD_Link10 	;
		rD_Link20 <= iD_Link 	;
		rD_Link21 <= rD_Link20 	;
		rD_Link30 <= iD_Link 	;
		rD_Link31 <= rD_Link30 	;
		rD_Link40 <= iD_Link 	;
		rD_Link41 <= rD_Link40 	;
		rCnt1	  <= rCnt ;
		rCnt2	  <= rCnt ;
		rCnt3	  <= rCnt ;
		rCnt4	  <= rCnt ;		
	end
end	
always @ (posedge iSclk or negedge iRstN)
begin
	if (iRstN!=1'b1)
		rTimeCnt <= 'd0 ;
	else 
	    rTimeCnt <= rTimeCnt+1 ; 
end	
always @ (posedge iSclk or negedge iRstN)
begin
	if (iRstN!=1'b1)
		rCnt <= 'd0 ;
	else if((&rTimeCnt) && (iSync == 0))
		rCnt <= (rCnt == 4)?'d0:rCnt+'d1 ;
	else ; 
end	
always @ (posedge iSclk or negedge iRstN)
begin
	if (iRstN!=1'b1)
		oRst <= 'd0 ;
	else if(rCnt != rCnt1)
		oRst <= 'd1;
	else 
		oRst <= 'd0; 
end	

always @ (posedge iSclk) 
    case(rCnt1) 
        3'd0:  oD_Link1 <= {rD_Link10[19:0]						    };  
        3'd1:  oD_Link1 <= {rD_Link10[18:0],rD_Link11[19]			};  
        3'd2:  oD_Link1 <= {rD_Link10[17:0],rD_Link11[19:18]		};  
        3'd3:  oD_Link1 <= {rD_Link10[16:0],rD_Link11[19:17]		};  
        3'd4:  oD_Link1 <= {rD_Link10[15:0],rD_Link11[19:16]		};  
        default: ; 
    endcase 
always @ (posedge iSclk) 
    case(rCnt2) 
        3'd0:  oD_Link2 <= {rD_Link20[14:0],rD_Link21[19:15]		};  
        3'd1:  oD_Link2 <= {rD_Link20[13:0],rD_Link21[19:14]		};  
        3'd2:  oD_Link2 <= {rD_Link20[12:0],rD_Link21[19:13]		};  
        3'd3:  oD_Link2 <= {rD_Link20[11:0],rD_Link21[19:12]		};  
        3'd4:  oD_Link2 <= {rD_Link20[10:0],rD_Link21[19:11]		};  
        default: ;
    endcase 

always @ (posedge iSclk) 
    case(rCnt3) 
        3'd0: oD_Link3 <= {rD_Link30[ 9:0],rD_Link31[19:10]		};   
        3'd1: oD_Link3 <= {rD_Link30[ 8:0],rD_Link31[19: 9]		};   
        3'd2: oD_Link3 <= {rD_Link30[ 7:0],rD_Link31[19: 8]		};  
        3'd3: oD_Link3 <= {rD_Link30[ 6:0],rD_Link31[19: 7]		};  
        3'd4: oD_Link3 <= {rD_Link30[ 5:0],rD_Link31[19: 6]		};  
        default:;
    endcase 
always @ (posedge iSclk) 
    case(rCnt4) 
        3'd0: oD_Link4 <= {rD_Link40[ 4:0],rD_Link41[19: 5]		};  
        3'd1: oD_Link4 <= {rD_Link40[ 3:0],rD_Link41[19: 4]		};  
        3'd2: oD_Link4 <= {rD_Link40[ 2:0],rD_Link41[19: 3]		};  
        3'd3: oD_Link4 <= {rD_Link40[ 1:0],rD_Link41[19: 2]		};  
        3'd4: oD_Link4 <= {rD_Link40[   0],rD_Link41[19: 1]		};  
        default:;
    endcase 

endmodule 







