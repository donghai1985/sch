create_clock -period 8.000 -name fmc_ref_clk_p [get_ports fmc_ref_clk_p]
set_input_jitter fmc_ref_clk_p 0.050

########################### 12.5Gbps Constraints ###########################
set_false_path -from [get_clocks -of_objects [get_pins {cxp_host_i/ext_phy_for_cxp_0/inst/gtwizard_ultrascale_0_wrapper_inst/gtwizard_ultrascale_0_inst/inst/gen_gtwizard_gthe3_top.gtwizard_ultrascale_0_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[24].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[3].GTHE3_CHANNEL_PRIM_INST/RXOUTCLK}]] -to [get_clocks -of_objects [get_pins cxp_host_i/clk_wiz_0/inst/mmcme3_adv_inst/CLKOUT0]]
set_false_path -from [get_clocks -of_objects [get_pins {cxp_host_i/ext_phy_for_cxp_0/inst/gtwizard_ultrascale_0_wrapper_inst/gtwizard_ultrascale_0_inst/inst/gen_gtwizard_gthe3_top.gtwizard_ultrascale_0_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[24].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[3].GTHE3_CHANNEL_PRIM_INST/RXOUTCLK}]] -to [get_clocks -of_objects [get_pins cxp_host_i/clk_wiz_0/inst/mmcme3_adv_inst/CLKOUT1]]
set_false_path -from [get_clocks -of_objects [get_pins {cxp_host_i/ext_phy_for_cxp_0/inst/gtwizard_ultrascale_0_wrapper_inst/gtwizard_ultrascale_0_inst/inst/gen_gtwizard_gthe3_top.gtwizard_ultrascale_0_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[24].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[3].GTHE3_CHANNEL_PRIM_INST/RXOUTCLK}]] -to [get_clocks -of_objects [get_pins {cxp_host_i/ext_phy_for_cxp_0/inst/gtwizard_ultrascale_0_wrapper_inst/gtwizard_ultrascale_0_inst/inst/gen_gtwizard_gthe3_top.gtwizard_ultrascale_0_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[24].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[1].GTHE3_CHANNEL_PRIM_INST/RXOUTCLK}]]

set_false_path -from [get_clocks -of_objects [get_pins cxp_host_i/clk_wiz_0/inst/mmcme3_adv_inst/CLKOUT0]] -to [get_clocks -of_objects [get_pins cxp_host_i/clk_wiz_0/inst/mmcme3_adv_inst/CLKOUT1]]
set_false_path -from [get_clocks -of_objects [get_pins cxp_host_i/clk_wiz_0/inst/mmcme3_adv_inst/CLKOUT0]] -to [get_clocks -of_objects [get_pins {cxp_host_i/ext_phy_for_cxp_0/inst/gtwizard_ultrascale_0_wrapper_inst/gtwizard_ultrascale_0_inst/inst/gen_gtwizard_gthe3_top.gtwizard_ultrascale_0_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[24].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[1].GTHE3_CHANNEL_PRIM_INST/RXOUTCLK}]]

set_false_path -from [get_clocks -of_objects [get_pins cxp_host_i/clk_wiz_0/inst/mmcme3_adv_inst/CLKOUT1]] -to [get_clocks -of_objects [get_pins {cxp_host_i/ext_phy_for_cxp_0/inst/gtwizard_ultrascale_0_wrapper_inst/gtwizard_ultrascale_0_inst/inst/gen_gtwizard_gthe3_top.gtwizard_ultrascale_0_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[24].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[3].GTHE3_CHANNEL_PRIM_INST/RXOUTCLK}]]
set_false_path -from [get_clocks -of_objects [get_pins cxp_host_i/clk_wiz_0/inst/mmcme3_adv_inst/CLKOUT1]] -to [get_clocks -of_objects [get_pins cxp_host_i/clk_wiz_0/inst/mmcme3_adv_inst/CLKOUT0]]
set_false_path -from [get_clocks -of_objects [get_pins cxp_host_i/clk_wiz_0/inst/mmcme3_adv_inst/CLKOUT1]] -to [get_clocks -of_objects [get_pins {cxp_host_i/ext_phy_for_cxp_0/inst/gtwizard_ultrascale_0_wrapper_inst/gtwizard_ultrascale_0_inst/inst/gen_gtwizard_gthe3_top.gtwizard_ultrascale_0_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[24].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[0].GTHE3_CHANNEL_PRIM_INST/RXOUTCLK}]]
set_false_path -from [get_clocks -of_objects [get_pins cxp_host_i/clk_wiz_0/inst/mmcme3_adv_inst/CLKOUT1]] -to [get_clocks -of_objects [get_pins {cxp_host_i/ext_phy_for_cxp_0/inst/gtwizard_ultrascale_0_wrapper_inst/gtwizard_ultrascale_0_inst/inst/gen_gtwizard_gthe3_top.gtwizard_ultrascale_0_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[24].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[1].GTHE3_CHANNEL_PRIM_INST/RXOUTCLK}]]
set_false_path -from [get_clocks -of_objects [get_pins cxp_host_i/clk_wiz_0/inst/mmcme3_adv_inst/CLKOUT1]] -to [get_clocks -of_objects [get_pins {cxp_host_i/ext_phy_for_cxp_0/inst/gtwizard_ultrascale_0_wrapper_inst/gtwizard_ultrascale_0_inst/inst/gen_gtwizard_gthe3_top.gtwizard_ultrascale_0_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[24].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[2].GTHE3_CHANNEL_PRIM_INST/RXOUTCLK}]]

