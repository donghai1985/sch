onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib afifo_w512r512_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {afifo_w512r512.udo}

run -all

quit -force
