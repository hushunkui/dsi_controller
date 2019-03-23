`ifndef CSI_TX_TOP
`define CSI_TX_TOP

`include "packet_types.vh"

module csi_tx_top #(
    parameter LINE_WIDTH        = 640,
    parameter BITS_PER_PIXEL    = 10,
    parameter IMAGE_HEIGHT      = 480,
    parameter BLANK_HORIZONTAL  = 80,
    parameter BLANK_VERTICAL    = 80,
    parameter [5:0] DATA_TYPE   = `LP_RAW10_CODE

    ) (
    /********* System signals *********/
    input wire                      clk_sys                             ,
    input wire                      rst_sys_n                           ,

    input wire                      clk_phy                             ,
    input wire                      rst_phy_n                           ,

    input wire                      clk_hs_latch                        ,
    input wire                      clk_hs                              ,
    input wire                      clk_hs_clk                          ,

    output  wire                    irq                                 ,

    /********* Avalon-ST input *********/
    input   wire [31:0]             avl_st_in_data                      ,
    input   wire                    avl_st_in_valid                     ,
    input   wire                    avl_st_in_endofpacket               ,
    input   wire                    avl_st_in_startofpacket             ,
    output  wire                    avl_st_in_ready                     ,

    /********* Output interface *********/
    output  wire [3:0]              dphy_data_hs_out_p                  ,
    output  wire [3:0]              dphy_data_hs_out_n                  ,
    output  wire [3:0]              dphy_data_lp_out_p                  ,
    output  wire [3:0]              dphy_data_lp_out_n                  ,

    output  wire                    dphy_clk_hs_out_p                   ,
    output  wire                    dphy_clk_hs_out_n                   ,
    output  wire                    dphy_clk_lp_out_p                   ,
    output  wire                    dphy_clk_lp_out_n                   ,

    `ifdef MODELING
    output  wire                    dphy_clk_hs_out                     ,
    output  wire [3:0]              dphy_data_hs_out                    ,

    `endif

    /********* Avalon-MM iface *********/
    input   wire [4:0]              avl_mm_addr                         ,

    input   wire                    avl_mm_read                         ,
    output  wire [31:0]             avl_mm_readdata                     ,
    output  wire [1:0]              avl_mm_response                     ,

    input   wire                    avl_mm_write                        ,
    input   wire [31:0]             avl_mm_writedata                    ,
    input   wire [3:0]              avl_mm_byteenable                   ,
    output  wire                    avl_mm_waitrequest

);

wire        packet_assembler_enable;
wire        lanes_enable;
wire        clk_out_enable;
wire [2:0]  lanes_number;
wire        packet_assembler_enable_sync;
wire        lanes_enable_sync;
wire        clk_out_enable_sync;
wire [2:0]  lanes_number_sync;
wire        lanes_ready_set_sync;
wire        clk_ready_set_sync;
wire        pix_buffer_underflow_set;
wire        pix_buffer_underflow_set_sync;
wire        lanes_ready_set;
wire        clk_ready_set;

wire [7:0]  tlpx_timeout;
wire [7:0]  hs_prepare_timeout;
wire [7:0]  hs_exit_timeout;
wire [7:0]  hs_go_timeout;
wire [7:0]  hs_trail_timeout;

wire [7:0]  tlpx_timeout_sync;
wire [7:0]  hs_prepare_timeout_sync;
wire [7:0]  hs_exit_timeout_sync;
wire [7:0]  hs_go_timeout_sync;
wire [7:0]  hs_trail_timeout_sync;

