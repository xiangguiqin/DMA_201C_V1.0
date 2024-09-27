// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
// Date        : Wed Sep 11 17:03:30 2024
// Host        : DESKTOP-AR7JAMA running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               d:/FPGA_project/Xilinx/DMA_201C_V1.0/project/project.srcs/sources_1/ip/selectio_wiz_0/selectio_wiz_0_sim_netlist.v
// Design      : selectio_wiz_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7s50fgga484-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* DEV_W = "30" *) (* SYS_W = "15" *) 
(* NotValidForBitStream *)
module selectio_wiz_0
   (data_in_from_pins_p,
    data_in_from_pins_n,
    data_in_to_device,
    clk_in_p,
    clk_in_n,
    clk_out,
    io_reset);
  input [14:0]data_in_from_pins_p;
  input [14:0]data_in_from_pins_n;
  output [29:0]data_in_to_device;
  input clk_in_p;
  input clk_in_n;
  output clk_out;
  input io_reset;

  (* DIFF_TERM = 0 *) (* IBUF_LOW_PWR *) (* IOSTANDARD = "DIFF_HSTL_I" *) wire clk_in_n;
  (* DIFF_TERM = 0 *) (* IBUF_LOW_PWR *) (* IOSTANDARD = "DIFF_HSTL_I" *) wire clk_in_p;
  wire clk_out;
  (* DIFF_TERM = 0 *) (* IBUF_LOW_PWR *) (* IOSTANDARD = "DIFF_HSTL_I" *) wire [14:0]data_in_from_pins_n;
  (* DIFF_TERM = 0 *) (* IBUF_LOW_PWR *) (* IOSTANDARD = "DIFF_HSTL_I" *) wire [14:0]data_in_from_pins_p;
  wire [29:0]data_in_to_device;
  wire io_reset;

  (* DEV_W = "30" *) 
  (* SYS_W = "15" *) 
  selectio_wiz_0_selectio_wiz_0_selectio_wiz inst
       (.clk_in_n(clk_in_n),
        .clk_in_p(clk_in_p),
        .clk_out(clk_out),
        .data_in_from_pins_n(data_in_from_pins_n),
        .data_in_from_pins_p(data_in_from_pins_p),
        .data_in_to_device(data_in_to_device),
        .io_reset(io_reset));
endmodule

