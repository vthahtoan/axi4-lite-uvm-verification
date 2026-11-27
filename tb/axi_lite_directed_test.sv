import uvm_pkg::*;
`include "uvm_macros.svh"

class axi_lite_directed_test extends uvm_test;

    //FACTORY
    `uvm_component_utils(axi_lite_directed_test)

    axi_lite_env env;

    //CONSTRUCTOR
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    //BUILD
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env = axi_lite_env::type_id::create("env", this);
    endfunction

    //RUN
    virtual task run_phase(uvm_phase phase);
        axi_lite_sequence seq;

        phase.raise_objection(this);

        if (env.agent.seqr == null) begin
            `uvm_fatal("NO_SEQUENCER", "Directed test requires an active agent")
        end

        seq = axi_lite_sequence::type_id::create("seq");

        `uvm_info("DIRECTED_TEST", "Checking empty read, FIFO fill, full write, and FIFO drain at 0x00", UVM_LOW)
        seq.start(env.agent.seqr);

        //CHECK
        if ((env.scb.write_count != 17) || (env.scb.read_count != 18)) begin
            `uvm_error("TRANSACTION_COUNT",
                $sformatf("Expected 17 writes and 18 reads; scoreboard received %0d writes and %0d reads",
                          env.scb.write_count, env.scb.read_count))
        end

        `uvm_info("DIRECTED_TEST", "Directed sequence completed", UVM_LOW)

        phase.drop_objection(this);
    endtask

endclass
