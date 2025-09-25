


#set_false_path -through [get_pins Data_proc_top_226/exdes_top_i_1/O]
#set_false_path -through [get_pins Data_proc_top_226/exdes_top_i_2/O]



####################################################################################
# Constraints from file : 'ddr4_pin.xdc'
####################################################################################



####################################################################################
# Constraints from file : 'ddr4_pin.xdc'
####################################################################################

current_instance DDR4_proc/u_ddr4_test/inst
set_property LOC MMCM_X1Y3 [get_cells -hier -filter {NAME =~ */u_ddr4_infrastructure/gen_mmcme*.u_mmcme_adv_inst}]
set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_pins -hier -filter {NAME =~ */u_ddr4_infrastructure/gen_mmcme*.u_mmcme_adv_inst/CLKIN1}]

create_clock -period 10.000 [get_ports sysclk_p]
set_false_path -through [get_nets rst]
set_false_path -through [get_nets RDMA_proc_top_*/rst_usr]
set_false_path -through [get_nets RDMA_proc_top_*/DDR4_proc/u_ddr4_test/c0_init_calib_complete]
set_false_path -through [get_nets RDMA_proc_top_*/Data_proc_top_226/stat_rx_pause_req*]


set_false_path -from [get_clocks -of_objects [get_pins clk_wiz_0/inst/mmcme4_adv_inst/CLKOUT1]] -to [get_clocks -of_objects [get_pins clk_wiz_0/inst/mmcme4_adv_inst/CLKOUT0]]
#set_false_path -from [get_clocks -of_objects [get_pins RDMA_proc_top_0/DDR4_proc/u_ddr4_test/inst/u_ddr4_infrastructure/gen_mmcme4.u_mmcme_adv_inst/CLKOUT0]] -to [get_clocks -of_objects [get_pins clk_wiz_0/inst/mmcme4_adv_inst/CLKOUT1]]
#set_false_path -from [get_clocks -of_objects [get_pins RDMA_proc_top_1/DDR4_proc/u_ddr4_test/inst/u_ddr4_infrastructure/gen_mmcme4.u_mmcme_adv_inst/CLKOUT0]] -to [get_clocks -of_objects [get_pins clk_wiz_0/inst/mmcme4_adv_inst/CLKOUT1]]
#set_false_path -from [get_clocks -of_objects [get_pins clk_wiz_0/inst/mmcme4_adv_inst/CLKOUT1]] -to [get_clocks -of_objects [get_pins RDMA_proc_top_0/DDR4_proc/u_ddr4_test/inst/u_ddr4_infrastructure/gen_mmcme4.u_mmcme_adv_inst/CLKOUT0]]
#set_false_path -from [get_clocks -of_objects [get_pins clk_wiz_0/inst/mmcme4_adv_inst/CLKOUT1]] -to [get_clocks -of_objects [get_pins RDMA_proc_top_1/DDR4_proc/u_ddr4_test/inst/u_ddr4_infrastructure/gen_mmcme4.u_mmcme_adv_inst/CLKOUT0]]
set_false_path -from [get_clocks -of_objects [get_pins clk_wiz_0/inst/mmcme4_adv_inst/CLKOUT2]] -to [get_clocks -of_objects [get_pins RDMA_proc_top_0/DDR4_proc/u_ddr4_test/inst/u_ddr4_infrastructure/gen_mmcme4.u_mmcme_adv_inst/CLKOUT0]]
set_false_path -from [get_clocks -of_objects [get_pins clk_wiz_0/inst/mmcme4_adv_inst/CLKOUT2]] -to [get_clocks -of_objects [get_pins RDMA_proc_top_1/DDR4_proc/u_ddr4_test/inst/u_ddr4_infrastructure/gen_mmcme4.u_mmcme_adv_inst/CLKOUT0]]
#set_false_path -from [get_clocks -of_objects [get_pins clk_wiz_0/inst/mmcme4_adv_inst/CLKOUT1]] -to [get_clocks -of_objects [get_pins clk_wiz_0/inst/mmcme4_adv_inst/CLKOUT2]]
#set_false_path -from [get_clocks -of_objects [get_pins clk_wiz_0/inst/mmcme4_adv_inst/CLKOUT2]] -to [get_clocks -of_objects [get_pins clk_wiz_0/inst/mmcme4_adv_inst/CLKOUT1]]

####################################################################################
# Constraints from file : 'ddr4_pin.xdc'
####################################################################################

create_pblock pblock_TDI_data_proc_topTDI_data_proc_top
create_pblock pblock_TDI_data_proc_top
add_cells_to_pblock [get_pblocks pblock_TDI_data_proc_top] [get_cells -quiet [list TDI_data_proc_top]]
resize_pblock [get_pblocks pblock_TDI_data_proc_top] -add {SLICE_X112Y60:SLICE_X139Y119}
resize_pblock [get_pblocks pblock_TDI_data_proc_top] -add {DSP48E2_X14Y24:DSP48E2_X15Y47}
resize_pblock [get_pblocks pblock_TDI_data_proc_top] -add {RAMB18_X8Y24:RAMB18_X9Y47}
resize_pblock [get_pblocks pblock_TDI_data_proc_top] -add {RAMB36_X8Y12:RAMB36_X9Y23}
resize_pblock [get_pblocks pblock_TDI_data_proc_top] -add {URAM288_X3Y16:URAM288_X3Y31}


