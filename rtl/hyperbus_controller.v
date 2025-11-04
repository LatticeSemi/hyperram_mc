// =============================================================================
// FILE DETAILS
// Project : <Hyperram>
// File : hyperbus_controller.v
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

module hyperbus_controller #(
  parameter HYPERRAM_NUM       = 2,   //only 2 is supported
  parameter ONE_RANK_EN        = 1,    //only 1 is supported
  parameter DELAY_HALF_CYCLE   = 0
 )
 (
  input  wire        clk_i,
  input  wire        rst_n,       // Reset, active low
  input  wire        hyperbus_clk_i,
  //signals <-> axil_if
  output wire        csr_wrstoerr,
  output wire        csr_wtrserr,
  output wire        csr_wdecerr,
  output wire        csr_wact,
  output wire        csr_rdsstall,
  output wire        csr_rrstoerr,
  output wire        csr_rtrserr,
  output wire        csr_rdecerr,
  output reg         csr_rsamperr,
  output wire        csr_ract,
  input  wire [7:0]  mbar0_offset,
  input  wire        mcr0_maxen,
  input  wire        mcr0_maxlen,
  output wire        mcr0_crt,
  input  wire        mcr0_devtype,
  input  wire [3:0]  mtr_rcshi,
  input  wire [3:0]  mtr_wcshi,
  input  wire [3:0]  mtr_rcss,
  input  wire [3:0]  mtr_wcss,
  input  wire [3:0]  mtr_rcsh,
  input  wire [3:0]  mtr_wcsh,
  input  wire [3:0]  mtr_latency,
  input  wire [15:0] mtr_ext_tvcs,
  input  wire [1:0]  mtr_ext_tdsv,
  input  wire [1:0]  mtr_ext_tdsz,
  input  wire [1:0]  mtr_ext_toz,
  input  wire [1:0]  mtr_ext_tcsm,
  input  wire [1:0]  mtr_ext_trwr,
  input  wire [7:0]  mbar1_offset,
  input  wire        mcr1_maxen,
  input  wire        mcr1_maxlen,
  output wire        mcr1_crt,
  input  wire        mcr1_devtype,
  input  wire [1:0]  ccr_ram_size,
  input  wire [1:0]  ccr_mode,
  input  wire        ccr_dynamic_latency_en,
  input  wire [7:0]  dpcr_dq_bit_sel,
  input  wire        dpcr_dir,
  input  wire        dpcr_loadn,
  input  wire [1:0]  dpcr_coarse,
  //signals <-> axi_if
  input  wire        local_valid,
  output wire        local_ready,
  input  wire        local_wr,
  input  wire [23:0] local_addr,
  input  wire [3:0]  local_size,
  input  wire [31:0] local_wdata,
  input  wire        local_wvalid,
  input  wire [3:0]   local_wstrb,
  output reg [31:0]  local_rdata,
  output reg         local_rvalid,
  output reg         core_busy,
  //signals <-> phy
  output reg [HYPERRAM_NUM-1:0]         csn_raw,
  output reg [HYPERRAM_NUM-1:0]         reset_raw,
  output reg [HYPERRAM_NUM-1:0]         clk_en,
  output reg [HYPERRAM_NUM-1:0]         clk_post_en,

  output reg  [16 * HYPERRAM_NUM - 1:0] dq_rawdata_o,
  input  wire [16 * HYPERRAM_NUM - 1:0] dq_rawdata_i,
  output reg  [HYPERRAM_NUM-1:0]        dq_out_en,
  output reg  [2 * HYPERRAM_NUM - 1:0]  rwds_o,
  input  wire [2 * HYPERRAM_NUM - 1:0]  rwds_i,
  output reg  [HYPERRAM_NUM-1:0]        rwds_out_en,

  output reg [HYPERRAM_NUM-1:0]         delay_adj_en,
  output reg [7:0]                      dq_in_loadn_o,
  output reg [7:0]                      dq_in_move_o,
  output reg [7:0]                      dq_in_direction_o,
  input  wire [7:0]                     dq_in_cflag_i,
  output reg [15:0]                     dq_in_coarse_dly_o,
  output reg                            rwds_in_loadn_o,
  output reg                            rwds_in_move_o,
  output reg                            rwds_in_direction_o,
  input  wire                            rwds_in_cflag_i,
  output reg [1:0]                      rwds_in_coarse_dly_o
);
  //reset cdc
  wire hyperbus_rstn;
  sync_non_rst  lclk_rstn_sync(
    .in_data (rst_n),
    .dest_clk (hyperbus_clk_i),
    .out_data (hyperbus_rstn)
  );
