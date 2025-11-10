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
// File : tb_top.v
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

`ifndef TB_TOP
`define TB_TOP
`timescale 1ns/1ps

`include "tb_lmmi_mst.v"
`include "lscc_lmmi2apb.v"
`include "lscc_uart_model.v"

module tb_top;

`include "dut_params.v"

// -----------------------------------------------------------------------------
// Parameters
// -----------------------------------------------------------------------------
parameter  integer SYS_CLK_PERIOD    = 1000 / SYS_CLOCK_FREQ;

// Localparams
localparam        DATA_WIDTH   = 32;
localparam        ADDR_WIDTH   = 4;
localparam        REG_OUTPUT   = 1 ;
localparam [31:0] CLKS_PER_BIT = ((SYS_CLOCK_FREQ*1000*1000)/BAUD_RATE);
localparam        PARITY_TYPE  = (LCR_PARITY_ENABLE == 0) ? 0 : ((LCR_PARITY_ODD == 1) ? 1 : 3);
localparam        MS_IE        = 0;
localparam        RLS_IE       = 0;
localparam        THRE_IE      = 0;
localparam        RDA_IE       = 0;

//********************************************************************************
// Internal Reg/Wires
//********************************************************************************

// Clock and Reset Signals
reg         clk_i      ;
reg         rst_i      ;
reg         rst_n_i    ;

// wires connected to DUT when LMMI I/F
wire        lmmi_request_i    ; 
wire        lmmi_wr_rdn_i     ; 
wire  [3:0] lmmi_offset_i     ; 
wire  [7:0] lmmi_wdata_i      ; 
wire        lmmi_ready_o      ;
wire  [7:0] lmmi_rdata_o      ; 
wire        lmmi_rdata_valid_o; 
// wires connected to DUT when APB I/F
wire        apb_penable_i ; 
wire        apb_psel_i    ; 
wire        apb_pwrite_i  ; 
wire [5:0]  apb_paddr_i   ; 
wire [31:0] apb_pwdata_i  ; 
wire        apb_pready_o  ; 
wire        apb_pslverr_o ; 
wire [31:0] apb_prdata_o  ; 

wire        rts_n_o       ; 
wire        dtr_n_o       ; 
wire        dsr_n_i       ; 
wire        dcd_n_i       ; 
wire        cts_n_i       ; 
wire        ri_n_i        ; 
wire        rxd_i         ; 
wire        txd_o         ; 
wire        int_o         ; 

// -----------------------------------------------------------------------------
// Clock Generator
// -----------------------------------------------------------------------------
initial begin
  clk_i     = 0;
end

always #(SYS_CLK_PERIOD/2) clk_i = ~clk_i;

// -----------------------------------------------------------------------------
// Reset Signals
// -----------------------------------------------------------------------------
initial begin
  rst_i     = 1;
  rst_n_i   = 0;
  #(10*SYS_CLK_PERIOD)
  rst_i     = 0;
  rst_n_i   = 1;
end

`ifdef LIFCL
    reg CLK_GSR = 0;
    reg USER_GSR = 1;
    wire GSROUT;
    
    initial begin
        forever begin
            #5;
            CLK_GSR = ~CLK_GSR;
        end
    end
    
    GSR GSR_INST (
        .GSR_N(USER_GSR),
        .CLK(CLK_GSR)
    );
`endif
 
`include "dut_inst.v"

lscc_uart_model #(
  .SERIAL_DATA_WIDTH(LCR_DATA_BITS   ),
  .STOP_BITS        (LCR_STOP_BITS   ),
  .PARITY_TYPE      (PARITY_TYPE     ),
  .STICK_PARITY     (LCR_PARITY_STICK),
  .CLKS_PER_BIT     (CLKS_PER_BIT    ))
uart_mdl_0(
  .clk_i  (clk_i  ),
  .rst_n_i(rst_n_i),
  .sin_i  (txd_o  ),
  .sout_o (rxd_i  ),  
  .dsr_n_o(dsr_n_i),
  .dcd_n_o(dcd_n_i),
  .cts_n_o(cts_n_i),
  .ri_n_o (ri_n_i ),
  .rts_n_i(rts_n_o),
  .dtr_n_i(dtr_n_o));


tb_lmmi_mst #(
  .AWIDTH          (4),
  .DWIDTH          (8))
lmmi_mst_0 (
  .lmmi_clk        (clk_i             ),
  .lmmi_resetn     (rst_n_i           ),
  .lmmi_rdata      (lmmi_rdata_o      ),
  .lmmi_rdata_valid(lmmi_rdata_valid_o),
  .lmmi_ready      (lmmi_ready_o      ),
  .lmmi_offset     (lmmi_offset_i     ),
  .lmmi_request    (lmmi_request_i    ),
  .lmmi_wdata      (lmmi_wdata_i      ),
  .lmmi_wr_rdn     (lmmi_wr_rdn_i     )
);

