// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
// Date        : Wed Sep 11 17:03:30 2024
// Host        : DESKTOP-AR7JAMA running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ selectio_wiz_0_stub.v
// Design      : selectio_wiz_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7s50fgga484-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix(data_in_from_pins_p, data_in_from_pins_n, 
  data_in_to_device, clk_in_p, clk_in_n, clk_out, io_reset)
/* synthesis syn_black_box black_box_pad_pin="data_in_from_pins_p[14:0],data_in_from_pins_n[14:0],data_in_to_device[29:0],clk_in_p,clk_in_n,clk_out,io_reset" */;
  input [14:0]data_in_from_pins_p;
  input [14:0]data_in_from_pins_n;
  output [29:0]data_in_to_device;
  input clk_in_p;
  input clk_in_n;
  output clk_out;
  input io_reset;
endmodule