//--------------------------------------------//
//    Logic for Control Flow with Hyperram    //
//--------------------------------------------//
  reg [15:0] count_down;   // counter down
  reg [15:0] count_value;  // count_value from different timing parameters

  reg        count_load;      // load the count_value to count_down
  reg        count_load_ff0;
  wire       count_load_en;
  reg        count_finish;     // flag to indicate done
  reg        count_finish_ff0;
  wire       count_finish_en;
  always @(posedge clk_i or negedge rst_n)
    if(!rst_n) begin
      count_load_ff0   <= 1'b0;
      count_finish_ff0 <= 1'b0;
    end
    else begin
      count_load_ff0 <= count_load;
      count_finish_ff0 <= count_finish;
    end
  assign count_load_en   = count_load && ~count_load_ff0;
  assign count_finish_en = count_finish && ~count_finish_ff0;

  always @(posedge clk_i or negedge rst_n)
    if(!rst_n) begin
      count_down   <= 16'hFFFF;
      count_finish <= 1'b0;
    end else if (count_load_en) begin
      count_down <= count_value;
      count_finish <= 1'b0;
    end else if (count_down == 16'd0)
      count_finish <= 1'b1;
    else
      count_down <= count_down - 16'd1;


  //deal with some timing parameters
  reg [3:0] latency;
  reg [3:0] latency_count;
  reg       double_latency;
  reg       start_latency;
  reg       ctrl_data_sync_latency;
  reg       cache_data_sync_latency;
  always @(posedge clk_i or negedge rst_n)
    if(!rst_n) begin
      latency <= 4'd0;
    end
    else begin
      latency <= mtr_latency + 4'd5;
    end

  always @(posedge clk_i or negedge rst_n)
    if(!rst_n) begin
      latency_count <= 4'd0;
    end
    else begin
      if (start_latency)
        latency_count <= latency_count - 4'd1;
      else begin
        if(double_latency)
          latency_count <= latency << 1'b1;
        else
          latency_count <= latency;
      end
    end


  assign local_ready = cache_data_sync_latency;
  wire [15:0] wdata_lower;
  wire [15:0] wdata_higher;
  wire [1:0]  wstrb_lower;
  wire [1:0]  wstrb_higher;
  reg [15:0]  rdata_lower;
  reg [15:0]  rdata_higher;

  assign wdata_lower  = local_wdata[15:0];
  assign wdata_higher = local_wdata[31:16];
  assign wstrb_lower  = local_wstrb[1:0];
  assign wstrb_higher = local_wstrb[3:2];

  //assign local_rdata[15:0]  = rdata_lower;
  //assign local_rdata[31:16] = rdata_higher;


  //state for control path
  reg [3:0] ctrl_state;
  localparam  [3:0] ST_CTRL_0_RST             = 4'd0,
                    ST_CTRL_1_POWERUP         = 4'd1,
                    ST_CTRL_2_SET_CR0         = 4'd2,
                    ST_CTRL_3_SET_CR1         = 4'd3,
                    ST_CTRL_4_IDLE            = 4'd4,
                    ST_CTRL_5_CMD_PREPARE     = 4'd5,
                    ST_CTRL_6_LATENCY_SYNC    = 4'd6,
                    ST_CTRL_7_LINEAR_TRANSFER = 4'd7,
                    ST_CTRL_8_DONE            = 4'd8;
  //state for data path
  reg [3:0] data_state;
  localparam  [3:0] ST_DATA_IDLE         = 4'd0,
                    ST_DATA_1_CA0        = 4'd1,
                    ST_DATA_2_CA1        = 4'd2,
                    ST_DATA_3_CA2        = 4'd3,
                    ST_DATA_4_LATENCY    = 4'd4,
                    ST_DATA_5_DIR_CTL    = 4'd5,
                    ST_DATA_6_WRITE      = 4'd6,
                    ST_DATA_7_READ_DUMMY = 4'd7,
                    ST_DATA_8_CLEANUP1   = 4'd8,
                    ST_DATA_9_CLEANUP2   = 4'd9,
                    ST_DATA_A_DONE       = 4'd10,
                    ST_DATA_B_POST_READ  = 4'd11,
                    ST_DATA_X_RESET      = 4'd12;

  //FSM for control flow
  localparam  [47:0] CR0_READ  = {8'hE0, 8'h00, 8'h01, 8'h00, 8'h00, 8'h00};
  localparam  [47:0] CR0_WRITE = {8'h60, 8'h00, 8'h01, 8'h00, 8'h00, 8'h00};
  //localparam  [47:0] CR0_WRITE = {8'h12, 8'h34, 8'h56, 8'h78, 8'h9A, 8'hBC};
  localparam  [47:0] CR1_READ  = {8'hE0, 8'h00, 8'h01, 8'h00, 8'h00, 8'h01};
  localparam  [47:0] CR1_WRITE = {8'h60, 8'h00, 8'h01, 8'h00, 8'h00, 8'h01};

  localparam  [5:0] TRP = 50; //RESET# Pulse Width, Min 200ns
  reg start_trans;
  reg trans_done;
  reg hyperam_reset_en;  // this is special since no transaction, but just pull the reset port
  reg trans_wr;
  reg [9:0]  trans_size; // size based on 1 word - 16 bits
  reg trans_hl_switch;
  reg [47:0] cmd_addr;
  reg [31:0] write_word;
  reg [3:0]  write_strb;
  reg write_data_for_ca;
  reg no_latency;
  reg [15:0] read_word;


  always @(posedge clk_i or negedge rst_n)
    if(!rst_n) begin
      ctrl_state  <= ST_CTRL_0_RST;
      count_load  <= 1'b0 ;
      start_trans <= 1'b0 ;
      hyperam_reset_en <= 1'b0;
      trans_wr    <= 1'b0 ;
      trans_size  <= 10'd0;
      trans_hl_switch <= 10'd1;  //higher or lower 16 bits switch
      cmd_addr          <= 48'd0;
      write_word        <= 32'd0;
      write_strb        <= 4'b0000; //1 for mask
      write_data_for_ca <= 1'b1;
      no_latency  <= 1'b0 ;
      read_word   <= 16'd0;
      core_busy   <= 1'b1;
    end else begin
      case(ctrl_state)
        ST_CTRL_0_RST: begin
          hyperam_reset_en  <= 1'b1;
          count_value  <= TRP;
          count_load   <= 1'b1;
          if (count_finish_en == 1'b1) begin
            count_load  <= 1'b0;
            hyperam_reset_en <= 1'b0;
            ctrl_state <= ST_CTRL_1_POWERUP;
          end
        end
        ST_CTRL_1_POWERUP: begin
          count_value  <= mtr_ext_tvcs;
          count_load   <= 1'b1;
          if (count_finish_en == 1'b1) begin
            count_load <= 1'b0;
            ctrl_state <= ST_CTRL_2_SET_CR0;
          end
        end
        ST_CTRL_2_SET_CR0: begin
          start_trans   <= 1'b1;
          trans_wr      <= 1'b1;
          trans_size    <= 10'd1;
          cmd_addr      <= CR0_WRITE;
          //write_word    <= {1'b1, 3'b000, 4'b1111, mtr_latency, ~ccr_dynamic_latency_en, 1'b1, 2'b11};
          //set to fixed 2 times latency to make sure two hyperrams have same sequence (otherwise, for one access, there may be the case one hyperam require 1 latency, another needs two times)
          write_word[15:0] <= {1'b1, 3'b000, 4'b1111, mtr_latency, 1'b1, 1'b1, 2'b00};
          no_latency    <= 1'b1;
          if (trans_done) begin
            start_trans <= 1'b0;
            ctrl_state  <= ST_CTRL_3_SET_CR1;
          end
        end
        ST_CTRL_3_SET_CR1: begin
          start_trans   <= 1'b1;
          trans_wr      <= 1'b1;
          trans_size    <= 10'd1;
          cmd_addr      <= CR1_WRITE;
          write_word[15:0]    <= {14'h0000, 2'b10};
          no_latency    <= 1'b1;
          if (trans_done) begin
            ctrl_state  <= ST_CTRL_4_IDLE;
            start_trans <= 1'b0;
          end
        end
        ST_CTRL_4_IDLE: begin
          no_latency    <= 1'b0;
          if(data_state == ST_DATA_IDLE)
            core_busy   <= 1'b0;
          if(local_valid)
            ctrl_state  <= ST_CTRL_5_CMD_PREPARE;
        end
        ST_CTRL_5_CMD_PREPARE: begin
          core_busy     <= 1'b1;
          start_trans   <= 1'b1;
          trans_wr      <= local_wr;
          trans_size  <= (10'd1 << local_size);
          //bit 47: 0 for write; bit 46: 0 for memory space; bit 45: 1 for linear burst
          //bits 44:16: Row & Upper Column Address; bit 15:3: reserved; bit 2:0: Lower Column Address
          cmd_addr      <= {~local_wr, 1'b0, 1'b1, 2'b00, 6'b000000, local_addr[23:3],13'd0, local_addr[2:0]};
          ctrl_state    <= ST_CTRL_6_LATENCY_SYNC;
        end
        ST_CTRL_6_LATENCY_SYNC: begin
          write_word <= local_wdata;
          write_data_for_ca <= 1'b0;
          //write_word   <= wdata_higher;
          //write_strb   <= wstrb_higher;
          if (ctrl_data_sync_latency) begin
            ctrl_state  <= ST_CTRL_7_LINEAR_TRANSFER;
          end
        end
        ST_CTRL_7_LINEAR_TRANSFER: begin
          if (trans_size == 10'd1) begin
            ctrl_state  <= ST_CTRL_8_DONE;
          end
          write_word   <= local_wdata;
          write_strb   <= local_wstrb;
          trans_size   <= trans_size - 1'd1;
        /*
          if (trans_hl_switch) begin
            write_word   <= wdata_lower;
            write_strb   <= wstrb_lower;

          end
          else begin
            write_word   <= wdata_higher;
            write_strb   <= wstrb_higher;
          end
          trans_hl_switch <= ~trans_hl_switch;
        */
        end
      ST_CTRL_8_DONE: begin
        //trans_hl_switch   <= 1'b1;
        write_data_for_ca <= 1'b1;
        if (trans_done) begin
          ctrl_state  <= ST_CTRL_4_IDLE;
          start_trans <= 1'b0;
        end
      end
      endcase
    end

  reg hyperam_reset_en_ff0;
  wire hyperam_reset_assert, hyperam_reset_deassert;
  always @(posedge clk_i or negedge rst_n)
    if(!rst_n) begin
      hyperam_reset_en_ff0 <= 1'b0;
    end
    else begin
      hyperam_reset_en_ff0 <= hyperam_reset_en;
    end
    assign hyperam_reset_assert   = hyperam_reset_en & ~hyperam_reset_en_ff0;
    assign hyperam_reset_deassert = ~hyperam_reset_en & hyperam_reset_en_ff0;
//--------------------------------------------//
//     Logic for data transfer with PHY       //
//--------------------------------------------//
  //FSM for data flow
  wire tx_fifo_empty;
  reg tx_fifo_empty_ff0, tx_fifo_empty_ff1;
  always @(posedge clk_i or negedge rst_n)
    if(!rst_n) begin
      tx_fifo_empty_ff0 <= 1'b0;
      tx_fifo_empty_ff1 <= 1'b0;
    end
    else begin
      tx_fifo_empty_ff0 <= tx_fifo_empty;
      tx_fifo_empty_ff1 <= tx_fifo_empty_ff0;
    end

  reg [16 * HYPERRAM_NUM - 1:0] dq_rawdata_o_c2phy;
  reg [2 * HYPERRAM_NUM - 1:0]  rwds_o_c2phy;
  reg [HYPERRAM_NUM-1:0]        csn_raw_c2phy;
  reg [HYPERRAM_NUM-1:0]        reset_raw_c2phy;
  reg [HYPERRAM_NUM-1:0]        clk_en_c2phy;
  reg [HYPERRAM_NUM-1:0]        clk_post_en_c2phy;
  reg [HYPERRAM_NUM-1:0]        dq_out_en_c2phy;
  reg [HYPERRAM_NUM-1:0]        rwds_out_en_c2phy;
  reg tx_fifo_wr_en;
  reg tx_ready;

  reg [2 * HYPERRAM_NUM - 1:0]  rwds_i_phy2c;
  wire [3:0]  rx_fifo_rwds_sys;
  wire [31:0] rx_fifo_dq_sys;
  wire rx_fifo_empty;
  reg rx_fifo_empty_ff0,rx_fifo_empty_ff1;
  reg rx_fifo_rd_en;
  reg [9:0] rx_trans_size;
  reg local_wvalid_ff0;
  always @(posedge clk_i or negedge rst_n)
  if(!rst_n) begin
    local_wvalid_ff0 <= 1'b0;
  end
  else begin
    local_wvalid_ff0 <= local_wvalid;
  end

  always @(posedge clk_i or negedge rst_n)
    if(!rst_n) begin
      data_state     <= ST_DATA_IDLE;
      trans_done     <= 1'b0;
      double_latency <= 1'b0;
      start_latency  <= 1'b0;
      ctrl_data_sync_latency  <= 1'b0;
      cache_data_sync_latency <= 1'b0;
      tx_fifo_wr_en  <= 1'b0;
      tx_ready       <= 1'b0;
      phy_rst(1'b1);
      rwds_i_phy2c       <= 4'd0;
      rx_fifo_rd_en      <= 1'b0;
      rx_trans_size      <= 10'd0;
      local_rvalid       <= 1'b0;
      local_rdata        <= 32'b0;
      csr_rsamperr       <= 1'b1;
    end else begin
      case(data_state)
        ST_DATA_IDLE: begin
          trans_done    <= 1'b0;
          ctrl_data_sync_latency  <= 1'b0;
          cache_data_sync_latency <= 1'b0;
          tx_fifo_wr_en <= 1'b0;
          tx_ready      <= 1'b0;
          if(start_trans && (trans_done == 1'b0)) begin
            //CA0
            tx_fifo_wr_en  <= 1'b1;
            rx_trans_size <= trans_size;
            enable_csclk();
            data_state <= ST_DATA_1_CA0;
          end
          else if (hyperam_reset_assert) begin
            tx_fifo_wr_en  <= 1'b1;
            hyperram_rst(1'b1);
            data_state <= ST_DATA_X_RESET;
          end
          else if (hyperam_reset_deassert) begin
            tx_fifo_wr_en  <= 1'b1;
            hyperram_rst(1'b0);
            data_state <= ST_DATA_X_RESET;
          end
        end
        ST_DATA_X_RESET: begin
            tx_ready   <= 1'b1;
            data_state <= ST_DATA_IDLE;
        end
        ST_DATA_1_CA0: begin
          ca_send(cmd_addr[47:32], 1'b0, 2'b00, 1'b1);
          //non Register Write, need to check latency
          if (no_latency == 1'b0) begin
/*
            rx_fifo_rd_en <= 1'b1;
            word_read(dq_rawdata_in, rwds_in);
            if (rwds_in == 2'b11)
              double_latency <= 1'b1;
*/
            double_latency <= 1'b1;  //only support fixed double latency for now.
          end
          data_state <= ST_DATA_2_CA1;
        end
        ST_DATA_2_CA1: begin
          ca_send(cmd_addr[31:16], 1'b0, 2'b00, 1'b1);
          data_state <= ST_DATA_3_CA2;
        end
        ST_DATA_3_CA2: begin
          ca_send(cmd_addr[15:0], 1'b0, 2'b00, 1'b1);
          if (no_latency) //Register Write
            data_state <= ST_DATA_6_WRITE;
          else begin
            data_state <= ST_DATA_4_LATENCY;
          end
        end
        ST_DATA_4_LATENCY: begin
          //dq to high-Z
          ca_send(cmd_addr[15:0], 1'b1, 2'b00, 1'b0);
          start_latency <= 1'b1;
          if (latency_count == 4'd6)  // assume fixed double latency for 1 rank
            cache_data_sync_latency <= 1'b1;
          else if(latency_count == 4'd4)
            ctrl_data_sync_latency <= 1'b1;
          if (latency_count == 4'd3) begin
            start_latency <= 1'b0;
            if(trans_wr)
              data_state <= ST_DATA_6_WRITE;
            else
              data_state <= ST_DATA_7_READ_DUMMY;
          end
        end
        ST_DATA_6_WRITE: begin
          word_send(write_word, write_data_for_ca, write_strb, local_wvalid_ff0);
          if(trans_size == 10'd1)
            data_state <= ST_DATA_8_CLEANUP1;
        end
        ST_DATA_7_READ_DUMMY: begin
          enable_read();
          if(trans_size == 10'd1)
            data_state <= ST_DATA_8_CLEANUP1;
        end
        ST_DATA_8_CLEANUP1: begin
          phy_rst(1'b0);
          data_state <= ST_DATA_9_CLEANUP2;
        end
        ST_DATA_9_CLEANUP2: begin
          phy_rst(1'b1);
          tx_ready   <= 1'b1;
          data_state <= ST_DATA_A_DONE;
        end
        ST_DATA_A_DONE: begin
          tx_ready      <= 1'b0;
          tx_fifo_wr_en <= 1'b0;
          //wait for previous trans done
          if(trans_wr) begin
            if (tx_fifo_empty_ff1) begin
              trans_done <= 1'b1;
              data_state <= ST_DATA_IDLE;
            end
          end
          else begin
            if(rx_fifo_empty_ff0 == 1'b0)
              data_state <= ST_DATA_B_POST_READ;
          end
        end
        ST_DATA_B_POST_READ: begin
          local_rvalid <= 1'b1;
          local_rdata  <= rx_fifo_dq_sys;
          rwds_i_phy2c <= rx_fifo_rwds_sys;
          if (rwds_i_phy2c != 4'b0101)
            csr_rsamperr <= 1'b1;
          rx_trans_size <= rx_trans_size - 10'd1;
          if(rx_trans_size == 10'd0) begin
            data_state <= ST_DATA_IDLE;
            trans_done <= 1'b1;
            local_rvalid <= 1'b0;
          end
        end
      endcase
    end

  task hyperram_rst;
    input  [15:0] enable;
    begin
      if(enable)
        reset_raw_c2phy   <= 2'b00;
      else
        reset_raw_c2phy   <= 2'b11;
    end
  endtask

  task phy_rst;
    input  [15:0] full;
    begin
      clk_en_c2phy        <= 2'b11; // 0 for output, 1 for input
      dq_rawdata_o_c2phy  <= 32'h0000;
      dq_out_en_c2phy     <= 2'b11;
      rwds_o_c2phy        <= 4'b0000;
      rwds_out_en_c2phy   <= 2'b11;
      if(full) begin
        csn_raw_c2phy     <= 2'b11;
        reset_raw_c2phy   <= 2'b11;
      end
      if (full)
        clk_post_en_c2phy <= 2'b11;
      else
        clk_post_en_c2phy <= 2'b00;
    end
  endtask

  task enable_csclk;
    begin
      csn_raw_c2phy      <= 2'b00;
      clk_en_c2phy       <= 2'b00;
      clk_post_en_c2phy  <= 2'b00;
    end
  endtask


  task ca_send;
    input [15:0] word_in;
    input        word_dir;
    input [1:0]  rwds_in;
    input        rwds_dir;
    begin
      csn_raw_c2phy             <= 2'b00;
      clk_en_c2phy              <= 2'b00;
      clk_post_en_c2phy         <= 2'b00;
      dq_rawdata_o_c2phy        <= {word_in, word_in};
      dq_out_en_c2phy           <= {word_dir, word_dir};
      rwds_o_c2phy              <= {rwds_in, rwds_in};
      rwds_out_en_c2phy         <= {rwds_dir, rwds_dir};
    end
  endtask

  task word_send;
    input [31:0] word_in;
    input        ca_data;
    input [3:0]  rwds_in;
    input        data_valid;
    begin
      csn_raw_c2phy        <= 2'b00;
      clk_en_c2phy         <= 2'b00;
      clk_post_en_c2phy    <= 2'b00;
      dq_out_en_c2phy      <= 2'b00;
      rwds_out_en_c2phy    <= 2'b00;
      if (ca_data) begin
        dq_rawdata_o_c2phy <= {word_in[15:0], word_in[15:0]};
      end
      else begin
        dq_rawdata_o_c2phy <= word_in;
        if (data_valid) begin
          tx_fifo_wr_en <= 1'b1;
        end else begin
          tx_fifo_wr_en <= 1'b0;
        end
      rwds_o_c2phy         <= rwds_in;
      end
    end
  endtask

  task enable_read;
    begin
      csn_raw_c2phy     <= 2'b00;
      clk_en_c2phy      <= 2'b00;
      clk_post_en_c2phy <= 2'b00;
      dq_out_en_c2phy   <= 2'b11;
      rwds_out_en_c2phy <= 2'b11;
    end
  endtask


  wire [47:0] tx_packed_data_sys;
  wire [47:0] tx_packed_data_phy;
  assign tx_packed_data_sys[31:0]  = dq_rawdata_o_c2phy;
  assign tx_packed_data_sys[35:32] = rwds_o_c2phy;

  generate
    genvar i;
    for (i = 0; i < HYPERRAM_NUM ; i = i + 1) begin: mapping
      //bit 37:36 for csn_raw
      assign tx_packed_data_sys[36 + i] = csn_raw_c2phy[i];
      //bit 39:38 for reset
      assign tx_packed_data_sys[38 + i] = reset_raw_c2phy[i];
      //bit 41:40 for clk_en
      assign tx_packed_data_sys[40 + i] = clk_en_c2phy[i];
      //bit 43:42 for dq_out_en
      assign tx_packed_data_sys[42 + i] = dq_out_en_c2phy[i];
      //bit 45:44 for rwds_out_en
      assign tx_packed_data_sys[44 + i] = rwds_out_en_c2phy[i];
      //bit 47:46 for clk_post_en
      assign tx_packed_data_sys[46 + i] = clk_post_en_c2phy[i];
    end
  endgenerate

  reg tx_ready_ff0, tx_ready_ff1, tx_ready_flag, tx_ready_flag_ff0, tx_ready_flag_ff1;
  always @(posedge hyperbus_clk_i or negedge hyperbus_rstn)
    if(!hyperbus_rstn) begin
      tx_ready_ff0 <= 1'b0;
      tx_ready_ff1 <= 1'b0;
    end
    else begin
      tx_ready_ff0 <= tx_ready;
      tx_ready_ff1 <= tx_ready_ff0;
    end

  always @(posedge hyperbus_clk_i or negedge hyperbus_rstn)
    if(!hyperbus_rstn) begin
      tx_ready_flag <= 1'b0;
    end
    else begin
      if(tx_ready_ff1)
        tx_ready_flag <= 1'b1;
      else if (tx_fifo_empty)
        tx_ready_flag <= 1'b0;
    end
  always @(posedge hyperbus_clk_i or negedge hyperbus_rstn)
    if(!hyperbus_rstn) begin
      tx_ready_flag_ff0 <= 1'b0;
      tx_ready_flag_ff1 <= 1'b0;
    end
    else begin
      tx_ready_flag_ff0 <= tx_ready_flag;
      tx_ready_flag_ff1 <= tx_ready_flag_ff0;
    end

  defparam tx_fifo.pmi_data_width_w      = 48;
  defparam tx_fifo.pmi_data_width_r      = 48;
  defparam tx_fifo.pmi_data_depth_w      = 512;
  defparam tx_fifo.pmi_data_depth_r      = 512;
  defparam tx_fifo.pmi_full_flag         = 512;
  defparam tx_fifo.pmi_empty_flag        = 0;
  defparam tx_fifo.pmi_almost_full_flag  = 511;
  defparam tx_fifo.pmi_almost_empty_flag = 1;
  defparam tx_fifo.pmi_regmode           = "reg";
  defparam tx_fifo.pmi_resetmode         = "async";
  defparam tx_fifo.pmi_family            = "LIFCL";
  defparam tx_fifo.pmi_implementation    = "EBR";
  pmi_fifo_dc tx_fifo (
      .Data       (tx_packed_data_sys),
      .WrClock    (clk_i),
      .RdClock    (hyperbus_clk_i),
      .WrEn       (tx_fifo_wr_en),
      .RdEn       (tx_ready_flag),
      .Reset      (~rst_n),
      .RPReset    (~hyperbus_rstn),
      // .Reset      (1'b0),
      // .RPReset    (1'b0),
      .Q          (tx_packed_data_phy),
      .Empty      (tx_fifo_empty),
      .Full       (),
      .AlmostEmpty(),
      .AlmostFull ()
  );

  reg [1:0] csn_raw_ff0;
  reg [1:0] csn_raw_ff1;
  reg [1:0] csn_raw_ff2;
  always @(posedge hyperbus_clk_i or negedge hyperbus_rstn)
    if(!hyperbus_rstn) begin
      csn_raw       <= 2'b11;
      reset_raw     <= 2'b11;
      clk_en        <= 2'b11; // all en follows BB direction: 0 for output, 1 for input
      clk_post_en   <= 2'b11;
      dq_rawdata_o  <= 32'h0000;
      dq_out_en     <= 2'b11;
      rwds_o        <= 4'b00;
      rwds_out_en   <= 2'b11;
    end
    else if (tx_ready_flag_ff1) begin
      dq_rawdata_o <= tx_packed_data_phy[31:0];
      rwds_o       <= tx_packed_data_phy[35:32];
      csn_raw      <= tx_packed_data_phy[37:36];
      reset_raw    <= tx_packed_data_phy[39:38];
      clk_en       <= tx_packed_data_phy[41:40];
      dq_out_en    <= tx_packed_data_phy[43:42];
      rwds_out_en  <= tx_packed_data_phy[45:44];
      clk_post_en  <= tx_packed_data_phy[47:46];
    end
    always @(posedge hyperbus_clk_i or negedge hyperbus_rstn)
      if(!hyperbus_rstn) begin
        csn_raw_ff0 <= 2'b11;
        csn_raw_ff1 <= 2'b11;
        csn_raw_ff2 <= 2'b11;
      end
      else begin
        csn_raw_ff0 <= csn_raw;
        csn_raw_ff1 <= csn_raw_ff0;
        csn_raw_ff2 <= csn_raw_ff1;
      end

  wire [35:0] rx_packed_data_sys;
  wire [35:0] rx_packed_data_phy;
  assign rx_packed_data_phy[31:0]  = dq_rawdata_i;
  assign rx_packed_data_phy[35:32] = rwds_i;
  assign rx_fifo_dq_sys   = rx_packed_data_sys[31:0];
  assign rx_fifo_rwds_sys = rx_packed_data_sys[35:32];


  reg rx_receive_start;
  reg [4:0] dq_valid_cnt;
  reg rx_fifo_wr_en;
  always @(posedge hyperbus_clk_i or negedge hyperbus_rstn)
    if(!hyperbus_rstn)
      rx_receive_start <= 1'b0;
    else begin
      if (csn_raw == 2'b00)
        rx_receive_start  <= 4'd1;
      else if ((DELAY_HALF_CYCLE && (csn_raw_ff2 == 2'b11)) || ((!DELAY_HALF_CYCLE) && (csn_raw_ff1 == 2'b11)))//add one cycle for 100MHZ
        rx_receive_start  <= 4'd0;
    end

  always @(posedge hyperbus_clk_i or negedge hyperbus_rstn)
    if(!hyperbus_rstn) begin
      dq_valid_cnt  <= 5'd0;
      rx_fifo_wr_en <= 1'b0;
    end
    else begin
      if (rx_receive_start) begin
        if (dq_valid_cnt == (5'd16 + mtr_latency + mtr_latency + DELAY_HALF_CYCLE))//add one cycle for 100MHZ and another for FD1P3DX delay
          rx_fifo_wr_en <= 1'b1;
        else
          dq_valid_cnt <= dq_valid_cnt + 4'd1;
      end else begin
        rx_fifo_wr_en <= 1'b0;
        dq_valid_cnt  <= 4'd0;
      end
    end

  pmi_fifo_dc #(
    .pmi_data_width_w      (36  ),
    .pmi_data_width_r      (36  ),
    .pmi_data_depth_w      (256 ),
    .pmi_data_depth_r      (256 ),
    .pmi_full_flag         (256 ),
    .pmi_empty_flag        (0   ),
    .pmi_almost_full_flag  (255 ),
    .pmi_almost_empty_flag (1   ),
    .pmi_regmode           ("reg"),
    .pmi_resetmode         ("async"),
    .pmi_family            ("LIFCL"),
    .pmi_implementation    ("EBR")
  )
  rx_fifo (
    .Data       (rx_packed_data_phy),
    .WrClock    (hyperbus_clk_i),
    .RdClock    (clk_i),
    .WrEn       (rx_fifo_wr_en),
    .RdEn       (1'b1),
    .Reset      (~hyperbus_rstn),
    .RPReset    (~rst_n),
    // .Reset      (1'b0),
    // .RPReset    (1'b0),
    .Q          (rx_packed_data_sys),
    .Empty      (rx_fifo_empty),
    .Full       (),
    .AlmostEmpty(),
    .AlmostFull ()
  );



  always @(posedge clk_i or negedge rst_n)
    if(!rst_n) begin
      rx_fifo_empty_ff0 <= 1'b1;
      rx_fifo_empty_ff1 <= 1'b1;
    end
    else begin
      rx_fifo_empty_ff0 <= rx_fifo_empty;
      rx_fifo_empty_ff1 <= rx_fifo_empty_ff0;
    end

  always @(posedge clk_i or negedge rst_n)
    if(!rst_n) begin
      delay_adj_en <= 2'b00;
      dq_in_loadn_o<= 8'd0;
      dq_in_move_o<= 8'd0;
      dq_in_direction_o<= 8'd0;
      dq_in_coarse_dly_o<= 16'd0;
      rwds_in_loadn_o<= 1'd0;
      rwds_in_move_o<= 1'd0;
      rwds_in_direction_o<= 1'd0;
      rwds_in_coarse_dly_o<= 2'd0;
  end

endmodule
