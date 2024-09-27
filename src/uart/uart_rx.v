module uart_rx #(
 parameter [15:0]  p_DIV      = 16'd434
,parameter [ 3:0]  p_DATA_BIT =  4'd8
) (
 input                           i_rst_n
,input                           i_local_clk
,input                           i_uart_rxd

,output	reg                      o_valid
,output	reg  [p_DATA_BIT-1:0]    o_data
);

parameter    S_IDLE      = 'b00 ;
parameter    S_START_BIT = 'b01 ;
parameter    S_DATA      = 'b11 ;
parameter    S_STOPBIT   = 'b10 ;

reg	   [1:0]    r_uart_rxd;

reg    [1:0]    r_cs      ;
reg    [1:0]    r_ns      ;
reg    [15:0]   r_div_cnt ;
reg    [3:0]    r_byte_Cnt;

always @(posedge i_local_clk or negedge i_rst_n) begin
	if(~i_rst_n)
		r_uart_rxd <= 'd0;
	else
		r_uart_rxd <= {r_uart_rxd[0],i_uart_rxd};
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
		o_data <= 'd0;
	else if(r_cs == S_DATA && r_div_cnt == p_DIV)
		o_data <= {r_uart_rxd[0],o_data[7:1]};
	else ;
end

always @(posedge i_local_clk or negedge i_rst_n)begin
	if(~i_rst_n)
		o_valid <= 'd0;
	else if(r_cs == S_STOPBIT && r_ns == S_DATA)
		o_valid <= 1'd1;
	else 
		o_valid <= 1'd0;
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
			if(r_uart_rxd == 2'b10)
				r_ns = S_STARTBIT;
			else
				r_ns = S_IDLE;
		S_START_BIT:
			if(r_div_cnt == p_DIV[15:1])
				r_ns = S_DATA;
			else
				r_ns = S_START_BIT;
		S_DATA:
			if(r_byte_Cnt >= p_DATA_BIT && r_div_cnt > p_DIV[15:1] && r_uart_rxd[0] == 1)
				r_ns = S_STOPBIT;
			else
				r_ns = S_DATA;
		S_STOPBIT:
			if(r_div_cnt == p_DIV)
				r_ns = S_IDLE;
			else if(r_uart_rxd == 2'b10)
				r_ns = S_START_BIT;
			else
				r_ns = S_STOPBIT;
		default:
			r_ns = S_IDLE;
	endcase
end





endmodule


