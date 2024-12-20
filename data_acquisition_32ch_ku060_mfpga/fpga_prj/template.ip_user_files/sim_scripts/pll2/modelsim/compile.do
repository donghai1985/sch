vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -work xil_defaultlib  -incr -mfcu "+incdir+../../../ipstatic" "+incdir+../../../../template.gen/sources_1/ip/pll2" \
"../../../../template.gen/sources_1/ip/pll2/pll2_clk_wiz.v" \
"../../../../template.gen/sources_1/ip/pll2/pll2.v" \


vlog -work xil_defaultlib \
"glbl.v"

