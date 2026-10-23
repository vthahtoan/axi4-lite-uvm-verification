import uvm_pkg::*;
`include "uvm_macros.svh"

class axi_lite_sequence extends uvm_sequence #(axi_lite_item);

    //FACTORY
    `uvm_object_utils(axi_lite_sequence)

    //CONSTRUCTOR
    function new(string name = "axi_lite_sequence");
        super.new(name);
    endfunction

    //SEQUENCE
    virtual task body();
        axi_lite_item req;

        //WRITE
        req = axi_lite_item::type_id::create("write_req");
        start_item(req);
        req.is_write = 1'b1;
        req.addr     = 32'h0000_0008;
        req.wdata    = 32'd100;
        req.wstrb    = 4'b1111;
        finish_item(req);

        //READ
        req = axi_lite_item::type_id::create("read_req");
        start_item(req);
        req.is_write = 1'b0;
        req.addr     = 32'h0000_0008;
        req.wdata    = 32'b0;
        req.wstrb    = 4'b0000;
        finish_item(req);
    endtask

endclass
