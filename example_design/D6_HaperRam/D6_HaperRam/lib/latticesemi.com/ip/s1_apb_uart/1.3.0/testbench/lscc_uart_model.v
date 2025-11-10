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
// File : lscc_uart_model.v
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
`ifndef LSCC_UART_MODEL
`define LSCC_UART_MODEL

`timescale 1ns/100ps
`include "uart_rx.v"
`include "uart_tx.v"

module lscc_uart_model #(
  parameter       SERIAL_DATA_WIDTH = 8,
  parameter [1:0] STOP_BITS         = 1,
  parameter [1:0] PARITY_TYPE       = 0,
  parameter [0:0] STICK_PARITY      = 0,
  parameter       CLKS_PER_BIT      = 432)
(
  input         clk_i,
  input         rst_n_i,
  input         sin_i,
  output        sout_o,
  output  reg   dsr_n_o,
  output  reg   dcd_n_o,
  output  reg   cts_n_o,
  output  reg   ri_n_o,
  input         rts_n_i,
  input         dtr_n_i);


reg        tx_dv  ; 
reg  [7:0] tx_byte; 

wire       tx_active_w;
wire       tx_done_w  ;
wire       rx_dv_w    ;
wire [7:0] rx_byte    ;
wire       par_err_w  ;

initial begin
  dsr_n_o = 1'b1;
  dcd_n_o = 1'b1;
  cts_n_o = 1'b1;
  ri_n_o  = 1'b1;
  tx_dv   = 1'b0;
  tx_byte = 8'h00;
end

uart_tx #(
  .SERIAL_DATA_WIDTH(SERIAL_DATA_WIDTH),
  .STOP_BITS        (STOP_BITS        ),
  .PARITY_TYPE      (PARITY_TYPE      ),
  .STICK_PARITY     (STICK_PARITY     ),
  .CLKS_PER_BIT     (CLKS_PER_BIT     ))
utx (
  .i_Clock    (clk_i      ),
  .i_Reset_n  (rst_n_i    ),
  .i_Tx_DV    (tx_dv      ),
  .i_Tx_Byte  (tx_byte    ), 
  .o_Tx_Active(tx_active_w),
  .o_Tx_Serial(sout_o     ),
  .o_Tx_Done  (tx_done_w  ));

uart_rx #(
  .SERIAL_DATA_WIDTH(SERIAL_DATA_WIDTH),
  .STOP_BITS        (STOP_BITS        ),
  .PARITY_TYPE      (PARITY_TYPE      ),
  .STICK_PARITY     (STICK_PARITY     ),
  .CLKS_PER_BIT     (CLKS_PER_BIT     ))
urx (
   .i_Clock     (clk_i    ),
   .i_Reset_n   (rst_n_i  ),
   .i_Rx_Serial (sin_i    ),
   .o_Rx_par_err(par_err_w),
   .o_Rx_DV     (rx_dv_w  ),
   .o_Rx_Byte   (rx_byte  ));

task check_rx_data(input [7:0] rxdata, output check_res);
  begin
    while(rts_n_i && rst_n_i) begin // wait for RTS or reset to assert
      @(posedge clk_i);
    end
    //for(i=0; i<CLKS_PER_BIT; i=i+1)  // Wait for 1 UART bit
      @(posedge clk_i);                // check the case if response of MODEM is 1 clock cycle
//    cts_n_o <= 1'b0;
    while(!rx_dv_w && rst_n_i) begin // wait until data is received or reset asserts
      @(posedge clk_i);
    end
    if (rst_n_i) begin // no reset occured
      if (rx_byte[SERIAL_DATA_WIDTH-1:0] != rxdata[SERIAL_DATA_WIDTH-1:0]) begin
        $error("[%010t] [UART_MDL]: data compare error on Receive. Actual (0x%02x) != Expected (0x%02x)!", $time, rx_byte[SERIAL_DATA_WIDTH-1:0], rxdata[SERIAL_DATA_WIDTH-1:0]);
        check_res = 1'b0;  // check fail
      end
      else begin
        check_res = 1'b1;  // check pass
        $display("[%010t] [UART_MDL]: Receive data is expected (0x%02x)!", $time, rx_byte);
      end
      if (STICK_PARITY) begin
        if (par_err_w)
          $display("[%010t] [UART_MDL]: Parity error on Receive data 0x%02x during Stick Parity is OK.", $time, rx_byte);
      end
      else if (par_err_w)
        $error("[%010t] [UART_MDL]: Parity error on Receive data 0x%02x!", $time, rx_byte);
    end
//    cts_n_o <= 1'b1; 
    @(posedge clk_i);
  end
endtask


task send_data(input [7:0] txdata);
  reg     reset_negated;
  integer i;
  begin
    while(dtr_n_i && rst_n_i) begin // wait for RTS or reset to assert
      @(posedge clk_i);
    end
    //for(i=0; i<CLKS_PER_BIT; i=i+1)  // Wait for 1 UART bit
      @(posedge clk_i);                // check the case if response of MODEM is 1 clock cycle
//    dsr_n_o <= 1'b0;
    @(posedge clk_i);
    tx_dv   <= 1'b1;
    tx_byte <= txdata;
    @(posedge clk_i);
    tx_dv   <= 1'b0;
    @(posedge clk_i);
    reset_negated = 1'b1;
    while(!tx_active_w && reset_negated) begin // wait until UART_TX is active or reset asserts
      @(posedge clk_i);
      reset_negated = rst_n_i;
    end
    if (reset_negated) begin
      while(!tx_done_w && rst_n_i) begin // wait until UART_TX is done or reset asserts
        @(posedge clk_i);
      end
    end
    if (rst_n_i)
      $display("[%010t] [UART_MDL]: Transmit data (0x%02x) is done!", $time, txdata[SERIAL_DATA_WIDTH-1:0]);
//    dsr_n_o <= 1'b1; 
    @(posedge clk_i);
  end
endtask
endmodule
`endif