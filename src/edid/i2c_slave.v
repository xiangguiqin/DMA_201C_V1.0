/****************************************************************************
I2C写寄存器的标准流程为：
1. Master发起START
2. Master发送I2C addr（7bit）和w操作0（1bit），等待ACK
3. Slave发送ACK
4. Master发送reg addr（8bit），等待ACK
5. Slave发送ACK
6. Master发送data（8bit），即要写入寄存器中的数据，等待ACK
7. Slave发送ACK
8. 第6步和第7步可以重复多次，即顺序写多个寄存器
9. Master发起STOP

I2C读寄存器的标准流程为：
1. Master发起START
2. Master发送I2C addr（7bit）和w操作0（1bit），等待ACK
3. Slave发送ACK
4. Master发送reg addr（8bit），等待ACK
5. Slave发送ACK
6. Master发起START
7. Master发送I2C addr（7bit）和r操作1（1bit），等待ACK
8. Slave发送ACK
9. Slave发送data（8bit），即寄存器里的值
10.Master如果继续读发送ACK，否则发送NACK
11.第9步和第10步（最后一次ACK Master发送NACK）可以重复多次，即顺序读多个寄存器
12.Master发起STOP
******************************************************************************/
module i2c_slave #(
 parameter p_debug_en = "FALSE"
)(
 input			       i_sclk
,input  		       i_rst_n

,input         [7:0]   i_device_addr

,output reg 	       o_wr_de
,output        [7:0]   o_wr_addr
,output        [7:0]   o_wr_data
,output reg            o_wr_done
,output reg    [8:0]   o_wr_length

,output        [7:0]   o_rd_addr
,input         [7:0]   i_rd_data
,output reg            o_rd_de

,input			       i_scl
,input			       i_sda
,output			       o_sda

,output			       o_status
);


localparam   S_IDLE         = 'h0;
localparam   S_START        = 'h1;
localparam   S_DEV_ADDR     = 'h2;
localparam   S_DEV_ACK      = 'h3;
localparam   S_REG_ADDR     = 'h4;
localparam   S_REG_ACK      = 'h5;
localparam   S_WR_DATA      = 'h6;
localparam   S_WR_DATA_ACK  = 'h7;
localparam   S_RD_DATA      = 'h8;
localparam   S_RD_DATA_ACK  = 'h9;
localparam   S_STOP         = 'ha;
reg  [4:0]   r_cs                ;
reg  [4:0]   r_ns                ;

reg  [3:0]   r_scl            ;
reg  [3:0]   r_sda            ;
reg          ro_sda           ;
wire         w_sda_pos        ;
wire         w_sda_neg        ;
wire         w_scl_pos        ;
wire         w_scl_neg        ;

reg  [5:0]   r_scl_pos        ;
reg  [5:0]   r_scl_neg        ;

wire         w_bus_start      ;
wire         w_bus_stop       ;


reg  [7:0]   r_device_addr    ;
reg  [7:0]   r_bit_cnt        ;

reg  [7:0]	r_wr_data_shift   ;
reg  [7:0]	r_wr_data		  ;
reg  [7:0]	r_wr_addr		  ;
reg  [7:0]	r_start_wr_addr   ;
reg  [8:0]	r_wr_length       ;
reg         r_rd_de           ;
reg  [7:0]  r_rd_addr         ;
reg  [7:0]  r_rd_data         ;
reg         r_check_ack       ;


reg         r_bus_wr_rd       ;

reg  [19:0] r_scl_low_freq_cnt;
reg  [19:0] r_scl_low_freq    ;
reg  [19:0] ro_sda_en_cnt     ;
reg         ro_sda_en         ;

reg  [19:0] r_scl_hight_freq_cnt;
reg  [19:0] r_scl_hight_freq    ;
reg  [29:0] r_scl_idle_cnt      ;
reg         r_scl_idle_en       ;

/******************************************************************************/
assign o_status    = r_cs       ;

assign o_sda       = ro_sda     ;

assign o_rd_addr   = r_rd_addr  ;
assign o_wr_data   = r_wr_data  ;
assign o_wr_addr   = r_wr_addr  ;

