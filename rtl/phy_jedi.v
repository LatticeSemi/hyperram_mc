// -----------------------------------------------------------------------------
//   Copyright (c) 2025 by Lattice Semiconductor Corporation
//   ALL RIGHTS RESERVED
//   Subject to Lattice's Software License Agreement
// -----------------------------------------------------------------------------

// =============================================================================
// FILE DETAILS
// Project : <Hyperram>
// File : phy_jedi.v
// Title :
// Dependencies : 1.
//              : 2.
// Description :
// =============================================================================
// REVISION HISTORY
// Version : 1.0
// Author(s) : Yibin
// Mod. Date : 09/21/2022
// Changes Made : Initial version of RTL
// -----------------------------------------------------------------------------
// Version : 1.1
// Author(s) :
// Mod. Date :
// Changes Made :
// =============================================================================

module phy_jedi #(
  parameter DELAY_HALF_CYCLE        = 0,
  parameter DATA_FINE_DELAY_VALUE   = "0",
  parameter DATA_COARSE_DELAY_VALUE = "0NS",
  parameter integer    DELAY_VALUE  = "0"  ,
  parameter            DEL_MODE     = "USER_DEFINED"
  )
  (
  input              rst_i,
  input              clk_i,
  // input              clk90_i,
  input              clk270_i,

  input  wire        csn_raw,
  input  wire        reset_raw,
  input  wire        clk_en,
  input  wire        clk_post_en,
  input  wire [15:0] dq_rawdata_o,
  output wire [15:0] dq_rawdata_i,
  input  wire        dq_out_en,

  input  wire [1:0]  rwds_o,
  output wire [1:0]  rwds_i,
  input  wire        rwds_out_en,

  input  wire        delay_adj_en,
  input  wire [7:0]  dq_in_loadn_i,
  input  wire [7:0]  dq_in_move_i,
  input  wire [7:0]  dq_in_direction_i,
  output wire [7:0]  dq_in_cflag_o,
  input  wire [15:0] dq_in_coarse_dly_i,
  input  wire        rwds_in_loadn_i,
  input  wire        rwds_in_move_i,
  input  wire        rwds_in_direction_i,
  output wire        rwds_in_cflag_o,
  input  wire [1:0]  rwds_in_coarse_dly_i,

  output wire        clk_lvds_o,
  output wire        clkn_lvds_o,
  output wire        csn_o,
  output wire        reset_o,
  inout  wire [7:0]  dq_io,
  inout  wire        rwds_io
);
  //reset cdc
  wire clk_rst;
  wire clk270_rst;
  sync_non_rst  clk_rst_sync(
    .in_data (rst_i),
    .dest_clk (clk_i),
    .out_data (clk_rst)
  );
  sync_non_rst  clk270_rst_sync(
    .in_data (rst_i),
    .dest_clk (clk270_i),
    .out_data (clk270_rst)
  );
  // -----------------------------------------------------------------------------
  // register the control signals to sync with data which has two clock cycle
  // latency due to DDR
  // -----------------------------------------------------------------------------
  reg dq_out_en_ff0, dq_out_en_ff1, dq_out_en_ff2;
  always @ (posedge clk270_i or posedge clk270_rst) begin
    if (clk270_rst) begin
      dq_out_en_ff0 <= 1'b1;
      dq_out_en_ff1 <= 1'b1;
      dq_out_en_ff2 <= 1'b1;
    end
    else begin
      dq_out_en_ff0 <= dq_out_en;
      dq_out_en_ff1 <= dq_out_en_ff0;
      dq_out_en_ff2 <= dq_out_en_ff1;
    end
  end
  reg rwds_out_en_ff0, rwds_out_en_ff1, rwds_out_en_ff2;
  always @ (posedge clk270_i or posedge clk270_rst) begin
    if (clk270_rst) begin
      rwds_out_en_ff0 <= 1'b1;
      rwds_out_en_ff1 <= 1'b1;
      rwds_out_en_ff2 <= 1'b1;
    end
    else begin
      rwds_out_en_ff0 <= rwds_out_en;
      rwds_out_en_ff1 <= rwds_out_en_ff0;
      rwds_out_en_ff2 <= rwds_out_en_ff1;
    end
  end
  reg clk_post_en_ff0, clk_post_en_ff1, clk_post_en_ff2;
  always @ (posedge clk270_i or posedge clk270_rst) begin
    if (clk270_rst) begin
      clk_post_en_ff0 <= 1'b1;
      clk_post_en_ff1 <= 1'b1;
      clk_post_en_ff2 <= 1'b1;
    end
    else begin
      clk_post_en_ff0 <= clk_post_en;
      clk_post_en_ff1 <= clk_post_en_ff0;
      clk_post_en_ff2 <= clk_post_en_ff1;
    end
  end
  reg clk_en_ff0;
  always @ (posedge clk270_i or posedge clk270_rst) begin
    if (clk270_rst) begin
      clk_en_ff0 <= 1'b1;
    end
    else begin
      clk_en_ff0 <= clk_en;
    end
  end

  // -----------------------------------------------------------------------------
  // clock, reset and cs Section
  // -----------------------------------------------------------------------------
  wire clk_p_o, clk_n_o;
  reg clk_d1_buf;
  wire clk_d2;
  /*
  always @ (posedge clk270_i or posedge clk270_rst) begin
    if (clk270_rst)
      clk_d1_buf <= 1'b1;
    else if(clk_en)
      clk_d1_buf <= 1'b0;
    else if(clk_en_ff0 == 1'b0)
      clk_d1_buf <= 1'b1;
    else
      clk_d1_buf <= 1'b0;
  end*/
  always @ (posedge clk_i or posedge clk_rst) begin
    if (clk_rst)
      clk_d1_buf <= 1'b1;
    else if(clk_en)
      clk_d1_buf <= 1'b0;
    else
      clk_d1_buf <= 1'b1;
  end
  assign clk_d2 = clk_en ? 1'b0 : clk_d1_buf;

  ODDRX1 u_clk_ODDRX1 (
     .D0                 (clk_d2),
     .D1                 (1'b0),
     .SCLK               (clk_i),
     .RST                (clk_rst),
     .Q                  (clk_p_o)
  );
  ODDRX1 u_clkn_ODDRX1 (
     .D0                 (~clk_d2),
     .D1                 (1'b1),
     .SCLK               (clk_i),
     .RST                (clk_rst),
     .Q                  (clk_n_o)
  );
  // OBZ clk_bb (.I(clk_p_o), .T(clk_post_en_ff2), .O(clk_lvds_o));//BB clk_bb (.I(clk_p_o), .O(), .T(clk_post_en_ff2), .B(clk_lvds_o))/* synthesis IO_TYPE="LVDS"*/;//Modified by lin
  // OBZ clkn_bb (.I(clk_n_o), .T(clk_post_en_ff2), .O(clkn_lvds_o));
  OB clk_bb (.I(clk_p_o), .O(clk_lvds_o));
  OB clkn_bb (.I(clk_n_o), .O(clkn_lvds_o));

  ODDRX1 u_rst_ODDRX1 (
     .D0                 (reset_raw),
     .D1                 (reset_raw),
     .SCLK               (clk_i),
     .RST                (clk_rst),
     .Q                  (reset_o)
  );

  ODDRX1 u_cs_ODDRX1 (
     .D0                 (csn_raw),
     .D1                 (csn_raw),
     .SCLK               (clk_i),
     .RST                (clk_rst),
     .Q                  (csn_o)
  );
  // -----------------------------------------------------------------------------
  // rwds Section
  // -----------------------------------------------------------------------------
  wire no_del_rwds_o;
  wire before_del_rwds_i;
  wire after_del_rwds_i;
  wire [1:0] rwds_ff0;

  ODDRX1 u_rwds_ODDRX1 (
     .D0                 (rwds_o[1]),
     .D1                 (rwds_o[0]),
     .SCLK               (clk270_i),
     .RST                (clk270_rst),
     .Q                  (no_del_rwds_o)
  );

  DELAYB #(
    .DEL_VALUE           (DELAY_VALUE          ),   //delay 1250ps
    .COARSE_DELAY       ("0NS"                ),
    .DEL_MODE           (DEL_MODE             )
  ) u_idelay_rwds_inst (
    .A                   (before_del_rwds_i    ),   // I
    .Z                  (after_del_rwds_i     )   // O
  );

  IDDRX1 u_rwds_IDDRX1 (
     .D                  (after_del_rwds_i),
     .SCLK               (clk270_i),
     .RST                (clk270_rst),
    //  .Q1                 (rwds_i[0]),
    //  .Q0                 (rwds_i[1])
     .Q1                 (rwds_ff0[0]),
     .Q0                 (rwds_ff0[1])
  );
  FD1P3DX  FD1P3DX_RW0  (.D(rwds_ff0[0]),    .SP(1'b1), .CK(~clk270_i),   .CD(clk270_rst), .Q(rwds_i[0]));
  FD1P3DX  FD1P3DX_RW1  (.D(rwds_ff0[1]),    .SP(1'b1), .CK(~clk270_i),   .CD(clk270_rst), .Q(rwds_i[1]));

  BB rwds_bb (.I(no_del_rwds_o), .O(before_del_rwds_i), .T(rwds_out_en_ff2), .B(rwds_io));

  // -----------------------------------------------------------------------------
  // DQ Section
  // -----------------------------------------------------------------------------
  wire [7:0] no_del_dq_o;
  wire [7:0] before_del_dq_i; // Data before DELAYA.
  wire [7:0] after_del_dq_i;  // Data after  DELAYA.
  wire [15:0] dq_rawdata_ff0;

  generate
     genvar i;
     for (i = 0; i < 8 ; i = i + 1) begin : Data_tx
        ODDRX1 u_data_ODDRX1 (
           .D0                 (dq_rawdata_o[i + 8*1]),
           .D1                 (dq_rawdata_o[i + 8*0]),
           .SCLK               (clk270_i),
           .RST                (clk270_rst),
           .Q                  (no_del_dq_o[i])
           );

        DELAYB #(
          .DEL_VALUE          (DELAY_VALUE          ),   //delay 1250ps
          .COARSE_DELAY       ("0NS"                ),
          .DEL_MODE           (DEL_MODE             )
        ) u_data_DELAYA(
          .A                   (before_del_dq_i[i]   ),  // I
          .Z                  (after_del_dq_i[i]    )   // O
        );
        if (DELAY_HALF_CYCLE) begin
          IDDRX1 u_data_IDDRX1 (
             .D                  (after_del_dq_i[i]),
             .SCLK               (~clk270_i),
             .RST                (clk270_rst),
            //  .Q1                 (dq_rawdata_i[i+0]),
            //  .Q0                 (dq_rawdata_i[i+8])
             .Q1                 (dq_rawdata_ff0[i+0]),
             .Q0                 (dq_rawdata_ff0[i+8])
          );
        end else begin
          IDDRX1 u_data_IDDRX1 (
             .D                  (after_del_dq_i[i]),
             .SCLK               (clk270_i),
             .RST                (clk270_rst),
            //  .Q1                 (dq_rawdata_i[i+0]),
            //  .Q0                 (dq_rawdata_i[i+8])
             .Q1                 (dq_rawdata_ff0[i+0]),
             .Q0                 (dq_rawdata_ff0[i+8])
          );
        end
        FD1P3DX  FD1P3DX_0  (.D(dq_rawdata_ff0[i+0]),    .SP(1'b1), .CK(~clk270_i),   .CD(clk270_rst), .Q(dq_rawdata_i[i+0]));
        FD1P3DX  FD1P3DX_1  (.D(dq_rawdata_ff0[i+8]),    .SP(1'b1), .CK(~clk270_i),   .CD(clk270_rst), .Q(dq_rawdata_i[i+8]));
        // assign dq_rawdata_i[i+0] = dq_rawdata_ff0[i+0];
        // assign dq_rawdata_i[i+8] = dq_rawdata_ff0[i+8];


        BB dq_bb (.I(no_del_dq_o[i]), .O(before_del_dq_i[i]), .T(dq_out_en_ff2), .B(dq_io[i]));
     end
  endgenerate

endmodule