(* DEV_W = "30" *) (* ORIG_REF_NAME = "selectio_wiz_0_selectio_wiz" *) (* SYS_W = "15" *) 
module selectio_wiz_0_selectio_wiz_0_selectio_wiz
   (data_in_from_pins_p,
    data_in_from_pins_n,
    data_in_to_device,
    clk_in_p,
    clk_in_n,
    clk_out,
    io_reset);
  input [14:0]data_in_from_pins_p;
  input [14:0]data_in_from_pins_n;
  output [29:0]data_in_to_device;
  input clk_in_p;
  input clk_in_n;
  output clk_out;
  input io_reset;

  wire clk_in_int;
  wire clk_in_n;
  wire clk_in_p;
  wire clk_out;
  wire [14:0]data_in_from_pins_int;
  wire [14:0]data_in_from_pins_n;
  wire [14:0]data_in_from_pins_p;
  wire [29:0]data_in_to_device;
  wire io_reset;

  (* BOX_TYPE = "PRIMITIVE" *) 
  BUFR #(
    .BUFR_DIVIDE("BYPASS"),
    .SIM_DEVICE("7SERIES")) 
    clkout_buf_inst
       (.CE(1'b1),
        .CLR(1'b0),
        .I(clk_in_int),
        .O(clk_out));
  (* BOX_TYPE = "PRIMITIVE" *) 
  (* CAPACITANCE = "DONT_CARE" *) 
  (* IBUF_DELAY_VALUE = "0" *) 
  (* IFD_DELAY_VALUE = "AUTO" *) 
  IBUFDS ibufds_clk_inst
       (.I(clk_in_p),
        .IB(clk_in_n),
        .O(clk_in_int));
  (* BOX_TYPE = "PRIMITIVE" *) 
  (* CAPACITANCE = "DONT_CARE" *) 
  (* IBUF_DELAY_VALUE = "0" *) 
  (* IFD_DELAY_VALUE = "AUTO" *) 
  IBUFDS \pins[0].ibufds_inst 
       (.I(data_in_from_pins_p[0]),
        .IB(data_in_from_pins_n[0]),
        .O(data_in_from_pins_int[0]));
  (* BOX_TYPE = "PRIMITIVE" *) 
  (* __SRVAL = "FALSE" *) 
  IDDR #(
    .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"),
    .INIT_Q1(1'b0),
    .INIT_Q2(1'b0),
    .IS_C_INVERTED(1'b0),
    .IS_D_INVERTED(1'b0),
    .SRTYPE("ASYNC")) 
    \pins[0].iddr_inst 
       (.C(clk_out),
        .CE(1'b1),
        .D(data_in_from_pins_int[0]),
        .Q1(data_in_to_device[0]),
        .Q2(data_in_to_device[15]),
        .R(io_reset),
        .S(1'b0));
  (* BOX_TYPE = "PRIMITIVE" *) 
  (* CAPACITANCE = "DONT_CARE" *) 
  (* IBUF_DELAY_VALUE = "0" *) 
  (* IFD_DELAY_VALUE = "AUTO" *) 
  IBUFDS \pins[10].ibufds_inst 
       (.I(data_in_from_pins_p[10]),
        .IB(data_in_from_pins_n[10]),
        .O(data_in_from_pins_int[10]));
  (* BOX_TYPE = "PRIMITIVE" *) 
  (* __SRVAL = "FALSE" *) 
  IDDR #(
    .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"),
    .INIT_Q1(1'b0),
    .INIT_Q2(1'b0),
    .IS_C_INVERTED(1'b0),
    .IS_D_INVERTED(1'b0),
    .SRTYPE("ASYNC")) 
    \pins[10].iddr_inst 
       (.C(clk_out),
        .CE(1'b1),
        .D(data_in_from_pins_int[10]),
        .Q1(data_in_to_device[10]),
        .Q2(data_in_to_device[25]),
        .R(io_reset),
        .S(1'b0));
  (* BOX_TYPE = "PRIMITIVE" *) 
  (* CAPACITANCE = "DONT_CARE" *) 
  (* IBUF_DELAY_VALUE = "0" *) 
  (* IFD_DELAY_VALUE = "AUTO" *) 
  IBUFDS \pins[11].ibufds_inst 
       (.I(data_in_from_pins_p[11]),
        .IB(data_in_from_pins_n[11]),
        .O(data_in_from_pins_int[11]));
  (* BOX_TYPE = "PRIMITIVE" *) 
  (* __SRVAL = "FALSE" *) 
  IDDR #(
    .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"),
    .INIT_Q1(1'b0),
    .INIT_Q2(1'b0),
    .IS_C_INVERTED(1'b0),
    .IS_D_INVERTED(1'b0),
    .SRTYPE("ASYNC")) 
    \pins[11].iddr_inst 
       (.C(clk_out),
        .CE(1'b1),
        .D(data_in_from_pins_int[11]),
        .Q1(data_in_to_device[11]),
        .Q2(data_in_to_device[26]),
        .R(io_reset),
        .S(1'b0));
  (* BOX_TYPE = "PRIMITIVE" *) 
  (* CAPACITANCE = "DONT_CARE" *) 
  (* IBUF_DELAY_VALUE = "0" *) 
  (* IFD_DELAY_VALUE = "AUTO" *) 
  IBUFDS \pins[12].ibufds_inst 
       (.I(data_in_from_pins_p[12]),
        .IB(data_in_from_pins_n[12]),
        .O(data_in_from_pins_int[12]));
  (* BOX_TYPE = "PRIMITIVE" *) 
  (* __SRVAL = "FALSE" *) 
  IDDR #(
    .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"),
    .INIT_Q1(1'b0),
    .INIT_Q2(1'b0),
    .IS_C_INVERTED(1'b0),
    .IS_D_INVERTED(1'b0),
    .SRTYPE("ASYNC")) 
    \pins[12].iddr_inst 
       (.C(clk_out),
        .CE(1'b1),
        .D(data_in_from_pins_int[12]),
        .Q1(data_in_to_device[12]),
        .Q2(data_in_to_device[27]),
        .R(io_reset),
        .S(1'b0));
  (* BOX_TYPE = "PRIMITIVE" *) 
  (* CAPACITANCE = "DONT_CARE" *) 
  (* IBUF_DELAY_VALUE = "0" *) 
  (* IFD_DELAY_VALUE = "AUTO" *) 
  IBUFDS \pins[13].ibufds_inst 
       (.I(data_in_from_pins_p[13]),
        .IB(data_in_from_pins_n[13]),
        .O(data_in_from_pins_int[13]));
  (* BOX_TYPE = "PRIMITIVE" *) 
  (* __SRVAL = "FALSE" *) 
  IDDR #(
    .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"),
    .INIT_Q1(1'b0),
    .INIT_Q2(1'b0),
    .IS_C_INVERTED(1'b0),
    .IS_D_INVERTED(1'b0),
    .SRTYPE("ASYNC")) 
    \pins[13].iddr_inst 
       (.C(clk_out),
        .CE(1'b1),
        .D(data_in_from_pins_int[13]),
        .Q1(data_in_to_device[13]),
        .Q2(data_in_to_device[28]),
        .R(io_reset),
        .S(1'b0));
  (* BOX_TYPE = "PRIMITIVE" *) 
  (* CAPACITANCE = "DONT_CARE" *) 
  (* IBUF_DELAY_VALUE = "0" *) 
  (* IFD_DELAY_VALUE = "AUTO" *) 
  IBUFDS \pins[14].ibufds_inst 
       (.I(data_in_from_pins_p[14]),
        .IB(data_in_from_pins_n[14]),
        .O(data_in_from_pins_int[14]));
  (* BOX_TYPE = "PRIMITIVE" *) 
  (* __SRVAL = "FALSE" *) 
  IDDR #(
    .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"),
    .INIT_Q1(1'b0),
    .INIT_Q2(1'b0),
    .IS_C_INVERTED(1'b0),
    .IS_D_INVERTED(1'b0),
    .SRTYPE("ASYNC")) 
    \pins[14].iddr_inst 
       (.C(clk_out),
        .CE(1'b1),
        .D(data_in_from_pins_int[14]),
        .Q1(data_in_to_device[14]),
        .Q2(data_in_to_device[29]),
        .R(io_reset),
        .S(1'b0));
  (* BOX_TYPE = "PRIMITIVE" *) 
  (* CAPACITANCE = "DONT_CARE" *) 
  (* IBUF_DELAY_VALUE = "0" *) 
  (* IFD_DELAY_VALUE = "AUTO" *) 
  IBUFDS \pins[1].ibufds_inst 
       (.I(data_in_from_pins_p[1]),
        .IB(data_in_from_pins_n[1]),
        .O(data_in_from_pins_int[1]));
  (* BOX_TYPE = "PRIMITIVE" *) 
  (* __SRVAL = "FALSE" *) 
  IDDR #(
    .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"),
    .INIT_Q1(1'b0),
    .INIT_Q2(1'b0),
    .IS_C_INVERTED(1'b0),
    .IS_D_INVERTED(1'b0),
    .SRTYPE("ASYNC")) 
    \pins[1].iddr_inst 
       (.C(clk_out),
        .CE(1'b1),
        .D(data_in_from_pins_int[1]),
        .Q1(data_in_to_device[1]),
        .Q2(data_in_to_device[16]),
        .R(io_reset),
        .S(1'b0));
  (* BOX_TYPE = "PRIMITIVE" *) 
  (* CAPACITANCE = "DONT_CARE" *) 
  (* IBUF_DELAY_VALUE = "0" *) 
  (* IFD_DELAY_VALUE = "AUTO" *) 
  IBUFDS \pins[2].ibufds_inst 
       (.I(data_in_from_pins_p[2]),
        .IB(data_in_from_pins_n[2]),
        .O(data_in_from_pins_int[2]));
  (* BOX_TYPE = "PRIMITIVE" *) 
  (* __SRVAL = "FALSE" *) 
  IDDR #(
    .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"),
    .INIT_Q1(1'b0),
    .INIT_Q2(1'b0),
    .IS_C_INVERTED(1'b0),
    .IS_D_INVERTED(1'b0),
    .SRTYPE("ASYNC")) 
    \pins[2].iddr_inst 
       (.C(clk_out),
        .CE(1'b1),
        .D(data_in_from_pins_int[2]),
        .Q1(data_in_to_device[2]),
        .Q2(data_in_to_device[17]),
        .R(io_reset),
        .S(1'b0));
  (* BOX_TYPE = "PRIMITIVE" *) 
  (* CAPACITANCE = "DONT_CARE" *) 
  (* IBUF_DELAY_VALUE = "0" *) 
  (* IFD_DELAY_VALUE = "AUTO" *) 
  IBUFDS \pins[3].ibufds_inst 
       (.I(data_in_from_pins_p[3]),
        .IB(data_in_from_pins_n[3]),
        .O(data_in_from_pins_int[3]));
  (* BOX_TYPE = "PRIMITIVE" *) 
  (* __SRVAL = "FALSE" *) 
  IDDR #(
    .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"),
    .INIT_Q1(1'b0),
    .INIT_Q2(1'b0),
    .IS_C_INVERTED(1'b0),
    .IS_D_INVERTED(1'b0),
    .SRTYPE("ASYNC")) 
    \pins[3].iddr_inst 
       (.C(clk_out),
        .CE(1'b1),
        .D(data_in_from_pins_int[3]),
        .Q1(data_in_to_device[3]),
        .Q2(data_in_to_device[18]),
        .R(io_reset),
        .S(1'b0));
  (* BOX_TYPE = "PRIMITIVE" *) 
  (* CAPACITANCE = "DONT_CARE" *) 
  (* IBUF_DELAY_VALUE = "0" *) 
  (* IFD_DELAY_VALUE = "AUTO" *) 
  IBUFDS \pins[4].ibufds_inst 
       (.I(data_in_from_pins_p[4]),
        .IB(data_in_from_pins_n[4]),
        .O(data_in_from_pins_int[4]));
  (* BOX_TYPE = "PRIMITIVE" *) 
  (* __SRVAL = "FALSE" *) 
  IDDR #(
    .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"),
    .INIT_Q1(1'b0),
    .INIT_Q2(1'b0),
    .IS_C_INVERTED(1'b0),
    .IS_D_INVERTED(1'b0),
    .SRTYPE("ASYNC")) 
    \pins[4].iddr_inst 
       (.C(clk_out),
        .CE(1'b1),
        .D(data_in_from_pins_int[4]),
        .Q1(data_in_to_device[4]),
        .Q2(data_in_to_device[19]),
        .R(io_reset),
        .S(1'b0));
  (* BOX_TYPE = "PRIMITIVE" *) 
  (* CAPACITANCE = "DONT_CARE" *) 
  (* IBUF_DELAY_VALUE = "0" *) 
  (* IFD_DELAY_VALUE = "AUTO" *) 
  IBUFDS \pins[5].ibufds_inst 
       (.I(data_in_from_pins_p[5]),
        .IB(data_in_from_pins_n[5]),
        .O(data_in_from_pins_int[5]));
  (* BOX_TYPE = "PRIMITIVE" *) 
  (* __SRVAL = "FALSE" *) 
  IDDR #(
    .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"),
    .INIT_Q1(1'b0),
    .INIT_Q2(1'b0),
    .IS_C_INVERTED(1'b0),
    .IS_D_INVERTED(1'b0),
    .SRTYPE("ASYNC")) 
    \pins[5].iddr_inst 
       (.C(clk_out),
        .CE(1'b1),
        .D(data_in_from_pins_int[5]),
        .Q1(data_in_to_device[5]),
        .Q2(data_in_to_device[20]),
        .R(io_reset),
        .S(1'b0));
  (* BOX_TYPE = "PRIMITIVE" *) 
  (* CAPACITANCE = "DONT_CARE" *) 
  (* IBUF_DELAY_VALUE = "0" *) 
  (* IFD_DELAY_VALUE = "AUTO" *) 
  IBUFDS \pins[6].ibufds_inst 
       (.I(data_in_from_pins_p[6]),
        .IB(data_in_from_pins_n[6]),
        .O(data_in_from_pins_int[6]));
  (* BOX_TYPE = "PRIMITIVE" *) 
  (* __SRVAL = "FALSE" *) 
  IDDR #(
    .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"),
    .INIT_Q1(1'b0),
    .INIT_Q2(1'b0),
    .IS_C_INVERTED(1'b0),
    .IS_D_INVERTED(1'b0),
    .SRTYPE("ASYNC")) 
    \pins[6].iddr_inst 
       (.C(clk_out),
        .CE(1'b1),
        .D(data_in_from_pins_int[6]),
        .Q1(data_in_to_device[6]),
        .Q2(data_in_to_device[21]),
        .R(io_reset),
        .S(1'b0));
  (* BOX_TYPE = "PRIMITIVE" *) 
  (* CAPACITANCE = "DONT_CARE" *) 
  (* IBUF_DELAY_VALUE = "0" *) 
  (* IFD_DELAY_VALUE = "AUTO" *) 
  IBUFDS \pins[7].ibufds_inst 
       (.I(data_in_from_pins_p[7]),
        .IB(data_in_from_pins_n[7]),
        .O(data_in_from_pins_int[7]));
  (* BOX_TYPE = "PRIMITIVE" *) 
  (* __SRVAL = "FALSE" *) 
  IDDR #(
    .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"),
    .INIT_Q1(1'b0),
    .INIT_Q2(1'b0),
    .IS_C_INVERTED(1'b0),
    .IS_D_INVERTED(1'b0),
    .SRTYPE("ASYNC")) 
    \pins[7].iddr_inst 
       (.C(clk_out),
        .CE(1'b1),
        .D(data_in_from_pins_int[7]),
        .Q1(data_in_to_device[7]),
        .Q2(data_in_to_device[22]),
        .R(io_reset),
        .S(1'b0));
  (* BOX_TYPE = "PRIMITIVE" *) 
  (* CAPACITANCE = "DONT_CARE" *) 
  (* IBUF_DELAY_VALUE = "0" *) 
  (* IFD_DELAY_VALUE = "AUTO" *) 
  IBUFDS \pins[8].ibufds_inst 
       (.I(data_in_from_pins_p[8]),
        .IB(data_in_from_pins_n[8]),
        .O(data_in_from_pins_int[8]));
  (* BOX_TYPE = "PRIMITIVE" *) 
  (* __SRVAL = "FALSE" *) 
  IDDR #(
    .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"),
    .INIT_Q1(1'b0),
    .INIT_Q2(1'b0),
    .IS_C_INVERTED(1'b0),
    .IS_D_INVERTED(1'b0),
    .SRTYPE("ASYNC")) 
    \pins[8].iddr_inst 
       (.C(clk_out),
        .CE(1'b1),
        .D(data_in_from_pins_int[8]),
        .Q1(data_in_to_device[8]),
        .Q2(data_in_to_device[23]),
        .R(io_reset),
        .S(1'b0));
  (* BOX_TYPE = "PRIMITIVE" *) 
  (* CAPACITANCE = "DONT_CARE" *) 
  (* IBUF_DELAY_VALUE = "0" *) 
  (* IFD_DELAY_VALUE = "AUTO" *) 
  IBUFDS \pins[9].ibufds_inst 
       (.I(data_in_from_pins_p[9]),
        .IB(data_in_from_pins_n[9]),
        .O(data_in_from_pins_int[9]));
  (* BOX_TYPE = "PRIMITIVE" *) 
  (* __SRVAL = "FALSE" *) 
  IDDR #(
    .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"),
    .INIT_Q1(1'b0),
    .INIT_Q2(1'b0),
    .IS_C_INVERTED(1'b0),
    .IS_D_INVERTED(1'b0),
    .SRTYPE("ASYNC")) 
    \pins[9].iddr_inst 
       (.C(clk_out),
        .CE(1'b1),
        .D(data_in_from_pins_int[9]),
        .Q1(data_in_to_device[9]),
        .Q2(data_in_to_device[24]),
        .R(io_reset),
        .S(1'b0));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

endmodule
`endif
