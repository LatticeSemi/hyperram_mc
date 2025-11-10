`ifndef LSCC_AXIMEM_MANAGER
`define LSCC_AXIMEM_MANAGER

module lscc_aximem_manager # (
    parameter       DATA_WIDTH                = 32,
    parameter       ADDR_DEPTH                = 1024,
    parameter       ID_WIDTH                  = 1,
    parameter       INIT_FILE                 = "none",
    parameter       INIT_FILE_FORMAT          = "hex",
    parameter       TARGET_COUNTER            = 10
)(
// ----------------------------
// Common Signals
// ----------------------------
    input                        axi_aclk_i,
    input                        axi_resetn_i,

// ----------------------------
// AXI4 Manager Interface 0
// ----------------------------
    output  [ID_WIDTH-1:0]       axi_m0_awid_o,
    output  [31:0]               axi_m0_awaddr_o,
    output  [7:0]                axi_m0_awlen_o,
    output  [2:0]                axi_m0_awsize_o,
    output  [1:0]                axi_m0_awburst_o,
    output                       axi_m0_awvalid_o,
    input                        axi_m0_awready_i,

    output  [DATA_WIDTH-1:0]     axi_m0_wdata_o,
    output  [DATA_WIDTH/8-1:0]   axi_m0_wstrb_o,
    output                       axi_m0_wlast_o,
    output                       axi_m0_wvalid_o,
    input                        axi_m0_wready_i,

    input [ID_WIDTH-1:0]         axi_m0_bid_i,
    input [1:0]                  axi_m0_bresp_i,
    input                        axi_m0_bvalid_i,
    output                       axi_m0_bready_o,

    output  [ID_WIDTH-1:0]       axi_m0_arid_o,
    output  [31:0]               axi_m0_araddr_o,
    output  [7:0]                axi_m0_arlen_o,
    output  [2:0]                axi_m0_arsize_o,
    output  [1:0]                axi_m0_arburst_o,
    output                       axi_m0_arvalid_o,
    input                        axi_m0_arready_i,

    input [ID_WIDTH-1:0]         axi_m0_rid_i,
    input [DATA_WIDTH-1:0]       axi_m0_rdata_i,
    input [1:0]                  axi_m0_rresp_i,
    input                        axi_m0_rlast_i,
    input                        axi_m0_rvalid_i,
    output                       axi_m0_rready_o,

    output                       axi_m0_data_chk,
    output                       done_o,
    output [31:0]                safe_count_o
);

// ----------------------------
// State
// ----------------------------
    localparam ST_IDLE         = 3'd0;
    localparam ST_AW_ADDR      = 3'd1;
    localparam ST_AW_DATA      = 3'd2;
    localparam ST_BR_WAIT      = 3'd3;
    localparam ST_BR_OKAY      = 3'd4;
    localparam ST_AR_ADDR      = 3'd5;
    localparam ST_RD_WAIT      = 3'd6;
    localparam ST_RD_OKAY      = 3'd7;

    reg [2:0]  cstate_reg;
    reg [2:0]  nstate_reg;

// ----------------------------
// Delay Values
// ----------------------------
    localparam P_RREADY_DLY    = 0;

// ----------------------------
// Output registers
// ----------------------------
    reg                  axi_m0_awvalid_reg;
    reg                  axi_m0_wvalid_reg;
    reg                  axi_m0_bready_reg;
    reg                  axi_m0_arvalid_reg;
    reg                  axi_m0_rready_reg;
    reg [31:0]           axi_m0_rready_dly_cnt;

// ----------------------------
// Expected Address and Data
// ----------------------------
    reg [31:0]            addr;
    reg [DATA_WIDTH-1:0]  data;
    reg [DATA_WIDTH-1:0]  valid_data;
    reg [DATA_WIDTH-1:0]  mem [ADDR_DEPTH-1:0]; 
    reg [DATA_WIDTH-1:0]  exp_data;
    reg [31:0]            exp_addr;
   wire [31:0]            exp_mem_addr;
    reg                   data_chk;
    reg [31:0]            done_reg;
    integer i;

initial begin
  if (INIT_FILE != "none") begin
      if (INIT_FILE_FORMAT == "hex")
        $readmemh (INIT_FILE, mem, 0, (ADDR_DEPTH - 1));
      else
        $readmemb (INIT_FILE, mem, 0, (ADDR_DEPTH - 1));
  end