set_false_path -from [get_clocks -of_objects [get_pins cxp_host_i/clk_wiz_0/inst/mmcme3_adv_inst/CLKOUT0]] -to [get_clocks -of_objects [get_pins {cxp_host_i/ext_phy_for_cxp_0/inst/gtwizard_ultrascale_0_wrapper_inst/gtwizard_ultrascale_0_inst/inst/gen_gtwizard_gthe3_top.gtwizard_ultrascale_0_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[24].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[3].GTHE3_CHANNEL_PRIM_INST/RXOUTCLK}]]
set_false_path -from [get_clocks -of_objects [get_pins cxp_host_i/clk_wiz_0/inst/mmcme3_adv_inst/CLKOUT0]] -to [get_clocks -of_objects [get_pins cxp_host_i/clk_wiz_0/inst/mmcme3_adv_inst/CLKOUT1]]
set_false_path -from [get_clocks -of_objects [get_pins cxp_host_i/clk_wiz_0/inst/mmcme3_adv_inst/CLKOUT0]] -to [get_clocks -of_objects [get_pins {cxp_host_i/ext_phy_for_cxp_0/inst/gtwizard_ultrascale_0_wrapper_inst/gtwizard_ultrascale_0_inst/inst/gen_gtwizard_gthe3_top.gtwizard_ultrascale_0_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[24].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[0].GTHE3_CHANNEL_PRIM_INST/RXOUTCLK}]]
set_false_path -from [get_clocks -of_objects [get_pins cxp_host_i/clk_wiz_0/inst/mmcme3_adv_inst/CLKOUT0]] -to [get_clocks -of_objects [get_pins {cxp_host_i/ext_phy_for_cxp_0/inst/gtwizard_ultrascale_0_wrapper_inst/gtwizard_ultrascale_0_inst/inst/gen_gtwizard_gthe3_top.gtwizard_ultrascale_0_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[24].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[1].GTHE3_CHANNEL_PRIM_INST/RXOUTCLK}]]
set_false_path -from [get_clocks -of_objects [get_pins cxp_host_i/clk_wiz_0/inst/mmcme3_adv_inst/CLKOUT0]] -to [get_clocks -of_objects [get_pins {cxp_host_i/ext_phy_for_cxp_0/inst/gtwizard_ultrascale_0_wrapper_inst/gtwizard_ultrascale_0_inst/inst/gen_gtwizard_gthe3_top.gtwizard_ultrascale_0_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[24].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[2].GTHE3_CHANNEL_PRIM_INST/RXOUTCLK}]]

set_false_path -from [get_clocks -of_objects [get_pins {cxp_host_i/ext_phy_for_cxp_0/inst/gtwizard_ultrascale_0_wrapper_inst/gtwizard_ultrascale_0_inst/inst/gen_gtwizard_gthe3_top.gtwizard_ultrascale_0_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[24].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[0].GTHE3_CHANNEL_PRIM_INST/RXOUTCLK}]] -to [get_clocks -of_objects [get_pins cxp_host_i/clk_wiz_0/inst/mmcme3_adv_inst/CLKOUT1]]

