-makelib ies_lib/xpm -sv \
  "D:/Xilinx2021/Vivado/2021.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "D:/Xilinx2021/Vivado/2021.1/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
  "D:/Xilinx2021/Vivado/2021.1/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib ies_lib/xpm \
  "D:/Xilinx2021/Vivado/2021.1/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies_lib/jtag_axi \
  "../../../ipstatic/hdl/jtag_axi_v1_2_rfs.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../../template.gen/sources_1/ip/jtag_axi_ip/sim/jtag_axi_ip.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  glbl.v
-endlib

