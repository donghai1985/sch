onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib afifo_w512r128_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {afifo_w512r128.udo}

run -all

quit -force
