onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -L gtwizard_ultrascale_v1_7_10 -L xil_defaultlib -L fifo_generator_v13_2_5 -L unisims_ver -L unimacro_ver -L secureip -L xpm -lib xil_defaultlib xil_defaultlib.aurora_64b66b_20g_ip xil_defaultlib.glbl

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {aurora_64b66b_20g_ip.udo}

run -all

quit -force
