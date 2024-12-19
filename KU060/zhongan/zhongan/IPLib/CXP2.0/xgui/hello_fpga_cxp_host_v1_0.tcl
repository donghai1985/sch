# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "CAM_NUM" -parent ${Page_0}
  ipgui::add_param $IPINST -name "LINKS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "STREAMS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "STREAM_WORDS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "STREAM_BUFFER_BYTES" -parent ${Page_0}
  ipgui::add_param $IPINST -name "MULTI_STREAM_EN" -parent ${Page_0}
  ipgui::add_param $IPINST -name "EXTERNAL_PHY" -parent ${Page_0}
  ipgui::add_param $IPINST -name "REF_CLK_FREQ" -parent ${Page_0}
  ipgui::add_param $IPINST -name "INDIRECT_REGS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "BIGENDIAN_EN" -parent ${Page_0}
  ipgui::add_param $IPINST -name "Event" -parent ${Page_0}
  ipgui::add_param $IPINST -name "Heartbeat" -parent ${Page_0}


}

proc update_PARAM_VALUE.ARBITER_BUFFER_BYPASS_EN { PARAM_VALUE.ARBITER_BUFFER_BYPASS_EN } {
	# Procedure called to update ARBITER_BUFFER_BYPASS_EN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ARBITER_BUFFER_BYPASS_EN { PARAM_VALUE.ARBITER_BUFFER_BYPASS_EN } {
	# Procedure called to validate ARBITER_BUFFER_BYPASS_EN
	return true
}

proc update_PARAM_VALUE.BIGENDIAN_EN { PARAM_VALUE.BIGENDIAN_EN } {
	# Procedure called to update BIGENDIAN_EN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BIGENDIAN_EN { PARAM_VALUE.BIGENDIAN_EN } {
	# Procedure called to validate BIGENDIAN_EN
	return true
}

proc update_PARAM_VALUE.BUFFER_ADDR_WIDTH { PARAM_VALUE.BUFFER_ADDR_WIDTH } {
	# Procedure called to update BUFFER_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BUFFER_ADDR_WIDTH { PARAM_VALUE.BUFFER_ADDR_WIDTH } {
	# Procedure called to validate BUFFER_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.BURST_WIDTH { PARAM_VALUE.BURST_WIDTH } {
	# Procedure called to update BURST_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BURST_WIDTH { PARAM_VALUE.BURST_WIDTH } {
	# Procedure called to validate BURST_WIDTH
	return true
}

proc update_PARAM_VALUE.BYPASS_UNPACKER { PARAM_VALUE.BYPASS_UNPACKER } {
	# Procedure called to update BYPASS_UNPACKER when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BYPASS_UNPACKER { PARAM_VALUE.BYPASS_UNPACKER } {
	# Procedure called to validate BYPASS_UNPACKER
	return true
}

proc update_PARAM_VALUE.CAM_NUM { PARAM_VALUE.CAM_NUM } {
	# Procedure called to update CAM_NUM when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CAM_NUM { PARAM_VALUE.CAM_NUM } {
	# Procedure called to validate CAM_NUM
	return true
}

proc update_PARAM_VALUE.CHANNEL_SHARE { PARAM_VALUE.CHANNEL_SHARE } {
	# Procedure called to update CHANNEL_SHARE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CHANNEL_SHARE { PARAM_VALUE.CHANNEL_SHARE } {
	# Procedure called to validate CHANNEL_SHARE
	return true
}

proc update_PARAM_VALUE.CONTROL_CLK_FREQ { PARAM_VALUE.CONTROL_CLK_FREQ } {
	# Procedure called to update CONTROL_CLK_FREQ when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CONTROL_CLK_FREQ { PARAM_VALUE.CONTROL_CLK_FREQ } {
	# Procedure called to validate CONTROL_CLK_FREQ
	return true
}

proc update_PARAM_VALUE.DEBUG_EN { PARAM_VALUE.DEBUG_EN } {
	# Procedure called to update DEBUG_EN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEBUG_EN { PARAM_VALUE.DEBUG_EN } {
	# Procedure called to validate DEBUG_EN
	return true
}

proc update_PARAM_VALUE.DEVICE { PARAM_VALUE.DEVICE } {
	# Procedure called to update DEVICE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEVICE { PARAM_VALUE.DEVICE } {
	# Procedure called to validate DEVICE
	return true
}

