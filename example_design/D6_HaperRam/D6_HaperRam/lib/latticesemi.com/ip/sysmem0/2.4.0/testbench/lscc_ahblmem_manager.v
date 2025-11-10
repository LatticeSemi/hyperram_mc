`ifndef LSCC_AHBLMEM_MANAGER
`define LSCC_AHBLMEM_MANAGER

module lscc_ahblmem_manager # (
    parameter       ADDR_DEPTH                = 16384,
    parameter       DATA_WIDTH                = 32,
    parameter       MEMORY_TYPE               = "EBR",
    parameter       PORT_COUNT                = 2,
    parameter       ECC_ENABLE                = 0,
    parameter       REGMODE_S0                = "reg",
    parameter       REGMODE_S1                = "noreg",
    parameter       RESET_MODE_S0             = "async",
    parameter       RESET_MODE_S1             = "async",
    parameter       BYTE_ENABLE_S0            = 0,
    parameter       BYTE_ENABLE_S1            = 0,
    parameter       S0_START_ADDR             = 0,
    parameter       S1_START_ADDR             = 0,
    parameter       S0_END_ADDR               = ADDR_DEPTH-1,
    parameter       S1_END_ADDR               = ADDR_DEPTH-1,
    parameter       ACCESS_TYPE_S0            = "R/W",
    parameter       ACCESS_TYPE_S1            = "R/W",
    parameter       UNALIGNED_ACCESS_EN_S0    = 0,
    parameter       UNALIGNED_ACCESS_EN_S1    = 0,
    parameter       SHIFT_DIRECTION_S0        = "none",
    parameter       SHIFT_DIRECTION_S1        = "none",
    parameter       TARGET_COUNTER            = 20,
    parameter       CNTR_OVERRIDE             = 0,
    parameter       INIT_FILE                 = "none",
    parameter       INIT_FILE_FORMAT          = "hex"
)(
// ----------------------------
// Common Signals
// ----------------------------
    input                   ahbl_hclk_i,
    input                   ahbl_hresetn_i,
    input                   fifo_hold_i,
// ----------------------------
// AHB-Lite Manager Interface 0
// ----------------------------
    input                   ahbl_s0_hreadyout_i,
    input                   ahbl_s0_hresp_i,
    input [DATA_WIDTH-1:0]  ahbl_s0_hrdata_i,

    output                  ahbl_s0_hsel_o,
    output                  ahbl_s0_hready_o,
    output [31:0]           ahbl_s0_haddr_o,
    output [2:0]            ahbl_s0_hburst_o,
    output [2:0]            ahbl_s0_hsize_o,
    output                  ahbl_s0_hmastlock_o,
    output [3:0]            ahbl_s0_hprot_o,
    output [1:0]            ahbl_s0_htrans_o,
    output                  ahbl_s0_hwrite_o,
    output [DATA_WIDTH-1:0] ahbl_s0_hwdata_o,
// ----------------------------
// AHB-Lite Subordinate Interface 1
// ----------------------------
    input                   ahbl_s1_hreadyout_i,
    input                   ahbl_s1_hresp_i,
    input [DATA_WIDTH-1:0]  ahbl_s1_hrdata_i,

    output                  ahbl_s1_hsel_o,
    output                  ahbl_s1_hready_o,
    output [31:0]           ahbl_s1_haddr_o,
    output [2:0]            ahbl_s1_hburst_o,
    output [2:0]            ahbl_s1_hsize_o,
    output                  ahbl_s1_hmastlock_o,
    output [3:0]            ahbl_s1_hprot_o,
    output [1:0]            ahbl_s1_htrans_o,
    output                  ahbl_s1_hwrite_o,
    output [DATA_WIDTH-1:0] ahbl_s1_hwdata_o,

// ----------------------------
// State
// ----------------------------
    output [7:0]            mstr_state_o,
    output                  done_o,
    output [31:0]           safe_count_o
);

// ------------------------------------------------------------------------------
// Local Parameters
// ------------------------------------------------------------------------------

localparam      ADDR_WIDTH                 = clog2(ADDR_DEPTH);
                                          
localparam      SM_SIZE                    = 8;
                                           
localparam      SM_C_START                 = 8'h01;
                                           
localparam      SM_I_READ32_PS0_INIT       = 8'h02;
localparam      SM_I_READ32_PS0_EXEC       = 8'h03;
localparam      SM_I_READ32_PS0_HOLD       = 8'h04;
localparam      SM_I_READ16_PS0_INIT       = 8'h05;
localparam      SM_I_READ16_PS0_EXEC       = 8'h06;
localparam      SM_I_READ16_PS0_HOLD       = 8'h07;
localparam      SM_I_READ8_PS0_INIT        = 8'h08;
localparam      SM_I_READ8_PS0_EXEC        = 8'h09;
localparam      SM_I_READ8_PS0_HOLD        = 8'h0A;
                                           
localparam      SM_I_READ32_PS1_INIT       = 8'h0B;
localparam      SM_I_READ32_PS1_EXEC       = 8'h0C;
localparam      SM_I_READ32_PS1_HOLD       = 8'h0D;
localparam      SM_I_READ16_PS1_INIT       = 8'h0E;
localparam      SM_I_READ16_PS1_EXEC       = 8'h0F;
localparam      SM_I_READ16_PS1_HOLD       = 8'h10;
localparam      SM_I_READ8_PS1_INIT        = 8'h11;
localparam      SM_I_READ8_PS1_EXEC        = 8'h12;
localparam      SM_I_READ8_PS1_HOLD        = 8'h13;
                                           
localparam      SM_N_WRITE32_PS0_INIT      = 8'h14;
localparam      SM_N_WRITE32_PS0_EXEC      = 8'h15;
localparam      SM_N_WRITE32_PS0_HOLD      = 8'h16;
localparam      SM_N_READ32_PS0_INIT       = 8'h17;
localparam      SM_N_READ32_PS0_EXEC       = 8'h18;
localparam      SM_N_READ32_PS0_HOLD       = 8'h19;
localparam      SM_N_READ32_PS01x_INIT     = 8'h1A;
localparam      SM_N_READ32_PS01x_EXEC     = 8'h1B;
localparam      SM_N_READ32_PS01x_HOLD     = 8'h1C;
localparam      SM_N_WRITE16_PS0_INIT      = 8'h1D;
localparam      SM_N_WRITE16_PS0_EXEC      = 8'h1E;
localparam      SM_N_WRITE16_PS0_HOLD      = 8'h1F;
localparam      SM_N_READ16_PS0_INIT       = 8'h20;
localparam      SM_N_READ16_PS0_EXEC       = 8'h21;
localparam      SM_N_READ16_PS0_HOLD       = 8'h22;
localparam      SM_N_READ16_PS01x_INIT     = 8'h23;
localparam      SM_N_READ16_PS01x_EXEC     = 8'h24;
localparam      SM_N_READ16_PS01x_HOLD     = 8'h25;
localparam      SM_N_WRITE8_PS0_INIT       = 8'h26;
localparam      SM_N_WRITE8_PS0_EXEC       = 8'h27;
localparam      SM_N_WRITE8_PS0_HOLD       = 8'h28;
localparam      SM_N_READ8_PS0_INIT        = 8'h29;
localparam      SM_N_READ8_PS0_EXEC        = 8'h2A;
localparam      SM_N_READ8_PS0_HOLD        = 8'h2B;
localparam      SM_N_READ8_PS01x_INIT      = 8'h2C;
localparam      SM_N_READ8_PS01x_EXEC      = 8'h2D;
localparam      SM_N_READ8_PS01x_HOLD      = 8'h2E;
                                                 
localparam      SM_N_WRITE32_PS1_INIT      = 8'h2F;
localparam      SM_N_WRITE32_PS1_EXEC      = 8'h30;
localparam      SM_N_WRITE32_PS1_HOLD      = 8'h31;
localparam      SM_N_READ32_PS1_INIT       = 8'h32;
localparam      SM_N_READ32_PS1_EXEC       = 8'h33;
localparam      SM_N_READ32_PS1_HOLD       = 8'h34;
localparam      SM_N_READ32_PS10x_INIT     = 8'h35;
localparam      SM_N_READ32_PS10x_EXEC     = 8'h36;
localparam      SM_N_READ32_PS10x_HOLD     = 8'h37;
localparam      SM_N_WRITE16_PS1_INIT      = 8'h38;
localparam      SM_N_WRITE16_PS1_EXEC      = 8'h39;
localparam      SM_N_WRITE16_PS1_HOLD      = 8'h3A;
localparam      SM_N_READ16_PS1_INIT       = 8'h3B;
localparam      SM_N_READ16_PS1_EXEC       = 8'h3C;
localparam      SM_N_READ16_PS1_HOLD       = 8'h3D;
localparam      SM_N_READ16_PS10x_INIT     = 8'h3E;
localparam      SM_N_READ16_PS10x_EXEC     = 8'h3F;
localparam      SM_N_READ16_PS10x_HOLD     = 8'h40;
localparam      SM_N_WRITE8_PS1_INIT       = 8'h41;
localparam      SM_N_WRITE8_PS1_EXEC       = 8'h42;
localparam      SM_N_WRITE8_PS1_HOLD       = 8'h43;
localparam      SM_N_READ8_PS1_INIT        = 8'h44;
localparam      SM_N_READ8_PS1_EXEC        = 8'h45;
localparam      SM_N_READ8_PS1_HOLD        = 8'h46;
localparam      SM_N_READ8_PS10x_INIT      = 8'h47;
localparam      SM_N_READ8_PS10x_EXEC      = 8'h48;
localparam      SM_N_READ8_PS10x_HOLD      = 8'h49;
                                           
localparam      SM_N_WR_TO_READ_PS0_INIT   = 8'h4A;
localparam      SM_N_WR_TO_READ_PS0_WRITE  = 8'h4B;
localparam      SM_N_WR_TO_READ_PS0_READ   = 8'h4C;
localparam      SM_N_WR_TO_READ_PS0_HOLD   = 8'h4D;

localparam      SM_N_WR_TO_READ_PS1_INIT   = 8'h4E;
localparam      SM_N_WR_TO_READ_PS1_WRITE  = 8'h4F;
localparam      SM_N_WR_TO_READ_PS1_READ   = 8'h50;
localparam      SM_N_WR_TO_READ_PS1_HOLD   = 8'h51;

localparam      SM_S_WRITE32_PS0_INIT      = 8'h52;
localparam      SM_S_WRITE32_PS0_EXEC      = 8'h53;
localparam      SM_S_WRITE32_PS0_HOLD      = 8'h54;
localparam      SM_S_READ32_PS0_INIT       = 8'h55;
localparam      SM_S_READ32_PS0_EXEC       = 8'h56;
localparam      SM_S_READ32_PS0_HOLD       = 8'h57;
localparam      SM_S_READ32_PS01x_INIT     = 8'h58;
localparam      SM_S_READ32_PS01x_EXEC     = 8'h59;
localparam      SM_S_READ32_PS01x_HOLD     = 8'h5A;
localparam      SM_S_WRITE16_PS0_INIT      = 8'h5B;
localparam      SM_S_WRITE16_PS0_EXEC      = 8'h5C;
localparam      SM_S_WRITE16_PS0_HOLD      = 8'h5D;
localparam      SM_S_READ16_PS0_INIT       = 8'h5E;
localparam      SM_S_READ16_PS0_EXEC       = 8'h5F;
localparam      SM_S_READ16_PS0_HOLD       = 8'h60;
localparam      SM_S_READ16_PS01x_INIT     = 8'h61;
localparam      SM_S_READ16_PS01x_EXEC     = 8'h62;
localparam      SM_S_READ16_PS01x_HOLD     = 8'h63;
localparam      SM_S_WRITE8_PS0_INIT       = 8'h64;
localparam      SM_S_WRITE8_PS0_EXEC       = 8'h65;
localparam      SM_S_WRITE8_PS0_HOLD       = 8'h66;
localparam      SM_S_READ8_PS0_INIT        = 8'h67;
localparam      SM_S_READ8_PS0_EXEC        = 8'h68;
localparam      SM_S_READ8_PS0_HOLD        = 8'h69;
localparam      SM_S_READ8_PS01x_INIT      = 8'h6A;
localparam      SM_S_READ8_PS01x_EXEC      = 8'h6B;
localparam      SM_S_READ8_PS01x_HOLD      = 8'h6C;

localparam      SM_S_WRITE32_PS1_INIT      = 8'h6D;
localparam      SM_S_WRITE32_PS1_EXEC      = 8'h6E;
localparam      SM_S_WRITE32_PS1_HOLD      = 8'h6F;
localparam      SM_S_READ32_PS1_INIT       = 8'h70;
localparam      SM_S_READ32_PS1_EXEC       = 8'h71;
localparam      SM_S_READ32_PS1_HOLD       = 8'h72;
localparam      SM_S_READ32_PS10x_INIT     = 8'h73;
localparam      SM_S_READ32_PS10x_EXEC     = 8'h74;
localparam      SM_S_READ32_PS10x_HOLD     = 8'h75;
localparam      SM_S_WRITE16_PS1_INIT      = 8'h76;
localparam      SM_S_WRITE16_PS1_EXEC      = 8'h77;
localparam      SM_S_WRITE16_PS1_HOLD      = 8'h78;
localparam      SM_S_READ16_PS1_INIT       = 8'h79;
localparam      SM_S_READ16_PS1_EXEC       = 8'h7A;
localparam      SM_S_READ16_PS1_HOLD       = 8'h7B;
localparam      SM_S_READ16_PS10x_INIT     = 8'h7C;
localparam      SM_S_READ16_PS10x_EXEC     = 8'h7D;
localparam      SM_S_READ16_PS10x_HOLD     = 8'h7E;
localparam      SM_S_WRITE8_PS1_INIT       = 8'h7F;
localparam      SM_S_WRITE8_PS1_EXEC       = 8'h80;
localparam      SM_S_WRITE8_PS1_HOLD       = 8'h81;
localparam      SM_S_READ8_PS1_INIT        = 8'h82;
localparam      SM_S_READ8_PS1_EXEC        = 8'h83;
localparam      SM_S_READ8_PS1_HOLD        = 8'h84;
localparam      SM_S_READ8_PS10x_INIT      = 8'h85;
localparam      SM_S_READ8_PS10x_EXEC      = 8'h86;
localparam      SM_S_READ8_PS10x_HOLD      = 8'h87;

localparam      SM_C_END                   = 8'h88;
localparam      SM_C_ERROR                 = 8'hFF;

// HBURST commands                                  
localparam      SINGLE            = 3'b000;
localparam      INCR              = 3'b001;
localparam      WRAP4             = 3'b010;
localparam      INCR4             = 3'b011;
localparam      WRAP8             = 3'b100;
localparam      INCR8             = 3'b101;
localparam      WRAP16            = 3'b110;
localparam      INCR16            = 3'b111;
// HTRANS commands           
localparam      IDLE              = 2'b00;
localparam      BUSY              = 2'b01;
localparam      NSEQ              = 2'b10;
localparam      SEQ               = 2'b11;
// ADDR offset          
localparam      ADDR_32_OFF       = 3'b100;
localparam      ADDR_16_OFF       = 3'b010;
localparam      ADDR_8_OFF        = 3'b001;
// HSIZE transactions           
localparam      X32_WORD          = 3'b010;
localparam      X16_HALFWORD      = 3'b001;
localparam      X8_BYTE           = 3'b000;
// HWRITE transactions           
localparam      HWRITE            = 1'b1;
localparam      HREAD             = 1'b0;

localparam      READ32_LIMIT_S0   = (CNTR_OVERRIDE == 1) ? TARGET_COUNTER : (S0_END_ADDR-S0_START_ADDR)/4;
localparam      WRITE32_LIMIT_S0  = (CNTR_OVERRIDE == 1) ? TARGET_COUNTER : (S0_END_ADDR-S0_START_ADDR)/4;
localparam      READ16_LIMIT_S0   = (CNTR_OVERRIDE == 1) ? TARGET_COUNTER : (S0_END_ADDR-S0_START_ADDR)/2;
localparam      WRITE16_LIMIT_S0  = (CNTR_OVERRIDE == 1) ? TARGET_COUNTER : (S0_END_ADDR-S0_START_ADDR)/2;
localparam      READ8_LIMIT_S0    = (CNTR_OVERRIDE == 1) ? TARGET_COUNTER : (S0_END_ADDR-S0_START_ADDR);
localparam      WRITE8_LIMIT_S0   = (CNTR_OVERRIDE == 1) ? TARGET_COUNTER : (S0_END_ADDR-S0_START_ADDR);

localparam      READ32_LIMIT_S1   = (CNTR_OVERRIDE == 1) ? TARGET_COUNTER : (S1_END_ADDR-S1_START_ADDR)/4;
localparam      WRITE32_LIMIT_S1  = (CNTR_OVERRIDE == 1) ? TARGET_COUNTER : (S1_END_ADDR-S1_START_ADDR)/4;
localparam      READ16_LIMIT_S1   = (CNTR_OVERRIDE == 1) ? TARGET_COUNTER : (S1_END_ADDR-S1_START_ADDR)/2;
localparam      WRITE16_LIMIT_S1  = (CNTR_OVERRIDE == 1) ? TARGET_COUNTER : (S1_END_ADDR-S1_START_ADDR)/2;
localparam      READ8_LIMIT_S1    = (CNTR_OVERRIDE == 1) ? TARGET_COUNTER : (S1_END_ADDR-S1_START_ADDR);
localparam      WRITE8_LIMIT_S1   = (CNTR_OVERRIDE == 1) ? TARGET_COUNTER : (S1_END_ADDR-S1_START_ADDR);

localparam      S0_READ_EN        = (ACCESS_TYPE_S0 == "R/O" || ACCESS_TYPE_S0 == "R/W") ? 1'b1 : 1'b0;
localparam      S0_WRITE_EN       = (ACCESS_TYPE_S0 == "W/O" || ACCESS_TYPE_S0 == "R/W") ? 1'b1 : 1'b0;
localparam      S1_READ_EN        = (ACCESS_TYPE_S1 == "R/O" || ACCESS_TYPE_S1 == "R/W") ? 1'b1 : 1'b0;
localparam      S1_WRITE_EN       = (ACCESS_TYPE_S1 == "W/O" || ACCESS_TYPE_S1 == "R/W") ? 1'b1 : 1'b0;

localparam      W32_S0_COUNT      = WRITE32_LIMIT_S0 + WRITE16_LIMIT_S0 + WRITE8_LIMIT_S0;
localparam      W16_S0_COOUNT     = WRITE16_LIMIT_S0 + WRITE8_LIMIT_S0;
localparam      R32_S0_COUNT      = READ32_LIMIT_S0 + READ16_LIMIT_S0 + READ8_LIMIT_S0;
localparam      R16_S0_COUNT      = READ16_LIMIT_S0 + READ8_LIMIT_S0;

localparam      WR_S0_TOT_COUNT   = S0_WRITE_EN == 1 ? (DATA_WIDTH == 32 ? (BYTE_ENABLE_S0 == 1 ? W32_S0_COUNT : WRITE32_LIMIT_S0) :
                                                        DATA_WIDTH == 16 ? (BYTE_ENABLE_S0 == 1 ? W16_S0_COOUNT : WRITE16_LIMIT_S0) :
                                                        WRITE8_LIMIT_S0) : 0;
localparam      RD_S0_TOT_COUNT   = S0_READ_EN  == 1 ? (DATA_WIDTH == 32 ? R32_S0_COUNT :
                                                        DATA_WIDTH == 16 ? R16_S0_COUNT :
                                                        READ8_LIMIT_S0) : 0;

localparam      W32_S1_COUNT      = WRITE32_LIMIT_S1 + WRITE16_LIMIT_S1 + WRITE8_LIMIT_S1;
localparam      W16_S1_COOUNT     = WRITE16_LIMIT_S1 + WRITE8_LIMIT_S1;
localparam      R32_S1_COUNT      = READ32_LIMIT_S1 + READ16_LIMIT_S1 + READ8_LIMIT_S1;
localparam      R16_S1_COUNT      = READ16_LIMIT_S1 + READ8_LIMIT_S1;

localparam      WR_S1_TOT_COUNT   = S1_WRITE_EN == 1 ? (DATA_WIDTH == 32 ? (BYTE_ENABLE_S1 == 1 ? W32_S1_COUNT : WRITE32_LIMIT_S1) :
                                                        DATA_WIDTH == 16 ? (BYTE_ENABLE_S1 == 1 ? W16_S1_COOUNT : WRITE16_LIMIT_S1) :
                                                        WRITE8_LIMIT_S1) : 0;
localparam      RD_S1_TOT_COUNT   = S1_READ_EN  == 1 ? (DATA_WIDTH == 32 ? R32_S1_COUNT :
                                                        DATA_WIDTH == 16 ? R16_S1_COUNT :
                                                        READ8_LIMIT_S1) : 0;

localparam      S0_TOTAL_COUNT    = (ACCESS_TYPE_S0 == "R/W") ? 5*(WR_S0_TOT_COUNT + RD_S0_TOT_COUNT) :
                                    (ACCESS_TYPE_S0 == "R/O") ? 4*RD_S0_TOT_COUNT : 4*WR_S0_TOT_COUNT;

localparam      S1_TOTAL_COUNT    = (ACCESS_TYPE_S1 == "R/W") ? 5*(WR_S1_TOT_COUNT + RD_S1_TOT_COUNT) :
                                    (ACCESS_TYPE_S1 == "R/O") ? 4*RD_S1_TOT_COUNT : 4*WR_S1_TOT_COUNT;

localparam      SAFE_COUNT        = 4*(S0_TOTAL_COUNT + S1_TOTAL_COUNT);

