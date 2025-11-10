`ifndef TB_TOP
`define TB_TOP

`timescale 1 ns / 1 ps

`include "lscc_ahblmem_manager.v"
`include "lscc_aximem_manager.v"
`include "lscc_data_checker.v"
`include "lscc_fifo_master.v"

module tb_top();
	
// ----------------------------
// Local Parameter
// ----------------------------
`include "dut_params.v"
localparam CNTR_OVERRIDE  = 0;
localparam TARGET_COUNTER = 50; // cycles

// ----------------------------
// Common Signals
// ----------------------------

reg                   ahbl_hclk_i;
reg                   ahbl_hresetn_i;

// Support for version 2.0.0
wire 				  axi_aclk_i;
wire 				  axi_resetn_i;

assign				  axi_aclk_i   = ahbl_hclk_i;
assign				  axi_resetn_i = ahbl_hresetn_i;

// ----------------------------
// AHB-Lite Subordinate Interface 0
// ----------------------------
wire                  ahbl_s0_hsel_i;
wire                  ahbl_s0_hready_i;
wire [31:0]           ahbl_s0_haddr_i;
wire [2:0]            ahbl_s0_hburst_i;
wire [2:0]            ahbl_s0_hsize_i;
wire                  ahbl_s0_hmastlock_i;
wire [3:0]            ahbl_s0_hprot_i;
wire [1:0]            ahbl_s0_htrans_i;
wire                  ahbl_s0_hwrite_i;
wire [DATA_WIDTH-1:0] ahbl_s0_hwdata_i;

wire                  ahbl_s0_hreadyout_o;
wire                  ahbl_s0_hresp_o;
wire [DATA_WIDTH-1:0] ahbl_s0_hrdata_o;

// ----------------------------
// AHB-Lite Subordinate Interface 1
// ----------------------------
wire                   ahbl_s1_hsel_i;
wire                   ahbl_s1_hready_i;
wire [31:0]            ahbl_s1_haddr_i;
wire [2:0]             ahbl_s1_hburst_i;
wire [2:0]             ahbl_s1_hsize_i;
wire                   ahbl_s1_hmastlock_i;
wire [3:0]             ahbl_s1_hprot_i;
wire [1:0]             ahbl_s1_htrans_i;
wire                   ahbl_s1_hwrite_i;
wire [DATA_WIDTH-1:0]  ahbl_s1_hwdata_i;

wire                   ahbl_s1_hreadyout_o;
wire                   ahbl_s1_hresp_o;
wire [DATA_WIDTH-1:0]  ahbl_s1_hrdata_o;

// ----------------------------
// AXI4 Subordinate Interface 0
// ----------------------------
wire  [ID_WIDTH-1:0]        axi_s0_awid_i;
wire  [31:0]                axi_s0_awaddr_i;
wire  [7:0]                 axi_s0_awlen_i;
wire  [2:0]                 axi_s0_awsize_i;
wire  [1:0]                 axi_s0_awburst_i;
wire                        axi_s0_awlock_i;
wire  [3:0]                 axi_s0_awcache_i;
wire  [3:0]                 axi_s0_awqos_i;
wire  [3:0]                 axi_s0_awregion_i;
wire  [2:0]                 axi_s0_awprot_i;
wire                        axi_s0_awvalid_i;
wire                        axi_s0_awready_o;

wire  [DATA_WIDTH-1:0]      axi_s0_wdata_i;
wire  [DATA_WIDTH/8-1:0]    axi_s0_wstrb_i;
wire                        axi_s0_wlast_i;
wire                        axi_s0_wvalid_i;
wire                        axi_s0_wready_o;

wire [ID_WIDTH-1:0]         axi_s0_bid_o;
wire [1:0]                  axi_s0_bresp_o;
wire                        axi_s0_bvalid_o;
wire                        axi_s0_bready_i;

