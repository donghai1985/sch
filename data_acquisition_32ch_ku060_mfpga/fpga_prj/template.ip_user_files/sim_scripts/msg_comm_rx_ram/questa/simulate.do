onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib msg_comm_rx_ram_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {msg_comm_rx_ram.udo}

run -all

quit -force
