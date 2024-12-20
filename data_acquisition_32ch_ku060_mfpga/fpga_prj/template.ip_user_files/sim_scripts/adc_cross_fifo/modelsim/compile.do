vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -work xil_defaultlib  -incr -mfcu \
"../../../ip/adc_cross_fifo/sim/adc_cross_fifo.v" \


vlog -work xil_defaultlib \
"glbl.v"

