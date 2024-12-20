vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -work xil_defaultlib  -incr -mfcu \
"../../../../template.gen/sources_1/ip/aurora_64b66b_10g_ip/ip_0/sim/gtwizard_ultrascale_v1_7_gthe3_channel.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_10g_ip/ip_0/sim/aurora_64b66b_10g_ip_gt_gthe3_channel_wrapper.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_10g_ip/ip_0/sim/aurora_64b66b_10g_ip_gt_gtwizard_gthe3.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_10g_ip/ip_0/sim/aurora_64b66b_10g_ip_gt_gtwizard_top.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_10g_ip/ip_0/sim/aurora_64b66b_10g_ip_gt.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_10g_ip/ip_1/sim/aurora_64b66b_10g_ip_fifo_gen_master.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_10g_ip/aurora_64b66b_10g_ip/src/aurora_64b66b_10g_ip_aurora_lane.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_10g_ip/aurora_64b66b_10g_ip/example_design/gt/aurora_64b66b_10g_ip_multi_wrapper.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_10g_ip/aurora_64b66b_10g_ip/example_design/gt/aurora_64b66b_10g_ip_ultrascale_rx_userclk.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_10g_ip/aurora_64b66b_10g_ip/src/aurora_64b66b_10g_ip_standard_cc_module.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_10g_ip/aurora_64b66b_10g_ip/src/aurora_64b66b_10g_ip_reset_logic.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_10g_ip/aurora_64b66b_10g_ip/src/aurora_64b66b_10g_ip_cdc_sync.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_10g_ip/aurora_64b66b_10g_ip_core.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_10g_ip/aurora_64b66b_10g_ip/src/aurora_64b66b_10g_ip_axi_to_ll.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_10g_ip/aurora_64b66b_10g_ip/src/aurora_64b66b_10g_ip_block_sync_sm.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_10g_ip/aurora_64b66b_10g_ip/src/aurora_64b66b_10g_ip_common_reset_cbcc.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_10g_ip/aurora_64b66b_10g_ip/src/aurora_64b66b_10g_ip_common_logic_cbcc.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_10g_ip/aurora_64b66b_10g_ip/src/aurora_64b66b_10g_ip_cbcc_gtx_6466.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_10g_ip/aurora_64b66b_10g_ip/src/aurora_64b66b_10g_ip_channel_err_detect.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_10g_ip/aurora_64b66b_10g_ip/src/aurora_64b66b_10g_ip_channel_init_sm.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_10g_ip/aurora_64b66b_10g_ip/src/aurora_64b66b_10g_ip_ch_bond_code_gen.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_10g_ip/aurora_64b66b_10g_ip/src/aurora_64b66b_10g_ip_64b66b_descrambler.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_10g_ip/aurora_64b66b_10g_ip/src/aurora_64b66b_10g_ip_err_detect.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_10g_ip/aurora_64b66b_10g_ip/src/aurora_64b66b_10g_ip_global_logic.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_10g_ip/aurora_64b66b_10g_ip/src/aurora_64b66b_10g_ip_polarity_check.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_10g_ip/aurora_64b66b_10g_ip/example_design/gt/aurora_64b66b_10g_ip_wrapper.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_10g_ip/aurora_64b66b_10g_ip/src/aurora_64b66b_10g_ip_lane_init_sm.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_10g_ip/aurora_64b66b_10g_ip/src/aurora_64b66b_10g_ip_ll_to_axi.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_10g_ip/aurora_64b66b_10g_ip/src/aurora_64b66b_10g_ip_rx_ll_datapath.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_10g_ip/aurora_64b66b_10g_ip/src/aurora_64b66b_10g_ip_rx_ll.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_10g_ip/aurora_64b66b_10g_ip/src/aurora_64b66b_10g_ip_width_conversion.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_10g_ip/aurora_64b66b_10g_ip/src/aurora_64b66b_10g_ip_64b66b_scrambler.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_10g_ip/aurora_64b66b_10g_ip/src/aurora_64b66b_10g_ip_sym_dec.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_10g_ip/aurora_64b66b_10g_ip/src/aurora_64b66b_10g_ip_sym_gen.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_10g_ip/aurora_64b66b_10g_ip/src/aurora_64b66b_10g_ip_tx_ll_control_sm.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_10g_ip/aurora_64b66b_10g_ip/src/aurora_64b66b_10g_ip_tx_ll_datapath.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_10g_ip/aurora_64b66b_10g_ip/src/aurora_64b66b_10g_ip_tx_ll.v" \
"../../../../template.gen/sources_1/ip/aurora_64b66b_10g_ip/aurora_64b66b_10g_ip.v" \


vlog -work xil_defaultlib \
"glbl.v"

