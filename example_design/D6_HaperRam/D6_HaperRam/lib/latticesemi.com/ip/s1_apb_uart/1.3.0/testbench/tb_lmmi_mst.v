// =============================================================================
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
// -----------------------------------------------------------------------------
// Copyright (c) 2019 by Lattice Semiconductor Corporation
// ALL RIGHTS RESERVED
// --------------------------------------------------------------------
//
// Permission:
//
// Lattice SG Pte. Ltd. grants permission to use this code
// pursuant to the terms of the Lattice Reference Design License Agreement.
//
//
// Disclaimer:
//
// This VHDL or Verilog source code is intended as a design reference
// which illustrates how these types of functions can be implemented.
// It is the user's responsibility to verify their design for
// consistency and functionality through the use of formal
// verification methods. Lattice provides no warranty
// regarding the use or functionality of this code.
//
// -----------------------------------------------------------------------------
//
//                     Lattice SG Pte. Ltd.
//                     101 Thomson Road, United Square #07-02
//                     Singapore 307591
//
//
//                     TEL: 1-800-Lattice (USA and Canada)
//                     +65-6631-2000 (Singapore)
//                     +1-503-268-8001 (other locations)
//
//                     web: http://www.latticesemi.com/
//                     email: techsupport@latticesemi.com
//
// -----------------------------------------------------------------------------
//
// =============================================================================
// FILE DETAILS
// Project : <UART>
// File : tb_lmmi_mst.v
// Title :
// Dependencies : 1.
//              : 2.
// Description :
// =============================================================================
// REVISION HISTORY
// Version : 1.0
// Author(s) : TP
// Mod. Date : 06/28/2019
// Changes Made : Initial version of RTL
// -----------------------------------------------------------------------------
// Version : 1.0
// Author(s) :
// Mod. Date :
// Changes Made :
// =============================================================================
//--------------------------------------------------------------------------------------------------

`ifndef TB_LMMI_MST
`define TB_LMMI_MST
`timescale 1ns/100ps
//==========================================================================
// Module : tb_lmmi_mst
//==========================================================================
module tb_lmmi_mst

#( //--begin_param--
//----------------------------
// Parameters
//----------------------------
parameter                AWIDTH        = 16,
parameter                DWIDTH        = 32,
parameter                MODEL_NAME    = "LMMI_MST",
parameter integer        TIMEOUT_VALUE = 512
) //--end_param--

( //--begin_ports--
//----------------------------
// Inputs
//----------------------------
input                    lmmi_clk,
input                    lmmi_resetn,

input       [DWIDTH-1:0] lmmi_rdata,
input                    lmmi_rdata_valid,
input                    lmmi_ready,

//----------------------------
// Outputs
//----------------------------
output reg  [AWIDTH-1:0] lmmi_offset,
output reg               lmmi_request,
output reg  [DWIDTH-1:0] lmmi_wdata,
output reg               lmmi_wr_rdn

); //--end_ports--

//--------------------------------------------------------------------------
//--- Registers ---
//--------------------------------------------------------------------------
reg [8*15:1]      model_name;
//reg  [AWIDTH-1:0] addr;
//reg  [DWIDTH-1:0] data;
//reg  [DWIDTH-1:0] rddata;

reg    [31:0] timeout_cntr;

initial begin
  lmmi_offset  = {AWIDTH{1'b0}};
  lmmi_request = 1'b0;
  lmmi_wdata   = {DWIDTH{1'b0}};
  lmmi_wr_rdn  = 1'b0;
  model_name   = MODEL_NAME;
end

task m_write
(
  input  [AWIDTH-1:0] addr,
  input  [DWIDTH-1:0] data
);
  begin
    $display("[%010t] [%0s]: LMMI Write Access.. Addr=%0h, WriteData=%0h",$time, model_name, addr,data);
    lmmi_request <= 1'b1;
    lmmi_wr_rdn  <= 1'b1;
    lmmi_wdata   <= data;
    lmmi_offset  <= addr;

    if (lmmi_resetn)
      @(posedge lmmi_clk);
    while(~(lmmi_ready | ~lmmi_resetn)) begin // exits on ready and reset
      @(posedge lmmi_clk);
    end
    lmmi_request <= 1'b0;
    if (~lmmi_resetn) begin // negate all outputs
      lmmi_wr_rdn  <= 1'b0;
      lmmi_wdata   <= {DWIDTH{1'b0}};
      lmmi_offset  <= {AWIDTH{1'b0}};
    end
  end
endtask // m_write

task m_read  //single access only, cannot do burst
(
  input  [AWIDTH-1:0] addr,
  output [DWIDTH-1:0] data
);
  reg           done;
  reg           valid;
  
  reg           read_failed;
  begin
    lmmi_request <= 1'b1;
    lmmi_wr_rdn  <= 1'b0;
    lmmi_offset  <= addr;
    timeout_cntr  = 0;
    read_failed   = 0;

    fork
      begin // request
        done = 0;
        while(!done) begin
          @(posedge lmmi_clk);
            done = lmmi_ready;
        end
        lmmi_request <= 1'b0;
      end

      begin // data
        valid = 0;
        while(!valid | !done) begin
          @(posedge lmmi_clk);
            read_failed = (timeout_cntr > TIMEOUT_VALUE);
            valid = (read_failed)? 1'b1 : lmmi_rdata_valid;
            timeout_cntr = timeout_cntr + 1;
        end
        data = (read_failed)? {32{1'b1}} : lmmi_rdata;
      end
    join
    if (read_failed)
      $display("[%010t] [%0s]: LMMI Read  Access Failed.. Addr=%0h Timeout value=%0h",$time,model_name,addr,TIMEOUT_VALUE);
    else
      $display("[%010t] [%0s]: LMMI Read  Access.. Addr=%0h ReadData=%0h",$time,model_name,addr,data);
  end
endtask // m_read

endmodule //--tb_lmmi_mst--
`endif // TB_LMMI_MST
