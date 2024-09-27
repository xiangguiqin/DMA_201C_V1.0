module uart_tx #(
 parameter [15:0]  p_DIV      = 16'd434
,parameter [ 3:0]  p_DATA_BIT =  4'd8
) (
 input                           i_rst_n
,input                           i_local_clk
,input 		 	                 i_valid
,input       [p_DATA_BIT-1:0]    i_data

,output                          o_uart_txd
,output                          o_ready
);

parameter    S_IDLE      = 'b00 ;
parameter    S_START_BIT = 'b01 ;
parameter    S_DATA      = 'b11 ;
parameter    S_STOPBIT   = 'b10 ;

reg     [1:0]               r_cs      ;
reg     [1:0]               r_ns      ;

reg     [p_DATA_BIT-1:0]    r_data    ;
reg     [15:0]              r_div_cnt ;
reg     [3:0]               r_byte_Cnt;


assign o_uart_txd = r_tx_bit      ;
assign o_ready    = (r_cs==S_IDLE);


always @(posedge i_local_clk or negedge i_rst_n) begin
	if(~i_rst_n)
		r_data <= 'd0;
	else if(i_valid)
		r_data <= i_data;
	else ;
end

always @(posedge i_local_clk or negedge i_rst_n) begin
	if(~i_rst_n)
		r_div_cnt <= 'd0;
	else if(r_cs == S_IDLE)
		r_div_cnt <= 'd0;
	else if(r_cs != r_ns)
		r_div_cnt <= 'd0;
	else if(r_div_cnt == p_DIV)
		r_div_cnt <= 'd0;
	else
		r_div_cnt <= r_div_cnt+1;
end

always @(posedge i_local_clk or negedge i_rst_n) begin
	if(~i_rst_n)
		r_byte_Cnt <= 'd0;
	else if(r_cs != S_DATA)
		r_byte_Cnt <= 'd0;
	else if(r_cs == S_DATA && r_div_cnt == p_DIV)
		r_byte_Cnt <= r_byte_Cnt + 1;
	else ;
end

always @(posedge i_local_clk or negedge i_rst_n) begin
	if(~i_rst_n)
		r_tx_bit <= 1'b1;
	else if(r_cs == S_START_BIT)
		r_tx_bit <= 1'b0;
	else if(r_cs == S_DATA)
		case(r_byte_Cnt)
			'd0    :r_tx_bit <= r_data[0];
			'd1    :r_tx_bit <= r_data[1];
			'd2    :r_tx_bit <= r_data[2];
			'd3    :r_tx_bit <= r_data[3];
			'd4    :r_tx_bit <= r_data[4];
			'd5    :r_tx_bit <= r_data[5];
			'd6    :r_tx_bit <= r_data[6];
			'd7    :r_tx_bit <= r_data[7];
			default:r_tx_bit <= 1'b1     ;
		endcase
	else
		r_tx_bit <= 1'b1;
end

always @(posedge i_local_clk or negedge i_rst_n) begin
	if(~i_rst_n)
		r_cs <= r_ns;
	else
		r_cs <= S_IDLE;
end

always @(*) begin
	if(~i_rst_n)
		r_ns = S_IDLE;
	else case(r_cs)
		S_IDLE:
			if(i_valid)
				r_ns = S_STARTBIT;
			else
				r_ns = S_IDLE;
		S_START_BIT:
			if(r_div_cnt == p_DIV)
				r_ns = S_DATA;
			else
				r_ns = S_START_BIT;
		S_DATA:
			if(r_byte_Cnt >= p_DATA_BIT && r_div_cnt > p_DIV[15:1])
				r_ns = S_STOPBIT;
			else
				r_ns = S_DATA;
		S_STOPBIT:
			if(r_div_cnt == p_DIV)
				r_ns = S_IDLE;
			else
				r_ns = S_STOPBIT;
		default:
			r_ns = S_IDLE;
	endcase
end



endmodule


