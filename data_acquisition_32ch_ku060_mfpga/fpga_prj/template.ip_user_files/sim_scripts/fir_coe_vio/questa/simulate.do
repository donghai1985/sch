onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib fir_coe_vio_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {fir_coe_vio.udo}

run -all

quit -force
