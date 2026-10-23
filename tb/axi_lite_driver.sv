import uvm_pkg::*;
`include "uvm_macros.svh"

class axi_lite_driver extends uvm_driver #(axi_lite_item);

    //FACTORY
    `uvm_component_utils(axi_lite_driver)

    virtual axi_lite_if vif;
    localparam int unsigned MAX_WAIT_CYCLES = 1000;

    //CONSTRUCTOR
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    //BUILD
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db #(virtual axi_lite_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NO_VIF", "Driver virtual interface was not configured")
        end
    endfunction

    //IDLE
    function void drive_idle();
        vif.AWADDR  = 32'b0;
        vif.AWPROT  = 3'b0;
        vif.AWVALID = 1'b0;
        vif.WDATA   = 32'b0;
        vif.WSTRB   = 4'b0;
        vif.WVALID  = 1'b0;
        vif.BREADY  = 1'b0;
        vif.ARADDR  = 32'b0;
        vif.ARPROT  = 3'b0;
        vif.ARVALID = 1'b0;
        vif.RREADY  = 1'b0;
    endfunction

    //RUN
    virtual task run_phase(uvm_phase phase);
        axi_lite_item item;

        drive_idle();

        forever begin
            seq_item_port.get_next_item(item);
            wait (vif.ARESETn === 1'b1);
            item.rdata = 'x;
            item.resp  = 'x;

            fork
                begin
                    if (item.is_write) begin
                        drive_write(item);
                    end else begin
                        drive_read(item);
                    end
                end

                //TIMEOUT
                begin
                    repeat (MAX_WAIT_CYCLES) @(posedge vif.ACLK);
                    `uvm_fatal("AXI_TIMEOUT", "AXI transaction exceeded the cycle limit")
                end

                //RESET
                begin
                    wait (vif.ARESETn !== 1'b1);
                    drive_idle();
                    `uvm_fatal("RESET_ABORT", "This driver expects reset only before traffic")
                end
            join_any
            disable fork;

            seq_item_port.item_done();
        end
    endtask

    //WRITE
    task drive_write(axi_lite_item item);
        @(negedge vif.ACLK);
        vif.AWADDR  = item.addr;
        vif.AWPROT  = 3'b000;
        vif.AWVALID = 1'b1;
        vif.WDATA   = item.wdata;
        vif.WSTRB   = item.wstrb;
        vif.WVALID  = 1'b1;
        vif.BREADY  = 1'b0;

        fork
            //AW
            begin
                do @(posedge vif.ACLK);
                while (vif.AWREADY !== 1'b1);

                @(negedge vif.ACLK);
                vif.AWVALID = 1'b0;
            end

            //W
            begin
                do @(posedge vif.ACLK);
                while (vif.WREADY !== 1'b1);

                @(negedge vif.ACLK);
                vif.WVALID = 1'b0;
            end
        join

        //B
        vif.BREADY = 1'b1;
        do @(posedge vif.ACLK);
        while (vif.BVALID !== 1'b1);
        item.resp = vif.BRESP;

        @(negedge vif.ACLK);
        vif.BREADY = 1'b0;
    endtask

    //READ
    task drive_read(axi_lite_item item);
        @(negedge vif.ACLK);
        vif.ARADDR  = item.addr;
        vif.ARPROT  = 3'b000;
        vif.ARVALID = 1'b1;
        vif.RREADY  = 1'b0;

        //AR
        do @(posedge vif.ACLK);
        while (vif.ARREADY !== 1'b1);

        @(negedge vif.ACLK);
        vif.ARVALID = 1'b0;
        vif.RREADY  = 1'b1;

        //R
        do @(posedge vif.ACLK);
        while (vif.RVALID !== 1'b1);
        item.rdata = vif.RDATA;
        item.resp  = vif.RRESP;

        @(negedge vif.ACLK);
        vif.RREADY = 1'b0;
    endtask

endclass
