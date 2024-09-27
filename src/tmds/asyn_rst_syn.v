//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           asyn_rst_syn
// Last modified Date:  2019/7/1 9:30:00
// Last Version:        V1.1
// Descriptions:        异步复位，同步释放，并转换成高电平有效
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2019/7/1 9:30:00
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module asyn_rst_syn(
 input  i_clk
,input  i_rst_n
    
,output o_syn_reset
);
    
//reg define
reg [1:0]r_reset;
    
//*****************************************************
//**                    main code
//***************************************************** 
assign o_syn_reset  = r_reset[1];
    
//对异步复位信号进行同步释放，并转换成高有效
always @ (posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        r_reset <= 2'b1;
    end
    else begin
        r_reset <= {r_reset[0], 1'b0};
    end
end
    
endmodule