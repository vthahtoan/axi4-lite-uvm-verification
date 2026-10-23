`timescale 1ns/1ps

package axi_lite_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    //ITEM
    `include "axi_lite_item.sv"

    //SEQUENCE
    `include "axi_lite_sequence.sv"
    `include "axi_lite_random_sequence.sv"

    //COMPONENTS
    `include "axi_lite_sequencer.sv"
    `include "axi_lite_driver.sv"
    `include "axi_lite_monitor.sv"
    `include "axi_lite_agent.sv"
    `include "axi_lite_scoreboard.sv"
    `include "axi_lite_coverage.sv"
    `include "axi_lite_env.sv"

    //TEST
    `include "axi_lite_directed_test.sv"
    `include "axi_lite_random_test.sv"

endpackage : axi_lite_pkg
