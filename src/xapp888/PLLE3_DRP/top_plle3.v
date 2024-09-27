//------------------------------------------------------------------------------------------
//   ____  ____
//  /   /\/   /
// /___/  \  /
// \   \   \/    � Copyright 2019 Xilinx, Inc. All rights reserved.
//  \   \        This file contains confidential and proprietary information of Xilinx, Inc.
//  /   /        and is protected under U.S. and international copyright and other
// /___/   /\    intellectual property laws.
// \   \  /  \
//  \___\/\___\
//
//-------------------------------------------------------------------------------------------
// Device:              Ultrascale
// Author:              Tatsukawa, Kruger, Defossez
// Entity Name:         top.plle3
// Purpose:             This is a basic demonstration of the PLL_DRP
//                      connectivity to the PLL_ADV.
// Tools:               Vivado_2019 or newer
// Limitations:
//
// Vendor:              Xilinx Inc.
// Version:             0.01
// Filename:            top.plle3.v
// Date Created:        02-May-2016
// Date Last Modified:  20-Jun2019
//-------------------------------------------------------------------------------------------
// Disclaimer:
//		This disclaimer is not a license and does not grant any rights to the materials
//		distributed herewith. Except as otherwise provided in a valid license issued to you
//		by Xilinx, and to the maximum extent permitted by applicable law: (1) THESE MATERIALS
//		ARE MADE AVAILABLE "AS IS" AND WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL
//		WARRANTIES AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING BUT NOT LIMITED
//		TO WARRANTIES OF MERCHANTABILITY, NON-INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR
//		PURPOSE; and (2) Xilinx shall not be liable (whether in contract or tort, including
//		negligence, or under any other theory of liability) for any loss or damage of any
//		kind or nature related to, arising under or in connection with these materials,
//		including for any direct, or any indirect, special, incidental, or consequential
//		loss or damage (including loss of data, profits, goodwill, or any type of loss or
//		damage suffered as a result of any action brought by a third party) even if such
//		damage or loss was reasonably foreseeable or Xilinx had been advised of the
//		possibility of the same.
//
// CRITICAL APPLICATIONS
//		Xilinx products are not designed or intended to be fail-safe, or for use in any
//		application requiring fail-safe performance, such as life-support or safety devices
//		or systems, Class III medical devices, nuclear facilities, applications related to
//		the deployment of airbags, or any other applications that could lead to death,
//		personal injury, or severe property or environmental damage (individually and
//		collectively, "Critical Applications"). Customer assumes the sole risk and
//		liability of any use of Xilinx products in Critical Applications, subject only to
//		applicable laws and regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE AT ALL TIMES.
//
// Contact:    e-mail  hotline@xilinx.com        phone   + 1 800 255 7778
//-------------------------------------------------------------------------------------------
// Revision History:
//  Rev: 02-May-2016 - Tatsukawa
//      Initial version of this design - source code.
//  Rev: 02-May-2016 - Tatsukawa
//      Updated S2 settings to match comments
//  Rev: 21-Jun-2019 - Defossez
//      POSTCRC attribute added through a virtual bandwidth parameter.
//  Rev: 25-Jun-2019 - Defossez
//      Register the LOCKED signal. Provide a choice to register or not the LOCKED output.
//      LOCKED is registered in the "plle3_drp" component and is registered on the input
//      clock of the PLL. When LOCKED is not registered it's just passed through, as is,
//      the "plle3_drp" component.
//-------------------------------------------------------------------------------------------
//
`timescale 1ps/1ps
//
//-------------------------------------------------------------------------------------------
// Entity pin description
//-------------------------------------------------------------------------------------------
// Inputs
//      SSTEP:      Start a reconfiguration. It should only be pulsed for one clock cycle.
//      STATE:      Determines which state the PLL_ADV will be reconfigured to. A value
//                  of 0 correlates to state 1, and a value of 1 correlates to state 2.
//      RST:        RST will reset the entire reference design including the PLL_ADV.
//      CLKIN:      Clock for the PLL_ADV CLKIN as well as the clock for the PLL_DRP module
//      SRDY:       Pulses for one clock cycle after the PLL_ADV is locked and the
//                  PLL_DRP module is ready to start another re-configuration.
// Outputs
//      LOCKED_OUT: PLL is locked after configuration or reconfiguration.
//      CLKOUTPHY:  High speed clock output used for Select-IO in native mode.
//      CLK0OUT:    These are the clock outputs from the PLL_ADV.
//      CLK1OUT:    These are the clock outputs from the PLL_ADV.
//-------------------------------------------------------------------------------------------
module top_plle3
    (
        input    SSTEP,
        input    STATE,
        input    RST,
        input    CLKIN,
        output   SRDY,
        output 	 LOCKED_OUT,
        //output    CLKOUTPHYOUT,
        output   CLK0OUT,
        output   CLK1OUT
    );
//-------------------------------------------------------------------------------------------
// These signals are used as direct connections between the PLL_ADV and the PLL_DRP.
(* MARK_DEBUG="true" *)   wire [15:0]    di;
(* MARK_DEBUG="true" *)   wire [6:0]     daddr;
(* MARK_DEBUG="true" *)   wire [15:0]    dout;
(* MARK_DEBUG="true" *)   wire           den;
(* MARK_DEBUG="true" *)   wire           dwe;
//
wire            CLKIN_ibuf;
wire            dclk;
wire            rst_pll;
wire            drdy;
reg			    current_state;
reg [7:0]	    sstep_int ;
reg			    init_drp_state = 1;
// These signals are used for the BUFG's necessary for the design.
wire            clkin_bufgout;
wire            clkfb_bufgout;
wire            clkfb_bufgin;
wire            clk0_bufgin;
wire            clk0_bufgout;
wire            clk1_bufgin;
wire            clk1_bufgout;
wire            clkoutphy_bufgin;
wire            clkoutphy_bufgout;
wire            LOCKED;
//-------------------------------------------------------------------------------------------
//
assign CLKIN_ibuf = CLKIN;
//
BUFG BUFG_IN    (.O (clkin_bufgout),    .I (CLKIN_ibuf));
BUFG BUFG_FB    (.O (clkfb_bufgout),    .I(clkfb_bufgin));
BUFG BUFG_CLK0  (.O (clk0_bufgout),     .I(clk0_bufgin));
BUFG BUFG_CLK1  (.O (clk1_bufgout),     .I(clk1_bufgin));
// ODDR registers used to output clocks
ODDRE1 ODDR_CLK0 (.Q (CLK0OUT), .C (clk0_bufgout), .SR (1'b0), .D1 (1'b1), .D2 (1'b0));
ODDRE1 ODDR_CLK1 (.Q (CLK1OUT), .C (clk1_bufgout), .SR (1'b0), .D1(1'b1), .D2 (1'b0));
//
// PLL_ADV that reconfiguration will take place on
//      DIVCLK_DIVIDE:  Value from 1 to 106
//      CLKFBOUT_MULT:  Value from 2 to 64
//      CLKFBOUT_PHASE: Value from -360 to 360
//      CLKIN_PERIOD:   Value from 0.938 to 14.286. Set the period (ns) of input the clock
//      REF_JITTER:     Value from 0.000 to 0.999
//  CLKOUT parameters:
//      DIVIDE:         Value from 1 to 128
//      DUTY_CYCLE:     Value from 0.01 to 0.99 - This is dependent on the divide value.
//      PHASE:          Value from -360 to 360.0 - This is dependent on the divide value.
//      USE_FINE_PS:    TRUE or FALSE
//      CLKOUTPHY_MODE: VCO_2X, VCO, VCO_HALF
//  Misc parameters
//      COMPENSATION:   "AUTO", PHY_ALIGN, BUF_IN, INTERNAL
//      STARTUP_WAIT:   "TRUE" or "FALSE"
//
    PLLE3_ADV #(
        .DIVCLK_DIVIDE      (1),
        .CLKFBOUT_MULT      (6),
        .CLKFBOUT_PHASE     (0.0),
        .CLKIN_PERIOD       (10.000),
        .REF_JITTER         (0.010),
        .CLKOUT0_DIVIDE     (6),
        .CLKOUT0_DUTY_CYCLE (0.5),
        .CLKOUT0_PHASE      (0.0),
        .CLKOUT1_DIVIDE     (6),
        .CLKOUT1_DUTY_CYCLE (0.5),
        .CLKOUT1_PHASE      (180.0),
        .CLKOUTPHY_MODE     ("VCO"),
        .COMPENSATION       ("AUTO"),
        .STARTUP_WAIT       ("FALSE")
    ) pll_test_inst (
        .CLKIN              (clkin_bufgout),
        .CLKFBIN            (clkfb_bufgout),
        .PWRDWN             (1'b0),
        .CLKOUTPHYEN        (1'b1),
        .RST                (rst_pll),
        .CLKFBOUT           (clkfb_bufgin),
        .CLKOUT0            (clk0_bufgin),
        .CLKOUT0B           (),
        .CLKOUT1            (clk1_bufgin),
        .CLKOUT1B           (),
        .CLKOUTPHY          (),
        .DCLK               (dclk),
        .DI                 (di),
        .DADDR              (daddr),
        .DEN                (den),
        .DWE                (dwe),
        .DO                 (dout),
        .DRDY               (drdy),
        .LOCKED             (LOCKED)
    );
//
//-------------------------------------------------------------------------------------------
//
// PLL_DRP instance that will perform the reconfiguration operations
plle3_drp #(
    // Register the LOCKED signal with teh MMCME3_ADV input clock.
    // The LOCKED_IN (LOCKED from the MMCME3_ADV) is fed into a register and then
    // passed the LOCKED_OUT when REGISTER_LOCKED is set to "Reg" or when set to
    // "NoReg" LOCKED_IN is just passed on to LOCKED_OUT without being registered.
    .REGISTER_LOCKED       ("Reg"),
    // Use the registered LOCKED signal from the MMCME3 also for the DRP state machine.
    .USE_REG_LOCKED        ("No"),
    // Possible combination of above two parameters:
    // | REGISTER_LOCKED | USE_REG_LOCKED |                                            |
    // |-----------------|----------------|--------------------------------------------|
    // |      "NoReg"    |     "No"       | LOCKED is just passed through mmcme3_drp   |
    // |                 |                | and is used as is with the state machine   |
    // |      "NoReg"    |     "Yes"      | NOT ALLOWED                                |
    // |       "Reg"     |     "No"       | LOCKED is registered but the unregistered  |
    // |                 |                | version is used for the state machine.     |
    // |       "Reg"     |     "Yes"      | LOCKED is registered and the registered    |
    // |                 |                | version is also used by the state machine. |
    //
    //***********************************************************************
    // State 1 Parameters - These are for the first reconfiguration state.
    //***********************************************************************
    // Set the multiply to 6.0 with 0 deg phase offset, optimal bandwidth, input divide of 1
    .S1_CLKFBOUT_MULT   (6),
    .S1_CLKFBOUT_PHASE  (000_000),
    .S1_DIVCLK_DIVIDE   (1),
    .S1_CLKOUTPHY_MODE  ("VCO"),
    .S1_VBANDWIDTH      ("DEFAULT"),
    // Set clockout0 to a divide of 6.0 (unity gain), 0 deg phase offset, 50/50 duty cycle
    .S1_CLKOUT0_DIVIDE  (6),
    .S1_CLKOUT0_PHASE   (000_000),
    .S1_CLKOUT0_DUTY    (50_000),
    // Set clockout 1 to a divide of 1, 0 deg phase offset, 50/50 duty cycle
    .S1_CLKOUT1_DIVIDE  (1),
    .S1_CLKOUT1_PHASE   (000_000),
    .S1_CLKOUT1_DUTY    (50_000),
    //***********************************************************************
    // State 2 Parameters - These are for the second reconfiguration state.
    //***********************************************************************
    .S2_CLKFBOUT_MULT   (7),
    .S2_CLKFBOUT_PHASE  (000_000),
    .S2_DIVCLK_DIVIDE   (1),
    .S2_CLKOUTPHY_MODE  ("VCO_HALF"),
    .S2_VBANDWIDTH      ("POSTCRC"),
    // Set clockout 0 to a divide of 7, 0 deg phase offset, 50/50 duty cycle
    .S2_CLKOUT0_DIVIDE  (7),
    .S2_CLKOUT0_PHASE   (000_000),
    .S2_CLKOUT0_DUTY    (50_000),
    // Set clockout 1 to a divide of 7, 45.0 deg phase offset, 50/50 duty cycle
    .S2_CLKOUT1_DIVIDE  (7),
    .S2_CLKOUT1_PHASE   (045_000),
    .S2_CLKOUT1_DUTY    (50_000)
) pll_drp_inst (
    .SADDR              (STATE),
    .SEN                (sstep_int[0]),
    .RST                (RST),
    .SRDY               (SRDY),
    .SCLK               (clkin_bufgout),
    .DO                 (dout),
    .DRDY               (drdy),
    .LOCK_REG_CLK_IN    (clkin_bufgout),
    .LOCKED_IN          (LOCKED),
    .DWE                (dwe),
    .DEN                (den),
    .DADDR              (daddr),
    .DI                 (di),
    .DCLK               (dclk),
    .RST_PLL            (rst_pll),
    .LOCKED_OUT         (LOCKED_OUT)
);
//
//***********************************************************************
// Additional STATE and SSTEP logic for push buttons and switches
//***********************************************************************
// The following logic is not required but is being used to allow the DRP
// circuitry work more effectively with boards that use toggle switches or
// buttons that may not adhere to the single clock requirement.
//
// Only start DRP after initial lock and when STATE has changed
always @ (posedge clkin_bufgout or posedge SSTEP)
    if (SSTEP) sstep_int <=  8'h80;
    else sstep_int <= {1'b0, sstep_int[7:1]};
//
//-------------------------------------------------------------------------------------------
//
endmodule
//
