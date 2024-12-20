onbreak {quit -force}
onerror {quit -force}

asim +access +r +m+aurora_64b66b_10g_ip -L xpm -L gtwizard_ultrascale_v1_7_10 -L xil_defaultlib -L fifo_generator_v13_2_5 -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.aurora_64b66b_10g_ip xil_defaultlib.glbl

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure

do {aurora_64b66b_10g_ip.udo}

run -all

endsim

quit -force