proc update_PARAM_VALUE.DIS_LOW_SPEED { PARAM_VALUE.DIS_LOW_SPEED } {
	# Procedure called to update DIS_LOW_SPEED when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DIS_LOW_SPEED { PARAM_VALUE.DIS_LOW_SPEED } {
	# Procedure called to validate DIS_LOW_SPEED
	return true
}

proc update_PARAM_VALUE.DROP_PACKETS_LOGIC_EN { PARAM_VALUE.DROP_PACKETS_LOGIC_EN } {
	# Procedure called to update DROP_PACKETS_LOGIC_EN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DROP_PACKETS_LOGIC_EN { PARAM_VALUE.DROP_PACKETS_LOGIC_EN } {
	# Procedure called to validate DROP_PACKETS_LOGIC_EN
	return true
}

proc update_PARAM_VALUE.DUAL_FIFO_USE_EN { PARAM_VALUE.DUAL_FIFO_USE_EN } {
	# Procedure called to update DUAL_FIFO_USE_EN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DUAL_FIFO_USE_EN { PARAM_VALUE.DUAL_FIFO_USE_EN } {
	# Procedure called to validate DUAL_FIFO_USE_EN
	return true
}

proc update_PARAM_VALUE.EXTERNAL_PHY { PARAM_VALUE.EXTERNAL_PHY } {
	# Procedure called to update EXTERNAL_PHY when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.EXTERNAL_PHY { PARAM_VALUE.EXTERNAL_PHY } {
	# Procedure called to validate EXTERNAL_PHY
	return true
}

proc update_PARAM_VALUE.EXTRA_RECONFIG_CH { PARAM_VALUE.EXTRA_RECONFIG_CH } {
	# Procedure called to update EXTRA_RECONFIG_CH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.EXTRA_RECONFIG_CH { PARAM_VALUE.EXTRA_RECONFIG_CH } {
	# Procedure called to validate EXTRA_RECONFIG_CH
	return true
}

proc update_PARAM_VALUE.EXTRA_WIDTH { PARAM_VALUE.EXTRA_WIDTH } {
	# Procedure called to update EXTRA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.EXTRA_WIDTH { PARAM_VALUE.EXTRA_WIDTH } {
	# Procedure called to validate EXTRA_WIDTH
	return true
}

proc update_PARAM_VALUE.Event { PARAM_VALUE.Event } {
	# Procedure called to update Event when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.Event { PARAM_VALUE.Event } {
	# Procedure called to validate Event
	return true
}

proc update_PARAM_VALUE.FIFO_USED_WIDTH { PARAM_VALUE.FIFO_USED_WIDTH } {
	# Procedure called to update FIFO_USED_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FIFO_USED_WIDTH { PARAM_VALUE.FIFO_USED_WIDTH } {
	# Procedure called to validate FIFO_USED_WIDTH
	return true
}

proc update_PARAM_VALUE.FULL_PACKETS_WAIT { PARAM_VALUE.FULL_PACKETS_WAIT } {
	# Procedure called to update FULL_PACKETS_WAIT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FULL_PACKETS_WAIT { PARAM_VALUE.FULL_PACKETS_WAIT } {
	# Procedure called to validate FULL_PACKETS_WAIT
	return true
}

proc update_PARAM_VALUE.GPIO { PARAM_VALUE.GPIO } {
	# Procedure called to update GPIO when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.GPIO { PARAM_VALUE.GPIO } {
	# Procedure called to validate GPIO
	return true
}

proc update_PARAM_VALUE.Heartbeat { PARAM_VALUE.Heartbeat } {
	# Procedure called to update Heartbeat when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.Heartbeat { PARAM_VALUE.Heartbeat } {
	# Procedure called to validate Heartbeat
	return true
}

proc update_PARAM_VALUE.INDIRECT_REGS { PARAM_VALUE.INDIRECT_REGS } {
	# Procedure called to update INDIRECT_REGS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INDIRECT_REGS { PARAM_VALUE.INDIRECT_REGS } {
	# Procedure called to validate INDIRECT_REGS
	return true
}

proc update_PARAM_VALUE.LINKS { PARAM_VALUE.LINKS } {
	# Procedure called to update LINKS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.LINKS { PARAM_VALUE.LINKS } {
	# Procedure called to validate LINKS
	return true
}

proc update_PARAM_VALUE.MULTI_STREAM_EN { PARAM_VALUE.MULTI_STREAM_EN } {
	# Procedure called to update MULTI_STREAM_EN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MULTI_STREAM_EN { PARAM_VALUE.MULTI_STREAM_EN } {
	# Procedure called to validate MULTI_STREAM_EN
	return true
}