csi_tx_regs csi_tx_regs_0(

    /********* Sys iface *********/
    .clk                                (clk_sys                        ),   // Clock
    .rst_n                              (rst_sys_n                      ),   // Asynchronous reset active low

    .irq                                (irq                            ),

    /********* Avalon-MM iface *********/
    .avl_mm_addr                        (avl_mm_addr                    ),

    .avl_mm_read                        (avl_mm_read                    ),
    .avl_mm_readdata                    (avl_mm_readdata                ),
    .avl_mm_response                    (avl_mm_response                ),

    .avl_mm_write                       (avl_mm_write                   ),
    .avl_mm_writedata                   (avl_mm_writedata               ),
    .avl_mm_byteenable                  (avl_mm_byteenable              ),

    .avl_mm_waitrequest                 (avl_mm_waitrequest             ),

    /********* Control signals *********/

    .packet_assembler_enable            (packet_assembler_enable        ),
    .lanes_enable                       (lanes_enable                   ),
    .clk_out_enable                     (clk_out_enable                 ),
    .lanes_number                       (lanes_number                   ),

    .tlpx_timeout                       (tlpx_timeout                   ),
    .hs_prepare_timeout                 (hs_prepare_timeout             ),
    .hs_exit_timeout                    (hs_exit_timeout                ),
    .hs_go_timeout                      (hs_go_timeout                  ),
    .hs_trail_timeout                   (hs_trail_timeout               ),

    .pix_buffer_underflow_set           (pix_buffer_underflow_set_sync  ),
    .lanes_ready_set                    (lanes_ready_set_sync           ),
    .clk_ready_set                      (clk_ready_set_sync             )
);

sync_2ff sync_assembler_enable(
    .clk_out               (clk_phy         ),    // Clock
    .data_in               (packet_assembler_enable),
    .data_out              (packet_assembler_enable_sync)
);

sync_2ff sync_lanes_enable(
    .clk_out               (clk_phy             ),    // Clock
    .data_in               (lanes_enable        ),
    .data_out              (lanes_enable_sync   )
);

sync_2ff sync_clk_enable(
    .clk_out               (clk_phy             ),    // Clock
    .data_in               (clk_out_enable      ),
    .data_out              (clk_out_enable_sync )
);

sync_2ff #(.WIDTH(3)) sync_lanes_number(
    .clk_out               (clk_phy             ),    // Clock
    .data_in               (lanes_number        ),
    .data_out              (lanes_number_sync   )
);

sync_2ff sync_clk_ready(
    .clk_out               (clk_sys             ),    // Clock
    .data_in               (clk_ready_set       ),
    .data_out              (clk_ready_set_sync  )
);

sync_2ff sync_lanes_ready(
    .clk_out               (clk_sys                 ),    // Clock
    .data_in               (lanes_ready_set         ),
    .data_out              (lanes_ready_set_sync    )
);

sync_2ff sync_pix_underflow(
    .clk_out               (clk_sys                         ),    // Clock
    .data_in               (pix_buffer_underflow_set        ),
    .data_out              (pix_buffer_underflow_set_sync   )
);

sync_2ff #(.WIDTH(8)) sync_tlpx_timeout(
    .clk_out               (clk_phy             ),    // Clock
    .data_in               (tlpx_timeout        ),
    .data_out              (tlpx_timeout_sync   )
);

sync_2ff #(.WIDTH(8)) sync_hs_prepare_timeout(
    .clk_out               (clk_phy             ),    // Clock
    .data_in               (hs_prepare_timeout        ),
    .data_out              (hs_prepare_timeout_sync   )
);

sync_2ff #(.WIDTH(8)) sync_hs_exit_timeout(
    .clk_out               (clk_phy             ),    // Clock
    .data_in               (hs_exit_timeout        ),
    .data_out              (hs_exit_timeout_sync   )
);

sync_2ff #(.WIDTH(8)) sync_hs_go_timeout(
    .clk_out               (clk_phy             ),    // Clock
    .data_in               (hs_go_timeout        ),
    .data_out              (hs_go_timeout_sync   )
);

sync_2ff #(.WIDTH(8)) sync_hs_trail_timeout(
    .clk_out               (clk_phy             ),    // Clock
    .data_in               (hs_trail_timeout        ),
    .data_out              (hs_trail_timeout_sync   )
);

wire [31:0]             fifo_data;
wire                    fifo_not_empty;
wire                    fifo_line_ready;
wire                    fifo_read_ack;

csi_tx_pixel_buffer #(
    .NOT_EMPTY_TRESHOLD (LINE_WIDTH*BITS_PER_PIXEL/8),
    .FIFO_DEPTH         (1024)
    ) csi_tx_pixel_buffer_0 (
    /********* System interface *********/
    .clk                        (clk_sys                    ),    // Clock
    .rst_n                      (rst_sys_n                  ),  // Asynchronous reset active low

    .clk_phy                    (clk_phy                    ),
    .rst_phy_n                  (rst_phy_n                  ),

    /********* Avalon-ST Sink *********/
    .avl_st_in_data             (avl_st_in_data             ),
    .avl_st_in_valid            (avl_st_in_valid            ),
    .avl_st_in_endofpacket      (avl_st_in_endofpacket      ),
    .avl_st_in_startofpacket    (avl_st_in_startofpacket    ),
    .avl_st_in_ready            (avl_st_in_ready            ),

    /********* Output interface *********/
    .fifo_data                  (fifo_data                  ),
    .fifo_not_empty             (fifo_not_empty             ),
    .fifo_line_ready            (fifo_line_ready            ),
    .fifo_read_ack              (fifo_read_ack              )
);

