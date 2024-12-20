vlib work
vlib riviera

vlib riviera/xpm
vlib riviera/gtwizard_ultrascale_v1_7_10
vlib riviera/xil_defaultlib
vlib riviera/fifo_generator_v13_2_5

vmap xpm riviera/xpm
vmap gtwizard_ultrascale_v1_7_10 riviera/gtwizard_ultrascale_v1_7_10
vmap xil_defaultlib riviera/xil_defaultlib
vmap fifo_generator_v13_2_5 riviera/fifo_generator_v13_2_5

vlog -work xpm  -sv2k12 \
"D:/Xilinx2021/Vivado/2021.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"D:/Xilinx2021/Vivado/2021.1/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
"D:/Xilinx2021/Vivado/2021.1/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93 \
"D:/Xilinx2021/Vivado/2021.1/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work gtwizard_ultrascale_v1_7_10  -v2k5 \
"../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_bit_sync.v" \
"../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gte4_drp_arb.v" \
"../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gthe4_delay_powergood.v" \
"../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gtye4_delay_powergood.v" \
"../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gthe3_cpll_cal.v" \
"../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gthe3_cal_freqcnt.v" \
"../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gthe4_cpll_cal.v" \
"../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gthe4_cpll_cal_rx.v" \
"../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gthe4_cpll_cal_tx.v" \
"../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gthe4_cal_freqcnt.v" \
"../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gtye4_cpll_cal.v" \
"../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gtye4_cpll_cal_rx.v" \
"../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gtye4_cpll_cal_tx.v" \
"../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gtye4_cal_freqcnt.v" \
"../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gtwiz_buffbypass_rx.v" \
"../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gtwiz_buffbypass_tx.v" \
"../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gtwiz_reset.v" \
"../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gtwiz_userclk_rx.v" \
"../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gtwiz_userclk_tx.v" \
"../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gtwiz_userdata_rx.v" \
"../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gtwiz_userdata_tx.v" \
"../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_reset_sync.v" \
"../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_reset_inv_sync.v" \

vlog -work xil_defaultlib  -v2k5 \
"../../../../template.gen/sources_1/ip/aurora_64b66b_20g_ip/ip_0/sim/gtwizard_ultrascale_v1_7_gthe3_channel.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_20g_ip/ip_0/sim/aurora_64b66b_20g_ip_gt_gthe3_channel_wrapper.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_20g_ip/ip_0/sim/aurora_64b66b_20g_ip_gt_gtwizard_gthe3.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_20g_ip/ip_0/sim/aurora_64b66b_20g_ip_gt_gtwizard_top.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_20g_ip/ip_0/sim/aurora_64b66b_20g_ip_gt.v" \

vlog -work fifo_generator_v13_2_5  -v2k5 \
"../../../ipstatic/simulation/fifo_generator_vlog_beh.v" \

vcom -work fifo_generator_v13_2_5 -93 \
"../../../ipstatic/hdl/fifo_generator_v13_2_rfs.vhd" \

vlog -work fifo_generator_v13_2_5  -v2k5 \
"../../../ipstatic/hdl/fifo_generator_v13_2_rfs.v" \

vlog -work xil_defaultlib  -v2k5 \
"../../../../template.gen/sources_1/ip/aurora_64b66b_20g_ip/ip_1/sim/aurora_64b66b_20g_ip_fifo_gen_master.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_20g_ip/ip_2/sim/aurora_64b66b_20g_ip_fifo_gen_slave.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_20g_ip/aurora_64b66b_20g_ip/src/aurora_64b66b_20g_ip_aurora_lane.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_20g_ip/aurora_64b66b_20g_ip/example_design/gt/aurora_64b66b_20g_ip_multi_wrapper.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_20g_ip/aurora_64b66b_20g_ip/example_design/gt/aurora_64b66b_20g_ip_ultrascale_rx_userclk.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_20g_ip/aurora_64b66b_20g_ip/src/aurora_64b66b_20g_ip_standard_cc_module.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_20g_ip/aurora_64b66b_20g_ip/src/aurora_64b66b_20g_ip_reset_logic.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_20g_ip/aurora_64b66b_20g_ip/src/aurora_64b66b_20g_ip_cdc_sync.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_20g_ip/aurora_64b66b_20g_ip_core.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_20g_ip/aurora_64b66b_20g_ip/src/aurora_64b66b_20g_ip_axi_to_ll.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_20g_ip/aurora_64b66b_20g_ip/src/aurora_64b66b_20g_ip_block_sync_sm.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_20g_ip/aurora_64b66b_20g_ip/src/aurora_64b66b_20g_ip_common_reset_cbcc.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_20g_ip/aurora_64b66b_20g_ip/src/aurora_64b66b_20g_ip_common_logic_cbcc.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_20g_ip/aurora_64b66b_20g_ip/src/aurora_64b66b_20g_ip_cbcc_gtx_6466.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_20g_ip/aurora_64b66b_20g_ip/src/aurora_64b66b_20g_ip_channel_err_detect.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_20g_ip/aurora_64b66b_20g_ip/src/aurora_64b66b_20g_ip_channel_init_sm.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_20g_ip/aurora_64b66b_20g_ip/src/aurora_64b66b_20g_ip_ch_bond_code_gen.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_20g_ip/aurora_64b66b_20g_ip/src/aurora_64b66b_20g_ip_64b66b_descrambler.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_20g_ip/aurora_64b66b_20g_ip/src/aurora_64b66b_20g_ip_err_detect.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_20g_ip/aurora_64b66b_20g_ip/src/aurora_64b66b_20g_ip_global_logic.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_20g_ip/aurora_64b66b_20g_ip/src/aurora_64b66b_20g_ip_polarity_check.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_20g_ip/aurora_64b66b_20g_ip/example_design/gt/aurora_64b66b_20g_ip_wrapper.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_20g_ip/aurora_64b66b_20g_ip/src/aurora_64b66b_20g_ip_lane_init_sm.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_20g_ip/aurora_64b66b_20g_ip/src/aurora_64b66b_20g_ip_ll_to_axi.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_20g_ip/aurora_64b66b_20g_ip/src/aurora_64b66b_20g_ip_rx_ll_datapath.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_20g_ip/aurora_64b66b_20g_ip/src/aurora_64b66b_20g_ip_rx_ll.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_20g_ip/aurora_64b66b_20g_ip/src/aurora_64b66b_20g_ip_width_conversion.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_20g_ip/aurora_64b66b_20g_ip/src/aurora_64b66b_20g_ip_64b66b_scrambler.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_20g_ip/aurora_64b66b_20g_ip/src/aurora_64b66b_20g_ip_sym_dec.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_20g_ip/aurora_64b66b_20g_ip/src/aurora_64b66b_20g_ip_sym_gen.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_20g_ip/aurora_64b66b_20g_ip/src/aurora_64b66b_20g_ip_tx_ll_control_sm.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_20g_ip/aurora_64b66b_20g_ip/src/aurora_64b66b_20g_ip_tx_ll_datapath.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_20g_ip/aurora_64b66b_20g_ip/src/aurora_64b66b_20g_ip_tx_ll.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_20g_ip/aurora_64b66b_20g_ip.v" \

vlog -work xil_defaultlib \
"glbl.v"