proc update_PARAM_VALUE.POLARITY { PARAM_VALUE.POLARITY } {
	# Procedure called to update POLARITY when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.POLARITY { PARAM_VALUE.POLARITY } {
	# Procedure called to validate POLARITY
	return true
}

proc update_PARAM_VALUE.REF_CLK_FREQ { PARAM_VALUE.REF_CLK_FREQ } {
	# Procedure called to update REF_CLK_FREQ when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.REF_CLK_FREQ { PARAM_VALUE.REF_CLK_FREQ } {
	# Procedure called to validate REF_CLK_FREQ
	return true
}

proc update_PARAM_VALUE.REGS_PER_LINK { PARAM_VALUE.REGS_PER_LINK } {
	# Procedure called to update REGS_PER_LINK when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.REGS_PER_LINK { PARAM_VALUE.REGS_PER_LINK } {
	# Procedure called to validate REGS_PER_LINK
	return true
}

proc update_PARAM_VALUE.SHARED_CLOCK { PARAM_VALUE.SHARED_CLOCK } {
	# Procedure called to update SHARED_CLOCK when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SHARED_CLOCK { PARAM_VALUE.SHARED_CLOCK } {
	# Procedure called to validate SHARED_CLOCK
	return true
}

proc update_PARAM_VALUE.SHARED_QPLL { PARAM_VALUE.SHARED_QPLL } {
	# Procedure called to update SHARED_QPLL when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SHARED_QPLL { PARAM_VALUE.SHARED_QPLL } {
	# Procedure called to validate SHARED_QPLL
	return true
}

proc update_PARAM_VALUE.STATUS { PARAM_VALUE.STATUS } {
	# Procedure called to update STATUS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.STATUS { PARAM_VALUE.STATUS } {
	# Procedure called to validate STATUS
	return true
}

proc update_PARAM_VALUE.STREAMS { PARAM_VALUE.STREAMS } {
	# Procedure called to update STREAMS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.STREAMS { PARAM_VALUE.STREAMS } {
	# Procedure called to validate STREAMS
	return true
}

proc update_PARAM_VALUE.STREAM_ARBITER_TYPE { PARAM_VALUE.STREAM_ARBITER_TYPE } {
	# Procedure called to update STREAM_ARBITER_TYPE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.STREAM_ARBITER_TYPE { PARAM_VALUE.STREAM_ARBITER_TYPE } {
	# Procedure called to validate STREAM_ARBITER_TYPE
	return true
}

proc update_PARAM_VALUE.STREAM_BUFFER_BYTES { PARAM_VALUE.STREAM_BUFFER_BYTES } {
	# Procedure called to update STREAM_BUFFER_BYTES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.STREAM_BUFFER_BYTES { PARAM_VALUE.STREAM_BUFFER_BYTES } {
	# Procedure called to validate STREAM_BUFFER_BYTES
	return true
}

proc update_PARAM_VALUE.STREAM_WORDS { PARAM_VALUE.STREAM_WORDS } {
	# Procedure called to update STREAM_WORDS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.STREAM_WORDS { PARAM_VALUE.STREAM_WORDS } {
	# Procedure called to validate STREAM_WORDS
	return true
}

proc update_PARAM_VALUE.TRIGGER_CLK_SYNC_EN { PARAM_VALUE.TRIGGER_CLK_SYNC_EN } {
	# Procedure called to update TRIGGER_CLK_SYNC_EN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TRIGGER_CLK_SYNC_EN { PARAM_VALUE.TRIGGER_CLK_SYNC_EN } {
	# Procedure called to validate TRIGGER_CLK_SYNC_EN
	return true
}

proc update_PARAM_VALUE.TRIGGER_PULSE_LENGTH { PARAM_VALUE.TRIGGER_PULSE_LENGTH } {
	# Procedure called to update TRIGGER_PULSE_LENGTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TRIGGER_PULSE_LENGTH { PARAM_VALUE.TRIGGER_PULSE_LENGTH } {
	# Procedure called to validate TRIGGER_PULSE_LENGTH
	return true
}

proc update_PARAM_VALUE.WIDTH_O { PARAM_VALUE.WIDTH_O } {
	# Procedure called to update WIDTH_O when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WIDTH_O { PARAM_VALUE.WIDTH_O } {
	# Procedure called to validate WIDTH_O
	return true
}


