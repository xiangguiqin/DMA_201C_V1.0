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
module i2c_master #(
 parameter [15:0]  p_DIV = 16'd500
) (
 input                           i_rst_n
,input                           i_local_clk

,input                           i_start
,input         [7:0]             i_req_num

,input         [7:0]             i_device_addr
,input         [7:0]             i_reg_addr
,input         [7:0]             i_wr_data
,output reg                      o_wr_done
,output        [7:0]             o_rd_data
,output                          o_rd_valid

,output                          o_busy
,output        [7:0]             o_reg_addr
,output reg    [7:0]             o_ack_erro
,output reg                      o_erro_valid

,output                          o_scl
,input                           i_sda
,output                          o_sda
);

parameter        S_IDLE        = 4'h0     ;
parameter        S_START       = 4'h1     ;
parameter        S_DEV_ADDR    = 4'h3     ;
parameter        S_DEV_ACK     = 4'h2     ;
parameter        S_REG_ADDR    = 4'h6     ;
parameter        S_REG_ACK     = 4'h7     ;
parameter        S_WR_DATA     = 4'h5     ;
parameter        S_WR_DATA_ACK = 4'h4     ;
parameter        S_START2      = 4'hc     ;
parameter        S_DEV_ADDR_RD = 4'hd     ;
parameter        S_DEV_ACK_RD  = 4'hf     ;
parameter        S_RD_DATA     = 4'he     ;
parameter        S_RD_DATA_ACK = 4'ha     ;
parameter        S_STOP        = 4'hb     ;

reg    [3:0]     r_cs                     ;
reg    [3:0]     r_ns                     ;
                                          
reg    [15:0]    r_div_cnt                ;
reg    [2:0]     r_bit_cnt                ;
reg    [7:0]     r_req_cnt                ;
reg    [7:0]     r_device_addr_temp       ;
reg    [7:0]     r_reg_addr_temp          ;
reg    [7:0]     r_device_addr            ;
reg    [7:0]     r_reg_addr               ;
reg              r_scl                    ;
reg              r_sda                    ;
reg              r_sda_ack                ;
reg    [7:0]     r_rd_data                ;
reg              r_rd_valid               ;
reg    [7:0]     r_wr_data                ;
reg              r_wr_done                ;
                                          
wire             w_wr_rd                  ;

assign o_rd_data   = r_rd_data            ;
assign o_rd_valid  = r_rd_valid           ;
assign w_wr_rd     = r_device_addr_temp[0];
assign o_busy      = (r_cs != S_IDLE)     ;
assign o_reg_addr  = r_reg_addr_temp      ;

assign o_scl       = r_scl                ;
assign o_sda       = r_sda                ;

always @(posedge i_local_clk or negedge i_rst_n) begin
	if(~i_rst_n)
		r_div_cnt <= 'd0;
	else case(r_ns == S_IDLE)
		r_div_cnt <= 'd0;
	else if(r_div_cnt == p_DIV-1)
		r_div_cnt <= 'd0;
	else
		r_div_cnt <= r_div_cnt+1;
end

always @(posedge i_local_clk or negedge i_rst_n) begin
	if(~i_rst_n)
		r_bit_cnt <= 'd0;
	else case(r_ns)
		S_DEV_ADDR,S_REG_ADDR,S_WR_DATA,S_DEV_ADDR_RD,S_RD_DATA:
			if(r_div_cnt == p_DIV-1)
				r_bit_cnt <= 'd0;
			else
				r_bit_cnt <= r_bit_cnt+1;
		default:r_bit_cnt <= 'd0;
	endcase
end

always @(posedge i_local_clk or negedge i_rst_n) begin
	if(~i_rst_n)
		r_req_cnt <= 'd0;
	else case(r_ns)
		S_WR_DATA,S_RD_DATA:
			if(r_req_cnt == i_req_num-1)
				r_req_cnt <= i_req_num-1;
			else
				r_req_cnt <= r_req_cnt+1;
		default:r_req_cnt <= 'd0;
	endcase
end

