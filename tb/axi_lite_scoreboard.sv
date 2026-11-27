import uvm_pkg::*;
`include "uvm_macros.svh"

typedef struct packed {
    bit          is_write;
    bit [31:0]   addr;
    bit [3:0]    wstrb;
    logic [1:0]  resp;
    int unsigned pre_count;
} fifo_cov_sample_t;

class axi_lite_scoreboard extends uvm_scoreboard;

    //FACTORY
    `uvm_component_utils(axi_lite_scoreboard)

    uvm_analysis_imp #(axi_lite_item, axi_lite_scoreboard) analysis_imp;
    uvm_analysis_port #(fifo_cov_sample_t) cov_ap;

    //MODEL
    localparam logic [1:0]  RESP_OKAY   = 2'b00;
    localparam logic [1:0]  RESP_SLVERR = 2'b10;
    localparam logic [31:0] DATA_ADDR  = 32'h0000_0000;
    localparam int FIFO_DEPTH = 16;

    logic [31:0] expected_fifo[$];
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
        cov_ap = new("cov_ap", this);
        reset_model();
        write_count = 0;
        read_count = 0;
        response_errors = 0;
        data_errors = 0;
    endfunction

    //RESET
    function void reset_model();
        expected_fifo.delete();
    endfunction

    //TRANSACTION
    virtual function void write(axi_lite_item item);
        logic [1:0] expected_resp;
        logic [31:0] expected_data;
        fifo_cov_sample_t cov_data;

        if (item == null) begin
            `uvm_error("NULL_ITEM", "Scoreboard received a null transaction")
            return;
        end

        cov_data.is_write  = item.is_write;
        cov_data.addr      = item.addr;
        cov_data.wstrb     = item.wstrb;
        cov_data.resp      = item.resp;
        cov_data.pre_count = expected_fifo.size();

        cov_ap.write(cov_data);

        expected_resp = RESP_SLVERR;
        expected_data = 32'd0;

        if (item.is_write) begin
            write_count++;

            if ((item.addr == DATA_ADDR) &&
                (item.wstrb == 4'hF) &&
                (expected_fifo.size() < FIFO_DEPTH)) begin
                expected_fifo.push_back(item.wdata);
                expected_resp = RESP_OKAY;
            end
        end else begin
            read_count++;

            if ((item.addr == DATA_ADDR) && (expected_fifo.size() > 0)) begin
                expected_data = expected_fifo.pop_front();
                expected_resp = RESP_OKAY;
            end
        end

        if (item.resp !== expected_resp) begin
            response_errors++;
            `uvm_error("RESP_MISMATCH",
                $sformatf("%s addr=0x%08h expected_resp=%02b actual_resp=%02b",
                          item.is_write ? "WRITE" : "READ",
                          item.addr, expected_resp, item.resp))
        end

        if (!item.is_write && (item.rdata !== expected_data)) begin
            data_errors++;
            `uvm_error("DATA_MISMATCH",
                $sformatf("READ addr=0x%08h expected_data=0x%08h actual_data=0x%08h",
                          item.addr, expected_data, item.rdata))
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
