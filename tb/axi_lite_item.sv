import uvm_pkg::*;
`include "uvm_macros.svh"

class axi_lite_item extends uvm_sequence_item;

    //REQUEST
    rand bit        is_write;
    rand bit [31:0] addr;
    rand bit [31:0] wdata;
    rand bit [3:0]  wstrb;

    //TIMING
    rand int unsigned aw_delay     = 0;
    rand int unsigned w_delay      = 0;
    rand int unsigned bready_delay = 0;
    rand int unsigned rready_delay = 0;

    //RESPONSE
    logic [31:0] rdata;
    logic [1:0]  resp;

    //FACTORY
    `uvm_object_utils(axi_lite_item)

    //CONSTRUCTOR
    function new(string name = "axi_lite_item");
        super.new(name);
    endfunction

endclass
