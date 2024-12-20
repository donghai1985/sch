set_property -dict {PACKAGE_PIN H23  IOSTANDARD LVCMOS18} [get_ports FPGA_RESET         ]
set_property -dict {PACKAGE_PIN AA24 IOSTANDARD LVDS    } [get_ports FPGA_MASTER_CLOCK_P]
set_property -dict {PACKAGE_PIN AA25 IOSTANDARD LVDS    } [get_ports FPGA_MASTER_CLOCK_N]
set_property DIFF_TERM true [get_ports FPGA_MASTER_CLOCK_P]
set_property DIFF_TERM true [get_ports FPGA_MASTER_CLOCK_N]

## SFP
# set_property PACKAGE_PIN K6 [get_ports SFP0_MGT_REFCLK_C_P]
# set_property PACKAGE_PIN K5 [get_ports SFP0_MGT_REFCLK_C_N]
set_property PACKAGE_PIN H6 [get_ports SFP0_MGT_REFCLK_C_P]
set_property PACKAGE_PIN H5 [get_ports SFP0_MGT_REFCLK_C_N]
# set_property PACKAGE_PIN B6 [get_ports FPGA_SFP0_TX_P]
# set_property PACKAGE_PIN B5 [get_ports FPGA_SFP0_TX_N]
# set_property PACKAGE_PIN A4 [get_ports FPGA_SFP0_RX_P]
# set_property PACKAGE_PIN A3 [get_ports FPGA_SFP0_RX_N]

# set_property PACKAGE_PIN P6 [get_ports SFP_MGT_REFCLK_C_P]
# set_property PACKAGE_PIN P5 [get_ports SFP_MGT_REFCLK_C_N]
set_property PACKAGE_PIN M6 [get_ports SFP_MGT_REFCLK_C_P]
set_property PACKAGE_PIN M5 [get_ports SFP_MGT_REFCLK_C_N]
set_property PACKAGE_PIN N4 [get_ports FPGA_SFP1_TX_P]
set_property PACKAGE_PIN N3 [get_ports FPGA_SFP1_TX_N]
set_property PACKAGE_PIN M2 [get_ports FPGA_SFP1_RX_P]
set_property PACKAGE_PIN M1 [get_ports FPGA_SFP1_RX_N]
#set_property PACKAGE_PIN L4 [get_ports FPGA_SFP2_TX_P]
#set_property PACKAGE_PIN L3 [get_ports FPGA_SFP2_TX_N]
#set_property PACKAGE_PIN K2 [get_ports FPGA_SFP2_RX_P]
#set_property PACKAGE_PIN K1 [get_ports FPGA_SFP2_RX_N]
set_property PACKAGE_PIN J4 [get_ports FPGA_SFP3_TX_P]
set_property PACKAGE_PIN J3 [get_ports FPGA_SFP3_TX_N]
set_property PACKAGE_PIN H2 [get_ports FPGA_SFP3_RX_P]
set_property PACKAGE_PIN H1 [get_ports FPGA_SFP3_RX_N]
set_property PACKAGE_PIN G4 [get_ports FPGA_SFP4_TX_P]
set_property PACKAGE_PIN G3 [get_ports FPGA_SFP4_TX_N]
set_property PACKAGE_PIN F2 [get_ports FPGA_SFP4_RX_P]
set_property PACKAGE_PIN F1 [get_ports FPGA_SFP4_RX_N]