assign w_sda_pos   = ~r_sda[3] & r_sda[2];
assign w_sda_neg   = r_sda[3] & ~r_sda[2];
assign w_scl_pos   = ~r_scl[3] & r_scl[2];
assign w_scl_neg   = r_scl[3] & ~r_scl[2];

assign w_bus_start = w_sda_neg & r_scl[3];
assign w_bus_stop  = w_sda_pos & r_scl[3];

/******************************************************************************/
always @(posedge i_sclk or negedge i_rst_n) begin	
	if(~i_rst_n) begin
		r_sda <= 'd0;
		r_scl <= 'd0;
	end
	else begin
		r_sda <= {r_sda[2:0],i_sda};
		r_scl <= {r_scl[2:0],i_scl};
	end
end

always @(posedge i_sclk or negedge i_rst_n) begin	
	if(~i_rst_n) begin
		r_scl_pos <= 'd0;
		r_scl_neg <= 'd0;
	end
	else begin
		r_scl_pos <= {r_scl_pos[4:0], w_scl_pos};
		r_scl_neg <= {r_scl_neg[4:0], w_scl_neg};
	end
end

always @(posedge i_sclk or negedge i_rst_n) begin	
	if(~i_rst_n)
		r_device_addr <= 'd0;
	else if(w_bus_start)
		r_device_addr <= i_device_addr;
	else ;
end


always @(posedge i_sclk or negedge i_rst_n) begin	
	if(~i_rst_n)
		r_bit_cnt <= 'd0;
	else case(r_ns)
		S_DEV_ADDR,S_REG_ADDR,S_WR_DATA,S_RD_DATA:
			if(w_scl_pos)
				r_bit_cnt <= r_bit_cnt + 'd1;
			else ;
		
		default:r_bit_cnt <= 'd0;
	endcase
end


always @(posedge i_sclk or negedge i_rst_n) begin	
	if(~i_rst_n)
		o_rd_de <= 'd0;
	else if((r_ns==S_DEV_ACK) && w_scl_pos && r_bus_wr_rd)
		o_rd_de <= 'd1;
	else if((r_ns==S_RD_DATA_ACK) && w_scl_pos && r_bus_wr_rd)
		o_rd_de <= 'd1;
	else
		o_rd_de <= 'd0;
end

always @(posedge i_sclk or negedge i_rst_n) begin	
	if(~i_rst_n)
		r_rd_de <= 'd0;
	else
		r_rd_de <= o_rd_de;
end


