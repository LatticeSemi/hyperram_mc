onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_top/clk
add wave -noupdate /tb_top/rstn
add wave -noupdate /tb_top/ram0_ck_n
add wave -noupdate /tb_top/ram0_ck_p
add wave -noupdate /tb_top/ram0_cs
add wave -noupdate /tb_top/ram0_dq
add wave -noupdate /tb_top/ram0_rst
add wave -noupdate /tb_top/ram0_rw
add wave -noupdate /tb_top/ram1_ck_n
add wave -noupdate /tb_top/ram1_ck_p
add wave -noupdate /tb_top/ram1_cs
add wave -noupdate /tb_top/ram1_dq
add wave -noupdate /tb_top/ram1_rw
add wave -noupdate /tb_top/hyperram_chip01/Config_reg_0
add wave -noupdate /tb_top/hyperram_chip01/Config_reg_1
add wave -noupdate /tb_top/D6_HaperRam_master/s1_uart_txd_o
add wave -noupdate /tb_top/uart_model/uart_model_inst/i_uart_rx/uart_rx_valid
add wave -noupdate /tb_top/uart_model/uart_model_inst/i_uart_rx/uart_rx_data
add wave -noupdate /tb_top/D6_HaperRam_master/hram_controller0_inst/hyperram_mc_inst/controller/rx_fifo_wr_en
add wave -noupdate {/tb_top/D6_HaperRam_master/hram_controller0_inst/hyperram_mc_inst/channel[0]/phy/dq_rawdata_i}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1467854565000 fs} 0} {{Cursor 2} {2888587410000 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 265
configure wave -valuecolwidth 175
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ms
update
WaveRestoreZoom {1467741377920 fs} {1468243475100 fs}
