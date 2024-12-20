onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib hmc7044_cfg_rom_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {hmc7044_cfg_rom.udo}

run -all

quit -force
