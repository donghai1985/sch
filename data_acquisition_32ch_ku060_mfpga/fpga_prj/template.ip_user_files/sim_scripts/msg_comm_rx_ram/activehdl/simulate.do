onbreak {quit -force}
onerror {quit -force}

asim +access +r +m+msg_comm_rx_ram -L xpm -L dist_mem_gen_v8_0_13 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.msg_comm_rx_ram xil_defaultlib.glbl

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure

do {msg_comm_rx_ram.udo}

run -all

endsim

quit -force
