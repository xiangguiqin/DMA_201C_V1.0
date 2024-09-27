module frmbuf_top #(
 parameter p_debug_en = 0
)(
 input                i_rst_n
,input                i_ddr3_clk

,input                i_system_init
,output    [ 26:0]    o_app_addr
,output    [  2:0]    o_app_cmd
,output               o_app_en
,input                i_app_rdy

,output    [255:0]    o_app_wdf_data
,output               o_app_wdf_wren
,input                i_app_wdf_rdy
,output               o_app_wdf_end

,input     [255:0]    i_app_rd_data
,input                i_app_rd_data_valid
,input                i_app_rd_data_end

,input                i_src_valid
,input                i_src0_clk
,input                i_src0_vsyn
,input                i_src0_de
,input     [23:0]     i_src0_data

,input                i_src1_clk
,input                i_src1_valid
,input                i_src1_vsyn
,input                i_src1_de
,input     [23:0]     i_src1_data

,input                i_dst0_clk
,input                i_dst0_vsyn
,input                i_dst0_rd
,output               o_dst0_de
,output    [23:0]     o_dst0_data

,input                i_dst1_clk
,input                i_dst1_vsyn
,input                i_dst1_rd
,output               o_dst1_de
,output    [23:0]     o_dst1_data
);

 wire                   w_wrfifo_rst
;wire                   w_wrfifo_almost_empty
;wire                   w_wrfifo_rd_en
;wire    [255:0]        w_wrfifo_data
;                       
 wire                   w_rdfifo_rst
;wire                   w_rdfifo_almost_full
;wire                   w_rdfifo_wr_en
;                       
 wire    [1:0]          w_arb_req
;wire    [1:0]          w_arb_response
;wire    [1:0]          w_arb_bust_end
;wire    [27*2-1:0]     w_arb_req_addr
;wire    [1:0]          w_arb_cmd_valid
;wire    [2*3-1:0]      w_arb_rdwr_cmd
;wire                   w_arb_wr_en
;wire    [255:0]        w_arb_wr_data
;
 wire                   w_wr_en
;wire                   w_wr_request
;wire                   w_wr_arb_response
;wire                   w_wr_cmd_valid
;wire    [2:0]          w_wr_cmd
;wire    [26:0]         w_wr_addr
;wire                   w_wr_bust_end
;wire    [26:0]         w_wr_addr_inital
;wire                   w_wrfifo_rd
;wire                   w_wr_busy
;
 wire                   w_rd_request
;wire                   w_rd_arb_response
;wire                   w_rd_cmd_valid
;wire    [2:0]          w_rd_cmd
;wire    [26:0]         w_rd_addr
;wire                   w_rd_bust_end
;wire                   w_rd_valid
;wire    [26:0]         w_rd_addr_inital
;wire                   w_rd_busy
;

 wire     [2:0]         w_arb_cs
;wire     [2:0]         w_arb_ns
;wire     [2:0]         w_wr_cs
;wire     [2:0]         w_wr_ns
;wire     [2:0]         w_rd_cs
;wire     [2:0]         w_rd_ns
;

 assign  w_arb_req         = {w_rd_request,w_wr_request}
;assign  w_arb_bust_end    = {w_rd_bust_end,w_wr_bust_end}
;assign  w_arb_req_addr    = {w_rd_addr,w_wr_addr}
;assign  w_arb_cmd_valid   = {w_rd_cmd_valid,w_wr_cmd_valid}
;assign  w_arb_rdwr_cmd    = {w_rd_cmd,w_wr_cmd}
;assign  w_arb_wr_en       = {w_wr_en}
;assign  w_arb_wr_data     = {w_wrfifo_data}
;
 assign  w_wr_arb_response = w_arb_response[0]
;assign  w_rd_arb_response = w_arb_response[1]
;
 assign  w_wrfifo_rd_en    = w_wrfifo_rd
;assign  w_rdfifo_wr_en    = i_app_rd_data_valid
;
 assign  o_app_wdf_end     = o_app_wdf_wren
;

frmbuf_fifo u_frmbuf_fifo (
 .i_rst_n               (i_rst_n               )
,.i_ddr3_clk            (i_ddr3_clk            )

,.i_src_clk             (i_src0_clk            )
,.i_src_vsyn            (i_src0_vsyn           )
,.i_src_de              (i_src0_de             )
,.i_src_data            (i_src0_data           )

,.i_wrfifo_rst		    (w_wrfifo_rst          )
,.o_wrfifo_almost_empty (w_wrfifo_almost_empty )
,.i_wrfifo_rd_en        (w_wrfifo_rd_en        )
,.o_wrfifo_data         (w_wrfifo_data         )

,.i_rdfifo_wr_en        (w_rdfifo_wr_en        )
,.i_rdfifo_data         (i_app_rd_data         )
,.i_rdfifo_rst          (w_rdfifo_rst          )
,.o_rdfifo_almost_full  (w_rdfifo_almost_full  )

,.i_dst_clk             (i_dst0_clk            )
,.i_dst_vsyn            (i_dst0_vsyn           )
,.i_rdfifo_rd_en        (i_dst0_rd             )
,.o_dst_de              (o_dst0_de             )
,.o_rdfifo_data         (o_dst0_data           )
);