localparam      WR2RD_LIMIT_S0    = (S0_READ_EN & S0_WRITE_EN) ? ((DATA_WIDTH == 32) ? ((WRITE32_LIMIT_S0 < READ32_LIMIT_S0) ? WRITE32_LIMIT_S0 : 
                                                                                                                               READ32_LIMIT_S0) :
                                                                  (DATA_WIDTH == 16) ? ((WRITE16_LIMIT_S0 < READ16_LIMIT_S0) ? WRITE16_LIMIT_S0 : 
                                                                                                                               READ16_LIMIT_S0) :
                                                                  (DATA_WIDTH == 8) ? ((WRITE8_LIMIT_S0 < READ8_LIMIT_S0) ? WRITE8_LIMIT_S0 : 
                                                                                                                            READ8_LIMIT_S0) :
                                                                  0) : 0;
localparam      WR2RD_LIMIT_S1    = (S1_READ_EN & S1_WRITE_EN) ? ((DATA_WIDTH == 32) ? ((WRITE32_LIMIT_S1 < READ32_LIMIT_S1) ? WRITE32_LIMIT_S1 : 
                                                                                                                               READ32_LIMIT_S1) :
                                                                  (DATA_WIDTH == 16) ? ((WRITE16_LIMIT_S1 < READ16_LIMIT_S1) ? WRITE16_LIMIT_S1 : 
                                                                                                                               READ16_LIMIT_S1) :
                                                                  (DATA_WIDTH == 8) ? ((WRITE8_LIMIT_S1 < READ8_LIMIT_S1) ? WRITE8_LIMIT_S1 : 
                                                                                                                            READ8_LIMIT_S1) :
                                                                  0) : 0;
localparam      WR2RD_INC_S0      = (DATA_WIDTH == 32) ? ADDR_32_OFF :
                                    (DATA_WIDTH == 16) ? ADDR_16_OFF : ADDR_8_OFF;
localparam      WR2RD_INC_S1      = (DATA_WIDTH == 32) ? ADDR_32_OFF :
                                    (DATA_WIDTH == 16) ? ADDR_16_OFF : ADDR_8_OFF;
localparam      DEFAULT_HSIZE     = (DATA_WIDTH == 32) ? X32_WORD :
                                    (DATA_WIDTH == 16) ? X16_HALFWORD : X8_BYTE;