set_property -dict {PACKAGE_PIN AH12 IOSTANDARD LVCMOS33} [get_ports FPGA_SFP0_LOS_LS       ]
set_property -dict {PACKAGE_PIN AG12 IOSTANDARD LVCMOS33} [get_ports FPGA_SFP0_MOD_DETECT_LS]
set_property -dict {PACKAGE_PIN AE11 IOSTANDARD LVCMOS33} [get_ports FPGA_SFP0_TX_DISABLE_LS]
set_property -dict {PACKAGE_PIN AD11 IOSTANDARD LVCMOS33} [get_ports FPGA_SFP0_TX_FAULT_LS  ]
set_property -dict {PACKAGE_PIN AN11 IOSTANDARD LVCMOS33} [get_ports FPGA_SFP1_LOS_LS       ]
set_property -dict {PACKAGE_PIN AN13 IOSTANDARD LVCMOS33} [get_ports FPGA_SFP1_MOD_DETECT_LS]
set_property -dict {PACKAGE_PIN AP10 IOSTANDARD LVCMOS33} [get_ports FPGA_SFP1_TX_DISABLE_LS]
set_property -dict {PACKAGE_PIN AP11 IOSTANDARD LVCMOS33} [get_ports FPGA_SFP1_TX_FAULT_LS  ]
set_property -dict {PACKAGE_PIN AF13 IOSTANDARD LVCMOS33} [get_ports FPGA_SFP2_LOS_LS       ]
set_property -dict {PACKAGE_PIN AK12 IOSTANDARD LVCMOS33} [get_ports FPGA_SFP2_MOD_DETECT_LS]
set_property -dict {PACKAGE_PIN AN12 IOSTANDARD LVCMOS33} [get_ports FPGA_SFP2_TX_DISABLE_LS]
set_property -dict {PACKAGE_PIN AM12 IOSTANDARD LVCMOS33} [get_ports FPGA_SFP2_TX_FAULT_LS  ]
set_property -dict {PACKAGE_PIN AE13 IOSTANDARD LVCMOS33} [get_ports FPGA_SFP3_LOS_LS       ]
set_property -dict {PACKAGE_PIN AL12 IOSTANDARD LVCMOS33} [get_ports FPGA_SFP3_MOD_DETECT_LS]
set_property -dict {PACKAGE_PIN AM11 IOSTANDARD LVCMOS33} [get_ports FPGA_SFP3_TX_DISABLE_LS]
set_property -dict {PACKAGE_PIN AP13 IOSTANDARD LVCMOS33} [get_ports FPGA_SFP3_TX_FAULT_LS  ]
set_property -dict {PACKAGE_PIN AF12 IOSTANDARD LVCMOS33} [get_ports FPGA_SFP4_LOS_LS       ]
set_property -dict {PACKAGE_PIN AE12 IOSTANDARD LVCMOS33} [get_ports FPGA_SFP4_MOD_DETECT_LS]
set_property -dict {PACKAGE_PIN AJ13 IOSTANDARD LVCMOS33} [get_ports FPGA_SFP4_TX_DISABLE_LS]
set_property -dict {PACKAGE_PIN AH13 IOSTANDARD LVCMOS33} [get_ports FPGA_SFP4_TX_FAULT_LS  ]

## HMC7044
set_property -dict {PACKAGE_PIN AM9  IOSTANDARD LVCMOS33} [get_ports HMC7044_1_RESET_LS]
set_property -dict {PACKAGE_PIN AP8  IOSTANDARD LVCMOS33} [get_ports HMC7044_1_SLEN_LS ]
set_property -dict {PACKAGE_PIN AN8  IOSTANDARD LVCMOS33} [get_ports HMC7044_SYNC      ]
set_property -dict {PACKAGE_PIN AJ8  IOSTANDARD LVCMOS33} [get_ports HMC7044_1_SDATA_LS]
set_property -dict {PACKAGE_PIN AJ9  IOSTANDARD LVCMOS33} [get_ports HMC7044_1_SCLK_LS ]
set_property -dict {PACKAGE_PIN AL8  IOSTANDARD LVCMOS33} [get_ports HMC7044_1_GPIO2_LS]
set_property -dict {PACKAGE_PIN AK8  IOSTANDARD LVCMOS33} [get_ports HMC7044_1_GPIO1_LS]

## EEPROM
set_property -dict {PACKAGE_PIN G27  IOSTANDARD LVCMOS18} [get_ports EEPROM_CS_B]
set_property -dict {PACKAGE_PIN G26  IOSTANDARD LVCMOS18} [get_ports EEPROM_SI  ]
set_property -dict {PACKAGE_PIN G25  IOSTANDARD LVCMOS18} [get_ports EEPROM_SO  ]
set_property -dict {PACKAGE_PIN K27  IOSTANDARD LVCMOS18} [get_ports EEPROM_SCK ]
set_property -dict {PACKAGE_PIN K26  IOSTANDARD LVCMOS18} [get_ports EEPROM_WP_B]

## TMP75
set_property -dict {PACKAGE_PIN J25  IOSTANDARD LVCMOS18} [get_ports TMP75_IIC_SCL]
set_property -dict {PACKAGE_PIN J24  IOSTANDARD LVCMOS18} [get_ports TMP75_IIC_SDA]
set_property -dict {PACKAGE_PIN J26  IOSTANDARD LVCMOS18} [get_ports TMP75_ALERT  ]

## AD5592
set_property -dict {PACKAGE_PIN AC24 IOSTANDARD LVCMOS18} [get_ports AD5592_1_SPI_CLK ]
set_property -dict {PACKAGE_PIN AB24 IOSTANDARD LVCMOS18} [get_ports AD5592_1_SPI_CS_B]
set_property -dict {PACKAGE_PIN AC27 IOSTANDARD LVCMOS18} [get_ports AD5592_1_SPI_MISO]
set_property -dict {PACKAGE_PIN AC26 IOSTANDARD LVCMOS18} [get_ports AD5592_1_SPI_MOSI]

