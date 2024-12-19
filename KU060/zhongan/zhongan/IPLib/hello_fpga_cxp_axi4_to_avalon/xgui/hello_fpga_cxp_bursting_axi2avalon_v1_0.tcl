# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "ADDRSIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "BURSTSIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "BYTESIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S_AXI_ADDR_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S_AXI_BURST_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S_AXI_DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DATASIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DEVICE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "ERRORCODESIZE" -parent ${Page_0}


}

proc update_PARAM_VALUE.ADDRSIZE { PARAM_VALUE.ADDRSIZE } {
	# Procedure called to update ADDRSIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ADDRSIZE { PARAM_VALUE.ADDRSIZE } {
	# Procedure called to validate ADDRSIZE
	return true
}

proc update_PARAM_VALUE.BURSTSIZE { PARAM_VALUE.BURSTSIZE } {
	# Procedure called to update BURSTSIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BURSTSIZE { PARAM_VALUE.BURSTSIZE } {
	# Procedure called to validate BURSTSIZE
	return true
}

proc update_PARAM_VALUE.BYTESIZE { PARAM_VALUE.BYTESIZE } {
	# Procedure called to update BYTESIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BYTESIZE { PARAM_VALUE.BYTESIZE } {
	# Procedure called to validate BYTESIZE
	return true
}

proc update_PARAM_VALUE.C_S_AXI_ADDR_WIDTH { PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to update C_S_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_ADDR_WIDTH { PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to validate C_S_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S_AXI_BURST_WIDTH { PARAM_VALUE.C_S_AXI_BURST_WIDTH } {
	# Procedure called to update C_S_AXI_BURST_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_BURST_WIDTH { PARAM_VALUE.C_S_AXI_BURST_WIDTH } {
	# Procedure called to validate C_S_AXI_BURST_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S_AXI_DATA_WIDTH { PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to update C_S_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_DATA_WIDTH { PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to validate C_S_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.DATASIZE { PARAM_VALUE.DATASIZE } {
	# Procedure called to update DATASIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATASIZE { PARAM_VALUE.DATASIZE } {
	# Procedure called to validate DATASIZE
	return true
}

proc update_PARAM_VALUE.DEVICE { PARAM_VALUE.DEVICE } {
	# Procedure called to update DEVICE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEVICE { PARAM_VALUE.DEVICE } {
	# Procedure called to validate DEVICE
	return true
}

proc update_PARAM_VALUE.ERRORCODESIZE { PARAM_VALUE.ERRORCODESIZE } {
	# Procedure called to update ERRORCODESIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ERRORCODESIZE { PARAM_VALUE.ERRORCODESIZE } {
	# Procedure called to validate ERRORCODESIZE
	return true
}


proc update_MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S_AXI_BURST_WIDTH { MODELPARAM_VALUE.C_S_AXI_BURST_WIDTH PARAM_VALUE.C_S_AXI_BURST_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_BURST_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_BURST_WIDTH}
}

proc update_MODELPARAM_VALUE.ADDRSIZE { MODELPARAM_VALUE.ADDRSIZE PARAM_VALUE.ADDRSIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ADDRSIZE}] ${MODELPARAM_VALUE.ADDRSIZE}
}

proc update_MODELPARAM_VALUE.DATASIZE { MODELPARAM_VALUE.DATASIZE PARAM_VALUE.DATASIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATASIZE}] ${MODELPARAM_VALUE.DATASIZE}
}

proc update_MODELPARAM_VALUE.BYTESIZE { MODELPARAM_VALUE.BYTESIZE PARAM_VALUE.BYTESIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BYTESIZE}] ${MODELPARAM_VALUE.BYTESIZE}
}

proc update_MODELPARAM_VALUE.BURSTSIZE { MODELPARAM_VALUE.BURSTSIZE PARAM_VALUE.BURSTSIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BURSTSIZE}] ${MODELPARAM_VALUE.BURSTSIZE}
}

proc update_MODELPARAM_VALUE.ERRORCODESIZE { MODELPARAM_VALUE.ERRORCODESIZE PARAM_VALUE.ERRORCODESIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ERRORCODESIZE}] ${MODELPARAM_VALUE.ERRORCODESIZE}
}

proc update_MODELPARAM_VALUE.DEVICE { MODELPARAM_VALUE.DEVICE PARAM_VALUE.DEVICE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEVICE}] ${MODELPARAM_VALUE.DEVICE}
}

