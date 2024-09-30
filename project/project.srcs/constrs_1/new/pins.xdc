set_property PACKAGE_PIN L16 [get_ports i_osc_clk_27M]
set_property PACKAGE_PIN T22 [get_ports o_gsv1_clk_27M]
set_property PACKAGE_PIN V21 [get_ports o_gsv2_clk_27M]
set_property PACKAGE_PIN T21 [get_ports o_gsv3_clk_27M]

set_property PACKAGE_PIN Y6 [get_ports i_lvds_clk_p]
set_property PACKAGE_PIN Y8 [get_ports i_lvds_vs_p]
set_property PACKAGE_PIN AA7 [get_ports i_lvds_hs_p]
set_property PACKAGE_PIN AA6 [get_ports i_lvds_de_p]

set_property PACKAGE_PIN T8 [get_ports {i_lvds_data_p[0]}]
set_property PACKAGE_PIN T7 [get_ports {i_lvds_data_p[1]}]
set_property PACKAGE_PIN V8 [get_ports {i_lvds_data_p[2]}]
set_property PACKAGE_PIN W7 [get_ports {i_lvds_data_p[3]}]
set_property PACKAGE_PIN AA10 [get_ports {i_lvds_data_p[4]}]
set_property PACKAGE_PIN AA9 [get_ports {i_lvds_data_p[5]}]
set_property PACKAGE_PIN AB5 [get_ports {i_lvds_data_p[6]}]
set_property PACKAGE_PIN Y4 [get_ports {i_lvds_data_p[7]}]
set_property PACKAGE_PIN AB3 [get_ports {i_lvds_data_p[8]}]
set_property PACKAGE_PIN AA2 [get_ports {i_lvds_data_p[9]}]
set_property PACKAGE_PIN W3 [get_ports {i_lvds_data_p[10]}]
set_property PACKAGE_PIN W2 [get_ports {i_lvds_data_p[11]}]

#set_property PACKAGE_PIN Y6 [get_ports i_video_clk]
#set_property PACKAGE_PIN Y8 [get_ports i_video_vsync]
#set_property PACKAGE_PIN AA7 [get_ports i_video_hsync]
#set_property PACKAGE_PIN AA6 [get_ports i_video_de]

set_property PACKAGE_PIN AA21 [get_ports o_ddc1_hpd]
set_property PACKAGE_PIN P21 [get_ports io_ddc1_i2c_sda]
set_property PACKAGE_PIN P20 [get_ports i_ddc1_i2c_scl]

set_property PACKAGE_PIN AA22 [get_ports o_ddc2_hpd]
set_property PACKAGE_PIN N18 [get_ports io_ddc2_i2c_sda]
set_property PACKAGE_PIN P22 [get_ports i_ddc2_i2c_scl]

#set_property PACKAGE_PIN W22 [get_ports o_ddc3_hpd]
#set_property PACKAGE_PIN N15 [get_ports io_ddc3_i2c_sda]
#set_property PACKAGE_PIN N19 [get_ports i_ddc3_i2c_scl]


set_property PACKAGE_PIN T1 [get_ports i_uart_rxd]
set_property PACKAGE_PIN R3 [get_ports o_uart_txd]

set_property PACKAGE_PIN V18 [get_ports o_run_led]
set_property PACKAGE_PIN AB20 [get_ports {o_hdmi_lock_led[0]}]
set_property PACKAGE_PIN AB19 [get_ports {o_hdmi_lock_led[1]}]
set_property PACKAGE_PIN AB21 [get_ports o_ddr3_init_done_led]


set_property IOSTANDARD LVCMOS33 [get_ports i_osc_clk_27M]
set_property IOSTANDARD LVCMOS33 [get_ports o_gsv1_clk_27M]
set_property IOSTANDARD LVCMOS33 [get_ports o_gsv2_clk_27M]
set_property IOSTANDARD LVCMOS33 [get_ports o_gsv3_clk_27M]

set_property IOSTANDARD LVCMOS33 [get_ports o_ddc1_hpd]
set_property IOSTANDARD LVCMOS33 [get_ports io_ddc1_i2c_sda]
set_property IOSTANDARD LVCMOS33 [get_ports i_ddc1_i2c_scl]

set_property IOSTANDARD LVCMOS33 [get_ports o_ddc2_hpd]
set_property IOSTANDARD LVCMOS33 [get_ports io_ddc2_i2c_sda]
set_property IOSTANDARD LVCMOS33 [get_ports i_ddc2_i2c_scl]

#set_property IOSTANDARD LVCMOS33 [get_ports o_ddc3_hpd]
#set_property IOSTANDARD LVCMOS33 [get_ports io_ddc3_i2c_sda]
#set_property IOSTANDARD LVCMOS33 [get_ports i_ddc3_i2c_scl]

set_property IOSTANDARD LVCMOS25 [get_ports i_uart_rxd]
set_property IOSTANDARD LVCMOS25 [get_ports o_uart_txd]
set_property IOSTANDARD LVCMOS33 [get_ports o_run_led]
set_property IOSTANDARD LVCMOS33 [get_ports {o_hdmi_lock_led[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_hdmi_lock_led[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports o_ddr3_init_done_led]

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 12 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]

set_property IOSTANDARD LVDS_25 [get_ports i_lvds_clk_p]
set_property IOSTANDARD LVDS_25 [get_ports i_lvds_vs_p]
set_property IOSTANDARD LVDS_25 [get_ports i_lvds_hs_p]
set_property IOSTANDARD LVDS_25 [get_ports i_lvds_de_p]
set_property IOSTANDARD LVDS_25 [get_ports {i_lvds_data_p[10]}]
set_property IOSTANDARD LVDS_25 [get_ports {i_lvds_data_p[9]}]
set_property IOSTANDARD LVDS_25 [get_ports {i_lvds_data_p[8]}]
set_property IOSTANDARD LVDS_25 [get_ports {i_lvds_data_p[7]}]
set_property IOSTANDARD LVDS_25 [get_ports {i_lvds_data_p[6]}]
set_property IOSTANDARD LVDS_25 [get_ports {i_lvds_data_p[5]}]
set_property IOSTANDARD LVDS_25 [get_ports {i_lvds_data_p[4]}]
set_property IOSTANDARD LVDS_25 [get_ports {i_lvds_data_p[3]}]
set_property IOSTANDARD LVDS_25 [get_ports {i_lvds_data_p[2]}]
set_property IOSTANDARD LVDS_25 [get_ports {i_lvds_data_p[1]}]
set_property IOSTANDARD LVDS_25 [get_ports {i_lvds_data_p[0]}]
set_property IOSTANDARD LVDS_25 [get_ports {i_lvds_data_p[11]}]

#set_property IOSTANDARD LVCMOS25 [get_ports i_video_clk]
#set_property IOSTANDARD LVCMOS25 [get_ports i_video_vsync]
#set_property IOSTANDARD LVCMOS25 [get_ports i_video_hsync]
#set_property IOSTANDARD LVCMOS25 [get_ports i_video_de]


set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets i_osc_clk_27M_IBUF]

create_clock -period 37.037 -name i_osc_clk_27M -waveform {0.000 18.518} [get_ports i_osc_clk_27M]

set_false_path -from [get_clocks i_osc_clk_27M] -to [get_clocks -of_objects [get_pins u0_pll_27MHz/inst/plle2_adv_inst/CLKOUT1]]
set_false_path -from [get_clocks i_osc_clk_27M] -to [get_clocks -of_objects [get_pins u0_pll_27MHz/inst/plle2_adv_inst/CLKOUT1]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets w_pll_clk148p5M]
