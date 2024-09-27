`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:
// Design Name:    
// Module Name:    iic_top
// Project Name:   
// Target Device:  
// Tool versions:  
// Description:
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////
module iic_com(
			clk,
			rst_n,
			scl,
			sda			
		);

input clk;		// 27MHz
input rst_n;	//复位信号，低有效
(* mark_debug = "true" *)output scl;		// 24C02的时钟端口
(* mark_debug = "true" *)inout sda;		// 24C02的数据端口
//output[7:0] dis_data;	//数码管显示的数据

//--------------------------------------------

reg[19:0] cnt_20ms;	//20ms计数寄存器

always @ (posedge clk or negedge rst_n)
	if(!rst_n) cnt_20ms <= 20'd0;
	else cnt_20ms <= cnt_20ms+1'b1;	//不断计数



//---------------------------------------------
		//分频部分
reg[2:0] cnt;	// cnt=0:scl上升沿，cnt=1:scl高电平中间，cnt=2:scl下降沿，cnt=3:scl低电平中间
reg[10:0] cnt_delay;	//1000循环计数，产生iic所需要的时钟
reg scl_r=1;		//时钟脉冲寄存器

always @ (posedge clk or negedge rst_n)
	if(!rst_n) cnt_delay <= 11'd0;
	else if(cnt_delay == 11'd999) cnt_delay <= 11'd0;	//计数到10us为scl的周期，即100KHz
	else cnt_delay <= cnt_delay+1'b1;	//时钟计数

always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) cnt <= 3'd5;
	else begin
		case (cnt_delay)
			11'd249:	cnt <= 3'd1;	//cnt=1:scl高电平中间,用于数据采样
			11'd499:	cnt <= 3'd2;	//cnt=2:scl下降沿
			11'd749:	cnt <= 3'd3;	//cnt=3:scl低电平中间,用于数据变化
			11'd999:	cnt <= 3'd0;	//cnt=0:scl上升沿
			default: cnt <= 3'd5;
			endcase
		end
end


`define SCL_POS		(cnt==3'd0)		//cnt=0:scl上升沿
`define SCL_HIG		(cnt==3'd1)		//cnt=1:scl高电平中间,用于数据采样
`define SCL_NEG		(cnt==3'd2)		//cnt=2:scl下降沿
`define SCL_LOW		(cnt==3'd3)		//cnt=3:scl低电平中间,用于数据变化


always @ (posedge clk or negedge rst_n)
	if(!rst_n) scl_r <= 1'b1;
	else if(cnt==3'd0) scl_r <= 1'b1;	//scl信号上升沿
   	else if(cnt==3'd2) scl_r <= 1'b0;	//scl信号下降沿

assign scl = scl_r;	//产生iic所需要的时钟
//---------------------------------------------
		//需要写入24C02的地址和数据
				
`define	DEVICE_READ		8'b1001_0001	//被寻址器件地址（读操作）
`define  DEVICE_WRITE	8'b1001_0000	//被寻址器件地址（写操作）
(* mark_debug = "true" *)reg[7:0] db_r;		//在IIC上传送的数据寄存器
(* mark_debug = "true" *)reg[7:0] read_data;	//读出EEPROM的数据寄存器


reg[15:0] LUT_DATA;
reg	[4:0]	LUT_INDEX;
//--------------------------------------
parameter	LUT_SIZE	=	4-1;

parameter	General_Control_0	=	0;
parameter	General_Control_1	=	1;
parameter	General_Control_2   =	2;
parameter	General_Control_3	=	3;
parameter	General_Control_4	=	4;
parameter	General_Control_5	=	5;
//---------------------------------------------
//---------------------------------------------
		//读、写时序
parameter 	IDLE 	= 4'd0;
parameter 	START1 	= 4'd1;
parameter 	ADD1 	= 4'd2;
parameter 	ACK1 	= 4'd3;
parameter 	ADD2 	= 4'd4;
parameter 	ACK2 	= 4'd5;
parameter 	START2 	= 4'd6;
parameter 	ADD3 	= 4'd7;
parameter 	ACK3	= 4'd8;
parameter 	DATA 	= 4'd9;
parameter 	ACK4	= 4'd10;
parameter 	STOP1 	= 4'd11;
parameter 	STOP2 	= 4'd12;

(* mark_debug = "true" *)reg[3:0] cstate;	//状态寄存器
reg sda_r=1;		//输出数据寄存器
reg sda_link;	//输出数据sda信号inout方向控制位		
reg[3:0] num;	//

(* mark_debug = "true" *) reg wr_en,rd_en;//不允许同时为1。
always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) begin
			cstate <= IDLE;
			sda_r <= 1'b1;
			sda_link <= 1'b0;
			num <= 4'd0;
			read_data <= 8'b0000_0000;
			LUT_INDEX <= 0;
			wr_en       <=1;
			rd_en       <=0;
		end
	else 	  
		case (cstate)
			IDLE:	begin
					sda_link <= 1'b1;			//数据线sda为input
					sda_r <= 1'b1;
					if(wr_en|rd_en) begin	//SW1,SW2键有一个被按下			
						db_r <= `DEVICE_WRITE;	//送器件地址（写操作）
						cstate <= START1;		
						end
					else cstate <= IDLE;	//没有任何键被按下
				end
			START1: begin
					if(`SCL_HIG) begin		//scl为高电平期间
						sda_link <= 1'b1;	//数据线sda为output
						sda_r <= 1'b0;		//拉低数据线sda，产生起始位信号
						cstate <= ADD1;
						num <= 4'd0;		//num计数清零
						end
					else cstate <= START1; //等待scl高电平中间位置到来
				end
			ADD1:	begin
					if(`SCL_LOW) begin
							if(num == 4'd8) begin	
									num <= 4'd0;			//num计数清零
									sda_r <= 1'b1;
									sda_link <= 1'b0;		//sda置为高阻态(input)
									cstate <= ACK1;
								end
							else begin
									cstate <= ADD1;
									num <= num+1'b1;
									case (num)
										4'd0: sda_r <= db_r[7];
										4'd1: sda_r <= db_r[6];
										4'd2: sda_r <= db_r[5];
										4'd3: sda_r <= db_r[4];
										4'd4: sda_r <= db_r[3];
										4'd5: sda_r <= db_r[2];
										4'd6: sda_r <= db_r[1];
										4'd7: sda_r <= db_r[0];
										default: ;
										endcase
							//		sda_r <= db_r[4'd7-num];	//送器件地址，从高位开始
								end
						end
			//		else if(`SCL_POS) db_r <= {db_r[6:0],1'b0};	//器件地址左移1bit
					else cstate <= ADD1;
				end
			ACK1:	begin
			// if(`SCL_POS) begin
					if(!sda) begin	//注：24C01/02/04/08/16器件可以不考虑应答位
							cstate <= ADD2;	//从机响应信号
							db_r <= LUT_DATA[15:8];//`BYTE_ADDR;	// 1地址	
						end
					else cstate <= ACK1;		//等待从机响应
				end
		//	end
			ADD2:	begin
					if(`SCL_LOW) begin
							if(num==4'd8) begin	
									num <= 4'd0;			//num计数清零
									sda_r <= 1'b1;
									sda_link <= 1'b0;		//sda置为高阻态(input)
									cstate <= ACK2;
								end
							else begin
									sda_link <= 1'b1;		//sda作为output
									num <= num+1'b1;
									case (num)
										4'd0: sda_r <= db_r[7];
										4'd1: sda_r <= db_r[6];
										4'd2: sda_r <= db_r[5];
										4'd3: sda_r <= db_r[4];
										4'd4: sda_r <= db_r[3];
										4'd5: sda_r <= db_r[2];
										4'd6: sda_r <= db_r[1];
										4'd7: sda_r <= db_r[0];
										default: ;
										endcase
							//		sda_r <= db_r[4'd7-num];	//送EEPROM地址（高bit开始）		
									cstate <= ADD2;					
								end
						end
			//		else if(`SCL_POS) db_r <= {db_r[6:0],1'b0};	//器件地址左移1bit
					else cstate <= ADD2;				
				end
			ACK2:	begin
					if(!sda) begin		//从机响应信号
						if(wr_en) begin
								cstate <= DATA; 	//写操作
								db_r <= LUT_DATA[7:0];//`WRITE_DATA;	//写入的数据						
							end	
						else if(rd_en) begin
								db_r <= `DEVICE_READ;	//送器件地址（读操作），特定地址读需要执行该步骤以下操作
								cstate <= START2;		//读操作
							end
						end
					else cstate <= ACK2;	//等待从机响应
				end
			START2: begin	//读操作起始位
					if(`SCL_LOW) begin
						sda_link <= 1'b1;	//sda作为output
						sda_r <= 1'b1;		//拉高数据线sda
						cstate <= START2;
						end
					else if(`SCL_HIG) begin	//scl为高电平中间
						sda_r <= 1'b0;		//拉低数据线sda，产生起始位信号
						cstate <= ADD3;
						end	 
					else cstate <= START2;
				end
			ADD3:	begin	//送读操作地址
					if(`SCL_LOW) begin
							if(num==4'd8) begin	
									num <= 4'd0;			//num计数清零
									sda_r <= 1'b1;
									sda_link <= 1'b0;		//sda置为高阻态(input)
									cstate <= ACK3;
								end
							else begin
									num <= num+1'b1;
									case (num)
										4'd0: sda_r <= db_r[7];
										4'd1: sda_r <= db_r[6];
										4'd2: sda_r <= db_r[5];
										4'd3: sda_r <= db_r[4];
										4'd4: sda_r <= db_r[3];
										4'd5: sda_r <= db_r[2];
										4'd6: sda_r <= db_r[1];
										4'd7: sda_r <= db_r[0];
										default: ;
										endcase									
								//	sda_r <= db_r[4'd7-num];	//送EEPROM地址（高bit开始）		
									cstate <= ADD3;					
								end
						end
				//	else if(`SCL_POS) db_r <= {db_r[6:0],1'b0};	//器件地址左移1bit
					else cstate <= ADD3;				
				end
			ACK3:	begin
					if(!sda) begin
							cstate <= DATA;	//从机响应信号
							sda_link <= 1'b0;
						end
					else cstate <= ACK3; 		//等待从机响应
				end
			DATA:	begin
					if(rd_en) begin	 //读操作
							if(num<=4'd7) begin
								cstate <= DATA;
								if(`SCL_HIG) begin	
									num <= num+1'b1;	
									case (num)
										4'd0: read_data[7] <= sda;
										4'd1: read_data[6] <= sda;  
										4'd2: read_data[5] <= sda; 
										4'd3: read_data[4] <= sda; 
										4'd4: read_data[3] <= sda; 
										4'd5: read_data[2] <= sda; 
										4'd6: read_data[1] <= sda; 
										4'd7: read_data[0] <= sda; 
										default: ;
										endcase																		
					//				read_data[4'd7-num] <= sda;	//读数据（高bit开始）
									end
				//				else if(`SCL_NEG) read_data <= {read_data[6:0],read_data[7]};	//数据循环右移
								end
							else if((`SCL_LOW) && (num==4'd8)) begin
								num <= 4'd0;			//num计数清零
								cstate <= ACK4;
								end
							else cstate <= DATA;
						end
					else if(wr_en) begin	//写操作
							sda_link <= 1'b1;	
							if(num<=4'd7) begin
								cstate <= DATA;
								if(`SCL_LOW) begin
									sda_link <= 1'b1;		//数据线sda作为output
									num <= num+1'b1;
									case (num)
										4'd0: sda_r <= db_r[7];
										4'd1: sda_r <= db_r[6];
										4'd2: sda_r <= db_r[5];
										4'd3: sda_r <= db_r[4];
										4'd4: sda_r <= db_r[3];
										4'd5: sda_r <= db_r[2];
										4'd6: sda_r <= db_r[1];
										4'd7: sda_r <= db_r[0];
										default: ;
										endcase									
								//	sda_r <= db_r[4'd7-num];	//写入数据（高bit开始）
									end
			//					else if(`SCL_POS) db_r <= {db_r[6:0],1'b0};	//写入数据左移1bit
							 	end
							else if((`SCL_LOW) && (num==4'd8)) begin
									num <= 4'd0;
									sda_r <= 1'b1;
									sda_link <= 1'b0;		//sda置为高阻态
									cstate <= ACK4;
								end
							else cstate <= DATA;
						end
				end
			ACK4: begin
					if(/*!sda*/`SCL_NEG) begin
//						sda_r <= 1'b1;
						cstate <= STOP1;	
						end
					else cstate <= ACK4;
				end
			STOP1:	begin
					if(`SCL_LOW) begin
							sda_link <= 1'b1;
							sda_r <= 1'b0;
							cstate <= STOP1;
						end
					else if(`SCL_HIG) begin
							sda_r <= 1'b1;	//scl为高时，sda产生上升沿（结束信号）
							cstate <= STOP2;
						end
					else cstate <= STOP1;
				end
			STOP2:	begin
					if(`SCL_LOW) sda_r <= 1'b1;
					else if(cnt_20ms==20'h7fff0)begin
					        if((LUT_INDEX < LUT_SIZE)) begin
					        cstate <= IDLE;
					        LUT_INDEX <= LUT_INDEX +1;
					        end
					        else if((LUT_INDEX >= LUT_SIZE)&wr_en) begin
					         cstate <= IDLE;
					        LUT_INDEX <= 0;  
					        wr_en   <= 0; 
					        rd_en   <= 0;
					        end
					        else if((LUT_INDEX >= LUT_SIZE)&rd_en) begin
					         cstate <= STOP2;
					        end
					    end
					else cstate <= STOP2;
				end
			default: cstate <= IDLE;
			endcase
end

assign sda = sda_link ? sda_r:1'bz;
//assign dis_data = read_data;


always@(posedge clk )
begin
	case(LUT_INDEX)
	//	Audio Config Data
	General_Control_0	:	LUT_DATA	<=	16'h5100;//选择端口0
	General_Control_1	:	LUT_DATA	<=	16'h6500;//[5:4] 00-RGB444  01-yuv422  10-yuv444
	General_Control_2	:	LUT_DATA	<=	16'h7108; //输入颜色选择

	
	default:		LUT_DATA	<=	16'hxxxx;
	endcase

end
//---------------------------------------------
//wire [49:0] probe0;
//ila_0 u_ila (
//	.clk(clk), // input wire clk
//	.probe0(probe0) // input wire [49:0] probe0
//);
//assign probe0[0] = scl;
//assign probe0[1] = sda;
//assign probe0[5:2] =cstate;
//assign probe0[13:6] =db_r;
//assign probe0[21:14] =read_data;
//assign probe0[22] =wr_en;
//assign probe0[23] =rd_en;
//assign probe0[28:24] =LUT_INDEX;
//assign probe0[29] =sda_link;
endmodule


