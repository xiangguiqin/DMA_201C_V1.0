`timescale 1 ns / 1 ps
module F_delay#(
 parameter pSIZE  = 2
,parameter pDELAY = 2
) (
 input 					   i_clk
,input 					   i_rst_n
,input 		[pSIZE-1:0]	   i_data
,output  	[pSIZE-1:0]	   o_data
);

reg [pSIZE*pDELAY-1:0] r_delay_data;

generate  
	genvar i;
	for(i=0; i<pDELAY; i=i+1) begin: u_delay
		always @(posedge i_clk or negedge i_rst_n) begin
			if(i_rst_n != 1'b1)begin
				r_delay_data[pSIZE*(i+1)-1:pSIZE*i]     <= 'h0;
			end else begin
				if(i == 0)
					r_delay_data[pSIZE*(i+1)-1:pSIZE*i] <= i_data[pSIZE-1:0];
				else
					r_delay_data[pSIZE*(i+1)-1:pSIZE*i] <= r_delay_data[pSIZE*i-1:pSIZE*(i-1)];
		    end
		end
	end
endgenerate

assign o_data[pSIZE-1:0] = r_delay_data[pSIZE*pDELAY-1:pSIZE*(pDELAY-1)];


		

endmodule


