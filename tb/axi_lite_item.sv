import uvm_pkg::*;
`include "uvm_macros.svh"

class axi_lite_item extends uvm_sequence_item;

    //REQUEST
    rand bit        is_write;
    rand bit [31:0] addr;
    rand bit [31:0] wdata;
    rand bit [3:0]  wstrb;

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