localparam      S0_START_ADDR_FIN = {32{1'b0}};
localparam      S1_START_ADDR_FIN = {32{1'b0}};

reg [SM_SIZE-1:0]    mstr_state_r         = SM_C_START;
reg [SM_SIZE-1:0]    mstr_state_nxt_c     = SM_C_START;
reg [31:0]           sys_cntr_r           = {32{1'b0}};
reg [31:0]           sys_cntr_nxt_c       = {32{1'b0}};

assign               mstr_state_o         = mstr_state_r;
assign               done_o               = (mstr_state_r == SM_C_END || mstr_state_r ==  SM_C_ERROR);

reg                  ahbl_s0_hsel_r       = 1'b0;
reg                  ahbl_s0_hready_r     = 1'b1;
reg [31:0]           ahbl_s0_haddr_r      = {32{1'b0}};
reg [2:0]            ahbl_s0_hburst_r     = INCR;
reg [2:0]            ahbl_s0_hsize_r      = DEFAULT_HSIZE;
reg                  ahbl_s0_hmastlock_r  = 1'b0;
reg [3:0]            ahbl_s0_hprot_r      = 1'b0;
reg [1:0]            ahbl_s0_htrans_r     = IDLE;
reg                  ahbl_s0_hwrite_r     = 1'b0;
reg [DATA_WIDTH-1:0] ahbl_s0_hwdata_r     = {DATA_WIDTH{1'b0}};

reg                  ahbl_s0_hsel_nxt_c       = 1'b0;
reg                  ahbl_s0_hready_nxt_c     = 1'b1;
reg [31:0]           ahbl_s0_haddr_nxt_c      = {32{1'b0}};
reg [2:0]            ahbl_s0_hburst_nxt_c     = INCR;
reg [2:0]            ahbl_s0_hsize_nxt_c      = DEFAULT_HSIZE;
reg                  ahbl_s0_hmastlock_nxt_c  = 1'b0;
reg [3:0]            ahbl_s0_hprot_nxt_c      = 1'b0;
reg [1:0]            ahbl_s0_htrans_nxt_c     = IDLE;
reg                  ahbl_s0_hwrite_nxt_c     = 1'b0;
reg [DATA_WIDTH-1:0] ahbl_s0_hwdata_nxt_c     = {DATA_WIDTH{1'b0}};

assign               ahbl_s0_hsel_o      = ahbl_s0_hsel_r;
assign               ahbl_s0_hready_o    = ahbl_s0_hready_r;
assign               ahbl_s0_haddr_o     = ahbl_s0_haddr_r;
assign               ahbl_s0_hburst_o    = ahbl_s0_hburst_r;
assign               ahbl_s0_hsize_o     = ahbl_s0_hsize_r;
assign               ahbl_s0_hmastlock_o = ahbl_s0_hmastlock_r;
assign               ahbl_s0_hprot_o     = ahbl_s0_hprot_r;
assign               ahbl_s0_htrans_o    = ahbl_s0_htrans_r;
assign               ahbl_s0_hwrite_o    = ahbl_s0_hwrite_r;
assign               ahbl_s0_hwdata_o    = ahbl_s0_hwdata_r;

reg                  ahbl_s1_hsel_r       = 1'b0;
reg                  ahbl_s1_hready_r     = 1'b1;
reg [31:0]           ahbl_s1_haddr_r      = {32{1'b0}};
reg [2:0]            ahbl_s1_hburst_r     = INCR;
reg [2:0]            ahbl_s1_hsize_r      = DEFAULT_HSIZE;
reg                  ahbl_s1_hmastlock_r  = 1'b0;
reg [3:0]            ahbl_s1_hprot_r      = 1'b0;
reg [1:0]            ahbl_s1_htrans_r     = IDLE;
reg                  ahbl_s1_hwrite_r     = 1'b0;
reg [DATA_WIDTH-1:0] ahbl_s1_hwdata_r     = {DATA_WIDTH{1'b0}};

reg                  ahbl_s1_hsel_nxt_c       = 1'b0;
reg                  ahbl_s1_hready_nxt_c     = 1'b1;
reg [31:0]           ahbl_s1_haddr_nxt_c      = {32{1'b0}};
reg [2:0]            ahbl_s1_hburst_nxt_c     = INCR;
reg [2:0]            ahbl_s1_hsize_nxt_c      = DEFAULT_HSIZE;
reg                  ahbl_s1_hmastlock_nxt_c  = 1'b0;
reg [3:0]            ahbl_s1_hprot_nxt_c      = 1'b0;
reg [1:0]            ahbl_s1_htrans_nxt_c     = IDLE;
reg                  ahbl_s1_hwrite_nxt_c     = 1'b0;
reg [DATA_WIDTH-1:0] ahbl_s1_hwdata_nxt_c     = {DATA_WIDTH{1'b0}};

wire ahbl_s1_hready_w = (PORT_COUNT == 2) ? ahbl_s1_hreadyout_i : 1'b1;

assign               ahbl_s1_hsel_o      = ahbl_s1_hsel_r;
assign               ahbl_s1_hready_o    = ahbl_s1_hready_r;
assign               ahbl_s1_haddr_o     = ahbl_s1_haddr_r;
assign               ahbl_s1_hburst_o    = ahbl_s1_hburst_r;
assign               ahbl_s1_hsize_o     = ahbl_s1_hsize_r;
assign               ahbl_s1_hmastlock_o = ahbl_s1_hmastlock_r;
assign               ahbl_s1_hprot_o     = ahbl_s1_hprot_r;
assign               ahbl_s1_htrans_o    = ahbl_s1_htrans_r;
assign               ahbl_s1_hwrite_o    = ahbl_s1_hwrite_r;
assign               ahbl_s1_hwdata_o    = ahbl_s1_hwdata_r;

assign               safe_count_o        = SAFE_COUNT;

reg [31:0] mem_s0 [2**ADDR_WIDTH-1:0];
reg [31:0] mem_s0_16 [2**ADDR_WIDTH-1:0];
reg [31:0] mem_s0_8 [2**ADDR_WIDTH-1:0];

reg [31:0] mem_s1 [2**ADDR_WIDTH-1:0];
reg [31:0] mem_s1_16 [2**ADDR_WIDTH-1:0];
reg [31:0] mem_s1_8 [2**ADDR_WIDTH-1:0];

integer i0;
initial begin
    for(i0 = 0; i0 < (2**(ADDR_WIDTH)); i0 = i0 + 1) begin
        mem_s0[i0] = $urandom_range({32{1'b0}},{32{1'b1}});
        mem_s0_16[i0] = $urandom_range({32{1'b0}},{32{1'b1}});
        mem_s0_8[i0] = $urandom_range({32{1'b0}},{32{1'b1}});
        mem_s1[i0] = $urandom_range({32{1'b0}},{32{1'b1}});
        mem_s1_16[i0] = $urandom_range({32{1'b0}},{32{1'b1}});
        mem_s1_8[i0] = $urandom_range({32{1'b0}},{32{1'b1}});
    end
end

always @ (*) begin
    mstr_state_nxt_c = mstr_state_r;
    sys_cntr_nxt_c = sys_cntr_r;
    if(ahbl_s0_hreadyout_i == 1'b1 && ahbl_s1_hready_w == 1'b1 && ~fifo_hold_i) begin
        case(mstr_state_r)
            // -----------------
            // ----- START -----
            // -----------------
            SM_C_START: begin 
                if(INIT_FILE != "none") begin
                    if(S0_READ_EN) begin
                        case(DATA_WIDTH)
                            32: mstr_state_nxt_c = SM_I_READ32_PS0_INIT;
                            16: mstr_state_nxt_c = SM_I_READ16_PS0_INIT;
                            8: mstr_state_nxt_c = SM_I_READ8_PS0_INIT;
                        endcase
                    end
                    else begin
                        case(DATA_WIDTH)
                            32: mstr_state_nxt_c = SM_I_READ32_PS1_INIT;
                            16: mstr_state_nxt_c = SM_I_READ16_PS1_INIT;
                            8: mstr_state_nxt_c = SM_I_READ8_PS1_INIT;
                        endcase
                    end
                end
                else begin
                    if(S0_WRITE_EN) begin
                        case(DATA_WIDTH)
                            32: mstr_state_nxt_c = SM_N_WRITE32_PS0_INIT;
                            16: mstr_state_nxt_c = SM_N_WRITE16_PS0_INIT;
                            8: mstr_state_nxt_c = SM_N_WRITE8_PS0_INIT;
                        endcase
                    end
                    else if(S1_WRITE_EN) begin
                        case(DATA_WIDTH)
                            32: mstr_state_nxt_c = SM_N_WRITE32_PS1_INIT;
                            16: mstr_state_nxt_c = SM_N_WRITE16_PS1_INIT;
                            8: mstr_state_nxt_c = SM_N_WRITE8_PS1_INIT;
                        endcase
                    end
                    else begin
                        mstr_state_nxt_c = SM_C_END;
                    end
                end
            end
            // --------------------------------------
            // ----- 32-bit INIT READ (port S0) -----
            // --------------------------------------
            SM_I_READ32_PS0_INIT: begin
                sys_cntr_nxt_c = {32{1'b0}};
                mstr_state_nxt_c = SM_I_READ32_PS0_EXEC;
            end
            SM_I_READ32_PS0_EXEC: begin
                if(sys_cntr_r < READ32_LIMIT_S0) begin
                    mstr_state_nxt_c = SM_I_READ32_PS0_HOLD;
                    sys_cntr_nxt_c = sys_cntr_r + 1'b1;
                end
                else begin
                    mstr_state_nxt_c = SM_I_READ16_PS0_INIT;
                    sys_cntr_nxt_c = {32{1'b0}};
                end
            end
            SM_I_READ32_PS0_HOLD: begin
                mstr_state_nxt_c = SM_I_READ32_PS0_EXEC;
            end
            // --------------------------------------
            // ----- 16-bit INIT READ (port S0) -----
            // --------------------------------------
            SM_I_READ16_PS0_INIT: begin
                sys_cntr_nxt_c = {32{1'b0}};
                mstr_state_nxt_c = SM_I_READ16_PS0_EXEC;
            end
            SM_I_READ16_PS0_EXEC: begin
                if(sys_cntr_r < READ16_LIMIT_S0) begin
                    mstr_state_nxt_c = SM_I_READ16_PS0_HOLD;
                    sys_cntr_nxt_c = sys_cntr_r + 1'b1;
                end
                else begin
                    mstr_state_nxt_c = SM_I_READ8_PS0_INIT;
                    sys_cntr_nxt_c = {32{1'b0}};
                end
            end
            SM_I_READ16_PS0_HOLD: begin
                mstr_state_nxt_c = SM_I_READ16_PS0_EXEC;
            end
            // -------------------------------------
            // ----- 8-bit INIT READ (port S0) -----
            // -------------------------------------
            SM_I_READ8_PS0_INIT: begin
                sys_cntr_nxt_c = {32{1'b0}};
                mstr_state_nxt_c = SM_I_READ8_PS0_EXEC;
            end
            SM_I_READ8_PS0_EXEC: begin
                if(sys_cntr_r < READ8_LIMIT_S0) begin
                    mstr_state_nxt_c = SM_I_READ8_PS0_HOLD;
                    sys_cntr_nxt_c = sys_cntr_r + 1'b1;
                end
                else begin
                    if(S1_READ_EN) begin
                        case(DATA_WIDTH)
                            32: mstr_state_nxt_c = SM_I_READ32_PS1_INIT;
                            16: mstr_state_nxt_c = SM_I_READ16_PS1_INIT;
                            8: mstr_state_nxt_c = SM_I_READ8_PS1_INIT;
                        endcase
                    end
                    else if(S0_WRITE_EN) begin
                        case(DATA_WIDTH)
                            32: mstr_state_nxt_c = SM_N_WRITE32_PS0_INIT;
                            16: mstr_state_nxt_c = SM_N_WRITE16_PS0_INIT;
                            8: mstr_state_nxt_c = SM_N_WRITE8_PS0_INIT;
                        endcase
                    end
                    else if(S1_WRITE_EN) begin
                        case(DATA_WIDTH)
                            32: mstr_state_nxt_c = SM_N_WRITE32_PS1_INIT;
                            16: mstr_state_nxt_c = SM_N_WRITE16_PS1_INIT;
                            8: mstr_state_nxt_c = SM_N_WRITE8_PS1_INIT;
                        endcase
                    end
                    else begin
                        mstr_state_nxt_c = SM_C_END;
                    end
                    sys_cntr_nxt_c = {32{1'b0}};
                end
            end
            SM_I_READ8_PS0_HOLD: begin
                mstr_state_nxt_c = SM_I_READ8_PS0_EXEC;
            end
            // --------------------------------------
            // ----- 32-bit INIT READ (port S1) -----
            // --------------------------------------
            SM_I_READ32_PS1_INIT: begin
                sys_cntr_nxt_c = {32{1'b0}};
                mstr_state_nxt_c = SM_I_READ32_PS1_EXEC;
            end
            SM_I_READ32_PS1_EXEC: begin
                if(sys_cntr_r < READ32_LIMIT_S1) begin
                    mstr_state_nxt_c = SM_I_READ32_PS1_HOLD;
                    sys_cntr_nxt_c = sys_cntr_r + 1'b1;
                end
                else begin
                    mstr_state_nxt_c = SM_I_READ16_PS1_INIT;
                    sys_cntr_nxt_c = {32{1'b0}};
                end
            end
            SM_I_READ32_PS1_HOLD: begin
                mstr_state_nxt_c = SM_I_READ32_PS1_EXEC;
            end
            // --------------------------------------
            // ----- 16-bit INIT READ (port S1) -----
            // --------------------------------------
            SM_I_READ16_PS1_INIT: begin
                sys_cntr_nxt_c = {32{1'b0}};
                mstr_state_nxt_c = SM_I_READ16_PS1_EXEC;
            end
            SM_I_READ16_PS1_EXEC: begin
                if(sys_cntr_r < READ16_LIMIT_S1) begin
                    mstr_state_nxt_c = SM_I_READ16_PS1_HOLD;
                    sys_cntr_nxt_c = sys_cntr_r + 1'b1;
                end
                else begin
                    mstr_state_nxt_c = SM_I_READ8_PS1_INIT;
                    sys_cntr_nxt_c = {32{1'b0}};
                end
            end
            SM_I_READ16_PS1_HOLD: begin
                mstr_state_nxt_c = SM_I_READ16_PS1_EXEC;
            end
            // -------------------------------------
            // ----- 8-bit INIT READ (port S1) -----
            // -------------------------------------
            SM_I_READ8_PS1_INIT: begin
                sys_cntr_nxt_c = {32{1'b0}};
                mstr_state_nxt_c = SM_I_READ8_PS1_EXEC;
            end
            SM_I_READ8_PS1_EXEC: begin
                if(sys_cntr_r < READ8_LIMIT_S1) begin
                    mstr_state_nxt_c = SM_I_READ8_PS1_HOLD;
                    sys_cntr_nxt_c = sys_cntr_r + 1'b1;
                end
                else begin
                    if(S0_WRITE_EN) begin
                        case(DATA_WIDTH)
                            32: mstr_state_nxt_c = SM_N_WRITE32_PS0_INIT;
                            16: mstr_state_nxt_c = SM_N_WRITE16_PS0_INIT;
                            8: mstr_state_nxt_c = SM_N_WRITE8_PS0_INIT;
                        endcase
                    end
                    else if(S1_WRITE_EN) begin
                        case(DATA_WIDTH)
                            32: mstr_state_nxt_c = SM_N_WRITE32_PS1_INIT;
                            16: mstr_state_nxt_c = SM_N_WRITE16_PS1_INIT;
                            8: mstr_state_nxt_c = SM_N_WRITE8_PS1_INIT;
                        endcase
                    end
                    else begin
                        mstr_state_nxt_c = SM_C_END;
                    end
                    sys_cntr_nxt_c = {32{1'b0}};
                end
            end
            SM_I_READ8_PS1_HOLD: begin
                mstr_state_nxt_c = SM_I_READ8_PS1_EXEC;
            end
            // ---------------------------------------
            // ----- 32-bit NSEQ WRITE (port S0) -----
            // ---------------------------------------
            SM_N_WRITE32_PS0_INIT: begin
                sys_cntr_nxt_c = {32{1'b0}};
                mstr_state_nxt_c = SM_N_WRITE32_PS0_EXEC;
            end
            SM_N_WRITE32_PS0_EXEC: begin
                if(sys_cntr_r < WRITE32_LIMIT_S0) begin
                    mstr_state_nxt_c = SM_N_WRITE32_PS0_HOLD;
                    sys_cntr_nxt_c = sys_cntr_r + 1'b1;
                end
                else begin
                    if(S0_READ_EN) begin
                        mstr_state_nxt_c = SM_N_READ32_PS0_INIT;
                    end
                    else begin
                        mstr_state_nxt_c = SM_N_READ32_PS01x_INIT;
                    end
                    sys_cntr_nxt_c = {32{1'b0}};
                end
            end
            SM_N_WRITE32_PS0_HOLD: begin
                mstr_state_nxt_c = SM_N_WRITE32_PS0_EXEC;
            end 
            // --------------------------------------
            // ----- 32-bit NSEQ READ (port S0) -----
            // --------------------------------------
            SM_N_READ32_PS0_INIT: begin
                sys_cntr_nxt_c = {32{1'b0}};
                mstr_state_nxt_c = SM_N_READ32_PS0_EXEC;
            end
            SM_N_READ32_PS0_EXEC: begin
                if(sys_cntr_r < READ32_LIMIT_S0) begin
                    mstr_state_nxt_c = SM_N_READ32_PS0_HOLD;
                    sys_cntr_nxt_c = sys_cntr_r + 1'b1;
                end
                else begin
                    if(S1_READ_EN) begin
                        mstr_state_nxt_c = SM_N_READ32_PS01x_INIT;
                    end
                    else if(BYTE_ENABLE_S0) begin
                        mstr_state_nxt_c = SM_N_WRITE16_PS0_INIT;
                    end
                    else begin
                        mstr_state_nxt_c = SM_N_READ16_PS0_INIT;
                    end
                    sys_cntr_nxt_c = {32{1'b0}};
                end
            end
            SM_N_READ32_PS0_HOLD: begin
                mstr_state_nxt_c = SM_N_READ32_PS0_EXEC;
            end
            // --------------------------------------
            // ----- 32-bit NSEQ READ (port S1) -----
            // --------------------------------------
            SM_N_READ32_PS01x_INIT: begin
                mstr_state_nxt_c = SM_N_READ32_PS01x_EXEC;
                sys_cntr_nxt_c = {32{1'b0}};
            end
            SM_N_READ32_PS01x_EXEC: begin
                if(sys_cntr_r < READ32_LIMIT_S1) begin
                    mstr_state_nxt_c = SM_N_READ32_PS01x_HOLD;
                    sys_cntr_nxt_c = sys_cntr_r + 1'b1;
                end
                else begin
                    if(BYTE_ENABLE_S0) begin
                        mstr_state_nxt_c = SM_N_WRITE16_PS0_INIT;
                    end
                    else if(S0_READ_EN) begin
                        mstr_state_nxt_c = SM_N_READ16_PS0_INIT;
                    end
                    else begin
                        mstr_state_nxt_c = SM_N_READ16_PS01x_INIT;
                    end
                    sys_cntr_nxt_c = {32{1'b0}};
                end
            end
            SM_N_READ32_PS01x_HOLD: begin
                mstr_state_nxt_c = SM_N_READ32_PS01x_EXEC;
            end
            // ---------------------------------------
            // ----- 16-bit NSEQ WRITE (port S0) -----
            // ---------------------------------------
            SM_N_WRITE16_PS0_INIT: begin
                mstr_state_nxt_c = SM_N_WRITE16_PS0_EXEC;
                sys_cntr_nxt_c = {32{1'b0}};
            end
            SM_N_WRITE16_PS0_EXEC: begin
                if(sys_cntr_r < WRITE16_LIMIT_S0) begin
                    mstr_state_nxt_c = SM_N_WRITE16_PS0_HOLD;
                    sys_cntr_nxt_c = sys_cntr_r + 1'b1;
                end
                else begin
                    if(S0_READ_EN) begin
                        mstr_state_nxt_c = SM_N_READ16_PS0_INIT;
                    end
                    else begin
                        mstr_state_nxt_c = SM_N_READ16_PS01x_INIT;
                    end
                    sys_cntr_nxt_c = {32{1'b0}};
                end
            end
            SM_N_WRITE16_PS0_HOLD: begin
                mstr_state_nxt_c = SM_N_WRITE16_PS0_EXEC;
            end
            // --------------------------------------
            // ----- 16-bit NSEQ READ (port S0) -----
            // --------------------------------------
            SM_N_READ16_PS0_INIT: begin
                mstr_state_nxt_c = SM_N_READ16_PS0_EXEC;
                sys_cntr_nxt_c = {32{1'b0}};
            end
            SM_N_READ16_PS0_EXEC: begin
                if(sys_cntr_r < READ16_LIMIT_S0) begin
                    mstr_state_nxt_c = SM_N_READ16_PS0_HOLD;
                    sys_cntr_nxt_c = sys_cntr_r + 1'b1;
                end
                else begin
                    if(S1_READ_EN) begin
                        mstr_state_nxt_c = SM_N_READ16_PS01x_INIT;
                    end
                    else if(BYTE_ENABLE_S0) begin
                        mstr_state_nxt_c = SM_N_WRITE8_PS0_INIT;
                    end
                    else begin
                        mstr_state_nxt_c = SM_N_READ8_PS0_INIT;
                    end
                    sys_cntr_nxt_c = {32{1'b0}};
                end
            end
            SM_N_READ16_PS0_HOLD: begin
                mstr_state_nxt_c = SM_N_READ16_PS0_EXEC;
            end
            // --------------------------------------
            // ----- 16-bit NSEQ READ (port S1) -----
            // --------------------------------------
            SM_N_READ16_PS01x_INIT: begin
                mstr_state_nxt_c = SM_N_READ16_PS01x_EXEC;
                sys_cntr_nxt_c = {32{1'b0}};
            end
            SM_N_READ16_PS01x_EXEC: begin
                if(sys_cntr_r < READ16_LIMIT_S1) begin
                    mstr_state_nxt_c = SM_N_READ16_PS01x_HOLD;
                    sys_cntr_nxt_c = sys_cntr_r + 1'b1;
                end
                else begin
                    if(BYTE_ENABLE_S0) begin
                        mstr_state_nxt_c = SM_N_WRITE8_PS0_INIT;
                    end
                    else if(S0_READ_EN) begin
                        mstr_state_nxt_c = SM_N_READ8_PS0_INIT;
                    end
                    else begin
                        mstr_state_nxt_c = SM_N_READ8_PS01x_INIT;
                    end
                    sys_cntr_nxt_c = {32{1'b0}};
                end
            end
            SM_N_READ16_PS01x_HOLD: begin
                mstr_state_nxt_c = SM_N_READ16_PS01x_EXEC;
            end
            // --------------------------------------
            // ----- 8-bit NSEQ WRITE (port S0) -----
            // --------------------------------------
            SM_N_WRITE8_PS0_INIT: begin
                mstr_state_nxt_c = SM_N_WRITE8_PS0_EXEC;
                sys_cntr_nxt_c = {32{1'b0}};
            end
            SM_N_WRITE8_PS0_EXEC: begin
                if(sys_cntr_r < WRITE8_LIMIT_S0) begin
                    mstr_state_nxt_c = SM_N_WRITE8_PS0_HOLD;
                    sys_cntr_nxt_c = sys_cntr_r + 1'b1;
                end
                else begin
                    if(S0_READ_EN) begin
                        mstr_state_nxt_c = SM_N_READ8_PS0_INIT;
                    end
                    else begin
                        mstr_state_nxt_c = SM_N_READ8_PS01x_INIT;
                    end
                    sys_cntr_nxt_c = {32{1'b0}};
                end
            end
            SM_N_WRITE8_PS0_HOLD: begin
                mstr_state_nxt_c = SM_N_WRITE8_PS0_EXEC;
            end
            // -------------------------------------
            // ----- 8-bit NSEQ READ (port S0) -----
            // -------------------------------------
            SM_N_READ8_PS0_INIT: begin
                mstr_state_nxt_c = SM_N_READ8_PS0_EXEC;
                sys_cntr_nxt_c = {32{1'b0}};
            end
            SM_N_READ8_PS0_EXEC: begin
                if(sys_cntr_r < READ8_LIMIT_S0) begin
                    mstr_state_nxt_c = SM_N_READ8_PS0_HOLD;
                    sys_cntr_nxt_c = sys_cntr_r + 1'b1;
                end
                else begin
                    if(S1_READ_EN) begin
                        mstr_state_nxt_c = SM_N_READ8_PS01x_INIT;
                    end
                    else if(S1_WRITE_EN) begin
                        case(DATA_WIDTH)
                            32: mstr_state_nxt_c = SM_N_WRITE32_PS1_INIT;
                            16: mstr_state_nxt_c = SM_N_WRITE16_PS1_INIT;
                            8: mstr_state_nxt_c = SM_N_WRITE8_PS1_INIT;
                        endcase
                    end
                    else begin
                        if(S0_READ_EN & S0_WRITE_EN) begin
                            mstr_state_nxt_c = SM_N_WR_TO_READ_PS0_INIT;
                        end
                        else if(S1_READ_EN & S1_WRITE_EN) begin
                            mstr_state_nxt_c = SM_N_WR_TO_READ_PS1_INIT;
                        end
                        else begin
                            case(DATA_WIDTH)
                                32: mstr_state_nxt_c = SM_S_WRITE32_PS0_INIT;
                                16: mstr_state_nxt_c = SM_S_WRITE16_PS0_INIT;
                                8: mstr_state_nxt_c = SM_S_WRITE8_PS0_INIT;
                            endcase
                        end
                    end
                    sys_cntr_nxt_c = {32{1'b0}};
                end
            end
            SM_N_READ8_PS0_HOLD: begin
                mstr_state_nxt_c = SM_N_READ8_PS0_EXEC;
            end
            // -------------------------------------
            // ----- 8-bit NSEQ READ (port S1) -----
            // -------------------------------------
            SM_N_READ8_PS01x_INIT: begin
                mstr_state_nxt_c = SM_N_READ8_PS01x_EXEC;
                sys_cntr_nxt_c = {32{1'b0}};
            end
            SM_N_READ8_PS01x_EXEC: begin
                if(sys_cntr_r < READ8_LIMIT_S1) begin
                    mstr_state_nxt_c = SM_N_READ8_PS01x_HOLD;
                    sys_cntr_nxt_c = sys_cntr_r + 1'b1;
                end
                else begin
                    if(S1_WRITE_EN) begin
                        case(DATA_WIDTH)
                            32: mstr_state_nxt_c = SM_N_WRITE32_PS1_INIT;
                            16: mstr_state_nxt_c = SM_N_WRITE16_PS1_INIT;
                            8: mstr_state_nxt_c = SM_N_WRITE8_PS1_INIT;
                        endcase
                    end
                    else begin
                        if(S0_READ_EN & S0_WRITE_EN) begin
                            mstr_state_nxt_c = SM_N_WR_TO_READ_PS0_INIT;
                        end
                        else if(S1_READ_EN & S1_WRITE_EN) begin
                            mstr_state_nxt_c = SM_N_WR_TO_READ_PS1_INIT;
                        end
                        else begin
                            case(DATA_WIDTH)
                                32: mstr_state_nxt_c = SM_S_WRITE32_PS0_INIT;
                                16: mstr_state_nxt_c = SM_S_WRITE16_PS0_INIT;
                                8: mstr_state_nxt_c = SM_S_WRITE8_PS0_INIT;
                            endcase
                        end
                    end
                    sys_cntr_nxt_c = {32{1'b0}};
                end
            end
            SM_N_READ8_PS01x_HOLD: begin
                mstr_state_nxt_c = SM_N_READ8_PS01x_EXEC;
            end
            // ---------------------------------------
            // PORT PRIORITY CHANGE
            // ---------------------------------------
            // ----- 32-bit NSEQ WRITE (port S1) -----
            // ---------------------------------------
            SM_N_WRITE32_PS1_INIT: begin
                sys_cntr_nxt_c = {32{1'b0}};
                mstr_state_nxt_c = SM_N_WRITE32_PS1_EXEC;
            end
            SM_N_WRITE32_PS1_EXEC: begin
                if(sys_cntr_r < WRITE32_LIMIT_S1) begin
                    mstr_state_nxt_c = SM_N_WRITE32_PS1_HOLD;
                    sys_cntr_nxt_c = sys_cntr_r + 1'b1;
                end
                else begin
                    if(S1_READ_EN) begin
                        mstr_state_nxt_c = SM_N_READ32_PS1_INIT;
                    end
                    else begin
                        mstr_state_nxt_c = SM_N_READ32_PS10x_INIT;
                    end
                    sys_cntr_nxt_c = {32{1'b0}};
                end
            end
            SM_N_WRITE32_PS1_HOLD: begin
                mstr_state_nxt_c = SM_N_WRITE32_PS1_EXEC;
            end
            // --------------------------------------
            // ----- 32-bit NSEQ READ (port S1) -----
            // --------------------------------------
            SM_N_READ32_PS1_INIT: begin
                sys_cntr_nxt_c = {32{1'b0}};
                mstr_state_nxt_c = SM_N_READ32_PS1_EXEC;
            end
            SM_N_READ32_PS1_EXEC: begin
                if(sys_cntr_r < READ32_LIMIT_S1-1) begin
                    mstr_state_nxt_c = SM_N_READ32_PS1_HOLD;
                    sys_cntr_nxt_c = sys_cntr_r + 1'b1;
                end
                else begin
                    if(S0_READ_EN) begin
                        mstr_state_nxt_c = SM_N_READ32_PS10x_INIT;
                    end
                    else if(BYTE_ENABLE_S1) begin
                        mstr_state_nxt_c = SM_N_WRITE16_PS1_INIT;
                    end
                    else begin
                        mstr_state_nxt_c = SM_N_READ16_PS1_INIT;
                    end
                    sys_cntr_nxt_c = {32{1'b0}};
                end
            end
            SM_N_READ32_PS1_HOLD: begin
                mstr_state_nxt_c = SM_N_READ32_PS1_EXEC;
            end
            // --------------------------------------
            // ----- 32-bit NSEQ READ (port S0) -----
            // --------------------------------------
            SM_N_READ32_PS10x_INIT: begin
                mstr_state_nxt_c = SM_N_READ32_PS10x_EXEC;
                sys_cntr_nxt_c = {32{1'b0}};
            end
            SM_N_READ32_PS10x_EXEC: begin
                if(sys_cntr_r < READ32_LIMIT_S1-1) begin
                    mstr_state_nxt_c = SM_N_READ32_PS10x_HOLD;
                    sys_cntr_nxt_c = sys_cntr_r + 1'b1;
                end
                else begin
                    if(BYTE_ENABLE_S1) begin
                        mstr_state_nxt_c = SM_N_WRITE16_PS1_INIT;
                    end
                    else if(S1_READ_EN) begin
                        mstr_state_nxt_c = SM_N_READ16_PS1_INIT;
                    end
                    else begin
                        mstr_state_nxt_c = SM_N_READ16_PS10x_INIT;
                    end
                    sys_cntr_nxt_c = {32{1'b0}};
                end
            end
            SM_N_READ32_PS10x_HOLD: begin
                mstr_state_nxt_c = SM_N_READ32_PS10x_EXEC;
            end
            // ---------------------------------------
            // ----- 16-bit NSEQ WRITE (port S1) -----
            // ---------------------------------------
            SM_N_WRITE16_PS1_INIT: begin
                mstr_state_nxt_c = SM_N_WRITE16_PS1_EXEC;
                sys_cntr_nxt_c = {32{1'b0}};
            end
            SM_N_WRITE16_PS1_EXEC: begin
                if(sys_cntr_r < WRITE16_LIMIT_S1) begin
                    mstr_state_nxt_c = SM_N_WRITE16_PS1_HOLD;
                    sys_cntr_nxt_c = sys_cntr_r + 1'b1;
                end
                else begin
                    if(S1_READ_EN) begin
                        mstr_state_nxt_c = SM_N_READ16_PS1_INIT;
                    end
                    else begin
                        mstr_state_nxt_c = SM_N_READ16_PS10x_INIT;
                    end
                    sys_cntr_nxt_c = {32{1'b0}};
                end
            end
            SM_N_WRITE16_PS1_HOLD: begin
                mstr_state_nxt_c = SM_N_WRITE16_PS1_EXEC;
            end
            // --------------------------------------
            // ----- 16-bit NSEQ READ (port S1) -----
            // --------------------------------------
            SM_N_READ16_PS1_INIT: begin
                mstr_state_nxt_c = SM_N_READ16_PS1_EXEC;
                sys_cntr_nxt_c = {32{1'b0}};
            end
            SM_N_READ16_PS1_EXEC: begin
                if(sys_cntr_r < READ16_LIMIT_S1-1) begin
                    mstr_state_nxt_c = SM_N_READ16_PS1_HOLD;
                    sys_cntr_nxt_c = sys_cntr_r + 1'b1;
                end
                else begin
                    if(S0_READ_EN) begin
                        mstr_state_nxt_c = SM_N_READ16_PS10x_INIT;
                    end
                    else if(BYTE_ENABLE_S1) begin
                        mstr_state_nxt_c = SM_N_WRITE8_PS1_INIT;
                    end
                    else begin
                        mstr_state_nxt_c = SM_N_READ8_PS1_INIT;
                    end
                    sys_cntr_nxt_c = {32{1'b0}};
                end
            end
            SM_N_READ16_PS1_HOLD: begin
                mstr_state_nxt_c = SM_N_READ16_PS1_EXEC;
            end
            // --------------------------------------
            // ----- 16-bit NSEQ READ (port S0) -----
            // --------------------------------------
            SM_N_READ16_PS10x_INIT: begin
                mstr_state_nxt_c = SM_N_READ16_PS10x_EXEC;
                sys_cntr_nxt_c = {32{1'b0}};
            end
            SM_N_READ16_PS10x_EXEC: begin
                if(sys_cntr_r < READ16_LIMIT_S0-1) begin
                    mstr_state_nxt_c = SM_N_READ16_PS10x_HOLD;
                    sys_cntr_nxt_c = sys_cntr_r + 1'b1;
                end
                else begin
                    if(BYTE_ENABLE_S1) begin
                        mstr_state_nxt_c = SM_N_WRITE8_PS1_INIT;
                    end
                    else if(S1_READ_EN) begin
                        mstr_state_nxt_c = SM_N_READ8_PS1_INIT;
                    end
                    else begin
                        mstr_state_nxt_c = SM_N_READ8_PS10x_INIT;
                    end
                    sys_cntr_nxt_c = {32{1'b0}};
                end
            end
            SM_N_READ16_PS10x_HOLD: begin
                mstr_state_nxt_c = SM_N_READ16_PS10x_EXEC;
            end
            // --------------------------------------
            // ----- 8-bit NSEQ WRITE (port S1) -----
            // --------------------------------------
            SM_N_WRITE8_PS1_INIT: begin
                mstr_state_nxt_c = SM_N_WRITE8_PS1_EXEC;
                sys_cntr_nxt_c = {32{1'b0}};
            end
            SM_N_WRITE8_PS1_EXEC: begin
                if(sys_cntr_r < WRITE8_LIMIT_S1) begin
                    mstr_state_nxt_c = SM_N_WRITE8_PS1_HOLD;
                    sys_cntr_nxt_c = sys_cntr_r + 1'b1;
                end
                else begin
                    if(S1_READ_EN) begin
                        mstr_state_nxt_c = SM_N_READ8_PS1_INIT;
                    end
                    else begin
                        mstr_state_nxt_c = SM_N_READ8_PS10x_INIT;
                    end
                    sys_cntr_nxt_c = {32{1'b0}};
                end
            end
            SM_N_WRITE8_PS1_HOLD: begin
                mstr_state_nxt_c = SM_N_WRITE8_PS1_EXEC;
            end
            // -------------------------------------
            // ----- 8-bit NSEQ READ (port S1) -----
            // -------------------------------------
            SM_N_READ8_PS1_INIT: begin
                mstr_state_nxt_c = SM_N_READ8_PS1_EXEC;
                sys_cntr_nxt_c = {32{1'b0}};
            end
            SM_N_READ8_PS1_EXEC: begin
                if(sys_cntr_r < READ8_LIMIT_S1-1) begin
                    mstr_state_nxt_c = SM_N_READ8_PS1_HOLD;
                    sys_cntr_nxt_c = sys_cntr_r + 1'b1;
                end
                else begin
                    if(S0_READ_EN) begin
                        mstr_state_nxt_c = SM_N_READ8_PS10x_INIT;
                    end
                    else if(S0_READ_EN & S0_WRITE_EN) begin
                        mstr_state_nxt_c = SM_N_WR_TO_READ_PS0_INIT;
                    end
                    else if(S1_READ_EN & S1_WRITE_EN) begin
                        mstr_state_nxt_c = SM_N_WR_TO_READ_PS1_INIT;
                    end
                    else if(S0_WRITE_EN) begin
                        case(DATA_WIDTH)
                            32: mstr_state_nxt_c = SM_S_WRITE32_PS0_INIT;
                            16: mstr_state_nxt_c = SM_S_WRITE16_PS0_INIT;
                            8: mstr_state_nxt_c = SM_S_WRITE8_PS0_INIT;
                        endcase
                    end
                    else begin
                        case(DATA_WIDTH)
                            32: mstr_state_nxt_c = SM_S_WRITE32_PS1_INIT;
                            16: mstr_state_nxt_c = SM_S_WRITE16_PS1_INIT;
                            8: mstr_state_nxt_c = SM_S_WRITE8_PS1_INIT;
                        endcase
                    end
                    sys_cntr_nxt_c = {32{1'b0}};
                end
            end
            SM_N_READ8_PS1_HOLD: begin
                mstr_state_nxt_c = SM_N_READ8_PS1_EXEC;
            end
            // -------------------------------------
            // ----- 8-bit NSEQ READ (port S0) -----
            // -------------------------------------
            SM_N_READ8_PS10x_INIT: begin
                mstr_state_nxt_c = SM_N_READ8_PS10x_EXEC;
                sys_cntr_nxt_c = {32{1'b0}};
            end
            SM_N_READ8_PS10x_EXEC: begin
                if(sys_cntr_r < READ8_LIMIT_S0-1) begin
                    mstr_state_nxt_c = SM_N_READ8_PS10x_HOLD;
                    sys_cntr_nxt_c = sys_cntr_r + 1'b1;
                end
                else begin
                    if(S0_READ_EN & S0_WRITE_EN) begin
                        mstr_state_nxt_c = SM_N_WR_TO_READ_PS0_INIT;
                    end
                    else if(S1_READ_EN & S1_WRITE_EN) begin
                        mstr_state_nxt_c = SM_N_WR_TO_READ_PS1_INIT;
                    end
                    else if(S0_WRITE_EN) begin
                        case(DATA_WIDTH)
                            32: mstr_state_nxt_c = SM_S_WRITE32_PS0_INIT;
                            16: mstr_state_nxt_c = SM_S_WRITE16_PS0_INIT;
                            8: mstr_state_nxt_c = SM_S_WRITE8_PS0_INIT;
                        endcase
                    end
                    else begin
                        case(DATA_WIDTH)
                            32: mstr_state_nxt_c = SM_S_WRITE32_PS1_INIT;
                            16: mstr_state_nxt_c = SM_S_WRITE16_PS1_INIT;
                            8: mstr_state_nxt_c = SM_S_WRITE8_PS1_INIT;
                        endcase
                    end
                    sys_cntr_nxt_c = {32{1'b0}};
                end
            end
            SM_N_READ8_PS10x_HOLD: begin
                mstr_state_nxt_c = SM_N_READ8_PS10x_EXEC;
            end
            // -----------------------------------
            // WRITE TO READ INSTRUCTIONS
            // -----------------------------------
            // ----- WRITE to READ (port S0) -----
            // -----------------------------------
            SM_N_WR_TO_READ_PS0_INIT: begin
                mstr_state_nxt_c = SM_N_WR_TO_READ_PS0_WRITE;
                sys_cntr_nxt_c = {32{1'b0}};
            end
            SM_N_WR_TO_READ_PS0_WRITE: begin
                mstr_state_nxt_c = SM_N_WR_TO_READ_PS0_READ;         
            end
            SM_N_WR_TO_READ_PS0_READ: begin
                if(sys_cntr_r < WR2RD_LIMIT_S0) begin
                   sys_cntr_nxt_c = sys_cntr_r + 1'b1;
                   mstr_state_nxt_c = SM_N_WR_TO_READ_PS0_HOLD;
                end
                else if(S1_READ_EN & S1_WRITE_EN)begin
                   sys_cntr_nxt_c = {32{1'b0}};
                   mstr_state_nxt_c = SM_N_WR_TO_READ_PS1_INIT;
                end
                else begin
                    if(S0_WRITE_EN) begin
                        case(DATA_WIDTH)
                            32: mstr_state_nxt_c = SM_S_WRITE32_PS0_INIT;
                            16: mstr_state_nxt_c = SM_S_WRITE16_PS0_INIT;
                            8: mstr_state_nxt_c = SM_S_WRITE8_PS0_INIT;
                        endcase
                    end
                    else begin
                        case(DATA_WIDTH)
                            32: mstr_state_nxt_c = SM_S_WRITE32_PS1_INIT;
                            16: mstr_state_nxt_c = SM_S_WRITE16_PS1_INIT;
                            8: mstr_state_nxt_c = SM_S_WRITE8_PS1_INIT;
                        endcase
                    end
                end
            end
            SM_N_WR_TO_READ_PS0_HOLD: begin
                mstr_state_nxt_c = SM_N_WR_TO_READ_PS0_WRITE;
            end
            // -----------------------------------
            // ----- WRITE to READ (port S1) -----
            // -----------------------------------
            SM_N_WR_TO_READ_PS1_INIT: begin
                mstr_state_nxt_c = SM_N_WR_TO_READ_PS1_WRITE;
                sys_cntr_nxt_c = {32{1'b0}};
            end
            SM_N_WR_TO_READ_PS1_WRITE: begin
                mstr_state_nxt_c = SM_N_WR_TO_READ_PS1_READ;         
            end
            SM_N_WR_TO_READ_PS1_READ: begin
                if(sys_cntr_r < WR2RD_LIMIT_S1) begin
                   sys_cntr_nxt_c = sys_cntr_r + 1'b1;
                   mstr_state_nxt_c = SM_N_WR_TO_READ_PS1_HOLD;
                end
                else begin
                    if(S0_WRITE_EN) begin
                        case(DATA_WIDTH)
                            32: mstr_state_nxt_c = SM_S_WRITE32_PS0_INIT;
                            16: mstr_state_nxt_c = SM_S_WRITE16_PS0_INIT;
                            8: mstr_state_nxt_c = SM_S_WRITE8_PS0_INIT;
                        endcase
                    end
                    else begin
                        case(DATA_WIDTH)
                            32: mstr_state_nxt_c = SM_S_WRITE32_PS1_INIT;
                            16: mstr_state_nxt_c = SM_S_WRITE16_PS1_INIT;
                            8: mstr_state_nxt_c = SM_S_WRITE8_PS1_INIT;
                        endcase
                    end
                    sys_cntr_nxt_c = {32{1'b0}};
                end
            end
            SM_N_WR_TO_READ_PS1_HOLD: begin
                mstr_state_nxt_c = SM_N_WR_TO_READ_PS1_WRITE;
            end
            // --------------------------------------
            // SEQUENTIAL MODE
            // --------------------------------------
            // ----- 32-bit SEQ WRITE (port S0) -----
            // --------------------------------------
            SM_S_WRITE32_PS0_INIT: begin
                mstr_state_nxt_c = SM_S_WRITE32_PS0_HOLD;
                sys_cntr_nxt_c = {32{1'b0}};
            end
            SM_S_WRITE32_PS0_HOLD: begin
                mstr_state_nxt_c = SM_S_WRITE32_PS0_EXEC;
                sys_cntr_nxt_c = {32{1'b0}} + 1'b1;
            end
            SM_S_WRITE32_PS0_EXEC: begin
                if(sys_cntr_r < WRITE32_LIMIT_S0-1) begin
                    sys_cntr_nxt_c = sys_cntr_r + 1'b1;
                end
                else begin
                    if(S0_READ_EN) begin
                        mstr_state_nxt_c = SM_S_READ32_PS0_INIT;
                    end
                    else begin
                        mstr_state_nxt_c = SM_S_READ32_PS01x_INIT;
                    end
                    sys_cntr_nxt_c = {32{1'b0}};
                end
            end
            // -------------------------------------
            // ----- 32-bit SEQ READ (port S0) -----
            // -------------------------------------
            SM_S_READ32_PS0_INIT: begin
                mstr_state_nxt_c = SM_S_READ32_PS0_HOLD;
                sys_cntr_nxt_c = {32{1'b0}};
            end
            SM_S_READ32_PS0_HOLD: begin
                mstr_state_nxt_c = SM_S_READ32_PS0_EXEC;
                sys_cntr_nxt_c = {32{1'b0}} + 1'b1;
            end
            SM_S_READ32_PS0_EXEC: begin
                if(sys_cntr_r < READ32_LIMIT_S0-1) begin
                    sys_cntr_nxt_c = sys_cntr_r + 1'b1;
                end
                else begin
                    if(S1_READ_EN) begin
                        mstr_state_nxt_c = SM_S_READ32_PS01x_INIT;
                    end
                    else if(BYTE_ENABLE_S0) begin
                        mstr_state_nxt_c = SM_S_WRITE16_PS0_INIT;
                    end
                    else begin
                        mstr_state_nxt_c = SM_S_READ16_PS0_INIT;
                    end
                    sys_cntr_nxt_c = {32{1'b0}};
                end
            end
            // -------------------------------------
            // ----- 32-bit SEQ READ (port S1) -----
            // -------------------------------------
            SM_S_READ32_PS01x_INIT: begin
                mstr_state_nxt_c = SM_S_READ32_PS01x_HOLD;
                sys_cntr_nxt_c = {32{1'b0}};
            end
            SM_S_READ32_PS01x_HOLD: begin
                mstr_state_nxt_c = SM_S_READ32_PS01x_EXEC;
                sys_cntr_nxt_c = {32{1'b0}} + 1'b1;
            end
            SM_S_READ32_PS01x_EXEC: begin
                if(sys_cntr_r < READ32_LIMIT_S1-1) begin
                    sys_cntr_nxt_c = sys_cntr_r + 1'b1;
                end
                else begin
                    if(BYTE_ENABLE_S0) begin
                        mstr_state_nxt_c = SM_S_WRITE16_PS0_INIT;
                    end
                    else if(S0_READ_EN) begin
                        mstr_state_nxt_c = SM_S_READ16_PS0_INIT;
                    end
                    else begin
                        mstr_state_nxt_c = SM_S_READ16_PS01x_INIT;
                    end
                    sys_cntr_nxt_c = {32{1'b0}};
                end
            end
            // --------------------------------------
            // ----- 16-bit SEQ WRITE (port S0) -----
            // --------------------------------------
            SM_S_WRITE16_PS0_INIT: begin
                mstr_state_nxt_c = SM_S_WRITE16_PS0_HOLD;
                sys_cntr_nxt_c = {32{1'b0}};
            end
            SM_S_WRITE16_PS0_HOLD: begin
                mstr_state_nxt_c = SM_S_WRITE16_PS0_EXEC;
                sys_cntr_nxt_c = {32{1'b0}} + 1'b1;
            end
            SM_S_WRITE16_PS0_EXEC: begin
                if(sys_cntr_r < WRITE16_LIMIT_S0-1) begin
                    sys_cntr_nxt_c = sys_cntr_r + 1'b1;
                end
                else begin
                    if(S0_READ_EN) begin
                        mstr_state_nxt_c = SM_S_READ16_PS0_INIT;
                    end
                    else begin
                        mstr_state_nxt_c = SM_S_READ16_PS01x_INIT;
                    end
                    sys_cntr_nxt_c = {32{1'b0}};
                end
            end
            // -------------------------------------
            // ----- 16-bit SEQ READ (port S0) -----
            // -------------------------------------
            SM_S_READ16_PS0_INIT: begin
                mstr_state_nxt_c = SM_S_READ16_PS0_HOLD;
                sys_cntr_nxt_c = {32{1'b0}};
            end
            SM_S_READ16_PS0_HOLD: begin
                mstr_state_nxt_c = SM_S_READ16_PS0_EXEC;
                sys_cntr_nxt_c = {32{1'b0}} + 1'b1;
            end
            SM_S_READ16_PS0_EXEC: begin
                if(sys_cntr_r < READ16_LIMIT_S0-1) begin
                    sys_cntr_nxt_c = sys_cntr_r + 1'b1;
                end
                else begin
                    if(S1_READ_EN) begin
                        mstr_state_nxt_c = SM_S_READ16_PS01x_INIT;
                    end
                    else if(BYTE_ENABLE_S0) begin
                        mstr_state_nxt_c = SM_S_WRITE8_PS0_INIT;
                    end
                    else begin
                        mstr_state_nxt_c = SM_S_READ8_PS0_INIT;
                    end
                    sys_cntr_nxt_c = {32{1'b0}};
                end
            end
            // -------------------------------------
            // ----- 16-bit SEQ READ (port S1) -----
            // -------------------------------------
            SM_S_READ16_PS01x_INIT: begin
                mstr_state_nxt_c = SM_S_READ16_PS01x_HOLD;
                sys_cntr_nxt_c = {32{1'b0}};
            end
            SM_S_READ16_PS01x_HOLD: begin
                mstr_state_nxt_c = SM_S_READ16_PS01x_EXEC;
                sys_cntr_nxt_c = {32{1'b0}} + 1'b1;
            end
            SM_S_READ16_PS01x_EXEC: begin
                if(sys_cntr_r < READ16_LIMIT_S1-1) begin
                    sys_cntr_nxt_c = sys_cntr_r + 1'b1;
                end
                else begin
                    if(BYTE_ENABLE_S0) begin
                        mstr_state_nxt_c = SM_S_WRITE8_PS0_INIT;
                    end
                    else if(S0_READ_EN) begin
                        mstr_state_nxt_c = SM_S_READ8_PS0_INIT;
                    end
                    else begin
                        mstr_state_nxt_c = SM_S_READ8_PS01x_INIT;
                    end
                    sys_cntr_nxt_c = {32{1'b0}};
                end
            end
            // -------------------------------------
            // ----- 8-bit SEQ WRITE (port S0) -----
            // -------------------------------------
            SM_S_WRITE8_PS0_INIT: begin
                mstr_state_nxt_c = SM_S_WRITE8_PS0_HOLD;
                sys_cntr_nxt_c = {32{1'b0}};
            end
            SM_S_WRITE8_PS0_HOLD: begin
                mstr_state_nxt_c = SM_S_WRITE8_PS0_EXEC;
                sys_cntr_nxt_c = {32{1'b0}} + 1'b1;
            end
            SM_S_WRITE8_PS0_EXEC: begin
                if(sys_cntr_r < WRITE8_LIMIT_S0-1) begin
                    sys_cntr_nxt_c = sys_cntr_r + 1'b1;
                end
                else begin
                    if(S0_READ_EN) begin
                        mstr_state_nxt_c = SM_S_READ8_PS0_INIT;
                    end
                    else begin
                        mstr_state_nxt_c = SM_S_READ8_PS01x_INIT;
                    end
                    sys_cntr_nxt_c = {32{1'b0}};
                end
            end
            // ------------------------------------
            // ----- 8-bit SEQ READ (port S0) -----
            // ------------------------------------
            SM_S_READ8_PS0_INIT: begin
                mstr_state_nxt_c = SM_S_READ8_PS0_HOLD;
                sys_cntr_nxt_c = {32{1'b0}};
            end
            SM_S_READ8_PS0_HOLD: begin
                mstr_state_nxt_c = SM_S_READ8_PS0_EXEC;
                sys_cntr_nxt_c = {32{1'b0}} + 1'b1;
            end
            SM_S_READ8_PS0_EXEC: begin
                if(sys_cntr_r < READ8_LIMIT_S0-1) begin
                    sys_cntr_nxt_c = sys_cntr_r + 1'b1;
                end
                else begin
                    if(S1_READ_EN) begin
                        mstr_state_nxt_c = SM_S_READ8_PS01x_INIT;
                    end
                    else if(S1_WRITE_EN) begin
                        case(DATA_WIDTH)
                            32: mstr_state_nxt_c = SM_S_WRITE32_PS1_INIT;
                            16: mstr_state_nxt_c = SM_S_WRITE16_PS1_INIT;
                            8: mstr_state_nxt_c = SM_S_WRITE8_PS1_INIT;
                        endcase
                    end
                    else begin
                        mstr_state_nxt_c = SM_C_END;
                    end
                    sys_cntr_nxt_c = {32{1'b0}};
                end
            end
            // ------------------------------------
            // ----- 8-bit SEQ READ (port S1) -----
            // ------------------------------------
            SM_S_READ8_PS01x_INIT: begin
                mstr_state_nxt_c = SM_S_READ8_PS01x_HOLD;
                sys_cntr_nxt_c = {32{1'b0}};
            end
            SM_S_READ8_PS01x_HOLD: begin
                mstr_state_nxt_c = SM_S_READ8_PS01x_EXEC;
                sys_cntr_nxt_c = {32{1'b0}} + 1'b1;
            end
            SM_S_READ8_PS01x_EXEC: begin
                if(sys_cntr_r < READ8_LIMIT_S1-1) begin
                    sys_cntr_nxt_c = sys_cntr_r + 1'b1;
                end
                else begin
                    if(S1_WRITE_EN) begin
                        case(DATA_WIDTH)
                            32: mstr_state_nxt_c = SM_S_WRITE32_PS1_INIT;
                            16: mstr_state_nxt_c = SM_S_WRITE16_PS1_INIT;
                            8: mstr_state_nxt_c = SM_S_WRITE8_PS1_INIT;
                        endcase
                    end
                    else begin
                        mstr_state_nxt_c = SM_C_END;
                    end
                    sys_cntr_nxt_c = {32{1'b0}};
                end
            end
            // --------------------------------------
            // SEQUENTIAL MODE - PORT PRIORITY CHANGE
            // --------------------------------------
            // ----- 32-bit SEQ WRITE (port S1) -----
            // --------------------------------------
            SM_S_WRITE32_PS1_INIT: begin
                mstr_state_nxt_c = SM_S_WRITE32_PS1_HOLD;
                sys_cntr_nxt_c = {32{1'b0}};
            end
            SM_S_WRITE32_PS1_HOLD: begin
                mstr_state_nxt_c = SM_S_WRITE32_PS1_EXEC;
                sys_cntr_nxt_c = {32{1'b0}} + 1'b1;
            end
            SM_S_WRITE32_PS1_EXEC: begin
                if(sys_cntr_r < WRITE32_LIMIT_S1-1) begin
                    sys_cntr_nxt_c = sys_cntr_r + 1'b1;
                end
                else begin
                    if(S1_READ_EN) begin
                        mstr_state_nxt_c = SM_S_READ32_PS1_INIT;
                    end
                    else begin
                        mstr_state_nxt_c = SM_S_READ32_PS10x_INIT;
                    end
                    sys_cntr_nxt_c = {32{1'b0}};
                end
            end
            // -------------------------------------
            // ----- 32-bit SEQ READ (port S1) -----
            // -------------------------------------
            SM_S_READ32_PS1_INIT: begin
                mstr_state_nxt_c = SM_S_READ32_PS1_HOLD;
                sys_cntr_nxt_c = {32{1'b0}};
            end
            SM_S_READ32_PS1_HOLD: begin
                mstr_state_nxt_c = SM_S_READ32_PS1_EXEC;
                sys_cntr_nxt_c = {32{1'b0}} + 1'b1;
            end
            SM_S_READ32_PS1_EXEC: begin
                if(sys_cntr_r < READ32_LIMIT_S1-1) begin
                    sys_cntr_nxt_c = sys_cntr_r + 1'b1;
                end
                else begin
                    if(S0_READ_EN) begin
                        mstr_state_nxt_c = SM_S_READ32_PS10x_INIT;
                    end
                    else if(BYTE_ENABLE_S1) begin
                        mstr_state_nxt_c = SM_S_WRITE16_PS1_INIT;
                    end
                    else begin
                        mstr_state_nxt_c = SM_S_READ16_PS1_INIT;
                    end
                    sys_cntr_nxt_c = {32{1'b0}};
                end
            end
            // -------------------------------------
            // ----- 32-bit SEQ READ (port S0) -----
            // -------------------------------------
            SM_S_READ32_PS10x_INIT: begin
                mstr_state_nxt_c = SM_S_READ32_PS10x_HOLD;
                sys_cntr_nxt_c = {32{1'b0}};
            end
            SM_S_READ32_PS10x_HOLD: begin
                mstr_state_nxt_c = SM_S_READ32_PS10x_EXEC;
                sys_cntr_nxt_c = {32{1'b0}} + 1'b1;
            end
            SM_S_READ32_PS10x_EXEC: begin
                if(sys_cntr_r < READ32_LIMIT_S0-1) begin
                    sys_cntr_nxt_c = sys_cntr_r + 1'b1;
                end
                else begin
                    if(BYTE_ENABLE_S1) begin
                        mstr_state_nxt_c = SM_S_WRITE16_PS1_INIT;
                    end
                    else if(S1_READ_EN) begin
                        mstr_state_nxt_c = SM_S_READ16_PS1_INIT;
                    end
                    else begin
                        mstr_state_nxt_c = SM_S_READ16_PS10x_INIT;
                    end
                    sys_cntr_nxt_c = {32{1'b0}};
                end
            end
            // --------------------------------------
            // ----- 16-bit SEQ WRITE (port S1) -----
            // --------------------------------------
            SM_S_WRITE16_PS1_INIT: begin
                mstr_state_nxt_c = SM_S_WRITE16_PS1_HOLD;
                sys_cntr_nxt_c = {32{1'b0}};
            end
            SM_S_WRITE16_PS1_HOLD: begin
                mstr_state_nxt_c = SM_S_WRITE16_PS1_EXEC;
                sys_cntr_nxt_c = {32{1'b0}} + 1'b1;
            end
            SM_S_WRITE16_PS1_EXEC: begin
                if(sys_cntr_r < WRITE16_LIMIT_S1-1) begin
                    sys_cntr_nxt_c = sys_cntr_r + 1'b1;
                end
                else begin
                    if(S1_READ_EN) begin
                        mstr_state_nxt_c = SM_S_READ16_PS1_INIT;
                    end
                    else begin
                        mstr_state_nxt_c = SM_S_READ16_PS10x_INIT;
                    end
                    sys_cntr_nxt_c = {32{1'b0}};
                end
            end
            // -------------------------------------
            // ----- 16-bit SEQ READ (port S1) -----
            // -------------------------------------
            SM_S_READ16_PS1_INIT: begin
                mstr_state_nxt_c = SM_S_READ16_PS1_HOLD;
                sys_cntr_nxt_c = {32{1'b0}};
            end
            SM_S_READ16_PS1_HOLD: begin
                mstr_state_nxt_c = SM_S_READ16_PS1_EXEC;
                sys_cntr_nxt_c = {32{1'b0}} + 1'b1;
            end
            SM_S_READ16_PS1_EXEC: begin
                if(sys_cntr_r < READ16_LIMIT_S1-1) begin
                    sys_cntr_nxt_c = sys_cntr_r + 1'b1;
                end
                else begin
                    if(S0_READ_EN) begin
                        mstr_state_nxt_c = SM_S_READ16_PS10x_INIT;
                    end
                    else if(BYTE_ENABLE_S1) begin
                        mstr_state_nxt_c = SM_S_WRITE8_PS1_INIT;
                    end
                    else begin
                        mstr_state_nxt_c = SM_S_READ8_PS1_INIT;
                    end
                    sys_cntr_nxt_c = {32{1'b0}};
                end
            end
            // -------------------------------------
            // ----- 16-bit SEQ READ (port S0) -----
            // -------------------------------------
            SM_S_READ16_PS10x_INIT: begin
                mstr_state_nxt_c = SM_S_READ16_PS10x_HOLD;
                sys_cntr_nxt_c = {32{1'b0}};
            end
            SM_S_READ16_PS10x_HOLD: begin
                mstr_state_nxt_c = SM_S_READ16_PS10x_EXEC;
                sys_cntr_nxt_c = {32{1'b0}} + 1'b1;
            end
            SM_S_READ16_PS10x_EXEC: begin
                if(sys_cntr_r < READ16_LIMIT_S0-1) begin
                    sys_cntr_nxt_c = sys_cntr_r + 1'b1;
                end
                else begin
                    if(BYTE_ENABLE_S1) begin
                        mstr_state_nxt_c = SM_S_WRITE8_PS1_INIT;
                    end
                    else if(S1_READ_EN) begin
                        mstr_state_nxt_c = SM_S_READ8_PS1_INIT;
                    end
                    else begin
                        mstr_state_nxt_c = SM_S_READ8_PS10x_INIT;
                    end
                    sys_cntr_nxt_c = {32{1'b0}};
                end
            end
            // -------------------------------------
            // ----- 8-bit SEQ WRITE (port S1) -----
            // -------------------------------------
            SM_S_WRITE8_PS1_INIT: begin
                mstr_state_nxt_c = SM_S_WRITE8_PS1_HOLD;
                sys_cntr_nxt_c = {32{1'b0}};
            end
            SM_S_WRITE8_PS1_HOLD: begin
                mstr_state_nxt_c = SM_S_WRITE8_PS1_EXEC;
                sys_cntr_nxt_c = {32{1'b0}} + 1'b1;
            end
            SM_S_WRITE8_PS1_EXEC: begin
                if(sys_cntr_r < WRITE8_LIMIT_S1-1) begin
                    sys_cntr_nxt_c = sys_cntr_r + 1'b1;
                end
                else begin
                    if(S1_READ_EN) begin
                        mstr_state_nxt_c = SM_S_READ8_PS1_INIT;
                    end
                    else begin
                        mstr_state_nxt_c = SM_S_READ8_PS10x_INIT;
                    end
                    sys_cntr_nxt_c = {32{1'b0}};
                end
            end
            // ------------------------------------
            // ----- 8-bit SEQ READ (port S1) -----
            // ------------------------------------
            SM_S_READ8_PS1_INIT: begin
                mstr_state_nxt_c = SM_S_READ8_PS1_HOLD;
                sys_cntr_nxt_c = {32{1'b0}};
            end
            SM_S_READ8_PS1_HOLD: begin
                mstr_state_nxt_c = SM_S_READ8_PS1_EXEC;
                sys_cntr_nxt_c = {32{1'b0}} + 1'b1;
            end
            SM_S_READ8_PS1_EXEC: begin
                if(sys_cntr_r < READ8_LIMIT_S1-1) begin
                    sys_cntr_nxt_c = sys_cntr_r + 1'b1;
                end
                else begin
                    if(S0_READ_EN) begin
                        mstr_state_nxt_c = SM_S_READ8_PS10x_INIT;
                    end
                    else begin
                        mstr_state_nxt_c = SM_C_END;
                    end
                    sys_cntr_nxt_c = {32{1'b0}};
                end
            end
            // ------------------------------------
            // ----- 8-bit SEQ READ (port S0) -----
            // ------------------------------------
            SM_S_READ8_PS10x_INIT: begin
                mstr_state_nxt_c = SM_S_READ8_PS10x_HOLD;
                sys_cntr_nxt_c = {32{1'b0}};
            end
            SM_S_READ8_PS10x_HOLD: begin
                mstr_state_nxt_c = SM_S_READ8_PS10x_EXEC;
                sys_cntr_nxt_c = {32{1'b0}} + 1'b1;
            end
            SM_S_READ8_PS10x_EXEC: begin
                if(sys_cntr_r < READ8_LIMIT_S0-1) begin
                    sys_cntr_nxt_c = sys_cntr_r + 1'b1;
                end
                else begin
                    mstr_state_nxt_c = SM_C_END;
                    sys_cntr_nxt_c = {32{1'b0}};
                end
            end
            SM_C_END: begin
        
            end
            SM_C_ERROR: begin
        
            end
        endcase
    end
end

/*************************
 * PORT S0 hsel Controller 
 *************************/
always @ (*) begin
    ahbl_s0_hsel_nxt_c = // INITIALIZATION STATES
                         (mstr_state_nxt_c == SM_I_READ32_PS0_EXEC)      || 
                         (mstr_state_nxt_c == SM_I_READ16_PS0_EXEC)      ||
                         (mstr_state_nxt_c == SM_I_READ8_PS0_EXEC)       || 
                         // NON-SEQUENTIAL STATES (PORT S0 Priority)                        
                         (mstr_state_nxt_c == SM_N_WRITE32_PS0_EXEC)     || 
                         (mstr_state_nxt_c == SM_N_READ32_PS0_EXEC)      ||
                         (mstr_state_nxt_c == SM_N_WRITE16_PS0_EXEC)     || 
                         (mstr_state_nxt_c == SM_N_READ16_PS0_EXEC)      ||
                         (mstr_state_nxt_c == SM_N_WRITE8_PS0_EXEC)      || 
                         (mstr_state_nxt_c == SM_N_READ8_PS0_EXEC)       ||
                         // NON-SEQUENTIAL STATES (PORT S1 Priority)  
                         (mstr_state_nxt_c == SM_N_READ32_PS10x_EXEC)    ||
                         (mstr_state_nxt_c == SM_N_READ16_PS10x_EXEC)    || 
                         (mstr_state_nxt_c == SM_N_READ8_PS10x_EXEC)     ||
                         // WRITE TO READ STATES
                         (mstr_state_nxt_c == SM_N_WR_TO_READ_PS0_WRITE) || 
                         (mstr_state_nxt_c == SM_N_WR_TO_READ_PS0_READ)  ||
                         // SEQUENTIAL STATES (PORT S0 Priority) 
                         (mstr_state_nxt_c == SM_S_WRITE32_PS0_INIT)     ||
                         (mstr_state_nxt_c == SM_S_WRITE32_PS0_EXEC)     ||
                         (mstr_state_nxt_c == SM_S_WRITE32_PS0_HOLD)     ||
                         (mstr_state_nxt_c == SM_S_READ32_PS0_INIT)      ||
                         (mstr_state_nxt_c == SM_S_READ32_PS0_EXEC)      ||
                         (mstr_state_nxt_c == SM_S_READ32_PS0_HOLD)      ||
                         (mstr_state_nxt_c == SM_S_WRITE16_PS0_INIT)     || 
                         (mstr_state_nxt_c == SM_S_WRITE16_PS0_EXEC)     || 
                         (mstr_state_nxt_c == SM_S_WRITE16_PS0_HOLD)     ||
                         (mstr_state_nxt_c == SM_S_READ16_PS0_INIT)      || 
                         (mstr_state_nxt_c == SM_S_READ16_PS0_EXEC)      || 
                         (mstr_state_nxt_c == SM_S_READ16_PS0_HOLD)      ||
                         (mstr_state_nxt_c == SM_S_WRITE8_PS0_INIT)      ||
                         (mstr_state_nxt_c == SM_S_WRITE8_PS0_EXEC)      ||
                         (mstr_state_nxt_c == SM_S_WRITE8_PS0_HOLD)      ||
                         (mstr_state_nxt_c == SM_S_READ8_PS0_INIT)       || 
                         (mstr_state_nxt_c == SM_S_READ8_PS0_EXEC)       ||
                         (mstr_state_nxt_c == SM_S_READ8_PS0_HOLD)       ||
                         // SEQUENTIAL STATES (PORT S1 Priority)
                         (mstr_state_nxt_c == SM_S_READ32_PS10x_INIT)    ||
                         (mstr_state_nxt_c == SM_S_READ32_PS10x_EXEC)    ||
                         (mstr_state_nxt_c == SM_S_READ32_PS10x_HOLD)    ||
                         (mstr_state_nxt_c == SM_S_READ16_PS10x_INIT)    ||
                         (mstr_state_nxt_c == SM_S_READ16_PS10x_EXEC)    ||
                         (mstr_state_nxt_c == SM_S_READ16_PS10x_HOLD)    ||
                         (mstr_state_nxt_c == SM_S_READ8_PS10x_INIT)     ||
                         (mstr_state_nxt_c == SM_S_READ8_PS10x_EXEC)     ||
                         (mstr_state_nxt_c == SM_S_READ8_PS10x_HOLD);
    
end

/****************************
 * PORT S0 Address Controller 
 ****************************/
always @ (*) begin
    ahbl_s0_haddr_nxt_c = ahbl_s0_haddr_r;
    case(mstr_state_nxt_c)
        // INITIALIZATION
        SM_I_READ32_PS0_INIT:     ahbl_s0_haddr_nxt_c = S0_START_ADDR_FIN;
        SM_I_READ32_PS0_HOLD:     ahbl_s0_haddr_nxt_c = ahbl_s0_haddr_r + ADDR_32_OFF;
        SM_I_READ16_PS0_INIT:     ahbl_s0_haddr_nxt_c = S0_START_ADDR_FIN;
        SM_I_READ16_PS0_HOLD:     ahbl_s0_haddr_nxt_c = ahbl_s0_haddr_r + ADDR_16_OFF;
        SM_I_READ8_PS0_INIT:      ahbl_s0_haddr_nxt_c = S0_START_ADDR_FIN;
        SM_I_READ8_PS0_HOLD:      ahbl_s0_haddr_nxt_c = ahbl_s0_haddr_r + ADDR_8_OFF;
        // NON-SEQUENTIAL PORT S0 PRIORITY
        SM_N_WRITE32_PS0_INIT:    ahbl_s0_haddr_nxt_c = S0_START_ADDR_FIN;
        SM_N_WRITE32_PS0_HOLD:    ahbl_s0_haddr_nxt_c = ahbl_s0_haddr_r + ADDR_32_OFF;
        SM_N_READ32_PS0_INIT:     ahbl_s0_haddr_nxt_c = S0_START_ADDR_FIN;
        SM_N_READ32_PS0_HOLD:     ahbl_s0_haddr_nxt_c = ahbl_s0_haddr_r + ADDR_32_OFF;
        SM_N_WRITE16_PS0_INIT:    ahbl_s0_haddr_nxt_c = S0_START_ADDR_FIN;
        SM_N_WRITE16_PS0_HOLD:    ahbl_s0_haddr_nxt_c = ahbl_s0_haddr_r + ADDR_16_OFF;
        SM_N_READ16_PS0_INIT:     ahbl_s0_haddr_nxt_c = S0_START_ADDR_FIN;
        SM_N_READ16_PS0_HOLD:     ahbl_s0_haddr_nxt_c = ahbl_s0_haddr_r + ADDR_16_OFF;
        SM_N_WRITE8_PS0_INIT:     ahbl_s0_haddr_nxt_c = S0_START_ADDR_FIN;
        SM_N_WRITE8_PS0_HOLD:     ahbl_s0_haddr_nxt_c = ahbl_s0_haddr_r + ADDR_8_OFF;
        SM_N_READ8_PS0_INIT:      ahbl_s0_haddr_nxt_c = S0_START_ADDR_FIN;
        SM_N_READ8_PS0_HOLD:      ahbl_s0_haddr_nxt_c = ahbl_s0_haddr_r + ADDR_8_OFF;
        // NON-SEQUENTIAL PORT S1 PRIORITY
        SM_N_READ32_PS10x_INIT:   ahbl_s0_haddr_nxt_c = S0_START_ADDR_FIN;
        SM_N_READ32_PS10x_HOLD:   ahbl_s0_haddr_nxt_c = ahbl_s0_haddr_r + ADDR_32_OFF;
        SM_N_READ16_PS10x_INIT:   ahbl_s0_haddr_nxt_c = S0_START_ADDR_FIN;
        SM_N_READ16_PS10x_HOLD:   ahbl_s0_haddr_nxt_c = ahbl_s0_haddr_r + ADDR_16_OFF;
        SM_N_READ8_PS10x_INIT:    ahbl_s0_haddr_nxt_c = S0_START_ADDR_FIN;
        SM_N_READ8_PS10x_HOLD:    ahbl_s0_haddr_nxt_c = ahbl_s0_haddr_r + ADDR_8_OFF;
        // WRITE-TO-READ
        SM_N_WR_TO_READ_PS0_INIT: ahbl_s0_haddr_nxt_c = S0_START_ADDR_FIN;
        SM_N_WR_TO_READ_PS0_HOLD: ahbl_s0_haddr_nxt_c = ahbl_s0_haddr_r + WR2RD_INC_S0;
        // SEQUENTIAL PORT S0 PRIORITY
        SM_S_WRITE32_PS0_INIT:    ahbl_s0_haddr_nxt_c = S0_START_ADDR_FIN;
        SM_S_WRITE32_PS0_EXEC:    ahbl_s0_haddr_nxt_c = ahbl_s0_haddr_r + ADDR_32_OFF;
        SM_S_WRITE32_PS0_HOLD:    ahbl_s0_haddr_nxt_c = S0_START_ADDR_FIN + ADDR_32_OFF;
        SM_S_READ32_PS0_INIT:     ahbl_s0_haddr_nxt_c = S0_START_ADDR_FIN;
        SM_S_READ32_PS0_EXEC:     ahbl_s0_haddr_nxt_c = ahbl_s0_haddr_r + ADDR_32_OFF;
        SM_S_READ32_PS0_HOLD:     ahbl_s0_haddr_nxt_c = S0_START_ADDR_FIN + ADDR_32_OFF;
        SM_S_WRITE16_PS0_INIT:    ahbl_s0_haddr_nxt_c = S0_START_ADDR_FIN;
        SM_S_WRITE16_PS0_EXEC:    ahbl_s0_haddr_nxt_c = ahbl_s0_haddr_r + ADDR_16_OFF;
        SM_S_WRITE16_PS0_HOLD:    ahbl_s0_haddr_nxt_c = S0_START_ADDR_FIN + ADDR_16_OFF;
        SM_S_READ16_PS0_INIT:     ahbl_s0_haddr_nxt_c = S0_START_ADDR_FIN;
        SM_S_READ16_PS0_EXEC:     ahbl_s0_haddr_nxt_c = ahbl_s0_haddr_r + ADDR_16_OFF;
        SM_S_READ16_PS0_HOLD:     ahbl_s0_haddr_nxt_c = S0_START_ADDR_FIN + ADDR_16_OFF;
        SM_S_WRITE8_PS0_INIT:     ahbl_s0_haddr_nxt_c = S0_START_ADDR_FIN;
        SM_S_WRITE8_PS0_EXEC:     ahbl_s0_haddr_nxt_c = ahbl_s0_haddr_r + ADDR_8_OFF;
        SM_S_WRITE8_PS0_HOLD:     ahbl_s0_haddr_nxt_c = S0_START_ADDR_FIN + ADDR_8_OFF;
        SM_S_READ8_PS0_INIT:      ahbl_s0_haddr_nxt_c = S0_START_ADDR_FIN;
        SM_S_READ8_PS0_EXEC:      ahbl_s0_haddr_nxt_c = ahbl_s0_haddr_r + ADDR_8_OFF;
        SM_S_READ8_PS0_HOLD:      ahbl_s0_haddr_nxt_c = S0_START_ADDR_FIN + ADDR_8_OFF;
        // SEQUENTIAL PORT S1 PRIORITY
        SM_S_READ32_PS10x_INIT:   ahbl_s0_haddr_nxt_c = S0_START_ADDR_FIN;
        SM_S_READ32_PS10x_EXEC:   ahbl_s0_haddr_nxt_c = ahbl_s0_haddr_r + ADDR_32_OFF;
        SM_S_READ32_PS10x_HOLD:   ahbl_s0_haddr_nxt_c = S0_START_ADDR_FIN + ADDR_32_OFF;
        SM_S_READ16_PS10x_INIT:   ahbl_s0_haddr_nxt_c = S0_START_ADDR_FIN;
        SM_S_READ16_PS10x_EXEC:   ahbl_s0_haddr_nxt_c = ahbl_s0_haddr_r + ADDR_16_OFF;
        SM_S_READ16_PS10x_HOLD:   ahbl_s0_haddr_nxt_c = S0_START_ADDR_FIN + ADDR_16_OFF;
        SM_S_READ8_PS10x_INIT:    ahbl_s0_haddr_nxt_c = S0_START_ADDR_FIN;
        SM_S_READ8_PS10x_EXEC:    ahbl_s0_haddr_nxt_c = ahbl_s0_haddr_r + ADDR_8_OFF;
        SM_S_READ8_PS10x_HOLD:    ahbl_s0_haddr_nxt_c = S0_START_ADDR_FIN + ADDR_8_OFF;
    endcase
end

/**************************
 * PORT S0 hsize Controller 
 **************************/
always @ (*) begin
    ahbl_s0_hsize_nxt_c = ahbl_s0_hsize_r;
    case(mstr_state_nxt_c)
        SM_C_START                 : ahbl_s0_hsize_nxt_c = DEFAULT_HSIZE;
        // INITIALIZATION                           
        SM_I_READ32_PS0_INIT       : ahbl_s0_hsize_nxt_c = X32_WORD;
        SM_I_READ32_PS0_EXEC       : ahbl_s0_hsize_nxt_c = X32_WORD;
        SM_I_READ32_PS0_HOLD       : ahbl_s0_hsize_nxt_c = X32_WORD;
        SM_I_READ16_PS0_INIT       : ahbl_s0_hsize_nxt_c = X16_HALFWORD;
        SM_I_READ16_PS0_EXEC       : ahbl_s0_hsize_nxt_c = X16_HALFWORD;
        SM_I_READ16_PS0_HOLD       : ahbl_s0_hsize_nxt_c = X16_HALFWORD;
        SM_I_READ8_PS0_INIT        : ahbl_s0_hsize_nxt_c = X8_BYTE;
        SM_I_READ8_PS0_EXEC        : ahbl_s0_hsize_nxt_c = X8_BYTE;
        SM_I_READ8_PS0_HOLD        : ahbl_s0_hsize_nxt_c = X8_BYTE;
        // NON-SEQUENTIAL (PORT S0 PRIORITY)                                    
        SM_N_WRITE32_PS0_INIT      : ahbl_s0_hsize_nxt_c = X32_WORD;
        SM_N_WRITE32_PS0_EXEC      : ahbl_s0_hsize_nxt_c = X32_WORD;
        SM_N_WRITE32_PS0_HOLD      : ahbl_s0_hsize_nxt_c = X32_WORD;
        SM_N_READ32_PS0_INIT       : ahbl_s0_hsize_nxt_c = X32_WORD;
        SM_N_READ32_PS0_EXEC       : ahbl_s0_hsize_nxt_c = X32_WORD;
        SM_N_READ32_PS0_HOLD       : ahbl_s0_hsize_nxt_c = X32_WORD;
        SM_N_WRITE16_PS0_INIT      : ahbl_s0_hsize_nxt_c = X16_HALFWORD;
        SM_N_WRITE16_PS0_EXEC      : ahbl_s0_hsize_nxt_c = X16_HALFWORD;
        SM_N_WRITE16_PS0_HOLD      : ahbl_s0_hsize_nxt_c = X16_HALFWORD;
        SM_N_READ16_PS0_INIT       : ahbl_s0_hsize_nxt_c = X16_HALFWORD;
        SM_N_READ16_PS0_EXEC       : ahbl_s0_hsize_nxt_c = X16_HALFWORD;
        SM_N_READ16_PS0_HOLD       : ahbl_s0_hsize_nxt_c = X16_HALFWORD;
        SM_N_WRITE8_PS0_INIT       : ahbl_s0_hsize_nxt_c = X8_BYTE;
        SM_N_WRITE8_PS0_EXEC       : ahbl_s0_hsize_nxt_c = X8_BYTE;
        SM_N_WRITE8_PS0_HOLD       : ahbl_s0_hsize_nxt_c = X8_BYTE;
        SM_N_READ8_PS0_INIT        : ahbl_s0_hsize_nxt_c = X8_BYTE;
        SM_N_READ8_PS0_EXEC        : ahbl_s0_hsize_nxt_c = X8_BYTE;
        SM_N_READ8_PS0_HOLD        : ahbl_s0_hsize_nxt_c = X8_BYTE;
        // NON-SEQUENTIAL (PORT S1 PRIORITY)                                          
        SM_N_READ32_PS10x_INIT     : ahbl_s0_hsize_nxt_c = X32_WORD;
        SM_N_READ32_PS10x_EXEC     : ahbl_s0_hsize_nxt_c = X32_WORD;
        SM_N_READ32_PS10x_HOLD     : ahbl_s0_hsize_nxt_c = X32_WORD;
        SM_N_READ16_PS10x_INIT     : ahbl_s0_hsize_nxt_c = X16_HALFWORD;
        SM_N_READ16_PS10x_EXEC     : ahbl_s0_hsize_nxt_c = X16_HALFWORD;
        SM_N_READ16_PS10x_HOLD     : ahbl_s0_hsize_nxt_c = X16_HALFWORD;
        SM_N_READ8_PS10x_INIT      : ahbl_s0_hsize_nxt_c = X8_BYTE;
        SM_N_READ8_PS10x_EXEC      : ahbl_s0_hsize_nxt_c = X8_BYTE;
        SM_N_READ8_PS10x_HOLD      : ahbl_s0_hsize_nxt_c = X8_BYTE;
        // WRITE-TO-READ                                      
        SM_N_WR_TO_READ_PS0_INIT   : ahbl_s0_hsize_nxt_c = DEFAULT_HSIZE;
        SM_N_WR_TO_READ_PS0_WRITE  : ahbl_s0_hsize_nxt_c = DEFAULT_HSIZE;
        SM_N_WR_TO_READ_PS0_READ   : ahbl_s0_hsize_nxt_c = DEFAULT_HSIZE;
        SM_N_WR_TO_READ_PS0_HOLD   : ahbl_s0_hsize_nxt_c = DEFAULT_HSIZE;
        // SEQUENTIAL (PORT S0 PRIORITY)         
        SM_S_WRITE32_PS0_INIT      : ahbl_s0_hsize_nxt_c = X32_WORD;
        SM_S_WRITE32_PS0_EXEC      : ahbl_s0_hsize_nxt_c = X32_WORD;
        SM_S_WRITE32_PS0_HOLD      : ahbl_s0_hsize_nxt_c = X32_WORD;
        SM_S_READ32_PS0_INIT       : ahbl_s0_hsize_nxt_c = X32_WORD;
        SM_S_READ32_PS0_EXEC       : ahbl_s0_hsize_nxt_c = X32_WORD;
        SM_S_READ32_PS0_HOLD       : ahbl_s0_hsize_nxt_c = X32_WORD;
        SM_S_WRITE16_PS0_INIT      : ahbl_s0_hsize_nxt_c = X16_HALFWORD;
        SM_S_WRITE16_PS0_EXEC      : ahbl_s0_hsize_nxt_c = X16_HALFWORD;
        SM_S_WRITE16_PS0_HOLD      : ahbl_s0_hsize_nxt_c = X16_HALFWORD;
        SM_S_READ16_PS0_INIT       : ahbl_s0_hsize_nxt_c = X16_HALFWORD;
        SM_S_READ16_PS0_EXEC       : ahbl_s0_hsize_nxt_c = X16_HALFWORD;
        SM_S_READ16_PS0_HOLD       : ahbl_s0_hsize_nxt_c = X16_HALFWORD;
        SM_S_WRITE8_PS0_INIT       : ahbl_s0_hsize_nxt_c = X8_BYTE;
        SM_S_WRITE8_PS0_EXEC       : ahbl_s0_hsize_nxt_c = X8_BYTE;
        SM_S_WRITE8_PS0_HOLD       : ahbl_s0_hsize_nxt_c = X8_BYTE;
        SM_S_READ8_PS0_INIT        : ahbl_s0_hsize_nxt_c = X8_BYTE;
        SM_S_READ8_PS0_EXEC        : ahbl_s0_hsize_nxt_c = X8_BYTE;
        SM_S_READ8_PS0_HOLD        : ahbl_s0_hsize_nxt_c = X8_BYTE;
        // SEQUENTIAL (PORT S1 PRIORITY)           
        SM_S_READ32_PS10x_INIT     : ahbl_s0_hsize_nxt_c = X32_WORD;
        SM_S_READ32_PS10x_EXEC     : ahbl_s0_hsize_nxt_c = X32_WORD;
        SM_S_READ32_PS10x_HOLD     : ahbl_s0_hsize_nxt_c = X32_WORD;
        SM_S_READ16_PS10x_INIT     : ahbl_s0_hsize_nxt_c = X16_HALFWORD;
        SM_S_READ16_PS10x_EXEC     : ahbl_s0_hsize_nxt_c = X16_HALFWORD;
        SM_S_READ16_PS10x_HOLD     : ahbl_s0_hsize_nxt_c = X16_HALFWORD;
        SM_S_READ8_PS10x_INIT      : ahbl_s0_hsize_nxt_c = X8_BYTE;
        SM_S_READ8_PS10x_EXEC      : ahbl_s0_hsize_nxt_c = X8_BYTE;
        SM_S_READ8_PS10x_HOLD      : ahbl_s0_hsize_nxt_c = X8_BYTE;
        // END and ERROR          
        SM_C_END                   : ahbl_s0_hsize_nxt_c = DEFAULT_HSIZE;
        SM_C_ERROR                 : ahbl_s0_hsize_nxt_c = DEFAULT_HSIZE;
    endcase
end

/***************************
 * PORT S0 htrans Controller 
 ***************************/
always @ (*) begin
    ahbl_s0_htrans_nxt_c = ahbl_s0_htrans_r;
    case(mstr_state_nxt_c)
        // INITIALIZATION                           
        SM_I_READ32_PS0_EXEC       : ahbl_s0_htrans_nxt_c = NSEQ;
        SM_I_READ16_PS0_EXEC       : ahbl_s0_htrans_nxt_c = NSEQ;
        SM_I_READ8_PS0_EXEC        : ahbl_s0_htrans_nxt_c = NSEQ;
        // NON-SEQUENTIAL (PORT S0 PRIORITY)                                    
        SM_N_WRITE32_PS0_EXEC      : ahbl_s0_htrans_nxt_c = NSEQ;
        SM_N_READ32_PS0_EXEC       : ahbl_s0_htrans_nxt_c = NSEQ;
        SM_N_WRITE16_PS0_EXEC      : ahbl_s0_htrans_nxt_c = NSEQ;
        SM_N_READ16_PS0_EXEC       : ahbl_s0_htrans_nxt_c = NSEQ;
        SM_N_WRITE8_PS0_EXEC       : ahbl_s0_htrans_nxt_c = NSEQ;
        SM_N_READ8_PS0_EXEC        : ahbl_s0_htrans_nxt_c = NSEQ;
        // NON-SEQUENTIAL (PORT S1 PRIORITY)                                          
        SM_N_READ32_PS10x_EXEC     : ahbl_s0_htrans_nxt_c = NSEQ;
        SM_N_READ16_PS10x_EXEC     : ahbl_s0_htrans_nxt_c = NSEQ;
        SM_N_READ8_PS10x_EXEC      : ahbl_s0_htrans_nxt_c = NSEQ;
        // WRITE-TO-READ                                      
        SM_N_WR_TO_READ_PS0_WRITE  : ahbl_s0_htrans_nxt_c = NSEQ;
        SM_N_WR_TO_READ_PS0_READ   : ahbl_s0_htrans_nxt_c = NSEQ;
        // SEQUENTIAL (PORT S0 PRIORITY)         
        SM_S_WRITE32_PS0_INIT      : ahbl_s0_htrans_nxt_c = NSEQ;
        SM_S_WRITE32_PS0_EXEC      : ahbl_s0_htrans_nxt_c = SEQ;
        SM_S_WRITE32_PS0_HOLD      : ahbl_s0_htrans_nxt_c = SEQ;
        SM_S_READ32_PS0_INIT       : ahbl_s0_htrans_nxt_c = NSEQ;
        SM_S_READ32_PS0_EXEC       : ahbl_s0_htrans_nxt_c = SEQ;
        SM_S_READ32_PS0_HOLD       : ahbl_s0_htrans_nxt_c = SEQ;
        SM_S_WRITE16_PS0_INIT      : ahbl_s0_htrans_nxt_c = NSEQ;
        SM_S_WRITE16_PS0_EXEC      : ahbl_s0_htrans_nxt_c = SEQ;
        SM_S_WRITE16_PS0_HOLD      : ahbl_s0_htrans_nxt_c = SEQ;
        SM_S_READ16_PS0_INIT       : ahbl_s0_htrans_nxt_c = NSEQ;
        SM_S_READ16_PS0_EXEC       : ahbl_s0_htrans_nxt_c = SEQ;
        SM_S_READ16_PS0_HOLD       : ahbl_s0_htrans_nxt_c = SEQ;
        SM_S_WRITE8_PS0_INIT       : ahbl_s0_htrans_nxt_c = NSEQ;
        SM_S_WRITE8_PS0_EXEC       : ahbl_s0_htrans_nxt_c = SEQ;
        SM_S_WRITE8_PS0_HOLD       : ahbl_s0_htrans_nxt_c = SEQ;
        SM_S_READ8_PS0_INIT        : ahbl_s0_htrans_nxt_c = NSEQ;
        SM_S_READ8_PS0_EXEC        : ahbl_s0_htrans_nxt_c = SEQ;
        SM_S_READ8_PS0_HOLD        : ahbl_s0_htrans_nxt_c = SEQ;
        // SEQUENTIAL (PORT S1 PRIORITY)           
        SM_S_READ32_PS10x_INIT     : ahbl_s0_htrans_nxt_c = NSEQ;
        SM_S_READ32_PS10x_EXEC     : ahbl_s0_htrans_nxt_c = SEQ;
        SM_S_READ32_PS10x_HOLD     : ahbl_s0_htrans_nxt_c = SEQ;
        SM_S_READ16_PS10x_INIT     : ahbl_s0_htrans_nxt_c = NSEQ;
        SM_S_READ16_PS10x_EXEC     : ahbl_s0_htrans_nxt_c = SEQ;
        SM_S_READ16_PS10x_HOLD     : ahbl_s0_htrans_nxt_c = SEQ;
        SM_S_READ8_PS10x_INIT      : ahbl_s0_htrans_nxt_c = NSEQ;
        SM_S_READ8_PS10x_EXEC      : ahbl_s0_htrans_nxt_c = SEQ;
        SM_S_READ8_PS10x_HOLD      : ahbl_s0_htrans_nxt_c = SEQ;
        // END and ERROR          
        default                    : ahbl_s0_htrans_nxt_c = IDLE;
    endcase
end

/***************************
 * PORT S0 hwrite controller 
 ***************************/
always @ (*) begin
    ahbl_s0_hwrite_nxt_c = ahbl_s0_hwrite_r;
    case(mstr_state_nxt_c)
        // NON-SEQUENTIAL (PORT S0 PRIORITY)                                    
        SM_N_WRITE32_PS0_EXEC      : ahbl_s0_hwrite_nxt_c = 1'b1;
        SM_N_WRITE16_PS0_EXEC      : ahbl_s0_hwrite_nxt_c = 1'b1;
        SM_N_WRITE8_PS0_EXEC       : ahbl_s0_hwrite_nxt_c = 1'b1;                                      
        // WRITE-TO-READ                                      
        SM_N_WR_TO_READ_PS0_WRITE  : ahbl_s0_hwrite_nxt_c = 1'b1;
        // SEQUENTIAL (PORT S0 PRIORITY)         
        SM_S_WRITE32_PS0_INIT      : ahbl_s0_hwrite_nxt_c = 1'b1;
        SM_S_WRITE32_PS0_EXEC      : ahbl_s0_hwrite_nxt_c = 1'b1;
        SM_S_WRITE32_PS0_HOLD      : ahbl_s0_hwrite_nxt_c = 1'b1;
        SM_S_WRITE16_PS0_INIT      : ahbl_s0_hwrite_nxt_c = 1'b1;
        SM_S_WRITE16_PS0_EXEC      : ahbl_s0_hwrite_nxt_c = 1'b1;
        SM_S_WRITE16_PS0_HOLD      : ahbl_s0_hwrite_nxt_c = 1'b1;
        SM_S_WRITE8_PS0_INIT       : ahbl_s0_hwrite_nxt_c = 1'b1;
        SM_S_WRITE8_PS0_EXEC       : ahbl_s0_hwrite_nxt_c = 1'b1;
        SM_S_WRITE8_PS0_HOLD       : ahbl_s0_hwrite_nxt_c = 1'b1;
        default                    : ahbl_s0_hwrite_nxt_c = 1'b0;
    endcase
end

/***************************
 * PORT S0 hw_data controller 
 ***************************/

wire [31:0] tmem32_32_s0 = mem_s0[ahbl_s0_haddr_r >> 2];
wire [31:0] tmem32_16_s0 = mem_s0_16[ahbl_s0_haddr_r >> 2];
wire [31:0] tmem32_8_s0  = mem_s0_8[ahbl_s0_haddr_r >> 2];
wire [15:0] tmem16_16_s0 [1:0];
wire [15:0] tmem16_8_s0 [1:0];
wire [7:0] tmem8_s0 [3:0];

genvar ix0;
for(ix0 = 0; ix0 < 2; ix0 = ix0 + 1) begin
    assign tmem16_16_s0[ix0] = tmem32_16_s0[15+16*ix0:16*ix0];
    assign tmem16_8_s0[ix0] = tmem32_8_s0[15+16*ix0:16*ix0];
end
for(ix0 = 0; ix0 < 4; ix0 = ix0 + 1) begin
    assign tmem8_s0[ix0] = tmem32_8_s0[7+8*ix0:8*ix0];
end

always @ (*) begin
    ahbl_s0_hwdata_nxt_c = ahbl_s0_hwdata_r;
    case(mstr_state_nxt_c)
    /**********************************
     * WRITE DATA during WRITE STATES *
     **********************************/
        SM_N_WRITE32_PS0_HOLD:     ahbl_s0_hwdata_nxt_c = tmem32_32_s0;
        SM_N_WRITE16_PS0_HOLD:     begin
            case(DATA_WIDTH)
                32: ahbl_s0_hwdata_nxt_c = tmem32_16_s0;
                16: ahbl_s0_hwdata_nxt_c = tmem16_16_s0[ahbl_s0_haddr_r[1]];
            endcase
        end
        SM_N_WRITE8_PS0_HOLD:      begin
            case(DATA_WIDTH)
                32: ahbl_s0_hwdata_nxt_c = tmem32_8_s0;
                16: ahbl_s0_hwdata_nxt_c = tmem16_8_s0[ahbl_s0_haddr_r[1]];
                8:  ahbl_s0_hwdata_nxt_c = tmem8_s0[ahbl_s0_haddr_r[1:0]];
            endcase
        end
        SM_N_WR_TO_READ_PS0_READ: begin
            case(DATA_WIDTH)
                32: ahbl_s0_hwdata_nxt_c = tmem32_32_s0;
                16: ahbl_s0_hwdata_nxt_c = tmem16_16_s0[ahbl_s0_haddr_r[1]];
                8:  ahbl_s0_hwdata_nxt_c = tmem8_s0[ahbl_s0_haddr_r[1:0]];
            endcase
        end
        SM_S_WRITE32_PS0_EXEC:     ahbl_s0_hwdata_nxt_c = tmem32_32_s0;
        SM_S_WRITE32_PS0_HOLD:     ahbl_s0_hwdata_nxt_c = tmem32_32_s0;
        SM_S_WRITE16_PS0_EXEC:     begin
            case(DATA_WIDTH)
                32: ahbl_s0_hwdata_nxt_c = tmem32_16_s0;
                16: ahbl_s0_hwdata_nxt_c = tmem16_16_s0[ahbl_s0_haddr_r[1]];
            endcase
        end
        SM_S_WRITE16_PS0_HOLD:     begin
            case(DATA_WIDTH)
                32: ahbl_s0_hwdata_nxt_c = tmem32_16_s0;
                16: ahbl_s0_hwdata_nxt_c = tmem16_16_s0[ahbl_s0_haddr_r[1]];
            endcase
        end
        SM_S_WRITE8_PS0_EXEC:      begin
            case(DATA_WIDTH)
                32: ahbl_s0_hwdata_nxt_c = tmem32_8_s0;
                16: ahbl_s0_hwdata_nxt_c = tmem16_8_s0[ahbl_s0_haddr_r[1]];
                8:  ahbl_s0_hwdata_nxt_c = tmem8_s0[ahbl_s0_haddr_r[1:0]];
            endcase
        end
        SM_S_WRITE8_PS0_HOLD:      begin
            case(DATA_WIDTH)
                32: ahbl_s0_hwdata_nxt_c = tmem32_8_s0;
                16: ahbl_s0_hwdata_nxt_c = tmem16_8_s0[ahbl_s0_haddr_r[1]];
                8:  ahbl_s0_hwdata_nxt_c = tmem8_s0[ahbl_s0_haddr_r[1:0]];
            endcase
        end
    /******************************************
     * WRITE DATA with READ STATE NEXT (NSEQ) *
     ******************************************/
        SM_N_READ32_PS0_INIT: begin
            if(mstr_state_r == SM_N_WRITE32_PS0_EXEC) begin
                ahbl_s0_hwdata_nxt_c = tmem32_32_s0;
            end
            else begin
                ahbl_s0_hwdata_nxt_c = {DATA_WIDTH{1'b0}};
            end
        end
        SM_N_READ32_PS01x_INIT: begin
            if(mstr_state_r == SM_N_WRITE32_PS0_EXEC) begin
                ahbl_s0_hwdata_nxt_c = tmem32_32_s0;
            end
            else begin
                ahbl_s0_hwdata_nxt_c = {DATA_WIDTH{1'b0}};
            end
        end
        SM_N_READ16_PS0_INIT: begin
            if(mstr_state_r == SM_N_WRITE16_PS0_EXEC) begin
                case(DATA_WIDTH)
                    32: ahbl_s0_hwdata_nxt_c = tmem32_16_s0;
                    16: ahbl_s0_hwdata_nxt_c = tmem16_16_s0[ahbl_s0_haddr_r[1]];
                endcase
            end
            else begin
                ahbl_s0_hwdata_nxt_c = {DATA_WIDTH{1'b0}};
            end
        end
        SM_N_READ16_PS01x_INIT: begin
            if(mstr_state_r == SM_N_WRITE16_PS0_EXEC) begin
                case(DATA_WIDTH)
                    32: ahbl_s0_hwdata_nxt_c = tmem32_16_s0;
                    16: ahbl_s0_hwdata_nxt_c = tmem16_16_s0[ahbl_s0_haddr_r[1]];
                endcase
            end
            else begin
                ahbl_s0_hwdata_nxt_c = {DATA_WIDTH{1'b0}};
            end
        end
        SM_N_READ8_PS0_INIT: begin
            if(mstr_state_r == SM_N_WRITE8_PS0_EXEC) begin
                case(DATA_WIDTH)
                    32: ahbl_s0_hwdata_nxt_c = tmem32_8_s0;
                    16: ahbl_s0_hwdata_nxt_c = tmem16_8_s0[ahbl_s0_haddr_r[1]];
                    8:  ahbl_s0_hwdata_nxt_c = tmem8_s0[ahbl_s0_haddr_r[1:0]];
                endcase
            end
            else begin
                ahbl_s0_hwdata_nxt_c = {DATA_WIDTH{1'b0}};
            end
        end
        SM_N_READ8_PS01x_INIT: begin
            if(mstr_state_r == SM_N_WRITE8_PS0_EXEC) begin
                case(DATA_WIDTH)
                    32: ahbl_s0_hwdata_nxt_c = tmem32_8_s0;
                    16: ahbl_s0_hwdata_nxt_c = tmem16_8_s0[ahbl_s0_haddr_r[1]];
                    8:  ahbl_s0_hwdata_nxt_c = tmem8_s0[ahbl_s0_haddr_r[1:0]];
                endcase
            end
            else begin
                ahbl_s0_hwdata_nxt_c = {DATA_WIDTH{1'b0}};
            end
        end
    /*****************************************
     * WRITE DATA with READ STATE NEXT (SEQ) *
     *****************************************/
        SM_S_READ32_PS0_INIT: begin
            if(mstr_state_r == SM_S_WRITE32_PS0_EXEC) begin
                ahbl_s0_hwdata_nxt_c = tmem32_32_s0;
            end
            else begin
                ahbl_s0_hwdata_nxt_c = {DATA_WIDTH{1'b0}};
            end
        end
        SM_S_READ32_PS01x_INIT: begin
            if(mstr_state_r == SM_S_WRITE32_PS0_EXEC) begin
                ahbl_s0_hwdata_nxt_c = tmem32_32_s0;
            end
            else begin
                ahbl_s0_hwdata_nxt_c = {DATA_WIDTH{1'b0}};
            end
        end
        SM_S_READ16_PS0_INIT: begin
            if(mstr_state_r == SM_S_WRITE16_PS0_EXEC) begin
                case(DATA_WIDTH)
                    32: ahbl_s0_hwdata_nxt_c = tmem32_16_s0;
                    16: ahbl_s0_hwdata_nxt_c = tmem16_16_s0[ahbl_s0_haddr_r[1]];
                endcase
            end
            else begin
                ahbl_s0_hwdata_nxt_c = {DATA_WIDTH{1'b0}};
            end
        end
        SM_S_READ16_PS01x_INIT: begin
            if(mstr_state_r == SM_S_WRITE16_PS0_EXEC) begin
                case(DATA_WIDTH)
                    32: ahbl_s0_hwdata_nxt_c = tmem32_16_s0;
                    16: ahbl_s0_hwdata_nxt_c = tmem16_16_s0[ahbl_s0_haddr_r[1]];
                endcase
            end
            else begin
                ahbl_s0_hwdata_nxt_c = {DATA_WIDTH{1'b0}};
            end
        end
        SM_S_READ8_PS0_INIT: begin
            if(mstr_state_r == SM_S_WRITE8_PS0_EXEC) begin
                case(DATA_WIDTH)
                    32: ahbl_s0_hwdata_nxt_c = tmem32_8_s0;
                    16: ahbl_s0_hwdata_nxt_c = tmem16_8_s0[ahbl_s0_haddr_r[1]];
                    8:  ahbl_s0_hwdata_nxt_c = tmem8_s0[ahbl_s0_haddr_r[1:0]];
                endcase
            end
            else begin
                ahbl_s0_hwdata_nxt_c = {DATA_WIDTH{1'b0}};
            end
        end
        SM_S_READ8_PS01x_INIT: begin
            if(mstr_state_r == SM_S_WRITE8_PS0_EXEC) begin
                case(DATA_WIDTH)
                    32: ahbl_s0_hwdata_nxt_c = tmem32_8_s0;
                    16: ahbl_s0_hwdata_nxt_c = tmem16_8_s0[ahbl_s0_haddr_r[1]];
                    8:  ahbl_s0_hwdata_nxt_c = tmem8_s0[ahbl_s0_haddr_r[1:0]];
                endcase
            end
            else begin
                ahbl_s0_hwdata_nxt_c = {DATA_WIDTH{1'b0}};
            end
        end
        default:    ahbl_s0_hwdata_nxt_c = {DATA_WIDTH{1'b0}};
    endcase
end

/*************************
 * PORT S1 hsel Controller 
 *************************/
always @ (*) begin
    ahbl_s1_hsel_nxt_c = // INITIALIZATION STATES
                         (mstr_state_nxt_c == SM_I_READ32_PS1_EXEC)      || 
                         (mstr_state_nxt_c == SM_I_READ16_PS1_EXEC)      ||
                         (mstr_state_nxt_c == SM_I_READ8_PS1_EXEC)       || 
                         // NON-SEQUENTIAL STATES (PORT S0 Priority)                        
                         (mstr_state_nxt_c == SM_N_READ32_PS01x_EXEC)    || 
                         (mstr_state_nxt_c == SM_N_READ16_PS01x_EXEC)    ||
                         (mstr_state_nxt_c == SM_N_READ8_PS01x_EXEC)     || 
                         // NON-SEQUENTIAL STATES (PORT S1 Priority)
                         (mstr_state_nxt_c == SM_N_WRITE32_PS1_EXEC)     ||
                         (mstr_state_nxt_c == SM_N_READ32_PS1_EXEC)      || 
                         (mstr_state_nxt_c == SM_N_WRITE16_PS1_EXEC)     ||
                         (mstr_state_nxt_c == SM_N_READ16_PS1_EXEC)      ||
                         (mstr_state_nxt_c == SM_N_WRITE8_PS1_EXEC)      || 
                         (mstr_state_nxt_c == SM_N_READ8_PS1_EXEC)       ||
                         // WRITE TO READ STATES
                         (mstr_state_nxt_c == SM_N_WR_TO_READ_PS1_WRITE) || 
                         (mstr_state_nxt_c == SM_N_WR_TO_READ_PS1_READ)  ||
                         // SEQUENTIAL STATES (PORT S0 Priority) 
                         (mstr_state_nxt_c == SM_S_READ32_PS01x_INIT)    ||
                         (mstr_state_nxt_c == SM_S_READ32_PS01x_EXEC)    ||
                         (mstr_state_nxt_c == SM_S_READ32_PS01x_HOLD)    ||
                         (mstr_state_nxt_c == SM_S_READ16_PS01x_INIT)    ||
                         (mstr_state_nxt_c == SM_S_READ16_PS01x_EXEC)    ||
                         (mstr_state_nxt_c == SM_S_READ16_PS01x_HOLD)    ||
                         (mstr_state_nxt_c == SM_S_READ8_PS01x_INIT)     ||
                         (mstr_state_nxt_c == SM_S_READ8_PS01x_EXEC)     ||
                         (mstr_state_nxt_c == SM_S_READ8_PS01x_HOLD)     ||
                         // SEQUENTIAL STATES (PORT S1 Priority) 
                         (mstr_state_nxt_c == SM_S_WRITE32_PS1_INIT)     ||
                         (mstr_state_nxt_c == SM_S_WRITE32_PS1_EXEC)     ||
                         (mstr_state_nxt_c == SM_S_WRITE32_PS1_HOLD)     ||
                         (mstr_state_nxt_c == SM_S_READ32_PS1_INIT)      ||
                         (mstr_state_nxt_c == SM_S_READ32_PS1_EXEC)      ||
                         (mstr_state_nxt_c == SM_S_READ32_PS1_HOLD)      ||
                         (mstr_state_nxt_c == SM_S_WRITE16_PS1_INIT)     || 
                         (mstr_state_nxt_c == SM_S_WRITE16_PS1_EXEC)     || 
                         (mstr_state_nxt_c == SM_S_WRITE16_PS1_HOLD)     ||
                         (mstr_state_nxt_c == SM_S_READ16_PS1_INIT)      || 
                         (mstr_state_nxt_c == SM_S_READ16_PS1_EXEC)      || 
                         (mstr_state_nxt_c == SM_S_READ16_PS1_HOLD)      ||
                         (mstr_state_nxt_c == SM_S_WRITE8_PS1_INIT)      ||
                         (mstr_state_nxt_c == SM_S_WRITE8_PS1_EXEC)      ||
                         (mstr_state_nxt_c == SM_S_WRITE8_PS1_HOLD)      ||
                         (mstr_state_nxt_c == SM_S_READ8_PS1_INIT)       || 
                         (mstr_state_nxt_c == SM_S_READ8_PS1_EXEC)       ||
                         (mstr_state_nxt_c == SM_S_READ8_PS1_HOLD);
    
end

/****************************
 * PORT S1 Address Controller 
 ****************************/
always @ (*) begin
    ahbl_s1_haddr_nxt_c = ahbl_s1_haddr_r;
    case(mstr_state_nxt_c)
        // INITIALIZATION
        SM_I_READ32_PS1_INIT:     ahbl_s1_haddr_nxt_c = S1_START_ADDR_FIN;
        SM_I_READ32_PS1_HOLD:     ahbl_s1_haddr_nxt_c = ahbl_s1_haddr_r + ADDR_32_OFF;
        SM_I_READ16_PS1_INIT:     ahbl_s1_haddr_nxt_c = S1_START_ADDR_FIN;
        SM_I_READ16_PS1_HOLD:     ahbl_s1_haddr_nxt_c = ahbl_s1_haddr_r + ADDR_16_OFF;
        SM_I_READ8_PS1_INIT:      ahbl_s1_haddr_nxt_c = S1_START_ADDR_FIN;
        SM_I_READ8_PS1_HOLD:      ahbl_s1_haddr_nxt_c = ahbl_s1_haddr_r + ADDR_8_OFF;
        // NON-SEQUENTIAL PORT S0 PRIORITY
        SM_N_READ32_PS01x_INIT:   ahbl_s1_haddr_nxt_c = S1_START_ADDR_FIN;
        SM_N_READ32_PS01x_HOLD:   ahbl_s1_haddr_nxt_c = ahbl_s1_haddr_r + ADDR_32_OFF;
        SM_N_READ16_PS01x_INIT:   ahbl_s1_haddr_nxt_c = S1_START_ADDR_FIN;
        SM_N_READ16_PS01x_HOLD:   ahbl_s1_haddr_nxt_c = ahbl_s1_haddr_r + ADDR_16_OFF;
        SM_N_READ8_PS01x_INIT:    ahbl_s1_haddr_nxt_c = S1_START_ADDR_FIN;
        SM_N_READ8_PS01x_HOLD:    ahbl_s1_haddr_nxt_c = ahbl_s1_haddr_r + ADDR_8_OFF;
        // NON-SEQUENTIAL PORT S1 PRIORITY
        SM_N_WRITE32_PS1_INIT:    ahbl_s1_haddr_nxt_c = S1_START_ADDR_FIN;
        SM_N_WRITE32_PS1_HOLD:    ahbl_s1_haddr_nxt_c = ahbl_s1_haddr_r + ADDR_32_OFF;
        SM_N_READ32_PS1_INIT:     ahbl_s1_haddr_nxt_c = S1_START_ADDR_FIN;
        SM_N_READ32_PS1_HOLD:     ahbl_s1_haddr_nxt_c = ahbl_s1_haddr_r + ADDR_32_OFF;
        SM_N_WRITE16_PS1_INIT:    ahbl_s1_haddr_nxt_c = S1_START_ADDR_FIN;
        SM_N_WRITE16_PS1_HOLD:    ahbl_s1_haddr_nxt_c = ahbl_s1_haddr_r + ADDR_16_OFF;
        SM_N_READ16_PS1_INIT:     ahbl_s1_haddr_nxt_c = S1_START_ADDR_FIN;
        SM_N_READ16_PS1_HOLD:     ahbl_s1_haddr_nxt_c = ahbl_s1_haddr_r + ADDR_16_OFF;
        SM_N_WRITE8_PS1_INIT:     ahbl_s1_haddr_nxt_c = S1_START_ADDR_FIN;
        SM_N_WRITE8_PS1_HOLD:     ahbl_s1_haddr_nxt_c = ahbl_s1_haddr_r + ADDR_8_OFF;
        SM_N_READ8_PS1_INIT:      ahbl_s1_haddr_nxt_c = S1_START_ADDR_FIN;
        SM_N_READ8_PS1_HOLD:      ahbl_s1_haddr_nxt_c = ahbl_s1_haddr_r + ADDR_8_OFF;
        // WRITE-TO-READ
        SM_N_WR_TO_READ_PS1_INIT: ahbl_s1_haddr_nxt_c = S1_START_ADDR_FIN;
        SM_N_WR_TO_READ_PS1_HOLD: ahbl_s1_haddr_nxt_c = (ahbl_s1_hreadyout_i) ? ahbl_s1_haddr_r + WR2RD_INC_S1 : ahbl_s1_haddr_r;
        // SEQUENTIAL PORT S1 PRIORITY
        SM_S_READ32_PS01x_INIT:   ahbl_s1_haddr_nxt_c = S1_START_ADDR_FIN;
        SM_S_READ32_PS01x_EXEC:   ahbl_s1_haddr_nxt_c = ahbl_s1_haddr_r + ADDR_32_OFF;
        SM_S_READ32_PS01x_HOLD:   ahbl_s1_haddr_nxt_c = S1_START_ADDR_FIN + ADDR_32_OFF;
        SM_S_READ16_PS01x_INIT:   ahbl_s1_haddr_nxt_c = S1_START_ADDR_FIN;
        SM_S_READ16_PS01x_EXEC:   ahbl_s1_haddr_nxt_c = ahbl_s1_haddr_r + ADDR_16_OFF;
        SM_S_READ16_PS01x_HOLD:   ahbl_s1_haddr_nxt_c = S1_START_ADDR_FIN + ADDR_16_OFF;
        SM_S_READ8_PS01x_INIT:    ahbl_s1_haddr_nxt_c = S1_START_ADDR_FIN;
        SM_S_READ8_PS01x_EXEC:    ahbl_s1_haddr_nxt_c = ahbl_s1_haddr_r + ADDR_8_OFF;
        SM_S_READ8_PS01x_HOLD:    ahbl_s1_haddr_nxt_c = S1_START_ADDR_FIN + ADDR_8_OFF;
        // SEQUENTIAL PORT S0 PRIORITY
        SM_S_WRITE32_PS1_INIT:    ahbl_s1_haddr_nxt_c = S1_START_ADDR_FIN;
        SM_S_WRITE32_PS1_EXEC:    ahbl_s1_haddr_nxt_c = ahbl_s1_haddr_r + ADDR_32_OFF;
        SM_S_WRITE32_PS1_HOLD:    ahbl_s1_haddr_nxt_c = S1_START_ADDR_FIN + ADDR_32_OFF;
        SM_S_READ32_PS1_INIT:     ahbl_s1_haddr_nxt_c = S1_START_ADDR_FIN;
        SM_S_READ32_PS1_EXEC:     ahbl_s1_haddr_nxt_c = ahbl_s1_haddr_r + ADDR_32_OFF;
        SM_S_READ32_PS1_HOLD:     ahbl_s1_haddr_nxt_c = S1_START_ADDR_FIN + ADDR_32_OFF;
        SM_S_WRITE16_PS1_INIT:    ahbl_s1_haddr_nxt_c = S1_START_ADDR_FIN;
        SM_S_WRITE16_PS1_EXEC:    ahbl_s1_haddr_nxt_c = ahbl_s1_haddr_r + ADDR_16_OFF;
        SM_S_WRITE16_PS1_HOLD:    ahbl_s1_haddr_nxt_c = S1_START_ADDR_FIN + ADDR_16_OFF;
        SM_S_READ16_PS1_INIT:     ahbl_s1_haddr_nxt_c = S1_START_ADDR_FIN;
        SM_S_READ16_PS1_EXEC:     ahbl_s1_haddr_nxt_c = ahbl_s1_haddr_r + ADDR_16_OFF;
        SM_S_READ16_PS1_HOLD:     ahbl_s1_haddr_nxt_c = S1_START_ADDR_FIN + ADDR_16_OFF;
        SM_S_WRITE8_PS1_INIT:     ahbl_s1_haddr_nxt_c = S1_START_ADDR_FIN;
        SM_S_WRITE8_PS1_EXEC:     ahbl_s1_haddr_nxt_c = ahbl_s1_haddr_r + ADDR_8_OFF;
        SM_S_WRITE8_PS1_HOLD:     ahbl_s1_haddr_nxt_c = S1_START_ADDR_FIN + ADDR_8_OFF;
        SM_S_READ8_PS1_INIT:      ahbl_s1_haddr_nxt_c = S1_START_ADDR_FIN;
        SM_S_READ8_PS1_EXEC:      ahbl_s1_haddr_nxt_c = ahbl_s1_haddr_r + ADDR_8_OFF;
        SM_S_READ8_PS1_HOLD:      ahbl_s1_haddr_nxt_c = S1_START_ADDR_FIN + ADDR_8_OFF;
    endcase
end

/**************************
 * PORT S1 hsize Controller 
 **************************/
always @ (*) begin
    ahbl_s1_hsize_nxt_c = ahbl_s1_hsize_r;
    case(mstr_state_nxt_c)
        SM_C_START                 : ahbl_s1_hsize_nxt_c = DEFAULT_HSIZE;
        // INITIALIZATION                           
        SM_I_READ32_PS1_INIT       : ahbl_s1_hsize_nxt_c = X32_WORD;
        SM_I_READ32_PS1_EXEC       : ahbl_s1_hsize_nxt_c = X32_WORD;
        SM_I_READ32_PS1_HOLD       : ahbl_s1_hsize_nxt_c = X32_WORD;
        SM_I_READ16_PS1_INIT       : ahbl_s1_hsize_nxt_c = X16_HALFWORD;
        SM_I_READ16_PS1_EXEC       : ahbl_s1_hsize_nxt_c = X16_HALFWORD;
        SM_I_READ16_PS1_HOLD       : ahbl_s1_hsize_nxt_c = X16_HALFWORD;
        SM_I_READ8_PS1_INIT        : ahbl_s1_hsize_nxt_c = X8_BYTE;
        SM_I_READ8_PS1_EXEC        : ahbl_s1_hsize_nxt_c = X8_BYTE;
        SM_I_READ8_PS1_HOLD        : ahbl_s1_hsize_nxt_c = X8_BYTE;
        // NON-SEQUENTIAL (PORT S0 PRIORITY)                                          
        SM_N_READ32_PS01x_INIT     : ahbl_s1_hsize_nxt_c = X32_WORD;
        SM_N_READ32_PS01x_EXEC     : ahbl_s1_hsize_nxt_c = X32_WORD;
        SM_N_READ32_PS01x_HOLD     : ahbl_s1_hsize_nxt_c = X32_WORD;
        SM_N_READ16_PS01x_INIT     : ahbl_s1_hsize_nxt_c = X16_HALFWORD;
        SM_N_READ16_PS01x_EXEC     : ahbl_s1_hsize_nxt_c = X16_HALFWORD;
        SM_N_READ16_PS01x_HOLD     : ahbl_s1_hsize_nxt_c = X16_HALFWORD;
        SM_N_READ8_PS01x_INIT      : ahbl_s1_hsize_nxt_c = X8_BYTE;
        SM_N_READ8_PS01x_EXEC      : ahbl_s1_hsize_nxt_c = X8_BYTE;
        SM_N_READ8_PS01x_HOLD      : ahbl_s1_hsize_nxt_c = X8_BYTE;
        // NON-SEQUENTIAL (PORT S1 PRIORITY)                                    
        SM_N_WRITE32_PS1_INIT      : ahbl_s1_hsize_nxt_c = X32_WORD;
        SM_N_WRITE32_PS1_EXEC      : ahbl_s1_hsize_nxt_c = X32_WORD;
        SM_N_WRITE32_PS1_HOLD      : ahbl_s1_hsize_nxt_c = X32_WORD;
        SM_N_READ32_PS1_INIT       : ahbl_s1_hsize_nxt_c = X32_WORD;
        SM_N_READ32_PS1_EXEC       : ahbl_s1_hsize_nxt_c = X32_WORD;
        SM_N_READ32_PS1_HOLD       : ahbl_s1_hsize_nxt_c = X32_WORD;
        SM_N_WRITE16_PS1_INIT      : ahbl_s1_hsize_nxt_c = X16_HALFWORD;
        SM_N_WRITE16_PS1_EXEC      : ahbl_s1_hsize_nxt_c = X16_HALFWORD;
        SM_N_WRITE16_PS1_HOLD      : ahbl_s1_hsize_nxt_c = X16_HALFWORD;
        SM_N_READ16_PS1_INIT       : ahbl_s1_hsize_nxt_c = X16_HALFWORD;
        SM_N_READ16_PS1_EXEC       : ahbl_s1_hsize_nxt_c = X16_HALFWORD;
        SM_N_READ16_PS1_HOLD       : ahbl_s1_hsize_nxt_c = X16_HALFWORD;
        SM_N_WRITE8_PS1_INIT       : ahbl_s1_hsize_nxt_c = X8_BYTE;
        SM_N_WRITE8_PS1_EXEC       : ahbl_s1_hsize_nxt_c = X8_BYTE;
        SM_N_WRITE8_PS1_HOLD       : ahbl_s1_hsize_nxt_c = X8_BYTE;
        SM_N_READ8_PS1_INIT        : ahbl_s1_hsize_nxt_c = X8_BYTE;
        SM_N_READ8_PS1_EXEC        : ahbl_s1_hsize_nxt_c = X8_BYTE;
        SM_N_READ8_PS1_HOLD        : ahbl_s1_hsize_nxt_c = X8_BYTE;
        // WRITE-TO-READ                                      
        SM_N_WR_TO_READ_PS1_INIT   : ahbl_s1_hsize_nxt_c = DEFAULT_HSIZE;
        SM_N_WR_TO_READ_PS1_WRITE  : ahbl_s1_hsize_nxt_c = DEFAULT_HSIZE;
        SM_N_WR_TO_READ_PS1_READ   : ahbl_s1_hsize_nxt_c = DEFAULT_HSIZE;
        SM_N_WR_TO_READ_PS1_HOLD   : ahbl_s1_hsize_nxt_c = DEFAULT_HSIZE;
        // SEQUENTIAL (PORT S0 PRIORITY)           
        SM_S_READ32_PS01x_INIT     : ahbl_s1_hsize_nxt_c = X32_WORD;
        SM_S_READ32_PS01x_EXEC     : ahbl_s1_hsize_nxt_c = X32_WORD;
        SM_S_READ32_PS01x_HOLD     : ahbl_s1_hsize_nxt_c = X32_WORD;
        SM_S_READ16_PS01x_INIT     : ahbl_s1_hsize_nxt_c = X16_HALFWORD;
        SM_S_READ16_PS01x_EXEC     : ahbl_s1_hsize_nxt_c = X16_HALFWORD;
        SM_S_READ16_PS01x_HOLD     : ahbl_s1_hsize_nxt_c = X16_HALFWORD;
        SM_S_READ8_PS01x_INIT      : ahbl_s1_hsize_nxt_c = X8_BYTE;
        SM_S_READ8_PS01x_EXEC      : ahbl_s1_hsize_nxt_c = X8_BYTE;
        SM_S_READ8_PS01x_HOLD      : ahbl_s1_hsize_nxt_c = X8_BYTE;
        // SEQUENTIAL (PORT S1 PRIORITY)         
        SM_S_WRITE32_PS1_INIT      : ahbl_s1_hsize_nxt_c = X32_WORD;
        SM_S_WRITE32_PS1_EXEC      : ahbl_s1_hsize_nxt_c = X32_WORD;
        SM_S_WRITE32_PS1_HOLD      : ahbl_s1_hsize_nxt_c = X32_WORD;
        SM_S_READ32_PS1_INIT       : ahbl_s1_hsize_nxt_c = X32_WORD;
        SM_S_READ32_PS1_EXEC       : ahbl_s1_hsize_nxt_c = X32_WORD;
        SM_S_READ32_PS1_HOLD       : ahbl_s1_hsize_nxt_c = X32_WORD;
        SM_S_WRITE16_PS1_INIT      : ahbl_s1_hsize_nxt_c = X16_HALFWORD;
        SM_S_WRITE16_PS1_EXEC      : ahbl_s1_hsize_nxt_c = X16_HALFWORD;
        SM_S_WRITE16_PS1_HOLD      : ahbl_s1_hsize_nxt_c = X16_HALFWORD;
        SM_S_READ16_PS1_INIT       : ahbl_s1_hsize_nxt_c = X16_HALFWORD;
        SM_S_READ16_PS1_EXEC       : ahbl_s1_hsize_nxt_c = X16_HALFWORD;
        SM_S_READ16_PS1_HOLD       : ahbl_s1_hsize_nxt_c = X16_HALFWORD;
        SM_S_WRITE8_PS1_INIT       : ahbl_s1_hsize_nxt_c = X8_BYTE;
        SM_S_WRITE8_PS1_EXEC       : ahbl_s1_hsize_nxt_c = X8_BYTE;
        SM_S_WRITE8_PS1_HOLD       : ahbl_s1_hsize_nxt_c = X8_BYTE;
        SM_S_READ8_PS1_INIT        : ahbl_s1_hsize_nxt_c = X8_BYTE;
        SM_S_READ8_PS1_EXEC        : ahbl_s1_hsize_nxt_c = X8_BYTE;
        SM_S_READ8_PS1_HOLD        : ahbl_s1_hsize_nxt_c = X8_BYTE;
        // END and ERROR          
        SM_C_END                   : ahbl_s1_hsize_nxt_c = DEFAULT_HSIZE;
        SM_C_ERROR                 : ahbl_s1_hsize_nxt_c = DEFAULT_HSIZE;
    endcase
end

/***************************
 * PORT S1 htrans Controller 
 ***************************/
always @ (*) begin
    ahbl_s1_htrans_nxt_c = ahbl_s1_htrans_r;
    case(mstr_state_nxt_c)
        // INITIALIZATION                           
        SM_I_READ32_PS1_EXEC       : ahbl_s1_htrans_nxt_c = NSEQ;
        SM_I_READ16_PS1_EXEC       : ahbl_s1_htrans_nxt_c = NSEQ;
        SM_I_READ8_PS1_EXEC        : ahbl_s1_htrans_nxt_c = NSEQ;
        // NON-SEQUENTIAL (PORT S0 PRIORITY)                                          
        SM_N_READ32_PS01x_EXEC     : ahbl_s1_htrans_nxt_c = NSEQ;
        SM_N_READ16_PS01x_EXEC     : ahbl_s1_htrans_nxt_c = NSEQ;
        SM_N_READ8_PS01x_EXEC      : ahbl_s1_htrans_nxt_c = NSEQ;
        // NON-SEQUENTIAL (PORT S1 PRIORITY)                                    
        SM_N_WRITE32_PS1_EXEC      : ahbl_s1_htrans_nxt_c = NSEQ;
        SM_N_READ32_PS1_EXEC       : ahbl_s1_htrans_nxt_c = NSEQ;
        SM_N_WRITE16_PS1_EXEC      : ahbl_s1_htrans_nxt_c = NSEQ;
        SM_N_READ16_PS1_EXEC       : ahbl_s1_htrans_nxt_c = NSEQ;
        SM_N_WRITE8_PS1_EXEC       : ahbl_s1_htrans_nxt_c = NSEQ;
        SM_N_READ8_PS1_EXEC        : ahbl_s1_htrans_nxt_c = NSEQ;
        // WRITE-TO-READ                                      
        SM_N_WR_TO_READ_PS1_WRITE  : ahbl_s1_htrans_nxt_c = NSEQ;
        SM_N_WR_TO_READ_PS1_READ   : ahbl_s1_htrans_nxt_c = NSEQ;
        // SEQUENTIAL (PORT S0 PRIORITY)           
        SM_S_READ32_PS01x_INIT     : ahbl_s1_htrans_nxt_c = NSEQ;
        SM_S_READ32_PS01x_EXEC     : ahbl_s1_htrans_nxt_c = SEQ;
        SM_S_READ32_PS01x_HOLD     : ahbl_s1_htrans_nxt_c = SEQ;
        SM_S_READ16_PS01x_INIT     : ahbl_s1_htrans_nxt_c = NSEQ;
        SM_S_READ16_PS01x_EXEC     : ahbl_s1_htrans_nxt_c = SEQ;
        SM_S_READ16_PS01x_HOLD     : ahbl_s1_htrans_nxt_c = SEQ;
        SM_S_READ8_PS01x_INIT      : ahbl_s1_htrans_nxt_c = NSEQ;
        SM_S_READ8_PS01x_EXEC      : ahbl_s1_htrans_nxt_c = SEQ;
        SM_S_READ8_PS01x_HOLD      : ahbl_s1_htrans_nxt_c = SEQ;
        // SEQUENTIAL (PORT S1 PRIORITY)         
        SM_S_WRITE32_PS1_INIT      : ahbl_s1_htrans_nxt_c = NSEQ;
        SM_S_WRITE32_PS1_EXEC      : ahbl_s1_htrans_nxt_c = SEQ;
        SM_S_WRITE32_PS1_HOLD      : ahbl_s1_htrans_nxt_c = SEQ;
        SM_S_READ32_PS1_INIT       : ahbl_s1_htrans_nxt_c = NSEQ;
        SM_S_READ32_PS1_EXEC       : ahbl_s1_htrans_nxt_c = SEQ;
        SM_S_READ32_PS1_HOLD       : ahbl_s1_htrans_nxt_c = SEQ;
        SM_S_WRITE16_PS1_INIT      : ahbl_s1_htrans_nxt_c = NSEQ;
        SM_S_WRITE16_PS1_EXEC      : ahbl_s1_htrans_nxt_c = SEQ;
        SM_S_WRITE16_PS1_HOLD      : ahbl_s1_htrans_nxt_c = SEQ;
        SM_S_READ16_PS1_INIT       : ahbl_s1_htrans_nxt_c = NSEQ;
        SM_S_READ16_PS1_EXEC       : ahbl_s1_htrans_nxt_c = SEQ;
        SM_S_READ16_PS1_HOLD       : ahbl_s1_htrans_nxt_c = SEQ;
        SM_S_WRITE8_PS1_INIT       : ahbl_s1_htrans_nxt_c = NSEQ;
        SM_S_WRITE8_PS1_EXEC       : ahbl_s1_htrans_nxt_c = SEQ;
        SM_S_WRITE8_PS1_HOLD       : ahbl_s1_htrans_nxt_c = SEQ;
        SM_S_READ8_PS1_INIT        : ahbl_s1_htrans_nxt_c = NSEQ;
        SM_S_READ8_PS1_EXEC        : ahbl_s1_htrans_nxt_c = SEQ;
        SM_S_READ8_PS1_HOLD        : ahbl_s1_htrans_nxt_c = SEQ;
        // END and ERROR          
        default                    : ahbl_s1_htrans_nxt_c = IDLE;
    endcase
end

/***************************
 * PORT S1 hwrite controller 
 ***************************/
always @ (*) begin
    ahbl_s1_hwrite_nxt_c = ahbl_s1_hwrite_r;
    case(mstr_state_nxt_c)
        // NON-SEQUENTIAL (PORT S1 PRIORITY)                                    
        SM_N_WRITE32_PS1_EXEC      : ahbl_s1_hwrite_nxt_c = 1'b1;
        SM_N_WRITE16_PS1_EXEC      : ahbl_s1_hwrite_nxt_c = 1'b1;
        SM_N_WRITE8_PS1_EXEC       : ahbl_s1_hwrite_nxt_c = 1'b1;                                      
        // WRITE-TO-READ                                      
        SM_N_WR_TO_READ_PS1_WRITE  : ahbl_s1_hwrite_nxt_c = 1'b1;
        // SEQUENTIAL (PORT S1 PRIORITY)         
        SM_S_WRITE32_PS1_INIT      : ahbl_s1_hwrite_nxt_c = 1'b1;
        SM_S_WRITE32_PS1_EXEC      : ahbl_s1_hwrite_nxt_c = 1'b1;
        SM_S_WRITE32_PS1_HOLD      : ahbl_s1_hwrite_nxt_c = 1'b1;
        SM_S_WRITE16_PS1_INIT      : ahbl_s1_hwrite_nxt_c = 1'b1;
        SM_S_WRITE16_PS1_EXEC      : ahbl_s1_hwrite_nxt_c = 1'b1;
        SM_S_WRITE16_PS1_HOLD      : ahbl_s1_hwrite_nxt_c = 1'b1;
        SM_S_WRITE8_PS1_INIT       : ahbl_s1_hwrite_nxt_c = 1'b1;
        SM_S_WRITE8_PS1_EXEC       : ahbl_s1_hwrite_nxt_c = 1'b1;
        SM_S_WRITE8_PS1_HOLD       : ahbl_s1_hwrite_nxt_c = 1'b1;
        default                    : ahbl_s1_hwrite_nxt_c = 1'b0;
    endcase
end

/***************************
 * PORT S0 hw_data controller 
 ***************************/

wire [31:0] tmem32_32_s1 = mem_s1[ahbl_s1_haddr_r >> 2];
wire [31:0] tmem32_16_s1 = mem_s1_16[ahbl_s1_haddr_r >> 2];
wire [31:0] tmem32_8_s1  = mem_s1_8[ahbl_s1_haddr_r >> 2];
wire [15:0] tmem16_16_s1 [1:0];
wire [15:0] tmem16_8_s1 [1:0];
wire [7:0] tmem8_s1 [3:0];

genvar ix1;
for(ix1 = 0; ix1 < 2; ix1 = ix1 + 1) begin
    assign tmem16_16_s1[ix1] = tmem32_16_s1[15+16*ix1:16*ix1];
    assign tmem16_8_s1[ix1] = tmem32_8_s1[15+16*ix1:16*ix1];
end
for(ix1 = 0; ix1 < 4; ix1 = ix1 + 1) begin
    assign tmem8_s1[ix1] = tmem32_8_s1[7+8*ix1:8*ix1];
end

always @ (*) begin
    ahbl_s1_hwdata_nxt_c = ahbl_s1_hwdata_r;
    case(mstr_state_nxt_c)
    /**********************************
     * WRITE DATA during WRITE STATES *
     **********************************/
        SM_N_WRITE32_PS1_HOLD:     ahbl_s1_hwdata_nxt_c = tmem32_32_s1;
        SM_N_WRITE16_PS1_HOLD:     begin
            case(DATA_WIDTH)
                32: ahbl_s1_hwdata_nxt_c = tmem32_16_s1;
                16: ahbl_s1_hwdata_nxt_c = tmem16_16_s1[ahbl_s1_haddr_r[1]];
            endcase
        end
        SM_N_WRITE8_PS1_HOLD:      begin
            case(DATA_WIDTH)
                32: ahbl_s1_hwdata_nxt_c = tmem32_8_s1;
                16: ahbl_s1_hwdata_nxt_c = tmem16_8_s1[ahbl_s1_haddr_r[1]];
                8:  ahbl_s1_hwdata_nxt_c = tmem8_s1[ahbl_s1_haddr_r[1:0]];
            endcase
        end
        SM_N_WR_TO_READ_PS1_READ: begin
            case(DATA_WIDTH)
                32: ahbl_s1_hwdata_nxt_c = tmem32_32_s1;
                16: ahbl_s1_hwdata_nxt_c = tmem16_16_s1[ahbl_s1_haddr_r[1]];
                8:  ahbl_s1_hwdata_nxt_c = tmem8_s1[ahbl_s1_haddr_r[1:0]];
            endcase
        end
        SM_S_WRITE32_PS1_EXEC:     ahbl_s1_hwdata_nxt_c = tmem32_32_s1;
        SM_S_WRITE32_PS1_HOLD:     ahbl_s1_hwdata_nxt_c = tmem32_32_s1;
        SM_S_WRITE16_PS1_EXEC:     begin
            case(DATA_WIDTH)
                32: ahbl_s1_hwdata_nxt_c = tmem32_16_s1;
                16: ahbl_s1_hwdata_nxt_c = tmem16_16_s1[ahbl_s1_haddr_r[1]];
            endcase
        end
        SM_S_WRITE16_PS1_HOLD:     begin
            case(DATA_WIDTH)
                32: ahbl_s1_hwdata_nxt_c = tmem32_16_s1;
                16: ahbl_s1_hwdata_nxt_c = tmem16_16_s1[ahbl_s1_haddr_r[1]];
            endcase
        end
        SM_S_WRITE8_PS1_EXEC:      begin
            case(DATA_WIDTH)
                32: ahbl_s1_hwdata_nxt_c = tmem32_8_s1;
                16: ahbl_s1_hwdata_nxt_c = tmem16_8_s1[ahbl_s1_haddr_r[1]];
                8:  ahbl_s1_hwdata_nxt_c = tmem8_s1[ahbl_s1_haddr_r[1:0]];
            endcase
        end
        SM_S_WRITE8_PS1_HOLD:      begin
            case(DATA_WIDTH)
                32: ahbl_s1_hwdata_nxt_c = tmem32_8_s1;
                16: ahbl_s1_hwdata_nxt_c = tmem16_8_s1[ahbl_s1_haddr_r[1]];
                8:  ahbl_s1_hwdata_nxt_c = tmem8_s1[ahbl_s1_haddr_r[1:0]];
            endcase
        end
    /******************************************
     * WRITE DATA with READ STATE NEXT (NSEQ) *
     ******************************************/
        SM_N_READ32_PS1_INIT: begin
            if(mstr_state_r == SM_N_WRITE32_PS1_EXEC) begin
                ahbl_s1_hwdata_nxt_c = tmem32_32_s1;
            end
            else begin
                ahbl_s1_hwdata_nxt_c = {DATA_WIDTH{1'b0}};
            end
        end
        SM_N_READ32_PS10x_INIT: begin
            if(mstr_state_r == SM_N_WRITE32_PS1_EXEC) begin
                ahbl_s1_hwdata_nxt_c = tmem32_32_s1;
            end
            else begin
                ahbl_s1_hwdata_nxt_c = {DATA_WIDTH{1'b0}};
            end
        end
        SM_N_READ16_PS1_INIT: begin
            if(mstr_state_r == SM_N_WRITE16_PS1_EXEC) begin
                case(DATA_WIDTH)
                    32: ahbl_s1_hwdata_nxt_c = tmem32_16_s1;
                    16: ahbl_s1_hwdata_nxt_c = tmem16_16_s1[ahbl_s1_haddr_r[1]];
                endcase
            end
            else begin
                ahbl_s1_hwdata_nxt_c = {DATA_WIDTH{1'b0}};
            end
        end
        SM_N_READ16_PS10x_INIT: begin
            if(mstr_state_r == SM_N_WRITE16_PS1_EXEC) begin
                case(DATA_WIDTH)
                    32: ahbl_s1_hwdata_nxt_c = tmem32_16_s1;
                    16: ahbl_s1_hwdata_nxt_c = tmem16_16_s1[ahbl_s1_haddr_r[1]];
                endcase
            end
            else begin
                ahbl_s1_hwdata_nxt_c = {DATA_WIDTH{1'b0}};
            end
        end
        SM_N_READ8_PS1_INIT: begin
            if(mstr_state_r == SM_N_WRITE8_PS1_EXEC) begin
                case(DATA_WIDTH)
                    32: ahbl_s1_hwdata_nxt_c = tmem32_8_s1;
                    16: ahbl_s1_hwdata_nxt_c = tmem16_8_s1[ahbl_s1_haddr_r[1]];
                    8:  ahbl_s1_hwdata_nxt_c = tmem8_s1[ahbl_s1_haddr_r[1:0]];
                endcase
            end
            else begin
                ahbl_s1_hwdata_nxt_c = {DATA_WIDTH{1'b0}};
            end
        end
        SM_N_READ8_PS10x_INIT: begin
            if(mstr_state_r == SM_N_WRITE8_PS1_EXEC) begin
                case(DATA_WIDTH)
                    32: ahbl_s1_hwdata_nxt_c = tmem32_8_s1;
                    16: ahbl_s1_hwdata_nxt_c = tmem16_8_s1[ahbl_s1_haddr_r[1]];
                    8:  ahbl_s1_hwdata_nxt_c = tmem8_s1[ahbl_s1_haddr_r[1:0]];
                endcase
            end
            else begin
                ahbl_s1_hwdata_nxt_c = {DATA_WIDTH{1'b0}};
            end
        end
    /*****************************************
     * WRITE DATA with READ STATE NEXT (SEQ) *
     *****************************************/
        SM_S_READ32_PS1_INIT: begin
            if(mstr_state_r == SM_S_WRITE32_PS1_EXEC) begin
                ahbl_s1_hwdata_nxt_c = tmem32_32_s1;
            end
            else begin
                ahbl_s1_hwdata_nxt_c = {DATA_WIDTH{1'b0}};
            end
        end
        SM_S_READ32_PS10x_INIT: begin
            if(mstr_state_r == SM_S_WRITE32_PS1_EXEC) begin
                ahbl_s1_hwdata_nxt_c = tmem32_32_s1;
            end
            else begin
                ahbl_s1_hwdata_nxt_c = {DATA_WIDTH{1'b0}};
            end
        end
        SM_S_READ16_PS1_INIT: begin
            if(mstr_state_r == SM_S_WRITE16_PS1_EXEC) begin
                case(DATA_WIDTH)
                    32: ahbl_s1_hwdata_nxt_c = tmem32_16_s1;
                    16: ahbl_s1_hwdata_nxt_c = tmem16_16_s1[ahbl_s1_haddr_r[1]];
                endcase
            end
            else begin
                ahbl_s1_hwdata_nxt_c = {DATA_WIDTH{1'b0}};
            end
        end
        SM_S_READ16_PS10x_INIT: begin
            if(mstr_state_r == SM_S_WRITE16_PS1_EXEC) begin
                case(DATA_WIDTH)
                    32: ahbl_s1_hwdata_nxt_c = tmem32_16_s1;
                    16: ahbl_s1_hwdata_nxt_c = tmem16_16_s1[ahbl_s1_haddr_r[1]];
                endcase
            end
            else begin
                ahbl_s1_hwdata_nxt_c = {DATA_WIDTH{1'b0}};
            end
        end
        SM_S_READ8_PS1_INIT: begin
            if(mstr_state_r == SM_S_WRITE8_PS1_EXEC) begin
                case(DATA_WIDTH)
                    32: ahbl_s1_hwdata_nxt_c = tmem32_8_s1;
                    16: ahbl_s1_hwdata_nxt_c = tmem16_8_s1[ahbl_s1_haddr_r[1]];
                    8:  ahbl_s1_hwdata_nxt_c = tmem8_s1[ahbl_s1_haddr_r[1:0]];
                endcase
            end
            else begin
                ahbl_s1_hwdata_nxt_c = {DATA_WIDTH{1'b0}};
            end
        end
        SM_S_READ8_PS10x_INIT: begin
            if(mstr_state_r == SM_S_WRITE8_PS1_EXEC) begin
                case(DATA_WIDTH)
                    32: ahbl_s1_hwdata_nxt_c = tmem32_8_s1;
                    16: ahbl_s1_hwdata_nxt_c = tmem16_8_s1[ahbl_s1_haddr_r[1]];
                    8:  ahbl_s1_hwdata_nxt_c = tmem8_s1[ahbl_s1_haddr_r[1:0]];
                endcase
            end
            else begin
                ahbl_s1_hwdata_nxt_c = {DATA_WIDTH{1'b0}};
            end
        end
        default:    ahbl_s1_hwdata_nxt_c = {DATA_WIDTH{1'b0}};
    endcase
end

/********************************
 * STATE MACHINE sequential block
 ********************************/

always @ (posedge ahbl_hclk_i) begin
    if(ahbl_hresetn_i == 1'b0) begin
        mstr_state_r        <= SM_C_START;
        sys_cntr_r          <= {32{1'b0}};
    end
    else begin
        mstr_state_r        <= mstr_state_nxt_c;
        sys_cntr_r          <= sys_cntr_nxt_c;
    end
end

/**************************
 * Port S0 sequential block
 **************************/

wire                  t_ahbl_s0_hsel_nxt_c        = (ahbl_s0_hreadyout_i) ? ahbl_s0_hsel_nxt_c      :ahbl_s0_hsel_r     ;
wire                  t_ahbl_s0_hready_nxt_c      = (ahbl_s0_hreadyout_i) ? ahbl_s0_hready_nxt_c    :ahbl_s0_hready_r   ;
wire [31:0]           t_ahbl_s0_haddr_nxt_c       = (ahbl_s0_hreadyout_i) ? ahbl_s0_haddr_nxt_c     :ahbl_s0_haddr_r    ;
wire [2:0]            t_ahbl_s0_hburst_nxt_c      = (ahbl_s0_hreadyout_i) ? ahbl_s0_hburst_nxt_c    :ahbl_s0_hburst_r   ;
wire [2:0]            t_ahbl_s0_hsize_nxt_c       = (ahbl_s0_hreadyout_i) ? ahbl_s0_hsize_nxt_c     :ahbl_s0_hsize_r    ;
wire                  t_ahbl_s0_hmastlock_nxt_c   = (ahbl_s0_hreadyout_i) ? ahbl_s0_hmastlock_nxt_c :ahbl_s0_hmastlock_r;
wire [3:0]            t_ahbl_s0_hprot_nxt_c       = (ahbl_s0_hreadyout_i) ? ahbl_s0_hprot_nxt_c     :ahbl_s0_hprot_r    ;
wire [1:0]            t_ahbl_s0_htrans_nxt_c      = (ahbl_s0_hreadyout_i) ? ahbl_s0_htrans_nxt_c    :ahbl_s0_htrans_r   ;
wire                  t_ahbl_s0_hwrite_nxt_c      = (ahbl_s0_hreadyout_i) ? ahbl_s0_hwrite_nxt_c    :ahbl_s0_hwrite_r   ;
wire [DATA_WIDTH-1:0] t_ahbl_s0_hwdata_nxt_c      = (ahbl_s0_hreadyout_i) ? ahbl_s0_hwdata_nxt_c    :ahbl_s0_hwdata_r   ;

always @ (posedge ahbl_hclk_i) begin
    if(ahbl_hresetn_i == 1'b0) begin
        ahbl_s0_hsel_r      <= 1'b0;
        ahbl_s0_hready_r    <= 1'b1;
        ahbl_s0_haddr_r     <= {32{1'b0}};
        ahbl_s0_hburst_r    <= INCR;
        ahbl_s0_hsize_r     <= DEFAULT_HSIZE;
        ahbl_s0_hmastlock_r <= 1'b0;
        ahbl_s0_hprot_r     <= 1'b0;
        ahbl_s0_htrans_r    <= IDLE;
        ahbl_s0_hwrite_r    <= 1'b0;
        ahbl_s0_hwdata_r    <= {DATA_WIDTH{1'b0}};
    end
    else begin
        ahbl_s0_hsel_r      <= t_ahbl_s0_hsel_nxt_c;
        ahbl_s0_hready_r    <= t_ahbl_s0_hready_nxt_c;
        ahbl_s0_haddr_r     <= t_ahbl_s0_haddr_nxt_c;
        ahbl_s0_hburst_r    <= t_ahbl_s0_hburst_nxt_c;
        ahbl_s0_hsize_r     <= t_ahbl_s0_hsize_nxt_c;
        ahbl_s0_hmastlock_r <= t_ahbl_s0_hmastlock_nxt_c;
        ahbl_s0_hprot_r     <= t_ahbl_s0_hprot_nxt_c;
        ahbl_s0_htrans_r    <= t_ahbl_s0_htrans_nxt_c;
        ahbl_s0_hwrite_r    <= t_ahbl_s0_hwrite_nxt_c;
        ahbl_s0_hwdata_r    <= t_ahbl_s0_hwdata_nxt_c;
    end
end

/**************************
 * Port S1 sequential block
 **************************/

wire                  t_ahbl_s1_hsel_nxt_c       = (ahbl_s0_hreadyout_i) ? ahbl_s1_hsel_nxt_c      :ahbl_s1_hsel_r     ;
wire                  t_ahbl_s1_hready_nxt_c     = (ahbl_s0_hreadyout_i) ? ahbl_s1_hready_nxt_c    :ahbl_s1_hready_r   ;
wire [31:0]           t_ahbl_s1_haddr_nxt_c      = (ahbl_s0_hreadyout_i) ? ahbl_s1_haddr_nxt_c     :ahbl_s1_haddr_r    ;
wire [2:0]            t_ahbl_s1_hburst_nxt_c     = (ahbl_s0_hreadyout_i) ? ahbl_s1_hburst_nxt_c    :ahbl_s1_hburst_r   ;
wire [2:0]            t_ahbl_s1_hsize_nxt_c      = (ahbl_s0_hreadyout_i) ? ahbl_s1_hsize_nxt_c     :ahbl_s1_hsize_r    ;
wire                  t_ahbl_s1_hmastlock_nxt_c  = (ahbl_s0_hreadyout_i) ? ahbl_s1_hmastlock_nxt_c :ahbl_s1_hmastlock_r;
wire [3:0]            t_ahbl_s1_hprot_nxt_c      = (ahbl_s0_hreadyout_i) ? ahbl_s1_hprot_nxt_c     :ahbl_s1_hprot_r    ;
wire [1:0]            t_ahbl_s1_htrans_nxt_c     = (ahbl_s0_hreadyout_i) ? ahbl_s1_htrans_nxt_c    :ahbl_s1_htrans_r   ;
wire                  t_ahbl_s1_hwrite_nxt_c     = (ahbl_s0_hreadyout_i) ? ahbl_s1_hwrite_nxt_c    :ahbl_s1_hwrite_r   ;
wire [DATA_WIDTH-1:0] t_ahbl_s1_hwdata_nxt_c     = (ahbl_s0_hreadyout_i) ? ahbl_s1_hwdata_nxt_c    :ahbl_s1_hwdata_r   ;

always @ (posedge ahbl_hclk_i) begin
    if(ahbl_hresetn_i == 1'b0) begin
        ahbl_s1_hsel_r      <= 1'b0;
        ahbl_s1_hready_r    <= 1'b1;
        ahbl_s1_haddr_r     <= {32{1'b0}};
        ahbl_s1_hburst_r    <= INCR;
        ahbl_s1_hsize_r     <= DEFAULT_HSIZE;
        ahbl_s1_hmastlock_r <= 1'b0;
        ahbl_s1_hprot_r     <= 1'b0;
        ahbl_s1_htrans_r    <= IDLE;
        ahbl_s1_hwrite_r    <= 1'b0;
        ahbl_s1_hwdata_r    <= {DATA_WIDTH{1'b0}};
    end
    else begin
        ahbl_s1_hsel_r      <= t_ahbl_s1_hsel_nxt_c;
        ahbl_s1_hready_r    <= t_ahbl_s1_hready_nxt_c;
        ahbl_s1_haddr_r     <= t_ahbl_s1_haddr_nxt_c;
        ahbl_s1_hburst_r    <= t_ahbl_s1_hburst_nxt_c;
        ahbl_s1_hsize_r     <= t_ahbl_s1_hsize_nxt_c;
        ahbl_s1_hmastlock_r <= t_ahbl_s1_hmastlock_nxt_c;
        ahbl_s1_hprot_r     <= t_ahbl_s1_hprot_nxt_c;
        ahbl_s1_htrans_r    <= t_ahbl_s1_htrans_nxt_c;
        ahbl_s1_hwrite_r    <= t_ahbl_s1_hwrite_nxt_c;
        ahbl_s1_hwdata_r    <= t_ahbl_s1_hwdata_nxt_c;
    end
end

function [31:0] clog2;
  input [31:0] value;
  reg   [31:0] num;
  begin
    num = value - 1;
    for (clog2=0; num>0; clog2=clog2+1) num = num>>1;
  end
endfunction

endmodule
`endif