## AD5674
set_property -dict {PACKAGE_PIN AG10 IOSTANDARD LVCMOS33} [get_ports AD5674_1_SPI_CLK  ]
set_property -dict {PACKAGE_PIN AF10 IOSTANDARD LVCMOS33} [get_ports AD5674_1_SPI_CS   ]
set_property -dict {PACKAGE_PIN AG9  IOSTANDARD LVCMOS33} [get_ports AD5674_1_SPI_SDO  ]
set_property -dict {PACKAGE_PIN AF9  IOSTANDARD LVCMOS33} [get_ports AD5674_1_SPI_SDI  ]
set_property -dict {PACKAGE_PIN AF8  IOSTANDARD LVCMOS33} [get_ports AD5674_1_SPI_RESET]
set_property -dict {PACKAGE_PIN AE8  IOSTANDARD LVCMOS33} [get_ports AD5674_1_SPI_LDAC ]
set_property -dict {PACKAGE_PIN AE10 IOSTANDARD LVCMOS33} [get_ports AD5674_2_SPI_CLK  ]
set_property -dict {PACKAGE_PIN AD10 IOSTANDARD LVCMOS33} [get_ports AD5674_2_SPI_CS   ]
set_property -dict {PACKAGE_PIN AD8  IOSTANDARD LVCMOS33} [get_ports AD5674_2_SPI_SDO  ]
set_property -dict {PACKAGE_PIN AD9  IOSTANDARD LVCMOS33} [get_ports AD5674_2_SPI_SDI  ]
set_property -dict {PACKAGE_PIN AH8  IOSTANDARD LVCMOS33} [get_ports AD5674_2_SPI_RESET]
set_property -dict {PACKAGE_PIN AH9  IOSTANDARD LVCMOS33} [get_ports AD5674_2_SPI_LDAC ]


## MAX5216
set_property -dict {PACKAGE_PIN AP9  IOSTANDARD LVCMOS33} [get_ports MAX5216_CS ]
set_property -dict {PACKAGE_PIN AN9  IOSTANDARD LVCMOS33} [get_ports MAX5216_CLR]
set_property -dict {PACKAGE_PIN AL9  IOSTANDARD LVCMOS33} [get_ports MAX5216_DIN]
set_property -dict {PACKAGE_PIN AK10 IOSTANDARD LVCMOS33} [get_ports MAX5216_CLK]

## AD7680
set_property -dict {PACKAGE_PIN AJ10 IOSTANDARD LVCMOS33} [get_ports AD7680_SCLK]
set_property -dict {PACKAGE_PIN AM10 IOSTANDARD LVCMOS33} [get_ports AD7680_CS  ]
set_property -dict {PACKAGE_PIN AL10 IOSTANDARD LVCMOS33} [get_ports AD7680_DATA]


# CTRL LVDS
# MCLK <====== MOSI
# MOSI <====== CSN
# SCLK <====== CLK
# MISO <====== RF_FPS_TRIGGER
set_property -dict {PACKAGE_PIN Y25 IOSTANDARD LVDS    } [get_ports TIMING_SPI_MCLK_N   ]
set_property -dict {PACKAGE_PIN W25 IOSTANDARD LVDS    } [get_ports TIMING_SPI_MCLK_P   ]
set_property -dict {PACKAGE_PIN U22 IOSTANDARD LVDS    } [get_ports TIMING_SPI_MOSI_N   ]
set_property -dict {PACKAGE_PIN U21 IOSTANDARD LVDS    } [get_ports TIMING_SPI_MOSI_P   ]
set_property -dict {PACKAGE_PIN W24 IOSTANDARD LVDS    } [get_ports TIMING_SPI_SCLK_N   ]
set_property -dict {PACKAGE_PIN W23 IOSTANDARD LVDS    } [get_ports TIMING_SPI_SCLK_P   ]
set_property -dict {PACKAGE_PIN U25 IOSTANDARD LVDS    } [get_ports TIMING_SPI_MISO_N   ]
set_property -dict {PACKAGE_PIN U24 IOSTANDARD LVDS    } [get_ports TIMING_SPI_MISO_P   ]

# ENCODE MCLK <====== RF_SYNC
# ENCODE MOSI <====== MISO
set_property -dict {PACKAGE_PIN U27 IOSTANDARD LVDS   } [get_ports ENCODE_MCLK_N       ]
set_property -dict {PACKAGE_PIN U26 IOSTANDARD LVDS   } [get_ports ENCODE_MCLK_P       ]
set_property -dict {PACKAGE_PIN V23 IOSTANDARD LVDS   } [get_ports ENCODE_MOSI_N       ]
set_property -dict {PACKAGE_PIN V22 IOSTANDARD LVDS   } [get_ports ENCODE_MOSI_P       ]


