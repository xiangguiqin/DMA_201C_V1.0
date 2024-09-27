#-------------------------------------------------------------------------------------------
#-   ____  ____
#-  /   /\/   /
#- /___/  \  /
#- \   \   \/    � Copyright 2019 Xilinx, Inc. All rights reserved.
#-  \   \        This file contains confidential and proprietary information of Xilinx, Inc.
#-  /   /        and is protected under U.S. and international copyright and other
#- /___/   /\    intellectual property laws.
#- \   \  /  \
#-  \___\/\___\
#-
#--------------------------------------------------------------------------------------------
#- Device:              Ultrascale
#- Author:              Tatsukawa, Kruger, Defossez
#- Entity Name:         top_plle3
#- Purpose:
#-   This TCL script is used to do basic project setup and clarify the DRP settings.
#-
#-  Ultrascale PLL is called:          PLLE3
#-      7-Series PLL is called:        PLLE2
#-      UltrascalePlus PLL is called:  PLLE4
#-  PLLE3 attributes
#-      CLKINx_PERIOD:      0.938 to 14.286
#-      REF_JITTERx:        0.000 to 0.999
#-      COMPENSATION:       AUTO, PHY_ALIGN, INTERNAL and BUF_IN
#-      CLKOUTPHY_MODE:     VCO_2X, VCO, VCO_HALF
#-      DIVCLK_DIVIDE:      1 to 15
#-      CLKFBOUT_MULT:      1 to 19
#-      CLKFBOUT_PHASE:     -360 to 360
#-      CLKOUTn_DIVIDE:     1 to 128
#-      CLKOUTn_PHASE:      -360 to 360
#-      CLKOUTn_DUTY_CYCLE: 0.01 to 0.99
#-  A PLL has NO bandwidth attribute. Default the bandwidth setting is calculated from the
#-  given divide factor. When in Ultrascale a SEM-IP core is used in conjunction with a PLLE3
#-  it is possible that the jitter is levated. To compensate that higher jitter the bandwidth
#-  settings of the PLL must be adjusted. Therefore a virtual bandwidth is introduced.
#-  In the verilog source code this parameter is called "VBANDWIDTH".
#-  For the command "xapp888_drp_settings" a value "DEFAULT" or "POSTCRC" must be specified.
#-  REMARK:
#-      it is ONLY ALLOWED to change this setting from "default" to "postcrc" when the
#-      PLL is used in conjunction with a SEM-IP core.
#-
#-  XAPP888 TCL commands:
#-      xapp888_create_project <> - Basic project setup. Adjust as needed
#-      xapp888_help <>           - Descriptions of added TCL commands
#-
#-  XAPP888 TCL DRP Settings:
#-      xapp888_drp_settings <CLKFBOUT_MULT>  <DIVCLK_DIVIDE> <PHASE> <DEFAULT|POSTCRC>
#-      Displays & Returns the ordered pairs of DRP addresses & Data
#-      REMARK 1:
#-          <DEFAULT|POSTCRC>, can be in upper or lower case.
#-      REMARK 2:
#-          This setting calculates the values for the PLL bandwidth settings.
#-          it is ONLY ALLOWED to change this setting from "default" to "postcrc" when the
#-          PLL is used in conjunction with a SEM-IP core.
#-
#-      xapp888_drp_clkout <DIVIDE> <Duty Cycle e.g. 0.5> <Phase e.g.11.25> <CLKOUT0 to CLKOUT6>
#-      Displays & Returns the ordered pairs of DRP addresses & Data
#-
#- TCL process list:
#-     - xapp888_create_project     {}
#-     - xapp888_drp_clkout         {divide dutycycle phase clkout}
#-     - xapp888_drp_calc_m         {divide phase}
#-     - xapp888_drp_calc_d         {divide}
#-     - xapp888_dec2bin4ltht       {dec}
#-     - xapp888_cpres              {div bw}
#-     - xapp888_locking            {div}
#-     - xapp888_bin2hex            {bits}
#-     - xapp888_hex2bin            {hex}
#-     - xapp888_dec2hex            {value}
#-     - xapp888_drp_settings       {m d phase bw}
#-     - xapp888_dec2bin            {dec bits}
#-     - xapp888_help               {}
#-
#- Tools:               Vivado_2019 or newer
#- Limitations:
#-
#- Vendor:              Xilinx Inc.
#- Version:             0.01
#- Filename:            top_plle3.tcl
#- Date Created:        15-Jun-2015
#- Date Last Modified:  20-Jun-2019
#--------------------------------------------------------------------------------------------
#- Disclaimer:
#-        This disclaimer is not a license and does not grant any rights to the materials
#-        distributed herewith. Except as otherwise provided in a valid license issued to you
#-        by Xilinx, and to the maximum extent permitted by applicable law: (1) THESE MATERIALS
#-        ARE MADE AVAILABLE "AS IS" AND WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL
#-        WARRANTIES AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING BUT NOT LIMITED
#-        TO WARRANTIES OF MERCHANTABILITY, NON-INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR
#-        PURPOSE; and (2) Xilinx shall not be liable (whether in contract or tort, including
#-        negligence, or under any other theory of liability) for any loss or damage of any
#-        kind or nature related to, arising under or in connection with these materials,
#-        including for any direct, or any indirect, special, incidental, or consequential
#-        loss or damage (including loss of data, profits, goodwill, or any type of loss or
#-        damage suffered as a result of any action brought by a third party) even if such
#-        damage or loss was reasonably foreseeable or Xilinx had been advised of the
#-        possibility of the same.
#-
#- CRITICAL APPLICATIONS
#-        Xilinx products are not designed or intended to be fail-safe, or for use in any
#-        application requiring fail-safe performance, such as life-support or safety devices
#-        or systems, Class III medical devices, nuclear facilities, applications related to
#-        the deployment of airbags, or any other applications that could lead to death,
#-        personal injury, or severe property or environmental damage (individually and
#-        collectively, "Critical Applications"). Customer assumes the sole risk and
#-        liability of any use of Xilinx products in Critical Applications, subject only to
#-        applicable laws and regulations governing limitations on product liability.
#-
#- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE AT ALL TIMES.
#-
#- Contact:    e-mail  hotline@xilinx.com        phone   + 1 800 255 7778
#--------------------------------------------------------------------------------------------
#- Revision History:
#-  Rev: 15-Jun-2014 - Tatsukawa, Kruger, Defossez
#-      Initial version of this design - source code.
#-  Rev: 22-Oct-2014 - Tatsukawa, Kruger, Defossez
#-      Added TCL DRP commands
#-  Rev: 17-Mar-2016 - Tatsukawa
#-      Added min/max duty cycle checks
#-  Rev: 18-Apr-2017 - Kruger
#-      Fixed LOCK settings
#-  Rev: 28-Jun-2018 - Defossez
#-      Fixed duty cycles for divide > 64
#-  Rev: 20-Jun-2019 - Defossez
#-      Add BANDWIDTH POSTCRC attribute
#--------------------------------------------------------------------------------------------
#
proc xapp888_create_project {} {
    create_project xapp888_ultrascale  -force xapp888_ultrascale -part xcku040-ffva1156-1-c
    add_files -norecurse {plle3_drp.v top_plle3.v  top_plle3.xdc plle3_drp_func.h}
    import_files -force -norecurse
    import_files -fileset sim_1 -norecurse {top_plle3_tb.v}
    update_compile_order -fileset sim_1
}
#--------------------------------------------------------------------------------------------
#
proc xapp888_drp_clkout {divide dutycycle phase clkout} {
    set clkout_lower [string tolower $clkout]
        switch -glob -- $clkout_lower {
            clkout0  {  set daddr_reg1 08
                        set daddr_reg2 09
                        }
            clkout1  {  set daddr_reg1 0A
                        set daddr_reg2 0B
                        }
    }
        if {$phase < 0} {set phase [expr 360 + $phase]}
        set phasecycles_float [expr (($divide*$phase)/360)]
        set phasecycles [format %0.f $phasecycles_float]
        set pmphase [expr ($phase - ($phasecycles *360.000)/$divide)]
        #PLLE3 doesn't support fine phase shifting.
        set pmphasecycles 0

    puts "PLLE3 Requested phase is: $phase; Given divide=$divide then phase increments in [format %f [expr 360.000/$divide ]  ];  "
    #puts "DT will be $phasecycles, PM will be $pmphasecycles"
    #puts "Phase will be shifted by VCO period * $phasecycles.[expr 1000*$pmphasecycles / 8]"
    #puts "Phase will be shifted by [format %f [expr $phasecycles * 360.000 / $divide]] + [format %f  [expr $pmphasecycles * 45.000 / $divide]] = [format %f [expr ( $phasecycles * 360.000 / $divide) + ($pmphasecycles * 45.000 / $divide) ] ]"
    #puts "Requested Phase is: $phase; Actual: [format %f [expr ( $phasecycles * 360.000 / $divide) + ($pmphasecycles * 45.000 / $divide) ] ];  "

        set dc_step_size [expr  0.5 / $divide]
        if {$divide < 64} {
            set min_dc [expr 1.0 / $divide]
            set max_dc [expr ($divide - 0.5) / $divide]
        } else {
            set min_dc [expr ($divide - 64.0) / $divide]
            set max_dc [expr (64 + 0.5) / $divide]
        }
        if {$dutycycle < $min_dc} {puts "\n\tWARNING: Min duty cycle violation $dutycycle < $min_dc\n\t         Changing dutycycle to $min_dc\n"; set dutycycle $min_dc}
        if {$dutycycle > $max_dc} {puts "\n\tWARNING: Max duty cycle is $dutycycle > $max_dc\n\t         Changing dutycycle to $max_dc\n"; set dutycycle $max_dc}
        #puts "min_dc: $min_dc,  max_dc: $max_dc, dc_step_size: $dc_step_size, DC: $dutycycle"

        set ht [scan [expr int($dutycycle * [expr ($divide ) ])] %d]
        set lt [scan [expr $divide - $ht] %d]
        #puts "ht: $ht,  lt: $lt, DC: $dutycycle"
        set even_high [scan [expr $divide / 2] %d]
        set odd [expr $divide - $even_high * 2]

        if {$divide == 1} {
            set drp_reg1 "[xapp888_bin2hex [binary scan [binary format I $pmphasecycles] B32 var;string range $var end-2 end]1000001000001]"
            set drp_reg2 "[xapp888_bin2hex 00000000[expr $odd]1[xapp888_dec2bin $phasecycles 6] ]"
            puts "DADDR_$daddr_reg1: $drp_reg1\t-[string toupper $clkout] Register 1"
            puts "DADDR_$daddr_reg2: $drp_reg2\t-[string toupper $clkout] Register 2"
            return "$daddr_reg1 $drp_reg1 $daddr_reg2 $drp_reg2"
        } elseif {[expr fmod($divide,1)] == 0  }  {
            set drp_reg1 "[xapp888_bin2hex [binary scan [binary format I $pmphasecycles] B32 var;string range $var end-2 end]1[xapp888_dec2bin4ltht $ht][xapp888_dec2bin4ltht $lt]]"
            set drp_reg2 "[xapp888_bin2hex 00000000[expr $odd]0[xapp888_dec2bin $phasecycles 6] ]"
            # PLLE3 only supports course phase shifts
            puts "DADDR_$daddr_reg1: $drp_reg1\t-[string toupper $clkout] Register 1: Requested Phase is: $phase; Actual: [format %f [expr ( $phasecycles * 360.000 / $divide) + (0 * 45.000 / $divide) ] ]"
            puts "DADDR_$daddr_reg2: $drp_reg2\t-[string toupper $clkout] Register 2"
            return "$daddr_reg1 $drp_reg1 $daddr_reg2 $drp_reg2"
        } elseif {[string tolower $clkout] == "clkout0" } {
            set drp_frac_registers [xapp888_drp_clkout_frac $divide $phase ]
            set drp_reg1 [xapp888_bin2hex [lindex $drp_frac_registers 0]]
            set drp_reg2 [xapp888_bin2hex [lindex $drp_frac_registers 1]]
            set drp_regshared [xapp888_bin2hex [lindex $drp_frac_registers 2]0000000000]
            # PLLE3 only supports course phase shifts
            puts "DADDR_$daddr_reg2: $drp_reg2\t-[string toupper $clkout] Register 1: Requested Phase is: $phase; Actual: [format %f [expr ( $phasecycles * 360.000 / $divide) + (0 * 45.000 / $divide) ] ]"
            puts "DADDR_$daddr_reg1: $drp_reg1\t-[string toupper $clkout] Register 2"
            puts "DADDR_07: $drp_regshared\t-[string toupper $clkout] Register Shared with CLKOUT5"
            return "08 $drp_reg1 09 $drp_reg2 07 $drp_regshared"
        }  else {puts "\nERROR: Fractional divide setting only supported for CLKOUT0. Output clock set to [string toupper $clkout] \n"
    }
}
#--------------------------------------------------------------------------------------------
#
proc xapp888_drp_calc_m {divide phase} {
    set phasecycles [expr int(($divide*$phase)/360)]
    set pmphase [expr ($phase - ($phasecycles *360)/$divide)]

    #PLLE3 doesn't support fine phase shifting so disable    set pmphasecycles [scan [expr int(($pmphase *$divide)/ 45)] %d]
    set pmphasecycles 0

    set ht [scan [expr ($divide ) / 2] %d]
    set lt [scan [expr $divide - $ht] %d]
    set odd [expr $lt - $ht]
    set daddr_reg1 14
    set daddr_reg2 15
    set daddr_regshared 13

    puts "PLLE3 Requested phase is: $phase; Given divide=$divide then phase increments in [format %f [expr 360.000/$divide ]  ];  "

    if {$divide == 1} {
        set drp_reg1 "[xapp888_bin2hex [binary scan [binary format I $pmphasecycles] B32 var;string range $var end-2 end]1000001000001]"
        set drp_reg2 "[xapp888_bin2hex 00000000[expr $odd]1[xapp888_dec2bin $phasecycles 6] ]"
        puts "DADDR_$daddr_reg1: $drp_reg1\t-CLKFBOUT Register 1- "
        puts "DADDR_$daddr_reg2: $drp_reg2\t-CLKFBOUT Register 2- "
        return "$daddr_reg1 $drp_reg1 $daddr_reg2 $drp_reg2"
    } elseif {$divide > 19 } {
        puts "DADDR_14: ERROR: M must be 1 to 19\t-CLKFBOUT Register 2-"
        puts "DADDR_15: ERROR: M must be 1 to 19\t-CLKFBOUT Register 2-\tNOTE: The calculations are only for the non-fractional settings. CLKFBOUT must use an integer divide value for these DRP settings to work"
        return "14 ERROR 15 ERROR "
    } elseif {[expr fmod($divide,1)] > 0} {
        puts "ERROR: PLLE3 does not support fractional settings"
        return "14 ERROR 15 ERROR "
    } else {
        puts "DADDR_$daddr_reg1: [xapp888_bin2hex [binary scan [binary format I $pmphasecycles] B32 var;string range $var end-2 end]1[xapp888_dec2bin4ltht $ht][xapp888_dec2bin4ltht $lt]]\t-CLKFBOUT Register 1- Requested Phase is: $phase; Actual: [format %f [expr ( $phasecycles * 360.000 / $divide) + (0 * 45.000 / $divide) ] ]"
        puts "DADDR_$daddr_reg2: [xapp888_bin2hex 00000000[expr $odd]0[binary scan [binary format I $phasecycles] B32 var;string range $var end-5 end] ]\t-CLKFBOUT Register 2- "
        return "$daddr_reg1  [xapp888_bin2hex [binary scan [binary format I $pmphasecycles] B32 var;string range $var end-2 end]1[xapp888_dec2bin4ltht $ht][xapp888_dec2bin4ltht $lt]] $daddr_reg2  [xapp888_bin2hex 00000000[expr $odd]0[binary scan [binary format I $phasecycles] B32 var;string range $var end-5 end] ]"
    }
}
#--------------------------------------------------------------------------------------------
#
proc xapp888_drp_calc_d {divide} {
    set ht [scan [expr ($divide ) / 2] %d]
    set lt [scan [expr $divide - $ht] %d]
    if {$divide == 1} {
        puts "DADDR_16: [xapp888_bin2hex 0001000001000001]\t-DIVCLK Register $divide-"
        return "16 [xapp888_bin2hex 0001000001000001]"
    } elseif { $divide > 19} {
        puts "DADDR_16: ERROR D must be 1 to 19"
        return "16 ERROR"
    } else {
        puts "DADDR_16: [xapp888_bin2hex 0000[xapp888_dec2bin4ltht $ht][xapp888_dec2bin4ltht $lt] ]\t-DIVCLK Register $divide-" }
        return "16 [xapp888_bin2hex 0000[xapp888_dec2bin4ltht $ht][xapp888_dec2bin4ltht $lt] ] "
}

