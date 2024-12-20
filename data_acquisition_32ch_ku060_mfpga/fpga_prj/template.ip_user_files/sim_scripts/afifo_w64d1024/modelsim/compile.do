vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -work xil_defaultlib  -incr -mfcu \
"../../../../template.gen/sources_1/ip/afifo_w64d1024/sim/afifo_w64d1024.v" \


vlog -work xil_defaultlib \
"glbl.v"

