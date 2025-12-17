
if {[file exists work]} {
   file delete -force work
}
vlib work

vlog -timescale 1ns/100ps -f flist_d6.f  -sv -mfcu -l compile.log -suppress 2388,2083
vopt -L work -L uaplatform -L lfmxo5 -L pmi -debug -work work tb_top -l optimize.log -o design_opt +acc -suppress 8602,13259,2135,2912,1127,7063,2732
vsim -L work -L uaplatform -L lfmxo5 -L pmi -c design_opt -sv_seed 1 -lib work -l sim.log -suppress 8602,12130,10000
do wave.do
run -all