end

  always @ (posedge axi_aclk_i) begin
	for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin
		data[i*8 +: 8] 	<= $urandom_range(8'h00, 8'hFF);
	end
  end

  always @ (posedge axi_aclk_i) begin
	addr <= $urandom_range(0, ADDR_DEPTH);
  end

  always @ (posedge axi_aclk_i or negedge axi_resetn_i) begin
    if (~axi_resetn_i)
      valid_data		<= {DATA_WIDTH{1'b0}};
    else if (axi_m0_wvalid_reg && axi_m0_wready_i)
      valid_data		<= data[DATA_WIDTH-1:0];
  end

  always @ (posedge axi_aclk_i or negedge axi_resetn_i) begin
    if ((cstate_reg == ST_BR_WAIT) && axi_m0_bvalid_i && (axi_m0_bresp_i == 2'd0))
      mem[exp_mem_addr]		<= valid_data;
  end

  always @ (posedge axi_aclk_i or negedge axi_resetn_i) begin
    if (~axi_resetn_i)
      exp_data		<= {DATA_WIDTH{1'b0}};
    else if (cstate_reg == ST_RD_WAIT)
      exp_data		<= mem[exp_mem_addr];
  end

  always @ (posedge axi_aclk_i or negedge axi_resetn_i) begin
    if (~axi_resetn_i)
      exp_addr		<= 32'd0;
    else if (axi_m0_awvalid_reg)
      exp_addr		<= {addr[31:3], 3'b00};
  end

  assign exp_mem_addr = exp_addr[31:2];

// ----------------------------
// State-Machine
// ----------------------------
  always @ (posedge axi_aclk_i or negedge axi_resetn_i) begin
    if (~axi_resetn_i)	cstate_reg	<= ST_IDLE;
    else				cstate_reg	<= nstate_reg;
  end

  always @ (*) begin
    nstate_reg			= cstate_reg;
    case (cstate_reg)
      ST_IDLE: begin
        if (~done_o)
          nstate_reg		= ST_AW_ADDR;
      end
      ST_AW_ADDR: begin
        if (axi_m0_awvalid_reg && axi_m0_awready_i)
          nstate_reg		= ST_AW_DATA;
      end
      ST_AW_DATA: begin
        if (axi_m0_wvalid_reg && axi_m0_wready_i)
          nstate_reg		= ST_BR_WAIT;
      end
      ST_BR_WAIT: begin
        if (axi_m0_bvalid_i && axi_m0_bready_reg)
          nstate_reg		= ST_BR_OKAY;
      end
      ST_BR_OKAY: begin
          nstate_reg		= ST_AR_ADDR;
      end
      ST_AR_ADDR: begin
        if (axi_m0_arvalid_reg)
          nstate_reg		= ST_RD_WAIT;
      end
      ST_RD_WAIT: begin
        if (axi_m0_rlast_i && axi_m0_rvalid_i && axi_m0_rready_o)
          nstate_reg		= ST_RD_OKAY;
      end
      ST_RD_OKAY: begin
          nstate_reg		= ST_IDLE;
      end
    endcase
  end

// ----------------------------
// Main Logic
// ----------------------------
  always @ (posedge axi_aclk_i or negedge axi_resetn_i)
    if (~axi_resetn_i)
      axi_m0_awvalid_reg	<= 1'b0;
    else if (axi_m0_awready_i && axi_m0_awvalid_reg)
      axi_m0_awvalid_reg	<= 1'b0;
    else if ((cstate_reg == ST_AW_ADDR) && ~axi_m0_awvalid_reg)
      axi_m0_awvalid_reg	<= 1'b1;

  always @ (posedge axi_aclk_i or negedge axi_resetn_i)
    if (~axi_resetn_i)
      axi_m0_wvalid_reg		<= 1'b0;
    else if (axi_m0_wready_i && axi_m0_wvalid_reg)
      axi_m0_wvalid_reg		<= 1'b0;
    else if ((cstate_reg == ST_AW_DATA) && ~axi_m0_wvalid_reg)
      axi_m0_wvalid_reg		<= 1'b1;

  always @ (posedge axi_aclk_i or negedge axi_resetn_i)
    if (~axi_resetn_i)
      axi_m0_bready_reg		<= 1'b0;
    else if (cstate_reg == ST_BR_WAIT)
      axi_m0_bready_reg		<= 1'b1;
    else
      axi_m0_bready_reg		<= 1'b0;

  always @ (posedge axi_aclk_i or negedge axi_resetn_i)
    if (~axi_resetn_i)
      axi_m0_arvalid_reg	<= 1'b0;
    else if (axi_m0_arready_i && axi_m0_arvalid_reg)
      axi_m0_arvalid_reg	<= 1'b0;
    else if ((cstate_reg == ST_AR_ADDR) && ~axi_m0_arvalid_reg)
      axi_m0_arvalid_reg	<= 1'b1;

  always @ (posedge axi_aclk_i or negedge axi_resetn_i)
    if (~axi_resetn_i)
      axi_m0_rready_reg		<= 1'b0;
    else if ((cstate_reg == ST_RD_WAIT) && (axi_m0_rready_dly_cnt >= P_RREADY_DLY))
      axi_m0_rready_reg		<= 1'b1;
    else
      axi_m0_rready_reg		<= 1'b0;

    always @ (posedge axi_aclk_i or negedge axi_resetn_i)
    if (~axi_resetn_i)
      axi_m0_rready_dly_cnt <= 32'd0;
    else if (cstate_reg == ST_RD_OKAY)
      axi_m0_rready_dly_cnt <= 32'd0;
    else if (axi_m0_rready_dly_cnt >= P_RREADY_DLY)
      axi_m0_rready_dly_cnt <= axi_m0_rready_dly_cnt;
    else if (cstate_reg == ST_RD_WAIT)
      axi_m0_rready_dly_cnt <= axi_m0_rready_dly_cnt + 32'd1;

// ----------------------------
// AXI4 Outputs
// ----------------------------
assign axi_m0_awid_o    = {ID_WIDTH{1'b0}};
assign axi_m0_awaddr_o  = {addr[31:3], 3'b00};
assign axi_m0_awlen_o   = 8'd0;
assign axi_m0_awsize_o  = (DATA_WIDTH == 8)? 0 : (DATA_WIDTH == 16)? 1 : (DATA_WIDTH == 16)?2:3;
assign axi_m0_awburst_o = 2'd1;
assign axi_m0_awvalid_o = axi_m0_awvalid_reg;

assign axi_m0_wdata_o   = data[DATA_WIDTH-1:0];
assign axi_m0_wstrb_o   = {(DATA_WIDTH/8){1'b1}};
assign axi_m0_wlast_o   = 1'b1;
assign axi_m0_wvalid_o  = axi_m0_wvalid_reg;

assign axi_m0_bready_o  = axi_m0_bready_reg;

assign axi_m0_arid_o    = {ID_WIDTH{1'b0}};
assign axi_m0_araddr_o  = exp_addr;
assign axi_m0_arlen_o   = 8'd0;
assign axi_m0_arsize_o  = (DATA_WIDTH == 8)? 0 : (DATA_WIDTH == 16)? 1 : (DATA_WIDTH == 32)? 2:3;
assign axi_m0_arburst_o = 2'd1;
assign axi_m0_arvalid_o = axi_m0_arvalid_reg;

assign axi_m0_rready_o  = axi_m0_rready_reg;

// ----------------------------
// Number of Complete Write-Read Loops
// ----------------------------
  always @ (posedge axi_aclk_i or negedge axi_resetn_i)
    if (~axi_resetn_i)
      done_reg		<= 32'd0;
    else if (cstate_reg == ST_RD_OKAY)
      done_reg		<= done_reg + 32'd1;

assign done_o           = (done_reg >= TARGET_COUNTER);
assign safe_count_o     = 10000;

// ----------------------------
// Data Checker
// ----------------------------
  always @ (posedge axi_aclk_i or negedge axi_resetn_i) begin
    if (~axi_resetn_i)
      data_chk		<= 1'b0;
    else if (axi_m0_rresp_i != 2'd0)
      data_chk		<= 1'b0;
    else if (axi_m0_rvalid_i && axi_m0_rready_o) begin
      if (exp_data != axi_m0_rdata_i)
        data_chk	<= 1'b1;
      else
        data_chk	<= 1'b0;
    end
    else
      data_chk		<= 1'b0;
  end

assign axi_m0_data_chk = data_chk;

endmodule
`endif