proc update_MODELPARAM_VALUE.DIS_LOW_SPEED { MODELPARAM_VALUE.DIS_LOW_SPEED PARAM_VALUE.DIS_LOW_SPEED } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DIS_LOW_SPEED}] ${MODELPARAM_VALUE.DIS_LOW_SPEED}
}

proc update_MODELPARAM_VALUE.INDIRECT_REGS { MODELPARAM_VALUE.INDIRECT_REGS PARAM_VALUE.INDIRECT_REGS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INDIRECT_REGS}] ${MODELPARAM_VALUE.INDIRECT_REGS}
}

proc update_MODELPARAM_VALUE.REGS_PER_LINK { MODELPARAM_VALUE.REGS_PER_LINK PARAM_VALUE.REGS_PER_LINK } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.REGS_PER_LINK}] ${MODELPARAM_VALUE.REGS_PER_LINK}
}

proc update_MODELPARAM_VALUE.EXTRA_RECONFIG_CH { MODELPARAM_VALUE.EXTRA_RECONFIG_CH PARAM_VALUE.EXTRA_RECONFIG_CH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.EXTRA_RECONFIG_CH}] ${MODELPARAM_VALUE.EXTRA_RECONFIG_CH}
}

proc update_MODELPARAM_VALUE.CAM_NUM { MODELPARAM_VALUE.CAM_NUM PARAM_VALUE.CAM_NUM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CAM_NUM}] ${MODELPARAM_VALUE.CAM_NUM}
}

proc update_MODELPARAM_VALUE.MULTI_STREAM_EN { MODELPARAM_VALUE.MULTI_STREAM_EN PARAM_VALUE.MULTI_STREAM_EN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MULTI_STREAM_EN}] ${MODELPARAM_VALUE.MULTI_STREAM_EN}
}

proc update_MODELPARAM_VALUE.DROP_PACKETS_LOGIC_EN { MODELPARAM_VALUE.DROP_PACKETS_LOGIC_EN PARAM_VALUE.DROP_PACKETS_LOGIC_EN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DROP_PACKETS_LOGIC_EN}] ${MODELPARAM_VALUE.DROP_PACKETS_LOGIC_EN}
}

proc update_MODELPARAM_VALUE.FULL_PACKETS_WAIT { MODELPARAM_VALUE.FULL_PACKETS_WAIT PARAM_VALUE.FULL_PACKETS_WAIT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FULL_PACKETS_WAIT}] ${MODELPARAM_VALUE.FULL_PACKETS_WAIT}
}

proc update_MODELPARAM_VALUE.ARBITER_BUFFER_BYPASS_EN { MODELPARAM_VALUE.ARBITER_BUFFER_BYPASS_EN PARAM_VALUE.ARBITER_BUFFER_BYPASS_EN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ARBITER_BUFFER_BYPASS_EN}] ${MODELPARAM_VALUE.ARBITER_BUFFER_BYPASS_EN}
}

proc update_MODELPARAM_VALUE.DUAL_FIFO_USE_EN { MODELPARAM_VALUE.DUAL_FIFO_USE_EN PARAM_VALUE.DUAL_FIFO_USE_EN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DUAL_FIFO_USE_EN}] ${MODELPARAM_VALUE.DUAL_FIFO_USE_EN}
}

proc update_MODELPARAM_VALUE.DEBUG_EN { MODELPARAM_VALUE.DEBUG_EN PARAM_VALUE.DEBUG_EN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEBUG_EN}] ${MODELPARAM_VALUE.DEBUG_EN}
}

proc update_MODELPARAM_VALUE.FIFO_USED_WIDTH { MODELPARAM_VALUE.FIFO_USED_WIDTH PARAM_VALUE.FIFO_USED_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FIFO_USED_WIDTH}] ${MODELPARAM_VALUE.FIFO_USED_WIDTH}
}

proc update_MODELPARAM_VALUE.BUFFER_ADDR_WIDTH { MODELPARAM_VALUE.BUFFER_ADDR_WIDTH PARAM_VALUE.BUFFER_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BUFFER_ADDR_WIDTH}] ${MODELPARAM_VALUE.BUFFER_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.STREAMS { MODELPARAM_VALUE.STREAMS PARAM_VALUE.STREAMS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.STREAMS}] ${MODELPARAM_VALUE.STREAMS}
}

proc update_MODELPARAM_VALUE.REF_CLK_FREQ { MODELPARAM_VALUE.REF_CLK_FREQ PARAM_VALUE.REF_CLK_FREQ } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.REF_CLK_FREQ}] ${MODELPARAM_VALUE.REF_CLK_FREQ}
}

