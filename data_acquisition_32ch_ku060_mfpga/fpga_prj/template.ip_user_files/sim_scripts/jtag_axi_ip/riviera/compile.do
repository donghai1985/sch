vlib work
vlib riviera

vlib riviera/xpm
vlib riviera/jtag_axi
vlib riviera/xil_defaultlib

vmap xpm riviera/xpm
vmap jtag_axi riviera/jtag_axi
vmap xil_defaultlib riviera/xil_defaultlib

vlog -work xpm  -sv2k12 "+incdir+../../../../template.gen/sources_1/ip/jtag_axi_ip/hdl/verilog" \
"D:/Xilinx2021/Vivado/2021.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"D:/Xilinx2021/Vivado/2021.1/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
"D:/Xilinx2021/Vivado/2021.1/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93 \
"D:/Xilinx2021/Vivado/2021.1/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work jtag_axi  -v2k5 "+incdir+../../../../template.gen/sources_1/ip/jtag_axi_ip/hdl/verilog" \
"../../../ipstatic/hdl/jtag_axi_v1_2_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../template.gen/sources_1/ip/jtag_axi_ip/hdl/verilog" \
"../../../../template.gen/sources_1/ip/jtag_axi_ip/sim/jtag_axi_ip.v" \

vlog -work xil_defaultlib \
"glbl.v"

