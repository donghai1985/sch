onbreak {quit -force}
onerror {quit -force}

asim +access +r +m+fir_coe_vio -L xpm -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.fir_coe_vio xil_defaultlib.glbl

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure

do {fir_coe_vio.udo}

run -all

endsim

quit -force
