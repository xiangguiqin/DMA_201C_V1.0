`timescale 1ns/1ps
`define dVID_DW    ('d24)

module top(
 input  wire                     Q0_CLK0_GTREFCLK_PAD_N_IN
,input  wire                     Q0_CLK0_GTREFCLK_PAD_P_IN
,input  wire    [1:0]            RXN_IN
,input  wire    [1:0]            RXP_IN
,output wire    [1:0]            TXN_OUT
,output wire    [1:0]            TXP_OUT

,input  wire                     i_rst_n
,input  wire                     i_osc_clk_27M
,input  wire                     i_osc_clk_50M

,input  wire                     i_video_clk
,input  wire                     i_video_vsync
,input  wire                     i_video_hsync
,input  wire                     i_video_de
,input  wire   [`dVID_DW-1:0]    i_video_data

//HDMI随路音频
,input  wire                     i_video_i2s_mclk    //hdmi i2s
,input  wire                     i_video_i2s_sclk    //hdmi i2s
,input  wire                     i_video_i2s_rlclk   //hdmi i2s
,input  wire                     i_video_i2s_data    //hdmi i2s

//外部音频
,output wire                     o_ext_i2s_mclk
,output wire                     o_ext_i2s_sclk
,output wire                     o_ext_i2s_rlclk
,input  wire                     i_ext_i2s_data
,output wire                     o_ext_i2s_data

,input  wire                     i_uart_rxd
,output wire                     o_uart_txd

,output wire                     o_i2c_scl
,inout  wire                     io_i2c_sda

,output wire                     o_ite6802_rst_n

,output wire                     o_run_led
,output wire                     o_hdmi_lock_led
,output wire   [1:0]             o_pcs_lock_led
,output wire   [1:0]             o_pcs_tx_disable
,input  wire   [1:0]             i_pcs_rx_los
,output wire                     o_ddr3_init_done_led

//HDMI TMDS
,output wire                     oTMDS_CLK_P
,output wire                     oTMDS_CLK_N
,output wire                     oTMDS_D0_P
,output wire                     oTMDS_D0_N
,output wire                     oTMDS_D1_P
,output wire                     oTMDS_D1_N
,output wire                     oTMDS_D2_P
,output wire                     oTMDS_D2_N

//DDR3
,inout  wire  [31:0]             ddr3_dq
,inout  wire  [3:0]              ddr3_dqs_n
,inout  wire  [3:0]              ddr3_dqs_p
,output wire  [12:0]             ddr3_addr
,output wire  [2:0]              ddr3_ba
,output wire                     ddr3_ras_n
,output wire                     ddr3_cas_n
,output wire                     ddr3_we_n
,output wire                     ddr3_reset_n
,output wire  [0:0]              ddr3_ck_p
,output wire  [0:0]              ddr3_ck_n
,output wire  [0:0]              ddr3_cke
,output wire  [3:0]              ddr3_dm
,output wire  [0:0]              ddr3_odt
);

wire              w_bufg_clk_27M                    ;
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

//tx0                                               
wire              w_pcs0_tx_clk                     ;
wire              w_pcs0_tx_rd_en                   ;
wire    [63:0]    w_pcs0_tx_data                    ;
wire              w_pcs0_tx_head                    ;
wire              w_pcs0_tx_rst                     ;
//rx0                                               
wire              w_pcs0_rx_clk                     ;
wire    [63:0]    w_pcs0_rx_data                    ;
wire              w_pcs0_rx_head                    ;
wire              w_pcs0_rx_valid                   ;
wire              w_pcs0_rx_lock                    ;
wire              w_pcs0_rx_rst                     ;
//tx1                                               
wire              w_pcs1_tx_clk                     ;
wire              w_pcs1_tx_rd_en                   ;
wire    [63:0]    w_pcs1_tx_data                    ;
wire              w_pcs1_tx_head                    ;
wire              w_pcs1_tx_rst                     ;
//rx1                                               
wire              w_pcs1_rx_clk                     ;
wire    [63:0]    w_pcs1_rx_data                    ;
wire              w_pcs1_rx_head                    ;
wire              w_pcs1_rx_valid                   ;
wire              w_pcs1_rx_lock                    ;
wire              w_pcs1_rx_rst                     ;
                                                    
wire              w_pcs1_rx_video_vsyn              ;
wire              w_pcs1_rx_video_hsyn              ;
wire              w_pcs1_rx_video_de                ;
wire    [23:0]    w_pcs1_rx_video_data              ;

wire    [12:0]    w_pcs_rx_stable_vs_total_num      ;
wire    [12:0]    w_pcs_rx_stable_hs_total_num      ;
wire    [12:0]    w_pcs_rx_stable_vsyn_num          ;
wire    [12:0]    w_pcs_rx_stable_hsyn_num          ;
wire    [12:0]    w_pcs_rx_stable_video_start_pixel ;
wire    [12:0]    w_pcs_rx_stable_video_end_pixel   ;
wire    [12:0]    w_pcs_rx_stable_video_start_H     ;
wire    [12:0]    w_pcs_rx_stable_video_end_H       ;
wire    [7:0]     w_pcs_rx_stable_resolution        ;
wire              w_pcs_rx_stable_video_lock        ;

wire              w_i2s_mclk                        ;
wire              w_i2s_sclk                        ;
wire              w_i2s_rlclk                       ;


wire              w_ddr_de                          ;
wire    [23:0]    w_ddr_data                        ;
wire              w_timinggen_hsyn                  ;
wire              w_timinggen_vsyn                  ;
wire              w_timinggen_de                    ;
wire              w_timinggen_rd                    ;

assign o_ite6802_rst_n  = w_global_rst_n;

assign o_hdmi_lock_led  = w_video_lock;
assign o_pcs_lock_led   = {w_pcs1_rx_lock,w_pcs0_rx_lock};
assign o_pcs_tx_disable = 2'b0;

assign o_ext_i2s_mclk   = w_i2s_mclk  ;
assign o_ext_i2s_sclk   = w_i2s_sclk  ;
assign o_ext_i2s_rlclk  = w_i2s_rlclk ;


/* BUFG u_BUFG_27M(
 .I (i_osc_clk_27M  )  // 1-bit output: Clock buffer output
,.O (w_bufg_clk_27M )  // 1-bit input: Clock buffer input
); */

pll_27MHz u0_pll_27MHz(
 .clk_in1   (i_osc_clk_27M          )
,.clk_out1  (w_pll_clk74p25M        )
,.clk_out2  (w_pll_clk148p5M        )
,.clk_out3  (w_pll_serial_clk742p5M )
,.locked    (w_pll_27MHz_locked     )
,.resetn    (w_global_rst_n         )
);

pll_50MHz u0_pll_50MHz(
 .clk_in1  (i_osc_clk_50M      )
,.clk_out1 (w_pll_clk100M      )
,.clk_out2 (w_pll_clk200M      )
,.locked   (w_pll_50MHz_locked )
,.resetn   (w_global_rst_n     )
);

BFM_RST u0_BFM_RST(
 .i_rst_n        (i_rst_n        )
,.i_local_clk    (i_osc_clk_27M  )
,.o_global_rst_n (w_global_rst_n )
);

i2s_clock_gen u0_i2s_clock_gen(
 .i_clk   (w_pll_clk148p5M )
,.i_rst_n (w_global_rst_n  )
,.o_mclk  (w_i2s_mclk      )
,.o_sclk  (w_i2s_sclk      )
,.o_rlclk (w_i2s_rlclk     )
);

video_signal_adjust #(
 .pDATA_WIDTH  (`dVID_DW )
) u0_video_signal_adjust (
 .i_clk        (i_video_clk    )
,.i_rst_n      (w_global_rst_n )
,.i_vsyn       (i_video_vsync  )
,.i_hsyn       (i_video_hsync  )
,.i_de		   (i_video_de     )
,.i_video_data (i_video_data   )
,.o_vsyn       (w_adjust_vsyn  )
,.o_hsyn       (w_adjust_hsyn  )
,.o_de		   (w_adjust_de    )
,.o_video_data (w_adjust_data  )
);

video_detect #(
 .p_debug_en          ('b1          )
,.p_local_clk_freq    ('d148_500_000)
) u0_video_detect (
 .i_video_clk         (i_video_clk                )
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

pcs_tx_process u0_pcs_tx_process(
 .i_rst_n	           (w_global_rst_n             )
,.i_local_clk          (w_pll_clk148p5M            )
,.i_pcs_clk            (w_pcs0_tx_clk              )

,.i_video_clk          (i_video_clk                )
,.i_video_vsyn         (w_adjust_vsyn              )
,.i_video_hsyn         (w_adjust_hsyn              )
,.i_video_de           (w_adjust_de                )
,.i_video_data         (w_adjust_data              )

,.i_resolution         (w_detect_resolution        )
,.i_video_lock         (w_video_lock               )
,.i_vs_total_num       (w_detect_vs_total_num      )
,.i_hs_total_num       (w_detect_hs_total_num      )
,.i_vsyn_num           (w_detect_vsyn_num          )
,.i_hsyn_num           (w_detect_hsyn_num          )
,.i_video_start_pixel  (w_detect_video_start_pixel )
,.i_video_end_pixel    (w_detect_video_end_pixel   )
,.i_video_start_H      (w_detect_video_start_H     )
,.i_video_end_H        (w_detect_video_end_H       )

,.i_video_i2s_sclk     (i_video_i2s_sclk           )
,.i_video_i2s_rlclk    (i_video_i2s_rlclk          )
,.i_video_i2s_data     (i_video_i2s_data           )

,.i_external_i2s_sclk  (o_external_i2s_sclk        )
,.i_external_i2s_rlclk (o_external_i2s_rlclk       )
,.i_external_i2s_data  (i_external_i2s_data        )

,.i_uart_rxd           (i_uart_rxd                 )

,.o_pcs_rst            (w_pcs0_tx_rst              )
,.i_pcs_rd_en          (w_pcs0_tx_rd_en            )
,.o_pcs_data           (w_pcs0_tx_data             )
,.o_pcs_head           (w_pcs0_tx_head             )
);

pcs_rx_process u1_pcs_rx_process(
 .i_rst_n	           (w_global_rst_n                    )
,.i_local_clk          (w_pll_clk148p5M                   )
,.i_video_clk          (i_video_clk                       )
,.i_pcs_clk            (w_pcs0_rx_clk                     )
                                                          
,.i_pcs_data           (w_pcs0_rx_data                    )
,.i_pcs_head           (w_pcs0_rx_head                    )
,.i_data_valid         (w_pcs0_rx_valid                   )
                                                          
,.o_syn                ()
,.o_pcs_lock           (w_pcs0_rx_lock                    )
,.o_pcs_rst            (w_pcs0_rx_rst                     )

,.o_uart_txd           (o_uart_txd                        )
,.o_uart_drive         ()

//,.i_video_i2s_sclk     (i_video_i2s_sclk                  )
//,.i_video_i2s_rlclk    (i_video_i2s_rlclk                 )
//,.i_video_i2s_data     (i_video_i2s_data                  )
                                                          
//,.i_external_i2s_sclk  (o_external_i2s_sclk               )
//,.i_external_i2s_rlclk (o_external_i2s_rlclk              )
//,.o_external_i2s_data  (o_external_i2s_data               )

,.o_video_vsyn         (w_pcs1_rx_video_vsyn              )
,.o_video_de           (w_pcs1_rx_video_de                )
,.o_video_data         (w_pcs1_rx_video_data              )

,.o_video_lock         (w_pcs_rx_stable_video_lock        )
,.o_resolution         (w_pcs_rx_stable_resolution        )
,.o_vs_total_num       (w_pcs_rx_stable_vs_total_num      )
,.o_hs_total_num       (w_pcs_rx_stable_hs_total_num      )
,.o_vsyn_num           (w_pcs_rx_stable_vsyn_num          )
,.o_hsyn_num           (w_pcs_rx_stable_hsyn_num          )
,.o_video_start_pixel  (w_pcs_rx_stable_video_start_pixel )
,.o_video_end_pixel    (w_pcs_rx_stable_video_end_pixel   )
,.o_video_start_H      (w_pcs_rx_stable_video_start_H     )
,.o_video_end_H        (w_pcs_rx_stable_video_end_H       )
);

ddr_top u_ddr_top(
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
);

video_out u0_video_out(
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

hdmi_transmitter_top u0_tmds(
 .i_pixel_clk     (w_pll_clk148p5M                    )
,.i_serial_clk_x5 (w_pll_serial_clk742p5M             )
,.i_rst_n         (w_global_rst_n                     )

,.i_video_data    (w_ddr_data                         )
,.i_hsync         (w_timinggen_hsyn                   )
,.i_vsync         (w_timinggen_vsyn                   )
,.i_de            (w_timinggen_de                     )

,.oTMDS_CLK_P     (oTMDS_CLK_P                        )
,.oTMDS_CLK_N     (oTMDS_CLK_N                        )
,.oTMDS_DATA_P    ({oTMDS_D2_P,oTMDS_D1_P,oTMDS_D0_P} )
,.oTMDS_DATA_N    ({oTMDS_D2_N,oTMDS_D1_N,oTMDS_D0_N} )
);

iic_com	u_iic_com(
 .clk   (i_osc_clk_27M  )
,.rst_n (w_global_rst_n )
,.scl   (o_i2c_scl      )
,.sda   (io_i2c_sda     )
);

led u0_led(
 .iRst_n    (w_global_rst_n  )
,.iLocalClk (w_pll_clk148p5M )
,.oRunLed   (o_run_led       )
);

gtwizard_0_exdes u0_gtwizard_0_exdes(
 .Q0_CLK0_GTREFCLK_PAD_N_IN (Q0_CLK0_GTREFCLK_PAD_N_IN )
,.Q0_CLK0_GTREFCLK_PAD_P_IN (Q0_CLK0_GTREFCLK_PAD_P_IN )
,.DRP_CLK_IN                (w_pll_clk100M             )
,.RXN_IN                    (RXN_IN                    )
,.RXP_IN                    (RXP_IN                    )
,.TXN_OUT                   (TXN_OUT                   )
,.TXP_OUT                   (TXP_OUT                   )

,.i_tx_total_rst            (~w_global_rst_n           )
,.i_rx_total_rst            (~w_global_rst_n           )

,.o_gt0_txusrclk2           (w_pcs0_tx_clk             )
,.i_gt0_tx_data             (w_pcs0_tx_data            )
,.i_gt0_tx_head             (w_pcs0_tx_head            )
,.o_gt0_tx_rd_en            (w_pcs0_tx_rd_en           )

,.o_gt0_rxusrclk2           (w_pcs0_rx_clk             )
,.o_gt0_rx_head             (w_pcs0_rx_head            )
,.o_gt0_rx_valid            (w_pcs0_rx_valid           )
,.o_gt0_rx_data             (w_pcs0_rx_data            )

,.o_gt1_txusrclk2           (w_pcs1_tx_clk             )
,.i_gt1_tx_data             (w_pcs1_tx_data            )
,.i_gt1_tx_head             (w_pcs1_tx_head            )
,.o_gt1_tx_rd_en            (w_pcs1_tx_rd_en           )

,.o_gt1_rxusrclk2           (w_pcs1_rx_clk             )
,.o_gt1_rx_head             (w_pcs1_rx_head            )
,.o_gt1_rx_valid            (w_pcs1_rx_valid           )
,.o_gt1_rx_data             (w_pcs1_rx_data            )
);


endmodule


