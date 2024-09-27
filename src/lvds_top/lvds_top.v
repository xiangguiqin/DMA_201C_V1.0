`timescale 1ns/1ps
module lvds_top #(
 parameter p_debug_en       = "FALSE"
,parameter p_local_clk_freq = 'd74_250_000
) (
 input                      i_rst_n

,input                      i_lvds_clk_p
,input                      i_lvds_clk_n

,input                      i_lvds_vs_p
,input                      i_lvds_vs_n

,input                      i_lvds_hs_p
,input                      i_lvds_hs_n

,input                      i_lvds_de_p
,input                      i_lvds_de_n

,input         [11:0]       i_lvds_data_p
,input         [11:0]       i_lvds_data_n

,output                     o_video_clk
,output                     o_video_vsync
,output                     o_video_hsync
,output                     o_video_de
,output        [23:0]       o_video_data

);


wire [14:0]  w_lvds_p;
wire [14:0]  w_lvds_n;

wire [29:0]  w_data  ;
wire [29:0]  w_pixel_clk  ;

wire [1:0]   w_vs;
wire [1:0]   w_hs;
wire [1:0]   w_de;
wire [23:0]  w_video_data;


assign w_lvds_p = {i_lvds_vs_p,i_lvds_hs_p,i_lvds_de_p,i_lvds_data_p};
assign w_lvds_n = {i_lvds_vs_n,i_lvds_hs_n,i_lvds_de_n,i_lvds_data_n};

//assign o_video_clk    = w_pixel_clk;
assign o_video_vsync  = w_vs[1];
assign o_video_hsync  = w_hs[1];
assign o_video_de     = w_de[1];
assign o_video_data   = w_video_data;

assign w_vs         = w_data[29:28];
assign w_hs         = w_data[27:26];
assign w_de         = w_data[25:24];
assign w_video_data = w_data[23:0];


BUFG BUFG_inst (
 .O(o_video_clk) // 1-bit output: Clock output
,.I(w_pixel_clk)  // 1-bit input: Clock input
);

selectio_wiz_0 u0_selectio_wiz_0(
 .data_in_from_pins_p (w_lvds_p       )
,.data_in_from_pins_n (w_lvds_n       )
,.data_in_to_device   (w_data         )
,.clk_in_p            (i_lvds_clk_p   )
,.clk_in_n            (i_lvds_clk_n   )
,.clk_out             (w_pixel_clk    )
,.io_reset            (~i_rst_n       )
);


wire w_hs_posedge;
wire w_hs_negedge;

wire w_vs_posedge;
wire w_vs_negedge;

wire w_de_posedge;
wire w_de_negedge;

reg [11:0] r_de_cnt;
reg [23:0] r_frame_de_cnt;

assign w_hs_posedge = ~w_hs[1] & w_hs[0];
assign w_hs_negedge = w_hs[0] & ~w_hs[1];

assign w_vs_posedge = ~w_vs[1] & w_vs[0];
assign w_vs_negedge = w_vs[0] & ~w_vs[1];

assign w_de_posedge = ~w_de[1] & w_de[0];
assign w_de_negedge = w_de[0] & ~w_de[1];

always @(posedge w_pixel_clk or negedge i_rst_n) begin
	if(~i_rst_n)
		r_de_cnt <= 0;
	else if(w_hs_posedge || w_vs_posedge)
		r_de_cnt <= 0;
	else if(w_de[0])
		r_de_cnt <= r_de_cnt+1;
	else ;
end

always @(posedge w_pixel_clk or negedge i_rst_n) begin
	if(~i_rst_n)
		r_frame_de_cnt <= 0;
	else if(w_vs_posedge)
		r_frame_de_cnt <= 0;
	else if(w_de[0])
		r_frame_de_cnt <= r_frame_de_cnt+1;
	else ;
end



generate

	if(p_debug_en == "TRUE") begin : ila
		
		ila_128 u_ila_128(
			 .clk    (w_pixel_clk)
			,.probe0 ({
				 w_data
				,w_vs_posedge
				,w_vs_negedge
				,w_hs_posedge
				,w_hs_negedge
				,w_de_posedge
				,w_de_negedge
				,w_vs
				,w_hs
				,w_de
				,w_video_data
				,r_de_cnt
				,r_frame_de_cnt
			})
		
		); 

	end
endgenerate









endmodule


