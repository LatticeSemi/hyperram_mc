`timescale 1 ns / 1 ps
`include "lscc_lmmi2apb.v"

module tb_top();
`include "dut_params.v"

// -----------------------------------------------------------------------------
// Parameters
// -----------------------------------------------------------------------------
parameter integer SYS_CLK_PERIOD       = 40;
parameter         OFFSET_WIDTH         = 4;
parameter         INT_TYPE             = 0;                  // 0 = Edge Interrupt, 1 = Level Interrupt
parameter         INT_METHOD           = 0;                  // if (INT_TYPE = 0) then 0 = Rising Edge, 1 = Falling Edge,
                                                             // else 0 = High Level, 1 = Low Level
parameter         INT_ENABLE           = 0;

localparam RESET_TEST            = 0;
localparam WRITE_TEST            = 1;
localparam READ_TEST             = 2;
localparam RISING_EDGE_INT_TEST  = 3;
localparam FALLING_EDGE_INT_TEST = 4;
localparam HIGH_LEVEL_INT_TEST   = 5;
localparam LOW_LEVEL_INT_TEST    = 6;
localparam CHANGE_DIR_TEST       = 7;
localparam DUMMY_STATE           = 8;

//Addresses of Registers
localparam RD_DATA_REG_ADDR    = 4'b0000;
localparam WR_DATA_REG_ADDR    = 4'b0001;
localparam SET_DATA_REG_ADDR   = 4'b0010;
localparam CLEAR_DATA_REG_ADDR = 4'b0011;
localparam DIRECTION_REG_ADDR  = 4'b0100;
localparam INT_TYPE_REG_ADDR   = 4'b0101;
localparam INT_METHOD_REG_ADDR = 4'b0110;
localparam INT_STATUS_REG_ADDR = 4'b0111;
localparam INT_ENABLE_REG_ADDR = 4'b1000;
localparam INT_SET_REG_ADDR    = 4'b1001;

integer a = 0;
genvar i;

function [31:0] negation;
    input [31:0] a;
    negation = ~a;
endfunction

function [31:0] convert_str_to_bitvector;
  input reg [63:0] string_argument;
  integer i;
  reg [ 3:0] temp_bitvector;
  reg [31:0] result_bitvector;
  reg [63:0] string_arg;
begin
  string_arg = string_argument;
  for (i = 0; i<8; i=i+1) begin
    case (string_arg[7:0])
      8'h30: temp_bitvector = 'h0;
      8'h31: temp_bitvector = 'h1;
      8'h32: temp_bitvector = 'h2;
      8'h33: temp_bitvector = 'h3;
      8'h34: temp_bitvector = 'h4;
      8'h35: temp_bitvector = 'h5;
      8'h36: temp_bitvector = 'h6;
      8'h37: temp_bitvector = 'h7;
      8'h38: temp_bitvector = 'h8;
      8'h39: temp_bitvector = 'h9;
      8'h41: temp_bitvector = 'hA;
      8'h42: temp_bitvector = 'hB;
      8'h43: temp_bitvector = 'hC;
      8'h44: temp_bitvector = 'hD;
      8'h45: temp_bitvector = 'hE;
      8'h46: temp_bitvector = 'hF;
      8'h61: temp_bitvector = 'ha;
      8'h62: temp_bitvector = 'hb;
      8'h63: temp_bitvector = 'hc;
      8'h64: temp_bitvector = 'hd;
      8'h65: temp_bitvector = 'he;
      8'h66: temp_bitvector = 'hf;
      default: temp_bitvector = 4'hf;
    endcase
    result_bitvector = {temp_bitvector,result_bitvector[31:4]};
    string_arg = string_arg >> 8;
    convert_str_to_bitvector = result_bitvector;
  end
end
endfunction

function [63:0] convert_bitvector_to_str;
  input reg [31:0] bit_argument;
  integer i;
  reg [ 7:0] temp_strvector;
  reg [63:0] result_strvector;
  reg [31:0] bit_arg;
begin
  bit_arg = bit_argument;
  for (i = 0; i<8; i=i+1) begin
    case (bit_arg[3:0])
      4'h0: temp_strvector = 8'h30;
      4'h1: temp_strvector = 8'h31;
      4'h2: temp_strvector = 8'h32;
      4'h3: temp_strvector = 8'h33;
      4'h4: temp_strvector = 8'h34;
      4'h5: temp_strvector = 8'h35;
      4'h6: temp_strvector = 8'h36;
      4'h7: temp_strvector = 8'h37;
      4'h8: temp_strvector = 8'h38;
      4'h9: temp_strvector = 8'h39;
      4'hA: temp_strvector = 8'h41;
      4'hB: temp_strvector = 8'h42;
      4'hC: temp_strvector = 8'h43;
      4'hD: temp_strvector = 8'h44;
      4'hE: temp_strvector = 8'h45;
      4'hF: temp_strvector = 8'h46;
      default: temp_strvector = 8'h46;
    endcase
    result_strvector = {temp_strvector,result_strvector[63:8]};
    bit_arg = bit_arg >> 4;
    convert_bitvector_to_str = result_strvector;
  end
end
endfunction


localparam        DIRECTION_DEF_VAL_TB         = convert_str_to_bitvector(DIRECTION_DEF_VAL);
localparam        DIRECTION_DEF_VAL_TB_NEG     = negation(DIRECTION_DEF_VAL_TB);
localparam        DIRECTION_DEF_VAL_TB_NEG_STR = convert_bitvector_to_str(DIRECTION_DEF_VAL_TB_NEG);
localparam [31:0] OUT_RESET_VAL_BITVEC         = convert_str_to_bitvector(OUT_RESET_VAL);
localparam [31:0] DIRECTION_DEF_VAL_BITVEC     = convert_str_to_bitvector(DIRECTION_DEF_VAL);



reg                          clk_i;
reg                          resetn_i;

reg                          reset_test_done_r;
reg                          write_test_done_r;
reg                          read_test_done_r;
reg                          rising_edge_int_test_done_r;
reg                          falling_edge_int_test_done_r;
reg                          high_level_int_test_done_r;
reg                          low_level_int_test_done_r;
reg                          change_dir_test_done_r;

reg   [OFFSET_WIDTH - 1 : 0] reg_addr_r;
reg                    [7:0] rw_cnt_r;
reg     [IO_LINES_COUNT : 0] rw_data_r [63 : 0];
reg     [IO_LINES_COUNT-1:0] exp_out_result_r;
reg     [IO_LINES_COUNT-1:0] exp_out_result_reg_r;
reg     [IO_LINES_COUNT-1:0] exp_in_result_reg_r;
reg     [IO_LINES_COUNT-1:0] exp_in_result_r;
reg     [IO_LINES_COUNT-1:0] direction_reg_r;
reg                          cmd_done_r;
reg                    [3:0] int_test_state_r;
reg                    [3:0] test_state_r;
reg                          error_flag_r;


reg   [0  : 0]               lmmi_request_i;
reg                          lmmi_wr_rdn_i;
reg   [OFFSET_WIDTH - 1 : 0] lmmi_offset_i;
reg   [IO_LINES_COUNT-1 : 0] lmmi_wdata_i;
wire  [IO_LINES_COUNT-1 : 0] lmmi_rdata_o;
wire                         lmmi_rdata_valid_o;
wire                         lmmi_error_o;
wire                         lmmi_resetn_o;
wire                         lmmi_ready_o;

wire                         apb_pready_o;
wire                         apb_pslverr_o;
wire  [31 : 0]				 apb_prdata_o;

wire                         apb_penable_i;
wire                         apb_psel_i;
wire                         apb_pwrite_i;
wire  [OFFSET_WIDTH + 1 : 0] apb_paddr_i;
reg   [31 : 0]				 apb_pwdata_i;
wire  [IO_LINES_COUNT-1 : 0] apb_pwdata_w;

wire    [IO_LINES_COUNT-1:0] gpio_io;
wire    [IO_LINES_COUNT-1:0] gpio_io_bb;
wire    [IO_LINES_COUNT-1:0] gpio_i;
wire    [IO_LINES_COUNT-1:0] gpio_o;
wire    [IO_LINES_COUNT-1:0] gpio_en_o;
wire    [IO_LINES_COUNT-1:0] gpio_io_o_w;
wire						 int_o;
reg     [IO_LINES_COUNT-1:0] gpio_io_i_r;

generate
  for(i=0; i<IO_LINES_COUNT; i=i+1) begin
	if (EXTERNAL_BUF == 0) begin
      assign gpio_io_o_w[i] = (direction_reg_r[i]==1) ? gpio_io[i]     : 0;
      assign gpio_io[i]     = (direction_reg_r[i]==0) ? gpio_io_i_r[i] : 1'bz;
	end
    else begin //Added condition when Remove Tri-State Buffer is Checked
	  if(FAMILY != "iCE40UP") begin
      BB u_BB_data(
        .B                    (gpio_io_bb[i]),
        .I                    (gpio_o[i]),
        .T                    (gpio_en_o[i]),
        .O                    (gpio_i[i])
      );
      assign gpio_io_o_w[i] = (direction_reg_r[i]==1) ? gpio_io_bb[i]     : 0;
      assign gpio_io_bb[i]     = (direction_reg_r[i]==0) ? gpio_io_i_r[i] : 1'bz;
    end	
	  else begin
        assign gpio_i[i]     = (direction_reg_r[i]==0) ? gpio_io_bb[i] : 0;
        assign gpio_io_o_w[i] = (direction_reg_r[i]==1) ? gpio_io_bb[i]     : 0;
        assign gpio_io_bb[i]     = (direction_reg_r[i]==0) ? gpio_io_i_r[i] : 1'bz;
	  end
    end	


  end
endgenerate

// -----------------------------------------------------------------------------
// Clock Generator
// -----------------------------------------------------------------------------
initial begin
  clk_i     = 0;
end
 
always #(SYS_CLK_PERIOD/2) clk_i = ~clk_i;

initial begin
  resetn_i      <= 1'b0;
  #100 resetn_i <= 1'b1;
end

initial begin
  for(a = 0; a < 16 ; a=a+1)
    rw_data_r[a] <= (286331153 - a*4473924);
end


always @ (posedge clk_i) begin
  if(resetn_i == 0) begin
    reset_test_done_r            <= 0;
    write_test_done_r            <= 0;
    read_test_done_r             <= 0;
    rising_edge_int_test_done_r  <= 0;
    falling_edge_int_test_done_r <= 0;
    high_level_int_test_done_r   <= 0;
    low_level_int_test_done_r    <= 0;
    change_dir_test_done_r       <= 0;

    reg_addr_r           <= WR_DATA_REG_ADDR;
    rw_cnt_r             <= 15;
    direction_reg_r      <= DIRECTION_DEF_VAL_BITVEC[IO_LINES_COUNT-1:0];
    gpio_io_i_r          <= rw_data_r[0];
    cmd_done_r           <= 0;
    exp_out_result_r     <= DIRECTION_DEF_VAL_BITVEC[IO_LINES_COUNT-1:0] & OUT_RESET_VAL_BITVEC[IO_LINES_COUNT-1:0];
    exp_out_result_reg_r <= direction_reg_r & exp_out_result_r;

    exp_in_result_r     <= rw_data_r[rw_cnt_r][IO_LINES_COUNT-1:0];
    exp_in_result_reg_r <= (~direction_reg_r) & exp_in_result_r;

    lmmi_wdata_i    <= 0;
    lmmi_offset_i   <= 0;
    lmmi_request_i  <= 0;
    lmmi_wr_rdn_i   <= 0;
    lmmi_wdata_i    <= 0;

    test_state_r    <= RESET_TEST;
    int_test_state_r<= 0;

    error_flag_r = 0;
  end
  else begin
    exp_out_result_reg_r <= direction_reg_r & exp_out_result_r;
    exp_in_result_reg_r <= (~direction_reg_r) & exp_in_result_r;

    case (test_state_r)
      RESET_TEST: begin
        if(reset_test_done_r == 1)
          test_state_r <= WRITE_TEST;
      end
      WRITE_TEST: begin
        if(write_test_done_r == 1)
          test_state_r <= READ_TEST;
      end
      READ_TEST: begin
        if(read_test_done_r == 1)
          test_state_r <= RISING_EDGE_INT_TEST;
      end
      RISING_EDGE_INT_TEST: begin
        if(rising_edge_int_test_done_r == 1)
          test_state_r <= FALLING_EDGE_INT_TEST;
      end
      FALLING_EDGE_INT_TEST: begin
        if(falling_edge_int_test_done_r == 1)
          test_state_r <= HIGH_LEVEL_INT_TEST;
      end
      HIGH_LEVEL_INT_TEST: begin
        if(high_level_int_test_done_r == 1)
          test_state_r <= LOW_LEVEL_INT_TEST;
      end
      LOW_LEVEL_INT_TEST: begin
        if(low_level_int_test_done_r == 1)
          test_state_r <= CHANGE_DIR_TEST;
      end

      CHANGE_DIR_TEST: begin
        if(change_dir_test_done_r == 0) begin
          change_dir_test_done_r       <= 1;
          write_test_done_r            <= 0;
          read_test_done_r             <= 0;
          rising_edge_int_test_done_r  <= 0;
          falling_edge_int_test_done_r <= 0;
          high_level_int_test_done_r   <= 0;
          low_level_int_test_done_r    <= 0;

          lmmi_offset_i   <= DIRECTION_REG_ADDR;
          lmmi_request_i  <= 1;
          lmmi_wr_rdn_i   <= 1;
          lmmi_wdata_i    <= ~direction_reg_r;

          test_state_r    <= DUMMY_STATE;
        end
        else begin
          if(error_flag_r == 0) begin
			$display("-----------------------------------------------------");
			$display("----------------- SIMULATION PASSED -----------------");
			$display("-----------------------------------------------------");
          end
          else begin
			$display("-----------------------------------------------------");
			$display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			$display("-----------------------------------------------------");
          end
          $stop;
        end
      end

      DUMMY_STATE: begin
	  if( IF_USER_INTF == "LMMI") begin
        direction_reg_r <= ~direction_reg_r;
        test_state_r    <= WRITE_TEST;
	  end
	  else begin
        test_state_r    <= CHANGE_DIR_TEST;
	   end
      end
      default : begin end
    endcase
  end
end

//Reset test scenario
always @ (posedge clk_i) begin
  if((test_state_r == RESET_TEST) && (reset_test_done_r == 0) && (resetn_i == 1)) begin
    lmmi_offset_i  <= 0;
    lmmi_request_i <= 0;
    lmmi_wr_rdn_i  <= 0;

    case(reg_addr_r)
      WR_DATA_REG_ADDR: begin
        if(cmd_done_r == 0) begin
          lmmi_request_i <= 1;
          lmmi_wr_rdn_i  <= 0;
          lmmi_offset_i  <= WR_DATA_REG_ADDR;
          if(lmmi_ready_o == 1) begin
            cmd_done_r     <= 1;
          end
        end

        if(lmmi_rdata_valid_o == 1) begin
          if(lmmi_rdata_o != OUT_RESET_VAL_BITVEC[IO_LINES_COUNT-1:0]) begin
            $display("Error` wrong output reg reset value. Exp: %x Act: %x Time %t ps", OUT_RESET_VAL_BITVEC[IO_LINES_COUNT-1:0], lmmi_rdata_o, $realtime);
          end
          reg_addr_r <= DIRECTION_REG_ADDR;
          cmd_done_r <= 0;
        end
      end

      DIRECTION_REG_ADDR: begin
        if(cmd_done_r == 0) begin
          lmmi_request_i <= 1;
          lmmi_wr_rdn_i  <= 0;
          lmmi_offset_i  <= DIRECTION_REG_ADDR;
          if(lmmi_ready_o == 1) begin
            cmd_done_r     <= 1;
          end
        end
        else begin
          if(lmmi_rdata_valid_o == 1) begin
            if(lmmi_rdata_o != DIRECTION_DEF_VAL_BITVEC[IO_LINES_COUNT-1:0]) begin
              $display("Error` wrong direction reg reset value. Exp: %x Act: %x Time %t ps", DIRECTION_DEF_VAL_BITVEC[IO_LINES_COUNT-1:0], lmmi_rdata_o, $realtime);
            end
            reg_addr_r <= INT_TYPE_REG_ADDR;
            cmd_done_r <= 0;
          end
        end
      end

      INT_TYPE_REG_ADDR: begin
        if(cmd_done_r == 0) begin
          lmmi_request_i <= 1;
          lmmi_wr_rdn_i  <= 0;
          lmmi_offset_i  <= INT_TYPE_REG_ADDR;
          if(lmmi_ready_o == 1) begin
            cmd_done_r    <= 1;
          end
        end
        else begin
          if(lmmi_rdata_valid_o == 1) begin
            if(lmmi_rdata_o != 0) begin
              $display("Error` wrong interrupt type reg reset value. Exp: %x Act: %x Time %t ps", 0, lmmi_rdata_o, $realtime);
            end
            reg_addr_r <= INT_ENABLE_REG_ADDR;
            cmd_done_r <= 0;
          end
        end
      end

      INT_ENABLE_REG_ADDR: begin
        if(cmd_done_r == 0) begin
          lmmi_request_i <= 1;
          lmmi_wr_rdn_i  <= 0;
          lmmi_offset_i  <= INT_ENABLE_REG_ADDR;
          if(lmmi_ready_o == 1) begin
            cmd_done_r    <= 1;
          end
        end
        else begin
          if(lmmi_rdata_valid_o == 1) begin
            if(lmmi_rdata_o != 0) begin
              error_flag_r = 1;
              $display("Error` wrong interrupt enable reg reset value. Exp: %x Act: %x Time %t ps", 0, lmmi_rdata_o, $realtime);
            end
            reg_addr_r        <= WR_DATA_REG_ADDR;
            cmd_done_r        <= 0;
            reset_test_done_r <= 1;
          end
        end
      end
      default : begin
        $display("Reset test unexpected error");
        reset_test_done_r <= 1;
      end
    endcase
  end
