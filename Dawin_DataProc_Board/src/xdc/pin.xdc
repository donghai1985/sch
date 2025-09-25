set_property PACKAGE_PIN AM27 [get_ports sysclk_p]
set_property PACKAGE_PIN AN27 [get_ports sysclk_n]


set_property PACKAGE_PIN F33 [get_ports cha_fan_fg]
set_property PACKAGE_PIN H31 [get_ports cha_fan_pwm]
set_property PACKAGE_PIN K27 [get_ports cha_fan_pwren]
set_property PACKAGE_PIN AR25 [get_ports TMP75_IIC_SDA]
set_property PACKAGE_PIN AR26 [get_ports TMP75_IIC_SCL]


set_property PACKAGE_PIN AA7 [get_ports gt_226_ref_clk_p]
set_property PACKAGE_PIN U7 [get_ports gt_227_ref_clk_p]


set_property IOSTANDARD LVDS [get_ports sysclk_p]
set_property IOSTANDARD LVDS [get_ports sysclk_n]
set_property IOSTANDARD LVCMOS18 [get_ports cha_fan_fg]
set_property IOSTANDARD LVCMOS18 [get_ports cha_fan_pwm]
set_property IOSTANDARD LVCMOS18 [get_ports cha_fan_pwren]
set_property IOSTANDARD LVCMOS18 [get_ports TMP75_IIC_SDA]
set_property IOSTANDARD LVCMOS18 [get_ports TMP75_IIC_SCL]

####################################################################################
# Constraints from file : 'timing.xdc'
####################################################################################

set_property PACKAGE_PIN H24 [get_ports CHA_QSFP2_RESETL]
set_property PACKAGE_PIN K26 [get_ports CHA_QSFP3_RESETL]
set_property PACKAGE_PIN H26 [get_ports CHA_QSFP2_LPMODE_1V8]
set_property PACKAGE_PIN H27 [get_ports CHA_QSFP3_LPMODE_1V8]
set_property PACKAGE_PIN G26 [get_ports CHA_QSFP2_MODSELL]
set_property PACKAGE_PIN G27 [get_ports CHA_QSFP3_MODSELL]
set_property IOSTANDARD LVCMOS18 [get_ports CHA_QSFP2_RESETL]
set_property IOSTANDARD LVCMOS18 [get_ports CHA_QSFP3_RESETL]
set_property IOSTANDARD LVCMOS18 [get_ports CHA_QSFP2_LPMODE_1V8]
set_property IOSTANDARD LVCMOS18 [get_ports CHA_QSFP3_LPMODE_1V8]
set_property IOSTANDARD LVCMOS18 [get_ports CHA_QSFP2_MODSELL]
set_property IOSTANDARD LVCMOS18 [get_ports CHA_QSFP3_MODSELL]



set_property PACKAGE_PIN L24 [get_ports CHA_QSFP4_RESETL]
set_property PACKAGE_PIN P25 [get_ports CHA_QSFP5_RESETL]
set_property PACKAGE_PIN P24 [get_ports CHA_QSFP4_LPMODE_1V8]
set_property PACKAGE_PIN P26 [get_ports CHA_QSFP5_LPMODE_1V8]
set_property PACKAGE_PIN K23 [get_ports CHA_QSFP4_MODSELL]
set_property PACKAGE_PIN N24 [get_ports CHA_QSFP5_MODSELL]
set_property IOSTANDARD LVCMOS18 [get_ports CHA_QSFP4_RESETL]
set_property IOSTANDARD LVCMOS18 [get_ports CHA_QSFP5_RESETL]
set_property IOSTANDARD LVCMOS18 [get_ports CHA_QSFP4_LPMODE_1V8]
set_property IOSTANDARD LVCMOS18 [get_ports CHA_QSFP5_LPMODE_1V8]
set_property IOSTANDARD LVCMOS18 [get_ports CHA_QSFP4_MODSELL]
set_property IOSTANDARD LVCMOS18 [get_ports CHA_QSFP5_MODSELL]

####################################################################################
# GT 226/227
####################################################################################
set_property PACKAGE_PIN AA7 [get_ports gt_226_ref_clk_p]
set_property PACKAGE_PIN AD5 [get_ports gt_226_txp_out[0]]
set_property PACKAGE_PIN AC2 [get_ports gt_226_rxp_in[0]]
set_property PACKAGE_PIN AB5 [get_ports gt_226_txp_out[1]]
set_property PACKAGE_PIN AA2 [get_ports gt_226_rxp_in[1]]
set_property PACKAGE_PIN V5 [get_ports gt_226_txp_out[2]]
set_property PACKAGE_PIN W2 [get_ports gt_226_rxp_in[2]]
set_property PACKAGE_PIN T5 [get_ports gt_226_txp_out[3]]
set_property PACKAGE_PIN U2 [get_ports gt_226_rxp_in[3]]

set_property PACKAGE_PIN U7 [get_ports gt_227_ref_clk_p]
set_property PACKAGE_PIN P5 [get_ports gt_227_txp_out[0]]
set_property PACKAGE_PIN R2 [get_ports gt_227_rxp_in[0]]
set_property PACKAGE_PIN M5 [get_ports gt_227_txp_out[1]]
set_property PACKAGE_PIN N2 [get_ports gt_227_rxp_in[1]]
set_property PACKAGE_PIN K5 [get_ports gt_227_txp_out[2]]
set_property PACKAGE_PIN L2 [get_ports gt_227_rxp_in[2]]
set_property PACKAGE_PIN H5 [get_ports gt_227_txp_out[3]]
set_property PACKAGE_PIN J2 [get_ports gt_227_rxp_in[3]]
