onbreak {quit -force}
onerror {quit -force}

asim +access +r +m+vio_spi_cfg -L xpm -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.vio_spi_cfg xil_defaultlib.glbl

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure

do {vio_spi_cfg.udo}

run -all

endsim

quit -force
