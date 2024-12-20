vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -work xil_defaultlib  -incr -mfcu \
"../../../../template.gen/sources_1/ip/rx_dist_mem/sim/rx_dist_mem.v" \


vlog -work xil_defaultlib \
"glbl.v"