end

//WRITE_TEST
always @ (posedge clk_i) begin
  if((test_state_r == WRITE_TEST) && (write_test_done_r == 0) && (resetn_i == 1)) begin
    lmmi_offset_i  <= WR_DATA_REG_ADDR;
    lmmi_request_i <= 0;
    lmmi_wr_rdn_i  <= 0;
    lmmi_wdata_i   <= 0;
    if(cmd_done_r == 0)begin
      lmmi_offset_i    <= WR_DATA_REG_ADDR;
      lmmi_request_i   <= 1;
      lmmi_wr_rdn_i    <= 1;
      lmmi_wdata_i     <= rw_data_r[rw_cnt_r][IO_LINES_COUNT-1:0];
      exp_out_result_r <= rw_data_r[rw_cnt_r][IO_LINES_COUNT-1:0];
      if(lmmi_ready_o == 1) begin
        cmd_done_r <= 1;
      end
    end
    else begin
      if(rw_cnt_r > 0)begin
        rw_cnt_r   <= rw_cnt_r - 1;
        cmd_done_r <= 0;
      end
      else begin
        cmd_done_r <= 0;
        rw_cnt_r   <= 15;
        write_test_done_r <= 1;
      end
      if(gpio_io_o_w != exp_out_result_reg_r) begin
        error_flag_r = 1;
        $display("Error` WRITE error. Exp: %x Act: %x Time %t ps", exp_out_result_reg_r, gpio_io_o_w, $realtime);
      end
    end
  end