wire [ID_WIDTH-1:0]         axi_s0_arid_i;
wire [31:0]                 axi_s0_araddr_i;
wire [7:0]                  axi_s0_arlen_i;
wire [2:0]                  axi_s0_arsize_i;
wire [1:0]                  axi_s0_arburst_i;
wire                        axi_s0_arlock_i;
wire [3:0]                  axi_s0_arcache_i;
wire [3:0]                  axi_s0_arqos_i;
wire [3:0]                  axi_s0_arregion_i;
wire [2:0]                  axi_s0_arprot_i;
wire                        axi_s0_arvalid_i;
wire                        axi_s0_arready_o;

wire [ID_WIDTH-1:0]         axi_s0_rid_o;
wire [DATA_WIDTH-1:0]       axi_s0_rdata_o;
wire [1:0]                  axi_s0_rresp_o;
wire                        axi_s0_rlast_o;
wire                        axi_s0_rvalid_o;
wire                        axi_s0_rready_i;

// ----------------------------
// AXI4 Subordinate Interface 1
// ----------------------------
wire  [ID_WIDTH-1:0]        axi_s1_awid_i;
wire  [31:0]                axi_s1_awaddr_i;
wire  [7:0]                 axi_s1_awlen_i;
wire  [2:0]                 axi_s1_awsize_i;
wire  [1:0]                 axi_s1_awburst_i;
wire                        axi_s1_awlock_i;
wire  [3:0]                 axi_s1_awcache_i;
wire  [3:0]                 axi_s1_awqos_i;
wire  [3:0]                 axi_s1_awregion_i;
wire  [2:0]                 axi_s1_awprot_i;
wire                        axi_s1_awvalid_i;
wire                        axi_s1_awready_o;

wire  [DATA_WIDTH-1:0]      axi_s1_wdata_i;
wire  [DATA_WIDTH/8-1:0]    axi_s1_wstrb_i;
wire                        axi_s1_wlast_i;
wire                        axi_s1_wvalid_i;
wire                        axi_s1_wready_o;

wire [ID_WIDTH-1:0]         axi_s1_bid_o;
wire [1:0]                  axi_s1_bresp_o;
wire                        axi_s1_bvalid_o;
wire                        axi_s1_bready_i;

wire [ID_WIDTH-1:0]         axi_s1_arid_i;
wire [31:0]                 axi_s1_araddr_i;
wire [7:0]                  axi_s1_arlen_i;
wire [2:0]                  axi_s1_arsize_i;
wire [1:0]                  axi_s1_arburst_i;
wire                        axi_s1_arlock_i;
wire [3:0]                  axi_s1_arcache_i;
wire [3:0]                  axi_s1_arqos_i;
wire [3:0]                  axi_s1_arregion_i;
wire [2:0]                  axi_s1_arprot_i;
wire                        axi_s1_arvalid_i;
wire                        axi_s1_arready_o;

wire [ID_WIDTH-1:0]         axi_s1_rid_o;
wire [DATA_WIDTH-1:0]       axi_s1_rdata_o;
wire [1:0]                  axi_s1_rresp_o;
wire                        axi_s1_rlast_o;
wire                        axi_s1_rvalid_o;
wire                        axi_s1_rready_i;

// ----------------------------
// FIFO Interface
// ----------------------------
reg                    fifo_clk_i;

wire                   fifo_wr_en_i;
wire [7:0]             fifo_wr_data_i;
wire                   fifo_interface_en_i;
wire                   fifo_address_rst_i;
wire                   fifo_full_o;

// ----------------------------
// Control Signals
// ----------------------------

wire                   ahbl_s0_errgen_o;
wire                   ahbl_s1_errgen_o;
wire [DATA_WIDTH-1:0]  s0_exp_data_o;
wire [DATA_WIDTH-1:0]  s1_exp_data_o;

wire                   axi_s0_errgen_o;
wire                   axi_s0_done;
wire                   axi_s1_errgen_o;
wire                   axi_s1_done;

