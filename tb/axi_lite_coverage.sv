import uvm_pkg::*;
`include "uvm_macros.svh"

class axi_lite_coverage extends uvm_subscriber #(fifo_cov_sample_t);

    //FACTORY
    `uvm_component_utils(axi_lite_coverage)

    localparam logic [31:0] DATA_ADDR = 32'h0000_0000;
    int unsigned sample_count;

    //COVERAGE
    covergroup cg with function sample(fifo_cov_sample_t t);
        option.per_instance = 1;

        cp_operation: coverpoint t.is_write {
            bins read  = {0};
            bins write = {1};
        }

        cp_occupancy: coverpoint t.pre_count {
            bins empty   = {0};
            bins partial = {[1:15]};
            bins full    = {16};
        }

        cp_response: coverpoint t.resp {
            bins okay   = {2'b00};
            bins slverr = {2'b10};
        }

        operation_occupancy: cross cp_operation, cp_occupancy;
        operation_response:  cross cp_operation, cp_response;
    endgroup
    //CONSTRUCTOR
    function new(string name, uvm_component parent);
        super.new(name, parent);
        cg = new();
        cg.set_inst_name({get_full_name(), ".cg"});
        sample_count = 0;
    endfunction

    //SAMPLE
    virtual function void write(fifo_cov_sample_t t);
        if (t.addr != DATA_ADDR)
            return;
        if (t.is_write && t.wstrb != 4'hF)
            return;
        cg.sample(t);
        sample_count++;
    endfunction

    //REPORT
    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        `uvm_info("COV_SUMMARY",
            $sformatf("samples=%0d operation_occupancy=%0.2f%% functional_coverage=%0.2f%%",
                      sample_count, cg.operation_occupancy.get_inst_coverage(), cg.get_inst_coverage()),
            UVM_LOW)
    endfunction

endclass