always @(posedge i_sclk or negedge i_rst_n) begin	
	if(~i_rst_n)
		o_wr_de <= 'd0;
	else if(r_cs==S_WR_DATA && r_bit_cnt=='d8 && w_scl_neg)
		o_wr_de <= 'd1;
	else
		o_wr_de <= 'd0;
end

always @(posedge i_sclk or negedge i_rst_n) begin
	if(~i_rst_n)
		r_bus_wr_rd <= 1'b0;
	else if(r_ns==S_DEV_ADDR && r_bit_cnt=='d7 && w_scl_pos)
		r_bus_wr_rd <= r_sda[3];
	else ;
end

always @(posedge i_sclk or negedge i_rst_n) begin
	if(~i_rst_n)
		r_wr_addr <= 1'b0;
	else if(r_cs==S_REG_ADDR && r_bit_cnt=='d8 && w_scl_neg)
		r_wr_addr <= r_wr_data_shift;
	else if(r_cs==S_WR_DATA_ACK && w_scl_pos)
		r_wr_addr <= r_wr_addr + 1;
	else ;
end

always @(posedge i_sclk or negedge i_rst_n) begin
	if(~i_rst_n)
		r_start_wr_addr <= 1'b0;
	else if(r_cs==S_REG_ADDR && r_bit_cnt=='d8 && w_scl_neg)
		r_start_wr_addr <= r_wr_data_shift;
	else ;
end

always @(posedge i_sclk or negedge i_rst_n) begin
	if(~i_rst_n)
		r_rd_addr <= 1'b0;
	else if(r_cs==S_REG_ADDR && r_bit_cnt=='d8 && w_scl_neg)
		r_rd_addr <= r_wr_data_shift;
	else if(r_cs==S_RD_DATA_ACK && w_scl_pos)
		r_rd_addr <= r_rd_addr + 1;
	else ;
end

always @(posedge i_sclk or negedge i_rst_n) begin
	if(~i_rst_n)
		r_wr_data <= 1'b0;
	else if(r_cs==S_WR_DATA && r_bit_cnt=='d8 && w_scl_neg)
		r_wr_data <= r_wr_data_shift;
	else ;
end

always @(posedge i_sclk or negedge i_rst_n) begin
	if(~i_rst_n)
		r_wr_length <= 'd0;
	else if(r_cs==S_WR_DATA_ACK && ~r_bus_wr_rd && w_scl_pos)
		r_wr_length <= 1 + r_wr_addr - r_start_wr_addr;
	else ;
end

always @(posedge i_sclk or negedge i_rst_n) begin
	if(~i_rst_n) begin
		o_wr_done   <= 'd0;
		o_wr_length <= 'd0;
	end
	else if(~r_bus_wr_rd && w_bus_stop) begin
		o_wr_done   <= 'd1;
		o_wr_length <= r_wr_length;
	end
	else begin
		o_wr_done   <= 'd0;
		o_wr_length <= 'd0;
	end
end

always @(posedge i_sclk or negedge i_rst_n) begin	
	if(~i_rst_n)
		r_wr_data_shift <= 'd0;
	else if(w_scl_pos)
		r_wr_data_shift <= {r_wr_data_shift[6:0],r_sda[3]};
	else;
end

always @(posedge i_sclk or negedge i_rst_n) begin	
	if(~i_rst_n)
		r_rd_data <= 'd0;
	else if(r_rd_de)
		r_rd_data <= i_rd_data;
	else if(r_ns == S_RD_DATA && w_scl_pos)
		r_rd_data <= {r_rd_data[6:0],1'b0};
	else ;
end

always @(posedge i_sclk or negedge i_rst_n) begin	
	if(~i_rst_n)
		r_check_ack <= 'd0;
	else if(r_cs == S_RD_DATA_ACK && w_scl_pos)
		if(~r_sda[3])
			r_check_ack <= 1'b1;
		else
			r_check_ack <= 1'b0;
	else if(r_cs == S_RD_DATA_ACK && w_scl_neg)
		r_check_ack <= 1'b0;
	else ;
end

always @(posedge i_sclk or negedge i_rst_n) begin	
	if(~i_rst_n)
		ro_sda <= 1'b1;
	else if(r_ns == S_IDLE)
		ro_sda <= 1'b1;
	else if(r_scl_idle_en)
		ro_sda <= 1'b1;
	else if(r_ns == S_DEV_ACK)
		if(ro_sda_en)
			ro_sda <= 1'b0;
		else
			ro_sda <= ro_sda;
	else if(r_ns == S_REG_ACK)
		if(ro_sda_en)
			ro_sda <= 1'b0;
		else
			ro_sda <= ro_sda;	
	else if(r_ns == S_RD_DATA)
		if(ro_sda_en)
			ro_sda <= r_rd_data[7];
		else
			ro_sda <= ro_sda;
	else if(r_ns == S_WR_DATA_ACK)
		if(ro_sda_en)
			ro_sda <= 1'b0;
		else
			ro_sda <= ro_sda;
	else
		if(ro_sda_en)//在scl为低电平sda才可变化，变化在上下沿中间值
			ro_sda <= 1'b1;
		else
			ro_sda <= ro_sda;
end

/******************************************************************************/
always @(posedge i_sclk or negedge i_rst_n) begin	
	if(~i_rst_n)
		r_scl_low_freq_cnt <= 'd0;
	else if(r_ns==S_DEV_ADDR && r_bit_cnt=='d1 && w_scl_neg)
		r_scl_low_freq_cnt <= 'd0;
	else
		r_scl_low_freq_cnt <= r_scl_low_freq_cnt + 1'd1;
end

always @(posedge i_sclk or negedge i_rst_n) begin	
	if(~i_rst_n)
		r_scl_low_freq <= 'd0;
	else if(r_ns==S_DEV_ADDR && r_bit_cnt=='d1 && w_scl_pos)
		r_scl_low_freq <= r_scl_low_freq_cnt;
	else ;
end

always @(posedge i_sclk or negedge i_rst_n) begin	
	if(~i_rst_n)
		ro_sda_en_cnt <= 'd0;
	else if(r_ns != S_IDLE && r_scl_low_freq > 0)
		if(ro_sda_en_cnt == r_scl_low_freq)
			ro_sda_en_cnt <= 0;
		else if(r_scl[3])
			ro_sda_en_cnt <= 0;
		else
			ro_sda_en_cnt <= ro_sda_en_cnt + 1'b1;
	else
		ro_sda_en_cnt <= 0;
end

always @(posedge i_sclk or negedge i_rst_n) begin	
	if(~i_rst_n)
		ro_sda_en <= 0;
	else if(|r_scl_low_freq)
		if(ro_sda_en_cnt == r_scl_low_freq[19:1])
			ro_sda_en <= 1;
		else
			ro_sda_en <= 0;
	else
		ro_sda_en <= 0;
end

always @(posedge i_sclk or negedge i_rst_n) begin	
	if(~i_rst_n)
		r_scl_hight_freq_cnt <= 'd0;
	else if(r_ns==S_DEV_ADDR && r_bit_cnt=='d1 && w_scl_pos)
		r_scl_hight_freq_cnt <= 'd0;
	else if(w_scl_pos || w_scl_neg)
		r_scl_hight_freq_cnt <= 'd0;
	else
		r_scl_hight_freq_cnt <= r_scl_hight_freq_cnt + 1'd1;
end

always @(posedge i_sclk or negedge i_rst_n) begin	
	if(~i_rst_n)
		r_scl_hight_freq <= 'd0;
	else if(r_ns == S_IDLE)
		r_scl_hight_freq <= 'd0;
	else if(r_ns==S_DEV_ADDR && r_bit_cnt=='d2 && w_scl_neg)
		r_scl_hight_freq <= r_scl_hight_freq_cnt;
	else ;
end

always @(posedge i_sclk or negedge i_rst_n) begin	
	if(~i_rst_n)
		r_scl_idle_cnt <= 'd0;
	else if(r_ns != S_IDLE && r_scl_hight_freq > 0)
		if(r_scl_idle_cnt > r_scl_hight_freq + r_scl_hight_freq[19:1])//1.5
			r_scl_idle_cnt <= 0;
		else if(~r_scl[3])
			r_scl_idle_cnt <= 0;
		else
			r_scl_idle_cnt <= r_scl_idle_cnt + 1'b1;
	else
		r_scl_idle_cnt <= 0;
end

always @(posedge i_sclk or negedge i_rst_n) begin	
	if(~i_rst_n)
		r_scl_idle_en <= 0;
	else if(r_scl_idle_cnt > r_scl_hight_freq + r_scl_hight_freq[19:2])
		r_scl_idle_en <= 1;
	else
		r_scl_idle_en <= 0;
end

/******************************************************************************/
always @(posedge i_sclk or negedge i_rst_n) begin
	if(~i_rst_n)
		r_cs <= S_IDLE;
	else if(r_scl_idle_en)
		r_cs <= S_IDLE;
	else
		r_cs <= r_ns;
end

always @(*) begin
	if(~i_rst_n)
		r_ns = S_IDLE;
	else case(r_cs)
		S_IDLE:
			if(w_bus_start)
				r_ns = S_START;
			else
				r_ns = S_IDLE;

		S_START:
			if(w_bus_start)
				r_ns = S_START;
			else if(w_bus_stop)
				r_ns = S_IDLE;
			else if(w_scl_neg)
				r_ns = S_DEV_ADDR;
			else
				r_ns = S_START;
		
		S_DEV_ADDR:
			if(w_bus_start)
				r_ns = S_START;
			else if(w_bus_stop)
				r_ns = S_IDLE;
			else if(r_bit_cnt == 'd8 && w_scl_neg)
				if(r_wr_data_shift[7:1] == r_device_addr[7:1])
					r_ns = S_DEV_ACK;
				else
					r_ns = S_IDLE;
			else
				r_ns = S_DEV_ADDR;
		
		S_DEV_ACK:
			if(w_bus_start)
				r_ns = S_START;
			else if(w_bus_stop)
				r_ns = S_IDLE;
			else if(r_bus_wr_rd && w_scl_neg)
				r_ns = S_RD_DATA;
			else if(~r_bus_wr_rd && w_scl_neg)
				r_ns = S_REG_ADDR;
			else
				r_ns = S_DEV_ACK;
			
		S_REG_ADDR:
			if(w_bus_start)
				r_ns = S_START;
			else if(w_bus_stop)
				r_ns = S_IDLE;
			else if(r_bit_cnt=='d8 && w_scl_neg)
				r_ns = S_REG_ACK;
			else
				r_ns = S_REG_ADDR;
		
		S_REG_ACK:
			if(w_bus_start)
				r_ns = S_START;
			else if(w_bus_stop)
				r_ns = S_IDLE;
			else if(w_scl_neg)
				r_ns = S_WR_DATA;
			else
				r_ns = S_REG_ACK;
		
		S_WR_DATA:
			if(w_bus_start)
				r_ns = S_START;
			else if(w_bus_stop)
				r_ns = S_IDLE;
			else if(r_bit_cnt=='d8 && w_scl_neg)
				r_ns = S_WR_DATA_ACK;
			else
				r_ns = S_WR_DATA;
		
		S_WR_DATA_ACK:
			if(w_bus_start)
				r_ns = S_START;
			else if(w_bus_stop)
				r_ns = S_IDLE;
			else if(w_scl_neg)
				r_ns = S_WR_DATA;
			else
				r_ns = S_WR_DATA_ACK;
		
		S_RD_DATA:
			if(w_bus_start)
				r_ns = S_START;
			else if(w_bus_stop)
				r_ns = S_IDLE;
			else if(~r_bus_wr_rd && w_scl_neg)
				r_ns = S_IDLE;
			else if(r_bit_cnt=='d8 && w_scl_neg)
				r_ns = S_RD_DATA_ACK;
			else
				r_ns = S_RD_DATA;
		
		S_RD_DATA_ACK:
			if(w_bus_start)
				r_ns = S_START;
			else if(w_bus_stop)
				r_ns = S_IDLE;
			else if(w_scl_neg)
				if(r_check_ack)
					r_ns = S_RD_DATA;
				else
					r_ns = S_STOP;
			else
				r_ns = S_RD_DATA_ACK;
		
		S_STOP:
			if(w_bus_start)
				r_ns = S_START;
			else if(w_bus_stop)
				r_ns = S_IDLE;
			else
				r_ns = S_STOP;
		
		default:
			if(w_bus_start)
				r_ns = S_START;
			else if(w_bus_stop)
				r_ns = S_IDLE;
			else
				r_ns = S_IDLE;
		
	endcase
end


generate

	if(p_debug_en == "TRUE") begin : ila
		
		ila_256 u_ila_256(
			 .clk    (i_sclk)
			,.probe0 ({
				 i_rst_n
				,i_device_addr
				,o_rd_addr
				,i_rd_data
				,r_rd_data
				,o_rd_de
				,r_rd_de
				,i_scl
				,i_sda
				,o_sda
				,ro_sda
				,r_cs
				,r_ns
				,r_scl
				,r_sda
				,w_sda_pos
				,w_sda_neg
				,w_scl_pos
				,w_scl_neg
				,r_scl_pos
				,r_scl_neg
				,w_bus_start
				,w_bus_stop
				,r_bit_cnt
				,r_bus_wr_rd
				,r_wr_data_shift
				,r_check_ack
				,r_scl_idle_en
				,r_scl_idle_cnt
				,r_scl_hight_freq
				,r_scl_hight_freq_cnt
				,ro_sda_en
				,ro_sda_en_cnt
				,r_scl_low_freq
				,r_scl_low_freq_cnt
			})
		
		); 

	end
endgenerate



endmodule


