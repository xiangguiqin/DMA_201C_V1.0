//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           hdmi_transmitter_top
// Last modified Date:  2019/7/1 9:30:00
// Last Version:        V1.1
// Descriptions:        DVI发送端顶层模块
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2019/7/1 9:30:00
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module hdmi_transmitter_top(
 input              i_pixel_clk           // pixel clock
,input              i_serial_clk_x5        // pixel clock x5
,input              i_rst_n        // reset

,input    [23:0]    i_video_data      // RGB888 video in
,input              i_hsync    // hsync data
,input              i_vsync    // vsync data
,input              i_de       // data enable

,output             oTMDS_CLK_P    // TMDS 时钟通道
,output             oTMDS_CLK_N 
,output    [2:0]    oTMDS_DATA_P   // TMDS 数据通道
,output    [2:0]    oTMDS_DATA_N
,output             oTMDS_EN      // TMDS 输出使能
);
    
//wire define    
wire        w_rst       ;
//并行数据
wire [9:0]  w_red10bit  ;
wire [9:0]  w_green10bit;
wire [9:0]  w_blue10bit ;
wire [9:0]  w_clk10bit  ;
  
//串行数据
wire [2:0]  w_TMDS_data_serial;
wire        w_TMDS_clk_serial ;

//*****************************************************
//**                    main code
//***************************************************** 
assign oTMDS_EN = 1'b1            ;  
assign w_clk10bit = 10'b1111100000;

//异步复位，同步释放
asyn_rst_syn reset_syn(
 .i_clk       (i_pixel_clk )
,.i_rst_n     (i_rst_n     )

,.o_syn_reset (w_rst       )
);
  
//对三个颜色通道进行编码
dvi_encoder encoder_b(
 .clkin     (i_pixel_clk       )
,.rstin	    (w_rst             )

,.din       (i_video_data[7:0] )
,.c0        (i_hsync           )
,.c1        (i_vsync           )
,.de        (i_de              )
,.dout		(w_blue10bit       )
);

dvi_encoder encoder_g(
 .clkin     (i_pixel_clk        )
,.rstin	    (w_rst              )

,.din		(i_video_data[15:8] )
,.c0        (1'b0               )
,.c1        (1'b0               )
,.de        (i_de               )
,.dout		(w_green10bit       )
);

dvi_encoder encoder_r(
 .clkin     (i_pixel_clk         )
,.rstin	    (w_rst               )

,.din		(i_video_data[23:16] )
,.c0        (1'b0                )
,.c1        (1'b0                )
,.de        (i_de                )
,.dout		(w_red10bit          )
);
    
//对编码后的数据进行并串转换
serializer_10_to_1 serializer_b(
 .reset              (w_rst                 ) // 复位,高有效
,.paralell_clk       (i_pixel_clk           ) // 输入并行数据时钟
,.serial_clk_5x      (i_serial_clk_x5       ) // 输入串行数据时钟
,.paralell_data      (w_blue10bit           ) // 输入并行数据

,.serial_data_out    (w_TMDS_data_serial[0] ) // 输出串行数据
);    
    
serializer_10_to_1 serializer_g(
 .reset              (w_rst                 )
,.paralell_clk       (i_pixel_clk           )
,.serial_clk_5x      (i_serial_clk_x5       )
,.paralell_data      (w_green10bit          )

,.serial_data_out    (w_TMDS_data_serial[1] )
);
    
serializer_10_to_1 serializer_r(
 .reset              (w_rst                 )
,.paralell_clk       (i_pixel_clk           )
,.serial_clk_5x      (i_serial_clk_x5       )
,.paralell_data      (w_red10bit            )

,.serial_data_out    (w_TMDS_data_serial[2] )
);
            
serializer_10_to_1 serializer_clk(
 .reset              (w_rst             )
,.paralell_clk       (i_pixel_clk       )
,.serial_clk_5x      (i_serial_clk_x5   )
,.paralell_data      (w_clk10bit        )

,.serial_data_out    (w_TMDS_clk_serial )
);
    
//转换差分信号  
OBUFDS #(
 .IOSTANDARD  ("TMDS_33")    // I/O电平标准为TMDS
) TMDS0 (
 .I  (w_TMDS_data_serial[0] )
,.O  (oTMDS_DATA_P[0]       )
,.OB (oTMDS_DATA_N[0]       ) 
);

OBUFDS #(
 .IOSTANDARD  ("TMDS_33")    // I/O电平标准为TMDS
) TMDS1 (
 .I  (w_TMDS_data_serial[1] )
,.O  (oTMDS_DATA_P[1]       )
,.OB (oTMDS_DATA_N[1]       ) 
);

OBUFDS #(
 .IOSTANDARD  ("TMDS_33")    // I/O电平标准为TMDS
) TMDS2 (
 .I  (w_TMDS_data_serial[2] )
,.O  (oTMDS_DATA_P[2]       )
,.OB (oTMDS_DATA_N[2]       )
);

OBUFDS #(
 .IOSTANDARD  ("TMDS_33")    // I/O电平标准为TMDS
) TMDS3 (
 .I  (w_TMDS_clk_serial )
,.O  (oTMDS_CLK_P       )
,.OB (oTMDS_CLK_N       )
);



endmodule


