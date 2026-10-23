import uvm_pkg::*;
`include "uvm_macros.svh"

class axi_lite_env extends uvm_env;

    //FACTORY
    `uvm_component_utils(axi_lite_env)

    axi_lite_agent agent;
    axi_lite_scoreboard scb;
    axi_lite_coverage cov;

    //CONSTRUCTOR
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    //BUILD
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        agent = axi_lite_agent::type_id::create("agent", this);
        scb = axi_lite_scoreboard::type_id::create("scb", this);
        cov = axi_lite_coverage::type_id::create("cov", this);
    endfunction

    //CONNECT
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        agent.ap.connect(scb.analysis_imp);
        agent.ap.connect(cov.analysis_export);
    endfunction

endclass
