// -----------------------------------------------------------------------------
//   Copyright (c) 2025 by Lattice Semiconductor Corporation
//   ALL RIGHTS RESERVED
//   Subject to Lattice's Software License Agreement
// -----------------------------------------------------------------------------

module hyperram_mc
   #(
     parameter FAMILY            = "LIFCL",
     parameter HYPERRAM_NUM      = 2,
     parameter ONE_RANK_EN       = 1,
     parameter ID_W              = 1,
     parameter INITIAL_LATENCY   = 0,
     parameter DELAY_HALF_CYCLE  = 0,
    //  parameter CACHE_EN          = 1,
    //  parameter CACHE_ADDR_WIDTH  = 10,
    //  parameter CACHE_ADDR_DEPTH  = 1024,
     //Timing related
     parameter SYSBUS_CLOCK_MHZ  = 150,
     parameter TVCS_10US         = 15
    )
   (
     input  wire        clk_i,
     input  wire        hyperbus_clk_i,
    //  input  wire        hyperbus_clk90_i,
     input  wire        hyperbus_clk270_i,
     input  wire        rst_n,       // Reset, active low
     output wire        intr_o,      // Interupt Request, active high

     // hyperbus channels
     output wire [HYPERRAM_NUM-1:0]       hyperbus_clk_o,
     output wire [HYPERRAM_NUM-1:0]       hyperbus_clkn_o,
     output wire [HYPERRAM_NUM-1:0]       hyperbus_csn_o,
     output wire [HYPERRAM_NUM-1:0]       hyperbus_resetn_o,
     inout  wire [HYPERRAM_NUM-1:0]       hyperbus_rwds_io,
     inout  wire [8 * HYPERRAM_NUM - 1:0] hyperbus_dq_io,

     //AXIL for Control
     input  wire        s_axil_awvalid,
     output wire        s_axil_awready,
     input  wire [31:0] s_axil_awaddr,
     input  wire [2:0]  s_axil_awprot,
     input  wire        s_axil_wvalid,
     output wire        s_axil_wready,
     input  wire [31:0] s_axil_wdata,
     input  wire [3:0]  s_axil_wstrb,
     output wire        s_axil_bvalid,
     input  wire        s_axil_bready,
     output wire [1:0]  s_axil_bresp,
     input  wire        s_axil_arvalid,
     output wire        s_axil_arready,
     input  wire [31:0] s_axil_araddr,
     input  wire [2:0]  s_axil_arprot,
     output wire        s_axil_rvalid,
     input  wire        s_axil_rready,
     output wire [31:0] s_axil_rdata,
     output wire [1:0]  s_axil_rresp,

     //axi for data
     input  wire        s_axi_awvalid,
     output wire        s_axi_awready,
     input  wire [ID_W-1:0]       s_axi_awid,
     input  wire [31:0] s_axi_awaddr,
     input  wire [7:0]  s_axi_awlen,
     input  wire [2:0]  s_axi_awsize,
     input  wire [1:0]  s_axi_awburst,
     input  wire [0:0]  s_axi_awlock,
     input  wire [3:0]  s_axi_awcache,
     input  wire [2:0]  s_axi_awprot,
     input  wire [3:0]  s_axi_awqos,
     input  wire        s_axi_wvalid,
     output wire        s_axi_wready,
     input  wire [31:0] s_axi_wdata,
     input  wire [3:0]  s_axi_wstrb,
     input  wire        s_axi_wlast,
     output wire        s_axi_bvalid,
     input  wire        s_axi_bready,
     output wire [ID_W-1:0]       s_axi_bid,
     output wire [1:0]  s_axi_bresp,
     input  wire        s_axi_arvalid,
     output wire        s_axi_arready,
     input  wire [ID_W-1:0]       s_axi_arid,
     input  wire [31:0] s_axi_araddr,
     input  wire [7:0]  s_axi_arlen,
     input  wire [2:0]  s_axi_arsize,
     input  wire [1:0]  s_axi_arburst,
     input  wire [0:0]  s_axi_arlock,
     input  wire [3:0]  s_axi_arcache,
     input  wire [2:0]  s_axi_arprot,
     input  wire [3:0]  s_axi_arqos,
     output wire        s_axi_rvalid,
     input  wire        s_axi_rready,
     output wire [ID_W-1:0]       s_axi_rid,
     output wire [31:0] s_axi_rdata,
     output wire        s_axi_rlast,
     output wire [1:0]  s_axi_rresp,
     input  wire        s_axi_awuser,
     input  wire        s_axi_wuser,
     output wire        s_axi_buser,
     input  wire        s_axi_aruser,
     output wire        s_axi_ruser
);

  wire       csr_wrstoerr;
  wire       csr_wtrserr;
  wire       csr_wdecerr;
  wire       csr_wact;
  wire       csr_rdsstall;
  wire       csr_rrstoerr;
  wire       csr_rtrserr;
  wire       csr_rdecerr;
  wire       csr_rsamperr;
  wire       csr_ract;
  wire [7:0] mbar0_offset;
  wire       mcr0_maxen;
  wire       mcr0_maxlen;
  wire       mcr0_crt;
  wire       mcr0_devtype;
  wire [3:0] mtr_rcshi;
  wire [3:0] mtr_wcshi;
  wire [3:0] mtr_rcss;
  wire [3:0] mtr_wcss;
  wire [3:0] mtr_rcsh;
  wire [3:0] mtr_wcsh;
  wire [3:0] mtr_latency;
  wire [15:0] mtr_ext_tvcs;
  wire [1:0] mtr_ext_tdsv;
  wire [1:0] mtr_ext_tdsz;
  wire [1:0] mtr_ext_toz;
  wire [1:0] mtr_ext_tcsm;
  wire [1:0] mtr_ext_trwr;
  wire [7:0] mbar1_offset;
  wire       mcr1_maxen;
  wire       mcr1_maxlen;
  wire       mcr1_crt;
  wire       mcr1_devtype;
  wire [1:0] ccr_ram_size;
  wire [1:0] ccr_mode;
  wire       ccr_dynamic_latency_en;
  wire [7:0] dpcr_dq_bit_sel;
  wire       dpcr_dir;
  wire       dpcr_loadn;
  wire [1:0] dpcr_coarse;

  defparam axil_regs.C_AXI_ADDR_WIDTH  = 32;
  defparam axil_regs.SYSBUS_CLOCK_MHZ = SYSBUS_CLOCK_MHZ;
  axil_if axil_regs (
     .S_AXI_ACLK            (clk_i                 ),
     .S_AXI_ARESETN         (rst_n                 ),
     .S_AXI_AWVALID         (s_axil_awvalid        ),
     .S_AXI_AWREADY         (s_axil_awready        ),
     .S_AXI_AWADDR          (s_axil_awaddr         ),
     .S_AXI_AWPROT          (s_axil_awprot         ),
     .S_AXI_WVALID          (s_axil_wvalid         ),
     .S_AXI_WREADY          (s_axil_wready         ),
     .S_AXI_WDATA           (s_axil_wdata          ),
     .S_AXI_WSTRB           (s_axil_wstrb          ),
     .S_AXI_BVALID          (s_axil_bvalid         ),
     .S_AXI_BREADY          (s_axil_bready         ),
     .S_AXI_BRESP           (s_axil_bresp          ),
     .S_AXI_ARVALID         (s_axil_arvalid        ),
     .S_AXI_ARREADY         (s_axil_arready        ),
     .S_AXI_ARADDR          (s_axil_araddr         ),
     .S_AXI_ARPROT          (s_axil_arprot         ),
     .S_AXI_RVALID          (s_axil_rvalid         ),
     .S_AXI_RREADY          (s_axil_rready         ),
     .S_AXI_RDATA           (s_axil_rdata          ),
     .S_AXI_RRESP           (s_axil_rresp          ),
     .csr_wrstoerr          (csr_wrstoerr          ),
     .csr_wtrserr           (csr_wtrserr           ),
     .csr_wdecerr           (csr_wdecerr           ),
     .csr_wact              (csr_wact              ),
     .csr_rdsstall          (csr_rdsstall          ),
     .csr_rrstoerr          (csr_rrstoerr          ),
     .csr_rtrserr           (csr_rtrserr           ),
     .csr_rdecerr           (csr_rdecerr           ),
     .csr_rsamperr          (csr_rsamperr          ),
     .csr_ract              (csr_ract              ),
     .mbar0_offset          (mbar0_offset          ),
     .mcr0_maxen            (mcr0_maxen            ),
     .mcr0_maxlen           (mcr0_maxlen           ),
     .mcr0_crt              (mcr0_crt              ),
     .mcr0_devtype          (mcr0_devtype          ),
     .mtr_rcshi             (mtr_rcshi             ),
     .mtr_wcshi             (mtr_wcshi             ),
     .mtr_rcss              (mtr_rcss              ),
     .mtr_wcss              (mtr_wcss              ),
     .mtr_rcsh              (mtr_rcsh              ),
     .mtr_wcsh              (mtr_wcsh              ),
     .mtr_latency           (mtr_latency           ),
     .mtr_ext_tvcs          (mtr_ext_tvcs          ),
     .mtr_ext_tdsv          (mtr_ext_tdsv          ),
     .mtr_ext_tdsz          (mtr_ext_tdsz          ),
     .mtr_ext_toz           (mtr_ext_toz           ),
     .mtr_ext_tcsm          (mtr_ext_tcsm          ),
     .mtr_ext_trwr          (mtr_ext_trwr          ),
     .mbar1_offset          (mbar1_offset          ),
     .mcr1_maxen            (mcr1_maxen            ),
     .mcr1_maxlen           (mcr1_maxlen           ),
     .mcr1_crt              (mcr1_crt              ),
     .mcr1_devtype          (mcr1_devtype          ),
     .ccr_ram_size          (ccr_ram_size          ),
     .ccr_mode              (ccr_mode              ),
     .ccr_dynamic_latency_en(ccr_dynamic_latency_en),
     .dpcr_dq_bit_sel       (dpcr_dq_bit_sel       ),
     .dpcr_dir              (dpcr_dir              ),
     .dpcr_loadn            (dpcr_loadn            ),
     .dpcr_coarse           (dpcr_coarse           )
  );


  wire        axi_cache_rd;
  wire [29:0] axi_cache_raddr;
  wire [31:0] axi_cache_rdata;
  wire        axi_cache_rvalid;

  wire        cache_controller_valid;
  wire        cache_controller_ready;
  wire        cache_controller_wr;
  wire [23:0] cache_controller_addr;
  wire [3:0]  cache_controller_size;
  wire [31:0] cache_controller_wdata;
  wire        cache_controller_wvalid;
  wire [3:0]  cache_controller_wstrb;
  wire [31:0] cache_controller_rdata;
  wire        cache_controller_rvalid;
  wire        core_busy;

  axi2local #(
  .ID_W(ID_W)
  ) axi2local_bridge (
     .clk_i            (clk_i),
     .rst_n_i          (rst_n),
     .core_busy        (core_busy),
     //axi slave interface
     .s_axi_awid    (s_axi_awid    ),
     .s_axi_awaddr  (s_axi_awaddr  ),
     .s_axi_awlen   (s_axi_awlen   ),
     .s_axi_awsize  (s_axi_awsize  ),
     .s_axi_awburst (s_axi_awburst ),
     .s_axi_awlock  (s_axi_awlock  ),
     .s_axi_awcache (s_axi_awcache ),
     .s_axi_awprot  (s_axi_awprot  ),
     .s_axi_awqos   (s_axi_awqos   ),
     .s_axi_awregion(s_axi_awregion),
     .s_axi_awuser  (s_axi_awuser  ),
     .s_axi_awvalid (s_axi_awvalid ),
     .s_axi_awready (s_axi_awready ),
     .s_axi_wdata   (s_axi_wdata   ),
     .s_axi_wstrb   (s_axi_wstrb   ),
     .s_axi_wlast   (s_axi_wlast   ),
     .s_axi_wuser   (s_axi_wuser   ),
     .s_axi_wvalid  (s_axi_wvalid  ),
     .s_axi_wready  (s_axi_wready  ),
     .s_axi_bid     (s_axi_bid     ),
     .s_axi_bresp   (s_axi_bresp   ),
     .s_axi_buser   (s_axi_buser   ),
     .s_axi_bvalid  (s_axi_bvalid  ),
     .s_axi_bready  (s_axi_bready  ),
     .s_axi_arid    (s_axi_arid    ),
     .s_axi_araddr  (s_axi_araddr  ),
     .s_axi_arlen   (s_axi_arlen   ),
     .s_axi_arsize  (s_axi_arsize  ),
     .s_axi_arburst (s_axi_arburst ),
     .s_axi_arlock  (s_axi_arlock  ),
     .s_axi_arcache (s_axi_arcache ),
     .s_axi_arprot  (s_axi_arprot  ),
     .s_axi_arqos   (s_axi_arqos   ),
     .s_axi_arregion(s_axi_arregion),
     .s_axi_aruser  (s_axi_aruser  ),
     .s_axi_arvalid (s_axi_arvalid ),
     .s_axi_arready (s_axi_arready ),
     .s_axi_rid     (s_axi_rid     ),
     .s_axi_rdata   (s_axi_rdata   ),
     .s_axi_rresp   (s_axi_rresp   ),
     .s_axi_rlast   (s_axi_rlast   ),
     .s_axi_ruser   (s_axi_ruser   ),
     .s_axi_rvalid  (s_axi_rvalid  ),
     .s_axi_rready  (s_axi_rready  ),
     //signals <-> controller in hyperbus clock domain
     .local_valid_o    (cache_controller_valid),
     .local_ready_i    (cache_controller_ready),
     .local_wr_o       (cache_controller_wr),
     .local_addr_o     (cache_controller_addr),
     .local_size_o     (cache_controller_size),
     .local_wdata_o    (cache_controller_wdata),
     .local_wvalid_o    (cache_controller_wvalid),
     .local_wstrb_o    (cache_controller_wstrb),
     .local_rdata_i    (cache_controller_rdata),
     .local_rvalid_i   (cache_controller_rvalid)
  );


  wire [HYPERRAM_NUM-1:0]        csn_raw;
  wire [HYPERRAM_NUM-1:0]        reset_raw;
  wire [HYPERRAM_NUM-1:0]        clk_en;
  wire [HYPERRAM_NUM-1:0]        clk_post_en;
  wire [16 * HYPERRAM_NUM - 1:0] dq_rawdata_o;
  wire [16 * HYPERRAM_NUM - 1:0] dq_rawdata_i;
  wire [HYPERRAM_NUM-1:0]        dq_out_en;
  wire [2 * HYPERRAM_NUM - 1:0]  rwds_o;
  wire [2 * HYPERRAM_NUM - 1:0]  rwds_i;
  wire [HYPERRAM_NUM-1:0]        rwds_out_en;

  wire [HYPERRAM_NUM-1:0] delay_adj_en;
  wire [7:0]              dq_in_loadn_i;
  wire [7:0]              dq_in_move_i;
  wire [7:0]              dq_in_direction_i;
  wire [7:0]              dq_in_cflag_o;
  wire [15:0]             dq_in_coarse_dly_i;
  wire                    rwds_in_loadn_i;
  wire                    rwds_in_move_i;
  wire                    rwds_in_direction_i;
  wire                    rwds_in_cflag_o;
  wire [1:0]              rwds_in_coarse_dly_i;

  defparam controller.HYPERRAM_NUM = HYPERRAM_NUM;
  defparam controller.ONE_RANK_EN  = ONE_RANK_EN;
  defparam controller.DELAY_HALF_CYCLE  = DELAY_HALF_CYCLE;
  hyperbus_controller controller(
     .clk_i                 (clk_i                  ),
     .rst_n                 (rst_n                  ),
     .hyperbus_clk_i        (hyperbus_clk_i         ),
     .csr_wrstoerr          (csr_wrstoerr           ),
     .csr_wtrserr           (csr_wtrserr            ),
     .csr_wdecerr           (csr_wdecerr            ),
     .csr_wact              (csr_wact               ),
     .csr_rdsstall          (csr_rdsstall           ),
     .csr_rrstoerr          (csr_rrstoerr           ),
     .csr_rtrserr           (csr_rtrserr            ),
     .csr_rdecerr           (csr_rdecerr            ),
     .csr_rsamperr          (csr_rsamperr           ),
     .csr_ract              (csr_ract               ),
     .mbar0_offset          (mbar0_offset           ),
     .mcr0_maxen            (mcr0_maxen             ),
     .mcr0_maxlen           (mcr0_maxlen            ),
     .mcr0_crt              (mcr0_crt               ),
     .mcr0_devtype          (mcr0_devtype           ),
     .mtr_rcshi             (mtr_rcshi              ),
     .mtr_wcshi             (mtr_wcshi              ),
     .mtr_rcss              (mtr_rcss               ),
     .mtr_wcss              (mtr_wcss               ),
     .mtr_rcsh              (mtr_rcsh               ),
     .mtr_wcsh              (mtr_wcsh               ),
     .mtr_latency           (INITIAL_LATENCY        ),//change to parameter
     .mtr_ext_tvcs          (mtr_ext_tvcs           ),
     .mtr_ext_tdsv          (mtr_ext_tdsv           ),
     .mtr_ext_tdsz          (mtr_ext_tdsz           ),
     .mtr_ext_toz           (mtr_ext_toz            ),
     .mtr_ext_tcsm          (mtr_ext_tcsm           ),
     .mtr_ext_trwr          (mtr_ext_trwr           ),
     .mbar1_offset          (mbar1_offset           ),
     .mcr1_maxen            (mcr1_maxen             ),
     .mcr1_maxlen           (mcr1_maxlen            ),
     .mcr1_crt              (mcr1_crt               ),
     .mcr1_devtype          (mcr1_devtype           ),
     .ccr_ram_size          (ccr_ram_size           ),
     .ccr_mode              (ccr_mode               ),
     .ccr_dynamic_latency_en(ccr_dynamic_latency_en ),
     .dpcr_dq_bit_sel       (dpcr_dq_bit_sel        ),
     .dpcr_dir              (dpcr_dir               ),
     .dpcr_loadn            (dpcr_loadn             ),
     .dpcr_coarse           (dpcr_coarse            ),

     .local_valid           (cache_controller_valid ),
     .local_ready           (cache_controller_ready ),
     .local_wr              (cache_controller_wr    ),
     .local_addr            (cache_controller_addr  ),
     .local_size            (cache_controller_size  ),
     .local_wdata           (cache_controller_wdata ),
     .local_wvalid          (cache_controller_wvalid),
     .local_wstrb           (cache_controller_wstrb ),
     .local_rdata           (cache_controller_rdata ),
     .local_rvalid          (cache_controller_rvalid),
     .core_busy             (core_busy              ),
     .csn_raw               (csn_raw                ),
     .reset_raw             (reset_raw              ),
     .clk_en                (clk_en                 ),
     .clk_post_en           (clk_post_en            ),
     .dq_rawdata_o          (dq_rawdata_o           ),
     .dq_rawdata_i          (dq_rawdata_i           ),
     .dq_out_en             (dq_out_en              ),
     .rwds_o                (rwds_o                 ),
     .rwds_i                (rwds_i                 ),
     .rwds_out_en           (rwds_out_en            ),
     .delay_adj_en          (delay_adj_en           ),
     .dq_in_loadn_o         (dq_in_loadn_i          ),
     .dq_in_move_o          (dq_in_move_i           ),
     .dq_in_direction_o     (dq_in_direction_i      ),
     .dq_in_cflag_i         (dq_in_cflag_o          ),
     .dq_in_coarse_dly_o    (dq_in_coarse_dly_i     ),
     .rwds_in_loadn_o       (rwds_in_loadn_i        ),
     .rwds_in_move_o        (rwds_in_move_i         ),
     .rwds_in_direction_o   (rwds_in_direction_i    ),
     .rwds_in_cflag_i       (rwds_in_cflag_o        ),
     .rwds_in_coarse_dly_o  (rwds_in_coarse_dly_i   )
  );

  generate
    genvar i;
    for (i = 0; i < HYPERRAM_NUM ; i = i + 1) begin: channel
      phy_jedi #(
        .DELAY_HALF_CYCLE(DELAY_HALF_CYCLE)
      )
      phy(
        .rst_i                (~rst_n                  ),
        .clk_i                (hyperbus_clk_i          ),
        // .clk90_i              (hyperbus_clk90_i        ),
        .clk270_i             (hyperbus_clk270_i       ),

        .csn_raw              (csn_raw[i]              ),
        .reset_raw            (reset_raw[i]            ),
        .clk_en               (clk_en[i]               ),
        .clk_post_en          (clk_post_en[i]          ),
        .dq_rawdata_o         (dq_rawdata_o[(16*i)+:16]),
        .dq_rawdata_i         (dq_rawdata_i[(16*i)+:16]),
        .dq_out_en            (dq_out_en[i]            ),
        .rwds_o               (rwds_o[(2*i)+:2]        ),
        .rwds_i               (rwds_i[(2*i)+:2]        ),
        .rwds_out_en          (rwds_out_en[i]          ),

        .delay_adj_en         (delay_adj_en[i]         ),
        .rwds_in_loadn_i      (rwds_in_loadn_i         ),
        .rwds_in_move_i       (rwds_in_move_i          ),
        .rwds_in_direction_i  (rwds_in_direction_i     ),
        .rwds_in_cflag_o      (rwds_in_cflag_o         ),
        .rwds_in_coarse_dly_i (rwds_in_coarse_dly_i    ),
        .dq_in_loadn_i        (dq_in_loadn_i           ),
        .dq_in_move_i         (dq_in_move_i            ),
        .dq_in_direction_i    (dq_in_direction_i       ),
        .dq_in_cflag_o        (dq_in_cflag_o           ),
        .dq_in_coarse_dly_i   (dq_in_coarse_dly_i      ),

        .dq_io                (hyperbus_dq_io[(8*i)+:8]),
        .rwds_io              (hyperbus_rwds_io[i]     ),
        .clk_lvds_o           (hyperbus_clk_o[i]       ),
        .clkn_lvds_o          (hyperbus_clkn_o[i]      ),
        .csn_o                (hyperbus_csn_o[i]       ),
        .reset_o              (hyperbus_resetn_o[i]    )
      );
    end
  endgenerate

endmodule
