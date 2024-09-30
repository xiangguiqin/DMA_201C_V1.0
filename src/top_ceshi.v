`timescale 1ns/1ps
`define dVID_DW    ('d24)

module top_ceshi(
 input                      i_osc_clk_27M

,output                     o_gsv1_clk_27M
,output                     o_gsv2_clk_27M
,output                     o_gsv3_clk_27M

//,input                      i_video_clk
//,input                      i_video_vsync
//,input                      i_video_hsync
//,input                      i_video_de
//,input         [11:0]       i_video_data 

,input                      i_lvds_clk_p
,input                      i_lvds_clk_n

,input                      i_lvds_vs_p
,input                      i_lvds_vs_n

,input                      i_lvds_hs_p
,input                      i_lvds_hs_n

,input                      i_lvds_de_p
,input                      i_lvds_de_n

,input         [11:0]       i_lvds_data_p
,input         [11:0]       i_lvds_data_n


,output                     o_ddc1_hpd
,inout                      io_ddc1_i2c_sda
,input                      i_ddc1_i2c_scl

,output                     o_ddc2_hpd
,inout                      io_ddc2_i2c_sda
,input                      i_ddc2_i2c_scl

//,input                      i_ddc3_hpd
//,inout                      io_ddc3_i2c_sda
//,output                     o_ddc3_i2c_scl

,input                      i_uart_rxd
,output                     o_uart_txd

,output                     o_run_led
,output        [1:0]        o_hdmi_lock_led
,output                     o_ddr3_init_done_led

/* //DDR3
,inout    [31:0]             ddr3_dq
,inout    [3:0]              ddr3_dqs_n
,inout    [3:0]              ddr3_dqs_p
,output   [12:0]             ddr3_addr
,output   [2:0]              ddr3_ba
,output                      ddr3_ras_n
,output                      ddr3_cas_n
,output                      ddr3_we_n
,output                      ddr3_reset_n
,output   [0:0]              ddr3_ck_p
,output   [0:0]              ddr3_ck_n
,output   [0:0]              ddr3_cke
,output   [3:0]              ddr3_dm
,output   [0:0]              ddr3_odt */
);

wire              w_bufg_clk_27M                    ;
wire              w_pll_clk27M                      ;
wire              w_pll_clk148p5M                   ;
wire              w_pll_clk74p25M                   ;
wire              w_pll_serial_clk742p5M            ;
wire              w_pll_27MHz_locked                ;
                                                    
wire              w_pll_clk100M                     ;
wire              w_pll_clk200M                     ;
wire              w_pll_50MHz_locked                ;
                                                    
wire              w_global_rst_n                    ;
                                                    
wire              w_adjust_vsyn                     ;
wire              w_adjust_hsyn                     ;
wire              w_adjust_de                       ;
wire    [23:0]    w_adjust_data                     ;
                                                    
wire    [25:0]    w_detect_total_pix_num            ;
wire    [12:0]    w_detect_vs_total_num             ;
wire    [12:0]    w_detect_hs_total_num             ;
wire    [12:0]    w_detect_vsyn_num                 ;
wire    [12:0]    w_detect_hsyn_num                 ;
wire    [12:0]    w_detect_video_start_pixel        ;
wire    [12:0]    w_detect_video_end_pixel          ;
wire    [12:0]    w_detect_video_start_H            ;
wire    [12:0]    w_detect_video_end_H              ;
wire    [7:0]	  w_detect_refresh_rate             ;
wire              w_detect_actual_vs_rise           ;
wire              w_detect_bit_rate                 ;
                                                    
wire    [7:0]     w_detect_resolution               ;
wire              w_video_lock                      ;




wire              w_i2s_mclk                        ;
wire              w_i2s_sclk                        ;
wire              w_i2s_rlclk                       ;


wire              w_ddr_de                          ;
wire    [23:0]    w_ddr_data                        ;
wire              w_timinggen_hsyn                  ;
wire              w_timinggen_vsyn                  ;
wire              w_timinggen_de                    ;
wire              w_timinggen_rd                    ;


wire              w_video_clk   ;
wire              w_video_vsync ;
wire              w_video_hsync ;
wire              w_video_de    ;
wire    [23:0]    w_video_data  ;


assign o_ite6802_rst_n  = w_global_rst_n;

assign o_hdmi_lock_led  = {2{w_video_lock}};

assign o_gsv1_clk_27M = w_pll_clk27M;
assign o_gsv2_clk_27M = w_pll_clk27M;//w_video_clk;
assign o_gsv3_clk_27M = w_pll_clk27M;


/* BUFG u_BUFG_27M(
 .I (i_osc_clk_27M  )  // 1-bit output: Clock buffer output
,.O (w_bufg_clk_27M )  // 1-bit input: Clock buffer input
); */

pll_27MHz u0_pll_27MHz(
 .clk_in1   (i_osc_clk_27M          )
,.clk_out1  (w_pll_clk27M           )
,.clk_out2  (w_pll_clk148p5M        )
,.locked    (w_pll_27MHz_locked     )
,.resetn    (w_global_rst_n         )
);


BFM_RST u0_BFM_RST(
 .i_rst_n        (1              )
,.i_local_clk    (i_osc_clk_27M  )
,.o_global_rst_n (w_global_rst_n )
);

/* i2s_clock_gen u0_i2s_clock_gen(
 .i_clk   (w_pll_clk148p5M )
,.i_rst_n (w_global_rst_n  )
,.o_mclk  (w_i2s_mclk      )
,.o_sclk  (w_i2s_sclk      )
,.o_rlclk (w_i2s_rlclk     )
); */



//assign w_video_clk    = i_video_clk    ;
//assign w_video_vsync  = i_video_vsync  ;
//assign w_video_hsync  = i_video_hsync  ;
//assign w_video_de     = i_video_de     ;
//       w_video_data   = i_video_data   ;



lvds_top #(
 .p_debug_en("TRUE")
)u0_lvds_top(
 .i_rst_n       (w_global_rst_n  )
,.i_local_clk   (w_pll_clk148p5M )

,.i_lvds_clk_p  (i_lvds_clk_p    )
,.i_lvds_clk_n  (i_lvds_clk_n    )

,.i_lvds_de_p   (i_lvds_de_p     )
,.i_lvds_de_n   (i_lvds_de_n     )

,.i_lvds_hs_p   (i_lvds_hs_p     )
,.i_lvds_hs_n   (i_lvds_hs_n     )

,.i_lvds_vs_p   (i_lvds_vs_p     )
,.i_lvds_vs_n   (i_lvds_vs_n     )

,.i_lvds_data_p (i_lvds_data_p   )
,.i_lvds_data_n (i_lvds_data_n   )

,.o_video_clk   (w_video_clk     )
,.o_video_vsync (w_video_vsync   )
,.o_video_hsync (w_video_hsync   )
,.o_video_de    (w_video_de      )
,.o_video_data  (w_video_data    )
);

