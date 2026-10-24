#!/usr/bin/env bash
# Chay tu thu muc work/directed_test: bash run_directed.sh
# Log chinh: directed.log

xrun -64bit -sv -uvmhome CDNS-1.2 \
    -xmlibdirname "$PWD/xcelium_fixed.d" \
    -snapshot directed_tb \
    -coverage u \
    -covoverwrite \
    +incdir+../../tb \
    ../../rtl/axi_lite_slave.sv \
    ../../tb/axi_lite_if.sv \
    ../../tb/axi_lite_assertions.sv \
    ../../tb/axi_lite_pkg.sv \
    ../../tb/tb_top.sv \
    -top tb_top \
    -l directed.log \
    +UVM_TESTNAME=axi_lite_directed_test