set_property DIFF_TERM true  [get_ports TIMING_SPI_MCLK_N   ]
set_property DIFF_TERM true  [get_ports TIMING_SPI_MCLK_P   ]
set_property DIFF_TERM true  [get_ports TIMING_SPI_MOSI_N   ]
set_property DIFF_TERM true  [get_ports TIMING_SPI_MOSI_P   ]
set_property DIFF_TERM true  [get_ports ENCODE_MCLK_N       ]
set_property DIFF_TERM true  [get_ports ENCODE_MCLK_P       ]
set_property DIFF_TERM true  [get_ports ENCODE_MOSI_N       ]
set_property DIFF_TERM true  [get_ports ENCODE_MOSI_P       ]


## SFPGA
set_property -dict {PACKAGE_PIN AB22 IOSTANDARD LVCMOS18} [get_ports FPGA_TO_SFPGA_RESERVE1]
set_property -dict {PACKAGE_PIN AA22 IOSTANDARD LVCMOS18} [get_ports FPGA_TO_SFPGA_RESERVE0]
set_property -dict {PACKAGE_PIN AC23 IOSTANDARD LVCMOS18} [get_ports FPGA_TO_SFPGA_RESERVE3]
set_property -dict {PACKAGE_PIN AC22 IOSTANDARD LVCMOS18} [get_ports FPGA_TO_SFPGA_RESERVE2]
set_property -dict {PACKAGE_PIN AB20 IOSTANDARD LVCMOS18} [get_ports FPGA_TO_SFPGA_RESERVE5]
set_property -dict {PACKAGE_PIN AA20 IOSTANDARD LVCMOS18} [get_ports FPGA_TO_SFPGA_RESERVE4]
set_property -dict {PACKAGE_PIN AC21 IOSTANDARD LVCMOS18} [get_ports FPGA_TO_SFPGA_RESERVE7]
set_property -dict {PACKAGE_PIN AB21 IOSTANDARD LVCMOS18} [get_ports FPGA_TO_SFPGA_RESERVE6]
set_property -dict {PACKAGE_PIN AA23 IOSTANDARD LVCMOS18} [get_ports FPGA_TO_SFPGA_RESERVE9]
set_property -dict {PACKAGE_PIN Y23  IOSTANDARD LVCMOS18} [get_ports FPGA_TO_SFPGA_RESERVE8]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets FPGA_TO_SFPGA_RESERVE0_IBUF_inst/O]

# OTHERS
set_property -dict {PACKAGE_PIN J23   IOSTANDARD LVCMOS18} [get_ports VCC12V_FAN_EN]
set_property -dict {PACKAGE_PIN AJ11  IOSTANDARD LVCMOS33} [get_ports HV_EN_LS]


set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN Pullup [current_design]




set_property -dict {PACKAGE_PIN H24 IOSTANDARD LVCMOS18} [get_ports POW_GOOD[0] ]
set_property -dict {PACKAGE_PIN L27 IOSTANDARD LVCMOS18} [get_ports POW_GOOD[1] ]
set_property -dict {PACKAGE_PIN M27 IOSTANDARD LVCMOS18} [get_ports POW_GOOD[2] ]
set_property -dict {PACKAGE_PIN L24 IOSTANDARD LVCMOS18} [get_ports POW_GOOD[3] ]
set_property -dict {PACKAGE_PIN L23 IOSTANDARD LVCMOS18} [get_ports POW_GOOD[4] ]
set_property -dict {PACKAGE_PIN K25 IOSTANDARD LVCMOS18} [get_ports POW_GOOD[5] ]
set_property -dict {PACKAGE_PIN L25 IOSTANDARD LVCMOS18} [get_ports POW_GOOD[6] ]
set_property -dict {PACKAGE_PIN K23 IOSTANDARD LVCMOS18} [get_ports POW_GOOD[7] ]
set_property -dict {PACKAGE_PIN L22 IOSTANDARD LVCMOS18} [get_ports POW_GOOD[8] ]
set_property -dict {PACKAGE_PIN M26 IOSTANDARD LVCMOS18} [get_ports POW_GOOD[9] ]
set_property -dict {PACKAGE_PIN M25 IOSTANDARD LVCMOS18} [get_ports POW_GOOD[10] ]
set_property -dict {PACKAGE_PIN M24 IOSTANDARD LVCMOS18} [get_ports POW_GOOD[11] ]
set_property -dict {PACKAGE_PIN N24 IOSTANDARD LVCMOS18} [get_ports POW_GOOD[12] ]



























