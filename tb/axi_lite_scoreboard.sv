import uvm_pkg::*;
`include "uvm_macros.svh"

class axi_lite_scoreboard extends uvm_scoreboard;

    //FACTORY
    `uvm_component_utils(axi_lite_scoreboard)

    uvm_analysis_imp #(axi_lite_item, axi_lite_scoreboard) analysis_imp;

    //MODEL
    localparam int unsigned NUM_REGS = 8;
    localparam int unsigned BYTES_PER_REG = 4;
    localparam logic [1:0] RESP_OKAY   = 2'b00;
    localparam logic [1:0] RESP_SLVERR = 2'b10;

    logic [31:0] expected_regs [0:NUM_REGS-1];
    int unsigned write_count;
    int unsigned read_count;
    int unsigned response_errors;
    int unsigned data_errors;

    //CONSTRUCTOR
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    //BUILD
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        analysis_imp = new("analysis_imp", this);
        reset_model();
        write_count = 0;
        read_count = 0;
        response_errors = 0;
        data_errors = 0;
    endfunction

    //RESET
    function void reset_model();
        foreach (expected_regs[i]) begin
            expected_regs[i] = 32'b0;
        end
    endfunction

    //ADDRESS
    function bit address_valid(bit [31:0] addr);
        return (addr < NUM_REGS * BYTES_PER_REG) &&
               ((addr % BYTES_PER_REG) == 0);
    endfunction

    //TRANSACTION
    virtual function void write(axi_lite_item item);
        bit valid_addr;
        int unsigned reg_index;
        logic [1:0] expected_resp;
        logic [31:0] expected_data;

        if (item == null) begin
            `uvm_error("NULL_ITEM", "Scoreboard received a null transaction")
            return;
        end

        valid_addr = address_valid(item.addr);
        expected_resp = valid_addr ? RESP_OKAY : RESP_SLVERR;

        if (valid_addr) begin
            reg_index = item.addr / BYTES_PER_REG;
        end

        //RESPONSE
        if (item.resp !== expected_resp) begin
            response_errors++;
            `uvm_error("RESP_MISMATCH",
                $sformatf("%s addr=0x%08h expected_resp=%02b actual_resp=%02b",
                          item.is_write ? "WRITE" : "READ",
                          item.addr, expected_resp, item.resp))
        end

        //WRITE
        if (item.is_write) begin
            write_count++;

            if (valid_addr) begin
                for (int lane = 0; lane < BYTES_PER_REG; lane++) begin
                    if (item.wstrb[lane]) begin
                        expected_regs[reg_index][8*lane +: 8] =
                            item.wdata[8*lane +: 8];
                    end
                end
            end
        end 
        //READ
        else begin
            read_count++;
            expected_data = 32'b0;

            if (valid_addr) begin
                expected_data = expected_regs[reg_index];
            end

            if (item.rdata !== expected_data) begin
                data_errors++;
                `uvm_error("DATA_MISMATCH",
                    $sformatf("READ addr=0x%08h expected_data=0x%08h actual_data=0x%08h",
                              item.addr, expected_data, item.rdata))
            end
        end
    endfunction

    //CHECK
    virtual function void check_phase(uvm_phase phase);
        super.check_phase(phase);

        if ((write_count == 0) && (read_count == 0)) begin
            `uvm_error("NO_TRANSACTIONS", "Scoreboard did not receive any transactions")
        end
    endfunction

    //REPORT
    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        `uvm_info("SCB_SUMMARY",
            $sformatf("writes=%0d reads=%0d response_errors=%0d data_errors=%0d",
                      write_count, read_count, response_errors, data_errors),
            UVM_LOW)
    endfunction

endclass
