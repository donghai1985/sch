onbreak {quit -force}
onerror {quit -force}

asim +access +r +m+jtag_axi_ip -L xpm -L jtag_axi -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.jtag_axi_ip xil_defaultlib.glbl

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure

do {jtag_axi_ip.udo}

run -all

endsim

quit -force
