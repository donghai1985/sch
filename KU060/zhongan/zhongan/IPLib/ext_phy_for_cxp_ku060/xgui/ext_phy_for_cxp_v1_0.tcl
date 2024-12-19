# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"

}

proc update_PARAM_VALUE.LINKS { PARAM_VALUE.LINKS } {
	# Procedure called to update LINKS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.LINKS { PARAM_VALUE.LINKS } {
	# Procedure called to validate LINKS
	return true
}


proc update_MODELPARAM_VALUE.LINKS { MODELPARAM_VALUE.LINKS PARAM_VALUE.LINKS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.LINKS}] ${MODELPARAM_VALUE.LINKS}
}

