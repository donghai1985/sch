vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xpm
vlib questa_lib/msim/jtag_axi
vlib questa_lib/msim/xil_defaultlib

vmap xpm questa_lib/msim/xpm
vmap jtag_axi questa_lib/msim/jtag_axi
vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vlog -work xpm  -incr -mfcu -sv "+incdir+../../../../template.gen/sources_1/ip/jtag_axi_ip/hdl/verilog" \
"D:/Xilinx2021/Vivado/2021.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"D:/Xilinx2021/Vivado/2021.1/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
"D:/Xilinx2021/Vivado/2021.1/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm  -93 \
"D:/Xilinx2021/Vivado/2021.1/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work jtag_axi  -incr -mfcu "+incdir+../../../../template.gen/sources_1/ip/jtag_axi_ip/hdl/verilog" \
"../../../ipstatic/hdl/jtag_axi_v1_2_rfs.v" \

vlog -work xil_defaultlib  -incr -mfcu "+incdir+../../../../template.gen/sources_1/ip/jtag_axi_ip/hdl/verilog" \
"../../../../template.gen/sources_1/ip/jtag_axi_ip/sim/jtag_axi_ip.v" \

vlog -work xil_defaultlib \
"glbl.v"

