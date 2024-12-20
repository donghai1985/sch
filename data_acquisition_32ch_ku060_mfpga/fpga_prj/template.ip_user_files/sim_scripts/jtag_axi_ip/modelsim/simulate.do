onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -L jtag_axi -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -L xpm -lib xil_defaultlib xil_defaultlib.jtag_axi_ip xil_defaultlib.glbl

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {jtag_axi_ip.udo}

run -all

quit -force
