#set_property PACKAGE_PIN AM27 [get_ports board_100_p]
#set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports board_100_p]

#set_property PACKAGE_PIN AF26 [get_ports {cha_debug_led[0]}]
#set_property PACKAGE_PIN AT23 [get_ports {cha_debug_led[1]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {cha_debug_led[0]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {cha_debug_led[1]}]

#set_property PACKAGE_PIN k27 [get_ports FAN_PWREN]
#set_property IOSTANDARD LVCMOS18 [get_ports FAN_PWREN]
















#ddr 1
















#create_clock -period 5.000 -name c0_sys_clk_p [get_ports c0_sys_clk_p]

####################################################################################
# Constraints from file : 'pin.xdc'
####################################################################################




####################################################################################
# Constraints from file : 'axi_interconnect_0_impl_clocks.xdc'
####################################################################################


set_property PACKAGE_PIN AM10 [get_ports c0_sys_clk_p]
set_property PACKAGE_PIN AM9 [get_ports c0_sys_clk_n]
set_property PACKAGE_PIN AH9 [get_ports {c0_ddr4_adr[0]}]
set_property PACKAGE_PIN AL10 [get_ports {c0_ddr4_adr[1]}]
set_property PACKAGE_PIN AJ11 [get_ports {c0_ddr4_adr[2]}]
set_property PACKAGE_PIN AR8 [get_ports {c0_ddr4_adr[3]}]
set_property PACKAGE_PIN AJ9 [get_ports {c0_ddr4_adr[4]}]
set_property PACKAGE_PIN AM12 [get_ports {c0_ddr4_adr[5]}]
set_property PACKAGE_PIN AH12 [get_ports {c0_ddr4_adr[6]}]
set_property PACKAGE_PIN AV9 [get_ports {c0_ddr4_adr[7]}]
set_property PACKAGE_PIN AJ12 [get_ports {c0_ddr4_adr[8]}]
set_property PACKAGE_PIN AG9 [get_ports {c0_ddr4_adr[9]}]
set_property PACKAGE_PIN AK10 [get_ports {c0_ddr4_adr[10]}]
set_property PACKAGE_PIN AG10 [get_ports {c0_ddr4_adr[11]}]
set_property PACKAGE_PIN AM8 [get_ports {c0_ddr4_adr[12]}]
set_property PACKAGE_PIN AW9 [get_ports {c0_ddr4_adr[13]}]
set_property PACKAGE_PIN AK11 [get_ports {c0_ddr4_adr[14]}]
set_property PACKAGE_PIN AN10 [get_ports {c0_ddr4_adr[15]}]
set_property PACKAGE_PIN AP7 [get_ports {c0_ddr4_adr[16]}]
set_property PACKAGE_PIN AK9 [get_ports c0_ddr4_act_n]
set_property PACKAGE_PIN AH11 [get_ports {c0_ddr4_ba[0]}]
set_property PACKAGE_PIN AL11 [get_ports {c0_ddr4_ba[1]}]
set_property PACKAGE_PIN AH10 [get_ports {c0_ddr4_bg[0]}]
set_property PACKAGE_PIN AL8 [get_ports {c0_ddr4_odt[0]}]
set_property PACKAGE_PIN AK13 [get_ports c0_ddr4_reset_n]
set_property PACKAGE_PIN AM7 [get_ports {c0_ddr4_ck_t[0]}]
set_property PACKAGE_PIN AN7 [get_ports {c0_ddr4_ck_c[0]}]
set_property PACKAGE_PIN AL12 [get_ports {c0_ddr4_cke[0]}]
set_property PACKAGE_PIN AN9 [get_ports {c0_ddr4_cs_n[0]}]
set_property PACKAGE_PIN AJ14 [get_ports {c0_ddr4_dq[0]}]
set_property PACKAGE_PIN AH17 [get_ports {c0_ddr4_dq[1]}]
set_property PACKAGE_PIN AG15 [get_ports {c0_ddr4_dq[2]}]
set_property PACKAGE_PIN AJ17 [get_ports {c0_ddr4_dq[3]}]
set_property PACKAGE_PIN AJ13 [get_ports {c0_ddr4_dq[4]}]
set_property PACKAGE_PIN AF15 [get_ports {c0_ddr4_dq[5]}]
set_property PACKAGE_PIN AJ16 [get_ports {c0_ddr4_dq[6]}]
set_property PACKAGE_PIN AG17 [get_ports {c0_ddr4_dq[7]}]
set_property PACKAGE_PIN AM15 [get_ports {c0_ddr4_dq[8]}]
set_property PACKAGE_PIN AL17 [get_ports {c0_ddr4_dq[9]}]
set_property PACKAGE_PIN AM14 [get_ports {c0_ddr4_dq[10]}]
set_property PACKAGE_PIN AN14 [get_ports {c0_ddr4_dq[11]}]
set_property PACKAGE_PIN AL15 [get_ports {c0_ddr4_dq[12]}]
set_property PACKAGE_PIN AM17 [get_ports {c0_ddr4_dq[13]}]
set_property PACKAGE_PIN AL13 [get_ports {c0_ddr4_dq[14]}]
set_property PACKAGE_PIN AM13 [get_ports {c0_ddr4_dq[15]}]
set_property PACKAGE_PIN AP14 [get_ports {c0_ddr4_dq[16]}]
set_property PACKAGE_PIN AR15 [get_ports {c0_ddr4_dq[17]}]
set_property PACKAGE_PIN AR14 [get_ports {c0_ddr4_dq[18]}]
set_property PACKAGE_PIN AT15 [get_ports {c0_ddr4_dq[19]}]
set_property PACKAGE_PIN AN16 [get_ports {c0_ddr4_dq[20]}]
set_property PACKAGE_PIN AP17 [get_ports {c0_ddr4_dq[21]}]
set_property PACKAGE_PIN AN15 [get_ports {c0_ddr4_dq[22]}]
set_property PACKAGE_PIN AN17 [get_ports {c0_ddr4_dq[23]}]
set_property PACKAGE_PIN AW14 [get_ports {c0_ddr4_dq[24]}]
set_property PACKAGE_PIN AW18 [get_ports {c0_ddr4_dq[25]}]
set_property PACKAGE_PIN AV15 [get_ports {c0_ddr4_dq[26]}]
set_property PACKAGE_PIN AW17 [get_ports {c0_ddr4_dq[27]}]
set_property PACKAGE_PIN AV14 [get_ports {c0_ddr4_dq[28]}]
set_property PACKAGE_PIN AT17 [get_ports {c0_ddr4_dq[29]}]
set_property PACKAGE_PIN AU15 [get_ports {c0_ddr4_dq[30]}]
set_property PACKAGE_PIN AT16 [get_ports {c0_ddr4_dq[31]}]
set_property PACKAGE_PIN AH19 [get_ports {c0_ddr4_dq[32]}]
set_property PACKAGE_PIN AH21 [get_ports {c0_ddr4_dq[33]}]
set_property PACKAGE_PIN AJ19 [get_ports {c0_ddr4_dq[34]}]
set_property PACKAGE_PIN AJ21 [get_ports {c0_ddr4_dq[35]}]
set_property PACKAGE_PIN AF20 [get_ports {c0_ddr4_dq[36]}]
set_property PACKAGE_PIN AJ22 [get_ports {c0_ddr4_dq[37]}]
set_property PACKAGE_PIN AF21 [get_ports {c0_ddr4_dq[38]}]
set_property PACKAGE_PIN AH22 [get_ports {c0_ddr4_dq[39]}]
set_property PACKAGE_PIN AK19 [get_ports {c0_ddr4_dq[40]}]
set_property PACKAGE_PIN AM22 [get_ports {c0_ddr4_dq[41]}]
set_property PACKAGE_PIN AL20 [get_ports {c0_ddr4_dq[42]}]
set_property PACKAGE_PIN AL22 [get_ports {c0_ddr4_dq[43]}]
set_property PACKAGE_PIN AM20 [get_ports {c0_ddr4_dq[44]}]
set_property PACKAGE_PIN AK20 [get_ports {c0_ddr4_dq[45]}]
set_property PACKAGE_PIN AN19 [get_ports {c0_ddr4_dq[46]}]
set_property PACKAGE_PIN AM19 [get_ports {c0_ddr4_dq[47]}]
set_property PACKAGE_PIN AP19 [get_ports {c0_ddr4_dq[48]}]
set_property PACKAGE_PIN AR20 [get_ports {c0_ddr4_dq[49]}]
set_property PACKAGE_PIN AR19 [get_ports {c0_ddr4_dq[50]}]
set_property PACKAGE_PIN AN20 [get_ports {c0_ddr4_dq[51]}]
set_property PACKAGE_PIN AR18 [get_ports {c0_ddr4_dq[52]}]
set_property PACKAGE_PIN AN21 [get_ports {c0_ddr4_dq[53]}]
set_property PACKAGE_PIN AP18 [get_ports {c0_ddr4_dq[54]}]
set_property PACKAGE_PIN AT20 [get_ports {c0_ddr4_dq[55]}]
set_property PACKAGE_PIN AW21 [get_ports {c0_ddr4_dq[56]}]
set_property PACKAGE_PIN AU19 [get_ports {c0_ddr4_dq[57]}]
set_property PACKAGE_PIN AV19 [get_ports {c0_ddr4_dq[58]}]
set_property PACKAGE_PIN AW22 [get_ports {c0_ddr4_dq[59]}]
set_property PACKAGE_PIN AW19 [get_ports {c0_ddr4_dq[60]}]
set_property PACKAGE_PIN AU22 [get_ports {c0_ddr4_dq[61]}]
set_property PACKAGE_PIN AU18 [get_ports {c0_ddr4_dq[62]}]
set_property PACKAGE_PIN AT22 [get_ports {c0_ddr4_dq[63]}]
set_property PACKAGE_PIN AG14 [get_ports {c0_ddr4_dm_dbi_n[0]}]
set_property PACKAGE_PIN AK15 [get_ports {c0_ddr4_dm_dbi_n[1]}]
set_property PACKAGE_PIN AP16 [get_ports {c0_ddr4_dm_dbi_n[2]}]
set_property PACKAGE_PIN AV16 [get_ports {c0_ddr4_dm_dbi_n[3]}]
set_property PACKAGE_PIN AG19 [get_ports {c0_ddr4_dm_dbi_n[4]}]
set_property PACKAGE_PIN AL18 [get_ports {c0_ddr4_dm_dbi_n[5]}]
set_property PACKAGE_PIN AP21 [get_ports {c0_ddr4_dm_dbi_n[6]}]
set_property PACKAGE_PIN AU20 [get_ports {c0_ddr4_dm_dbi_n[7]}]
set_property PACKAGE_PIN AH16 [get_ports {c0_ddr4_dqs_t[0]}]
set_property PACKAGE_PIN AH15 [get_ports {c0_ddr4_dqs_c[0]}]
set_property PACKAGE_PIN AK16 [get_ports {c0_ddr4_dqs_t[1]}]
set_property PACKAGE_PIN AL16 [get_ports {c0_ddr4_dqs_c[1]}]
set_property PACKAGE_PIN AR13 [get_ports {c0_ddr4_dqs_t[2]}]
set_property PACKAGE_PIN AT13 [get_ports {c0_ddr4_dqs_c[2]}]
set_property PACKAGE_PIN AU17 [get_ports {c0_ddr4_dqs_t[3]}]
set_property PACKAGE_PIN AV17 [get_ports {c0_ddr4_dqs_c[3]}]
set_property PACKAGE_PIN AG20 [get_ports {c0_ddr4_dqs_t[4]}]
set_property PACKAGE_PIN AH20 [get_ports {c0_ddr4_dqs_c[4]}]
set_property PACKAGE_PIN AK21 [get_ports {c0_ddr4_dqs_t[5]}]
set_property PACKAGE_PIN AL21 [get_ports {c0_ddr4_dqs_c[5]}]
set_property PACKAGE_PIN AN22 [get_ports {c0_ddr4_dqs_t[6]}]
set_property PACKAGE_PIN AP22 [get_ports {c0_ddr4_dqs_c[6]}]
set_property PACKAGE_PIN AV22 [get_ports {c0_ddr4_dqs_t[7]}]
set_property PACKAGE_PIN AV21 [get_ports {c0_ddr4_dqs_c[7]}]

set_property IOSTANDARD DIFF_SSTL12 [get_ports c0_sys_clk_p]
set_property IOSTANDARD DIFF_SSTL12 [get_ports c0_sys_clk_n]

####################################################################################
# Constraints from file : 'axi_interconnect_0_impl_clocks.xdc'
####################################################################################

