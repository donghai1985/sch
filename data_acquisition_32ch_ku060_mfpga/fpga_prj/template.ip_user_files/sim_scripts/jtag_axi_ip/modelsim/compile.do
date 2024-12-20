vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -work xil_defaultlib  -incr -mfcu "+incdir+../../../../template.gen/sources_1/ip/jtag_axi_ip/hdl/verilog" \
"../../../../template.gen/sources_1/ip/jtag_axi_ip/sim/jtag_axi_ip.v" \


vlog -work xil_defaultlib \
"glbl.v"

