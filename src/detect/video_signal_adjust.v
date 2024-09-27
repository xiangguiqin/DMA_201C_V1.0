`timescale 1ns/1ps
module video_signal_adjust #(
 parameter pDATA_WIDTH = 'd16
) (
 input			              i_clk         			
,input			              i_rst_n           
,input			              i_vsyn             
,input			              i_hsyn             
,input			              i_de		        
,input	[pDATA_WIDTH-1:0]     i_video_data         
,output			              o_vsyn             
,output			              o_hsyn             
,output			              o_de		        
,output	[pDATA_WIDTH-1:0]     o_video_data
);

video_syn_detect uvs_video_syn_detect(
 .i_clk           (i_clk   )
,.i_rst_n         (i_rst_n )
,.i_low_more_flag (1'b1    )
,.i_video_vsyn    (i_vsyn  )
,.o_video_vsyn    (o_vsyn  )
);

video_syn_detect uhs_video_syn_detect(
 .i_clk           (i_clk   )
,.i_rst_n         (i_rst_n )
,.i_low_more_flag (1'b1    )
,.i_video_vsyn    (i_hsyn  )
,.o_video_vsyn    (o_hsyn  )
);

video_syn_detect ude_video_syn_detect(
 .i_clk           (i_clk   )
,.i_rst_n         (i_rst_n )
,.i_low_more_flag (1'b0    )
,.i_video_vsyn    (i_de    )
,.o_video_vsyn    (o_de    )
);

defparam  udata_F_delay.pSIZE   = pDATA_WIDTH;
defparam  udata_F_delay.pDELAY  = 2;
F_delay udata_F_delay(
 .i_clk   (i_clk        )
,.i_rst_n (i_rst_n      )
,.i_data  (i_video_data )
,.o_data  (o_video_data )
);



endmodule


