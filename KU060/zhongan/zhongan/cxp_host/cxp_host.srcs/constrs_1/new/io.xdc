

#UART print not avaliable, but constraint to unsed pins
# pl uart
set_property IOSTANDARD LVCMOS33 [get_ports UART_rxd]
set_property PACKAGE_PIN AD10 [get_ports UART_rxd]

set_property IOSTANDARD LVCMOS33 [get_ports UART_txd]
set_property PACKAGE_PIN AE10 [get_ports UART_txd]

### onBOARD CLK ###
#fmc ref_clk 
set_property PACKAGE_PIN AF6 [get_ports fmc_ref_clk_p]


#LOW SPEED TX
#LA02_N
set_property IOSTANDARD LVCMOS18 [get_ports {fmc_tx[*]}]
set_property PACKAGE_PIN AD26 [get_ports {fmc_tx[3]}]
#LA01_P_CC
set_property PACKAGE_PIN AD25 [get_ports {fmc_tx[2]}]
#LA01_N_CC 
set_property PACKAGE_PIN Y27 [get_ports {fmc_tx[1]}]
# LA00_P_CC FMC1_LA00_CC_P
set_property PACKAGE_PIN Y26 [get_ports {fmc_tx[0]}]

#led
#LA14_P green
#set_property IOSTANDARD LVCMOS18 [get_ports {cxp_led[3]}]
#set_property PACKAGE_PIN P15 [get_ports {cxp_led[3]}]
#LA13_P
#set_property IOSTANDARD LVCMOS18 [get_ports {cxp_led[2]}]
#set_property PACKAGE_PIN K16 [get_ports {cxp_led[2]}]
#LA12_P 
#set_property IOSTANDARD LVCMOS18 [get_ports {cxp_led[1]}]
#set_property PACKAGE_PIN E16 [get_ports {cxp_led[1]}]
# LA11_P
#set_property IOSTANDARD LVCMOS18 [get_ports {cxp_led[0]}]
#set_property PACKAGE_PIN M15 [get_ports {cxp_led[0]}]


### PoCXP actve low ###
#set_property IOSTANDARD LVCMOS18 [get_ports {pocxp_en_tri_o[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {pocxp_en_tri_o[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {pocxp_en_tri_o[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {pocxp_en_tri_o[0]}]

#FMC_HPC0_LA21_N LA21_N CHA_CXP_24V_PWREN  AP8
set_property PACKAGE_PIN AP8 [get_ports {pocxp_en_tri_o[0]}]
#FMC_HPC0_LA21_P LA21_P CHA_CXP_1V25_EN  AA27
set_property PACKAGE_PIN AA27 [get_ports {pocxp_en_tri_o[1]}]
#LA22_N CHA_CXP_GTH_EN    AN8
set_property PACKAGE_PIN AN8 [get_ports {pocxp_en_tri_o[2]}]
#LA22_P
#set_property PACKAGE_PIN G24 [get_ports {pocxp_en_tri_o[3]}]



#power good USER LED PL LED
set_property IOSTANDARD LVCMOS18 [get_ports power_good]
set_property PACKAGE_PIN Y22 [get_ports power_good]
## other status

