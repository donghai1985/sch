vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -work xil_defaultlib  -incr -mfcu \
"../../../ip/sync_fifo_w512/sim/sync_fifo_w512.v" \


vlog -work xil_defaultlib \
"glbl.v"