wire [31:0]             phy_data;
wire [3:0]              phy_write;
wire [3:0]              phy_full;

csi_tx_packets_assembler #(
    .LINE_WIDTH        (LINE_WIDTH          ),
    .BITS_PER_PIXEL    (BITS_PER_PIXEL      ),
    .IMAGE_HEIGHT      (IMAGE_HEIGHT        ),
    .BLANK_HORIZONTAL  (BLANK_HORIZONTAL    ),
    .BLANK_VERTICAL    (BLANK_VERTICAL      ),
    .DATA_TYPE         (DATA_TYPE           )

    ) csi_tx_packets_assembler_0 (
    /********* System interface *********/
    .clk                        (clk_phy                            ),  // Clock. The same as in PHY
    .rst_n                      (rst_phy_n                          ),  // Asynchronous reset active low

    /********* Input FIFO interface *********/
    .fifo_data                  (fifo_data                          ), // data should be already packed
    .fifo_not_empty             (fifo_not_empty                     ),
    .fifo_line_ready            (fifo_line_ready                    ),
    .fifo_read_ack              (fifo_read_ack                      ),

    /********* PHY interface *********/
    .phy_data                   (phy_data                           ),
    .phy_write                  (phy_write                          ),
    .phy_full                   (phy_full                           ),

    /********* Control signals *********/
    .enable                     (packet_assembler_enable_sync       ),
    .lanes_number               (lanes_number_sync                  ),
    .pix_buffer_underflow_set   (pix_buffer_underflow_set           )
);

wire [31:0]             lanes_fifo_data_0;
wire [35:0]             lanes_fifo_data;
wire [3:0]              lanes_fifo_empty;
wire [3:0]              lanes_fifo_read;

genvar i;

