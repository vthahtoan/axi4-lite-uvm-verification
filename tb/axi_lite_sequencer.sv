import uvm_pkg::*;
`include "uvm_macros.svh"

class axi_lite_sequencer extends uvm_sequencer #(axi_lite_item);

    //FACTORY
    `uvm_component_utils(axi_lite_sequencer)

    //CONSTRUCTOR
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

endclass