wire [7:0]             mstr_state_o;
wire                   done_o;

// ----------------------------
// Clock Register
// ----------------------------

reg [31:0] clock_prot_r = {32{1'b0}};

// ----------------------------
// System Counter 
// ----------------------------

wire [31:0] safe_count_o;

// ----------------------------
// Error checker
// ----------------------------
reg s0_data_chk_r = 1'b0;
reg s1_data_chk_r = 1'b0;

// ----------------------------
// DUT instance
// ----------------------------

`include "dut_inst.v"
GSR GSR_INST ( .GSR_N(1'b1), .CLK(1'b0));

// ----------------------------
// Manager Module
// ----------------------------

generate
if (INTERFACE == "AHBL") begin : AHBL_TB
  lscc_ahblmem_manager #(
      .ADDR_DEPTH             (ADDR_DEPTH),
      .DATA_WIDTH             (DATA_WIDTH),
      .MEMORY_TYPE            (MEMORY_TYPE),
      .PORT_COUNT             (PORT_COUNT),
      .ECC_ENABLE             (ECC_ENABLE),
      .REGMODE_S0             (REGMODE_S0),
      .REGMODE_S1             (REGMODE_S1),
      .RESET_MODE_S0          (RESET_MODE_S0),
      .RESET_MODE_S1          (RESET_MODE_S1),
      .BYTE_ENABLE_S0         (BYTE_ENABLE_S0),
      .BYTE_ENABLE_S1         (BYTE_ENABLE_S1),
      .S0_START_ADDR          (S0_START_ADDR),
      .S1_START_ADDR          (S1_START_ADDR),
      .S0_END_ADDR            (S0_END_ADDR),
      .S1_END_ADDR            (S1_END_ADDR),
      .ACCESS_TYPE_S0         (ACCESS_TYPE_S0),
      .ACCESS_TYPE_S1         (ACCESS_TYPE_S1),
      .UNALIGNED_ACCESS_EN_S0 (UNALIGNED_ACCESS_EN_S0),
      .UNALIGNED_ACCESS_EN_S1 (UNALIGNED_ACCESS_EN_S1),
      .SHIFT_DIRECTION_S0     (SHIFT_DIRECTION_S0),
      .SHIFT_DIRECTION_S1     (SHIFT_DIRECTION_S1),
      .INIT_FILE              (INIT_FILE),
      .INIT_FILE_FORMAT       (INIT_FILE_FORMAT),
      .TARGET_COUNTER         (TARGET_COUNTER),
      .CNTR_OVERRIDE          (CNTR_OVERRIDE)
  ) u_mngr0 (
      .ahbl_hclk_i            (ahbl_hclk_i),
      .ahbl_hresetn_i         (ahbl_hresetn_i),
      .fifo_hold_i            (fifo_interface_en_i),
  
  // ----------------------------
  // AHB-Lite Manager Interface 0
  // ----------------------------
      .ahbl_s0_hreadyout_i    (ahbl_s0_hreadyout_o),
      .ahbl_s0_hresp_i        (ahbl_s0_hresp_o),
      .ahbl_s0_hrdata_i       (ahbl_s0_hrdata_o),
  
      .ahbl_s0_hsel_o         (ahbl_s0_hsel_i),
      .ahbl_s0_hready_o       (ahbl_s0_hready_i),
      .ahbl_s0_haddr_o        (ahbl_s0_haddr_i),
      .ahbl_s0_hburst_o       (ahbl_s0_hburst_i),
      .ahbl_s0_hsize_o        (ahbl_s0_hsize_i),
      .ahbl_s0_hmastlock_o    (ahbl_s0_hmastlock_i),
      .ahbl_s0_hprot_o        (ahbl_s0_hprot_i),
      .ahbl_s0_htrans_o       (ahbl_s0_htrans_i),
      .ahbl_s0_hwrite_o       (ahbl_s0_hwrite_i),
      .ahbl_s0_hwdata_o       (ahbl_s0_hwdata_i),
  
  // ----------------------------
  // AHB-Lite Manager Interface 1
  // ----------------------------
      .ahbl_s1_hreadyout_i   (ahbl_s1_hreadyout_o),
      .ahbl_s1_hresp_i       (ahbl_s1_hresp_o),
      .ahbl_s1_hrdata_i      (ahbl_s1_hrdata_o),
  						   
      .ahbl_s1_hsel_o        (ahbl_s1_hsel_i),
      .ahbl_s1_hready_o      (ahbl_s1_hready_i),
      .ahbl_s1_haddr_o       (ahbl_s1_haddr_i),
      .ahbl_s1_hburst_o      (ahbl_s1_hburst_i),
      .ahbl_s1_hsize_o       (ahbl_s1_hsize_i),
      .ahbl_s1_hmastlock_o   (ahbl_s1_hmastlock_i),
      .ahbl_s1_hprot_o       (ahbl_s1_hprot_i),
      .ahbl_s1_htrans_o      (ahbl_s1_htrans_i),
      .ahbl_s1_hwrite_o      (ahbl_s1_hwrite_i),
      .ahbl_s1_hwdata_o      (ahbl_s1_hwdata_i),
  
  // ----------------------------
  // Master State
  // ----------------------------
      .mstr_state_o          (mstr_state_o),
      .done_o                (done_o),
      .safe_count_o          (safe_count_o)
  );
  
  lscc_data_checker # (
      .ADDR_DEPTH             (ADDR_DEPTH),
      .DATA_WIDTH             (DATA_WIDTH),
      .PORT_COUNT             (PORT_COUNT),
      .REGMODE_S0             (REGMODE_S0),
      .REGMODE_S1             (REGMODE_S1),
      .BYTE_ENABLE_S0         (BYTE_ENABLE_S0),
      .BYTE_ENABLE_S1         (BYTE_ENABLE_S1),
      .S0_START_ADDR          (S0_START_ADDR),
      .S1_START_ADDR          (S1_START_ADDR),
      .S0_END_ADDR            (S0_END_ADDR),
      .S1_END_ADDR            (S1_END_ADDR),
      .ACCESS_TYPE_S0         (ACCESS_TYPE_S0),
      .ACCESS_TYPE_S1         (ACCESS_TYPE_S1),
      .UNALIGNED_ACCESS_EN_S0 (UNALIGNED_ACCESS_EN_S0),
      .UNALIGNED_ACCESS_EN_S1 (UNALIGNED_ACCESS_EN_S1),
      .SHIFT_DIRECTION_S0     (SHIFT_DIRECTION_S0),
      .SHIFT_DIRECTION_S1     (SHIFT_DIRECTION_S1),
      .INIT_FILE              (INIT_FILE),
      .INIT_FILE_FORMAT       (INIT_FILE_FORMAT),
      .DATA_STREAMER_EN       (DATA_STREAMER_EN),
      .STREAMER_START_ADDR    (STREAMER_START_ADDR)
  ) data_chk0 (
      .ahbl_hclk_i            (ahbl_hclk_i),
      .ahbl_hresetn_i         (ahbl_hresetn_i),
  				            
      .ahbl_s0_hsel_i         (ahbl_s0_hsel_i),
      .ahbl_s0_hready_i       (ahbl_s0_hready_i),
      .ahbl_s0_haddr_i        (ahbl_s0_haddr_i),
      .ahbl_s0_hburst_i       (ahbl_s0_hburst_i),
      .ahbl_s0_hsize_i        (ahbl_s0_hsize_i),
      .ahbl_s0_hmastlock_i    (ahbl_s0_hmastlock_i),
      .ahbl_s0_hprot_i        (ahbl_s0_hprot_i),
      .ahbl_s0_htrans_i       (ahbl_s0_htrans_i),
      .ahbl_s0_hwrite_i       (ahbl_s0_hwrite_i),
      .ahbl_s0_hwdata_i       (ahbl_s0_hwdata_i),
  
      .ahbl_s0_hrdata_o       (ahbl_s0_hrdata_o),
      .ahbl_s0_hreadyout_o    (ahbl_s0_hreadyout_o),
  
      .ahbl_s1_hsel_i         (ahbl_s1_hsel_i),
      .ahbl_s1_hready_i       (ahbl_s1_hready_i),
      .ahbl_s1_haddr_i        (ahbl_s1_haddr_i),
      .ahbl_s1_hburst_i       (ahbl_s1_hburst_i),
      .ahbl_s1_hsize_i        (ahbl_s1_hsize_i),
      .ahbl_s1_hmastlock_i    (ahbl_s1_hmastlock_i),
      .ahbl_s1_hprot_i        (ahbl_s1_hprot_i),
      .ahbl_s1_htrans_i       (ahbl_s1_htrans_i),
      .ahbl_s1_hwrite_i       (ahbl_s1_hwrite_i),
      .ahbl_s1_hwdata_i       (ahbl_s1_hwdata_i),
  
      .ahbl_s1_hrdata_o       (ahbl_s1_hrdata_o),
      .ahbl_s1_hreadyout_o    (ahbl_s1_hreadyout_o),
  
      .fifo_clk_i             (fifo_clk_i),
      .fifo_wr_en_i           (fifo_wr_en_i),
      .fifo_wr_data_i         (fifo_wr_data_i),
      .fifo_interface_en_i    (fifo_interface_en_i),
      .fifo_address_rst_i     (fifo_address_rst_i),
  							
      .fifo_full_i            (fifo_full_o),
  
      .ahbl_s0_errgen_o       (ahbl_s0_errgen_o),
      .ahbl_s1_errgen_o       (ahbl_s1_errgen_o),
      .s0_exp_data_o          (s0_exp_data_o),
      .s1_exp_data_o          (s1_exp_data_o)
  );
  
  // ----------------------------
  // Error Check
  // ----------------------------
  
  always @ (posedge ahbl_hclk_i) begin
      s0_data_chk_r <= ahbl_s0_errgen_o | s0_data_chk_r;
      s1_data_chk_r <= ahbl_s1_errgen_o | s1_data_chk_r;
  end
  
  if(PORT_COUNT == 2) begin
      always @ (posedge ahbl_hclk_i) begin
          if(ahbl_s0_hresp_o == 1'b1 || ahbl_s1_hresp_o == 1'b1) begin
              if(ahbl_s0_hresp_o == 1'b1) begin
                  $display("-----------------------------------------------------");
                  $display("!!!!!!!!!!! PORT S0 AHBL PROTOCOL FAILED !!!!!!!!!!!!");
                  $display("-----------------------------------------------------");         
              end 
              if(ahbl_s1_hresp_o == 1'b1) begin
                  $display("-----------------------------------------------------");
                  $display("!!!!!!!!!!! PORT S1 AHBL PROTOCOL FAILED !!!!!!!!!!!!");
                  $display("-----------------------------------------------------");        
              end
              $finish;
          end
      end
  end
  else begin
      always @ (posedge ahbl_hclk_i) begin
          if(ahbl_s0_hresp_o == 1'b1) begin
              $display("-----------------------------------------------------");
              $display("!!!!!!!!!!! PORT S0 AHBL PROTOCOL FAILED !!!!!!!!!!!!");
              $display("-----------------------------------------------------");
              $finish;
          end 
      end
  end

always @ (posedge ahbl_hclk_i) begin
    if(done_o == 1'b1) begin
        if(ACCESS_TYPE_S0 == "R/O" || ACCESS_TYPE_S0 == "R/W") begin
            if(s0_data_chk_r == 1'b1) begin
                $display("-----------------------------------------------------");
                $display("!!!!!!!!!!!!! PORT S0 SIMULATION FAILED !!!!!!!!!!!!!");
                $display("-----------------------------------------------------");
            end
            else begin
                $display("-----------------------------------------------------");
                $display("------------- PORT S0 SIMULATION PASSED -------------");
                $display("-----------------------------------------------------");
            end
        end
        if(PORT_COUNT == 2 && (ACCESS_TYPE_S1 == "R/O" || ACCESS_TYPE_S1 == "R/W")) begin 
            if(s1_data_chk_r == 1'b1) begin
                $display("-----------------------------------------------------");
                $display("!!!!!!!!!!!!! PORT S1 SIMULATION FAILED !!!!!!!!!!!!!");
                $display("-----------------------------------------------------");
            end
            else begin
                $display("-----------------------------------------------------");
                $display("------------- PORT S1 SIMULATION PASSED -------------");
                $display("-----------------------------------------------------");
            end
        end
        $finish;
    end
    else begin
        if(ACCESS_TYPE_S0 == "R/O" || ACCESS_TYPE_S0 == "R/W") begin
            if(ahbl_s0_errgen_o == 1'b1) begin
                $display("ERROR on port S0 after %h cycles, during %h state at %i", clock_prot_r, mstr_state_o,$time);
            end
        end

        if(PORT_COUNT == 2 && (ACCESS_TYPE_S1 == "R/O" || ACCESS_TYPE_S1 == "R/W")) begin 
            if(ahbl_s1_errgen_o == 1'b1) begin
                $display("ERROR on port S1 after %h cycles, during %h state at %i", clock_prot_r, mstr_state_o,$time);
            end
        end
    end
end

end
else begin : AXI4_TB// (INTERFACE == "AXI4")

  lscc_aximem_manager # (
    .DATA_WIDTH             (DATA_WIDTH),
    .ADDR_DEPTH             (ADDR_DEPTH),
    .ID_WIDTH               (ID_WIDTH),
    .INIT_FILE              (INIT_FILE),
    .INIT_FILE_FORMAT       (INIT_FILE_FORMAT),
    .TARGET_COUNTER         (TARGET_COUNTER)
  ) u_mngr0 (
    .axi_aclk_i             (axi_aclk_i),
    .axi_resetn_i           (axi_resetn_i),

    .axi_m0_awid_o          (axi_s0_awid_i),
    .axi_m0_awaddr_o        (axi_s0_awaddr_i),
    .axi_m0_awlen_o         (axi_s0_awlen_i),
    .axi_m0_awsize_o        (axi_s0_awsize_i),
    .axi_m0_awburst_o       (axi_s0_awburst_i),
    .axi_m0_awvalid_o       (axi_s0_awvalid_i),
    .axi_m0_awready_i       (axi_s0_awready_o),

    .axi_m0_wdata_o         (axi_s0_wdata_i),
    .axi_m0_wstrb_o         (axi_s0_wstrb_i),
    .axi_m0_wlast_o         (axi_s0_wlast_i),
    .axi_m0_wvalid_o        (axi_s0_wvalid_i),
    .axi_m0_wready_i        (axi_s0_wready_o),

    .axi_m0_bid_i           (axi_s0_bid_o),
    .axi_m0_bresp_i         (axi_s0_bresp_o),
    .axi_m0_bvalid_i        (axi_s0_bvalid_o),
    .axi_m0_bready_o        (axi_s0_bready_i),

    .axi_m0_arid_o          (axi_s0_arid_i),
    .axi_m0_araddr_o        (axi_s0_araddr_i),
    .axi_m0_arlen_o         (axi_s0_arlen_i),
    .axi_m0_arsize_o        (axi_s0_arsize_i),
    .axi_m0_arburst_o       (axi_s0_arburst_i),
    .axi_m0_arvalid_o       (axi_s0_arvalid_i),
    .axi_m0_arready_i       (axi_s0_arready_o),

    .axi_m0_rid_i           (axi_s0_rid_o),
    .axi_m0_rdata_i         (axi_s0_rdata_o),
    .axi_m0_rresp_i         (axi_s0_rresp_o),
    .axi_m0_rlast_i         (axi_s0_rlast_o),
    .axi_m0_rvalid_i        (axi_s0_rvalid_o),
    .axi_m0_rready_o        (axi_s0_rready_i),

    .axi_m0_data_chk        (axi_s0_errgen_o),
    .done_o                 (axi_s0_done),
    .safe_count_o           (safe_count_o)
  );

  if (PORT_COUNT == 2) begin
    lscc_aximem_manager # (
      .DATA_WIDTH             (DATA_WIDTH),
      .ADDR_DEPTH             (ADDR_DEPTH),
      .ID_WIDTH               (ID_WIDTH),
      .TARGET_COUNTER         (TARGET_COUNTER)
    ) u_mngr1 (
      .axi_aclk_i             (axi_aclk_i),
      .axi_resetn_i           (axi_resetn_i),
    
      .axi_m0_awid_o          (axi_s1_awid_i),
      .axi_m0_awaddr_o        (axi_s1_awaddr_i),
      .axi_m0_awlen_o         (axi_s1_awlen_i),
      .axi_m0_awsize_o        (axi_s1_awsize_i),
      .axi_m0_awburst_o       (axi_s1_awburst_i),
      .axi_m0_awvalid_o       (axi_s1_awvalid_i),
      .axi_m0_awready_i       (axi_s1_awready_o),
    
      .axi_m0_wdata_o         (axi_s1_wdata_i),
      .axi_m0_wstrb_o         (axi_s1_wstrb_i),
      .axi_m0_wlast_o         (axi_s1_wlast_i),
      .axi_m0_wvalid_o        (axi_s1_wvalid_i),
      .axi_m0_wready_i        (axi_s1_wready_o),
    
      .axi_m0_bid_i           (axi_s1_bid_o),
      .axi_m0_bresp_i         (axi_s1_bresp_o),
      .axi_m0_bvalid_i        (axi_s1_bvalid_o),
      .axi_m0_bready_o        (axi_s1_bready_i),
    
      .axi_m0_arid_o          (axi_s1_arid_i),
      .axi_m0_araddr_o        (axi_s1_araddr_i),
      .axi_m0_arlen_o         (axi_s1_arlen_i),
      .axi_m0_arsize_o        (axi_s1_arsize_i),
      .axi_m0_arburst_o       (axi_s1_arburst_i),
      .axi_m0_arvalid_o       (axi_s1_arvalid_i),
      .axi_m0_arready_i       (axi_s1_arready_o),
    
      .axi_m0_rid_i           (axi_s1_rid_o),
      .axi_m0_rdata_i         (axi_s1_rdata_o),
      .axi_m0_rresp_i         (axi_s1_rresp_o),
      .axi_m0_rlast_i         (axi_s1_rlast_o),
      .axi_m0_rvalid_i        (axi_s1_rvalid_o),
      .axi_m0_rready_o        (axi_s1_rready_i),
    
      .axi_m0_data_chk        (axi_s1_errgen_o),
      .done_o                 (axi_s1_done),
      .safe_count_o           (safe_count_o)
    );
  end

  // ----------------------------
  // Error Check
  // ----------------------------
  
  always @ (posedge axi_aclk_i) begin
      s0_data_chk_r <= axi_s0_errgen_o | s0_data_chk_r;
      s1_data_chk_r <= axi_s1_errgen_o | s1_data_chk_r;
  end

  if (PORT_COUNT == 1) begin
    always @ (posedge axi_aclk_i) begin
      if(axi_s0_done == 1'b1) begin
        if(s0_data_chk_r == 1'b1) begin
            $display("-----------------------------------------------------");
            $display("!!!!!!!!!!!!! PORT S0 SIMULATION FAILED !!!!!!!!!!!!!");
            $display("-----------------------------------------------------");
        end
        else begin
            $display("-----------------------------------------------------");
            $display("------------- PORT S0 SIMULATION PASSED -------------");
            $display("-----------------------------------------------------");
        end
        $finish;
      end
    end
  end
  else begin //  (PORT_COUNT == 2) 
    always @ (posedge axi_aclk_i) begin
      if(axi_s0_done && axi_s1_done) begin
        if (~s0_data_chk_r && ~s1_data_chk_r) begin
            $display("-----------------------------------------------------");
            $display("------------- PORT S0 SIMULATION PASSED -------------");
            $display("-----------------------------------------------------");
            $display("-----------------------------------------------------");
            $display("------------- PORT S1 SIMULATION PASSED -------------");
            $display("-----------------------------------------------------");
        end
        else begin
            if (s0_data_chk_r == 1'b1) begin
              $display("-----------------------------------------------------");
              $display("!!!!!!!!!!!!! PORT S0 SIMULATION FAILED !!!!!!!!!!!!!");
              $display("-----------------------------------------------------");
            end
            else begin
              $display("-----------------------------------------------------");
              $display("------------- PORT S0 SIMULATION PASSED -------------");
              $display("-----------------------------------------------------");
            end
            if (s1_data_chk_r == 1'b1) begin
              $display("-----------------------------------------------------");
              $display("!!!!!!!!!!!!! PORT S1 SIMULATION FAILED !!!!!!!!!!!!!");
              $display("-----------------------------------------------------");
            end
            else begin
              $display("-----------------------------------------------------");
              $display("------------- PORT S1 SIMULATION PASSED -------------");
              $display("-----------------------------------------------------");
            end
        end
        $finish;
      end
    end
  end

end
endgenerate

lscc_fifo_master # (
    .FIFO_EN (DATA_STREAMER_EN)
) fifo_master (
    .clk_i               (fifo_clk_i),
    .rstn_i              (ahbl_hresetn_i),

    .fifo_wr_en_o        (fifo_wr_en_i),
    .fifo_wr_data_o      (fifo_wr_data_i),
    .fifo_interface_en_o (fifo_interface_en_i), 
    .fifo_address_rst_o  (fifo_address_rst_i),

    .fifo_full_o         (fifo_full_o)
);

// ----------------------------
// Reset and Clock generation
// ----------------------------
initial begin
    ahbl_hclk_i = 1'b0;
    forever #10 ahbl_hclk_i = ~ahbl_hclk_i;
end

initial begin
    ahbl_hresetn_i = 1'b0;
    #20;
    @(posedge ahbl_hclk_i);
    ahbl_hresetn_i = 1'b1;
end

if(STREAMER_CLK_BYPASS) begin
    always @ (*) begin
        fifo_clk_i = ahbl_hclk_i;
    end
end
else begin
    initial begin
        fifo_clk_i = 1'b0;
        #5;
        forever #15 fifo_clk_i = ~fifo_clk_i;
    end
end

// ----------------------------
// Simulation runaway protection
// ----------------------------
generate
  if (INTERFACE == "AHBL") begin
    always @ (posedge ahbl_hclk_i) begin
        if(ahbl_hresetn_i == 1'b1) begin
            if(clock_prot_r < safe_count_o) begin
                clock_prot_r <= clock_prot_r + 1'b1;
            end
            else begin
                $finish;
            end
        end
    end
  end
  else begin // AXI
    always @ (posedge axi_aclk_i) begin
        if(axi_resetn_i == 1'b1) begin
            if(clock_prot_r < safe_count_o) begin
                clock_prot_r <= clock_prot_r + 1'b1;
            end
            else begin
                $finish;
            end
        end
    end
  end
endgenerate

endmodule
`endif