generate
    for (i = 0; i < 4; i = i + 1) begin: lanes_fifo
    altera_generic_fifo #(
        .WIDTH      (8),
        .DEPTH      (32),
        .DC_FIFO    (0),
        .SHOWAHEAD  (1)
        ) fifo_8x32_inst(
        .aclr           (!rst_phy_n                 ),
        .data           (phy_data[i*8+:8]           ),
        .rdclk          (clk_phy                    ),
        .rdreq          (lanes_fifo_read[i]         ),
        .wrreq          (phy_write[i]               ),
        .q              (lanes_fifo_data_0[i*8+:8]  ),
        .empty          (lanes_fifo_empty[i]        ),
        .full           (phy_full[i]                )
    );

    assign lanes_fifo_data[i*9+:9] = {1'b0, lanes_fifo_data_0[i*8+:8]};

    end
endgenerate

wire [3:0]  data_lp_enable;
wire        clk_lp_enable;
wire [31:0] hs_lane_output_bus;
wire [7:0]  clock_hs_output_bus;

wire [3:0]  LP_p_output;
wire [3:0]  LP_n_output;
wire        clock_LP_p_output;
wire        clock_LP_n_output;

dsi_lanes_controller dsi_lanes_controller_0
    (
    /********* Clock signals *********/
    .clk_phy                    (clk_phy                    ), // serial data clock
    .rst_n                      (rst_phy_n                  ),

    /********* lanes controller iface *********/
    .lanes_fifo_data            (lanes_fifo_data            ),
    .lanes_fifo_empty           (lanes_fifo_empty           ),

    .lanes_fifo_read            (lanes_fifo_read            ),

    /********* Misc signals *********/

    .reg_lanes_number           (lanes_number_sync          ),
    .lines_enable               (lanes_enable_sync          ),   // enable output buffers of LP lines
    .clock_enable               (clk_out_enable_sync        ),   // enable clock

    /********* Output signals *********/
    .lines_ready                (lanes_ready_set            ),
    .clock_ready                (clk_ready_set              ),
    .lines_active               (),

    .tlpx_timeout               (tlpx_timeout_sync          ),
    .hs_prepare_timeout         (hs_prepare_timeout_sync    ),
    .hs_exit_timeout            (hs_exit_timeout_sync       ),
    .hs_go_timeout              (hs_go_timeout_sync         ),
    .hs_trail_timeout           (hs_trail_timeout_sync      ),

    /********* Lanes *********/
    .hs_lane_output             (hs_lane_output_bus         ),
    .hs_lane_enable             (),
    .LP_p_output                (LP_p_output                ),
    .LP_n_output                (LP_n_output                ),
    .LP_enable                  (data_lp_enable             ),

    /********* Clock output *********/
    .clock_LP_p_output          (clock_LP_p_output          ),
    .clock_LP_n_output          (clock_LP_n_output          ),
    .clock_LP_enable            (clk_lp_enable              ),
    .clock_hs_output            (clock_hs_output_bus        ),
    .clock_hs_enable            ()

    );

/********* Primitives instanciation *********/

/********* CLK lane *********/
`ifdef MAX_10

wire clk_lvds_out;

lvds_soft lvds_clk(
        .tx_inclock     (clk_hs_clk                     ),   //   tx_inclock.tx_inclock
        .tx_syncclock   (clk_hs_latch                   ), // tx_syncclock.tx_syncclock
        .tx_in          (clock_hs_output_bus            ),        //        tx_in.tx_in
        .tx_out         (clk_lvds_out                   )        //       tx_out.tx_out
    );

`ifdef MIPI_TX_TRI_STATED_HS_OUTPUTS

wire clk_lvds_out_n;
wire clk_lvds_out_p;

gpio gpio_clk(
        .din            (clk_lvds_out       ),       //       din.export
        .pad_out        (clk_lvds_out_p     ),   //   pad_out.export
        .pad_out_b      (clk_lvds_out_n     ), // pad_out_b.export
        .oe             (!clk_lp_enable     )         //        oe.export
    );

assign dphy_clk_hs_out_p = clk_lvds_out_p;
assign dphy_clk_hs_out_n = clk_lvds_out_n;

`else

assign dphy_clk_hs_out_p = clk_lvds_out;
assign dphy_clk_hs_out_n = 1'b0;

`endif

assign dphy_clk_lp_out_p = clk_lp_enable ? clock_LP_p_output : 1'bZ;
assign dphy_clk_lp_out_n = clk_lp_enable ? clock_LP_n_output : 1'bZ;

`ifdef MODELING
    assign dphy_clk_hs_out = clk_lvds_out;
`endif

/********* Data lanes *********/

wire [3:0] data_lvds_out;
wire [3:0] data_lvds_out_n;
wire [3:0] data_lvds_out_p;

generate
    for (i = 0; i < 4; i = i + 1) begin:lanes_lvds

        lvds_soft lvds_data(
                .tx_inclock     (clk_hs                         ),   //   tx_inclock.tx_inclock
                .tx_syncclock   (clk_hs_latch                   ), // tx_syncclock.tx_syncclock
                .tx_in          (hs_lane_output_bus[i*8+:8]     ),        //        tx_in.tx_in
                .tx_out         (data_lvds_out[i]               )        //       tx_out.tx_out
            );
`ifdef MIPI_TX_TRI_STATED_HS_OUTPUTS

        gpio gpio_data(
                .din            (data_lvds_out[i]   ),       //       din.export
                .pad_out        (data_lvds_out_p[i] ),   //   pad_out.export
                .pad_out_b      (data_lvds_out_n[i] ), // pad_out_b.export
                .oe             (!data_lp_enable[i] )         //        oe.export
            );

        assign dphy_data_hs_out_p[i] = data_lvds_out_p[i];
        assign dphy_data_hs_out_n[i] = data_lvds_out_n[i];

`else
        assign dphy_data_hs_out_p[i] = data_lvds_out[i];
        assign dphy_data_hs_out_n[i] = 1'b0;
`endif

        assign dphy_data_lp_out_p[i] = data_lp_enable[i] ? LP_p_output[i] : 1'bZ;
        assign dphy_data_lp_out_n[i] = data_lp_enable[i] ? LP_n_output[i] : 1'bZ;

        `ifdef MODELING
            assign dphy_data_hs_out[i] = data_lvds_out[i];
        `endif

    end
endgenerate

`elsif CYCLONE_10

`endif

endmodule

`endif