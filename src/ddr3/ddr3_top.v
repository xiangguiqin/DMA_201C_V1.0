`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/11 14:04:51
// Design Name: 
// Module Name: DDR_Top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ddr_top(
 input                 i_local_clk // 200M
,input                 i_rst_n
,output                o_init_done
,input                 i_src0_clk
,input                 i_src_valid
,input                 i_src0_vsyn
,input                 i_src0_de
,input       [23:0]    i_src0_data

,input                 i_src1_clk
,input                 i_src1_valid
,input                 i_src1_vsyn
,input                 i_src1_de
,input       [23:0]    i_src1_data

,input                 i_dst0_clk
,input                 i_dst0_vsyn
,input				   i_dst0_rd
,output                o_dst0_de
,output      [23:0]    o_dst0_data

,input                 i_dst1_clk
,input                 i_dst1_vsyn
,input				   i_dst1_rd
,output                o_dst1_de
,output      [23:0]    o_dst1_data

,inout     [31:0]      ddr3_dq
,inout     [ 3:0]      ddr3_dqs_n
,inout     [ 3:0]      ddr3_dqs_p
,output    [12:0]      ddr3_addr
,output    [ 2:0]      ddr3_ba
,output                ddr3_ras_n
,output                ddr3_cas_n
,output                ddr3_we_n
,output                ddr3_reset_n
,output    [ 0:0]      ddr3_ck_p
,output    [ 0:0]      ddr3_ck_n
,output    [ 0:0]      ddr3_cke
,output    [ 3:0]      ddr3_dm
,output    [ 0:0]      ddr3_odt
);


wire                  w_clk_ref_200M        ;
wire                  w_sys_clk_200M        ;

wire    [ 26:0]       app_addr              ;
wire    [  2:0]       app_cmd               ;
wire                  app_en                ;
wire    [255:0]       app_wdf_data          ;
wire                  app_wdf_end           ;
wire    [ 31:0]       app_wdf_mask          ;
wire                  app_wdf_wren          ;
wire    [255:0]       app_rd_data           ;
wire                  app_rd_data_end       ;
wire                  app_rd_data_valid     ;
wire                  app_rdy               ;
wire                  app_wdf_rdy           ;
wire                  ui_clk                ;
wire                  ui_clk_sync_rst       ;
wire                  init_calib_complete   ;
wire    [ 11:0]       device_temp           ;


assign w_clk_ref_200M = i_local_clk;
assign w_sys_clk_200M = i_local_clk;

assign app_wdf_mask = 32'd0;

assign o_init_done = init_calib_complete;

mig_7series_0 mig_7series_0_u0(
// Inouts
 .ddr3_dq             (ddr3_dq            )//io[ 31:0]
,.ddr3_dqs_n          (ddr3_dqs_n         )//io[  3:0]
,.ddr3_dqs_p          (ddr3_dqs_p         )//io[  3:0]
,.ddr3_addr           (ddr3_addr          )//o [ 12:0]
,.ddr3_ba             (ddr3_ba            )//o [  2:0]
,.ddr3_ras_n          (ddr3_ras_n         )//o
,.ddr3_cas_n          (ddr3_cas_n         )//o
,.ddr3_we_n           (ddr3_we_n          )//o
,.ddr3_reset_n        (ddr3_reset_n       )//o
,.ddr3_ck_p           (ddr3_ck_p          )//o [  0:0]
,.ddr3_ck_n           (ddr3_ck_n          )//o [  0:0]
,.ddr3_cke            (ddr3_cke           )//o [  0:0]
,.ddr3_dm             (ddr3_dm            )//o [  3:0]
,.ddr3_odt            (ddr3_odt           )//o [  0:0]

,.sys_rst             (i_rst_n            )//i 
,.sys_clk_i           (w_clk_ref_200M     )//i 
,.clk_ref_i           (w_sys_clk_200M     )//i 
,.app_addr            (app_addr           )//i [ 26:0]
,.app_cmd             (app_cmd            )//i [  2:0]
,.app_en              (app_en             )//i 
,.app_wdf_data        (app_wdf_data       )//i [255:0]
,.app_wdf_end         (app_wdf_end        )//i 
,.app_wdf_mask        (app_wdf_mask       )//i [ 31:0]
,.app_wdf_wren        (app_wdf_wren       )//i 
,.app_rd_data         (app_rd_data        )//o [255:0]
,.app_rd_data_end     (app_rd_data_end    )//o
,.app_rd_data_valid   (app_rd_data_valid  )//o
,.app_rdy             (app_rdy            )//o
,.app_wdf_rdy         (app_wdf_rdy        )//o
,.app_sr_req          (1'b0               )//i
,.app_ref_req         (1'b0               )//i
,.app_zq_req          (1'b0               )//i
,.app_sr_active       (                   )//o
,.app_ref_ack         (                   )//o
,.app_zq_ack          (                   )//o
,.ui_clk              (ui_clk             )//o
,.ui_clk_sync_rst     (ui_clk_sync_rst    )//o
,.init_calib_complete (init_calib_complete)//o
,.device_temp         (device_temp        )//o [ 11:0]
);

frmbuf_top u_frmbuf_top(
 .i_rst_n             (~ui_clk_sync_rst&i_rst_n)
,.i_ddr3_clk          (ui_clk              )

,.i_system_init       (init_calib_complete )
,.o_app_addr          (app_addr            )
,.o_app_cmd           (app_cmd             )
,.o_app_en            (app_en              )
,.i_app_rdy           (app_rdy             )

,.o_app_wdf_data      (app_wdf_data        )
,.o_app_wdf_wren      (app_wdf_wren        )
,.i_app_wdf_rdy       (app_wdf_rdy         )
,.o_app_wdf_end       (app_wdf_end         )

,.i_app_rd_data       (app_rd_data         )
,.i_app_rd_data_valid (app_rd_data_valid   )
,.i_app_rd_data_end   (app_rd_data_end     )

,.i_src_valid         (i_src_valid         )
,.i_src0_clk          (i_src0_clk          )
,.i_src0_vsyn         (i_src0_vsyn         )
,.i_src0_de           (i_src0_de           )
,.i_src0_data         (i_src0_data         )

,.i_src1_clk          (i_src1_clk          )
,.i_src1_valid        (i_src1_valid        )
,.i_src1_vsyn         (i_src1_vsyn         )
,.i_src1_de           (i_src1_de           )
,.i_src1_data         (i_src1_data         )

,.i_dst0_clk          (i_dst0_clk          )
,.i_dst0_vsyn         (i_dst0_vsyn         )
,.i_dst0_rd           (i_dst0_rd           )
,.o_dst0_de           (o_dst0_de           )
,.o_dst0_data         (o_dst0_data         )

,.i_dst1_clk          (i_dst1_clk          )
,.i_dst1_vsyn         (i_dst1_vsyn         )
,.i_dst1_rd           (i_dst1_rd           )
,.o_dst1_de           (o_dst1_de           )
,.o_dst1_data         (o_dst1_data         )
);


endmodule
