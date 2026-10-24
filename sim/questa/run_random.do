# Chay tu thu muc work/random_test
transcript file random.log
onerror {abort}

# Seed
set seed 12345

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
vsim -L mtiUvm -coverage -sv_seed $seed -onfinish stop -voptargs=+acc -wlf random.wlf work.tb_top +UVM_TESTNAME=axi_lite_random_test
add wave sim:/tb_top/axi_if/*
onbreak {resume}
run -all
quit -f
