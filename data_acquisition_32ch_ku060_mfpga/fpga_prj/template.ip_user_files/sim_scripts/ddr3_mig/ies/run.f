-makelib ies_lib/xpm -sv \
  "D:/Xilinx2021/Vivado/2021.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "D:/Xilinx2021/Vivado/2021.1/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
  "D:/Xilinx2021/Vivado/2021.1/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib ies_lib/xpm \
  "D:/Xilinx2021/Vivado/2021.1/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies_lib/microblaze_v11_0_6 \
  "../../../ipstatic/hdl/microblaze_v11_0_vh_rfs.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../../template.gen/sources_1/ip/ddr3_mig/bd_0/ip/ip_0/sim/bd_b70e_microblaze_I_0.vhd" \
-endlib
-makelib ies_lib/lib_cdc_v1_0_2 \
  "../../../ipstatic/hdl/lib_cdc_v1_0_rfs.vhd" \
-endlib
-makelib ies_lib/proc_sys_reset_v5_0_13 \
  "../../../ipstatic/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../../template.gen/sources_1/ip/ddr3_mig/bd_0/ip/ip_1/sim/bd_b70e_rst_0_0.vhd" \
-endlib
-makelib ies_lib/lmb_v10_v3_0_11 \
  "../../../ipstatic/hdl/lmb_v10_v3_0_vh_rfs.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../../template.gen/sources_1/ip/ddr3_mig/bd_0/ip/ip_2/sim/bd_b70e_ilmb_0.vhd" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/bd_0/ip/ip_3/sim/bd_b70e_dlmb_0.vhd" \
-endlib
-makelib ies_lib/lmb_bram_if_cntlr_v4_0_19 \
  "../../../ipstatic/hdl/lmb_bram_if_cntlr_v4_0_vh_rfs.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../../template.gen/sources_1/ip/ddr3_mig/bd_0/ip/ip_4/sim/bd_b70e_dlmb_cntlr_0.vhd" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/bd_0/ip/ip_5/sim/bd_b70e_ilmb_cntlr_0.vhd" \
-endlib
-makelib ies_lib/blk_mem_gen_v8_4_4 \
  "../../../ipstatic/simulation/blk_mem_gen_v8_4.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../../template.gen/sources_1/ip/ddr3_mig/bd_0/ip/ip_6/sim/bd_b70e_lmb_bram_I_0.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../../template.gen/sources_1/ip/ddr3_mig/bd_0/ip/ip_7/sim/bd_b70e_second_dlmb_cntlr_0.vhd" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/bd_0/ip/ip_8/sim/bd_b70e_second_ilmb_cntlr_0.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../../template.gen/sources_1/ip/ddr3_mig/bd_0/ip/ip_9/sim/bd_b70e_second_lmb_bram_I_0.v" \
-endlib
-makelib ies_lib/iomodule_v3_1_7 \
  "../../../ipstatic/hdl/iomodule_v3_1_vh_rfs.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../../template.gen/sources_1/ip/ddr3_mig/bd_0/ip/ip_10/sim/bd_b70e_iomodule_0_0.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../../template.gen/sources_1/ip/ddr3_mig/bd_0/sim/bd_b70e.v" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/ip_0/sim/ddr3_mig_microblaze_mcs.v" \
-endlib
-makelib ies_lib/xil_defaultlib -sv \
  "../../../../template.gen/sources_1/ip/ddr3_mig/ip_1/rtl/phy/ddr3_mig_phy_ddr3.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/ip_1/rtl/phy/ddr3_phy_v1_4_xiphy_behav.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/ip_1/rtl/phy/ddr3_phy_v1_4_xiphy.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/ip_1/rtl/iob/ddr3_phy_v1_4_iob_byte.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/ip_1/rtl/iob/ddr3_phy_v1_4_iob.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/ip_1/rtl/clocking/ddr3_phy_v1_4_pll.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/ip_1/rtl/xiphy_files/ddr3_phy_v1_4_xiphy_tristate_wrapper.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/ip_1/rtl/xiphy_files/ddr3_phy_v1_4_xiphy_riuor_wrapper.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/ip_1/rtl/xiphy_files/ddr3_phy_v1_4_xiphy_control_wrapper.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/ip_1/rtl/xiphy_files/ddr3_phy_v1_4_xiphy_byte_wrapper.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/ip_1/rtl/xiphy_files/ddr3_phy_v1_4_xiphy_bitslice_wrapper.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/ip_1/rtl/ip_top/ddr3_mig_phy.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/controller/ddr3_v1_4_mc_wtr.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/controller/ddr3_v1_4_mc_ref.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/controller/ddr3_v1_4_mc_rd_wr.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/controller/ddr3_v1_4_mc_periodic.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/controller/ddr3_v1_4_mc_group.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/controller/ddr3_v1_4_mc_ecc_merge_enc.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/controller/ddr3_v1_4_mc_ecc_gen.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/controller/ddr3_v1_4_mc_ecc_fi_xor.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/controller/ddr3_v1_4_mc_ecc_dec_fix.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/controller/ddr3_v1_4_mc_ecc_buf.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/controller/ddr3_v1_4_mc_ecc.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/controller/ddr3_v1_4_mc_ctl.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/controller/ddr3_v1_4_mc_cmd_mux_c.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/controller/ddr3_v1_4_mc_cmd_mux_ap.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/controller/ddr3_v1_4_mc_arb_p.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/controller/ddr3_v1_4_mc_arb_mux_p.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/controller/ddr3_v1_4_mc_arb_c.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/controller/ddr3_v1_4_mc_arb_a.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/controller/ddr3_v1_4_mc_act_timer.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/controller/ddr3_v1_4_mc_act_rank.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/controller/ddr3_v1_4_mc.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/ui/ddr3_v1_4_ui_wr_data.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/ui/ddr3_v1_4_ui_rd_data.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/ui/ddr3_v1_4_ui_cmd.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/ui/ddr3_v1_4_ui.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/clocking/ddr3_v1_4_infrastructure.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/cal/ddr3_v1_4_cal_xsdb_bram.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/cal/ddr3_v1_4_cal_write.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/cal/ddr3_v1_4_cal_wr_byte.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/cal/ddr3_v1_4_cal_wr_bit.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/cal/ddr3_v1_4_cal_sync.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/cal/ddr3_v1_4_cal_read.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/cal/ddr3_v1_4_cal_rd_en.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/cal/ddr3_v1_4_cal_pi.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/cal/ddr3_v1_4_cal_odt.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/cal/ddr3_v1_4_cal_mc_odt.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/cal/ddr3_v1_4_cal_debug_microblaze.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/cal/ddr3_v1_4_cal_cplx_data.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/cal/ddr3_v1_4_cal_cplx.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/cal/ddr3_v1_4_cal_config_rom.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/cal/ddr3_v1_4_cal_bfifo.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/cal/ddr3_v1_4_cal_addr_decode.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/cal/ddr3_v1_4_cal_top.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/cal/ddr3_v1_4_cal_xsdb_arbiter.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/cal/ddr3_v1_4_cal.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/cal/ddr3_v1_4_chipscope_xsdb_slave.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/cal/ddr3_v1_4_dp_AB9.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/ip_top/ddr3_mig_ddr3.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/ip_top/ddr3_mig_ddr3_mem_intfc.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/cal/ddr3_mig_ddr3_cal_riu.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/rtl/ip_top/ddr3_mig.sv" \
  "../../../../template.gen/sources_1/ip/ddr3_mig/tb/microblaze_mcs_0.sv" \
-endlib
-makelib ies_lib/xil_defaultlib \
  glbl.v
-endlib
