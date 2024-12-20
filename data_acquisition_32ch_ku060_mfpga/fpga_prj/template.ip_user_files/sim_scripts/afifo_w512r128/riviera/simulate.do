onbreak {quit -force}
onerror {quit -force}

asim +access +r +m+afifo_w512r128 -L xpm -L fifo_generator_v13_2_5 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.afifo_w512r128 xil_defaultlib.glbl

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure

do {afifo_w512r128.udo}

run -all

endsim

quit -force
