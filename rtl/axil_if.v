// -----------------------------------------------------------------------------
//   Copyright (c) 2025 by Lattice Semiconductor Corporation
//   ALL RIGHTS RESERVED
//   Subject to Lattice's Software License Agreement
// -----------------------------------------------------------------------------

// =============================================================================
// FILE DETAILS
// Project : <Hyperram>
// File : axil_if.v
// Title :
// Dependencies : 1.
//              : 2.
// Description :
// =============================================================================
// REVISION HISTORY
// Version : 1.0
// Author(s) : Yibin
// Mod. Date : 09/17/2022
// Changes Made : Initial version of RTL
// -----------------------------------------------------------------------------
// Version : 1.1
// Author(s) :
// Mod. Date :
// Changes Made :
// =============================================================================
module axil_if #(
    parameter C_AXI_ADDR_WIDTH     = 32,
    parameter C_AXI_DATA_WIDTH     = 32,
    parameter [0:0] OPT_LOWPOWER   = 0,
    parameter SYSBUS_CLOCK_MHZ     = 150,
    parameter TVCS_10US            = 15
  ) (
      input  wire                          S_AXI_ACLK,
      input  wire                          S_AXI_ARESETN,
            //
      input  wire                          S_AXI_AWVALID,
      output wire                          S_AXI_AWREADY,
      input  wire [C_AXI_ADDR_WIDTH-1:0]   S_AXI_AWADDR,
      input  wire [2:0]                    S_AXI_AWPROT,
            //
      input  wire                          S_AXI_WVALID,
      output wire                          S_AXI_WREADY,
      input  wire [C_AXI_DATA_WIDTH-1:0]   S_AXI_WDATA,
      input  wire [C_AXI_DATA_WIDTH/8-1:0] S_AXI_WSTRB,
            //
      output wire                          S_AXI_BVALID,
      input  wire                          S_AXI_BREADY,
      output wire [1:0]                    S_AXI_BRESP,
            //
      input  wire                          S_AXI_ARVALID,
      output wire                          S_AXI_ARREADY,
      input  wire [C_AXI_ADDR_WIDTH-1:0]   S_AXI_ARADDR,
      input  wire [2:0]                    S_AXI_ARPROT,
            //
      output wire                          S_AXI_RVALID,
      input  wire                          S_AXI_RREADY,
      output wire [C_AXI_DATA_WIDTH-1:0]   S_AXI_RDATA,
      output wire [1:0]                    S_AXI_RRESP,

      //design inputs
      input  wire        csr_wrstoerr,        // CSR[26] RSTO Error in Write Transaction
      input  wire        csr_wtrserr,         // CSR[25] Transaction Error (AXI protocol) in Write Transaction
      input  wire        csr_wdecerr,         // CSR[24] Transaction Error (access address) in Write Transaction
      input  wire        csr_wact,            // CSR[16] Write Transaction Active
      input  wire        csr_rdsstall,        // CSR[11] RDS Stall Error in Read Transaction
      input  wire        csr_rrstoerr,        // CSR[10] RSTO Error in Read Transaction
      input  wire        csr_rtrserr,         // CSR[9] Transaction Error (AXI protocol) in Read Transaction
      input  wire        csr_rdecerr,         // CSR[8] Transaction Error (access address) in Read Transaction
      input  wire        csr_rsamperr,        // CSR[7] Transaction Error (RWDS sampling) in Read Transaction
      input  wire        csr_ract,            // CSR[0] Read Transaction Active
      //For CS0
      output wire [7:0]  mbar0_offset,  //MBAR0[31:24] Offset address to differentiate CS0 and CS1
      output wire        mcr0_maxen,    //MCR0[31]    Maximum Length Enable
      output wire        mcr0_maxlen,   //MCR0[26:18] Maximum Length
      input  wire        mcr0_crt,      //MCR0[5] Memory/Register space, equal to CA [46] bit in command/address cycle
      output wire        mcr0_devtype,  //MCR0[4] device type

      //For CS1
      output wire [7:0]  mbar1_offset,  //MBAR1[31:24] Offset address to differentiate CS0 and CS1
      output wire        mcr1_maxen,    //MCR1[31]    Maximum Length Enable
      output wire        mcr1_maxlen,   //MCR1[26:18] Maximum Length
      input  wire        mcr1_crt,      //MCR1[5] Memory/Register space, equal to CA [46] bit in command/address cycle
      output wire        mcr1_devtype,  //MCR1[4] device type

      //shared timing parameters
      output wire [3:0]  mtr_rcshi,    //MTR[31:28] Read Chip Select High Between Operations
      output wire [3:0]  mtr_wcshi,    //MTR[27:24] Read Chip Select High Between Operations
      output wire [3:0]  mtr_rcss,     //MTR[23:20] Read Chip Select Setup to next CK Rising Edge
      output wire [3:0]  mtr_wcss,     //MTR[19:16] Write Chip Select Setup to next CK Rising Edge
      output wire [3:0]  mtr_rcsh,     //MTR[15:12] Read Chip Select Setup to next CK Falling Edge
      output wire [3:0]  mtr_wcsh,     //MTR[11:8] Write Chip Select Setup to next CK Falling Edge
      output wire [3:0]  mtr_latency,  //MTR[3:0] Latency Cycle for HyperRAM
      output wire [15:0] mtr_ext_tvcs, //mtr_ext[31:16] power up initialization
      output wire [1:0]  mtr_ext_tdsv, //mtr_ext[29:28] Data Strobe Valid
      output wire [1:0]  mtr_ext_tdsz, //mtr_ext[27:26] Chip Select Inactive to RWDS HI-Z
      output wire [1:0]  mtr_ext_toz,  //mtr_ext[25:24] Chip Select Inactive to DQ HI-Z
      output wire [1:0]  mtr_ext_tcsm, //mtr_ext[23:22] HyperRAM Chip Select Maximum LOW Time
      output wire [1:0]  mtr_ext_trwr, //mtr_ext[21:20] HyperRAM Read-Write Recovery Time

      output wire [1:0]  ccr_ram_size,           //CCR[31:30] hyperram size
      output wire [1:0]  ccr_mode,               //CCR[29:28] mode
      output wire        ccr_dynamic_latency_en, //CCR[27] dynamic latency enable

      output wire [7:0]  dpcr_dq_bit_sel,        //DPCR[31:24] enable the corresponding data bit for data path delay adjustment
      output wire        dpcr_dir,               //DPCR[23] direcion
      output wire        dpcr_loadn,             //DPCR[22] load
      output wire [1:0]  dpcr_coarse             //DPCR[21:20] coarse delay control
);

      ////////////////////////////////////////////////////////////////////////
      //
      // Register/wire signal declarations
      // {{{
      ////////////////////////////////////////////////////////////////////////
      //
      localparam ADDRLSB = $clog2(C_AXI_DATA_WIDTH)-3;

      wire i_reset = !S_AXI_ARESETN;

      wire                                axil_write_ready;
      wire [C_AXI_ADDR_WIDTH-ADDRLSB-1:0] awskd_addr;
      //
      wire [C_AXI_DATA_WIDTH-1:0]         wskd_data;
      wire [C_AXI_DATA_WIDTH/8-1:0]       wskd_strb;
      reg                                 axil_bvalid;
      //
      wire                                axil_read_ready;
      wire [C_AXI_ADDR_WIDTH-ADDRLSB-1:0] arskd_addr;
      reg  [C_AXI_DATA_WIDTH-1:0]         axil_read_data;
      reg                                 axil_read_valid;

      //user registers
      `define CSR_OFFSET     4'b0000
      `define MBAR0_OFFSET   4'b0001
      `define MBAR1_OFFSET   4'b0010
      `define MCR0_OFFSET    4'b0011
      `define MCR1_OFFSET    4'b0100
      `define MTR_OFFSET     4'b0101
      `define MTR_EXT_OFFSET 4'b0110
      `define CCR_OFFSET     4'b0111
      `define DPCR_OFFSET    4'b1000
      wire [31:0] csr;      //0x00 CSR     - Controller Status Register
      reg [31:0]  mbar0;    //0x04 MBAR0   - CS0 Memory Base Address Register
      reg [31:0]  mbar1;    //0x08 MBAR1   - CS1 Memory Base Address Register
      reg [31:0]  mcr0;     //0x0C MCR0    - CS0 Memory Configuration Register
      reg [31:0]  mcr1;     //0x10 MCR1    - CS1 Memory Configuration Register
      reg [31:0]  mtr;      //0x14 MTR     - Memory Timing
      reg [31:0]  mtr_ext;  //0x18 MTR_EXD - Memory Timing Extend
      reg [31:0]  ccr;      //0x1C CCR     - Controller Configuration Register
      reg [31:0]  dpcr;     //0x20 DPCR    - Data Path Calibration Register

      wire [31:0] wskd_csr;
      wire [31:0] wskd_mbar0;
      wire [31:0] wskd_mbar1;
      wire [31:0] wskd_mcr0;
      wire [31:0] wskd_mcr1;
      wire [31:0] wskd_mtr;
      wire [31:0] wskd_mtr_ext;
      wire [31:0] wskd_ccr;
      wire [31:0] wskd_dpcr;
      ////////////////////////////////////////////////////////////////////////
      //
      // AXI-lite signaling
      //
      ////////////////////////////////////////////////////////////////////////
      // Write signaling
      reg axil_awready;
      initial axil_awready = 1'b0;

      always @(posedge S_AXI_ACLK)
        if (!S_AXI_ARESETN)
          axil_awready <= 1'b0;
        else
          axil_awready <= !axil_awready
                            && (S_AXI_AWVALID && S_AXI_WVALID)
                            && (!S_AXI_BVALID || S_AXI_BREADY);

      assign S_AXI_AWREADY = axil_awready;
      assign S_AXI_WREADY  = axil_awready;

      assign awskd_addr = S_AXI_AWADDR[C_AXI_ADDR_WIDTH-1:ADDRLSB];
      assign wskd_data  = S_AXI_WDATA;
      assign wskd_strb  = S_AXI_WSTRB;

      assign axil_write_ready = axil_awready;


      initial axil_bvalid = 0;

      always @(posedge S_AXI_ACLK)
        if (i_reset)
          axil_bvalid <= 0;
        else if (axil_write_ready)
          axil_bvalid <= 1;
        else if (S_AXI_BREADY)
          axil_bvalid <= 0;

      assign S_AXI_BVALID = axil_bvalid;
      assign S_AXI_BRESP = 2'b00;

      // Read signaling
      reg axil_arready;
      always @(*)
        axil_arready = !S_AXI_RVALID;

      assign arskd_addr = S_AXI_ARADDR[C_AXI_ADDR_WIDTH-1:ADDRLSB];
      assign S_AXI_ARREADY = axil_arready;
      assign axil_read_ready = (S_AXI_ARVALID && S_AXI_ARREADY);

      initial axil_read_valid = 1'b0;
      always @(posedge S_AXI_ACLK)
        if (i_reset)
          axil_read_valid <= 1'b0;
        else if (axil_read_ready)
          axil_read_valid <= 1'b1;
        else if (S_AXI_RREADY)
          axil_read_valid <= 1'b0;

      assign S_AXI_RVALID = axil_read_valid;
      assign S_AXI_RDATA  = axil_read_data;
      assign S_AXI_RRESP  = 2'b00;

      ////////////////////////////////////////////////////////////////////////
      //
      // Timing Data
      //
      ////////////////////////////////////////////////////////////////////////
      localparam  real    SYSBUS_CLOCK_PERIOD_NS = 1000.0 / SYSBUS_CLOCK_MHZ;
      //power-up reset time
      localparam  integer MEM_TVCS = SYSBUS_CLOCK_MHZ * TVCS_10US * 10;

      ////////////////////////////////////////////////////////////////////////
      //
      // AXI-lite register logic
      //
      ////////////////////////////////////////////////////////////////////////
      // apply_wstrb(old_data, new_data, write_strobes)

      assign wskd_mbar0    = apply_wstrb(mbar0,    wskd_data, wskd_strb);
      assign wskd_mbar1    = apply_wstrb(mbar1,    wskd_data, wskd_strb);
      assign wskd_mcr0     = apply_wstrb(mcr0,     wskd_data, wskd_strb);
      assign wskd_mcr1     = apply_wstrb(mcr1,     wskd_data, wskd_strb);
      assign wskd_mtr      = apply_wstrb(mtr,      wskd_data, wskd_strb);
      assign wskd_mtr_ext  = apply_wstrb(mtr_ext,  wskd_data, wskd_strb);
      assign wskd_ccr      = apply_wstrb(ccr,      wskd_data, wskd_strb);
      assign wskd_dpcr     = apply_wstrb(dpcr,     wskd_data, wskd_strb);

      always @(posedge S_AXI_ACLK)
        if (i_reset) begin
            mbar0   <= 0;
            mbar1   <= 0;
            mcr0    <= 0;
            mcr1    <= 0;
            mtr     <= 0;
            `ifdef RTL_SIM
              mtr_ext[31:16] <= 16'h00A0; //'d160
            `else
              mtr_ext[31:16] <= MEM_TVCS;
            `endif
            mtr_ext[15:0] <= 0;
            ccr     <= 0;
            dpcr    <= 0;
        end else if (axil_write_ready) begin
            case(awskd_addr[3:0])
              `MBAR0_OFFSET   : mbar0    <= wskd_mbar0;
              `MBAR1_OFFSET   : mbar1    <= wskd_mbar1;
              `MCR0_OFFSET    : mcr0     <= {wskd_mcr0[31:6], mcr0_crt, wskd_mcr0[4:0]};
              `MCR1_OFFSET    : mcr1     <= {wskd_mcr1[31:6], mcr1_crt, wskd_mcr1[4:0]};
              `MTR_OFFSET     : mtr      <= wskd_mtr;
              `MTR_EXT_OFFSET : mtr_ext  <= wskd_mtr_ext;
              `CCR_OFFSET     : ccr      <= wskd_ccr;
              `DPCR_OFFSET    : dpcr     <= wskd_dpcr;
            endcase
        end
       else begin
            mcr0[5] <= mcr0_crt;
            mcr1[5] <= mcr1_crt;
       end

      always @(posedge S_AXI_ACLK)
        if (OPT_LOWPOWER && !S_AXI_ARESETN)
          axil_read_data <= 0;
        else if (!S_AXI_RVALID || S_AXI_RREADY) begin
          case(arskd_addr[3:0])
            `CSR_OFFSET     : axil_read_data <= csr;
            `MBAR0_OFFSET   : axil_read_data <= {mbar0[31:24], 24'b0};
            `MBAR1_OFFSET   : axil_read_data <= {mbar1[31:24], 24'b0};
            `MCR0_OFFSET    : axil_read_data <= {mcr0[31], 4'b0, mcr0[26:18], 12'b0, mcr0[5], mcr0[4], 4'b0};
            `MCR1_OFFSET    : axil_read_data <= {mcr1[31], 4'b0, mcr1[26:18], 12'b0, mcr1[5], mcr1[4], 4'b0};
            `MTR_OFFSET     : axil_read_data <= {mtr[31:28], mtr[27:24], mtr[23:20], mtr[19:16], mtr[15:12], mtr[11:8], 4'b0, mtr[3:0]};
            `MTR_EXT_OFFSET : axil_read_data <= {mtr_ext[31:16], mtr_ext[29:28], mtr_ext[27:26], mtr_ext[25:24], mtr_ext[23:22], mtr_ext[21:20], 20'b0};
            `CCR_OFFSET     : axil_read_data <= {ccr[31:30], ccr[29:28],ccr[27], 27'b0};
            `DPCR_OFFSET    : axil_read_data <= {dpcr[31:24], dpcr[23], dpcr[22], dpcr[21:20], 20'b0};
          endcase
          if (OPT_LOWPOWER && !axil_read_ready)
            axil_read_data <= 0;
        end

      function [C_AXI_DATA_WIDTH-1:0] apply_wstrb;
        input [C_AXI_DATA_WIDTH-1:0]   prior_data;
        input [C_AXI_DATA_WIDTH-1:0]   new_data;
        input [C_AXI_DATA_WIDTH/8-1:0] wstrb;

        integer k;
        for(k=0; k<C_AXI_DATA_WIDTH/8; k=k+1)
          begin
            apply_wstrb[k*8 +: 8]
              = wstrb[k] ? new_data[k*8 +: 8] : prior_data[k*8 +: 8];
          end
      endfunction

      assign csr[31:27]    = 5'b0;
      assign csr[26]       = csr_wrstoerr;
      assign csr[25]       = csr_wtrserr;
      assign csr[24]       = csr_wdecerr;
      assign csr[16]       = csr_wact;
      assign csr[11]       = csr_rdsstall;
      assign csr[10]       = csr_rrstoerr;
      assign csr[9]        = csr_rtrserr;
      assign csr[8]        = csr_rdecerr;
      assign csr[7]        = csr_rsamperr;
      assign csr[0]        = csr_ract;

      assign mbar0_offset  = mbar0[31:24];
      assign mcr0_maxen    = mcr0[31]    ;
      assign mcr0_maxlen   = mcr0[26:18] ;
      assign mcr0_devtype  = mcr0[4]     ;
      assign mbar1_offset  = mbar1[31:24];
      assign mcr1_maxen    = mcr1[31]    ;
      assign mcr1_maxlen   = mcr1[26:18] ;
      assign mcr1_devtype  = mcr1[4]     ;

      assign mtr_rcshi    = mtr[31:28] ;
      assign mtr_wcshi    = mtr[27:24] ;
      assign mtr_rcss     = mtr[23:20] ;
      assign mtr_wcss     = mtr[19:16] ;
      assign mtr_rcsh     = mtr[15:12] ;
      assign mtr_wcsh     = mtr[11:8]  ;
      assign mtr_latency  = mtr[3:0]   ;
      assign mtr_ext_tvcs = mtr_ext[31:16];
      assign mtr_ext_tdsv = mtr_ext[15:14];
      assign mtr_ext_tdsz = mtr_ext[13:12];
      assign mtr_ext_toz  = mtr_ext[11:10];
      assign mtr_ext_tcsm = mtr_ext[9:8];
      assign mtr_ext_trwr = mtr_ext[7:6];

      assign ccr_ram_size           = ccr[31:30];
      assign ccr_mode               = ccr[29:28];
      assign ccr_dynamic_latency_en = ccr[27]   ;

      assign dpcr_dq_bit_sel        = dpcr[31:24];
      assign dpcr_dir               = dpcr[23];
      assign dpcr_loadn             = dpcr[22];
      assign dpcr_coarse            = dpcr[21:20];

endmodule