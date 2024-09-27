`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/21 16:35:48
// Design Name: 
// Module Name: ddc_edid_slave
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


module ddc_edid_slave #(
 p_debug_en = "FALSE"
)(
 input  i_local_clk   
,input  i_rst_n       

,input  i_ir          

,output o_ddc_hpd     
,inout  io_ddc_i2c_sda
,input  i_ddc_i2c_scl 

);




wire [3:0]  w_vid_mode;
reg  [3:0]  r_vid_mode;
reg  [3:0]  r_vid_mode_dly1;
wire [7:0]  w_rom_addr;
wire [7:0]  w_rom_data;
wire [7:0]  w_i2c_slave_rdaddr;
wire [7:0]  w_i2c_slave_rddata;

wire [7:0]  w_i2c_slave_device_addr;
wire        w_i2c_slave_osda;
wire        w_i2c_slave_isda;

reg  [23:0] r_ms_cnt;
reg         r_ddc_hpd;

wire  [4:0] w_state;



assign o_ddc_hpd = r_ddc_hpd;

assign io_ddc_i2c_sda = (w_i2c_slave_osda==1'b0) ? 1'b0 : 1'hz;
assign w_i2c_slave_isda = io_ddc_i2c_sda;

assign w_i2c_slave_device_addr   = {7'h50, 1'b0};

assign w_rom_addr = w_i2c_slave_rdaddr;
assign w_i2c_slave_rddata = w_rom_data;






always @(posedge i_local_clk or negedge i_rst_n) begin
	if(~i_rst_n)
		r_vid_mode <= 0;
	else
		r_vid_mode <= w_vid_mode;
end

always @(posedge i_local_clk or negedge i_rst_n) begin
	if(~i_rst_n)
		r_vid_mode_dly1 <= 0;
	else
		r_vid_mode_dly1 <= r_vid_mode;
end

always @(posedge i_local_clk or negedge i_rst_n) begin
	if(~i_rst_n)
		r_ms_cnt <= 0;
	else if(r_vid_mode != r_vid_mode_dly1)
		r_ms_cnt <= 0;
	else if(&r_ms_cnt)
		r_ms_cnt <= r_ms_cnt;
	else
		r_ms_cnt <= r_ms_cnt+1;
end

always @(posedge i_local_clk or negedge i_rst_n) begin
	if(~i_rst_n)
		r_ddc_hpd <= 0;
	else if(~(&r_ms_cnt))
		r_ddc_hpd <= 0;
	else
		r_ddc_hpd <= 1;
end




ddc_edid_rom u0_ddc_edid_rom(
 .addra ({r_vid_mode,w_rom_addr})
,.clka  (i_local_clk )
,.douta (w_rom_data  )
);

i2c_slave #(
 .p_debug_en(p_debug_en)
) u0_i2c_slave (
 .i_sclk        (i_local_clk             )
,.i_rst_n       (i_rst_n                 )

,.i_device_addr (w_i2c_slave_device_addr )

,.o_wr_de       ()
,.o_wr_addr     ()
,.o_wr_data     ()
,.o_wr_done     ()
,.o_wr_length   ()

,.o_rd_addr     (w_i2c_slave_rdaddr      )
,.i_rd_data     (w_i2c_slave_rddata      )
,.o_rd_de       ()

,.i_scl         (i_ddc_i2c_scl           )
,.i_sda         (w_i2c_slave_isda        )
,.o_sda         (w_i2c_slave_osda        )

,.o_status      (w_state                 )
);


vio_4 u0_vio_4(
 .clk        (i_local_clk )
,.probe_out0 (w_vid_mode  )
);


generate

	if(p_debug_en == "TRUE") begin : ila
		
		ila_128 u_ila_128(
			 .clk    (i_local_clk)
			,.probe0 ({
				 w_i2c_slave_osda
				,w_i2c_slave_isda
				,i_ddc_i2c_scl
				,w_i2c_slave_rddata
				,w_i2c_slave_rdaddr
				,w_i2c_slave_device_addr
				,i_rst_n
				,w_rom_data
				,w_rom_addr
				,r_ddc_hpd
				,r_ms_cnt
				,i_ir
				,w_state
			})
		
		); 

	end
endgenerate



endmodule


