//////////////////////////////////////////////////////////////////////
// File Downloaded from http://www.nandland.com
//////////////////////////////////////////////////////////////////////
// This file contains the UART Receiver.  This receiver is able to
// receive 8 bits of serial data, one start bit, one stop bit,
// and no parity bit.  When receive is complete o_rx_dv will be
// driven high for one clock cycle.
// 
// Set Parameter CLKS_PER_BIT as follows:
// CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
// Example: 10 MHz Clock, 115200 baud UART
// (10000000)/(115200) = 87
//
// Note: This file has been modified by Lattice
`ifndef UART_RX
`define UART_RX

module uart_rx 
  #(
    parameter        SERIAL_DATA_WIDTH = 8,
    parameter  [1:0] STOP_BITS         = 1,
    parameter  [1:0] PARITY_TYPE       = 0,
    parameter  [0:0] STICK_PARITY      = 0,
    parameter [15:0] CLKS_PER_BIT      = 432)
  (
    input            i_Clock     ,
    input            i_Reset_n   ,
    input            i_Rx_Serial ,
    output           o_Rx_par_err,
    output           o_Rx_DV     ,
    output [7:0]     o_Rx_Byte
   );
  localparam sWIDTH         = 5;
  localparam s_IDLE         = 5'h01;
  localparam s_RX_START_BIT = 5'h02;
  localparam s_RX_DATA_BITS = 5'h04;
  localparam s_TX_PAR_BIT   = 5'h08;
  localparam s_RX_STOP_BIT  = 5'h10;