always @(posedge i_local_clk or negedge i_rst_n) begin
	if(~i_rst_n) begin
		r_device_addr_temp <= 'd0;
		r_reg_addr_temp    <= 'd0;
	end else case(r_ns)
		S_IDLE:
			if(i_start) begin
				r_device_addr_temp <= i_device_addr;
				r_reg_addr_temp    <= i_reg_addr;
			end else ;
		S_WR_DATA_ACK:
			if(r_div_cnt == p_DIV[15:1]-1 && ~r_sda_ack)
				r_reg_addr_temp    <= r_reg_addr_temp+1;
			else ;
		S_RD_DATA_ACK:
			if(r_div_cnt == p_DIV[15:1]-1)
				r_reg_addr_temp    <= r_reg_addr_temp+1;
			else ;
		default: begin
			r_device_addr_temp <= r_device_addr_temp;
			r_reg_addr_temp    <= r_reg_addr_temp;
		end
	endcase
end

always @(posedge i_local_clk or negedge i_rst_n) begin
	if(~i_rst_n)
		r_device_addr <= 'd0;
	else if(r_ns==S_START)
		r_device_addr <= {r_device_addr_temp[7:1],1'b0};
	else if(S_START2)
		r_device_addr <= r_device_addr_temp;
	else if((r_ns==S_DEV_ADDR) || (r_ns==S_DEV_ADDR_RD))
		if(r_div_cnt == p_DIV-1)
			r_device_addr <= {r_device_addr[6:0],1'b0};
		else ;
	else ;
end

always @(posedge i_local_clk or negedge i_rst_n) begin
	if(~i_rst_n)
		r_reg_addr <= 'd0;
	else if(r_ns==S_START || r_ns==S_WR_DATA_ACK || r_ns==S_RD_DATA_ACK)
		r_reg_addr <= r_reg_addr_temp;
	else if(r_ns==S_REG_ADDR)
		if(r_div_cnt == p_DIV-1)
			r_reg_addr <= {r_reg_addr[6:0],1'b0};
		else ;
	else ;
end

always @(posedge i_local_clk or negedge i_rst_n) begin
	if(~i_rst_n)
		r_wr_data <= 'd0;
	else case(r_ns)
		S_REG_ACK,S_WR_DATA_ACK:
			r_wr_data <= i_wr_data;
		S_WR_DATA:
			if(r_div_cnt == p_DIV-1)
				r_wr_data <= {r_wr_data[6:0],1'b0};
			else ;
		default:r_wr_data <= 'd0;
	endcase
end

always @(posedge i_local_clk or negedge i_rst_n) begin
	if(~i_rst_n)
		o_wr_done <= 'd0;
	else if(r_ns == S_WR_DATA_ACK && r_div_cnt == p_DIV[15:1]-1 && ~r_sda_ack)
		o_wr_done <= 'd1;
	else
		o_wr_done <= 'd0;
end

always @(posedge i_local_clk or negedge i_rst_n) begin
	if(~i_rst_n)
		r_sda_ack <= 'd1;
	else case(r_ns)
		S_DEV_ACK,S_REG_ACK,S_WR_DATA_ACK,S_DEV_ACK_RD:
			if(r_div_cnt <= p_DIV[15:2]-1)
				r_sda_ack <= i_sda;
			else ;
		default:r_sda_ack <= 'd1;
	endcase
end

always @(posedge i_local_clk or negedge i_rst_n) begin
	if(~i_rst_n)
		r_rd_data <= 'd0;
	else if(r_ns == S_RD_DATA && r_div_cnt == p_DIV[15:2]-1)
		r_rd_data <= {r_rd_data[6:0],i_sda};
	else ;
end

always @(posedge i_local_clk or negedge i_rst_n) begin
	if(~i_rst_n)
		r_rd_valid <= 'd0;
	else if(r_ns == S_RD_DATA && r_bit_cnt >= 8-1 && r_div_cnt == p_DIV-1)
		r_rd_valid <= 'd1;
	else
		r_rd_valid <= 'd0;
end

always @(posedge i_local_clk or negedge i_rst_n) begin
	if(~i_rst_n) begin
		o_ack_erro   <= 'h0;
		o_erro_valid <= 'd0;
	end else case(r_ns)
		S_DEV_ACK:
			if(r_div_cnt == p_DIV-1 && r_sda_ack) begin
				o_ack_erro   <= 'h1;
				o_erro_valid <= 'd1;
			end else begin
				o_ack_erro   <= 'h0;
				o_erro_valid <= 'd0;
			end
		S_REG_ACK:
			if(r_div_cnt == p_DIV-1 && r_sda_ack) begin
				o_ack_erro   <= 'h2;
				o_erro_valid <= 'd1;
			end else begin
				o_ack_erro   <= 'h0;
				o_erro_valid <= 'd0;
			end
		S_WR_DATA_ACK:
			if(r_div_cnt == p_DIV-1 && r_sda_ack) begin
				o_ack_erro   <= 'h4;
				o_erro_valid <= 'd1;
			end else begin
				o_ack_erro   <= 'h0;
				o_erro_valid <= 'd0;
			end
		S_DEV_ACK_RD:
			if(r_div_cnt == p_DIV-1 && r_sda_ack) begin
				o_ack_erro   <= 'h8;
				o_erro_valid <= 'd1;
			end else begin
				o_ack_erro   <= 'h0;
				o_erro_valid <= 'd0;
			end
		default: begin
			o_ack_erro   <= 'd0;
			o_erro_valid <= 'd0;
		end
	endcase
end

always @(posedge i_local_clk or negedge i_rst_n) begin
	if(~i_rst_n) begin
		r_scl <= 'd1;
		r_sda <= 'd1;
	end else case(r_ns)
		S_IDLE: begin
			r_scl <= 'd1;
			r_sda <= 'd1;
		end
		S_START: begin
			if(r_div_cnt <= p_DIV[15:2]-1)
				r_sda <= 'd1;
			else
				r_sda <= 'd0;
			if(r_div_cnt <= p_DIV[15:1]-1)
				r_scl <= 'd1;
			else
				r_scl <= 'd0;
		end
		S_DEV_ADDR: begin
			if(r_div_cnt <= p_DIV[15:1]-1)
				r_scl <= 1;
			else
				r_scl <= 0;
			if(r_div_cnt == p_DIV[15:1]+p_DIV[15:2]-1)
				r_sda <= r_device_addr[7];
			else ;
		end
		S_DEV_ACK: begin
			r_sda <= 'd1;
			if(r_div_cnt <= p_DIV[15:1]-1)
				r_scl <= 1;
			else
				r_scl <= 0;
		end
		S_REG_ADDR: begin
			if(r_div_cnt <= p_DIV[15:1]-1)
				r_scl <= 1;
			else
				r_scl <= 0;
			if(r_div_cnt == p_DIV[15:1]+p_DIV[15:2]-1)
				r_sda <= r_reg_addr[7];
			else ;
		end
		S_REG_ACK: begin
			r_sda <= 'd1;
			if(r_div_cnt <= p_DIV[15:1]-1)
				r_scl <= 1;
			else
				r_scl <= 0;
		end
		S_WR_DATA: begin
			if(r_div_cnt <= p_DIV[15:1]-1)
				r_scl <= 1;
			else
				r_scl <= 0;
			if(r_div_cnt == p_DIV[15:1]+p_DIV[15:2]-1)
				r_sda <= r_wr_data[7];
			else ;
		end
		S_WR_DATA_ACK: begin
			r_sda <= 'd1;
			if(r_div_cnt <= p_DIV[15:1]-1)
				r_scl <= 1;
			else
				r_scl <= 0;
		end
		S_START2: begin
			if(r_div_cnt <= p_DIV[15:2]-1)
				r_sda <= 'd1;
			else
				r_sda <= 'd0;
			if(r_div_cnt <= p_DIV[15:1]-1)
				r_scl <= 'd1;
			else
				r_scl <= 'd0;
		end
		S_DEV_ADDR_RD: begin
			if(r_div_cnt <= p_DIV[15:1]-1)
				r_scl <= 1;
			else
				r_scl <= 0;
			if(r_div_cnt == p_DIV[15:1]+p_DIV[15:2]-1)
				r_sda <= r_device_addr[7];
			else ;
		end
		S_DEV_ACK_RD: begin
			r_sda <= 'd1;
			if(r_div_cnt <= p_DIV[15:1]-1)
				r_scl <= 1;
			else
				r_scl <= 0;
		end
		S_RD_DATA: begin
			r_sda <= 1;
			if(r_div_cnt <= p_DIV[15:1]-1)
				r_scl <= 1;
			else
				r_scl <= 0;
		end
		S_RD_DATA_ACK: begin
			if(r_div_cnt <= p_DIV[15:1]-1)
				r_scl <= 1;
			else
				r_scl <= 0;
			if(r_div_cnt == p_DIV[15:1]+p_DIV[15:2]-1)
				if(i_req_num == r_req_cnt-1)
					r_sda <= 1;
				else
					r_sda <= 0;
			else ;
		end
		S_STOP: begin
			if(r_div_cnt <= p_DIV[15:1]+p_DIV[15:2]-1)
				r_sda <= 'd0;
			else
				r_sda <= 'd1;
			if(r_div_cnt <= p_DIV[15:1]-1)
				r_scl <= 'd0;
			else
				r_scl <= 'd1;
		end
		default: begin
			r_scl <= 1;
			r_sda <= 1;
		end
	endcase
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
			if(i_start)
				r_ns = S_START;
			else
				r_ns = S_IDLE;
		S_START:
			if(r_div_cnt == p_DIV-1)
				r_ns = S_DATA;
			else
				r_ns = S_START;
		S_DEV_ADDR:
			if(r_bit_cnt >= 8-1 && r_div_cnt == p_DIV-1)
				r_ns = S_DEV_ACK;
			else
				r_ns = S_DEV_ADDR;
		S_DEV_ACK:
			if(r_div_cnt == p_DIV-1 && r_sda_ack)
				r_ns = S_IDLE;
			else if(r_div_cnt == p_DIV-1 && ~r_sda_ack)
				r_ns = S_REG_ADDR;
			else
				r_ns = S_DEV_ACK;
		S_REG_ADDR:
			if(r_bit_cnt >= 8-1 && r_div_cnt == p_DIV-1)
				r_ns = S_REG_ACK;
			else
				r_ns = S_REG_ADDR;
		S_REG_ACK:
			if(r_div_cnt == p_DIV-1 && r_sda_ack)
				r_ns = S_IDLE;
			else if(r_div_cnt == p_DIV-1 && ~r_sda_ack)
				if(~w_wr_rd)
					r_ns = S_WR_DATA;
				else
					r_ns = S_START2;
			else
				r_ns = S_REG_ACK;
		S_WR_DATA:
			if(r_bit_cnt >= 8-1 && r_div_cnt == p_DIV-1)
				r_ns = S_WR_DATA_ACK;
			else
				r_ns = S_WR_DATA;
		S_WR_DATA_ACK:
			if(r_div_cnt == p_DIV-1)
				if(r_sda_ack)
					r_ns = S_IDLE;
				else if(i_req_num == i_req_cnt-1)
					r_ns = S_STOP;
				else
					r_ns = S_WR_DATA;
			else
				r_ns = S_WR_DATA_ACK;
		S_START2:
			if(r_div_cnt == p_DIV-1)
				r_ns = S_DEV_ADDR_RD;
			else
				r_ns = S_START2;
		S_DEV_ADDR_RD:
			if(r_bit_cnt >= 8-1 && r_div_cnt == p_DIV-1)
				r_ns = S_DEV_ACK_RD;
			else
				r_ns = S_DEV_ADDR_RD;
		S_DEV_ACK_RD:
			if(r_div_cnt == p_DIV-1 && r_sda_ack)
				r_ns = S_IDLE;
			else if(r_div_cnt == p_DIV-1 && ~r_sda_ack)
				r_ns = S_RD_DATA;
			else
				r_ns = S_DEV_ACK_RD;
		S_RD_DATA:
			if(r_bit_cnt >= 8-1 && r_div_cnt == p_DIV-1)
				r_ns = S_RD_DATA_ACK;
			else
				r_ns = S_RD_DATA;
		S_RD_DATA_ACK:
			if(r_div_cnt == p_DIV-1)
				if(i_req_num == r_req_cnt-1)
					r_ns = S_STOP;
				else
					r_ns = S_RD_DATA;
			else
				r_ns = S_RD_DATA_ACK;
		S_STOP:
			if(r_div_cnt == p_DIV-1)
				r_ns = S_IDLE;
			else
				r_ns = S_STOP;
		default:
			r_ns = S_IDLE;
	endcase
end




endmodule


