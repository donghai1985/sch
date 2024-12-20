create_clock -period 10.000 -name FPGA_MASTER_CLOCK_P [get_ports FPGA_MASTER_CLOCK_P]
create_clock -period  6.400 -name SFP0_MGT_REFCLK_C_P [get_ports SFP0_MGT_REFCLK_C_P]
create_clock -period  6.400 -name SFP_MGT_REFCLK_C_P  [get_ports SFP_MGT_REFCLK_C_P]
create_clock -period  5.000 -name ddr_clk_p           [get_ports ddr_clk_p]

create_clock -period  7.8   -name ADC_1_4_DCO   [get_ports ADC_1_4_DCO_P  ]
create_clock -period  7.8   -name ADC_5_8_DCO   [get_ports ADC_5_8_DCO_P  ]
create_clock -period  7.8   -name ADC_9_12_DCO  [get_ports ADC_9_12_DCO_P ]
create_clock -period  7.8   -name ADC_13_16_DCO [get_ports ADC_13_16_DCO_P]
create_clock -period  7.8   -name ADC_17_20_DCO [get_ports ADC_17_20_DCO_P]
create_clock -period  7.8   -name ADC_21_24_DCO [get_ports ADC_21_24_DCO_P]
create_clock -period  7.8   -name ADC_25_28_DCO [get_ports ADC_25_28_DCO_P]
create_clock -period  7.8   -name ADC_29_32_DCO [get_ports ADC_29_32_DCO_P]


# set_false_path -from [get_clocks -of_objects [get_pins pll_inst1/inst/mmcme3_adv_inst/CLKOUT0]] -to [get_clocks -of_objects [get_pins pll_inst/inst/mmcme3_adv_inst/CLKOUT2]]
# set_false_path -from [get_clocks -of_objects [get_pins pll_inst/inst/mmcme3_adv_inst/CLKOUT2]] -to [get_clocks -of_objects [get_pins pll_inst/inst/mmcme3_adv_inst/CLKOUT0]]
# set_false_path -from [get_clocks -of_objects [get_pins pll_inst/inst/mmcme3_adv_inst/CLKOUT2]] -to [get_clocks -of_objects [get_pins pll_inst1/inst/mmcme3_adv_inst/CLKOUT0]]
# set_false_path -from [get_clocks -of_objects [get_pins pll_inst/inst/mmcme3_adv_inst/CLKOUT0]] -to [get_clocks -of_objects [get_pins pll_inst/inst/mmcme3_adv_inst/CLKOUT1]]
# set_false_path -from [get_clocks -of_objects [get_pins pll_inst/inst/mmcme3_adv_inst/CLKOUT1]] -to [get_clocks -of_objects [get_pins pll_inst/inst/mmcme3_adv_inst/CLKOUT0]]
# set_false_path -from [get_clocks -of_objects [get_pins pll_inst/inst/mmcme3_adv_inst/CLKOUT0]] -to [get_clocks -of_objects [get_pins pll_inst1/inst/mmcme3_adv_inst/CLKOUT0]]
# 
# set_false_path -from [get_clocks -of_objects [get_pins pll_inst1/inst/mmcme3_adv_inst/CLKOUT0]] -to [get_clocks -of_objects [get_pins pll_inst/inst/mmcme3_adv_inst/CLKOUT3]]
# set_false_path -from [get_clocks -of_objects [get_pins pll_inst/inst/mmcme3_adv_inst/CLKOUT3]] -to [get_clocks -of_objects [get_pins pll_inst1/inst/mmcme3_adv_inst/CLKOUT0]]
# set_false_path -from [get_clocks -of_objects [get_pins pll_inst1/inst/mmcme3_adv_inst/CLKOUT0]] -to [get_clocks -of_objects [get_pins pll_inst/inst/mmcme3_adv_inst/CLKOUT0]]
# set_false_path -from [get_clocks -of_objects [get_pins pll_inst/inst/mmcme3_adv_inst/CLKOUT3]] -to [get_clocks -of_objects [get_pins pll_inst/inst/mmcme3_adv_inst/CLKOUT0]]
# set_false_path -from [get_clocks -of_objects [get_pins u_aurora_inf_top/u_aurora_64b66b_20g_ip_support/clock_module_i/ultrascale_tx_userclk_1/gen_gtwiz_userclk_tx_main.bufg_gt_usrclk2_inst/O]] -to [get_clocks -of_objects [get_pins pll_inst/inst/mmcme3_adv_inst/CLKOUT0]]


