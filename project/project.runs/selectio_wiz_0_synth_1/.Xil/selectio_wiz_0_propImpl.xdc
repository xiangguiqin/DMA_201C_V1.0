set_property SRC_FILE_INFO {cfile:d:/FPGA_project/Xilinx/DMA_201C_V1.0/project/project.srcs/sources_1/ip/selectio_wiz_0/selectio_wiz_0_ooc.xdc rfile:../../../project.srcs/sources_1/ip/selectio_wiz_0/selectio_wiz_0_ooc.xdc id:1 order:EARLY scoped_inst:inst} [current_design]
current_instance inst
set_property src_info {type:SCOPED_XDC file:1 line:56 export:INPUT save:INPUT read:FILTER_OUT_OF_CONTEXT} [current_design]
set_input_jitter [get_clocks -of_objects [get_ports clk_in_p]] 0.1
