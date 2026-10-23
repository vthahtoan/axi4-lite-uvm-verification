import uvm_pkg::*;
`include "uvm_macros.svh"

class axi_lite_agent extends uvm_agent;

    //FACTORY
    `uvm_component_utils(axi_lite_agent)

    axi_lite_sequencer seqr;
    axi_lite_driver drv;
    axi_lite_monitor mon;
    uvm_analysis_port #(axi_lite_item) ap;

    //CONSTRUCTOR
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    //BUILD
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        ap = new("ap", this);
        mon = axi_lite_monitor::type_id::create("mon", this);

        if (get_is_active() == UVM_ACTIVE) begin
            seqr = axi_lite_sequencer::type_id::create("seqr", this);
            drv = axi_lite_driver::type_id::create("drv", this);
        end
    endfunction

    //CONNECT
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        mon.ap.connect(ap);

        if (get_is_active() == UVM_ACTIVE) begin
            drv.seq_item_port.connect(seqr.seq_item_export);
        end
    endfunction

endclass
