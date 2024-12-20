vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -work xil_defaultlib  -incr -mfcu "+incdir+../../../ipstatic" "+incdir+../../../../template.gen/sources_1/ip/pll" \
"../../../../template.gen/sources_1/ip/pll/pll_clk_wiz.v" \
"../../../../template.gen/sources_1/ip/pll/pll.v" \


vlog -work xil_defaultlib \
"glbl.v"

