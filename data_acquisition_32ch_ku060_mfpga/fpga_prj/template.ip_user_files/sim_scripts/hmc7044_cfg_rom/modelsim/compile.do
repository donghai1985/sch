vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -work xil_defaultlib  -incr -mfcu \
"../../../../template.gen/sources_1/ip/hmc7044_cfg_rom/sim/hmc7044_cfg_rom.v" \


vlog -work xil_defaultlib \
"glbl.v"