generate
  if (APB_ENABLE) begin: apb_en
    lscc_lmmi2apb # (
      .DATA_WIDTH(8),
      .ADDR_WIDTH(6),
      .REG_OUTPUT(1))
    lmmi2apb_0 (
      .clk_i             (clk_i             ),
      .rst_n_i           (rst_n_i           ),
      .lmmi_request_i    (lmmi_request_i    ),
      .lmmi_wr_rdn_i     (lmmi_wr_rdn_i     ),
      .lmmi_offset_i     ({lmmi_offset_i,2'b00}),
      .lmmi_wdata_i      (lmmi_wdata_i      ),
      .lmmi_ready_o      (lmmi_ready_o      ),
      .lmmi_rdata_valid_o(lmmi_rdata_valid_o),
      .lmmi_ext_error_o  (                  ), // unconnected
      .lmmi_rdata_o      (lmmi_rdata_o      ),
      .lmmi_resetn_o     (                  ), // unconnected
      .apb_pready_i      (apb_pready_o      ),
      .apb_pslverr_i     (apb_pslverr_o     ),
      .apb_prdata_i      (apb_prdata_o[7:0] ),
      .apb_penable_o     (apb_penable_i     ),
      .apb_psel_o        (apb_psel_i        ),
      .apb_pwrite_o      (apb_pwrite_i      ),
      .apb_paddr_o       (apb_paddr_i       ),
      .apb_pwdata_o      (apb_pwdata_i[7:0] ));
      
    assign apb_pwdata_i[31:8] = 24'h000000;
  end
endgenerate

//GSR_CORE GSR_inst(
//        .GSR_N(rst_n_i),
//        .CLK(clk_i));
//
//PUR PUR_INST (
//    .PUR(rst_i)
//);

integer i;
integer error_count;

localparam ADDR_RBR   = 4'b0000;
localparam ADDR_THR   = 4'b0000;
localparam ADDR_IER   = 4'b0001;
localparam ADDR_IIR   = 4'b0010;
//localparam ADDR_FCR   = 4'b0010; 
localparam ADDR_LCR   = 4'b0011;
localparam ADDR_MCR   = 4'b0100;
localparam ADDR_LSR   = 4'b0101;
localparam ADDR_MSR   = 4'b0110;
localparam ADDR_SCR   = 4'b0111;  // Not implemented
localparam ADDR_DLRL  = 4'b1000;
localparam ADDR_DLRM  = 4'b1001;

// Not included in reg test: RBR, THR, IIR, FCR
// exp data, 8 bit writable bits, 8bit default value
  reg [23:0] ier     = {8'h00,(MODEM_ENA ? 8'h0F: 8'h07),{4'b0,MS_IE[0],RLS_IE[0],THRE_IE[0],RDA_IE[0]}};
  reg [23:0] lcr     = {8'h00,8'h7F,{2'b00,LCR_PARITY_STICK[0],~LCR_PARITY_ODD[0],LCR_PARITY_ENABLE[0],LCR_STOP_BITS[1],
                       (LCR_DATA_BITS==8) ? 2'b11:((LCR_DATA_BITS==7) ? 2'b10 : ((LCR_DATA_BITS==6) ? 2'b01 : 2'b00))}};
  reg [23:0] mcr     = MODEM_ENA ? {8'h00,8'h1F,8'h00} : {8'h00,8'h00,8'h00};
  reg [23:0] lsr     = {8'h00,8'h00,8'h60};
  reg [23:0] msr     = {8'h00,8'h00,8'h00};  // behaves as reserved
  reg [23:0] scr     = {8'h00,8'h00,8'h00};  // behaves as reserved
  reg [23:0] dlrl    = {8'h00,8'h00,8'h00};
  reg [23:0] dlrm    = {8'h00,8'h00,8'h00};


// Test
initial begin
  error_count = 0;
  repeat(20) @(posedge clk_i); // wait for some time
  register_check();
  reset_during_idle();
  if (FIFO)
    normal_operation_fifo_full_test();
  else
    normal_operation_no_fifo_test(1'b1);
  if (error_count == 0)
    $display("\n[%010t] [TEST]: SIMULATION PASSED \n", $time);
  else
    $display("\n[%010t] [TEST]: SIMULATION FAILED!  No of Errors = %0d.\n", $time, error_count);
  $finish;
end

//localparam ADDR_RBR   = 4'b0000;
//localparam ADDR_THR   = 4'b0000;
//localparam ADDR_IER   = 4'b0001;
//localparam ADDR_IIR   = 4'b0010;
//localparam ADDR_FCR   = 4'b0010;
//localparam ADDR_LCR   = 4'b0011;
//localparam ADDR_MCR   = 4'b0100;
//localparam ADDR_LSR   = 4'b0101;
//localparam ADDR_MSR   = 4'b0110;
//localparam ADDR_DLRL  = 4'b0111;
//localparam ADDR_DLRM  = 4'b1000;

// Test routines
task register_check();
  reg [7:0]  wr_data;
  reg [7:0]  rd_data;
  integer    j;
  begin
    $display("\n[%010t] [TEST]: Register access test start!", $time);
    $display("\n[%010t] [TEST]: Register default data check start.", $time);
    // Set Expected read data to default
    ier [23:16] = ier [7:0];
    lcr [23:16] = lcr [7:0];
    mcr [23:16] = mcr [7:0];
    lsr [23:16] = lsr [7:0];
    msr [23:16] = msr [7:0];
    dlrl[23:16] = dlrl[7:0];
    dlrm[23:16] = dlrm[7:0];
    check_rd_check_all_regs();
    $display("[%010t] [TEST]: Register default data check end.\n", $time);
    $display("[%010t] [TEST]: Register access check Start.", $time);
    for (i=0; i < 5; i=i+1) begin
      // Write Random data to all regs
      wr_data    = $random;
      wr_data[7] = 1'b0;      // dlab=0
      lmmi_mst_0.m_write(ADDR_LCR, wr_data);
      lcr[23:16] = get_exp_data(lcr[15:8], wr_data, lcr[7:0]);
      wr_data = $random;
      lmmi_mst_0.m_write(ADDR_IER, wr_data);
      ier[23:16] = get_exp_data(ier[15:8], wr_data, ier[7:0]);
      wr_data = $random;
      lmmi_mst_0.m_write(ADDR_MCR, wr_data);
      mcr[23:16] = get_exp_data(mcr[15:8], wr_data, mcr[7:0]);
      wr_data = $random;
      lmmi_mst_0.m_write(ADDR_LSR, wr_data);
      lsr[23:16] = get_exp_data(lsr[15:8], wr_data, lsr[7:0]);
      wr_data = $random;
      lmmi_mst_0.m_write(ADDR_MSR, wr_data);
      msr[23:16] = get_exp_data(msr[15:8], wr_data, msr[7:0]);
//      // Check LSR now before dlab is modified
//      lmmi_mst_0.m_read(ADDR_LCR, rd_data);
//      data_compare_reg(rd_data,lcr[23:16], "LCR");
//      rd_data[7] = 1'b1; // Allow access to DLR
//      lmmi_mst_0.m_write(ADDR_LCR, rd_data);
      wr_data = $random;
      lmmi_mst_0.m_write(ADDR_SCR, wr_data);
      wr_data = $random;
      lmmi_mst_0.m_write(ADDR_DLRL, wr_data);
      dlrl[23:16] = get_exp_data(dlrl[15:8], wr_data, dlrl[7:0]);
      wr_data = $random;
      lmmi_mst_0.m_write(ADDR_DLRM, wr_data);
      dlrm[23:16] = get_exp_data(dlrm[15:8], wr_data, dlrm[7:0]);
//      // Allow access to IER
//      lcr[23]     = 1'b0;
//      rd_data     = lcr[23:16]; 
//      lmmi_mst_0.m_write(ADDR_LCR, rd_data);
      if (i == 2) begin
        $display("[%010t] [TEST]: Reserved address check start.", $time);
        for (j=10; j < 16; j=j+1) begin
          wr_data = $random;
          lmmi_mst_0.m_write(j[3:0], $random);
        end
        for (j=10; j < 16; j=j+1) begin
          lmmi_mst_0.m_read(j[3:0], rd_data);
          data_compare_reg(rd_data,8'h00, "Reserved");
        end
        $display("[%010t] [TEST]: Reserved address check end.", $time);
      end
      check_rd_check_all_regs(); 
    end
    $display("[%010t] [TEST]: Register access check end.", $time);
    $display("[%010t] [TEST]:Register test end!\n", $time);
  end
endtask

task check_rd_check_all_regs();
  reg [7:0]  rd_data;
  begin
    // dlab bit must be set to 0 outside
    lmmi_mst_0.m_read(ADDR_IER, rd_data);
    data_compare_reg(rd_data,ier[23:16], "IER");
    lmmi_mst_0.m_read(ADDR_LCR, rd_data);
    data_compare_reg(rd_data,lcr[23:16], "LCR");
//    rd_data[7] = 1'b1; // Allow access to DLR
//    lmmi_mst_0.m_write(ADDR_LCR, rd_data);
    lmmi_mst_0.m_read(ADDR_MCR, rd_data);
    data_compare_reg(rd_data,mcr[23:16], "MCR");
    lmmi_mst_0.m_read(ADDR_LSR, rd_data);
    data_compare_reg(rd_data,lsr[23:16], "LSR");
    lmmi_mst_0.m_read(ADDR_MSR, rd_data);
    data_compare_reg(rd_data,msr[23:16], "MSR");
    lmmi_mst_0.m_read(ADDR_SCR, rd_data);
    data_compare_reg(rd_data,scr[23:16], "SCR-rsv");
    lmmi_mst_0.m_read(ADDR_DLRL, rd_data);
    data_compare_reg(rd_data,dlrl[23:16], "DLR_LSB");
    lmmi_mst_0.m_read(ADDR_DLRM, rd_data);
    data_compare_reg(rd_data,dlrm[23:16], "DLR_MSB");
  end
endtask

task reset_during_idle();
  begin
    $display("[%010t] [TEST]: Reset during IDLE start.", $time);
    // Previous register test updated the register values  
//    lcr[23]     = 1'b0; // Make IER accessible
//    lmmi_mst_0.m_write(ADDR_LCR, lcr[23:16]);
    lmmi_mst_0.m_write(ADDR_IER, 8'h0F); // Goal is to make int_o=1
    lmmi_mst_0.m_write(ADDR_MCR, 8'h03); // Set rts_n_o and dtr_n_o to 0
    @(posedge clk_i);
    @(posedge clk_i);
    @(posedge clk_i);
    if (~int_o) begin
      $error("[%010t] int_o should be asserted due to Transmitter Holding Register Empty Interrupt.",$time);
      error_count = error_count + 1;
    end
    if (rts_n_o) begin
      $error("[%010t] rts_n_o=1 when MCR.rts_ctrl=1",$time);
      error_count = error_count + 1;
    end
    if (dtr_n_o) begin
      $error("[%010t] dtr_n_o=1 when MCR.dtr_ctrl=1",$time);
      error_count = error_count + 1;
    end
    $display("[%010t] [TEST]: Asserting reset for 2 clock cycles.", $time);
    @(posedge clk_i);
    rst_i     <= 1'b1;
    rst_n_i   <= 1'b0;
    @(posedge clk_i);
    @(posedge clk_i);
    rst_i     <= 1'b0;
    rst_n_i   <= 1'b1;
    @(posedge clk_i);
    if (int_o) begin
      $error("[%010t] int_o did not negate after reset.",$time);
      error_count = error_count + 1;
    end
    if (~rts_n_o) begin
      $error("[%010t] rts_n_o did not negate after reset.",$time);
      error_count = error_count + 1;
    end
    if (~dtr_n_o) begin
      $error("[%010t] dtr_n_o did not negate after reset.",$time);
      error_count = error_count + 1;
    end
    $display("[%010t] [TEST]: Check that register default values are correct.", $time);
    ier [23:16] = ier [7:0];
    lcr [23:16] = lcr [7:0];
    mcr [23:16] = mcr [7:0];
    lsr [23:16] = lsr [7:0];
    msr [23:16] = msr [7:0];
    dlrl[23:16] = dlrl[7:0];
    dlrm[23:16] = dlrm[7:0];
    check_rd_check_all_regs();
    $display("[%010t] [TEST]: Reset during IDLE end.", $time);
  end
endtask

task normal_operation_fifo_full_test();
  reg [7:0]  tx_data_lst[0:18];
  reg [7:0]  rx_data_lst[0:15];
  reg [7:0]  rd_data;
  reg [7:0]  tmp_data;
  reg [15:0] rand_num;
  reg        rx_check_pass;
  integer    j, k, l, num;
  begin
    $display("[%010t] [TEST]: Normal operation XMIT and RCVR FIFO full test start.", $time);
    // Initialize registers
    lmmi_mst_0.m_read(ADDR_LCR, rd_data);
    rd_data[7] = 1'b0; // set dlab=0
    lmmi_mst_0.m_write(ADDR_LCR,rd_data);
    lmmi_mst_0.m_write(ADDR_IER, 8'h0D);  // THR Empty Int will not assert
//    lmmi_mst_0.m_write(ADDR_FCR, 8'hC0);  // RDA will assert when RCVR_FIFO has 14 data
    // initialize list and write to THR
    for(i=0;i<16;i=i+1) begin
      rand_num = $random;
      tx_data_lst[i] = rand_num[7:0];
      rx_data_lst[i] = rand_num[15:8];
      lmmi_mst_0.m_write(ADDR_THR, rand_num[7:0]);
    end
    rand_num = $random;
    tx_data_lst[16] = rand_num[7:0];
    lmmi_mst_0.m_write(ADDR_THR, rand_num[7:0]);
    lmmi_mst_0.m_write(ADDR_IER, 8'h0F);  // Enable all interrupts
//    lmmi_mst_0.m_write(ADDR_MCR, 8'h03);  // asssert rts_n_o and dtr_n_o
    i = 0;
    fork
      begin // DUT check sequence
        // Wait for Modem Status Interrupt
        if (MODEM_ENA) begin
          wait_for_int((CLKS_PER_BIT*12*2), "MS Stat");
          lmmi_mst_0.m_read(ADDR_IIR, rd_data);
          if (rd_data == 8'hC0) begin
            $display("[%010t] [TEST]: IIR=0x%02x is expected (MS int=1).", $time, rd_data);
            lmmi_mst_0.m_read(ADDR_MSR, rd_data);
            if (rd_data == 8'h11) begin
              $display("[%010t] [TEST]: MSR=0x%02x is expected (dcti=1).", $time, rd_data);
              lmmi_mst_0.m_read(ADDR_MSR, rd_data);
              if (rd_data[0]) begin
                $error("[%010t] [TEST]: MSR.ddcti did not negate when read", $time, rd_data);
                error_count = error_count + 1;
              end
            end
            else begin
              $error("[%010t] [TEST]: MSR=0x%02x is wrong.", $time, rd_data);
              error_count = error_count + 1;
            end
          end
          else begin
            $error("[%010t] [TEST]: IIR=0x%02x is wrong.", $time, rd_data);
            error_count = error_count + 1;
          end
        end
        $display("[%010t] [TEST]: Masking MODEM Status Interrupt.", $time, rd_data);
        lmmi_mst_0.m_write(ADDR_IER, 8'h06);    // RDA is disabled
        wait_for_int((CLKS_PER_BIT*12*17), "THR Empty");
        lmmi_mst_0.m_read(ADDR_IIR, rd_data);
        if (rd_data == 8'hC2) begin
          $display("[%010t] [TEST]: IIR=0x%02x is expected (THRE=1).", $time, rd_data);
          lmmi_mst_0.m_read(ADDR_LSR, rd_data);
          if (rd_data == 8'h21)
            $display("[%010t] [TEST]: LSR=0x%02x is expected (thr_empty=1,data_rdy=1).", $time, rd_data);
          else  begin
            $error("[%010t] [TEST]: LSR=0x%02x is wrong.", $time, rd_data);
            error_count = error_count + 1;
          end
        end
        else begin
          $error("[%010t] [TEST]: IIR=0x%02x is wrong.", $time, rd_data);
          error_count = error_count + 1;
        end
        // Check that masking interrupt will update IIR but not status
        lmmi_mst_0.m_write(ADDR_IER, 8'h04);  // RDA and THRE interrupts are disabled
        lmmi_mst_0.m_read(ADDR_IIR, rd_data); 
        lmmi_mst_0.m_read(ADDR_IIR, rd_data); // need dummy read for the interrupt to negate at output
        if (int_o) begin
          $error("[%010t] [TEST]: Interrupt did not negate when thre_int_en=0.", $time);
          error_count = error_count + 1;
        end
        if (rd_data == 8'hC1) begin
          $display("[%010t] [TEST]: IIR=0x%02x is expected.", $time, rd_data);
          lmmi_mst_0.m_read(ADDR_LSR, rd_data);
          if (rd_data == 8'h21)
            $display("[%010t] [TEST]: LSR=0x%02x is expected.", $time, rd_data);
          else begin
            $error("[%010t] [TEST]: LSR=0x%02x is wrong.", $time, rd_data);
            error_count = error_count + 1;
          end
        end
        else begin
          $error("[%010t] [TEST]: IIR=0x%02x is wrong.", $time, rd_data);
          error_count = error_count + 1;
        end
        
        $display("[%010t] [TEST]: DUT sequence done.", $time);
      end
     
      begin // UART tx data checks
        @(posedge clk_i);
        uart_mdl_0.cts_n_o <= 1'b0;
        @(posedge clk_i);
        for(l=0;l<17;l=l+1) begin
          uart_mdl_0.check_rx_data(tx_data_lst[l], rx_check_pass);
          if (!rx_check_pass)
            error_count = error_count + 1;
          else
            $display("[%010t] [TEST]: Tx data No. %0d check OK.", $time, l);
          if ((l == 15) && MODEM_ENA) begin // Negate CTS in the middle of byte 16
            for(k=0;k<(CLKS_PER_BIT*4);k=k+1) @(posedge clk_i);
            uart_mdl_0.cts_n_o <= 1'b1;
          end
          if ((l == 16) && MODEM_ENA) begin
            // Assert CTS after > 3 byte time
            for(k=0;k<(CLKS_PER_BIT*12*3);k=k+1) @(posedge clk_i);
            uart_mdl_0.cts_n_o <= 1'b0;
          end
        end
        @(posedge clk_i);
        uart_mdl_0.cts_n_o <= 1'b1;
        @(posedge clk_i);
        $display("[%010t] [TEST]: UART Model Tx data checks done.", $time);
      end
      
      begin // UART rx data sending by the model
        @(posedge clk_i);
        uart_mdl_0.dsr_n_o <= 1'b1;
        while(l < 8) begin // Wait for tx to send 8 data
          @(posedge clk_i);
        end
        @(posedge clk_i);
        uart_mdl_0.dsr_n_o <= 1'b0;
        @(posedge clk_i);
        for(j=0;j<16;j=j+1) begin
          uart_mdl_0.send_data(rx_data_lst[j]);
        end
        @(posedge clk_i);
        uart_mdl_0.dsr_n_o <= 1'b1;
        @(posedge clk_i);
        $display("[%010t] [TEST]: UART Model Rx data checks done.", $time);
      end
    join
    //////////////////////////////////////////////////////////////////////////////////
    // Perform UART check for RDA interrupt
    lmmi_mst_0.m_write(ADDR_IER, 8'h05);  // Enable RDA and LSR interrupts
    lmmi_mst_0.m_read(ADDR_IIR, rd_data); // dummy read
    wait_for_int((CLKS_PER_BIT*12*16), "RDA Int");
    lmmi_mst_0.m_read(ADDR_IIR, rd_data);
    if (rd_data == 8'hC4) begin
      $display("[%010t] [TEST]: IIR=0x%02x is expected (RDA=1).", $time, rd_data);
      lmmi_mst_0.m_read(ADDR_LSR, rd_data);
      if (rd_data[4:0] == 5'h01) begin
        $display("[%010t] [TEST]: LSR[4:0]=0x%02x is expected (data_rdy=1).", $time, rd_data);
        for(i=0;i<16;i=i+1) begin
          lmmi_mst_0.m_read(ADDR_RBR, rd_data);
          tmp_data = rx_data_lst[i];
          if (rd_data[LCR_DATA_BITS-1:0] != tmp_data[LCR_DATA_BITS-1:0]) begin
            $error("[%010t] [TEST]: Data compare error on data # %02d: RBR=0x%02x, Expected=0x%02x", $time, num, rd_data[LCR_DATA_BITS-1:0], tmp_data[LCR_DATA_BITS-1:0]);
            error_count = error_count + 1;
          end
        end
      end
      else begin
        $error("[%010t] [TEST]: LSR=0x%02x is wrong.", $time, rd_data);
        error_count = error_count + 1;
      end
      lmmi_mst_0.m_read(ADDR_LSR, rd_data);
      if (rd_data[4:0]!=5'h00) begin
        $error("[%010t] [TEST]: LSR.data_rdy=1 after reading all the data.", $time, rd_data);
        error_count = error_count + 1;
      end
    end
    else begin
      $error("[%010t] [TEST]: IIR=0x%02x is wrong.", $time, rd_data);
      error_count = error_count + 1;
    end
    
    
// Timeout is not supported yet
//    // Perform UART check for Timeout interrupt
//    wait_for_int((CLKS_PER_BIT*12*16), "Timeout Int");
//    lmmi_mst_0.m_read(ADDR_IIR, rd_data);
//    if (rd_data == 8'hCC) begin
//      $display("[%010t] [TEST]: IIR=0x%02x is expected (RDA=1,timeout_int=1).", $time, rd_data);
//      for (i=14; i<16; i=i+1) begin  // trig_lvl=2'b11
//        lmmi_mst_0.m_read(ADDR_LSR, rd_data);
//        if (rd_data == 8'h61) begin
//          $display("[%010t] [TEST]: LSR=0x%02x is expected (data_rdy=1).", $time, rd_data);
//          lmmi_mst_0.m_read(ADDR_RBR, rd_data);
//          tmp_data = rx_data_lst[i];
//          if (rd_data[LCR_DATA_BITS-1:0] != tmp_data[LCR_DATA_BITS-1:0]) begin
//            $error("[%010t] [TEST]: Data compare error on data # %02d: RBR=0x%02x, Expected=0x%02x", $time, i, rd_data[LCR_DATA_BITS-1:0], tmp_data[LCR_DATA_BITS-1:0]);
//            error_count = error_count + 1;
//          end
//        end
//        else begin
//          $error("[%010t] [TEST]: LSR=0x%02x is wrong.", $time, rd_data);
//          error_count = error_count + 1;
//        end
//      end  
//      lmmi_mst_0.m_read(ADDR_LSR, rd_data);
//      if (rd_data!=8'h60) begin
//        $error("[%010t] [TEST]: LSR.data_rdy=1 after reading all the data.", $time, rd_data);
//        error_count = error_count + 1;
//      end
//    end
//    else begin
//      $error("[%010t] [TEST]: IIR=0x%02x is wrong.", $time, rd_data);
//      error_count = error_count + 1;
//    end
    for (i=14; i<1000; i=i+1) @(posedge clk_i); // just wait for some time
    $display("[%010t] [TEST]: Normal operation XMIT and RCVR FIFO full test end.", $time);
  end
endtask // normal_operation_fifo_full_test

task wait_for_int(
  input     [31:0] timeout_val,
  input   [8*15:1] comment      // To identify the call
);
  reg [31:0] count;
  begin
    $display("[%010t] [TEST]: Waiting for interrupt to assert (Timeout=%0d).", $time, timeout_val);
    count = 32'h0;
    while(~int_o && (count < timeout_val)) begin 
      @(posedge clk_i);
      count = count+1;
//      if (int_o)
//        $display("[%010t] [TEST]: Interrupt asserted.", $time);
    end
    if (count < timeout_val)
      $display("[%010t] [TEST]: Interrupt asserted. (%0s)", $time, comment);
    else 
      $error("[%010t] [TEST]: Timeout occured while waiting for interrupt (%0s).", $time, comment);
  end
endtask

task data_compare_reg(
  input     [7:0]         act,
  input     [7:0]         exp,
  input reg [8*10:1]      reg_name
);
  begin
    if (exp != act) begin
      error_count = error_count + 1;
      $error("[%010t] [reg_test]: Data compare error on %s register. Actual (0x%02x) != Expected (0x%02x)!", $time, reg_name, act, exp);
    end
  end
endtask

//functions
function [7:0] get_exp_data(input [7:0] wrbits, 
                            input [7:0] data,
                            input [7:0] def);
  begin
    if (wrbits == 8'b00)
      get_exp_data = def;
    else
      get_exp_data = wrbits & data;
  end
endfunction


task normal_operation_no_fifo_test(
  input int_ena
);
  reg [7:0]    tx_data_lst[0:15];
  reg [7:0]    rx_data_lst[0:15];
  reg [7:0]    rd_data ;
  reg [7:0]    exp_data;
  reg [7:0]    rd_reg  ;
  reg [7:0]    loop_cnt;
  reg [15:0]   rand_num;
  reg          rx_check_pass;
  integer      j, k, l;
  begin
    $display("[%010t] [TEST]: Normal operation no FIFO test start.", $time);
    for(i=0;i<16;i=i+1) begin
      rand_num = $random;
      tx_data_lst[i] = rand_num[7:0];
      rx_data_lst[i] = rand_num[15:8];
    end
    lmmi_mst_0.m_write(ADDR_IER, 8'h00);  // Disable all interrupts
//    lmmi_mst_0.m_write(ADDR_MCR, 8'h03);  // asssert rts_n_o and dtr_n_o
    i = 0;
    j = 0;
    fork
      begin // DUT check sequence
        // Transmit 1st 16 tx_data and Receive 8 rx_data
        for(i=0;i<16;i=i+1) begin
          lmmi_mst_0.m_write(ADDR_THR, tx_data_lst[i]);
          lmmi_mst_0.m_read(ADDR_IER, rd_reg);  // dummy read
          lmmi_mst_0.m_read(ADDR_IER, rd_reg);  // dummy read
          if (int_ena) begin
            if (i==0) 
              lmmi_mst_0.m_write(ADDR_IER, 8'h07);  // Enable ALL interrupts
            wait_for_int((CLKS_PER_BIT*12*2), "Tx Data");
            lmmi_mst_0.m_read(ADDR_IIR, rd_reg);
            if (rd_reg == 8'h04) begin // a data is received 
              exp_data = rx_data_lst[j];
              lmmi_mst_0.m_read(ADDR_RBR, rd_data);
              if (rd_data[LCR_DATA_BITS-1:0] == exp_data[LCR_DATA_BITS-1:0])
                $display("[%010t] [TEST]: Receive data %02x is expected", $time, rd_data);
              else begin
                $error("[%010t] [TEST]: Receive data compare error! Expected=%02x, Actual=%02x", $time, exp_data[LCR_DATA_BITS-1:0], rd_data[LCR_DATA_BITS-1:0]);
                error_count = error_count + 1;
              end
              j = j + 1;
              lmmi_mst_0.m_read(ADDR_IER, rd_reg);  // dummy read
              lmmi_mst_0.m_read(ADDR_IER, rd_reg);  // dummy read
              wait_for_int((CLKS_PER_BIT*12*2), "Rx Data");
              lmmi_mst_0.m_read(ADDR_IIR, rd_reg);
              if (rd_reg != 8'h02) begin
                $error("[%010t] [TEST]: IIR=%0x is not expected after Rx data No. %02d!", $time, rd_reg, j);
                error_count = error_count + 1;
              end
            end
            else if (rd_reg != 8'h02) begin // If it is not RDA, it should be THRE
              $error("[%010t] [TEST]: IIR=%0x is not expected for Tx data No. %0d!", $time, rd_reg, i);
              error_count = error_count + 1;
            end
          end
          else begin
            rd_reg   = 8'h00;
            loop_cnt = 8'h00;
            while ((loop_cnt < 24) && (~rd_reg[5])) begin
              repeat (CLKS_PER_BIT) @clk_i;
              lmmi_mst_0.m_read(ADDR_LSR, rd_reg);
              if (rd_reg[0]) begin
                exp_data = rx_data_lst[j];
                lmmi_mst_0.m_read(ADDR_RBR, rd_data);
                if (rd_data[LCR_DATA_BITS-1:0] == exp_data[LCR_DATA_BITS-1:0])
                  $display("[%010t] [TEST]: Receive data No. %0d (%02x) is expected", $time, j, rd_data[LCR_DATA_BITS-1:0]);
                else begin
                  $error("[%010t] [TEST]: Receive data compare error for Data No. %0d! Expected=%02x, Actual=%02x", $time, j, exp_data[LCR_DATA_BITS-1:0], rd_data[LCR_DATA_BITS-1:0]);
                  error_count = error_count + 1;
                end
                j = j + 1;
              end
              loop_cnt = loop_cnt + 8'h01;
            end
            if (loop_cnt == 24) begin
              $error("[%010t] [TEST]: timeout occurs while polling LSR Bit 5 to assert for Data No. %0d", $time, i);
              error_count = error_count + 1;
            end
          end
        end // for loop
        lmmi_mst_0.m_read(ADDR_IER, rd_reg);  // dummy read
        lmmi_mst_0.m_write(ADDR_IER, 8'h05);  // Disable THRE interrupts
        lmmi_mst_0.m_read(ADDR_IER, rd_reg);  // dummy read
        // Receive Remaining rx_data
        //for(i=j;i<16;i=i+1) begin
        i = j;
        while(i < 16) begin
          if (int_ena) begin
            wait_for_int((CLKS_PER_BIT*12*2), "Rx Data2");
            lmmi_mst_0.m_read(ADDR_IIR, rd_reg);
            if (rd_reg == 8'h04) begin // a data is received 
              exp_data = rx_data_lst[i];
              lmmi_mst_0.m_read(ADDR_RBR, rd_data);
              if (rd_data[LCR_DATA_BITS-1:0] == exp_data[LCR_DATA_BITS-1:0])
                $display("[%010t] [TEST]: Receive data No. %0d (%02x) is expected", $time, i, rd_data);
              else begin
                $error("[%010t] [TEST]: Receive data compare error for Data No. %0d! Expected=%02x, Actual=%02x", $time, i, exp_data[LCR_DATA_BITS-1:0], rd_data[LCR_DATA_BITS-1:0]);
                error_count = error_count + 1;
              end
              lmmi_mst_0.m_read(ADDR_IER, rd_reg);  // dummy read
              lmmi_mst_0.m_read(ADDR_IER, rd_reg);  // dummy read
            end
            else begin
              $error("[%010t] [TEST]: IIR=%0x is not expected for Rx data No. %0d!", $time, rd_reg, i);
              error_count = error_count + 1;
            end
          end
          else begin
            rd_reg   = 8'h00;
            loop_cnt = 8'h00;
            while ((loop_cnt < 24) && (~rd_reg[0])) begin
              repeat (CLKS_PER_BIT) @clk_i;
              lmmi_mst_0.m_read(ADDR_LSR, rd_reg);
              if (rd_reg[0]) begin
                exp_data = rx_data_lst[i];
                lmmi_mst_0.m_read(ADDR_RBR, rd_data);
                if (rd_data[LCR_DATA_BITS-1:0] == exp_data[LCR_DATA_BITS-1:0])
                  $display("[%010t] [TEST]: Receive data %02x is expected", $time, rd_data);
                else begin 
                  $error("[%010t] [TEST]: Receive data compare error! Expected=%02x, Actual=%02x", $time, exp_data[LCR_DATA_BITS-1:0], rd_data[LCR_DATA_BITS-1:0]);
                  error_count = error_count + 1;
                end
              end
              loop_cnt = loop_cnt + 8'h01;
            end
            if (loop_cnt == 24) begin
              $error("[%010t] [TEST]: timeout occurs while polling LSR Bit 5 to assert for Data No. %d", $time, i);
              error_count = error_count + 1;
            end
          end
          i = i + 1;
        end // while loop
        $display("[%010t] [TEST]: DUT sequence done.", $time);
      end
     
      begin // UART tx data checks
        @(posedge clk_i);
        uart_mdl_0.cts_n_o <= 1'b0;
        @(posedge clk_i);
        for(k=0;k<16;k=k+1) begin
          uart_mdl_0.check_rx_data(tx_data_lst[k], rx_check_pass);
          if (!rx_check_pass)
            error_count = error_count + 1;
          else
            $display("[%010t] [TEST]: Tx data No. %0d check OK.", $time, i);
        end
        @(posedge clk_i);
        $display("[%010t] [TEST]: UART Model Tx data checks done.", $time);
      end
      
      begin // UART rx data sending by the model
        @(posedge clk_i);
        uart_mdl_0.dsr_n_o <= 1'b1;
        while(i < 8) begin // Wait for tx to send 8 data
          @(posedge clk_i);
        end
        @(posedge clk_i);
        @(posedge clk_i);
        for(l=0;l<16;l=l+1) begin
          uart_mdl_0.send_data(rx_data_lst[l]);
        end
        @(posedge clk_i);
        $display("[%010t] [TEST]: UART Model Rx data checks done.", $time);
      end
    join

    for (i=14; i<1000; i=i+1) @(posedge clk_i); // just wait for some time
    $display("[%010t] [TEST]: Normal operation no FIFO test end.", $time);
  end
endtask // normal_operation_no_fifo_test

endmodule
`endif