end

reg [1:0] delay_2;

//READ Test
always @ (posedge clk_i) begin
  if (resetn_i == 0) 
    delay_2        <= 2'b00;
  else if((test_state_r == READ_TEST) && (read_test_done_r == 0) && (resetn_i == 1)) begin
    lmmi_offset_i  <= RD_DATA_REG_ADDR;
    lmmi_request_i <= 0;
    lmmi_wr_rdn_i  <= 0;
    gpio_io_i_r    <= rw_data_r[rw_cnt_r];

    if(delay_2[1] && (cmd_done_r == 0)) begin  // send read command only after 2 cycles delay from previous access
      lmmi_offset_i   <= RD_DATA_REG_ADDR;
      lmmi_request_i  <= 1;
      lmmi_wr_rdn_i   <= 0;
      exp_in_result_r <= rw_data_r[rw_cnt_r];
      if(lmmi_ready_o == 1) begin
        cmd_done_r <= 1;
      end
    end
    if(lmmi_rdata_valid_o == 1) begin
      delay_2  <= 2'b00;
      if(rw_cnt_r > 0)begin
        rw_cnt_r   <= rw_cnt_r - 1;
        cmd_done_r <= 0;
      end
      else begin
        cmd_done_r <= 0;
        rw_cnt_r   <= 15;
        read_test_done_r <= 1;
      end
      if((lmmi_rdata_o & (~direction_reg_r)) != exp_in_result_reg_r) begin
        error_flag_r = 1;
        $display("Error` READ error. Exp: %x Act: %x Time %t ps", exp_in_result_reg_r, (lmmi_rdata_o & (~direction_reg_r)), $realtime);
      end
    end
    else 
      delay_2  <= {delay_2[0], 1'b1}; 
  end
end

//Rising edge interrupt Test
always @ (posedge clk_i) begin
  if((test_state_r == RISING_EDGE_INT_TEST) && (rising_edge_int_test_done_r == 0) && (resetn_i == 1)) begin
    lmmi_offset_i  <= 0;
    lmmi_request_i <= 0;
    lmmi_wr_rdn_i  <= 0;
    lmmi_wdata_i   <= {IO_LINES_COUNT {1'b0}};

    if((&direction_reg_r)== 0) begin
      case(int_test_state_r)
        0: begin //Clear all interrupts
          lmmi_offset_i    <= INT_STATUS_REG_ADDR;
          lmmi_request_i   <= 1;
          lmmi_wr_rdn_i    <= 1;
          lmmi_wdata_i     <= {IO_LINES_COUNT {1'b1}};
          if(lmmi_ready_o == 1) begin
            int_test_state_r <= 1;
          end
          gpio_io_i_r      <= direction_reg_r;
        end

        1: begin //Configure for edge interrupt
          lmmi_offset_i    <= INT_TYPE_REG_ADDR;
          lmmi_request_i   <= 1;
          lmmi_wr_rdn_i    <= 1;
          lmmi_wdata_i     <= {IO_LINES_COUNT {1'b0}};
          if(lmmi_ready_o == 1) begin
            int_test_state_r <= 2;
          end
        end

        2: begin //Configure for rising edge interrupt
          lmmi_offset_i    <= INT_METHOD_REG_ADDR;
          lmmi_request_i   <= 1;
          lmmi_wr_rdn_i    <= 1;
          lmmi_wdata_i     <= {IO_LINES_COUNT {1'b1}};
          if(lmmi_ready_o == 1) begin
            int_test_state_r <= 3;
          end
        end

        3: begin  //Write interrupt enable register
          lmmi_offset_i    <= INT_ENABLE_REG_ADDR;
          lmmi_request_i   <= 1;
          lmmi_wr_rdn_i    <= 1;
          lmmi_wdata_i     <= (~direction_reg_r);
          if(lmmi_ready_o == 1) begin
            int_test_state_r <= 4;
          end
        end

        4: begin //provide rising edge
          gpio_io_i_r      <= ~direction_reg_r;
          int_test_state_r <= 5;
        end

        5: begin
          if(int_o == 1'b1) begin //Clear interrupt
            lmmi_offset_i    <= INT_STATUS_REG_ADDR;
            lmmi_request_i   <= 1;
            lmmi_wr_rdn_i    <= 1;
            lmmi_wdata_i     <= (~direction_reg_r);
            int_test_state_r <= 6;
          end
        end

        6: begin //Clear interrupt
          lmmi_offset_i    <= INT_STATUS_REG_ADDR;
          lmmi_request_i   <= 1;
          lmmi_wr_rdn_i    <= 1;
          lmmi_wdata_i     <= (~direction_reg_r);
          if(lmmi_ready_o == 1) begin
            if(cmd_done_r == 0) begin
              cmd_done_r       <= 1;
              int_test_state_r <= 4;
              gpio_io_i_r      <= direction_reg_r; //set all inputs to 0
            end
            else begin
              int_test_state_r <= 7;
            end
          end
        end

        7: begin //Rising edge test is complete.
          lmmi_offset_i    <= INT_ENABLE_REG_ADDR;
          lmmi_request_i   <= 1;
          lmmi_wr_rdn_i    <= 1;
          lmmi_wdata_i     <= {IO_LINES_COUNT{1'b0}};
          if(lmmi_ready_o == 1) begin
            int_test_state_r <= 0;
            cmd_done_r       <= 0;
            int_test_state_r <= 0;
            rising_edge_int_test_done_r <= 1;
          end
        end
      endcase
    end
    else begin
      rising_edge_int_test_done_r <= 1;
    end
  end
end


//Falling edge interrupt Test
always @ (posedge clk_i) begin
  if((test_state_r == FALLING_EDGE_INT_TEST) && (falling_edge_int_test_done_r == 0) && (resetn_i == 1)) begin
    lmmi_offset_i  <= 0;
    lmmi_request_i <= 0;
    lmmi_wr_rdn_i  <= 0;
    lmmi_wdata_i   <= {IO_LINES_COUNT {1'b0}};

    if((&direction_reg_r)== 0) begin
      case(int_test_state_r)
        0: begin //Clear all interrupts
          lmmi_offset_i    <= INT_STATUS_REG_ADDR;
          lmmi_request_i   <= 1;
          lmmi_wr_rdn_i    <= 1;
          lmmi_wdata_i     <= {IO_LINES_COUNT {1'b1}};
          if(lmmi_ready_o == 1) begin
            int_test_state_r <= 1;
          end
          gpio_io_i_r      <= ~direction_reg_r;
        end

        1: begin //Configure for edge interrupt
          lmmi_offset_i    <= INT_TYPE_REG_ADDR;
          lmmi_request_i   <= 1;
          lmmi_wr_rdn_i    <= 1;
          lmmi_wdata_i     <= {IO_LINES_COUNT {1'b0}};
          if(lmmi_ready_o == 1) begin
            int_test_state_r <= 2;
          end
        end

        2: begin //Configure for falling edge interrupt
          lmmi_offset_i    <= INT_METHOD_REG_ADDR;
          lmmi_request_i   <= 1;
          lmmi_wr_rdn_i    <= 1;
          lmmi_wdata_i     <= {IO_LINES_COUNT {1'b0}};
          if(lmmi_ready_o == 1) begin
            int_test_state_r <= 3;
          end
        end

        3: begin  //Write interrupt enable register
          lmmi_offset_i    <= INT_ENABLE_REG_ADDR;
          lmmi_request_i   <= 1;
          lmmi_wr_rdn_i    <= 1;
          lmmi_wdata_i     <= (~direction_reg_r);
          if(lmmi_ready_o == 1) begin
            int_test_state_r <= 4;
          end
        end

        4: begin //provide falling edge
          gpio_io_i_r      <= direction_reg_r;
          int_test_state_r <= 5;
        end

        5: begin
          if(int_o == 1'b1) begin //Clear interrupt
            lmmi_offset_i    <= INT_STATUS_REG_ADDR;
            lmmi_request_i   <= 1;
            lmmi_wr_rdn_i    <= 1;
            lmmi_wdata_i     <= (~direction_reg_r);
            int_test_state_r <= 6;
          end
        end

        6: begin
          lmmi_offset_i    <= INT_STATUS_REG_ADDR;
          lmmi_request_i   <= 1;
          lmmi_wr_rdn_i    <= 1;
          lmmi_wdata_i     <= (~direction_reg_r);
          if(lmmi_ready_o == 1) begin
            if(cmd_done_r == 1) begin
              cmd_done_r       <= 1;
              int_test_state_r <= 4;
              gpio_io_i_r      <= ~direction_reg_r; //set all inputs to 0
            end
            else begin
              int_test_state_r <= 7;
            end
          end
        end

        7: begin //Falling edge test is complete.
          lmmi_offset_i    <= INT_ENABLE_REG_ADDR;
          lmmi_request_i   <= 1;
          lmmi_wr_rdn_i    <= 1;
          lmmi_wdata_i     <= {IO_LINES_COUNT{1'b0}};
          if(lmmi_ready_o == 1) begin
            cmd_done_r       <= 0;
            int_test_state_r <= 0;
            falling_edge_int_test_done_r <= 1;
          end
        end
      endcase
    end
    else begin
      falling_edge_int_test_done_r <= 1;
    end
  end
end


//High Level interrupt Test
always @ (posedge clk_i) begin
  if((test_state_r == HIGH_LEVEL_INT_TEST) && (high_level_int_test_done_r == 0) && (resetn_i == 1)) begin
    lmmi_offset_i  <= 0;
    lmmi_request_i <= 0;
    lmmi_wr_rdn_i  <= 0;
    lmmi_wdata_i   <= {IO_LINES_COUNT {1'b0}};

    if((&direction_reg_r)== 0) begin
      case(int_test_state_r)
        0: begin //Clear all interrupts
          lmmi_offset_i    <= INT_STATUS_REG_ADDR;
          lmmi_request_i   <= 1;
          lmmi_wr_rdn_i    <= 1;
          lmmi_wdata_i     <= {IO_LINES_COUNT {1'b1}};
          gpio_io_i_r      <= direction_reg_r;
          if(lmmi_ready_o == 1) begin
            int_test_state_r <= 1;
          end
        end

        1: begin //Configure for level interrupt
          lmmi_offset_i    <= INT_TYPE_REG_ADDR;
          lmmi_request_i   <= 1;
          lmmi_wr_rdn_i    <= 1;
          lmmi_wdata_i     <= {IO_LINES_COUNT {1'b1}};
          if(lmmi_ready_o == 1) begin
            int_test_state_r <= 2;
          end
        end

        2: begin //Configure for high level interrupt
          lmmi_offset_i    <= INT_METHOD_REG_ADDR;
          lmmi_request_i   <= 1;
          lmmi_wr_rdn_i    <= 1;
          lmmi_wdata_i     <= {IO_LINES_COUNT {1'b1}};
          if(lmmi_ready_o == 1) begin
            int_test_state_r <= 3;
          end
        end

        3: begin  //Write interrupt enable register
          lmmi_offset_i    <= INT_ENABLE_REG_ADDR;
          lmmi_request_i   <= 1;
          lmmi_wr_rdn_i    <= 1;
          lmmi_wdata_i     <= (~direction_reg_r);
          if(lmmi_ready_o == 1) begin
            int_test_state_r <= 4;
          end
        end

        4: begin //provide high level
          gpio_io_i_r      <= ~direction_reg_r;
          int_test_state_r <= 5;
        end

        5: begin
          if(int_o == 1'b1) begin //Clear interrupt
            lmmi_offset_i    <= INT_STATUS_REG_ADDR;
            lmmi_request_i   <= 1;
            lmmi_wr_rdn_i    <= 1;
            lmmi_wdata_i     <= (~direction_reg_r);
            gpio_io_i_r      <= direction_reg_r; //set all inputs to 0
            int_test_state_r <= 6;
          end
        end

        6: begin
          lmmi_offset_i  <= INT_STATUS_REG_ADDR;
          lmmi_request_i <= 1;
          lmmi_wr_rdn_i  <= 1;
          lmmi_wdata_i   <= (~direction_reg_r);
          if(lmmi_ready_o == 1) begin
            if(cmd_done_r == 0) begin
              cmd_done_r       <= 1;
              int_test_state_r <= 4;
              gpio_io_i_r      <= direction_reg_r; //set all inputs to 0
            end
            else begin
              int_test_state_r <= 7;
            end
          end
        end

        7: begin //High level interrupt test is complete.
          lmmi_offset_i    <= INT_ENABLE_REG_ADDR;
          lmmi_request_i   <= 1;
          lmmi_wr_rdn_i    <= 1;
          lmmi_wdata_i     <= {IO_LINES_COUNT{1'b0}};
          if(lmmi_ready_o == 1) begin
            cmd_done_r       <= 0;
            int_test_state_r <= 0;
            high_level_int_test_done_r <= 1;
          end
        end
      endcase
    end
    else begin
      high_level_int_test_done_r <= 1;
    end
  end
end


//Low Level interrupt Test
always @ (posedge clk_i) begin
  if((test_state_r == LOW_LEVEL_INT_TEST) && (low_level_int_test_done_r == 0) && (resetn_i == 1)) begin
    lmmi_offset_i  <= 0;
    lmmi_request_i <= 0;
    lmmi_wr_rdn_i  <= 0;
    lmmi_wdata_i   <= {IO_LINES_COUNT {1'b0}};

    if((&direction_reg_r)== 0) begin
      case(int_test_state_r)
        0: begin //Clear all interrupts
          lmmi_offset_i    <= INT_STATUS_REG_ADDR;
          lmmi_request_i   <= 1;
          lmmi_wr_rdn_i    <= 1;
          lmmi_wdata_i     <= {IO_LINES_COUNT {1'b1}};
          if(lmmi_ready_o == 1) begin
            int_test_state_r <= 1;
          end
          gpio_io_i_r      <= ~direction_reg_r;
        end

        1: begin //Configure for level interrupt
          lmmi_offset_i    <= INT_TYPE_REG_ADDR;
          lmmi_request_i   <= 1;
          lmmi_wr_rdn_i    <= 1;
          lmmi_wdata_i     <= {IO_LINES_COUNT {1'b1}};
          if(lmmi_ready_o == 1) begin
            int_test_state_r <= 2;
          end
        end

        2: begin //Configure for low level interrupt
          lmmi_offset_i    <= INT_METHOD_REG_ADDR;
          lmmi_request_i   <= 1;
          lmmi_wr_rdn_i    <= 1;
          lmmi_wdata_i     <= {IO_LINES_COUNT {1'b0}};
          if(lmmi_ready_o == 1) begin
            int_test_state_r <= 3;
          end
        end

        3: begin  //Write interrupt enable register
          lmmi_offset_i    <= INT_ENABLE_REG_ADDR;
          lmmi_request_i   <= 1;
          lmmi_wr_rdn_i    <= 1;
          lmmi_wdata_i     <= (~direction_reg_r);
          if(lmmi_ready_o == 1) begin
            int_test_state_r <= 4;
          end
        end

        4: begin //provide low level
          gpio_io_i_r      <= direction_reg_r;
          int_test_state_r <= 5;
        end

        5: begin
          if(int_o == 1'b1) begin //Clear interrupt
            lmmi_offset_i    <= INT_STATUS_REG_ADDR;
            lmmi_request_i   <= 1;
            lmmi_wr_rdn_i    <= 1;
            lmmi_wdata_i     <= (~direction_reg_r);
            gpio_io_i_r      <= ~direction_reg_r; //set all inputs to 1
            int_test_state_r <= 6;
          end
        end

        6: begin //Clear interrupt
          lmmi_offset_i    <= INT_STATUS_REG_ADDR;
          lmmi_request_i   <= 1;
          lmmi_wr_rdn_i    <= 1;
          lmmi_wdata_i     <= (~direction_reg_r);
          if(lmmi_ready_o == 1) begin
            if(cmd_done_r == 0) begin
              cmd_done_r       <= 1;
              int_test_state_r <= 4;
            end
            else begin
              int_test_state_r <= 7;
            end
          end
        end

        7: begin //low level interrupt test is complete.
          lmmi_offset_i    <= INT_ENABLE_REG_ADDR;
          lmmi_request_i   <= 1;
          lmmi_wr_rdn_i    <= 1;
          lmmi_wdata_i     <= {IO_LINES_COUNT{1'b0}};
          if(lmmi_ready_o == 1) begin
            cmd_done_r       <= 0;
            int_test_state_r <= 0;
            low_level_int_test_done_r <= 1;
          end
        end
      endcase
    end
    else begin
      low_level_int_test_done_r <= 1;
    end
  end
end

generate
  wire [5:0] apb_lmmi_offset_i;
  assign apb_lmmi_offset_i [1:0] = 2'b00;

  if(IF_USER_INTF == "APB") begin
	assign apb_lmmi_offset_i [5:2] = lmmi_offset_i;
  lscc_lmmi2apb # (
    .DATA_WIDTH (IO_LINES_COUNT),
    .ADDR_WIDTH (6),
    .REG_OUTPUT (0)
  ) lscc_lmmi2apb_0
  (
    .clk_i  (clk_i),
    .rst_n_i(resetn_i),

    .lmmi_request_i(lmmi_request_i),         // start transaction
    .lmmi_wr_rdn_i (lmmi_wr_rdn_i ),         // write 1, read 0
    .lmmi_offset_i (apb_lmmi_offset_i ),         // address/offset
    .lmmi_wdata_i  (lmmi_wdata_i  ),         // write data

    .lmmi_ready_o      (lmmi_ready_o),       // slave is ready to start new transaction
    .lmmi_rdata_valid_o(lmmi_rdata_valid_o), // read transaction is complete
    .lmmi_error_o      (lmmi_error_o),       // error indicator
    .lmmi_rdata_o      (lmmi_rdata_o),       // read data
    .lmmi_resetn_o     (lmmi_resetn_o),      // lmmi active low reset

    .apb_pready_i (apb_pready_o),            // apb ready
    .apb_pslverr_i(apb_pslverr_o),           // apb slave error
    .apb_prdata_i (apb_prdata_o[IO_LINES_COUNT-1:0]),            // apb read data

    .apb_penable_o(apb_penable_i),           // apb enable
    .apb_psel_o   (apb_psel_i),              // apb slave select
    .apb_pwrite_o (apb_pwrite_i),            // apb write 1, read 0
    .apb_paddr_o  (apb_paddr_i),             // apb address
    .apb_pwdata_o (apb_pwdata_w)             // apb write data
  );
	always@* begin
		if(IO_LINES_COUNT <= 31) begin
			apb_pwdata_i = {{(32-IO_LINES_COUNT){1'b0}}, apb_pwdata_w};
		end
		else if (IO_LINES_COUNT == 32) begin
			apb_pwdata_i = apb_pwdata_w;
		end
	end

  end
endgenerate
// ----------------------------
// GSR instance
// ----------------------------
`ifdef ICE40UP

`define iCE40UP

`endif

`ifndef iCE40UP
GSR GSR_INST ( .GSR_N(1'b1), .CLK(1'b0));
`endif


`include "dut_inst.v"

endmodule
