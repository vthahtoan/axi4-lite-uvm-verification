import uvm_pkg::*;
`include "uvm_macros.svh"

class axi_lite_random_test extends uvm_test;

    //FACTORY
    `uvm_component_utils(axi_lite_random_test)

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
        axi_lite_random_sequence seq;

        phase.raise_objection(this);

        if (env.agent.seqr == null) begin
            `uvm_fatal("NO_SEQUENCER", "Random test requires an active agent")
        end

        seq = axi_lite_random_sequence::type_id::create("seq");
        seq.num_pairs = 100;

        `uvm_info("RANDOM_TEST",
            $sformatf("Starting %0d randomized write/read pairs", seq.num_pairs),
            UVM_LOW)

        seq.start(env.agent.seqr);

        //CHECK
        if ((env.scb.write_count != seq.num_pairs) ||
            (env.scb.read_count != seq.num_pairs)) begin
            `uvm_error("TRANSACTION_COUNT",
                $sformatf("Expected %0d writes and %0d reads; scoreboard received %0d writes and %0d reads",
                          seq.num_pairs, seq.num_pairs,
                          env.scb.write_count, env.scb.read_count))
        end

        `uvm_info("RANDOM_TEST", "Random sequence completed", UVM_LOW)

        phase.drop_objection(this);
    endtask

endclass
