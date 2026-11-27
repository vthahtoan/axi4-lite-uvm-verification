import uvm_pkg::*;
`include "uvm_macros.svh"

class axi_lite_sequence extends uvm_sequence #(axi_lite_item);

    //FACTORY
    `uvm_object_utils(axi_lite_sequence)

    localparam logic [31:0] DATA_ADDR = 32'h0000_0000;
    localparam int unsigned FIFO_DEPTH = 16;

    //CONSTRUCTOR
    function new(string name = "axi_lite_sequence");
        super.new(name);
    endfunction

    //SEQUENCE
    virtual task body();
        //READ EMPTY
        send_read();

        //FILL
        for (int unsigned value = 1; value <= FIFO_DEPTH; value++) begin
            send_write(value);
        end

        //WRITE FULL
        send_write(32'd999);

        //DRAIN
        repeat (FIFO_DEPTH) begin
            send_read();
        end

        //READ EMPTY AGAIN
        send_read();
    endtask

    //WRITE
    task send_write(bit [31:0] data);
        axi_lite_item req;

        req = axi_lite_item::type_id::create("write_req");
        start_item(req);
        req.is_write     = 1'b1;
        req.addr         = DATA_ADDR;
        req.wdata        = data;
        req.wstrb        = 4'hF;
        req.aw_delay     = 2;
        req.w_delay      = 0;
        req.bready_delay = 3;
        finish_item(req);
    endtask

    //READ
    task send_read();
        axi_lite_item req;

        req = axi_lite_item::type_id::create("read_req");
        start_item(req);
        req.is_write     = 1'b0;
        req.addr         = DATA_ADDR;
        req.rready_delay = 3;
        finish_item(req);
    endtask

endclass
