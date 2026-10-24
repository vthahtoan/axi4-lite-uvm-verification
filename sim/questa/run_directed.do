# Chay tu thu muc work/directed_test
transcript file directed.log
onerror {abort}

# Thu vien work
if {![file exists modelsim.ini]} {
    vmap -c
}
if {![file exists work]} {
    vlib work
}
vmap work work

# Compile
vlog -sv -L mtiUvm ../../rtl/axi_lite_slave.sv
vlog -sv -L mtiUvm ../../tb/axi_lite_if.sv
vlog -sv -L mtiUvm ../../tb/axi_lite_assertions.sv
vlog -sv -L mtiUvm +incdir+../../tb ../../tb/axi_lite_pkg.sv
vlog -sv -L mtiUvm ../../tb/tb_top.sv

# Mo phong
vsim -L mtiUvm -coverage -onfinish stop -voptargs=+acc -wlf directed.wlf work.tb_top +UVM_TESTNAME=axi_lite_directed_test
add wave sim:/tb_top/axi_if/*
onbreak {resume}
run -all
quit -f
