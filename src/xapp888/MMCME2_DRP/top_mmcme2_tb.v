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
// Device:              7-Series
// Author:              Tatsukawa, Defossez
// Entity Name:         top_mmcme2_tb
// Purpose:            This is a basic demonstration that drives the MMCM_DRP
//                      ports to trigger two reconfiguration events, one for
//                      each state.
// Tools:               QuestaSim_10.7d or newer
// Limitations:
//
// Vendor:              Xilinx Inc.
// Version:             0.01
// Filename:            top_mmcme2_tb.v
// Date Created:        30-Jul-2014
// Date Last Modified:  26-Jun-2019
//-------------------------------------------------------------------------------------------
// Disclaimer:
//        This disclaimer is not a license and does not grant any rights to the materials
//        distributed herewith. Except as otherwise provided in a valid license issued to you
//        by Xilinx, and to the maximum extent permitted by applicable law: (1) THESE MATERIALS
//        ARE MADE AVAILABLE "AS IS" AND WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL
//        WARRANTIES AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING BUT NOT LIMITED
//        TO WARRANTIES OF MERCHANTABILITY, NON-INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR
//        PURPOSE; and (2) Xilinx shall not be liable (whether in contract or tort, including
//        negligence, or under any other theory of liability) for any loss or damage of any
//        kind or nature related to, arising under or in connection with these materials,
//        including for any direct, or any indirect, special, incidental, or consequential
//        loss or damage (including loss of data, profits, goodwill, or any type of loss or
//        damage suffered as a result of any action brought by a third party) even if such
//        damage or loss was reasonably foreseeable or Xilinx had been advised of the
//        possibility of the same.
//
// CRITICAL APPLICATIONS
//        Xilinx products are not designed or intended to be fail-safe, or for use in any
//        application requiring fail-safe performance, such as life-support or safety devices
//        or systems, Class III medical devices, nuclear facilities, applications related to
//        the deployment of airbags, or any other applications that could lead to death,
//        personal injury, or severe property or environmental damage (individually and
//        collectively, "Critical Applications"). Customer assumes the sole risk and
//        liability of any use of Xilinx products in Critical Applications, subject only to
//        applicable laws and regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE AT ALL TIMES.
//
// Contact:    e-mail  hotline@xilinx.com        phone   + 1 800 255 7778
//-------------------------------------------------------------------------------------------
// Revision History:
//  Rev: 30-Jul-20149 - Tatsukawa
//      Initial version of this design - source code.
//  Rev: 26-Jun-2019 - Defossez
//      Make sure the simulation works after modifications to the design.
//-------------------------------------------------------------------------------------------
//
`timescale 1ps / 1ps
//-------------------------------------------------------------------------------------------
module top_tb  ();
    reg SSTEP, RST, CLKin, STATE;
    wire SRDY, clk0out, clk1out, clk2out, clk3out, clk4out, clk5out, clk6out;
//-------------------------------------------------------------------------------------------
    top_mmcme2 U1
    (
        .SSTEP      (SSTEP),
        .STATE      (STATE),
        .RST        (RST),
        .CLKIN      (CLKin),
        .SRDY       (SRDY),
        .LOCKED_OUT (locked),
        .CLK0OUT    (clk0out),
        .CLK1OUT    (clk1out),
        .CLK2OUT    (clk2out),
        .CLK3OUT    (clk3out),
        .CLK4OUT    (clk4out),
        .CLK5OUT    (clk5out),
        .CLK6OUT    (clk6out)
    );
//-------------------------------------------------------------------------------------------
    localparam one_ns = 1000;
    localparam clock_period = 10;
    parameter [1:0]    STARTUP = 0, STATE0 = 1, STATE1 = 2, UNDEFINED = 3;
    reg [1:0] SM = STARTUP ;

always @ (posedge CLKin)
    begin
        if (RST)
               SM = STARTUP;
        else
            case (SM)
                STARTUP:
                    begin
                        SM = STATE0;
                        SSTEP=1'b0;
                        STATE=1'b0;
                    end
                STATE0:
                    begin
                        if (locked == 1 )
                            begin
                                #(1 * clock_period * one_ns) SSTEP= 1'b1;
                                #(1 * clock_period * one_ns) SSTEP=1'b0;
                                #(100 * clock_period * one_ns) SM = STATE1 ;
                                STATE=1'b1;
                            end
                    end
                STATE1:
                    begin
                        if (locked == 1 )
                            begin
                                #(1 * clock_period * one_ns) SSTEP= 1'b1;
                                #(1 * clock_period * one_ns) SSTEP=1'b0;
                                #(100 * clock_period * one_ns) SM = STATE0;
                                STATE=1'b0;
                            end
                    end
                UNDEFINED:   SM= STARTUP;
            endcase
        end
//
    initial
        begin
                CLKin = 0;
                RST = 1;
                #50000 RST = 0;
        end
    always
        # (clock_period * one_ns / 2) CLKin = ~CLKin;
//
//-------------------------------------------------------------------------------------------
endmodule
//
