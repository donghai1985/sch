onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib afifo_w64d1024_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {afifo_w64d1024.udo}

run -all

quit -force
