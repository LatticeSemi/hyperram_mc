// -----------------------------------------------------------------------------
//   Copyright (c) 2025 by Lattice Semiconductor Corporation
//   ALL RIGHTS RESERVED
//   Subject to Lattice's Software License Agreement
// -----------------------------------------------------------------------------
//
// =============================================================================
//                         FILE DETAILS
// Project               :
// File                  :axi2local.v
// Title                 :
// Dependencies          :
// Description           :
// =============================================================================
//                        REVISION HISTORY
// Version               : 1.0.0.
// Author(s)             : pliu
// Mod. Date             : 10/24/2022
// Changes Made          : Initial release.
// =============================================================================


//==========================================================================
// Module : axi2local
//==========================================================================
module axi2local #(
  parameter ID_W              = 1
  )
  ( //--begin_ports--
    //----------------------------
    // Global Signals (Clock and Reset)
    //----------------------------
    input                         clk_i,               // apb clock
    input                         rst_n_i,             // active low reset

    //----------------------------
    // AXI Interface
    //----------------------------
    input   wire [ID_W-1:0]       s_axi_awid,
    input   wire [31:0] s_axi_awaddr,
    input   wire [7:0]  s_axi_awlen,
    input   wire [2:0]  s_axi_awsize,
    input   wire [1:0]  s_axi_awburst,
    input   wire        s_axi_awlock,
    input   wire [3:0]  s_axi_awcache,
    input   wire [2:0]  s_axi_awprot,
    input   wire [3:0]  s_axi_awqos,
    input   wire [3:0]  s_axi_awregion,
    input   wire        s_axi_awuser,
    input   wire        s_axi_awvalid,
    output  wire        s_axi_awready,
    input   wire [31:0] s_axi_wdata,
    input   wire [3:0]  s_axi_wstrb,
    input   wire        s_axi_wlast,
    input   wire        s_axi_wuser,
    input   wire        s_axi_wvalid,
    output  wire        s_axi_wready,
    output  wire [ID_W-1:0]       s_axi_bid,
    output  wire [1:0]  s_axi_bresp,
    output  wire        s_axi_buser,
    output  wire        s_axi_bvalid,
    input   wire        s_axi_bready,
    input   wire [ID_W-1:0]       s_axi_arid,
    input   wire [31:0] s_axi_araddr,
    input   wire [7:0]  s_axi_arlen,
    input   wire [2:0]  s_axi_arsize,
    input   wire [1:0]  s_axi_arburst,
    input   wire        s_axi_arlock,
    input   wire [3:0]  s_axi_arcache,
    input   wire [2:0]  s_axi_arprot,
    input   wire [3:0]  s_axi_arqos,
    input   wire [3:0]  s_axi_arregion,
    input   wire        s_axi_aruser,
    input   wire        s_axi_arvalid,
    output  wire        s_axi_arready,
    output  wire [ID_W-1:0]       s_axi_rid,
    output  wire [31:0] s_axi_rdata,
    output  wire [1:0]  s_axi_rresp,
    output  wire        s_axi_rlast,
    output  wire        s_axi_ruser,
    output  wire        s_axi_rvalid,
    input   wire        s_axi_rready,

    input  wire        core_busy,
    //signals <-> controller in hyperbus clock domain
    output wire        local_valid_o,
    input  wire        local_ready_i,
    output wire        local_wr_o,
    output wire [23:0]  local_addr_o,
    output wire [3:0]   local_size_o, // 2 ^ size bytes
    output wire [31:0] local_wdata_o,
    output wire        local_wvalid_o,
    output wire [3:0]  local_wstrb_o,
    input  wire [31:0] local_rdata_i,
    input  wire        local_rvalid_i

  ); //--end_ports--

  //--------------------------------------------------------------------------
  //--- Registers ---
  //--------------------------------------------------------------------------
  reg       bvalid_r;
  reg [7:0] rd_length;
  reg [23:0] addr_r;
  reg       wr_r;
  reg [3:0] size_r;
  reg       ready_r;
  reg       ready_rr;

