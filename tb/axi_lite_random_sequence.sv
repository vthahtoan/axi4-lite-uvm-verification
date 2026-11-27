import uvm_pkg::*;
`include "uvm_macros.svh"

class axi_lite_random_sequence extends uvm_sequence #(axi_lite_item);

    //FACTORY
    `uvm_object_utils(axi_lite_random_sequence)

    localparam logic [31:0] DATA_ADDR = 32'h0000_0000;
    int unsigned num_transactions = 200;
    int unsigned write_count;
    int unsigned read_count;

    //CONSTRUCTOR
    function new(string name = "axi_lite_random_sequence");
        super.new(name);
    endfunction

    //SEQUENCE
    virtual task body();
        axi_lite_item req;

        write_count = 0;
        read_count = 0;

        repeat (num_transactions) begin
            req = axi_lite_item::type_id::create("req");
            start_item(req);

            if (!req.randomize() with {
                is_write dist {1'b0 := 1, 1'b1 := 1};
                addr == DATA_ADDR;
                wstrb == (is_write ? 4'hF : 4'h0);
                if (!is_write) wdata == 32'b0;

                aw_delay     inside {[0:3]};
                w_delay      inside {[0:3]};
                bready_delay inside {[0:3]};
                rready_delay inside {[0:3]};
            }) begin
                `uvm_fatal("RANDOMIZE_FAILED", "Cannot randomize FIFO request")
            end

            finish_item(req);

            if (req.is_write)
                write_count++;
            else
                read_count++;
        end
    endtask

endclass
