// =============================================================================
// >>>>>>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
// -----------------------------------------------------------------------------
//   Copyright (c) 2017 by Lattice Semiconductor Corporation
//   ALL RIGHTS RESERVED
// -----------------------------------------------------------------------------
//
//   Permission:
//
//      Lattice SG Pte. Ltd. grants permission to use this code
//      pursuant to the terms of the Lattice Reference Design License Agreement.
//
//
//   Disclaimer:
//
//      This VHDL or Verilog source code is intended as a design reference
//      which illustrates how these types of functions can be implemented.
//      It is the user's responsibility to verify their design for
//      consistency and functionality through the use of formal
//      verification methods.  Lattice provides no warranty
//      regarding the use or functionality of this code.
//
// -----------------------------------------------------------------------------
//
//                  Lattice SG Pte. Ltd.
//                  101 Thomson Road, United Square #07-02
//                  Singapore 307591
//
//
//                  TEL: 1-800-Lattice (USA and Canada)
//                       +65-6631-2000 (Singapore)
//                       +1-503-268-8001 (other locations)
//
//                  web: http://www.latticesemi.com/
//                  email: techsupport@latticesemi.com
//
// -----------------------------------------------------------------------------
//
// =============================================================================
//                         FILE DETAILS
// Project               :
// File                  :lscc_lmmi2apb.v
// Title                 :
// Dependencies          :
// Description           :
// =============================================================================
//                        REVISION HISTORY
// Version               : 1.0.0.
// Author(s)             : Rommel.Edillorana@latticesemi.com
// Mod. Date             : 11/9/2017 2:12:50 PM
// Changes Made          : Initial release.
// =============================================================================

`ifndef LSCC_LMMI2APB
`define LSCC_LMMI2APB
//==========================================================================
// Module : lscc_lmmi2apb
//==========================================================================
module lscc_lmmi2apb #

( //--begin_param--
//----------------------------
// Parameters
//----------------------------
parameter                     DATA_WIDTH = 32,    // Data width
parameter                     ADDR_WIDTH = 16,    // Address width
parameter                     REG_OUTPUT = 1      // enable registered output

) //--end_param--

( //--begin_ports--
//----------------------------
// Global Signals (Clock and Reset)
//----------------------------
input                         clk_i,         // clock
input                         rst_n_i,       // active low reset

//----------------------------
// LMMI-Extended Interface
//----------------------------
input                         lmmi_request_i,       // start transaction
input                         lmmi_wr_rdn_i,        // write 1, read 0
input       [ADDR_WIDTH-1:0]  lmmi_offset_i,        // address/offset
input       [DATA_WIDTH-1:0]  lmmi_wdata_i,         // write data

output reg                    lmmi_ready_o,         // slave is ready to start new transaction
output reg                    lmmi_rdata_valid_o,   // read transaction is complete
output reg                    lmmi_ext_error_o,     // error indicator
output reg  [DATA_WIDTH-1:0]  lmmi_rdata_o,         // read data

output wire                   lmmi_resetn_o,         // lmmi active low reset

//----------------------------
// APB Interface
//----------------------------
input                         apb_pready_i,         // apb ready
input                         apb_pslverr_i,        // apb slave error
input       [DATA_WIDTH-1:0]  apb_prdata_i,         // apb read data

output reg                    apb_penable_o,        // apb enable
output reg                    apb_psel_o,           // apb slave select
output reg                    apb_pwrite_o,         // apb write 1, read 0
output reg  [ADDR_WIDTH-1:0]  apb_paddr_o,          // apb address
output reg  [DATA_WIDTH-1:0]  apb_pwdata_o          // apb write data

); //--end_ports--



//--------------------------------------------------------------------------
//--- Local Parameters/Defines ---
//--------------------------------------------------------------------------
localparam                    ST_BUS_IDLE = 2'd0;
localparam                    ST_BUS_REQ  = 2'd1;
localparam                    ST_BUS_DAT  = 2'd2;

//--------------------------------------------------------------------------
//--- Combinational Wire/Reg ---
//--------------------------------------------------------------------------

//--------------------------------------------------------------------------
//--- Registers ---
//--------------------------------------------------------------------------

assign lmmi_resetn_o   =  rst_n_i;

