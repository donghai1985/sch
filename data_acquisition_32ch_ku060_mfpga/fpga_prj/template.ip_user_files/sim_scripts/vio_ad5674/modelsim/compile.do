vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -work xil_defaultlib  -incr -mfcu "+incdir+../../../ip/vio_ad5674/hdl/verilog" "+incdir+../../../ip/vio_ad5674/hdl" \
"../../../ip/vio_ad5674/sim/vio_ad5674.v" \


vlog -work xil_defaultlib \
"glbl.v"

