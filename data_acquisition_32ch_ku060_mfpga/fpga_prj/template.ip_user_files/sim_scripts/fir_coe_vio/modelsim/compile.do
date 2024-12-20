vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -work xil_defaultlib  -incr -mfcu "+incdir+../../../ip/fir_coe_vio/hdl/verilog" "+incdir+../../../ip/fir_coe_vio/hdl" \
"../../../ip/fir_coe_vio/sim/fir_coe_vio.v" \


vlog -work xil_defaultlib \
"glbl.v"