proc xapp888_dec2bin4ltht {dec} {
     binary scan [binary format c $dec] B* bin
     string range $bin end-5 end
}
#--------------------------------------------------------------------------------------------
#
proc xapp888_cpres {div bw} {
    #CP_RES_LFHF
    set div [scan $div %d]
    set bw_lower [string tolower $bw]
    if [$bw_lower == "default"] {
        switch -glob -- $div {
            1   {set CP 0010 ; set RES 1111 ; set LFHF 01 }
            2   {set CP 0010 ; set RES 0011 ; set LFHF 11 }
            3   {set CP 0011 ; set RES 0011 ; set LFHF 11 }
            4   {set CP 0010 ; set RES 0001 ; set LFHF 11 }
            5   {set CP 0010 ; set RES 0110 ; set LFHF 11 }
            6   {set CP 0010 ; set RES 1010 ; set LFHF 11 }
            7   {set CP 0010 ; set RES 1010 ; set LFHF 11 }
            8   {set CP 0011 ; set RES 0110 ; set LFHF 11 }
            9   {set CP 0010 ; set RES 1100 ; set LFHF 11 }
            10  {set CP 0010 ; set RES 1100 ; set LFHF 11 }
            11  {set CP 0010 ; set RES 1100 ; set LFHF 11 }
            12  {set CP 0010 ; set RES 0010 ; set LFHF 11 }
            13  {set CP 0011 ; set RES 1100 ; set LFHF 11 }
            14  {set CP 0011 ; set RES 1100 ; set LFHF 11 }
            15  {set CP 0011 ; set RES 1100 ; set LFHF 11 }
            16  {set CP 0011 ; set RES 1100 ; set LFHF 11 }
            17  {set CP 0011 ; set RES 0010 ; set LFHF 11 }
            18  {set CP 0011 ; set RES 0010 ; set LFHF 11 }
            19  {set CP 0011 ; set RES 0010 ; set LFHF 11 }
        }
    } else if [bw_lower == "postcrc"] {
        switch glob -- $div {                                 # CP  RES LFHF
            1   {set CP 0010 ; set RES 1011 ; set LFHF 00 }   # 2   11    0
            2   {set CP 0101 ; set RES 1111 ; set LFHF 00 }   # 5   15    0
            3   {set CP 0110 ; set RES 1011 ; set LFHF 00 }   # 6   11    0
            4   {set CP 1110 ; set RES 1111 ; set LFHF 00 }   # 14  15    0
            5   {set CP 1110 ; set RES 0111 ; set LFHF 00 }   # 14  7     0
            6   {set CP 0111 ; set RES 1001 ; set LFHF 00 }   # 7   9     0
            7   {set CP 0110 ; set RES 1110 ; set LFHF 00 }   # 6   14    0
            8   {set CP 0110 ; set RES 1110 ; set LFHF 00 }   # 6   14    0
            9   {set CP 0011 ; set RES 0010 ; set LFHF 00 }   # 3   2     0
            10  {set CP 0110 ; set RES 0001 ; set LFHF 00 }   # 6   1     0
            11  {set CP 0100 ; set RES 1100 ; set LFHF 00 }   # 4   12    0
            12  {set CP 0100 ; set RES 0010 ; set LFHF 00 }   # 4   2     0
            13  {set CP 0110 ; set RES 1010 ; set LFHF 00 }   # 6   10    0
            14  {set CP 0101 ; set RES 1100 ; set LFHF 00 }   # 5   12    0
            15  {set CP 0101 ; set RES 0010 ; set LFHF 00 }   # 5   2     0
            16  {set CP 0110 ; set RES 1100 ; set LFHF 00 }   # 6   12    0
            17  {set CP 1100 ; set RES 1010 ; set LFHF 00 }   # 12  10    0
            18  {set CP 0111 ; set RES 1100 ; set LFHF 00 }   # 7   12    0
            19  {set CP 1101 ; set RES 1010 ; set LFHF 00 }   # 13  10    0
        }
    }

    puts "DADDR_4F: [xapp888_bin2hex "[string index $RES 0]00[string range $RES 1 2]00[string index $RES 3][string index $LFHF 0]00[string index $LFHF 1]0000"]\t-Filter Register 1: M set to $div -"
    puts "DADDR_4E: [xapp888_bin2hex "[string index $CP 0]00[string range $CP 1 2]00[string index $CP 3]00001000"]\t-Filter Register 2: M set to $div -"
    return "4F [xapp888_bin2hex "[string index $RES 0]00[string range $RES 1 2]00[string index $RES 3][string index $LFHF 0]00[string index $LFHF 1]0000"] 4E [xapp888_bin2hex "[string index $CP 0]00[string range $CP 1 2]00[string index $CP 3]00001000"]"
}
#--------------------------------------------------------------------------------------------
#
proc xapp888_locking {div} {
        # LockRefDly_LockFBDly_LockCnt_LockSatHigh_UnlockCnt
        set div [scan $div %d]
        switch -glob -- $div {
            1 {set LockRefDly 00110 ; set LockFBDly 00110 ; set LockCnt 1111101000;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            2 {set LockRefDly 00110 ; set LockFBDly 00110 ; set LockCnt 1111101000;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            3 {set LockRefDly 01000 ; set LockFBDly 01000 ; set LockCnt 1111101000;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            4 {set LockRefDly 01011 ; set LockFBDly 01011 ; set LockCnt 1111101000;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            5 {set LockRefDly 01110 ; set LockFBDly 01110 ; set LockCnt 1111101000;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            6 {set LockRefDly 10001 ; set LockFBDly 10001 ; set LockCnt 1111101000;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            7 {set LockRefDly 10011 ; set LockFBDly 10011 ; set LockCnt 1111101000;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            8 {set LockRefDly 10110 ; set LockFBDly 10110 ; set LockCnt 1111101000;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            9 {set LockRefDly 11001 ; set LockFBDly 11001 ; set LockCnt 1111101000;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            10 {set LockRefDly 11100 ; set LockFBDly 11100 ; set LockCnt 1111101000;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            11 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 1110000100;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            12 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 1100111001;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            13 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 1011101110;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            14 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 1010111100;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            15 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 1010001010;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            16 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 1001110001;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            17 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 1000111111;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            18 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 1000100110;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            19 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 1000001101;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            20 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 0111110100;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            21 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 0111011011;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            22 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 0111000010;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            23 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 0110101001;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            24 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 0110010000;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            25 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 0110010000;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            26 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 0101110111;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            27 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 0101011110;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            28 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 0101011110;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            29 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 0101000101;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            30 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 0101000101;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            31 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 0100101100;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            32 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 0100101100;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            33 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 0100101100;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            34 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 0100010011;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            35 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 0100010011;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            36 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 0100010011;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            37 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 0011111010;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            38 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 0011111010;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            39 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 0011111010;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            40 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 0011111010;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            41 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 0011111010;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            42 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 0011111010;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            43 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 0011111010;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            44 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 0011111010;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            45 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 0011111010;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            46 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 0011111010;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            47 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 0011111010;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            48 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 0011111010;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            49 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 0011111010;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            50 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 0011111010;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            51 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 0011111010;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            52 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 0011111010;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            53 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 0011111010;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            54 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 0011111010;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            55 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 0011111010;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            56 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 0011111010;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            57 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 0011111010;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            58 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 0011111010;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            59 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 0011111010;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            60 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 0011111010;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            61 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 0011111010;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            62 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 0011111010;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            63 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 0011111010;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
            64 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt 0011111010;set LockSatHigh 1111101001 ;set UnlockCnt 0000000001}
         }
#        puts "debug: $LockRefDly\_$LockFBDly\_$LockCnt\_$LockSatHigh\_$UnlockCnt"
        puts "DADDR_18: [xapp888_bin2hex 000000$LockCnt]\t-Lock Register 1: for M set to $div -"
        puts "DADDR_19: [xapp888_bin2hex 0$LockFBDly$UnlockCnt]\t-Lock Register 2: for M set to $div"
        puts "DADDR_1A: [xapp888_bin2hex 0$LockRefDly$LockSatHigh]\t-Lock Register 3: for M set to $div"

        return "18 [xapp888_bin2hex 000000$LockCnt] 19 [xapp888_bin2hex 0$LockFBDly$UnlockCnt] 1A [xapp888_bin2hex 0$LockRefDly$LockSatHigh]"
}
#--------------------------------------------------------------------------------------------
#
proc xapp888_bin2hex {bits} {
    set abits ""
    for {set i 0} {$i <= [expr 15 - [string length $bits]] } {incr i} {
        append abits 0}
    append abits "$bits"
    set binValue [binary format B16 $abits]
    binary scan $binValue H4 hex
    return $hex
    }

proc xapp888_hex2bin {hex} {
    for {set i 0} { $i <= [string length $hex]} { incr i 1} {
        append convert2bin [string map -nocase {
            0 0000 1 0001 2 0010 3 0011 4 0100 5 0101 6 0110 7 0111
            8 1000 9 1001 a 1010 b 1011 c 1100 d 1101 e 1110 f 1111
            } [string index $hex $i ] ]
        }
    return $convert2bin
}
#--------------------------------------------------------------------------------------------
#
proc xapp888_dec2hex {value} {
   # Creates a 16 bit hex number from a signed decimal number
   # Replace all non-decimal characters
   regsub -all {[^0-9\.\-]} $value {} newtemp
   set value [string trim $newtemp]
   if {$value < 65535 && $value >= 0} {
      set tempvalue [format "%#010X" [expr $value]]
      return [string range $tempvalue 6 9]
   } elseif {$value < 0} {
      puts "Unsigned value"
      return "0000"
   } else {
      puts "Violates 16 bit range"
      return "FFFF"
   }
}
#--------------------------------------------------------------------------------------------
#
proc xapp888_drp_settings {m d phase bw } {
    if {$phase < 0} {set phase [expr 360 + $phase]}
    set data_m [xapp888_drp_calc_m $m $phase]
    set data_d [xapp888_drp_calc_d $d]
    set data_cpres [xapp888_cpres $m $bw ]
    set data_locking [xapp888_locking $m]
    return "$data_m $data_d $data_cpres $data_locking"
}
#--------------------------------------------------------------------------------------------
#
proc xapp888_dec2bin {dec bits} {
    return [binary scan [binary format I $dec] B32 var;string range $var end-[expr $bits-1] end]
}
#--------------------------------------------------------------------------------------------
#
proc xapp888_help {} {
    puts "\n\n   -------------------------------------------------------------------------------------\
    \n   NOTES:\n   The following TCL commands are being added to give example calculations\
    \n   for drp programming values for PLLE3 (UltraScale). For other architectures care\
    \n   should be taken due to VCO and programming addresses. This script can be altered\
    \n   to adjust for those differences but exact settings should be reviewed.\
    \n\n   Also please note that this is a subset of the full programming options.\
    \n   Fine phase shifting and dynamic phase shifting is not directly supported by\
    \n   these scripts.\
    \n      xapp888_drp_settings <CLKFBOUT_MULT> <DIVCLK_DIVIDE> <PHASE> <DEFAULT|POSTCRC> \
    \n      REMARK 1: \
    \n          <DEFAULT|POSTCRC>, can be in upper or lower case. \
    \n      REMARK 2: \
    \n          This setting calculates the values for the PLL bandwidth settings. \
    \n          It is ONLY ALLOWED to change this setting from default to postcrc when the \
    \n          PLL is used in conjunction with a SEM-IP core. \
    \n
    \n      xapp888_drp_clkout <DIVIDE>  <Duty Cycle e.g. 0.5> <Phase e.g.11.25> <CLKOUT0 or CLKOUT1> \
    \n      xapp888_help <> \
    \n
    \n\n   For Example:\
    \n\t   xapp888_drp_settings <m> <d> <phase> <default>; \
    \n\t   xapp888_drp_clkout <div> <dc> <phase> clkout0; \
    \n\t   xapp888_drp_clkout <div> <dc> <phase> clkout1;"
    puts "   -------------------------------------------------------------------------------------"
}
#--------------------------------------------------------------------------------------------
#
xapp888_help
#
#--------------------------------------------------------------------------------------------
#