frmbuf_arb u_frmbuf_arb (
 .i_rst_n       (i_rst_n         )
,.i_ddr3_clk    (i_ddr3_clk      )
,.i_system_init (i_system_init   )
,.i_request     (w_arb_req       )
,.o_response    (w_arb_response  )
,.i_bust_end    (w_arb_bust_end  )
,.i_req_addr    (w_arb_req_addr  )
,.i_cmd_valid   (w_arb_cmd_valid )
,.i_rdwr_cmd    (w_arb_rdwr_cmd  )
,.i_wr_en       (w_arb_wr_en     )
,.i_wr_data     (w_arb_wr_data   )
//,.o_wrfifo_rd   (w_wrfifo_rd     )

,.o_app_en      (o_app_en        )
,.o_app_cmd     (o_app_cmd       )
,.o_app_addr    (o_app_addr      )
,.o_app_wdf_data(o_app_wdf_data  )
,.o_app_wdf_wren(o_app_wdf_wren  )

,.o_cs          (w_arb_cs        )
,.o_ns          (w_arb_ns        )
);

frmbuf_wr u0_frmbuf_wr (
 .i_rst_n            (i_rst_n              )
,.i_ddr3_clk         (i_ddr3_clk           )
,.i_system_init      (i_system_init        )
,.i_src_vsyn         (i_src0_vsyn          )
,.i_fifo_almost_empty(w_wrfifo_almost_empty)
,.o_fifo_rst         (w_wrfifo_rst         )

,.o_request          (w_wr_request         )
,.i_response         (w_wr_arb_response    )
,.o_app_en           (w_wr_cmd_valid       )
,.o_app_cmd          (w_wr_cmd             )
,.o_addr             (w_wr_addr            )
,.o_bust_end         (w_wr_bust_end        )

,.i_app_rdy          (i_app_rdy            )
,.i_app_wdf_rdy      (i_app_wdf_rdy        )
,.o_app_wdf_wren     (w_wr_en              )
,.i_addr_inital      (w_wr_addr_inital     )
,.o_fifo_rd          (w_wrfifo_rd          )
,.o_wr_busy          (w_wr_busy            )

,.i_wrfifo_data      (w_wrfifo_data        )
,.o_cs               (w_wr_cs              )
,.o_ns               (w_wr_ns              )
);

frmbuf_rd u0_frmbuf_rd (
 .i_rst_n             (i_rst_n               )
,.i_ddr3_clk          (i_ddr3_clk            )
,.i_system_init       (i_system_init         )
,.i_dst_vsync         (i_dst0_vsyn           )
,.i_fifo_almost_full  (w_rdfifo_almost_full  )
,.o_fifo_rst          (w_rdfifo_rst          )
,.o_request           (w_rd_request          )
,.i_response          (w_rd_arb_response     )
,.i_app_rdy           (i_app_rdy             )	
,.o_app_en            (w_rd_cmd_valid        )
,.o_app_cmd           (w_rd_cmd              )
,.o_addr              (w_rd_addr             )		
,.o_bust_end          (w_rd_bust_end         )	
,.i_app_rd_data_valid (i_app_rd_data_valid   )
,.i_addr_inital       (w_rd_addr_inital      )
,.o_rd_busy           (w_rd_busy             )

,.i_app_rd_data       (i_app_rd_data         )
,.o_cs                (w_rd_cs               )
,.o_ns                (w_rd_ns               )
);

frmbuf_addr_control u_frmbuf_addr_control(
 .i_rst_n          (i_rst_n          )
,.i_ddr3_clk       (i_ddr3_clk       )
,.i_src_valid      (i_src_valid      )
,.i_src_vsyn       (i_src0_vsyn      )
,.i_dst_vsyn       (i_dst0_vsyn      )
,.o_wr_addr_inital (w_wr_addr_inital )
,.o_rd_addr_inital (w_rd_addr_inital )
);


/* generate
	if(p_debug_en) begin

		ila_0 uwr_ila_0(
		 .clk    (i_ddr3_clk)
		,.probe0 ({
				 i_app_rdy
				,o_app_en
				,i_app_wdf_rdy
				,o_app_wdf_wren
				,w_wr_en
				,r_src_vsyn_pos
				,w_arb_bust_end
				,w_arb_req
				,w_arb_response
				,w_arb_cmd_valid
				,w_wrfifo_almost_empty
				,i_app_rd_data_valid
				,i_app_rd_data_end
				,w_rdfifo_almost_full
				,i_system_init
				,w_wr_busy
				,w_rd_busy
				,w_arb_req_addr
				,o_app_addr
				
				,w_arb_cs
				,w_arb_ns
				,w_wr_cs
				,w_wr_ns
				,w_rd_cs
				,w_rd_ns
			})//512
		);
	end
endgenerate */


endmodule 
