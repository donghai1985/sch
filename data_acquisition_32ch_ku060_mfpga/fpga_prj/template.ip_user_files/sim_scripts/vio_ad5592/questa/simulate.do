onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib vio_ad5592_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {vio_ad5592.udo}

run -all

quit -force
