vlib work
vlib activehdl

vlib activehdl/xpm
vlib activehdl/xil_defaultlib

vmap xpm activehdl/xpm
vmap xil_defaultlib activehdl/xil_defaultlib

vlog -work xpm  -sv2k12 "+incdir+../../../../template.gen/sources_1/ip/vio_ad5592/hdl/verilog" "+incdir+../../../../template.gen/sources_1/ip/vio_ad5592/hdl" \
"D:/Xilinx2021/Vivado/2021.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"D:/Xilinx2021/Vivado/2021.1/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
"D:/Xilinx2021/Vivado/2021.1/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93 \
"D:/Xilinx2021/Vivado/2021.1/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../template.gen/sources_1/ip/vio_ad5592/hdl/verilog" "+incdir+../../../../template.gen/sources_1/ip/vio_ad5592/hdl" \
"../../../../template.gen/sources_1/ip/vio_ad5592/sim/vio_ad5592.v" \

vlog -work xil_defaultlib \
"glbl.v"
