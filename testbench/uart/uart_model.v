
//
// Module: uart_model
//
// Notes:
// - Top level module to be used in an implementation.
// - To be used in conjunction with the constraints/defaults.xdc file.
// - Ports can be (un)commented depending on whether they are being used.
// - The constraints file contains a complete list of the available ports
//   including the chipkit/Arduino pins.
//

`ifndef UART_MODEL_TB
   `define UART_MODEL_TB

//`include "defines.v"
`include "uart_tx.v"
`include "uart_rx.v"

//module uart_model #(parameter CLK_HZ = 50000000, BIT_RATE = 115200, PAYLOAD_BITS = 8, STACK_DEPTH =  128, STIMULUS_GEN = 0, STIMULUS_FILE_NAME = "none") (
module uart_model #(parameter CLK_MHZ = 50, BIT_RATE = 115200, PAYLOAD_BITS = 8, STACK_DEPTH =  128, STIMULUS_GEN = 0, STIMULUS_FILE_NAME = "none", DEBUG_PINS_EN = 1) (
input               clk     , // Top level system clock input.
input               rstn    , // Reset.
input   wire        uart_rxd, // UART Recieve pin.
output  wire        uart_txd, // UART transmit pin.
output  wire [7:0]  led,
output [PAYLOAD_BITS-1:0] uart_rx_data_debug,
output                    uart_rx_valid_debug,
output                    uart_rx_break_debug,
output [PAYLOAD_BITS-1:0] uart_tx_data_debug,
output                    uart_tx_en_debug,
output                    uart_tx_busy_debug
);

// Clock frequency in hertz.
//parameter CLK_HZ = 50000000;
//parameter BIT_RATE = 115200;
//parameter PAYLOAD_BITS = 8;
//parameter STACK_DEPTH =  128;
//parameter STIMULUS_GEN = 0;
//parameter STIMULUS_FILE_NAME = "none";


wire [PAYLOAD_BITS-1:0]  uart_rx_data;
wire                      uart_rx_valid;
wire                      uart_rx_break;

wire                      uart_tx_busy;
wire [PAYLOAD_BITS-1:0]  uart_tx_data;
wire                      uart_tx_en;

reg  [PAYLOAD_BITS-1:0]  led_reg;

assign  led = led_reg;
assign uart_rx_data_debug = uart_rx_data;
assign uart_rx_valid_debug = uart_rx_valid;
assign uart_rx_break_debug = uart_rx_break;
assign uart_tx_data_debug = uart_tx_data;
assign uart_tx_en_debug = uart_tx_en;
assign uart_tx_busy_debug = uart_tx_busy;

// -------------------------------------------------------------------------

// stack_data[0] is always empty: data records from stack_data[1]
reg  [PAYLOAD_BITS-1:0]  stack_data      [0:STACK_DEPTH-1];
reg  [7:0]  stack_counter   ;
reg done_flag = 0;

assign uart_tx_data = stack_data[stack_counter];
assign uart_tx_en   = !uart_tx_busy && STIMULUS_GEN && !done_flag;

reg uart_tx_en_r;

reg [7:0] valid_length = 0;

integer i;

initial begin
  if (STIMULUS_GEN == 1)
    $readmemh(STIMULUS_FILE_NAME, stack_data);
  foreach (stack_data[i]) begin
//   for (i = 0; i < 256; i = i+1) begin
    if (stack_data[i] !== 8'dx)
      valid_length = valid_length + 1;
  end
end

always @(posedge clk, negedge rstn) begin
    if(!rstn)
      uart_tx_en_r <= 1'b0;
    else
      uart_tx_en_r <= uart_tx_en;

end

always @(posedge clk, negedge rstn) begin
    if(!rstn)
      stack_counter <= 1'b0;
    else if(stack_counter == valid_length)
      done_flag <= 1'b1;
    else if(uart_tx_en_r) begin
      stack_counter <= stack_counter + 1;
    end
end

always @(posedge clk, negedge rstn) begin
    if(!rstn) begin
        led_reg <= 8'hF0;
    end else if(uart_rx_valid) begin
        led_reg <= uart_rx_data;
    end
end


// -------------------------------------------------------------------------

//
// UART RX
uart_rx #(
.BIT_RATE(BIT_RATE),
.PAYLOAD_BITS(PAYLOAD_BITS),
.CLK_MHZ  (CLK_MHZ  )
) i_uart_rx(
.clk          (clk          ), // Top level system clock input.
.resetn       (rstn         ), // Asynchronous active low reset.
.uart_rxd     (uart_rxd     ), // UART Recieve pin.
.uart_rx_en   (1'b1         ), // Recieve enable
.uart_rx_break(uart_rx_break), // Did we get a BREAK message?
.uart_rx_valid(uart_rx_valid), // Valid data recieved and available.
.uart_rx_data (uart_rx_data )  // The recieved data.
);

//
// UART Transmitter module.
//
uart_tx #(
.BIT_RATE(BIT_RATE),
.PAYLOAD_BITS(PAYLOAD_BITS),
.CLK_MHZ  (CLK_MHZ  )
) i_uart_tx(
.clk          (clk          ),
.resetn       (rstn         ),
.uart_txd     (uart_txd     ),
.uart_tx_en   (uart_tx_en   ),
.uart_tx_busy (uart_tx_busy ),
.uart_tx_data (uart_tx_data )
);


endmodule

`endif