function [31:0] clog2;
  input [31:0] value;
  reg   [31:0] num;
  begin
    num = value - 1;
    for (clog2=0; num>0; clog2=clog2+1) num = num>>1;
  end
endfunction


  always @(posedge clk_i or negedge rst_n_i)
  begin
    if (~rst_n_i)
    begin
      ready_r <= 0;
    end
    else
    begin
      ready_r <= local_ready_i;
    end
  end

  always @(posedge clk_i or negedge rst_n_i)
  begin
    if (~rst_n_i)
    begin
      ready_rr <= 0;
    end
    else
    begin
      ready_rr <= ready_r;
    end
  end

  always @(posedge clk_i or negedge rst_n_i)
  begin
    if (~rst_n_i)
    begin
      wr_r <= 0;
    end
    else if(s_axi_awvalid)
    begin
      wr_r <= 1;
    end
    else if (core_busy)
    begin
      wr_r <= 0;
    end
  end

  always @(posedge clk_i or negedge rst_n_i)
  begin
    if (~rst_n_i)
    begin
      addr_r <= 24'h0;
    end
    else if(s_axi_awvalid)
    begin
      addr_r <= s_axi_awaddr[25:2];
    end
    else if (s_axi_arvalid)
    begin
      addr_r <= s_axi_araddr[25:2];
    end
  end

  always @(posedge clk_i or negedge rst_n_i)
  begin
    if (~rst_n_i)
    begin
      size_r <= 4'h0;
    end
    else if(s_axi_awvalid)
    begin
      size_r <= clog2(s_axi_awlen + 1);//size_r <= $clog2(s_axi_awlen + 1);
    end
    else if (s_axi_arvalid)
    begin
      size_r <= clog2(s_axi_arlen + 1);//size_r <= $clog2(s_axi_arlen + 1);
    end
  end

  always @(posedge clk_i or negedge rst_n_i)
  begin
    if (~rst_n_i)
    begin
      bvalid_r <= 0;
    end
    else if(s_axi_wvalid && s_axi_wready && s_axi_wlast)
    begin
      bvalid_r <= 1;
    end
    else if(bvalid_r && s_axi_bready)
    begin
      bvalid_r <= 0;
    end
  end
  //rd_length
  always @(posedge clk_i or negedge rst_n_i)
    if (~rst_n_i)
    begin
      rd_length <= 8'hff;
    end
    else if (s_axi_arvalid)
    begin
      rd_length <= s_axi_arlen;
    end
    else if (s_axi_rvalid && s_axi_rready)
    begin
      rd_length <= rd_length - 1'b1;
    end


  assign s_axi_awready = ~core_busy;

  assign s_axi_wready = ready_rr;

  assign s_axi_bid = s_axi_awid;
  assign s_axi_bresp = 2'b0;
  assign s_axi_buser = 1'b0;
  assign s_axi_bvalid = bvalid_r;

  assign s_axi_arready = ~core_busy;

  assign s_axi_rid = s_axi_arid;
  assign s_axi_rdata = local_rdata_i;
  assign s_axi_rresp = 2'b0;
  assign s_axi_rlast = (rd_length == 8'h0);
  assign s_axi_ruser = 1'b0;
  assign s_axi_rvalid = local_rvalid_i;

  assign local_valid_o = (s_axi_awvalid & s_axi_awready) || (s_axi_arvalid & s_axi_arready);
  assign local_wr_o = wr_r;
  assign local_addr_o = addr_r;
  assign local_size_o = size_r;
  assign local_wdata_o = s_axi_wdata;
  assign local_wvalid_o = s_axi_wvalid & s_axi_wready;
  assign local_wstrb_o = (~s_axi_wstrb);
  // assign local_wstrb_o = (s_axi_wvalid & s_axi_wready) ? (~s_axi_wstrb) : 4'b1111;
endmodule //--lscc_apb2lmmi--