set_property CLOCK_DELAY_GROUP ADC0_ISERDES  [get_nets -of_objects [get_pins {u0_ad9253_4ch_driver/u0_ad9253_driver/BUFG_inst/O      }]]
set_property CLOCK_DELAY_GROUP ADC0_ISERDES  [get_nets -of_objects [get_pins {u0_ad9253_4ch_driver/u0_ad9253_driver/BUFGCE_DIV_inst/O}]]
set_property CLOCK_DELAY_GROUP ADC1_ISERDES  [get_nets -of_objects [get_pins {u0_ad9253_4ch_driver/u1_ad9253_driver/BUFG_inst/O      }]]
set_property CLOCK_DELAY_GROUP ADC1_ISERDES  [get_nets -of_objects [get_pins {u0_ad9253_4ch_driver/u1_ad9253_driver/BUFGCE_DIV_inst/O}]]
set_property CLOCK_DELAY_GROUP ADC2_ISERDES  [get_nets -of_objects [get_pins {u0_ad9253_4ch_driver/u2_ad9253_driver/BUFG_inst/O      }]]
set_property CLOCK_DELAY_GROUP ADC2_ISERDES  [get_nets -of_objects [get_pins {u0_ad9253_4ch_driver/u2_ad9253_driver/BUFGCE_DIV_inst/O}]]
set_property CLOCK_DELAY_GROUP ADC3_ISERDES  [get_nets -of_objects [get_pins {u0_ad9253_4ch_driver/u3_ad9253_driver/BUFG_inst/O      }]]
set_property CLOCK_DELAY_GROUP ADC3_ISERDES  [get_nets -of_objects [get_pins {u0_ad9253_4ch_driver/u3_ad9253_driver/BUFGCE_DIV_inst/O}]]
set_property CLOCK_DELAY_GROUP ADC4_ISERDES  [get_nets -of_objects [get_pins {u1_ad9253_4ch_driver/u0_ad9253_driver/BUFG_inst/O      }]]
set_property CLOCK_DELAY_GROUP ADC4_ISERDES  [get_nets -of_objects [get_pins {u1_ad9253_4ch_driver/u0_ad9253_driver/BUFGCE_DIV_inst/O}]]
set_property CLOCK_DELAY_GROUP ADC5_ISERDES  [get_nets -of_objects [get_pins {u1_ad9253_4ch_driver/u1_ad9253_driver/BUFG_inst/O      }]]
set_property CLOCK_DELAY_GROUP ADC5_ISERDES  [get_nets -of_objects [get_pins {u1_ad9253_4ch_driver/u1_ad9253_driver/BUFGCE_DIV_inst/O}]]
set_property CLOCK_DELAY_GROUP ADC6_ISERDES  [get_nets -of_objects [get_pins {u1_ad9253_4ch_driver/u2_ad9253_driver/BUFG_inst/O      }]]
set_property CLOCK_DELAY_GROUP ADC6_ISERDES  [get_nets -of_objects [get_pins {u1_ad9253_4ch_driver/u2_ad9253_driver/BUFGCE_DIV_inst/O}]]
set_property CLOCK_DELAY_GROUP ADC7_ISERDES  [get_nets -of_objects [get_pins {u1_ad9253_4ch_driver/u3_ad9253_driver/BUFG_inst/O      }]]
set_property CLOCK_DELAY_GROUP ADC7_ISERDES  [get_nets -of_objects [get_pins {u1_ad9253_4ch_driver/u3_ad9253_driver/BUFGCE_DIV_inst/O}]]

set_clock_groups -name async_clk_group -asynchronous -group [get_clocks FPGA_MASTER_CLOCK_P -include_generated_clocks]\
                                                     -group [get_clocks ddr_clk_p           -include_generated_clocks]\
                                                     -group [get_clocks ADC_1_4_DCO         -include_generated_clocks]\   
                                                     -group [get_clocks ADC_5_8_DCO         -include_generated_clocks]\   
                                                     -group [get_clocks ADC_9_12_DCO        -include_generated_clocks]\   
                                                     -group [get_clocks ADC_13_16_DCO       -include_generated_clocks]\   
                                                     -group [get_clocks ADC_17_20_DCO       -include_generated_clocks]\   
                                                     -group [get_clocks ADC_21_24_DCO       -include_generated_clocks]\   
                                                     -group [get_clocks ADC_25_28_DCO       -include_generated_clocks]\   
                                                     -group [get_clocks ADC_29_32_DCO       -include_generated_clocks]\   
                                                     -group [get_clocks -of_objects [get_pins pll_inst/inst/mmcme3_adv_inst/CLKOUT0]]\
                                                     -group [get_clocks -of_objects [get_pins pll_inst/inst/mmcme3_adv_inst/CLKOUT1]]\
                                                     -group [get_clocks -of_objects [get_pins pll_inst/inst/mmcme3_adv_inst/CLKOUT2]]\
                                                     -group [get_clocks -of_objects [get_pins pll_inst/inst/mmcme3_adv_inst/CLKOUT3]]\
                                                     -group [get_clocks -of_objects [get_pins pll_inst1/inst/mmcme3_adv_inst/CLKOUT0]]\
                                                     -group [get_clocks -of_objects [get_pins pll_inst1/inst/mmcme3_adv_inst/CLKOUT1]]\   
                                                     -group [get_clocks -of_objects [get_pins u_aurora_inf_top/u_aurora_64b66b_20g_ip_support/clock_module_i/ultrascale_tx_userclk_1/gen_gtwiz_userclk_tx_main.bufg_gt_usrclk2_inst/O]]\
                                                     -group [get_clocks -of_objects [get_pins u_ddr_top/u_ddr_sch_top/ddr3_mig_inst/inst/u_ddr3_infrastructure/gen_mmcme3.u_mmcme_adv_inst/CLKOUT0]]\
                                                     -group [get_clocks -of_objects [get_pins u_ddr_top/u_ddr_sch_top/ddr3_mig_inst/inst/u_ddr3_infrastructure/gen_mmcme3.u_mmcme_adv_inst/CLKOUT6]]

                                   
                                                     
                                                     
                                                     











