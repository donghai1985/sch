vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -work xil_defaultlib  -incr -mfcu "+incdir+../../../ip/vio_spi_cfg/hdl/verilog" "+incdir+../../../ip/vio_spi_cfg/hdl" \
"../../../ip/vio_spi_cfg/sim/vio_spi_cfg.v" \


vlog -work xil_defaultlib \
"glbl.v"

