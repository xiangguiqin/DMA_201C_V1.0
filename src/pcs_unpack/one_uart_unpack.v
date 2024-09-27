module one_uart_unpack(
 input			i_clk148p5M
,input			i_pcs_clk          
,input			i_rst_n
,output 		o_uart_txd
,output 		o_uart_drive
,input			i_valid       
,input	[31:0]	i_data          
);

reg [7:0]   r_idle_cnt;
reg         r_valid;
reg [31:0]	r_data;
reg [31:0]	r_data_valid_dly;

always @(posedge i_pcs_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1)
		r_data_valid_dly <= 'd1;
	else if(i_valid == 1)
		r_data_valid_dly <= i_data;
	else ;
end

always @(posedge i_pcs_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1)
		r_idle_cnt <= 'd1;
	else if((i_data == r_data_valid_dly) && (i_valid == 1))
		r_idle_cnt <= (&r_idle_cnt) ? r_idle_cnt : r_idle_cnt + 1;
	else if((i_data != r_data_valid_dly) && (i_valid == 1))
		r_idle_cnt <= 'd0;
	else ;
end

always @(posedge i_pcs_clk or negedge i_rst_n) begin
	if(i_rst_n != 1'b1) begin
		r_valid <= 'd0;
		r_data  <= 'd0;
	end else if((w_almostempty == 1) && (&r_idle_cnt) && (i_valid == 0)) begin
		r_valid <= 'd1;
		r_data  <= r_data_valid_dly;
	end else if((w_lmostfull == 1) && (&r_idle_cnt) && (i_valid == 1) && (i_data == r_data_valid_dly)) begin
		r_valid <= 'd0;
	end else begin
		r_valid <= i_valid;
		r_data  <= i_data;
	end
end

wire        w_almostempty ;
wire        w_lmostfull   ;
wire        w_empty       ;
wire        w_full        ;
wire [31:0] w_fifo_Q      ;
wire		w_fifo_rd_en  ;

fifo_w32_r32 u0_fifo_w32_r32(
  .prog_empty_thresh_assert	(4                         )
 ,.prog_empty_thresh_negate	(4                         )
 ,.prog_full_thresh_assert  (25                        )
 ,.prog_full_thresh_negate  (25                        )
 ,.din                      (i_data                    )
 ,.wr_clk                   (i_pcs_clk                 )
 ,.rd_clk                   (i_clk148p5M               )
 ,.wr_en                    (i_valid & (~w_full)       )
 ,.rd_en                    (w_fifo_rd_en & (~w_empty) )
 ,.rst                      (~i_rst_n                  )
 ,.dout                     (w_fifo_Q                  )
 ,.prog_empty               (w_almostempty             )
 ,.prog_full                (w_lmostfull               )
 ,.empty                    (w_empty                   )
 ,.full                     (w_full                    )
);

uart_tx_decode u0_uart_tx_decode(
 .i_clk        (i_clk148p5M  )
,.i_rst_n      (i_rst_n      )
,.o_uart_txd   (o_uart_txd   )
,.o_uart_drive (o_uart_drive )
,.i_data       (w_fifo_Q     )
,.o_fifo_rd_en (w_fifo_rd_en )
); 



endmodule


