import uvm_pkg::*;
`include "uvm_macros.svh"

class axi_lite_coverage extends uvm_subscriber #(axi_lite_item);

    //FACTORY
    `uvm_component_utils(axi_lite_coverage)

    localparam int unsigned NUM_REGS = 8;
    localparam int unsigned BYTES_PER_REG = 4;
    int unsigned sample_count;

    //COVERAGE
    covergroup cg with function sample(axi_lite_item item, bit valid_addr);
        option.per_instance = 1;

        cp_operation: coverpoint item.is_write {
            bins read  = {0};
            bins write = {1};
        }

        cp_address_kind: coverpoint valid_addr {
            bins valid   = {1};
            bins invalid = {0};
        }

        cp_register: coverpoint item.addr[4:2] iff (valid_addr) {
            bins registers[] = {[0:NUM_REGS-1]};
        }

        cp_response: coverpoint item.resp {
            bins okay   = {2'b00};
            bins slverr = {2'b10};
        }

        cp_strobe: coverpoint item.wstrb iff (item.is_write && valid_addr) {
            bins strobes[] = {[0:15]};
        }

        operation_register: cross cp_operation, cp_register iff (valid_addr);
        operation_response: cross cp_operation, cp_response;
    endgroup

    //CONSTRUCTOR
    function new(string name, uvm_component parent);
        super.new(name, parent);
        cg = new();
        cg.set_inst_name({get_full_name(), ".cg"});
        sample_count = 0;
    endfunction

    //SAMPLE
    virtual function void write(axi_lite_item t);
        bit valid_addr;

        if (t == null) begin
            `uvm_error("NULL_ITEM", "Coverage received a null transaction")
            return;
        end

        valid_addr = (t.addr < NUM_REGS * BYTES_PER_REG) &&
                     ((t.addr % BYTES_PER_REG) == 0);

        cg.sample(t, valid_addr);
        sample_count++;
    endfunction

    //REPORT
    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        `uvm_info("COV_SUMMARY",
            $sformatf("transactions=%0d functional_coverage=%0.2f%%",
                      sample_count, cg.get_inst_coverage()),
            UVM_LOW)
    endfunction

endclass
