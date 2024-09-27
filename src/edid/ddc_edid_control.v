`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/21 14:53:56
// Design Name: 
// Module Name: ddc_edid_control
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ddc_edid_control(
 input  i_local_clk    
,input  i_rst_n        

,input  i_ir           

,output o_ddc1_hpd     
,inout  io_ddc1_i2c_sda
,input  i_ddc1_i2c_scl 
        
,output o_ddc2_hpd     
,inout  io_ddc2_i2c_sda
,input  i_ddc2_i2c_scl 
        
,input  i_ddc3_hpd  
,inout  io_ddc3_i2c_sda
,output o_ddc3_i2c_scl 
   
);


ddc_edid_slave #(
 .p_debug_en("TRUE")
)u0_ddc_edid_slave(
 .i_local_clk    (i_local_clk     )
,.i_rst_n        (i_rst_n         )

,.i_ir           (i_ir            )

,.o_ddc_hpd      (o_ddc1_hpd      )
,.io_ddc_i2c_sda (io_ddc1_i2c_sda )
,.i_ddc_i2c_scl  (i_ddc1_i2c_scl  )
);

ddc_edid_slave #(
 .p_debug_en("FALSE")
)u1_ddc_edid_slave(
 .i_local_clk    (i_local_clk     )
,.i_rst_n        (i_rst_n         )

,.i_ir           (i_ir            )

,.o_ddc_hpd      (o_ddc2_hpd      )
,.io_ddc_i2c_sda (io_ddc2_i2c_sda )
,.i_ddc_i2c_scl  (i_ddc2_i2c_scl  )
);


/* ddc_edid_master u0_ddc_edid_master(
 .i_local_clk    (i_local_clk     )
,.i_rst_n        (i_rst_n         )

,.i_ddc_hpd      (i_ddc3_hpd      )
,.io_ddc_i2c_sda (io_ddc3_i2c_sda )
,.o_ddc_i2c_scl  (o_ddc3_i2c_scl  )
); */



endmodule


