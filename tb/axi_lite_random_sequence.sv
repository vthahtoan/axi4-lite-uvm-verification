import uvm_pkg::*;
`include "uvm_macros.svh"

class axi_lite_random_sequence extends uvm_sequence #(axi_lite_item);

    //FACTORY
    `uvm_object_utils(axi_lite_random_sequence)

    int unsigned num_pairs = 100;

    //CONSTRUCTOR
    function new(string name = "axi_lite_random_sequence");
        super.new(name);
    endfunction

    //SEQUENCE
    virtual task body();
        axi_lite_item write_req;
        axi_lite_item read_req;

        repeat (num_pairs) begin
            //WRITE
            write_req = axi_lite_item::type_id::create("write_req");
            start_item(write_req);

            if (!write_req.randomize() with {
                is_write == 1'b1;
                addr inside {
                    32'h00, 32'h04, 32'h08, 32'h0C,
                    32'h10, 32'h14, 32'h18, 32'h1C,
                    32'h02, 32'h20
                };
            }) begin
                `uvm_fatal("RANDOMIZE_FAILED", "Cannot randomize write request")
            end

            finish_item(write_req);

            //READ BACK
            read_req = axi_lite_item::type_id::create("read_req");
            start_item(read_req);
            read_req.is_write = 1'b0;
            read_req.addr     = write_req.addr;
            read_req.wdata    = 32'b0;
            read_req.wstrb    = 4'b0000;
            finish_item(read_req);
        end
    endtask

endclass
