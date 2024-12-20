onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib sync_fifo_w512_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {sync_fifo_w512.udo}

run -all

quit -force