//  localparam s_CLEANUP      = 6'h20;
//  localparam [2:0] LAST_BIT = SERIAL_DATA_WIDTH - 1;
  
  reg              r_Rx_Data_R = 1'b1;
  reg              r_Rx_Data   = 1'b1;
   
  reg [15:0]       r_Clock_Count;
  reg [3:0]        r_Bit_Index  ; //8 bits total
  reg [7:0]        r_Rx_Byte    ;
  reg              r_Rx_DV      ;
  reg [sWIDTH-1:0] r_SM_Main    ;
  reg              r_parity     ;
  reg              r_parity_err ;
  // control reg
  reg              stop_bits_2  ;
  reg              parity_en    ;
  reg              parity_even  ;
  reg              stick_parity ;
  reg [3:0]        data_width   ;
  
  wire             clock_cnt_half_max;
  wire             clock_cnt_not_max;

  assign  clock_cnt_half_max = (r_Clock_Count == (CLKS_PER_BIT-1)/2);
  assign  clock_cnt_not_max  = (r_Clock_Count < CLKS_PER_BIT-1);
  
  
  initial begin
    stop_bits_2  = STOP_BITS[1];
    parity_en    = (PARITY_TYPE == 2'b00) ? 1'b0: 1'b1;
    parity_even  = PARITY_TYPE[1];
    stick_parity = STICK_PARITY;
    data_width   = SERIAL_DATA_WIDTH;
  end
   
  // Purpose: Double-register the incoming data.
  // This allows it to be used in the UART RX Clock Domain.
  // (It removes problems caused by metastability)
  always @(posedge i_Clock or negedge i_Reset_n)
    begin
      if (!i_Reset_n)
        begin
          r_Rx_Data_R <= 1'b1;
          r_Rx_Data   <= 1'b1;
        end
      else
        begin
          r_Rx_Data_R <= i_Rx_Serial;
          r_Rx_Data   <= r_Rx_Data_R;        
        end
    end
   
   
  // Purpose: Control RX state machine
  always @(posedge i_Clock or negedge i_Reset_n)
    begin
      if (!i_Reset_n)
        begin
          r_Rx_DV       <= 1'b0;
          r_Clock_Count <= 16'h0000;
          r_Bit_Index   <= 3'h0;
          r_SM_Main     <= s_IDLE;
          r_Rx_Byte     <= 8'h00;
          r_parity      <= 1'b0;
          r_parity_err  <= 1'b0;
        end
      else
        begin
          case (r_SM_Main)
            s_IDLE :
              begin
                r_Rx_DV       <= 1'b0;
                r_Clock_Count <= 16'h0000;
                r_Bit_Index   <= 3'h0;
                r_parity_err  <= 1'b0;
                r_parity      <= 1'b0;
                if (r_Rx_Data == 1'b0)          // Start bit detected
                  r_SM_Main   <= s_RX_START_BIT;
                else
                  r_SM_Main   <= s_IDLE;
              end
             
            // Check middle of start bit to make sure it's still low
            s_RX_START_BIT :
              begin
                if (clock_cnt_not_max)
                  begin
                    r_Clock_Count <= r_Clock_Count + 16'h1;
                    if (clock_cnt_half_max && (r_Rx_Data == 1'b1)) 
                      begin
                        r_SM_Main <= s_IDLE;
                        $error("[%010t] [UART_MDL]: Error in Start bit!", $time);
                      end
                    else 
                      r_SM_Main   <= s_RX_START_BIT;
                  end
                else
                  begin
                    r_Clock_Count <= 16'h0000;
                    r_SM_Main     <= s_RX_DATA_BITS;
                  end
              end // case: s_RX_START_BIT
             
             
            // Wait CLKS_PER_BIT-1 clock cycles to sample serial data
            s_RX_DATA_BITS :
              begin
                if (clock_cnt_not_max)
                  begin
                    r_Clock_Count <= r_Clock_Count + 16'h1;
                    r_SM_Main     <= s_RX_DATA_BITS;
                    if (clock_cnt_half_max)  // sample data at half-bit period 
                      begin
                        r_Rx_Byte[r_Bit_Index] <= r_Rx_Data;
                        r_parity    <= r_parity ^ r_Rx_Data;
                        if (r_Bit_Index != data_width)
                          r_Bit_Index <= r_Bit_Index + 1;
                      end
                  end
                else
                  begin
                    r_Clock_Count          <= 16'h0000;
                    // Check if we have received all bits
                    if (r_Bit_Index < data_width)
                        r_SM_Main   <= s_RX_DATA_BITS;
                    else
                      begin
                        r_Bit_Index <= 0;
                        r_SM_Main   <= (parity_en) ? s_TX_PAR_BIT : s_RX_STOP_BIT;
                      end
                  end
              end // case: s_RX_DATA_BITS
          
            // Receive Stop bit.  Stop bit = 1
            s_TX_PAR_BIT :
              begin
                // Wait CLKS_PER_BIT-1 clock cycles for Stop bit to finish
                if (clock_cnt_not_max)
                  begin
                    r_Clock_Count <= r_Clock_Count + 16'h1;
                    r_SM_Main     <= s_TX_PAR_BIT;
                    if (clock_cnt_half_max)  // sample data at half-bit period 
                      begin
                        if (((parity_even) ? r_parity : ~r_parity) == r_Rx_Data)
                          r_parity_err <= 1'b0;
                        else
                          r_parity_err <= 1'b1;
                      end
                  end
                else
                  begin
                    r_Rx_DV       <= 1'b0;
                    r_Clock_Count <= 16'h0000;
                    r_SM_Main     <= s_RX_STOP_BIT;
                  end
              end // case: s_TX_PAR_BIT
              
            // Receive Stop bit.  Stop bit = 1
            s_RX_STOP_BIT :
              begin
                // Wait CLKS_PER_BIT-1 clock cycles for Stop bit to finish
                if (clock_cnt_not_max)
                  begin
                    r_Clock_Count <= r_Clock_Count + 16'h1;
                    r_SM_Main     <= s_RX_STOP_BIT;
                    if ((clock_cnt_half_max) && (!r_Rx_Data))
                      $error("[%010t] [UART_MDL]: r_Rx_Data is 1'b0 during stop bit!", $time);
                      
                  end
                else
                  begin
                    r_Rx_DV       <= 1'b1;
                    r_Clock_Count <= 16'h0000;
                    r_SM_Main     <= s_IDLE;
                  end
              end // case: s_RX_STOP_BIT
          
             
            // Stay here 1 clock
//            s_CLEANUP :
//              begin
//                r_SM_Main <= s_IDLE;
//                r_Rx_DV   <= 1'b0;
//              end
             
             
            default :
              r_SM_Main <= s_IDLE;
             
          endcase
        end
    end   
    
  assign o_Rx_par_err = r_parity_err;
  assign o_Rx_DV      = r_Rx_DV;
  assign o_Rx_Byte    = r_Rx_Byte;
   
endmodule // uart_rx
`endif