generate
  if(REG_OUTPUT) begin : reg_out
    reg         [1:0]             bus_sm_ns;
    reg         [1:0]             bus_sm_cs;

    reg                           lmmi_ready_nxt      ;
    reg                           lmmi_rdata_valid_nxt;
    reg                           lmmi_error_nxt      ;
    reg         [DATA_WIDTH-1:0]  lmmi_rdata_nxt      ;
    reg                           apb_penable_nxt     ;
    reg                           apb_psel_nxt        ;
    reg                           apb_pwrite_nxt      ;
    reg         [ADDR_WIDTH-1:0]  apb_paddr_nxt       ;
    reg         [DATA_WIDTH-1:0]  apb_pwdata_nxt      ;
    //--------------------------------------------
    //-- Bus Statemachine --
    //--------------------------------------------
    always @* begin
      bus_sm_ns = bus_sm_cs;
      case(bus_sm_cs)
        ST_BUS_REQ : begin
          bus_sm_ns     = ST_BUS_DAT;
        end
        ST_BUS_DAT : begin
          if(apb_pready_i) begin
            if(lmmi_request_i)
              bus_sm_ns = ST_BUS_REQ;
            else
              bus_sm_ns = ST_BUS_IDLE;
          end
          else begin
            bus_sm_ns   = ST_BUS_DAT;
          end
        end
        default : begin
          if(lmmi_request_i)
            bus_sm_ns   = ST_BUS_REQ;
          else
            bus_sm_ns   = ST_BUS_IDLE;
        end
      endcase
    end //--always @*--

    //--------------------------------------------
    //-- LMMI to APB conversion --
    //--------------------------------------------
    always @* begin
      lmmi_ready_nxt       = lmmi_ready_o      ;
      lmmi_rdata_valid_nxt = 1'b0              ;
      lmmi_rdata_nxt       = lmmi_rdata_o      ;
      lmmi_error_nxt       = 1'b0              ;
      apb_penable_nxt      = apb_penable_o     ;
      apb_psel_nxt         = apb_psel_o        ;
      apb_pwrite_nxt       = apb_pwrite_o      ;
      apb_paddr_nxt        = apb_paddr_o       ;
      apb_pwdata_nxt       = apb_pwdata_o      ;
      case(bus_sm_cs)
        ST_BUS_REQ : begin
          lmmi_ready_nxt       = 1'b0;
          apb_penable_nxt      = 1'b1;
        end
        ST_BUS_DAT : begin
          if(apb_pready_i) begin
            apb_psel_nxt       = 1'b0;
            apb_penable_nxt    = 1'b0;
            apb_pwrite_nxt     = 1'b0;
            lmmi_ready_nxt     = 1'b1;

            if(~apb_pwrite_o) begin
              lmmi_rdata_valid_nxt = 1'b1;
              lmmi_rdata_nxt       = apb_prdata_i;
              lmmi_error_nxt       = apb_pslverr_i;
            end

            if(lmmi_request_i) begin
              apb_psel_nxt    = 1'b1;
              apb_pwrite_nxt  = lmmi_wr_rdn_i;
              apb_pwdata_nxt  = lmmi_wdata_i;
              apb_paddr_nxt   = lmmi_offset_i;
            end
          end
        end
        default : begin
          lmmi_ready_nxt    = 1'b1;
          if(lmmi_request_i) begin
            apb_psel_nxt    = 1'b1;
            apb_penable_nxt = 1'b0;
            apb_pwrite_nxt  = lmmi_wr_rdn_i;
            apb_pwdata_nxt  = lmmi_wdata_i;
            apb_paddr_nxt   = lmmi_offset_i;
            lmmi_ready_nxt  = 1'b0;
          end
          else begin
            apb_psel_nxt    = 1'b0;
            apb_penable_nxt = 1'b0;
            apb_pwrite_nxt  = 1'b0;
          end
        end
      endcase
    end //--always @*--

    //--------------------------------------------
    //-- Sequential block --
    //--------------------------------------------
    always @(posedge clk_i or negedge rst_n_i) begin
      if(~rst_n_i) begin
        bus_sm_cs <= ST_BUS_IDLE;
        /*AUTORESET*/
        // Beginning of autoreset for uninitialized flops
        apb_paddr_o        <= {ADDR_WIDTH{1'b0}};
        apb_penable_o      <= 1'b0;
        apb_psel_o         <= 1'b0;
        apb_pwdata_o       <= {DATA_WIDTH{1'b0}};
        apb_pwrite_o       <= 1'b0;
        lmmi_ext_error_o   <= 1'b0;
        lmmi_rdata_o       <= {DATA_WIDTH{1'b0}};
        lmmi_rdata_valid_o <= 1'b0;
        lmmi_ready_o       <= 1'b0;
        // End of automatics
      end
      else begin
        bus_sm_cs          <= bus_sm_ns;
        lmmi_ready_o       <= lmmi_ready_nxt      ;
        lmmi_rdata_valid_o <= lmmi_rdata_valid_nxt;
        lmmi_rdata_o       <= lmmi_rdata_nxt      ;
        lmmi_ext_error_o   <= lmmi_error_nxt      ;
        apb_penable_o      <= apb_penable_nxt     ;
        apb_psel_o         <= apb_psel_nxt        ;
        apb_pwrite_o       <= apb_pwrite_nxt      ;
        apb_paddr_o        <= apb_paddr_nxt       ;
        apb_pwdata_o       <= apb_pwdata_nxt      ;
      end
    end //--always @(posedge clk_i or negedge rst_n_i)--
  end // REG_OUTPUT == 1

  else begin : no_reg // REG_OUTPUT == 0
    reg                           lmmi_ready_nxt;
    reg                           lmmi_rdy_tmp_nxt;
    reg                           apb_penable_nxt;

    reg                           reg_apb_psel  ;
    reg                           reg_apb_pwrite;
    reg         [ADDR_WIDTH-1:0]  reg_apb_paddr ;
    reg         [DATA_WIDTH-1:0]  reg_apb_pwdata;
    reg         [DATA_WIDTH-1:0]  reg_lmmi_rdata;
    reg                           lmmi_rdy_tmp;

    //--------------------------------------------
    //-- LMMI ready --
    //--------------------------------------------
    always @* begin
      lmmi_ready_nxt = 1'b0;
      if(lmmi_rdy_tmp) begin
        if(apb_pready_i & apb_psel_o) begin
          lmmi_rdy_tmp_nxt = 1'b0;
        end
        else begin
          lmmi_rdy_tmp_nxt = 1'b1;
        end
      end
      else begin
        if(lmmi_request_i) begin
          lmmi_rdy_tmp_nxt = 1'b1;
          lmmi_ready_nxt   = lmmi_request_i;
        end
        else begin
          lmmi_rdy_tmp_nxt = 1'b0;
        end
      end
    end //--always @*--

    //--------------------------------------------
    //-- store new request --
    //--------------------------------------------
    always @* begin
      if(lmmi_rdy_tmp) begin
        apb_psel_o   = reg_apb_psel;
        apb_paddr_o  = reg_apb_paddr;
        apb_pwrite_o = reg_apb_pwrite;
        apb_pwdata_o = reg_apb_pwdata;
      end
      else begin
        apb_psel_o   = lmmi_request_i;
        apb_paddr_o  = lmmi_offset_i;
        apb_pwrite_o = lmmi_wr_rdn_i;
        apb_pwdata_o = lmmi_wdata_i;
      end
    end //--always @*--

    //--------------------------------------------
    //-- APB enable --
    //--------------------------------------------
    always @* begin
      apb_penable_nxt = (~apb_penable_o &  (apb_psel_o             )) |
                        ( apb_penable_o & ~(apb_pready_i & apb_psel_o));
    end //--always @*--

    //--------------------------------------------
    //-- LMMI read data valid --
    //--------------------------------------------
    always @* begin
      lmmi_rdata_valid_o = apb_penable_o & apb_pready_i & ~apb_pwrite_o;
    end //--always @*--

    //--------------------------------------------
    //-- LMMI read data --
    //--------------------------------------------
    always @* begin
      lmmi_rdata_o     = (lmmi_rdata_valid_o)? apb_prdata_i : reg_lmmi_rdata;
      lmmi_ext_error_o = (lmmi_rdata_valid_o)? apb_pslverr_i : 1'b0;
    end //--always @*--

    //--------------------------------------------
    //-- Sequential block --
    //--------------------------------------------
    always @(posedge clk_i or negedge rst_n_i) begin
      if(~rst_n_i) begin
        /*AUTORESET*/
        // Beginning of autoreset for uninitialized flops
        apb_penable_o  <= 1'b0;
        lmmi_rdy_tmp   <= 1'b0;
        lmmi_ready_o   <= 1'b0;
        reg_apb_paddr  <= {ADDR_WIDTH{1'b0}};
        reg_apb_psel   <= 1'b0;
        reg_apb_pwdata <= {DATA_WIDTH{1'b0}};
        reg_apb_pwrite <= 1'b0;
        reg_lmmi_rdata <= {DATA_WIDTH{1'b0}};
        // End of automatics
      end
      else begin
        apb_penable_o  <= apb_penable_nxt;
        reg_apb_psel   <= apb_psel_o;
        reg_apb_paddr  <= apb_paddr_o;
        reg_apb_pwrite <= apb_pwrite_o;
        reg_apb_pwdata <= apb_pwdata_o;
        lmmi_rdy_tmp   <= lmmi_rdy_tmp_nxt;
        lmmi_ready_o   <= lmmi_ready_nxt;
        reg_lmmi_rdata <= lmmi_rdata_o;
      end
    end //--always @(posedge clk_i or negedge rst_n_i)--
  end // REG_OUTPUT == 0
endgenerate

//--------------------------------------------------------------------------
//--- Module Instantiation ---
//--------------------------------------------------------------------------



endmodule //--lscc_lmmi2apb--
`endif 
