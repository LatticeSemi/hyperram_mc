// -----------------------------------------------------------------------------
//   Copyright (c) 2025 by Lattice Semiconductor Corporation
//   ALL RIGHTS RESERVED
//   Subject to Lattice's Software License Agreement
// -----------------------------------------------------------------------------

module tb_top;

GSR GSR_INST (.GSR_N(1'b1));
PUR PUR_INST (.PUR(1'b1)  );

reg clk;
reg rstn;

wire [0:0]ram0_ck_n;
wire [0:0]ram0_ck_p;
wire [0:0]ram0_cs;
wire [7:0]ram0_dq;
wire [0:0]ram0_rst;
wire [0:0]ram0_rw;
wire [0:0]ram1_ck_n;
wire [0:0]ram1_ck_p;
wire [0:0]ram1_cs;
wire [7:0]ram1_dq;
wire [0:0]ram1_rw;

wire txd;

initial begin
    rstn = 1;
    #100 rstn = 0;
    #200 rstn = 1;
end
initial
begin
    clk = 0;
  forever
  begin
    #5 clk = ~clk;
  end
end

D6_HaperRam D6_HaperRam_master(
  .ram0_ck_n(ram0_ck_n),
  .ram0_ck_p(ram0_ck_p),
  .ram0_cs  (ram0_cs  ),
  .ram0_dq  (ram0_dq  ),
  .ram0_rst (ram0_rst ),
  .ram0_rw  (ram0_rw  ),
  .ram1_ck_n(ram1_ck_n),
  .ram1_ck_p(ram1_ck_p),
  .ram1_cs  (ram1_cs  ),
  .ram1_dq  (ram1_dq  ),
  .ram1_rw  (ram1_rw  ),
  .s1_uart_txd_o(txd),
  .rstn_i   (rstn)
);

uart_model1 uart_model(
  .clk(clk),
  .rstn(rstn),
  .uart_rxd(txd)
);

defparam hyperram_chip01.mem_file_name = "s27ks0641.mem";
defparam hyperram_chip01.chip_name = "chip01";
s27ks0641 hyperram_chip01
  (
  .DQ7      (ram0_dq[7]),
  .DQ6      (ram0_dq[6]),
  .DQ5      (ram0_dq[5]),
  .DQ4      (ram0_dq[4]),
  .DQ3      (ram0_dq[3]),
  .DQ2      (ram0_dq[2]),
  .DQ1      (ram0_dq[1]),
  .DQ0      (ram0_dq[0]),
  .RWDS     (ram0_rw),
  .CSNeg    (ram0_cs),
  .CK       (ram0_ck_p),
  .CKNeg    (ram0_ck_n),
  .RESETNeg (ram0_rst)
  );
defparam hyperram_chip02.mem_file_name = "s27ks0641_2.mem";
defparam hyperram_chip02.chip_name = "chip02";
s27ks0641 hyperram_chip02
  (
  .DQ7      (ram1_dq[7]),
  .DQ6      (ram1_dq[6]),
  .DQ5      (ram1_dq[5]),
  .DQ4      (ram1_dq[4]),
  .DQ3      (ram1_dq[3]),
  .DQ2      (ram1_dq[2]),
  .DQ1      (ram1_dq[1]),
  .DQ0      (ram1_dq[0]),
  .RWDS     (ram1_rw),
  .CSNeg    (ram1_cs),
  .CK       (ram1_ck_p),
  .CKNeg    (ram1_ck_n),
  .RESETNeg (ram0_rst)
  );
endmodule