vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -work xil_defaultlib  -incr -mfcu "+incdir+../../../../template.gen/sources_1/ip/vio_ad9253/hdl/verilog" "+incdir+../../../../template.gen/sources_1/ip/vio_ad9253/hdl" \
"../../../../template.gen/sources_1/ip/vio_ad9253/sim/vio_ad9253.v" \


vlog -work xil_defaultlib \
"glbl.v"

