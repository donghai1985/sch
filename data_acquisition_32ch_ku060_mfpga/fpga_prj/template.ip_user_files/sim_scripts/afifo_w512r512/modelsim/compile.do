vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -work xil_defaultlib  -incr -mfcu \
"../../../ip/afifo_w512r512/sim/afifo_w512r512.v" \


vlog -work xil_defaultlib \
"glbl.v"

