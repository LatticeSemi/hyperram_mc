`ifndef LSCC_DATA_CHECKER
`define LSCC_DATA_CHECKER

module lscc_data_checker # (
    parameter   ADDR_DEPTH              = 16384,
    parameter   DATA_WIDTH              = 32,
    parameter   PORT_COUNT              = 1,
    parameter   REGMODE_S0              = "noreg",
    parameter   REGMODE_S1              = "noreg",
    parameter   BYTE_ENABLE_S0          = 0,
    parameter   BYTE_ENABLE_S1          = 0,
    parameter   S0_START_ADDR           = 0,
    parameter   S1_START_ADDR           = 0,
    parameter   ACCESS_TYPE_S0          = "R/W",
    parameter   ACCESS_TYPE_S1          = "R/W",
    parameter   S0_END_ADDR             = ADDR_DEPTH-1,
    parameter   S1_END_ADDR             = ADDR_DEPTH-1,
    parameter   UNALIGNED_ACCESS_EN_S0  = 0,
    parameter   UNALIGNED_ACCESS_EN_S1  = 0,
    parameter   SHIFT_DIRECTION_S0      = "none",
    parameter   SHIFT_DIRECTION_S1      = "none",
    parameter   INIT_FILE               = "none",
    parameter   INIT_FILE_FORMAT        = "hex",
    parameter   DATA_STREAMER_EN        = 0,
    parameter   STREAMER_START_ADDR     = 0
)(
    input                           ahbl_hclk_i,
    input                           ahbl_hresetn_i,

    input                           ahbl_s0_hsel_i,
    input                           ahbl_s0_hready_i,
    input  [31:0]                   ahbl_s0_haddr_i,
    input  [2:0]                    ahbl_s0_hburst_i,
    input  [2:0]                    ahbl_s0_hsize_i,
    input                           ahbl_s0_hmastlock_i,
    input  [3:0]                    ahbl_s0_hprot_i,
    input  [1:0]                    ahbl_s0_htrans_i,
    input                           ahbl_s0_hwrite_i,
    input  [DATA_WIDTH-1:0]         ahbl_s0_hwdata_i,

    input  [DATA_WIDTH-1:0]         ahbl_s0_hrdata_o,
    input                           ahbl_s0_hreadyout_o,

    input                           ahbl_s1_hsel_i,
    input                           ahbl_s1_hready_i,
    input  [31:0]                   ahbl_s1_haddr_i,
    input  [2:0]                    ahbl_s1_hburst_i,
    input  [2:0]                    ahbl_s1_hsize_i,
    input                           ahbl_s1_hmastlock_i,
    input  [3:0]                    ahbl_s1_hprot_i,
    input  [1:0]                    ahbl_s1_htrans_i,
    input                           ahbl_s1_hwrite_i,
    input  [DATA_WIDTH-1:0]         ahbl_s1_hwdata_i,

    input  [DATA_WIDTH-1:0]         ahbl_s1_hrdata_o,
    input                           ahbl_s1_hreadyout_o,

    input                           fifo_clk_i,
    input                           fifo_wr_en_i,
    input [7:0]                     fifo_wr_data_i,
    input                           fifo_interface_en_i,
    input                           fifo_address_rst_i,

    input                           fifo_full_i,

    output                          ahbl_s0_errgen_o,
    output                          ahbl_s1_errgen_o,
    output [DATA_WIDTH-1:0]         s0_exp_data_o,
    output [DATA_WIDTH-1:0]         s1_exp_data_o
);

localparam ADDR_WIDTH             = clog2(ADDR_DEPTH);

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

localparam      DEFAULT_HSIZE     = (DATA_WIDTH == 32) ? X32_WORD :
                                    (DATA_WIDTH == 16) ? X16_HALFWORD : X8_BYTE;

reg [DATA_WIDTH-1:0] mem [2**ADDR_WIDTH-1:0];

initial begin
    if(INIT_FILE != "none") begin
        if(INIT_FILE_FORMAT == "hex") begin 
            $readmemh(INIT_FILE, mem, 0, ADDR_DEPTH-1);
        end
        else begin
            $readmemb(INIT_FILE, mem, 0, ADDR_DEPTH-1);
        end
    end
end

