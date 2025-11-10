//////////////////////////////////////////////////////////////////////
// File Downloaded from http://www.nandland.com
//////////////////////////////////////////////////////////////////////
// This file contains the UART Transmitter.  This transmitter is able
// to transmit 8 bits of serial data, one start bit, one stop bit,
// and no parity bit.  When transmit is complete o_Tx_done will be
// driven high for one clock cycle.
//
// Set Parameter CLKS_PER_BIT as follows:
// CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
// Example: 10 MHz Clock, 115200 baud UART
// (10000000)/(115200) = 87
//
// Note: This file has been modified by Lattice
`ifndef UART_TX
`define UART_TX

module uart_tx #(
    parameter        SERIAL_DATA_WIDTH = 8,
    parameter  [1:0] STOP_BITS         = 1,
    parameter  [1:0] PARITY_TYPE       = 0,
    parameter  [0:0] STICK_PARITY      = 0,
    parameter [15:0] CLKS_PER_BIT      = 432
  )
  (
    input       i_Clock,
    input       i_Reset_n,
    input       i_Tx_DV,
    input [7:0] i_Tx_Byte, 
    output      o_Tx_Active,
    output reg  o_Tx_Serial,
    output      o_Tx_Done
   );
  
  localparam sWIDTH         = 5;
  localparam s_IDLE         = 5'h01;
  localparam s_TX_START_BIT = 5'h02;
  localparam s_TX_DATA_BITS = 5'h04;
  localparam s_TX_PAR_BIT   = 5'h08;
  localparam s_TX_STOP_BIT  = 5'h10;
//  localparam s_CLEANUP      = 6'h20;
  localparam LAST_BIT       = SERIAL_DATA_WIDTH - 1;
   
  reg [sWIDTH-1:0] r_SM_Main    ;
  reg [15:0]       r_Clock_Count;
  reg [2:0]        r_Bit_Index  ;
  reg [7:0]        r_Tx_Data    ;
  reg              r_Tx_Done    ;
  reg              r_Tx_Active  ;
  reg              r_parity     ;
  // control reg
  reg              stop_bits_2  ;
  reg              parity_en    ;
  reg              parity_even  ;
  reg              stick_parity ;
  reg [2:0]        last_bit_idx ;
  initial begin
    stop_bits_2  = STOP_BITS[1];
    parity_en    = (PARITY_TYPE == 2'b00) ? 1'b0: 1'b1;
    parity_even  = PARITY_TYPE[1];
    stick_parity = STICK_PARITY;
    last_bit_idx = LAST_BIT;
  end
  
     
  always @(posedge i_Clock or negedge i_Reset_n)
    begin
      if (!i_Reset_n)
        begin
          o_Tx_Serial   <= 1'b1;
          r_Tx_Done     <= 1'b0;
          r_Clock_Count <= 16'h0000;
          r_Bit_Index   <= 3'h0;
          r_Tx_Data     <= 8'h00;
          r_SM_Main     <= s_IDLE;
          r_parity      <= 1'b0;
        end
      else 
        begin
          case (r_SM_Main)
            s_IDLE :
              begin
                o_Tx_Serial   <= 1'b1;         // Drive Line High for Idle
                r_Tx_Done     <= 1'b0;
                r_Clock_Count <= 16'h0000;
                r_Bit_Index   <= 3'h0;
                r_parity      <= 1'b0;       
                if (i_Tx_DV == 1'b1)
                  begin
                    r_Tx_Active <= 1'b1;
                    r_Tx_Data   <= i_Tx_Byte;
                    r_SM_Main   <= s_TX_START_BIT;
                  end
                else
                  begin 
                    r_SM_Main   <= s_IDLE;
                    r_Tx_Active <= 1'b0;
                  end
              end // case: s_IDLE
             
             
            // Send out Start Bit. Start bit = 0
            s_TX_START_BIT :
              begin
                o_Tx_Serial       <= 1'b0;
                 
                // Wait CLKS_PER_BIT-1 clock cycles for start bit to finish
                if (r_Clock_Count < CLKS_PER_BIT-1)
                  begin
                    r_Clock_Count <= r_Clock_Count + 1;
                    r_SM_Main     <= s_TX_START_BIT;
                  end
                else
                  begin
                    r_Clock_Count <= 16'h0000;
                    r_SM_Main     <= s_TX_DATA_BITS;
                  end
              end // case: s_TX_START_BIT
             
             
            // Wait CLKS_PER_BIT-1 clock cycles for data bits to finish         
            s_TX_DATA_BITS :
              begin
                o_Tx_Serial       <= r_Tx_Data[r_Bit_Index];
                if (r_Clock_Count < CLKS_PER_BIT-1)
                  begin
                    r_Clock_Count <= r_Clock_Count + 1;
                    r_SM_Main     <= s_TX_DATA_BITS;
                  end
                else
                  begin
                    r_Clock_Count <= 16'h0000;
                    r_parity          <= r_parity ^ r_Tx_Data[r_Bit_Index];
                    // Check if we have sent out all bits
                    if (r_Bit_Index < last_bit_idx)
                      begin
                        r_Bit_Index <= r_Bit_Index + 1;
                        r_SM_Main   <= s_TX_DATA_BITS;
                      end
                    else
                      begin
                        r_Bit_Index <= 0;
                        r_SM_Main   <= (parity_en) ? s_TX_PAR_BIT : s_TX_STOP_BIT;
                      end
                  end
              end // case: s_TX_DATA_BITS
              
            s_TX_PAR_BIT  : 
              begin
                if (stick_parity)
                  o_Tx_Serial     <= ~parity_even;
                else 
                  o_Tx_Serial     <= (parity_even) ? r_parity : ~r_parity;
                if (r_Clock_Count < CLKS_PER_BIT-1)
                  begin
                    r_Clock_Count <= r_Clock_Count + 1;
                    r_SM_Main     <= s_TX_PAR_BIT;
                  end
                else
                  begin
                    r_Clock_Count <= 16'h0000;
                    r_SM_Main     <= s_TX_STOP_BIT;
                  end
              end
             
            // Send out Stop bit.  Stop bit = 1
            s_TX_STOP_BIT :
              begin
                o_Tx_Serial <= 1'b1;
                 
                // Wait CLKS_PER_BIT-1 clock cycles for Stop bit to finish
                if (r_Clock_Count < CLKS_PER_BIT-1)
                  begin
                    r_Clock_Count     <= r_Clock_Count + 1;
                    r_SM_Main         <= s_TX_STOP_BIT;
                  end
                else
                  begin
                    r_Clock_Count     <= 16'h0000;
                    r_Bit_Index       <= r_Bit_Index + 3'h1;
                    if (stop_bits_2 == r_Bit_Index)
                      begin
                        r_Tx_Done     <= 1'b1  ;
                        r_SM_Main     <= s_IDLE;
                        r_Tx_Active   <= 1'b0  ;
                      end
                  end
              end // case: s_Tx_STOP_BIT
             
             
//            // Stay here 1 clock
//            s_CLEANUP :
//              begin
//                r_Tx_Done <= 1'b1  ;
//                r_SM_Main <= s_IDLE;
//              end
             
             
            default :
              r_SM_Main <= s_IDLE;
             
          endcase
        end
    end
 
  assign o_Tx_Active = r_Tx_Active;
  assign o_Tx_Done   = r_Tx_Done;
   
endmodule
`endif