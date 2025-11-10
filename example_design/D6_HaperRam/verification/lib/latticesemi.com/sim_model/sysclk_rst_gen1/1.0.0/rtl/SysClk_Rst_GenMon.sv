// Name         : SysClk_Rst_GenMon
// Author       : LatticeSemi
// Last updated : 2022.8.12

`ifndef SYSCLK_RST_GENMON_TB
   `define SYSCLK_RST_GENMON_TB

`timescale 1ns/1ps

module SysClk_Rst_GenMon #(parameter
   DUT_CLK_IN_EN = 0,
   DUT_RST_IN_EN = 0,
   TB_CLK_PERIOD = 10,
   TB_CLK_DUTY = 50,
   TB_RST_POL = 0,
   TB_RST_PERIOD = 50,
   INIT_RST = 1
   )(
   input dut_clk_i,
   input dut_rst_i,
   output dut_clk_o,
   output dut_rst_o,
   output tb_rst_o,
   output tb_clk_o
   );

   real   clk_period_ns;      // clock period in ns
   real   clk_freq_mhz;       // clock frequency in MHz
   real   clk_duty;           // clock duty cycle
   reg    clk_gate = 1'b0;
   initial begin
     clk_period_ns = real'(TB_CLK_PERIOD);
     clk_freq_mhz  =  real'(1000) / real'(TB_CLK_PERIOD);
     clk_duty      = real'(TB_CLK_DUTY) / real'(100);
   end

   wire   rst_pol;
   real   rst_period_ns;
   real   rst_period_left;
   reg    rst_enable = 0;
   initial begin
     rst_period_ns   = real'(TB_RST_PERIOD);
	 rst_period_left = real'(0);
   end
   assign rst_pol = TB_RST_POL;

   wire   dut_clk_enable;
   wire   dut_rst_enable;
   assign dut_clk_enable = DUT_CLK_IN_EN;
   assign dut_rst_enable = DUT_RST_IN_EN;

   reg    clk_o = 1'b0;
   reg    rst_o = !TB_RST_POL;
   reg    init_rst_o = !TB_RST_POL;

   // Clocking blocks
   clocking tb_cb @(posedge tb_clk_o);
   endclocking

   clocking tb_cbn @(negedge tb_clk_o);
   endclocking

   clocking dut_cb @(posedge dut_clk_o);
   endclocking

   clocking dut_cbn @(negedge dut_clk_o);
   endclocking

   // Set clock period in ns
   function automatic void set_clk_period_ns(real period_ns);
      clk_period_ns = period_ns;
      clk_freq_mhz = real'(1000) / period_ns;
      $display("Testbench clock frequency set to %f Mhz, clock period set to %f ns", clk_freq_mhz, clk_period_ns);
   endfunction

   // Set clock frequency in MHz
   function automatic void set_clk_freq_mhz(real freq_mhz);
      clk_period_ns = real'(1000) / freq_mhz;
      clk_freq_mhz = freq_mhz;
      $display("Testbench clock frequency set to %f Mhz, clock period set to %f ns", clk_freq_mhz, clk_period_ns);
   endfunction

   // Set clock duty cycle
   function automatic void set_clk_duty(real duty);
      clk_duty = duty / real'(100);
   endfunction

   // Enable clock
   function automatic void start_clk();
      clk_gate = 1'b0;
   endfunction

   // Disable clock
   function automatic void stop_clk();
      clk_gate = 1'b1;
   endfunction

   // Set reset period
   function automatic void set_rst_period(real period_ns);
      rst_period_ns = period_ns;
   endfunction

   // Set reset period in testbench clock cycles
   function automatic void set_rst_cycles(int num_cycles);
      rst_period_ns = clk_period_ns * num_cycles;
   endfunction


   // Insert a reset period
   function automatic void insert_rst();
      rst_enable = 1'b1;
   endfunction

   // Wait specified positive tb clock edges
   task automatic wait_tb_clk_posedges(int num);
      repeat (num) @tb_cb;
   endtask

   // Wait specified negtive tb clock edges
   task automatic wait_tb_clk_negedges(int num);
      repeat (num) @tb_cbn;
   endtask

   // Wait specified positive dut clock edges
   task automatic wait_dut_clk_posedges(int num);
      repeat (num) @dut_cb;
   endtask

   // Wait specified negtive dut clock edges
   task automatic wait_dut_clk_negedges(int num);
      repeat (num) @dut_cbn;
   endtask

   // Halt clock for specified time(ns)
   task automatic gate_clk_ns(int gate_time);
      clk_gate = 1'b1;
      #gate_time clk_gate = 1'b0;
   endtask

   // Halt clock for specified cycles
   task automatic gate_clk_cycles(int num_cycles);
      clk_gate = 1'b1;
      #(num_cycles * clk_period_ns) clk_gate = 1'b0;
   endtask

   // Clock & reset scheme 1
   task automatic clk_rst_scheme1();
      fork
         insert_rst();
         start_clk();
      join
   endtask

   always@(posedge rst_enable) begin
      rst_o = TB_RST_POL;
      #rst_period_ns rst_o = !TB_RST_POL;
      rst_enable = 1'b0;
   end

   initial begin
      init_rst_o = !TB_RST_POL;
      if (INIT_RST) begin
         init_rst_o = TB_RST_POL;
         #rst_period_ns init_rst_o = !TB_RST_POL;
      end
   end

   initial begin
      forever begin
         if(!clk_gate) begin
            #(clk_period_ns * (real'(1)-clk_duty)) clk_o = 1'b1;
            #(clk_period_ns * clk_duty) clk_o = 1'b0;
         end else begin
            #clk_period_ns;
         end
      end
   end

   assign tb_clk_o = clk_o;
   assign tb_rst_o = rst_pol ? (rst_o | init_rst_o) : (rst_o & init_rst_o);
   assign dut_clk_o = dut_clk_enable ? dut_clk_i : 1'bz;
   assign dut_rst_o = dut_rst_enable ? dut_rst_i : 1'bz;


endmodule

`endif
