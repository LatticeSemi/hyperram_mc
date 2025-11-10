`timescale 1ns/1ns

//==========================================================================
// Module : tb_top
// Description : Testbench for TCM IP
//==========================================================================

module tb_top ();

// Clock and Reset Declarations
reg                         sys_rst_n                 ;
reg                         sys_clk                   ;
// Data port from CPU
reg                         ibus_cmd_valid            ;
wire                        ibus_cmd_ready            ;
reg                         ibus_cmd_payload_wr       ;
reg                         ibus_cmd_payload_uncached ; 
reg  [31:0]                 ibus_cmd_payload_address  ;
reg  [31:0]                 ibus_cmd_payload_data     ;
reg  [3:0]                  ibus_cmd_payload_mask     ;
reg  [2:0]                  ibus_cmd_payload_size     ;
reg                         ibus_cmd_payload_last     ;    
wire                        ibus_rsp_valid            ;
wire                        ibus_rsp_payload_last     ;
wire [31:0]                 ibus_rsp_payload_data     ;
wire                        ibus_rsp_payload_error    ;
// Debug ports from CPU
reg                         dbus_cmd_valid            ;
wire                        dbus_cmd_ready            ;
reg                         dbus_cmd_payload_wr       ;
reg                         dbus_cmd_payload_uncached ; 
reg  [31:0]                 dbus_cmd_payload_address  ;
reg  [31:0]                 dbus_cmd_payload_data     ;
reg  [3:0]                  dbus_cmd_payload_mask     ;
reg  [2:0]                  dbus_cmd_payload_size     ; 
reg                         dbus_cmd_payload_last     ;    
wire                        dbus_rsp_valid            ;
wire                        dbus_rsp_payload_last     ;
wire [31:0]                 dbus_rsp_payload_data     ;
wire                        dbus_rsp_payload_error    ;
reg                         ibus_bus_rdy;
reg                         dbus_bus_rdy;
// FIFO Interface
wire                        fifo_clk_i                ;
wire                        fifo_wr_en_i              ; 
wire [7:0]                  fifo_wr_data_i            ;     
wire                        fifo_interface_en_i       ;     
wire                        fifo_address_rst_i        ; 
wire                        fifo_full_o ;

`include "dut_inst.v"
`include "dut_params.v"

// GSR Instantiation
GSR GSR_INST ( .GSR_N(1'b1), .CLK(1'b0));
   
   
// Clock Generation
always #10 sys_clk = ~sys_clk;  
assign fifo_clk_i = sys_clk;

// Reset Generation
initial begin
  sys_clk   = 0;
  sys_rst_n =1'b0;
  #100;
  @(posedge sys_clk);
  sys_rst_n =1'b1;
  #30;
end  

// lscc_fifo_master # (
    // .FIFO_EN (FIFO_STREAMER_EN)
// ) fifo_master (
    // .clk_i               (fifo_clk_i),
    // .rstn_i              (sys_rst_n),

    // .fifo_wr_en_o        (fifo_wr_en_i),
    // .fifo_wr_data_o      (fifo_wr_data_i),
    // .fifo_interface_en_o (fifo_interface_en_i), 
    // .fifo_address_rst_o  (fifo_address_rst_i),
    // .fifo_full_o         (fifo_full_o)
// );

// initializing all the input variables 
initial begin
    //Port A
    ibus_cmd_valid            = 1'b0           ;        
    ibus_cmd_payload_wr       = 1'b0           ;
    ibus_cmd_payload_uncached = 1'b0           ; 
    ibus_cmd_payload_address  = 32'h00000000   ;
    ibus_cmd_payload_data     = 32'h00000000   ;
    ibus_cmd_payload_mask     = 4'b0000        ;
    ibus_cmd_payload_size     = 3'b000         ;
    ibus_cmd_payload_last     = 1'b0           ;      
    ibus_bus_rdy              = 1'b0           ; 
    //Port B    
    dbus_cmd_valid            = 1'b0           ;        
    dbus_cmd_payload_wr       = 1'b0           ;
    dbus_cmd_payload_uncached = 1'b0           ; 
    dbus_cmd_payload_address  = 32'h00000000   ;
    dbus_cmd_payload_data     = 32'h00000000   ;
    dbus_cmd_payload_mask     = 4'b0000        ;
    dbus_cmd_payload_size     = 3'b000         ;
    dbus_cmd_payload_last     = 1'b0           ; 
    dbus_bus_rdy              = 1'b0           ; 

 end
 
 
// task for writing into Port A
task write_portA; 
    input [31:0] address;
    input [3:0]  mask;
    input [31:0] data;
  begin
    @(posedge sys_clk);
    ibus_cmd_valid           = 1;
    ibus_cmd_payload_wr      = 1;
    ibus_bus_rdy             = 0;
    ibus_cmd_payload_size    = 3'b001;
    ibus_cmd_payload_mask    = mask;
    ibus_cmd_payload_address = address;
    ibus_cmd_payload_data    = data; 
    @(posedge sys_clk);
    ibus_cmd_valid           = 0;
    ibus_cmd_payload_wr      = 0;
    ibus_bus_rdy             = 0;
    ibus_cmd_payload_mask    = 4'b1111;
    ibus_cmd_payload_size    = 3'b001; 
    @(posedge sys_clk);    
  end
endtask
 
// task for writing into Port B , which accept 2 inputs namely 32bit address & 32 bit data
task write_portB; 
    input [31:0] address;
    input [3:0]  mask;
    input [31:0] data;
  begin
    dbus_cmd_valid           = 1;
    dbus_cmd_payload_wr      = 1;
    dbus_bus_rdy             = 0;
    dbus_cmd_payload_mask    = 4'b1111;
    dbus_cmd_payload_size    = 3'b001;
    dbus_cmd_payload_address = address;
    dbus_cmd_payload_data    = data; 
    @(posedge sys_clk);
    dbus_cmd_valid           = 0;
    dbus_cmd_payload_wr      = 0;
    dbus_bus_rdy             = 0;
    dbus_cmd_payload_mask    = 4'b1111;
    dbus_cmd_payload_size    = 3'b001; 
    @(posedge sys_clk);
  end
endtask 

// task for writing into Port A
task write_portA_burst; 
    input [31:0] address;
    input [3:0]  mask;
    input [31:0] data;
  begin
    @(posedge sys_clk);
    ibus_cmd_valid           = 1;
    ibus_cmd_payload_wr      = 1;
    ibus_bus_rdy             = 0;
    ibus_cmd_payload_size    = 3'b101;
    ibus_cmd_payload_mask    = mask;
    ibus_cmd_payload_address = address;
    ibus_cmd_payload_data    = 32'h11111111; 
    // @(posedge sys_clk);
    // ibus_cmd_valid           = 1;
    // ibus_cmd_payload_wr      = 1;
    // ibus_bus_rdy             = 1;
    @(posedge sys_clk);
    ibus_cmd_payload_data    = 32'h11111112; 
    ibus_cmd_valid           = 0;
    ibus_cmd_payload_wr      = 0;
    ibus_bus_rdy             = 0;
    ibus_cmd_payload_size    = 3'b001; 
    ibus_cmd_payload_mask    = 4'b1111;
    @(posedge sys_clk);
    ibus_cmd_payload_data    = 32'h11111113; 
    @(posedge sys_clk);
    ibus_cmd_payload_data    = 32'h11111114; 
    @(posedge sys_clk);
    ibus_cmd_payload_data    = 32'h11111115; 
    @(posedge sys_clk);
    ibus_cmd_payload_data    = 32'h11111116; 
    @(posedge sys_clk);
    ibus_cmd_payload_data    = 32'h11111117; 
    @(posedge sys_clk);
    ibus_cmd_payload_data    = 32'h11111118; 
  end
endtask

// task for writing into Port A
task write_portB_burst; 
    input [31:0] address;
    input [3:0]  mask;
    input [31:0] data;
  begin
    @(posedge sys_clk);
    dbus_cmd_valid           = 1;
    dbus_cmd_payload_wr      = 1;
    dbus_bus_rdy             = 0;
    dbus_cmd_payload_size    = 3'b101;
    dbus_cmd_payload_mask    = mask;
    dbus_cmd_payload_address = address;
    dbus_cmd_payload_data    = 32'h51111111; 
    @(posedge sys_clk);
    dbus_cmd_payload_data    = 32'h51111112; 
    dbus_cmd_valid           = 0;
    dbus_cmd_payload_wr      = 0;
    dbus_bus_rdy             = 0;
    dbus_cmd_payload_mask    = 4'b1111;
    dbus_cmd_payload_size    = 3'b001; 
    @(posedge sys_clk);
    dbus_cmd_payload_data    = 32'h51111113; 
    @(posedge sys_clk);
    dbus_cmd_payload_data    = 32'h51111114; 
    @(posedge sys_clk);
    dbus_cmd_payload_data    = 32'h51111115; 
    @(posedge sys_clk);
    dbus_cmd_payload_data    = 32'h51111116; 
    @(posedge sys_clk);
    dbus_cmd_payload_data    = 32'h51111117; 
    @(posedge sys_clk);
    dbus_cmd_payload_data    = 32'h51111118; 
  end
endtask

// task for reading from Port A
task read_portA;
     input  [31:0] address;
     input  [3:0]  mask;
     output [31:0] data;
   begin
     @(posedge sys_clk);
     ibus_cmd_valid           = 1;
     ibus_cmd_payload_wr      = 0;
     ibus_bus_rdy             = 0;
     ibus_cmd_payload_mask    = mask;
     ibus_cmd_payload_size    = 3'b001; 
     ibus_cmd_payload_address = address;
     @(posedge sys_clk);
     ibus_cmd_valid           = 0;
     ibus_cmd_payload_wr      = 0;
     ibus_bus_rdy             = 0;
     ibus_cmd_payload_address = 0;
     wait(ibus_rsp_valid == 1'b1);
     @(posedge sys_clk);
     data = ibus_rsp_payload_data;
     $display("Port:A - Read data at %x is %x",address,data);
     @(posedge sys_clk);     
   end
endtask

// task for reading from Port A
task read_portB;
     input  [31:0] address;
     input  [3:0]  mask;
     output [31:0] data;
   begin
     @(posedge sys_clk);
     dbus_cmd_valid           = 1;
     dbus_cmd_payload_wr      = 0;
     dbus_bus_rdy             = 0;
     dbus_cmd_payload_mask    = mask;
     dbus_cmd_payload_size    = 3'b001; 
     dbus_cmd_payload_address = address;
     @(posedge sys_clk);
     dbus_cmd_valid           = 0;
     dbus_cmd_payload_wr      = 0;
     dbus_bus_rdy             = 0;
     dbus_cmd_payload_address = 0;
     wait(dbus_rsp_valid == 1'b1);
     @(posedge sys_clk);
     data = dbus_rsp_payload_data;
     $display("Port:B - Read data at %x is %x",address,data);
     @(posedge sys_clk);
   end
endtask
 
// task for reading from Port A
task read_portA_burst;
     input  [31:0] address;
     input  [3:0]  mask;
     input  [31:0] data_to_be_compare;
     output pass_fail_flag;
     reg    [31:0] data [7:0];
     reg    [7:0] pass_fail;
     integer i,j;
   begin
     @(posedge sys_clk);
     ibus_cmd_valid           = 1;
     ibus_cmd_payload_wr      = 0;
     ibus_bus_rdy             = 0;
     ibus_cmd_payload_mask    = mask;
     ibus_cmd_payload_size    = 3'b101; 
     ibus_cmd_payload_address = address;
     @(posedge sys_clk);
     ibus_cmd_valid           = 0;
     ibus_cmd_payload_wr      = 0;
     ibus_bus_rdy             = 0;
     ibus_cmd_payload_address = 0;
     for(i=0;i<8;i=i+1)
     begin 
      wait(ibus_rsp_valid == 1'b1);
      @(posedge sys_clk);
      data[i] = ibus_rsp_payload_data;
      $display("Port:A - Read Burst data at %x is %x",address,data[i]);
     end
     if(data[0] == data_to_be_compare)begin 
       $display("location[%0d] burst data matched : PASSED",0);
       pass_fail[0] = 1; 
     end
     else begin 
       $display("location[%0d] burst data not matched : FAILED!\n At %0t DUT DATA = %x, DATA_TO_BE_COMPARED = %x",0,$time,data[0],data_to_be_compare);
       pass_fail[0] = 0;
     end
     for(j=1;j<8;j=j+1)begin
       if(data[j] == data[j-1] + 32'h04040404)begin
         $display("location[%0d] burst data matched : PASSED",j);
         pass_fail[j] = 1;
       end else begin 
         $display("location[%0d] burst data not matched : FAILED!\n At %0t DUT DATA = %x, DATA_TO_BE_COMPARED = %x",j,$time,data[j],data[j-1]+32'h04040404);
         pass_fail[j] = 0;
       end
     end
     pass_fail_flag = pass_fail & 8'b11111111;
      @(posedge sys_clk);
   end
endtask

// task for reading from Port B
task read_portB_burst;
     input  [31:0] address;
     input  [3:0]  mask;
     input  [31:0] data_to_be_compare;
     output pass_fail_flag;
     reg    [31:0] data [7:0];
     reg    [7:0] pass_fail;
     integer i,j;
   begin
     @(posedge sys_clk);
     dbus_cmd_valid           = 1;
     dbus_cmd_payload_wr      = 0;
     dbus_bus_rdy             = 0;
     dbus_cmd_payload_mask    = mask;
     dbus_cmd_payload_size    = 3'b101; 
     dbus_cmd_payload_address = address;
     @(posedge sys_clk);
     dbus_cmd_valid           = 0;
     dbus_cmd_payload_wr      = 0;
     dbus_bus_rdy             = 0;
     dbus_cmd_payload_address = 0;
     for(i=0;i<8;i=i+1)
     begin 
      wait(dbus_rsp_valid == 1'b1);
      @(posedge sys_clk);
      data[i] = dbus_rsp_payload_data;
      $display("Port:B - Read Burst data at %x is %x",address,data[i]);
     end
     if(data[0] == data_to_be_compare)begin 
       $display("location[%0d] burst data matched : PASSED",0);
       pass_fail[0] = 1; 
     end
     else begin 
       $display("location[%0d] burst data not matched : FAILED!\n At %0t DUT DATA = %x, DATA_TO_BE_COMPARED = %x",0,$time,data[0],data_to_be_compare);
       pass_fail[0] = 0;
     end
     for(j=1;j<8;j=j+1)begin
       if(data[j] == data[j-1] + 32'h04040404)begin
         $display("location[%0d] burst data matched : PASSED",j);
         pass_fail[j] = 1;
       end else begin 
         $display("location[%0d] burst data not matched : FAILED!\n At %0t DUT DATA = %x, DATA_TO_BE_COMPARED = %x",j,$time,data[j],data[j-1]+32'h04040404);
         pass_fail[j] = 0;
       end
     end
     pass_fail_flag = pass_fail & 8'b11111111;
     @(posedge sys_clk);
   end
endtask
 
// task for writing 1st byte into Port A 
task write_portA_1st_byte;
  input [29:0]address;
  input [31:0]data;
  begin
    ibus_cmd_valid           = 1;
    ibus_cmd_payload_wr      = 1;
    ibus_bus_rdy             = 0;
    ibus_cmd_payload_mask    = 4'b0001;
    ibus_cmd_payload_size    = 3'b000;
    ibus_cmd_payload_address = {address,2'b00};
    ibus_cmd_payload_data    = data; 
  end
endtask
 
//task for writing 2nd byte into Port A  
task write_portA_2nd_byte;
 input [29:0]address;
 input [31:0]data;
 begin
 ibus_cmd_valid=1;
 ibus_cmd_payload_wr=1;
 ibus_bus_rdy=0;
 ibus_cmd_payload_mask=4'b0010;
 ibus_cmd_payload_size=3'b000;
 ibus_cmd_payload_address={address,2'b01};
 ibus_cmd_payload_data=data; 
 end
endtask
 
//task for writing 3rd byte into Port A 
task write_portA_3rd_byte;
 input [29:0]address;
 input [31:0]data;
 begin
 ibus_cmd_valid=1;
 ibus_cmd_payload_wr=1;
 ibus_bus_rdy=0;
 ibus_cmd_payload_mask=4'b0100;
 ibus_cmd_payload_size=3'b000;
 ibus_cmd_payload_address={address,2'b10};
 ibus_cmd_payload_data=data; 
 end
endtask
 
//task for writing 4th byte into Port A  
task write_portA_4th_byte;
 input [29:0]address;
 input [31:0]data;
 begin
 ibus_cmd_valid=1;
 ibus_cmd_payload_wr=1;
 ibus_bus_rdy=0;
 ibus_cmd_payload_mask=4'b1000;
 ibus_cmd_payload_size=3'b000;
 ibus_cmd_payload_address={address,2'b11};
 ibus_cmd_payload_data=data; 
 end
endtask
   
// task for reading from 1st byte Port A 
task read_portA_1st_byte;
 input [29:0]address;
 begin
 ibus_cmd_valid=1;
 ibus_cmd_payload_wr=0;
 ibus_bus_rdy=0;
 ibus_cmd_payload_mask=4'b0001;
 ibus_cmd_payload_size=3'b000;
 ibus_cmd_payload_address={address,2'b00};
 end
endtask
 
 
// task for reading from 2nd byte Port A
task read_portA_2nd_byte;
 input [29:0]address;
 begin
 ibus_cmd_valid=1;
 ibus_cmd_payload_wr=0;
 ibus_bus_rdy=0;
 ibus_cmd_payload_mask=4'b0010;
 ibus_cmd_payload_size=3'b000;
 ibus_cmd_payload_address={address,2'b01};
 end
endtask
 
 
// task for reading from 3rd byte Port A
task read_portA_3rd_byte;
 input [29:0]address;
 begin
 ibus_cmd_valid=1;
 ibus_cmd_payload_wr=0;
 ibus_bus_rdy=0;
 ibus_cmd_payload_mask=4'b0100;
 ibus_cmd_payload_size=3'b000;
 ibus_cmd_payload_address={address,2'b10}; 
 end
endtask
 
// task for reading from 4th byte Port A
task read_portA_4th_byte;
 input [29:0]address;
 begin
 ibus_cmd_valid=1;
 ibus_cmd_payload_wr=0;
 ibus_bus_rdy=0;
 ibus_cmd_payload_mask=4'b1000;
 ibus_cmd_payload_size=3'b000;
 ibus_cmd_payload_address={address,2'b11};
 end
endtask


// task for reading from 1st byte Port B
task read_portB_1st_byte;
 input [29:0]address;
 begin
 dbus_cmd_valid=1;
 dbus_cmd_payload_wr=0;
 dbus_bus_rdy=0;
 dbus_cmd_payload_mask=4'b0001;
 dbus_cmd_payload_size=3'b000;
 dbus_cmd_payload_address={address,2'b00};
 end
endtask
 
 
// task for reading from 2nd byte Port B
task read_portB_2nd_byte;
 input [29:0]address;
 begin
 dbus_cmd_valid=1;
 dbus_cmd_payload_wr=0;
 dbus_bus_rdy=0;
 dbus_cmd_payload_mask=4'b0010;
 dbus_cmd_payload_size=3'b000;
 dbus_cmd_payload_address={address,2'b01};
 end
endtask
 
 
// task for reading from 3rd byte Port B
task read_portB_3rd_byte;
 input [29:0]address;
 begin
 dbus_cmd_valid=1;
 dbus_cmd_payload_wr=0;
 dbus_bus_rdy=0;
 dbus_cmd_payload_mask=4'b0100;
 dbus_cmd_payload_size=3'b000;
 dbus_cmd_payload_address={address,2'b10}; 
 end
endtask
 
 
// task for reading from 4th byte Port B
task read_portB_4th_byte;
 input [29:0]address;
 begin
 dbus_cmd_valid=1;
 dbus_cmd_payload_wr=0;
 dbus_bus_rdy=0;
 dbus_cmd_payload_mask=4'b1000;
 dbus_cmd_payload_size=3'b000;
 dbus_cmd_payload_address={address,2'b11};
 end
endtask
 
//Task for comparision
task compare;
  input [31:0] dut_output_data;
  input [31:0] data_to_be_compare;
  output pass_fail_flag;
 begin 
   if(dut_output_data == data_to_be_compare)begin
     $display("At time %0t, Reading Successfull!",$time);
     pass_fail_flag = 1;
   end 
   else begin 
     $display("At time %0t, Reading Failed!! with output data = %x",$time,dut_output_data);
     pass_fail_flag = 0;
   end
 end 
endtask 

reg [31:0] data;
reg pass_fail_flag;
reg [5:0] pass_fail_status_reg = 6'd0;
// Testcases
initial 
  begin
  #1000;
  
   $display("Single Word Read Write from PORT-A Started");
   // write_portA(32'h008, 4'b1111, 32'hABCDEF11);
    // read_portA(32'h0000, 4'b1111, data);  
    // read_portA(32'h0004, 4'b1111, data);  
    // read_portA(32'h0008, 4'b1111, data);  
        // read_portA(32'h001, 4'b1001, data); 
        // read_portA(32'h001, 4'b1010, data);  
        // read_portA(32'h001, 4'b1011, data); 
    // write_portA(32'h101, 4'b1111, 32'hABCDEF22);
     // write_portA(32'h00A, 4'b1100, 32'hABCD1234);
    // read_portA(32'h0001, 4'b1100, data);
    // read_portA(32'h0002, 4'b0011, data);
    // read_portA(32'h0003, 4'b0000, data);
    // read_portA(32'h0004, 4'b0010, data);
    // read_portA(32'h0005, 4'b0100, data);
    // read_portA(32'h0006, 4'b1000, data);
    // read_portA(32'h001, 4'b1100, data);  
    // read_portA(32'h001, 4'b1101, data); 
    // read_portA(32'h001, 4'b1110, data);  
    // read_portA(32'h001, 4'b1111, data);
    
    // write_portA(32'h201, 4'b1111, 32'hABCDEF33);
    // read_portA(32'h201, 4'b1010, data);  
    // write_portA(32'h301, 4'b1111, 32'hABCDEF44);
    // read_portA(32'h301, 4'b1011, data);
     // write_portA(32'h401, 4'b1111, 32'hABCDEF55);
    // read_portA(32'h401, 4'b1100, data); 
    // write_portA(32'h501, 4'b1111, 32'hABCDEF66);
    // read_portA(32'h501, 4'b1001, data);      
    // write_portA(32'h601, 4'b1111, 32'hABCDEF77);
    // read_portA(32'h601, 4'b1110, data);
    // write_portA(32'h701, 4'b1111, 32'hABCDEF88);
    // read_portA(32'h701, 4'b1111, data);
      
    
    // write_portA(32'h201, 4'b1111, 32'hFFFFFF86);
    // read_portA(32'h201, 4'b1000, data);
     // write_portA(32'h401, 4'b1111, 32'hFFFFFFFF);
    // read_portA(32'h401, 4'b1001, data);  
    // write_portA(32'h801, 4'b1111, 32'hFFFFFF20);
    // read_portA(32'h801, 4'b1010, data);
    // write_portA(32'h601, 4'b1111, 32'hFFFFFF12);
    // read_portA(32'h601, 4'b1011, data);
    
    // write_portB(32'h201, 4'b1111, 32'hFFFFFF86);
    // read_portB(32'h201, 4'b1111, data);
    // write_portB(32'h401, 4'b1111, 32'hFFFFFFFF);
    // read_portB(32'h401, 4'b1111, data);  
    // write_portB(32'h801, 4'b1111, 32'hFFFFFF20);
    // read_portB(32'h801, 4'b1111, data);
    // write_portB(32'd601, 4'b1111, 32'hFFFFFF12);
    // read_portB(32'd601, 4'b1111, data);
    
   // sys_rst_n =1'b0;
   // #100;
   // @(posedge sys_clk);
   // sys_rst_n =1'b1;
   // #30;
   // read_portA(32'd0, 4'b1111, data);   
       
    
     // write_portA_burst(32'd4, 4'b1111, 32'hFFFFFFFF);
     // write_portA_burst(32'd40, 4'b1111, 32'hFFFFFFFF);
     // read_portA_burst(32'd4, 4'b1111, 32'h14131211,pass_fail_flag);
     // read_portA_burst(32'd40, 4'b1111, 32'h14131211,pass_fail_flag);
     // write_portB_burst(32'd4, 4'b1111, 32'hFFFFFFFF);
     // write_portB_burst(32'd40, 4'b1111, 32'hFFFFFFFF);
     // read_portB_burst(32'd4, 4'b1111, 32'h14131211,pass_fail_flag);
     // read_portB_burst(32'd40, 4'b1111, 32'h14131211,pass_fail_flag);     
     
     read_portA(32'd0, 4'b0000, data);
     read_portA(32'd0, 4'b0001, data);
     read_portA(32'd0, 4'b0010, data);
     read_portA(32'd0, 4'b0011, data);
     read_portA(32'd0, 4'b1000, data);
     read_portA(32'd0, 4'b1001, data);
     read_portA(32'd0, 4'b1010, data);
     read_portA(32'd0, 4'b1011, data);
	 
     read_portA(32'd0, 4'b0100, data);
     read_portA(32'd0, 4'b0101, data);
     read_portA(32'd0, 4'b0110, data);
     read_portA(32'd0, 4'b0111, data);
     read_portA(32'd0, 4'b1100, data);
     read_portA(32'd0, 4'b1101, data);
     read_portA(32'd0, 4'b1110, data);
     read_portA(32'd0, 4'b1111, data);

     read_portB(32'd4, 4'b0000, data);
     read_portB(32'd4, 4'b0001, data);
     read_portB(32'd4, 4'b0010, data);
     read_portB(32'd4, 4'b0011, data);
     read_portB(32'd4, 4'b1000, data);
     read_portB(32'd4, 4'b1001, data);
     read_portB(32'd4, 4'b1010, data);
     read_portB(32'd4, 4'b1011, data);
	 
     read_portB(32'd4, 4'b0100, data);
     read_portB(32'd4, 4'b0101, data);
     read_portB(32'd4, 4'b0110, data);
     read_portB(32'd4, 4'b0111, data);
     read_portB(32'd4, 4'b1100, data);
     read_portB(32'd4, 4'b1101, data);
     read_portB(32'd4, 4'b1110, data);
     read_portB(32'd4, 4'b1111, data);


     $display("# # # # # # # # # # # # # # # # # #");
     $display("# Testcases execution started  #");
     $display("# # # # # # # # # # # # # # # # # #");
     if(FIFO_STREAMER_EN == 0)begin
        $display("---------- FIFO STREAMER DISABLED ----------");
        // Single Word Read Port A
        $display("Single Word Read from PORT-A Started");     
        read_portA(32'd0, 4'b0000,data);
        compare(data,32'h04030201,pass_fail_flag);
        pass_fail_status_reg[0] =  pass_fail_flag;
        $display("Single Word Read from PORT-A Completed");
       if(ACCESS_TYPE_S1 == "R/W")begin 
        // Single Word Read Port B
        $display("Single Word Read from PORT-B Started");
        read_portB(32'd4, 4'b0000, data);
        compare(data,32'h08070605,pass_fail_flag);
        pass_fail_status_reg[1] =  pass_fail_flag;
        $display("Single Word Read from PORT-B Completed");
       end
       // Burst Read Port A
       $display("Burst Word Read from PORT-A Started");
       read_portA_burst(32'h10, 4'b0000, 32'h14131211,pass_fail_flag);
       pass_fail_status_reg[2] =  pass_fail_flag;
       $display("Burst Word Read from PORT-A Completed");
       if(ACCESS_TYPE_S1 == "R/W")begin
        // Burst Read Port B
        $display("Burst Word Read from PORT-B Started");
        read_portB_burst(32'h0,4'b0000,32'h04030201,pass_fail_flag);
        pass_fail_status_reg[3] =  pass_fail_flag;
        $display("Burst Word Read from PORT-B Completed");
       end
       // Single Word Read Write Port A
       $display("Single Word Read Write from PORT-A Started");
       write_portA(32'd4, 4'b1111, 32'hFFFFFFFF);
       read_portA(32'd4, 4'b0000, data);
       compare(data,32'hFFFFFFFF,pass_fail_flag);
       pass_fail_status_reg[4] =  pass_fail_flag;
       $display("Single Word Read Write from PORT-A Completed");
       if(ACCESS_TYPE_S1 == "R/W")begin 
        // Single Word Read Write Port B
        $display("Single Word Read Write from PORT-B Started");
        write_portB(32'd4, 4'b1111, 32'h11111111);
        read_portB(32'd4, 4'b0000, data);
        compare(data,32'h11111111,pass_fail_flag);
        pass_fail_status_reg[5] =  pass_fail_flag;
        $display("Single Word Read Write from PORT-B Completed");
       end
       if(pass_fail_status_reg == 6'b111111)begin 
         $display("# # # # # # # # # # # # # # # # # #");
         $display("#    SIMULATION PASSED!    #");
         $display("# # # # # # # # # # # # # # # # # #");
       end else begin
         $display("# # # # # # # # # # # # # # # # # #");
         $display("#    SIMULATION FAILED!    #");
         $display("# # # # # # # # # # # # # # # # # #");
      end
     end
// --------------------- FIFO STREAMER TESTCASES ----------------------------------------------//     
     else if(FIFO_STREAMER_EN == 1)begin
      $display("---------- FIFO STREAMER ENABLED ----------");
      // #150;
      // Single Word Read Port A
      $display("Single Word Read from PORT-A Started");     
      read_portA(32'd0, 4'b0000,data);
      compare(data,32'h04030201,pass_fail_flag);
      pass_fail_status_reg[0] =  pass_fail_flag;
      $display("Single Word Read from PORT-A Completed");
      $display("%b",pass_fail_status_reg);
      
      if(ACCESS_TYPE_S1 == "R/W")begin 
        #150;
        // Single Word Read Port B
        $display("Single Word Read from PORT-B Started");
        read_portB(32'd4, 4'b0000, data);
        compare(data,32'h08070605,pass_fail_flag);
        pass_fail_status_reg[1] =  pass_fail_flag;
        $display("Single Word Read from PORT-B Completed");
       end
       // Burst Read Port A
       $display("Burst Word Read from PORT-A Started");
       read_portA_burst(32'h10, 4'b0000, 32'h14131211,pass_fail_flag);
       pass_fail_status_reg[2] =  pass_fail_flag;
       $display("Burst Word Read from PORT-A Completed");
       if(ACCESS_TYPE_S1 == "R/W")begin
        // Burst Read Port B
        $display("Burst Word Read from PORT-B Started");
        read_portB_burst(32'h0,4'b0000,32'h04030201,pass_fail_flag);
        pass_fail_status_reg[3] =  pass_fail_flag;
        $display("Burst Word Read from PORT-B Completed");
       end
       // Single Word Read Write Port A
       $display("Single Word Read Write from PORT-A Started");
       write_portA(32'd4, 4'b1111, 32'hFFFFFFFF);
       read_portA(32'd4, 4'b0000, data);
       compare(data,32'hFFFFFFFF,pass_fail_flag);
       pass_fail_status_reg[4] =  pass_fail_flag;
       $display("Single Word Read Write from PORT-A Completed");
       if(ACCESS_TYPE_S1 == "R/W")begin 
        // Single Word Read Write Port B
        $display("Single Word Read Write from PORT-B Started");
        write_portB(32'd4, 4'b1111, 32'h11111111);
        read_portB(32'd4, 4'b0000, data);
        compare(data,32'h11111111,pass_fail_flag);
        pass_fail_status_reg[5] =  pass_fail_flag;
        $display("Single Word Read Write from PORT-B Completed");
       end
       if(pass_fail_status_reg == 6'b111111)begin 
         $display("# # # # # # # # # # # # # # # # # #");
         $display("#    SIMULATION PASSED!    #");
         $display("# # # # # # # # # # # # # # # # # #");
       end else begin
         $display("# # # # # # # # # # # # # # # # # #");
         $display("#    SIMULATION FAILED!    #");
         $display("# # # # # # # # # # # # # # # # # #");
      end
      end
  /*
  // Single Word Write, Burst Read Port A 
  // write_portA(32'd4,  4'b1111, 32'hFFFFFFFF);
  // write_portA(32'd5,  4'b1111, 32'hABCDDEAD);  
  // write_portA(32'd6,  4'b1111, 32'hFFFFFFFF);  
  // write_portA(32'd7,  4'b1111, 32'hFFFFFFF0);  
  // write_portA(32'd8,  4'b1111, 32'hFFFFFF0F);  
  // write_portA(32'd9,  4'b1111, 32'hFFFFF0FF);  
  // write_portA(32'd10, 4'b1111, 32'hFFFF0FFF);  
  // write_portA(32'd11, 4'b1111, 32'hFFF0FFFF);  
  // write_portA(32'd12, 4'b1111, 32'hFF0FFFFF);  
  // write_portA(32'd13, 4'b1111, 32'hF0FFFFFF);  
  // read_portA_burst(32'd4, 4'b1111, data);  
 
  // Single Word Write, Burst Read Port B
  // write_portB(32'd4,  4'b1111, 32'hFFFFFFFF);
  // write_portB(32'd5,  4'b1111, 32'hABCDDEAD);  
  // write_portB(32'd6,  4'b1111, 32'hFFFFFFFF);  
  // write_portB(32'd7,  4'b1111, 32'hFFFFFFF0);  
  // write_portB(32'd8,  4'b1111, 32'hFFFFFF0F);  
  // write_portB(32'd9,  4'b1111, 32'hFFFFF0FF);  
  // write_portB(32'd10, 4'b1111, 32'hFFFF0FFF);  
  // write_portB(32'd11, 4'b1111, 32'hFFF0FFFF);  
  // write_portB(32'd12, 4'b1111, 32'hFF0FFFFF);  
  // write_portB(32'd13, 4'b1111, 32'hF0FFFFFF);  
  // read_portB_burst(32'd4, 4'b1111, data);  
 
  // Single Word Write Port A
  
  // read_portA_burst(32'd4);
  
  // Single Byte Read
  // @(posedge sys_clk);
  // read_portB(32'd0);
  // read_portB(32'd4);
  
  // Burst Read
  // @(posedge sys_clk);
  // read_portB_burst(32'd4);  
  // @(posedge sys_clk);
  // @(posedge sys_clk);
  // @(posedge sys_clk);
  // @(posedge sys_clk);
  // @(posedge sys_clk);
  // @(posedge sys_clk);
  // @(posedge sys_clk);
  
  
  // Port A Write read 
  // write_portA(32'd4, 32'hFFFFFFFF);
  // write_portA(32'd8, 32'hABCDDEAD);
  // read_portB(32'd4);
  // read_portB(32'd8);  

  // Port B Write read 
  // write_portB(32'd4, 32'hFFFFFFFF);
  // write_portB(32'd8, 32'hABCDDEAD);
  // read_portB(32'd4);
  // read_portB(32'd8);   
  
  // @(posedge ibus_rsp_valid);
  // if (ibus_rsp_payload_data == 32'h0001020304)
  // $display("ibus_rsp_payload_data = %x",ibus_rsp_payload_data );
   
    // write_portA(32'd286326784,32'd70025 );
    // #40;
    // @(posedge sys_clk);
    // write_portA(32'd286326788,32'd85125 );
    // #40;
    // @(posedge sys_clk);
    // write_portA(32'd286326792,32'd10578 );
    // #40;
    // @(posedge sys_clk);
    // write_portA(32'd286326796,32'd22845 );
    */
    // #300;
    // read_portB(32'd1, 4'b1111, data);
    // #60;
    // read_portB(32'd1, 4'b0010, data);
    // #20;
    // read_portB(32'd1, 4'b0100, data);
    #10000;
    $finish();
    end


endmodule

