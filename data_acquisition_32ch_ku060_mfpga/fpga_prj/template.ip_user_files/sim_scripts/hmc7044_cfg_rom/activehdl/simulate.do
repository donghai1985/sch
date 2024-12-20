onbreak {quit -force}
onerror {quit -force}

asim +access +r +m+hmc7044_cfg_rom -L xpm -L blk_mem_gen_v8_4_4 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.hmc7044_cfg_rom xil_defaultlib.glbl

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure

do {hmc7044_cfg_rom.udo}

run -all

endsim

quit -force
