#
puts "-----------------------------------------------------------------------------------"
puts " Before anything else, check the lockation of the  glbl.v  file in                 "
puts " the Vivado installaton used to run this simulation.                               "
puts " When Vivado is installed on a Windows computer it can be something                "
puts " like: C:\\CaeTools\\Xilinx\\2019_1\\Vivado\\2019.1\\data\\verilog\\src            "
puts "                                                                                   "
puts " Open, edit, modify and save the  .\/SimScripts\/MmcmPll_FuncSim.do file.          "
puts " Check below line and make it match the lockation of the glbl.v file of the system "
puts " used to run simulations of this design                                            "
puts " vlog -work work {C:\\CaeTools\\Xilinx\\2019_1\\Vivado\\2019.1\\data\\verilog\\src\\glbl.v} "
puts "                                                                                   "
puts " When this is done, enter \[x\] -- Without \[\] of course --                       "
puts "-----------------------------------------------------------------------------------"

while {[gets stdin] != "x"} {
	after 100
}

puts "-----------------------------------------------------------------------------------"
puts "Please enter the type of FPGA that needs to be simulated.            "
puts " 7-Series = 7Srs, Ultracsale = Ultrscl and Ultrascale+ = UltrsclPls. "
puts "-----------------------------------------------------------------------------------"
puts ""
#
puts -nonewline "What FPGA to simulate? (7Srs, Ultrscl or UltrsclPls): "
flush stdout
set C_UseFpga [gets stdin]
#
puts -nonewline "simulate MMCM or PLL? (MMCM, PLL): "
flush stdout
set C_MmcmPll [gets stdin]
#
if {[string equal $C_UseFpga 7Srs]} {
    if {[string equal $C_MmcmPll MMCM]} {
        set C_ClockGen MMCME2_DRP
        set C_Symbol mmcme2
    } elseif {[string equal $C_MmcmPll PLL]} {
        set C_ClockGen PLLE2_DRP
        set C_Symbol plle2
    } else {
        puts "----------------------"
        puts "Wrong entry $C_MmcmPll"
        puts "----------------------"
        return
    }
} elseif {[string equal $C_UseFpga Ultrscl]} {
    if {[string equal $C_MmcmPll MMCM]} {
        set C_ClockGen MMCME3_DRP
        set C_Symbol mmcme3
    } elseif {[string equal $C_MmcmPll PLL]} {
        set C_ClockGen PLLE3_DRP
        set C_Symbol plle3
    } else {
      puts "----------------------"
      puts "Wrong entry $C_MmcmPll"
      puts "----------------------"
      return
    }
} elseif {[string equal $C_UseFpga UltrsclPls]} {
    if {[string equal $C_MmcmPll MMCM]} {
        set C_ClockGen MMCME4_DRP
        set C_Symbol mmcme4
    } elseif {[string equal $C_MmcmPll PLL]} {
        set C_ClockGen PLLE4_DRP
        set C_Symbol plle4
    } else {
      puts "----------------------"
      puts "Wrong entry $C_MmcmPll"
      puts "----------------------"
      return
    }
} else {
    puts "----------------------"
    puts "Wrong entry $C_UseFpga"
    puts "----------------------"
    return
}
do MmcmPll_FuncSim.do $C_ClockGen $C_Symbol
