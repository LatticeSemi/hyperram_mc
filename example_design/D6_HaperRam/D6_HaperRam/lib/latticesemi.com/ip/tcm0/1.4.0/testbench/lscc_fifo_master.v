module lscc_fifo_master # (
  parameter FIFO_EN = 1
)(
  input            clk_i,
  input            rstn_i,
  output           fifo_wr_en_o,
  output reg [7:0] fifo_wr_data_o,
  output reg       fifo_interface_en_o,
  output reg       fifo_address_rst_o,
  input            fifo_full_o
);

reg wr_en_r;
reg [7:0] counter_data;

assign fifo_wr_en_o = wr_en_r & ~fifo_full_o;

initial begin
  if(FIFO_EN == 1) begin
    @(posedge rstn_i);
    @(posedge clk_i);
    fifo_address_rst_o  <= 1'b1;
    @(posedge clk_i);   
    fifo_address_rst_o  <= 1'b0;
    repeat(50)begin
      // wr_en_r         <= $urandom_range(1'b0,1'b1);
      wr_en_r         <= 1;
      // fifo_wr_data_o  <= $urandom_range({8{1'b0}},{8{1'b1}});
      fifo_wr_data_o  <= counter_data;
      @(posedge clk_i);
    end
    wr_en_r             <= 1'b0;
    fifo_interface_en_o <= 1'b0;
    @(posedge clk_i);
  end
end

//Counter Data generator
always @(posedge clk_i)
begin 
  if(rstn_i == 0)begin 
    counter_data <= 0;
  end else begin 
    counter_data <= (FIFO_EN) ? (counter_data + 1) : 0;
  end 
end

// Initial Block
initial begin
  fifo_interface_en_o <= FIFO_EN;
  fifo_address_rst_o  <= 1'b0;
  wr_en_r             <= 1'b0;
  fifo_wr_data_o      <= 8'h00;     
end

endmodule