video_signal_adjust #(
 .pDATA_WIDTH  (`dVID_DW )
) u0_video_signal_adjust (
 .i_rst_n      (w_global_rst_n )
,.i_clk        (w_video_clk    )//i_video_clk    )
,.i_vsyn       (w_video_vsync  )//i_video_vsync  )
,.i_hsyn       (w_video_hsync  )//i_video_hsync  )
,.i_de		   (w_video_de     )//i_video_de     )
,.i_video_data (w_video_data   )//i_video_data   )
,.o_vsyn       (w_adjust_vsyn  )
,.o_hsyn       (w_adjust_hsyn  )
,.o_de		   (w_adjust_de    )
,.o_video_data (w_adjust_data  )
);

video_detect #(
 .p_debug_en("TRUE")
,.p_local_clk_freq    ('d148_500_000)
) u0_video_detect (
 .i_video_clk         (w_video_clk                )
,.i_local_clk         (w_pll_clk148p5M            )
,.i_rst_n             (w_global_rst_n             )
,.i_vsyn              (w_adjust_vsyn              )
,.i_hsyn              (w_adjust_hsyn              )
,.i_de                (w_adjust_de                )
,.o_total_pix_num     (w_detect_total_pix_num     )
,.o_vs_total_num      (w_detect_vs_total_num      )
,.o_hs_total_num      (w_detect_hs_total_num      )
,.o_vsyn_num          (w_detect_vsyn_num          )
,.o_hsyn_num          (w_detect_hsyn_num          )
,.o_video_start_pixel (w_detect_video_start_pixel )
,.o_video_end_pixel   (w_detect_video_end_pixel   )
,.o_video_start_H     (w_detect_video_start_H     )
,.o_video_end_H       (w_detect_video_end_H       )
,.o_refresh_rate      (w_detect_refresh_rate      )
,.o_actual_vs_rise    (w_detect_actual_vs_rise    )
,.o_bit_rate          (w_detect_bit_rate          )
);

video_judgement u0_video_judgement(
 .i_local_clk     (w_pll_clk148p5M        )
,.i_rst_n         (w_global_rst_n         )
,.i_total_pix_num (w_detect_total_pix_num )
,.i_h_num         (w_detect_hs_total_num  )
,.i_v_num         (w_detect_vs_total_num  )
,.i_refresh_rate  (w_detect_refresh_rate  )
,.i_vsyn          (w_adjust_vsyn          )
,.o_resolution    (w_detect_resolution    )
,.o_video_valid   (w_video_lock           )
);

/* wire [2:0] w_r2y_i_tags;
wire [2:0] w_r2y_o_tags;
wire       l_r2y_VSyn ;
wire       l_r2y_HSyn ;
wire       l_r2y_De   ;

wire [7:0] lr2y_R     ;
wire [7:0] lr2y_G     ;
wire [7:0] lr2y_B     ;

wire [7:0] lr2y_Y     ;
wire [7:0] lr2y_Cb    ;
wire [7:0] lr2y_Cr    ;

assign w_r2y_i_tags = {w_adjust_vsyn,w_adjust_hsyn,w_adjust_de};
assign {w_r2y_R,w_r2y_G,w_r2y_B} = w_adjust_data;
assign {w_r2y_vsyn,w_r2y_hsyn,w_r2y_de} = w_r2y_o_tags;
rgb2ycbcr u0_r2y(
 .i_rst_n (w_global_rst_n )
,.i_pclk  (i_video_clk    )
,.i_valid (1'b1           )
,.o_valid (               )
,.i_R     (w_r2y_R        )
,.i_G     (w_r2y_G        )
,.i_B     (w_r2y_B        )
,.o_Y     (w_r2y_Y        )
,.o_Cb    (w_r2y_Cb       )
,.o_Cr    (w_r2y_Cr       )
,.i_tags  (w_r2y_i_tags   )
,.o_tags  (w_r2y_o_tags   )
);


wire        lGammaVSyn;
wire        lGammaHSyn;
wire        lGammaDe  ;
wire [23:0] lGammaData;
GammaTop u0_GammaTop(
 .iResetN   (iRst_n                  )
,.iVideoClk (iVideoClk               )
,.iGamma    ()
,.iVideoVSyn(l_r2y_VSyn              )
,.iVideoHSyn(l_r2y_HSyn              )
,.iVideoDe  (l_r2y_De                )
,.iVideoData({lr2y_Y,lr2y_Cb,lr2y_Cr})
,.oVideoVSyn(lGammaVSyn              )
,.oVideoHSyn(lGammaHSyn              )
,.oVideoDe  (lGammaDe                )
,.oVideoData(lGammaData              )
);


wire [23:0] w_y2r_data ;
wire        w_y2r_vsyn ;
wire        w_y2r_hsyn ;
wire        w_y2r_de   ;
yuv2rgb u0_y2r(
 .iRstN (iRst_n                  )
,.iSclk (iVideoClk               )
,.iD    (lGammaData              )
,.iV    (lGammaVSyn              )
,.iH    (lGammaHSyn              )
,.iE    (lGammaDe                )
,.iflag (1'b1                    )
,.oDesR (w_y2r_data[23:16]       )
,.oDesG (w_y2r_data[15: 8]       )
,.oDesB (w_y2r_data[ 7: 0]       )
,.oDesV (w_y2r_vsyn              )
,.oDesH (w_y2r_hsyn              )
,.oDesDE(w_y2r_de                )
); */



/* ddr_top u_ddr_top(
 .i_local_clk  (w_pll_clk200M        )
,.i_rst_n      (w_global_rst_n       )
,.o_init_done  (o_ddr3_init_done_led )

,.i_src_valid  (1                    )
,.i_src0_clk   (w_pcs0_rx_clk        )
,.i_src0_vsyn  (w_pcs1_rx_video_vsyn )
,.i_src0_de    (w_pcs1_rx_video_de   )
,.i_src0_data  (w_pcs1_rx_video_data )

,.i_dst0_clk   (w_pll_clk148p5M      )
,.i_dst0_vsyn  (w_timinggen_vsyn     )
,.i_dst0_rd    (w_timinggen_rd       )
,.o_dst0_de    (w_ddr_de             )
,.o_dst0_data  (w_ddr_data           )

,.ddr3_dq      (ddr3_dq              )
,.ddr3_dqs_n   (ddr3_dqs_n           )
,.ddr3_dqs_p   (ddr3_dqs_p           )
,.ddr3_addr    (ddr3_addr            )
,.ddr3_ba      (ddr3_ba              )
,.ddr3_ras_n   (ddr3_ras_n           )
,.ddr3_cas_n   (ddr3_cas_n           )
,.ddr3_we_n    (ddr3_we_n            )
,.ddr3_reset_n (ddr3_reset_n         )
,.ddr3_ck_p    (ddr3_ck_p            )
,.ddr3_ck_n    (ddr3_ck_n            )
,.ddr3_cke     (ddr3_cke             )
,.ddr3_dm      (ddr3_dm              )
,.ddr3_odt     (ddr3_odt             )
); */

/* video_out u0_video_out(
 .i_video_clk         (w_pll_clk148p5M                   )
,.i_rst_n             (w_global_rst_n                    )
,.i_frm_gen_enable    (w_pcs_rx_stable_video_lock        )
,.i_resolution        (w_pcs_rx_stable_resolution        )
,.i_vs_total_num      (w_pcs_rx_stable_vs_total_num      )
,.i_hs_total_num      (w_pcs_rx_stable_hs_total_num      )
,.i_vsyn_num          (w_pcs_rx_stable_vsyn_num          )
,.i_hsyn_num          (w_pcs_rx_stable_hsyn_num          )
,.i_video_start_pixel (w_pcs_rx_stable_video_start_pixel )
,.i_video_end_pixel   (w_pcs_rx_stable_video_end_pixel   )
,.i_video_start_H     (w_pcs_rx_stable_video_start_H     )
,.i_video_end_H       (w_pcs_rx_stable_video_end_H       )
,.o_hsyn              (w_timinggen_hsyn                  )
,.o_vsyn              (w_timinggen_vsyn                  )
,.o_de                (w_timinggen_de                    )
,.o_rd                (w_timinggen_rd                    )
);
 */


ddc_edid_control u0_ddc_edid_control(
 .i_local_clk     (w_pll_clk148p5M    )
,.i_rst_n         (w_global_rst_n     )

,.i_ir            (w_ir               )

//i2c slave
,.o_ddc1_hpd      (o_ddc1_hpd         )
,.io_ddc1_i2c_sda (io_ddc1_i2c_sda    )
,.i_ddc1_i2c_scl  (i_ddc1_i2c_scl     )

//i2c slave
,.o_ddc2_hpd      (o_ddc2_hpd         )
,.io_ddc2_i2c_sda (io_ddc2_i2c_sda    )
,.i_ddc2_i2c_scl  (i_ddc2_i2c_scl     )

////i2c master
//,.io_ddc3_i2c_sda (io_ddc3_i2c_sda    )
//,.o_ddc3_i2c_scl  (i_ddc3_i2c_scl     )
//,.i_ddc3_hpd      (i_ddc3_hpd         )
);


led run_led(
 .i_rst_n     (w_global_rst_n  )
,.i_local_clk (w_pll_clk148p5M )
,.o_run_led   (o_run_led       )
);


endmodule


