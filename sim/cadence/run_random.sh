#!/usr/bin/env bash
# Chay tu thu muc work/random_test: bash run_random.sh
# Log chinh: random.log

# Seed
seed=12345

xrun -64bit -sv -uvmhome CDNS-1.2 \
    -seed "$seed" \
    -xmlibdirname "$PWD/xcelium_random.d" \
    -snapshot random_tb \
    -coverage u \
    -covoverwrite \
    +incdir+../../tb \
    ../../rtl/axi_lite_slave.sv \
    ../../tb/axi_lite_if.sv \
    ../../tb/axi_lite_assertions.sv \
    ../../tb/axi_lite_pkg.sv \
    ../../tb/tb_top.sv \
    -top tb_top \
    -l random.log \
    +UVM_TESTNAME=axi_lite_random_test