proc update_MODELPARAM_VALUE.STREAM_WORDS { MODELPARAM_VALUE.STREAM_WORDS PARAM_VALUE.STREAM_WORDS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.STREAM_WORDS}] ${MODELPARAM_VALUE.STREAM_WORDS}
}

proc update_MODELPARAM_VALUE.LINKS { MODELPARAM_VALUE.LINKS PARAM_VALUE.LINKS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.LINKS}] ${MODELPARAM_VALUE.LINKS}
}

proc update_MODELPARAM_VALUE.STREAM_BUFFER_BYTES { MODELPARAM_VALUE.STREAM_BUFFER_BYTES PARAM_VALUE.STREAM_BUFFER_BYTES } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.STREAM_BUFFER_BYTES}] ${MODELPARAM_VALUE.STREAM_BUFFER_BYTES}
}

proc update_MODELPARAM_VALUE.DEVICE { MODELPARAM_VALUE.DEVICE PARAM_VALUE.DEVICE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEVICE}] ${MODELPARAM_VALUE.DEVICE}
}

proc update_MODELPARAM_VALUE.CHANNEL_SHARE { MODELPARAM_VALUE.CHANNEL_SHARE PARAM_VALUE.CHANNEL_SHARE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CHANNEL_SHARE}] ${MODELPARAM_VALUE.CHANNEL_SHARE}
}

proc update_MODELPARAM_VALUE.EXTERNAL_PHY { MODELPARAM_VALUE.EXTERNAL_PHY PARAM_VALUE.EXTERNAL_PHY } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.EXTERNAL_PHY}] ${MODELPARAM_VALUE.EXTERNAL_PHY}
}

proc update_MODELPARAM_VALUE.STREAM_ARBITER_TYPE { MODELPARAM_VALUE.STREAM_ARBITER_TYPE PARAM_VALUE.STREAM_ARBITER_TYPE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.STREAM_ARBITER_TYPE}] ${MODELPARAM_VALUE.STREAM_ARBITER_TYPE}
}

proc update_MODELPARAM_VALUE.BIGENDIAN_EN { MODELPARAM_VALUE.BIGENDIAN_EN PARAM_VALUE.BIGENDIAN_EN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BIGENDIAN_EN}] ${MODELPARAM_VALUE.BIGENDIAN_EN}
}

proc update_MODELPARAM_VALUE.TRIGGER_CLK_SYNC_EN { MODELPARAM_VALUE.TRIGGER_CLK_SYNC_EN PARAM_VALUE.TRIGGER_CLK_SYNC_EN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TRIGGER_CLK_SYNC_EN}] ${MODELPARAM_VALUE.TRIGGER_CLK_SYNC_EN}
}

proc update_MODELPARAM_VALUE.TRIGGER_PULSE_LENGTH { MODELPARAM_VALUE.TRIGGER_PULSE_LENGTH PARAM_VALUE.TRIGGER_PULSE_LENGTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TRIGGER_PULSE_LENGTH}] ${MODELPARAM_VALUE.TRIGGER_PULSE_LENGTH}
}

proc update_MODELPARAM_VALUE.SHARED_CLOCK { MODELPARAM_VALUE.SHARED_CLOCK PARAM_VALUE.SHARED_CLOCK } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SHARED_CLOCK}] ${MODELPARAM_VALUE.SHARED_CLOCK}
}

proc update_MODELPARAM_VALUE.SHARED_QPLL { MODELPARAM_VALUE.SHARED_QPLL PARAM_VALUE.SHARED_QPLL } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SHARED_QPLL}] ${MODELPARAM_VALUE.SHARED_QPLL}
}

proc update_MODELPARAM_VALUE.POLARITY { MODELPARAM_VALUE.POLARITY PARAM_VALUE.POLARITY } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.POLARITY}] ${MODELPARAM_VALUE.POLARITY}
}

proc update_MODELPARAM_VALUE.BYPASS_UNPACKER { MODELPARAM_VALUE.BYPASS_UNPACKER PARAM_VALUE.BYPASS_UNPACKER } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BYPASS_UNPACKER}] ${MODELPARAM_VALUE.BYPASS_UNPACKER}
}

proc update_MODELPARAM_VALUE.CONTROL_CLK_FREQ { MODELPARAM_VALUE.CONTROL_CLK_FREQ PARAM_VALUE.CONTROL_CLK_FREQ } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CONTROL_CLK_FREQ}] ${MODELPARAM_VALUE.CONTROL_CLK_FREQ}
}

