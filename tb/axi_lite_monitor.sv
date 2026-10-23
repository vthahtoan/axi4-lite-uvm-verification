import uvm_pkg::*;
`include "uvm_macros.svh"

class axi_lite_monitor extends uvm_monitor;

    //FACTORY
    `uvm_component_utils(axi_lite_monitor)

    virtual axi_lite_if vif;
    uvm_analysis_port #(axi_lite_item) ap;

    //BUFFERS
    typedef struct packed {
        logic [31:0] data;
        logic [3:0]  strb;
    } write_payload_t;

    logic [31:0] aw_queue[$];
    write_payload_t w_queue[$];
    logic [31:0] ar_queue[$];

    //CONSTRUCTOR
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    //BUILD
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);

        if (!uvm_config_db #(virtual axi_lite_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NO_VIF", "Monitor virtual interface was not configured")
        end
    endfunction

    //RUN
    virtual task run_phase(uvm_phase phase);
        clear_buffers();

        forever begin
            @(posedge vif.ACLK or negedge vif.ARESETn);
            if (vif.ARESETn !== 1'b1) begin
                clear_buffers();
            end else begin
                sample_write();
                sample_read();
            end
        end
    endtask

    //RESET
    function void clear_buffers();
        aw_queue.delete();
        w_queue.delete();
        ar_queue.delete();
    endfunction

    //WRITE
    function void sample_write();
        axi_lite_item item;
        write_payload_t payload;

        //AW
        if (vif.AWVALID && vif.AWREADY) begin
            if ($isunknown(vif.AWADDR)) begin
                `uvm_error("AW_UNKNOWN", "Write address contains X/Z")
            end
            aw_queue.push_back(vif.AWADDR);
        end

        //W
        if (vif.WVALID && vif.WREADY) begin
            if ($isunknown(vif.WSTRB)) begin
                `uvm_error("WSTRB_UNKNOWN", "Write strobes contain X/Z")
            end
            for (int lane = 0; lane < 4; lane++) begin
                if ((vif.WSTRB[lane] === 1'b1) &&
                    $isunknown(vif.WDATA[8*lane +: 8])) begin
                    `uvm_error("WDATA_UNKNOWN", "An enabled write byte contains X/Z")
                end
            end
            payload.data = vif.WDATA;
            payload.strb = vif.WSTRB;
            w_queue.push_back(payload);
        end

        //B
        if (vif.BVALID && vif.BREADY) begin
            if ((aw_queue.size() == 0) || (w_queue.size() == 0)) begin
                `uvm_error("B_WITHOUT_REQ", "Write response has no matching AW/W payload")
            end else begin
                item = axi_lite_item::type_id::create("write_item");
                item.is_write = 1'b1;
                item.addr = aw_queue.pop_front();
                payload = w_queue.pop_front();
                item.wdata = payload.data;
                item.wstrb = payload.strb;
                item.rdata = 32'b0;
                item.resp = vif.BRESP;

                ap.write(item);
            end
        end
    endfunction

    //READ
    function void sample_read();
        axi_lite_item item;

        //AR
        if (vif.ARVALID && vif.ARREADY) begin
            if ($isunknown(vif.ARADDR)) begin
                `uvm_error("AR_UNKNOWN", "Read address contains X/Z")
            end
            ar_queue.push_back(vif.ARADDR);
        end

        //R
        if (vif.RVALID && vif.RREADY) begin
            if (ar_queue.size() == 0) begin
                `uvm_error("R_WITHOUT_REQ", "Read response has no matching AR payload")
            end else begin
                item = axi_lite_item::type_id::create("read_item");
                item.is_write = 1'b0;
                item.addr = ar_queue.pop_front();
                item.wdata = 32'b0;
                item.wstrb = 4'b0000;
                item.rdata = vif.RDATA;
                item.resp = vif.RRESP;

                ap.write(item);
            end
        end
    endfunction

    //CHECK
    virtual function void check_phase(uvm_phase phase);
        super.check_phase(phase);

        if ((aw_queue.size() != 0) || (w_queue.size() != 0) ||
            (ar_queue.size() != 0)) begin
            `uvm_error("INCOMPLETE_REQ", "Simulation ended with requests awaiting responses")
        end
    endfunction

endclass