set_false_path -from [get_clocks -of_objects [get_pins {cxp_host_i/ext_phy_for_cxp_0/inst/gtwizard_ultrascale_0_wrapper_inst/gtwizard_ultrascale_0_inst/inst/gen_gtwizard_gthe3_top.gtwizard_ultrascale_0_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[24].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[1].GTHE3_CHANNEL_PRIM_INST/RXOUTCLK}]] -to [get_clocks -of_objects [get_pins cxp_host_i/clk_wiz_0/inst/mmcme3_adv_inst/CLKOUT0]]
set_false_path -from [get_clocks -of_objects [get_pins {cxp_host_i/ext_phy_for_cxp_0/inst/gtwizard_ultrascale_0_wrapper_inst/gtwizard_ultrascale_0_inst/inst/gen_gtwizard_gthe3_top.gtwizard_ultrascale_0_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[24].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[1].GTHE3_CHANNEL_PRIM_INST/RXOUTCLK}]] -to [get_clocks -of_objects [get_pins cxp_host_i/clk_wiz_0/inst/mmcme3_adv_inst/CLKOUT1]]
set_false_path -from [get_clocks -of_objects [get_pins {cxp_host_i/ext_phy_for_cxp_0/inst/gtwizard_ultrascale_0_wrapper_inst/gtwizard_ultrascale_0_inst/inst/gen_gtwizard_gthe3_top.gtwizard_ultrascale_0_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[24].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[1].GTHE3_CHANNEL_PRIM_INST/RXOUTCLK}]] -to [get_clocks -of_objects [get_pins cxp_host_i/clk_wiz_0/inst/mmcme3_adv_inst/CLKOUT0]]

set_false_path -from [get_clocks -of_objects [get_pins {cxp_host_i/ext_phy_for_cxp_0/inst/gtwizard_ultrascale_0_wrapper_inst/gtwizard_ultrascale_0_inst/inst/gen_gtwizard_gthe3_top.gtwizard_ultrascale_0_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[24].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[2].GTHE3_CHANNEL_PRIM_INST/RXOUTCLK}]] -to [get_clocks -of_objects [get_pins cxp_host_i/clk_wiz_0/inst/mmcme3_adv_inst/CLKOUT0]]
set_false_path -from [get_clocks -of_objects [get_pins {cxp_host_i/ext_phy_for_cxp_0/inst/gtwizard_ultrascale_0_wrapper_inst/gtwizard_ultrascale_0_inst/inst/gen_gtwizard_gthe3_top.gtwizard_ultrascale_0_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[24].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[2].GTHE3_CHANNEL_PRIM_INST/RXOUTCLK}]] -to [get_clocks -of_objects [get_pins cxp_host_i/clk_wiz_0/inst/mmcme3_adv_inst/CLKOUT1]]
set_false_path -from [get_clocks -of_objects [get_pins {cxp_host_i/ext_phy_for_cxp_0/inst/gtwizard_ultrascale_0_wrapper_inst/gtwizard_ultrascale_0_inst/inst/gen_gtwizard_gthe3_top.gtwizard_ultrascale_0_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[24].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[2].GTHE3_CHANNEL_PRIM_INST/RXOUTCLK}]] -to [get_clocks -of_objects [get_pins cxp_host_i/clk_wiz_0/inst/mmcme3_adv_inst/CLKOUT0]]

set_false_path -from [get_clocks -of_objects [get_pins cxp_host_i/clk_wiz_0/inst/mmcme3_adv_inst/CLKOUT0]] -to [get_clocks -of_objects [get_pins {cxp_host_i/ext_phy_for_cxp_0/inst/gtwizard_ultrascale_0_wrapper_inst/gtwizard_ultrascale_0_inst/inst/gen_gtwizard_gthe3_top.gtwizard_ultrascale_0_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[24].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[0].GTHE3_CHANNEL_PRIM_INST/RXOUTCLK}]]

set_false_path -from [get_clocks -of_objects [get_pins {cxp_host_i/ext_phy_for_cxp_0/inst/gtwizard_ultrascale_0_wrapper_inst/gtwizard_ultrascale_0_inst/inst/gen_gtwizard_gthe3_top.gtwizard_ultrascale_0_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[24].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[0].GTHE3_CHANNEL_PRIM_INST/RXOUTCLK}]] -to [get_clocks -of_objects [get_pins cxp_host_i/clk_wiz_0/inst/mmcme3_adv_inst/CLKOUT0]]
set_false_path -from [get_clocks -of_objects [get_pins {cxp_host_i/ext_phy_for_cxp_0/inst/gtwizard_ultrascale_0_wrapper_inst/gtwizard_ultrascale_0_inst/inst/gen_gtwizard_gthe3_top.gtwizard_ultrascale_0_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[24].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[0].GTHE3_CHANNEL_PRIM_INST/RXOUTCLK}]] -to [get_clocks -of_objects [get_pins cxp_host_i/clk_wiz_0/inst/mmcme3_adv_inst/CLKOUT0]]
set_false_path -from [get_clocks -of_objects [get_pins {cxp_host_i/ext_phy_for_cxp_0/inst/gtwizard_ultrascale_0_wrapper_inst/gtwizard_ultrascale_0_inst/inst/gen_gtwizard_gthe3_top.gtwizard_ultrascale_0_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[24].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[3].GTHE3_CHANNEL_PRIM_INST/RXOUTCLK}]] -to [get_clocks -of_objects [get_pins cxp_host_i/clk_wiz_0/inst/mmcme3_adv_inst/CLKOUT0]]