reg                           ahbl_s0_hsel_p_r      = 1'b0;
reg                           ahbl_s0_hready_p_r    = 1'b0;
reg  [31:0]                   ahbl_s0_haddr_p_r     = {32{1'b0}};
reg  [2:0]                    ahbl_s0_hburst_p_r    = INCR;
reg  [2:0]                    ahbl_s0_hsize_p_r     = DEFAULT_HSIZE;
reg                           ahbl_s0_hmastlock_p_r = 1'b0;
reg  [3:0]                    ahbl_s0_hprot_p_r     = {3{1'b0}};
reg  [1:0]                    ahbl_s0_htrans_p_r    = IDLE;
reg                           ahbl_s0_hwrite_p_r    = HREAD;
reg  [DATA_WIDTH-1:0]         ahbl_s0_hwdata_p_r    = {DATA_WIDTH{1'b0}};

reg                           ahbl_s1_hsel_p_r      = 1'b0;
reg                           ahbl_s1_hready_p_r    = 1'b0;
reg  [31:0]                   ahbl_s1_haddr_p_r     = {32{1'b0}};
reg  [2:0]                    ahbl_s1_hburst_p_r    = INCR;
reg  [2:0]                    ahbl_s1_hsize_p_r     = DEFAULT_HSIZE;
reg                           ahbl_s1_hmastlock_p_r = 1'b0;
reg  [3:0]                    ahbl_s1_hprot_p_r     = {3{1'b0}};
reg  [1:0]                    ahbl_s1_htrans_p_r    = IDLE;
reg                           ahbl_s1_hwrite_p_r    = HREAD;
reg  [DATA_WIDTH-1:0]         ahbl_s1_hwdata_p_r    = {DATA_WIDTH{1'b0}};

reg                           ahbl_s0_errgen_r = 1'b0;
reg                           ahbl_s1_errgen_r = 1'b0;

assign                        ahbl_s0_errgen_o = ahbl_s0_errgen_r;
assign                        ahbl_s1_errgen_o = ahbl_s1_errgen_r;

always @ (posedge ahbl_hclk_i, ahbl_hresetn_i) begin
    if(~ahbl_hresetn_i) begin
        ahbl_s0_hsel_p_r      <= 1'b0;
        ahbl_s0_hready_p_r    <= 1'b0;
        ahbl_s0_haddr_p_r     <= {32{1'b0}};
        ahbl_s0_hburst_p_r    <= INCR;
        ahbl_s0_hsize_p_r     <= DEFAULT_HSIZE;
        ahbl_s0_hmastlock_p_r <= 1'b0;
        ahbl_s0_hprot_p_r     <= {3{1'b0}};
        ahbl_s0_htrans_p_r    <= IDLE;
        ahbl_s0_hwrite_p_r    <= HREAD;
        ahbl_s0_hwdata_p_r    <= {DATA_WIDTH{1'b0}};
        if(PORT_COUNT == 2) begin
            ahbl_s1_hsel_p_r      <= 1'b0;
            ahbl_s1_hready_p_r    <= 1'b0;
            ahbl_s1_haddr_p_r     <= {32{1'b0}};
            ahbl_s1_hburst_p_r    <= INCR;
            ahbl_s1_hsize_p_r     <= DEFAULT_HSIZE;
            ahbl_s1_hmastlock_p_r <= 1'b0;
            ahbl_s1_hprot_p_r     <= {3{1'b0}};
            ahbl_s1_htrans_p_r    <= IDLE;
            ahbl_s1_hwrite_p_r    <= HREAD;
            ahbl_s1_hwdata_p_r    <= {DATA_WIDTH{1'b0}};
        end
    end
    else begin
        ahbl_s0_hsel_p_r      <= ahbl_s0_hsel_i;
        ahbl_s0_hready_p_r    <= ahbl_s0_hready_i;
        ahbl_s0_haddr_p_r     <= ahbl_s0_haddr_i;
        ahbl_s0_hburst_p_r    <= ahbl_s0_hburst_i;
        ahbl_s0_hsize_p_r     <= ahbl_s0_hsize_i;
        ahbl_s0_hmastlock_p_r <= ahbl_s0_hmastlock_i;
        ahbl_s0_hprot_p_r     <= ahbl_s0_hprot_i;
        ahbl_s0_htrans_p_r    <= ahbl_s0_htrans_i; 
        ahbl_s0_hwrite_p_r    <= ahbl_s0_hwrite_i;  
        ahbl_s0_hwdata_p_r    <= ahbl_s0_hwdata_i;   
        if(PORT_COUNT == 2) begin
            ahbl_s1_hsel_p_r      <= ahbl_s1_hsel_i;
            ahbl_s1_hready_p_r    <= ahbl_s1_hready_i;
            ahbl_s1_haddr_p_r     <= ahbl_s1_haddr_i;
            ahbl_s1_hburst_p_r    <= ahbl_s1_hburst_i;
            ahbl_s1_hsize_p_r     <= ahbl_s1_hsize_i;
            ahbl_s1_hmastlock_p_r <= ahbl_s1_hmastlock_i;
            ahbl_s1_hprot_p_r     <= ahbl_s1_hprot_i;
            ahbl_s1_htrans_p_r    <= ahbl_s1_htrans_i; 
            ahbl_s1_hwrite_p_r    <= ahbl_s1_hwrite_i;  
            ahbl_s1_hwdata_p_r    <= ahbl_s1_hwdata_i;
        end
    end
end

if(DATA_WIDTH == 32) begin : dwid_32
    wire [31:0] ahbl_s0_haddr_wr_w = ahbl_s0_haddr_p_r + S0_START_ADDR;
    wire [31:0] ahbl_s1_haddr_wr_w = ahbl_s1_haddr_p_r + S1_START_ADDR;

    wire wr_en_s0_w = (ahbl_s0_htrans_p_r == NSEQ || ahbl_s0_htrans_p_r == SEQ) &&
                      (ahbl_s0_hwrite_p_r == HWRITE) &&
                      (ahbl_s0_hsel_p_r == 1'b1);
    wire wr_en_s1_w = (ahbl_s1_htrans_p_r == NSEQ || ahbl_s1_htrans_p_r == SEQ) &&
                      (ahbl_s1_hwrite_p_r == HWRITE) &&
                      (ahbl_s1_hsel_p_r == 1'b1) && (PORT_COUNT == 2);

    reg [31:0] ahbl_s0_hrdata_ben_r = {32{1'b0}};
    reg [31:0] ahbl_s1_hrdata_ben_r = {32{1'b0}};

    wire [31:0] s0_pointed_data_w = mem[ahbl_s0_haddr_wr_w >> 2];
    wire [31:0] s1_pointed_data_w = mem[ahbl_s1_haddr_wr_w >> 2];

    if(ACCESS_TYPE_S0 == "R/W" || ACCESS_TYPE_S0 == "W/O") begin : s0_wr_ctrl
        always @ (*) begin
            if(ahbl_s0_hsize_p_r == X32_WORD) begin
                ahbl_s0_hrdata_ben_r = ahbl_s0_hwdata_i;
            end
            else if(ahbl_s0_hsize_p_r == X16_HALFWORD) begin
                if(ahbl_s0_haddr_wr_w[1] == 1) begin
                    ahbl_s0_hrdata_ben_r = {ahbl_s0_hwdata_i[31:16], s0_pointed_data_w[15:0]};
                end
                else begin
                    ahbl_s0_hrdata_ben_r = {s0_pointed_data_w[31:16], ahbl_s0_hwdata_i[15:0]};
                end
            end
            else begin
                case(ahbl_s0_haddr_wr_w[1:0])
                    2'b00: ahbl_s0_hrdata_ben_r = {s0_pointed_data_w[31:8], ahbl_s0_hwdata_i[7:0]};
                    2'b01: ahbl_s0_hrdata_ben_r = {s0_pointed_data_w[31:16], ahbl_s0_hwdata_i[15:8], s0_pointed_data_w[7:0]};
                    2'b10: ahbl_s0_hrdata_ben_r = {s0_pointed_data_w[31:24], ahbl_s0_hwdata_i[23:16], s0_pointed_data_w[15:0]};
                    2'b11: ahbl_s0_hrdata_ben_r = {ahbl_s0_hwdata_i[31:24], s0_pointed_data_w[23:0]};
                endcase
            end
        end
        always @ (posedge ahbl_hclk_i) begin
            if(wr_en_s0_w) begin
                mem[ahbl_s0_haddr_wr_w >> 2] <= (BYTE_ENABLE_S0 == 0) ? ahbl_s0_hwdata_i : ahbl_s0_hrdata_ben_r;
            end
        end

    end

    if((PORT_COUNT == 2) && (ACCESS_TYPE_S1 == "R/W" || ACCESS_TYPE_S1 == "W/O")) begin : s1_wr_ctrl
        always @ (*) begin
            if(ahbl_s1_hsize_p_r == X32_WORD) begin
                ahbl_s1_hrdata_ben_r = ahbl_s1_hwdata_i;
            end
            else if(ahbl_s1_hsize_p_r == X16_HALFWORD) begin
                if(ahbl_s1_haddr_wr_w[1] == 1) begin
                    ahbl_s1_hrdata_ben_r = {ahbl_s1_hwdata_i[31:16], s1_pointed_data_w[15:0]};
                end
                else begin
                    ahbl_s1_hrdata_ben_r = {s1_pointed_data_w[31:16], ahbl_s1_hwdata_i[15:0]};
                end
            end
            else begin
                case(ahbl_s1_haddr_wr_w[1:0])
                    2'b00: ahbl_s1_hrdata_ben_r = {s1_pointed_data_w[31:8], ahbl_s1_hwdata_i[7:0]};
                    2'b01: ahbl_s1_hrdata_ben_r = {s1_pointed_data_w[31:16], ahbl_s1_hwdata_i[15:8], s1_pointed_data_w[7:0]};
                    2'b10: ahbl_s1_hrdata_ben_r = {s1_pointed_data_w[31:24], ahbl_s1_hwdata_i[23:16], s1_pointed_data_w[15:0]};
                    2'b11: ahbl_s1_hrdata_ben_r = {ahbl_s1_hwdata_i[31:24], s1_pointed_data_w[23:0]};
                endcase
            end
        end

        always @ (posedge ahbl_hclk_i) begin
            if(wr_en_s1_w) begin
                mem[ahbl_s1_haddr_wr_w >> 2] <= (BYTE_ENABLE_S1 == 0) ? ahbl_s1_hwdata_i : ahbl_s1_hrdata_ben_r;
            end
        end
    end

    wire rd_en_s0_w   = (ahbl_s0_htrans_i == NSEQ || ahbl_s0_htrans_i == SEQ) &&
                        (ahbl_s0_hwrite_i == 1'b0) &&
                        (ahbl_s0_hsel_i == 1'b1);
    wire rd_en_s1_w   = (ahbl_s1_htrans_i == NSEQ || ahbl_s1_htrans_i == SEQ) &&
                        (ahbl_s1_hwrite_i == 1'b0) &&
                        (ahbl_s1_hsel_i == 1'b1) && (PORT_COUNT == 2);

    reg rd_en_s0_p_r = 1'b0;
    reg rd_en_s1_p_r = 1'b0;

    wire t_rd_en_s0_w = (~wr_en_s0_w) & (rd_en_s0_p_r | rd_en_s0_w);
    wire t_rd_en_s1_w = (~wr_en_s1_w) & (rd_en_s1_p_r | rd_en_s1_w);

    localparam   RD_STATE_SIZE = 8;
    localparam   RD_IDLE_STATE = 8'h01;
    localparam   RD_READ_STATE = 8'h02;

    always @ (posedge ahbl_hclk_i) begin
        rd_en_s0_p_r <= rd_en_s0_w;
    end

    always @ (posedge ahbl_hclk_i) begin
        rd_en_s1_p_r <= rd_en_s1_w;
    end

    if(ACCESS_TYPE_S0 == "R/W" || ACCESS_TYPE_S0 == "R/O") begin : s0_rd_ctrl
        reg [RD_STATE_SIZE-1:0] s0_rd_state_r = RD_IDLE_STATE;
        reg [RD_STATE_SIZE-1:0] s0_rd_state_nxt_r = RD_IDLE_STATE;
        reg [DATA_WIDTH-1:0]    s0_cmp_data_r = {DATA_WIDTH{1'b0}};

        wire [31:0] ahbl_s0_haddr_rd_w = ahbl_s0_haddr_i + S0_START_ADDR;
        reg [31:0] ahbl_s0_haddr_rd_p_r = {32{1'b0}};

        wire [31:0] ahbl_s0_rd_addr_t_w = (ahbl_s0_hreadyout_o == 1) ? ahbl_s0_haddr_rd_w : ahbl_s0_haddr_rd_p_r;

        assign s0_exp_data_o = s0_cmp_data_r;

        always @ (posedge ahbl_hclk_i) begin
            if(ahbl_s0_hreadyout_o == 1'b1) begin
                ahbl_s0_haddr_rd_p_r <= ahbl_s0_haddr_rd_w;
            end
        end

        always @ (*) begin
            s0_rd_state_nxt_r = s0_rd_state_r;
            case(s0_rd_state_r)
                RD_IDLE_STATE: begin
                    s0_rd_state_nxt_r = (rd_en_s0_w == 1) ? RD_READ_STATE : RD_IDLE_STATE;
                end
                RD_READ_STATE: begin
                    s0_rd_state_nxt_r = (rd_en_s0_w == 1) ? RD_READ_STATE : RD_IDLE_STATE;
                end
            endcase
        end

        always @ (posedge ahbl_hclk_i) begin
            if(ahbl_s0_hreadyout_o == 1'b1) begin
                s0_rd_state_r <= s0_rd_state_nxt_r;
            end
        end
        
        if(UNALIGNED_ACCESS_EN_S0 == 1 && SHIFT_DIRECTION_S0 != "none") begin
            if(SHIFT_DIRECTION_S0 == "right") begin
                always @ (posedge ahbl_hclk_i) begin
                    if(t_rd_en_s0_w == 1) begin
                        s0_cmp_data_r <= mem[ahbl_s0_rd_addr_t_w >> 2] >> (8*ahbl_s0_rd_addr_t_w[1:0]);
                    end
                end
            end
            else begin
                always @ (posedge ahbl_hclk_i) begin
                    if(t_rd_en_s0_w == 1) begin
                        s0_cmp_data_r <= mem[ahbl_s0_rd_addr_t_w >> 2] << (8*ahbl_s0_rd_addr_t_w[1:0]);
                    end
                end
            end
        end
        else begin
            always @ (posedge ahbl_hclk_i) begin
                if(t_rd_en_s0_w == 1) begin
                    s0_cmp_data_r <= mem[ahbl_s0_rd_addr_t_w >> 2];
                end
            end
        end

        always @ (posedge ahbl_hclk_i) begin
            if(s0_rd_state_r == RD_READ_STATE && ahbl_s0_hreadyout_o == 1) begin
                if(s0_cmp_data_r != ahbl_s0_hrdata_o) begin
                    $display("Mismatch found at port S0, expected DATA = %h, output DATA = %h", s0_cmp_data_r, ahbl_s0_hrdata_o);
                    ahbl_s0_errgen_r <= 1'b1;
                end
                else begin
                    ahbl_s0_errgen_r <= 1'b0;
                end
            end
            else begin
                ahbl_s0_errgen_r <= 1'b0;
            end
        end
    end
    else begin : s0_rd_disable
        assign s0_exp_data_o = {DATA_WIDTH{1'b0}};
    end

    if(ACCESS_TYPE_S1 == "R/W" || ACCESS_TYPE_S1 == "R/O") begin : s1_rd_ctrl
        reg [RD_STATE_SIZE-1:0] s1_rd_state_r = RD_IDLE_STATE;
        reg [RD_STATE_SIZE-1:0] s1_rd_state_nxt_r = RD_IDLE_STATE;
        reg [DATA_WIDTH-1:0]    s1_cmp_data_r = {DATA_WIDTH{1'b0}};

        wire [31:0] ahbl_s1_haddr_rd_w = ahbl_s1_haddr_i + S1_START_ADDR;
        reg [31:0] ahbl_s1_haddr_rd_p_r = {32{1'b0}};

        wire [31:0] ahbl_s1_rd_addr_t_w = (ahbl_s1_hreadyout_o == 1) ? ahbl_s1_haddr_rd_w : ahbl_s1_haddr_rd_p_r;

        assign s1_exp_data_o = s1_cmp_data_r;

        always @ (posedge ahbl_hclk_i) begin
            if(ahbl_s1_hreadyout_o == 1'b1) begin
                ahbl_s1_haddr_rd_p_r <= ahbl_s1_haddr_rd_w;
            end
        end

        always @ (*) begin
            s1_rd_state_nxt_r = s1_rd_state_r;
            case(s1_rd_state_r)
                RD_IDLE_STATE: begin
                    s1_rd_state_nxt_r = (rd_en_s1_w == 1) ? RD_READ_STATE : RD_IDLE_STATE;
                end
                RD_READ_STATE: begin
                    s1_rd_state_nxt_r = (rd_en_s1_w == 1) ? RD_READ_STATE : RD_IDLE_STATE;
                end
            endcase
        end

        always @ (posedge ahbl_hclk_i) begin
            if(ahbl_s1_hreadyout_o == 1'b1) begin
                s1_rd_state_r <= s1_rd_state_nxt_r;
            end
        end
        
        if(UNALIGNED_ACCESS_EN_S1 == 1 && SHIFT_DIRECTION_S1 != "none") begin
            if(SHIFT_DIRECTION_S1 == "right") begin
                always @ (posedge ahbl_hclk_i) begin
                    if(t_rd_en_s1_w == 1) begin
                        s1_cmp_data_r <= mem[ahbl_s1_rd_addr_t_w >> 2] >> (8*ahbl_s1_rd_addr_t_w[1:0]);
                    end
                end
            end
            else begin
                always @ (posedge ahbl_hclk_i) begin
                    if(t_rd_en_s1_w == 1) begin
                        s1_cmp_data_r <= mem[ahbl_s1_rd_addr_t_w >> 2] << (8*ahbl_s1_rd_addr_t_w[1:0]);
                    end
                end
            end
        end
        else begin
            always @ (posedge ahbl_hclk_i) begin
                if(t_rd_en_s1_w == 1) begin
                    s1_cmp_data_r <= mem[ahbl_s1_rd_addr_t_w >> 2];
                end
            end
        end

        always @ (posedge ahbl_hclk_i) begin
            if(s1_rd_state_r == RD_READ_STATE && ahbl_s1_hreadyout_o == 1) begin
                if(s1_cmp_data_r != ahbl_s1_hrdata_o) begin
                    $display("Mismatch found at port S1, expected DATA = %h, output DATA = %h", s1_cmp_data_r, ahbl_s1_hrdata_o);
                    ahbl_s1_errgen_r <= 1'b1;
                end
                else begin
                    ahbl_s1_errgen_r <= 1'b0;
                end
            end
            else begin
                ahbl_s1_errgen_r <= 1'b0;
            end
        end
    end
    else begin : s1_rd_disable
        assign s1_exp_data_o = {DATA_WIDTH{1'b0}};
    end
end
else if(DATA_WIDTH == 16) begin : dwid_16
    wire [31:0] ahbl_s0_haddr_wr_w = ahbl_s0_haddr_p_r + S0_START_ADDR;
    wire [31:0] ahbl_s1_haddr_wr_w = ahbl_s1_haddr_p_r + S1_START_ADDR;

    wire wr_en_s0_w = (ahbl_s0_htrans_p_r == NSEQ || ahbl_s0_htrans_p_r == SEQ) &&
                      (ahbl_s0_hwrite_p_r == HWRITE) &&
                      (ahbl_s0_hsel_p_r == 1'b1);
    wire wr_en_s1_w = (ahbl_s1_htrans_p_r == NSEQ || ahbl_s1_htrans_p_r == SEQ) &&
                      (ahbl_s1_hwrite_p_r == HWRITE) &&
                      (ahbl_s1_hsel_p_r == 1'b1) && (PORT_COUNT == 2);

    reg [15:0] ahbl_s0_hrdata_ben_r = {16{1'b0}};
    reg [15:0] ahbl_s1_hrdata_ben_r = {16{1'b0}};

    wire [15:0] s0_pointed_data_w = mem[ahbl_s0_haddr_wr_w >> 1];
    wire [15:0] s1_pointed_data_w = mem[ahbl_s1_haddr_wr_w >> 1];

    if(ACCESS_TYPE_S0 == "R/W" || ACCESS_TYPE_S0 == "W/O") begin : s0_wr_ctrl
        always @ (*) begin
            if(ahbl_s0_hsize_p_r == X16_HALFWORD) begin
                ahbl_s0_hrdata_ben_r = ahbl_s0_hwdata_i;
            end
            else begin
                if(ahbl_s0_haddr_wr_w[0] == 1) begin
                    ahbl_s0_hrdata_ben_r = {ahbl_s0_hwdata_i[15:8], s0_pointed_data_w[7:0]};
                end
                else begin
                    ahbl_s0_hrdata_ben_r = {s0_pointed_data_w[15:8], ahbl_s0_hwdata_i[7:0]};
                end
            end
        end

        always @ (posedge ahbl_hclk_i) begin
            if(wr_en_s0_w) begin
                mem[ahbl_s0_haddr_wr_w >> 1] <= (BYTE_ENABLE_S0 == 0) ? ahbl_s0_hwdata_i : ahbl_s0_hrdata_ben_r;
            end
        end
    end

    if((PORT_COUNT == 2) && (ACCESS_TYPE_S1 == "R/W" || ACCESS_TYPE_S1 == "W/O")) begin : s1_wr_ctrl
        always @ (*) begin
            if(ahbl_s1_hsize_p_r == X16_HALFWORD) begin
                ahbl_s1_hrdata_ben_r = ahbl_s1_hwdata_i;
            end
            else begin
                if(ahbl_s1_haddr_wr_w[0] == 1) begin
                    ahbl_s1_hrdata_ben_r = {ahbl_s1_hwdata_i[15:8], s1_pointed_data_w[7:0]};
                end
                else begin
                    ahbl_s1_hrdata_ben_r = {s1_pointed_data_w[15:8], ahbl_s1_hwdata_i[7:0]};
                end
            end
        end

        always @ (posedge ahbl_hclk_i) begin
            if(wr_en_s1_w) begin
                mem[ahbl_s1_haddr_wr_w >> 1] <= (BYTE_ENABLE_S1 == 0) ? ahbl_s1_hwdata_i : ahbl_s1_hrdata_ben_r;
            end
        end
    end

    wire rd_en_s0_w   = (ahbl_s0_htrans_i == NSEQ || ahbl_s0_htrans_i == SEQ) &&
                        (ahbl_s0_hwrite_i == 1'b0) &&
                        (ahbl_s0_hsel_i == 1'b1);
    wire rd_en_s1_w   = (ahbl_s1_htrans_i == NSEQ || ahbl_s1_htrans_i == SEQ) &&
                        (ahbl_s1_hwrite_i == 1'b0) &&
                        (ahbl_s1_hsel_i == 1'b1) && (PORT_COUNT == 2);

    reg rd_en_s0_p_r = 1'b0;
    reg rd_en_s1_p_r = 1'b0;

    wire t_rd_en_s0_w = (~wr_en_s0_w) & (rd_en_s0_p_r | rd_en_s0_w);
    wire t_rd_en_s1_w = (~wr_en_s1_w) & (rd_en_s1_p_r | rd_en_s1_w);

    localparam   RD_STATE_SIZE = 8;
    localparam   RD_IDLE_STATE = 8'h01;
    localparam   RD_READ_STATE = 8'h02;

    always @ (posedge ahbl_hclk_i) begin
        rd_en_s0_p_r <= rd_en_s0_w;
    end

    always @ (posedge ahbl_hclk_i) begin
        rd_en_s1_p_r <= rd_en_s1_w;
    end

    if(ACCESS_TYPE_S0 == "R/W" || ACCESS_TYPE_S0 == "R/O") begin : s0_rd_ctrl
        reg [RD_STATE_SIZE-1:0] s0_rd_state_r = RD_IDLE_STATE;
        reg [RD_STATE_SIZE-1:0] s0_rd_state_nxt_r = RD_IDLE_STATE;
        reg [DATA_WIDTH-1:0]    s0_cmp_data_r = {DATA_WIDTH{1'b0}};

        wire [31:0] ahbl_s0_haddr_rd_w = ahbl_s0_haddr_i + S0_START_ADDR;
        reg [31:0] ahbl_s0_haddr_rd_p_r = {32{1'b0}};

        wire [31:0] ahbl_s0_rd_addr_t_w = (ahbl_s0_hreadyout_o == 1) ? ahbl_s0_haddr_rd_w : ahbl_s0_haddr_rd_p_r;

        assign s0_exp_data_o = s0_cmp_data_r;

        always @ (posedge ahbl_hclk_i) begin
            if(ahbl_s0_hreadyout_o == 1'b1) begin
                ahbl_s0_haddr_rd_p_r <= ahbl_s0_haddr_rd_w;
            end
        end

        always @ (*) begin
            s0_rd_state_nxt_r = s0_rd_state_r;
            case(s0_rd_state_r)
                RD_IDLE_STATE: begin
                    s0_rd_state_nxt_r = (rd_en_s0_w == 1) ? RD_READ_STATE : RD_IDLE_STATE;
                end
                RD_READ_STATE: begin
                    s0_rd_state_nxt_r = (rd_en_s0_w == 1) ? RD_READ_STATE : RD_IDLE_STATE;
                end
            endcase
        end

        always @ (posedge ahbl_hclk_i) begin
            if(ahbl_s0_hreadyout_o == 1'b1) begin
                s0_rd_state_r <= s0_rd_state_nxt_r;
            end
        end
        
        always @ (posedge ahbl_hclk_i) begin
            if(t_rd_en_s0_w == 1) begin
                s0_cmp_data_r <= mem[ahbl_s0_rd_addr_t_w >> 1];
            end
        end

        always @ (posedge ahbl_hclk_i) begin
            if(s0_rd_state_r == RD_READ_STATE && ahbl_s0_hreadyout_o == 1) begin
                if(s0_cmp_data_r != ahbl_s0_hrdata_o) begin
                    $display("Mismatch found at port S0, expected DATA = %h, output DATA = %h", s0_cmp_data_r, ahbl_s0_hrdata_o);
                    ahbl_s0_errgen_r <= 1'b1;
                end
                else begin
                    ahbl_s0_errgen_r <= 1'b0;
                end
            end
            else begin
                ahbl_s0_errgen_r <= 1'b0;
            end
        end
    end
    else begin : s0_rd_disable
        assign s0_exp_data_o = {DATA_WIDTH{1'b0}};
    end

    if(ACCESS_TYPE_S1 == "R/W" || ACCESS_TYPE_S1 == "R/O") begin : s1_rd_ctrl
        reg [RD_STATE_SIZE-1:0] s1_rd_state_r = RD_IDLE_STATE;
        reg [RD_STATE_SIZE-1:0] s1_rd_state_nxt_r = RD_IDLE_STATE;
        reg [DATA_WIDTH-1:0]    s1_cmp_data_r = {DATA_WIDTH{1'b0}};

        wire [31:0] ahbl_s1_haddr_rd_w = ahbl_s1_haddr_i + S1_START_ADDR;
        reg [31:0] ahbl_s1_haddr_rd_p_r = {32{1'b0}};

        wire [31:0] ahbl_s1_rd_addr_t_w = (ahbl_s1_hreadyout_o == 1) ? ahbl_s1_haddr_rd_w : ahbl_s1_haddr_rd_p_r;

        assign s1_exp_data_o = s1_cmp_data_r;

        always @ (posedge ahbl_hclk_i) begin
            if(ahbl_s1_hreadyout_o == 1'b1) begin
                ahbl_s1_haddr_rd_p_r <= ahbl_s1_haddr_rd_w;
            end
        end

        always @ (*) begin
            s1_rd_state_nxt_r = s1_rd_state_r;
            case(s1_rd_state_r)
                RD_IDLE_STATE: begin
                    s1_rd_state_nxt_r = (rd_en_s1_w == 1) ? RD_READ_STATE : RD_IDLE_STATE;
                end
                RD_READ_STATE: begin
                    s1_rd_state_nxt_r = (rd_en_s1_w == 1) ? RD_READ_STATE : RD_IDLE_STATE;
                end
            endcase
        end

        always @ (posedge ahbl_hclk_i) begin
            if(ahbl_s1_hreadyout_o == 1'b1) begin
                s1_rd_state_r <= s1_rd_state_nxt_r;
            end
        end
        
        always @ (posedge ahbl_hclk_i) begin
            if(t_rd_en_s1_w == 1) begin
                s1_cmp_data_r <= mem[ahbl_s1_rd_addr_t_w >> 1];
            end
        end

        always @ (posedge ahbl_hclk_i) begin
            if(s1_rd_state_r == RD_READ_STATE && ahbl_s1_hreadyout_o == 1) begin
                if(s1_cmp_data_r != ahbl_s1_hrdata_o) begin
                    $display("Mismatch found at port S1, expected DATA = %h, output DATA = %h", s1_cmp_data_r, ahbl_s1_hrdata_o);
                    ahbl_s1_errgen_r <= 1'b1;
                end
                else begin
                    ahbl_s1_errgen_r <= 1'b0;
                end
            end
            else begin
                ahbl_s1_errgen_r <= 1'b0;
            end
        end
    end
    else begin : s1_rd_disable
        assign s1_exp_data_o = {DATA_WIDTH{1'b0}};
    end
end
else begin : dwid_8
    wire [31:0] ahbl_s0_haddr_wr_w = ahbl_s0_haddr_p_r + S0_START_ADDR;
    wire [31:0] ahbl_s1_haddr_wr_w = ahbl_s1_haddr_p_r + S1_START_ADDR;

    wire wr_en_s0_w = (ahbl_s0_htrans_p_r == NSEQ || ahbl_s0_htrans_p_r == SEQ) &&
                      (ahbl_s0_hwrite_p_r == HWRITE) &&
                      (ahbl_s0_hsel_p_r == 1'b1);
    wire wr_en_s1_w = (ahbl_s1_htrans_p_r == NSEQ || ahbl_s1_htrans_p_r == SEQ) &&
                      (ahbl_s1_hwrite_p_r == HWRITE) &&
                      (ahbl_s1_hsel_p_r == 1'b1) && (PORT_COUNT == 2);

    if(ACCESS_TYPE_S0 == "R/W" || ACCESS_TYPE_S0 == "W/O") begin : s0_wr_ctrl

        always @ (posedge ahbl_hclk_i) begin
            if(wr_en_s0_w) begin
                mem[ahbl_s0_haddr_wr_w] <= ahbl_s0_hwdata_i;
            end
        end
    end

    if((PORT_COUNT == 2) && (ACCESS_TYPE_S1 == "R/W" || ACCESS_TYPE_S1 == "W/O")) begin : s1_wr_ctrl
        always @ (posedge ahbl_hclk_i) begin
            if(wr_en_s1_w) begin
                mem[ahbl_s1_haddr_wr_w] <= ahbl_s1_hwdata_i;
            end
        end
    end

    wire rd_en_s0_w   = (ahbl_s0_htrans_i == NSEQ || ahbl_s0_htrans_i == SEQ) &&
                        (ahbl_s0_hwrite_i == 1'b0) &&
                        (ahbl_s0_hsel_i == 1'b1);
    wire rd_en_s1_w   = (ahbl_s1_htrans_i == NSEQ || ahbl_s1_htrans_i == SEQ) &&
                        (ahbl_s1_hwrite_i == 1'b0) &&
                        (ahbl_s1_hsel_i == 1'b1) && (PORT_COUNT == 2);

    reg rd_en_s0_p_r = 1'b0;
    reg rd_en_s1_p_r = 1'b0;

    wire t_rd_en_s0_w = (~wr_en_s0_w) & (rd_en_s0_p_r | rd_en_s0_w);
    wire t_rd_en_s1_w = (~wr_en_s1_w) & (rd_en_s1_p_r | rd_en_s1_w);

    localparam   RD_STATE_SIZE = 8;
    localparam   RD_IDLE_STATE = 8'h01;
    localparam   RD_READ_STATE = 8'h02;

    always @ (posedge ahbl_hclk_i) begin
        rd_en_s0_p_r <= rd_en_s0_w;
    end

    always @ (posedge ahbl_hclk_i) begin
        rd_en_s1_p_r <= rd_en_s1_w;
    end

    if(ACCESS_TYPE_S0 == "R/W" || ACCESS_TYPE_S0 == "R/O") begin : s0_rd_ctrl
        reg [RD_STATE_SIZE-1:0] s0_rd_state_r = RD_IDLE_STATE;
        reg [RD_STATE_SIZE-1:0] s0_rd_state_nxt_r = RD_IDLE_STATE;
        reg [DATA_WIDTH-1:0]    s0_cmp_data_r = {DATA_WIDTH{1'b0}};

        wire [31:0] ahbl_s0_haddr_rd_w = ahbl_s0_haddr_i + S0_START_ADDR;
        reg [31:0] ahbl_s0_haddr_rd_p_r = {32{1'b0}};

        wire [31:0] ahbl_s0_rd_addr_t_w = (ahbl_s0_hreadyout_o == 1) ? ahbl_s0_haddr_rd_w : ahbl_s0_haddr_rd_p_r;

        assign s0_exp_data_o = s0_cmp_data_r;

        always @ (posedge ahbl_hclk_i) begin
            if(ahbl_s0_hreadyout_o == 1'b1) begin
                ahbl_s0_haddr_rd_p_r <= ahbl_s0_haddr_rd_w;
            end
        end

        always @ (*) begin
            s0_rd_state_nxt_r = s0_rd_state_r;
            case(s0_rd_state_r)
                RD_IDLE_STATE: begin
                    s0_rd_state_nxt_r = (rd_en_s0_w == 1) ? RD_READ_STATE : RD_IDLE_STATE;
                end
                RD_READ_STATE: begin
                    s0_rd_state_nxt_r = (rd_en_s0_w == 1) ? RD_READ_STATE : RD_IDLE_STATE;
                end
            endcase
        end

        always @ (posedge ahbl_hclk_i) begin
            if(ahbl_s0_hreadyout_o == 1'b1) begin
                s0_rd_state_r <= s0_rd_state_nxt_r;
            end
        end
        
        always @ (posedge ahbl_hclk_i) begin
            if(t_rd_en_s0_w == 1) begin
                s0_cmp_data_r <= mem[ahbl_s0_rd_addr_t_w];
            end
        end

        always @ (posedge ahbl_hclk_i) begin
            if(s0_rd_state_r == RD_READ_STATE && ahbl_s0_hreadyout_o == 1) begin
                if(s0_cmp_data_r != ahbl_s0_hrdata_o) begin
                    $display("Mismatch found at port S0, expected DATA = %h, output DATA = %h", s0_cmp_data_r, ahbl_s0_hrdata_o);
                    ahbl_s0_errgen_r <= 1'b1;
                end
                else begin
                    ahbl_s0_errgen_r <= 1'b0;
                end
            end
            else begin
                ahbl_s0_errgen_r <= 1'b0;
            end
        end
    end
    else begin : s0_rd_disable
        assign s0_exp_data_o = {DATA_WIDTH{1'b0}};
    end

    if(ACCESS_TYPE_S1 == "R/W" || ACCESS_TYPE_S1 == "R/O") begin : s1_rd_ctrl
        reg [RD_STATE_SIZE-1:0] s1_rd_state_r = RD_IDLE_STATE;
        reg [RD_STATE_SIZE-1:0] s1_rd_state_nxt_r = RD_IDLE_STATE;
        reg [DATA_WIDTH-1:0]    s1_cmp_data_r = {DATA_WIDTH{1'b0}};

        wire [31:0] ahbl_s1_haddr_rd_w = ahbl_s1_haddr_i + S1_START_ADDR;
        reg [31:0] ahbl_s1_haddr_rd_p_r = {32{1'b0}};

        wire [31:0] ahbl_s1_rd_addr_t_w = (ahbl_s1_hreadyout_o == 1) ? ahbl_s1_haddr_rd_w : ahbl_s1_haddr_rd_p_r;

        assign s1_exp_data_o = s1_cmp_data_r;

        always @ (posedge ahbl_hclk_i) begin
            if(ahbl_s1_hreadyout_o == 1'b1) begin
                ahbl_s1_haddr_rd_p_r <= ahbl_s1_haddr_rd_w;
            end
        end

        always @ (*) begin
            s1_rd_state_nxt_r = s1_rd_state_r;
            case(s1_rd_state_r)
                RD_IDLE_STATE: begin
                    s1_rd_state_nxt_r = (rd_en_s1_w == 1) ? RD_READ_STATE : RD_IDLE_STATE;
                end
                RD_READ_STATE: begin
                    s1_rd_state_nxt_r = (rd_en_s1_w == 1) ? RD_READ_STATE : RD_IDLE_STATE;
                end
            endcase
        end

        always @ (posedge ahbl_hclk_i) begin
            if(ahbl_s1_hreadyout_o == 1'b1) begin
                s1_rd_state_r <= s1_rd_state_nxt_r;
            end
        end
        
        always @ (posedge ahbl_hclk_i) begin
            if(t_rd_en_s1_w == 1) begin
                s1_cmp_data_r <= mem[ahbl_s1_rd_addr_t_w];
            end
        end

        always @ (posedge ahbl_hclk_i) begin
            if(s1_rd_state_r == RD_READ_STATE && ahbl_s1_hreadyout_o == 1) begin
                if(s1_cmp_data_r != ahbl_s1_hrdata_o) begin
                    $display("Mismatch found at port S1, expected DATA = %h, output DATA = %h", s1_cmp_data_r, ahbl_s1_hrdata_o);
                    ahbl_s1_errgen_r <= 1'b1;
                end
                else begin
                    ahbl_s1_errgen_r <= 1'b0;
                end
            end
            else begin
                ahbl_s1_errgen_r <= 1'b0;
            end
        end
    end
    else begin : s1_rd_disable
        assign s1_exp_data_o = {DATA_WIDTH{1'b0}};
    end
end

if(DATA_STREAMER_EN) begin
    if(DATA_WIDTH == 32) begin
        reg [ADDR_WIDTH-1:0] faddr_ptr_r;
        reg [3:0]            sel_r;
        reg [ADDR_WIDTH-1:0] faddr_ptr_nxt_c;
        reg [3:0]            sel_nxt_c;

        wire        fsel_w      = ~fifo_full_i & fifo_interface_en_i & fifo_wr_en_i;
        wire [31:0] fdata_ptr_w = mem[faddr_ptr_r];
        wire [31:0] fdata_wr_w  = {(sel_r[3]) ? fifo_wr_data_i : fdata_ptr_w[31:24],
                                   (sel_r[2]) ? fifo_wr_data_i : fdata_ptr_w[23:16],
                                   (sel_r[1]) ? fifo_wr_data_i : fdata_ptr_w[15: 8],
                                   (sel_r[0]) ? fifo_wr_data_i : fdata_ptr_w[ 7: 0]};
        always @ (*) begin
            sel_nxt_c = (fsel_w) ? {sel_r[2:0], sel_r[3]} : sel_r;
        end

        always @ (*) begin
            faddr_ptr_nxt_c = (fsel_w & sel_r[3]) ? faddr_ptr_r + 1'b1 : faddr_ptr_r;
        end

        always @ (posedge fifo_clk_i) begin
            if(fsel_w) begin 
                mem[faddr_ptr_r] <= fdata_wr_w;
            end
        end

        always @ (posedge fifo_clk_i, ahbl_hresetn_i) begin
            if(~ahbl_hresetn_i) begin
                faddr_ptr_r <= STREAMER_START_ADDR;
                sel_r       <= 4'b0001;
            end
            else begin
                faddr_ptr_r <= faddr_ptr_nxt_c;
                sel_r       <= sel_nxt_c;
            end
        end
    end
    else if (DATA_WIDTH == 16) begin
        reg [ADDR_WIDTH-1:0] faddr_ptr_r;
        reg [1:0]            sel_r;
        reg [ADDR_WIDTH-1:0] faddr_ptr_nxt_c;
        reg [1:0]            sel_nxt_c;

        wire        fsel_w      = ~fifo_full_i & fifo_interface_en_i & fifo_wr_en_i;
        wire [31:0] fdata_ptr_w = mem[faddr_ptr_r];
        wire [31:0] fdata_wr_w  = {(sel_r[1]) ? fifo_wr_data_i : fdata_ptr_w[15: 8],
                                   (sel_r[0]) ? fifo_wr_data_i : fdata_ptr_w[ 7: 0]};
        always @ (*) begin
            sel_nxt_c = (fsel_w) ? {sel_r[0], sel_r[1]} : sel_r;
        end

        always @ (*) begin
            faddr_ptr_nxt_c = (fsel_w & sel_r[1]) ? faddr_ptr_r + 1'b1 : faddr_ptr_r;
        end

        always @ (posedge fifo_clk_i) begin
            if(fsel_w) begin 
                mem[faddr_ptr_r] <= fdata_wr_w;
            end
        end

        always @ (posedge fifo_clk_i, ahbl_hresetn_i) begin
            if(~ahbl_hresetn_i) begin
                faddr_ptr_r <= STREAMER_START_ADDR;
                sel_r       <= 2'b01;
            end
            else begin
                faddr_ptr_r <= faddr_ptr_nxt_c;
                sel_r       <= sel_nxt_c;
            end
        end
    end
    else begin
        reg [ADDR_WIDTH-1:0] faddr_ptr_r;
        reg [ADDR_WIDTH-1:0] faddr_ptr_nxt_c;

        wire fsel_w = ~fifo_full_i & fifo_interface_en_i & fifo_wr_en_i;

        always @ (*) begin
            faddr_ptr_nxt_c = (fsel_w) ? faddr_ptr_r + 1'b1 : faddr_ptr_r;
        end

        always @ (posedge fifo_clk_i) begin
            if(fsel_w) begin 
                mem[faddr_ptr_r] <= fifo_wr_data_i;
            end
        end

        always @ (posedge fifo_clk_i, ahbl_hresetn_i) begin
            if(~ahbl_hresetn_i) begin
                faddr_ptr_r <= STREAMER_START_ADDR;
            end
            else begin
                faddr_ptr_r <= faddr_ptr_nxt_c;
            end
        end
    end
end

function [31:0] clog2;
  input [31:0] value;
  reg   [31:0] num;
  begin
    num = value - 1;
    for (clog2 = 0; num > 0; clog2 = clog2 + 1) num = num >> 1;
  end
endfunction

endmodule
`endif