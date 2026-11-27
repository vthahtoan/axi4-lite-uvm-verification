`timescale 1ns/1ps

module axi_lite_assertions (axi_lite_if axi);

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    //AW
    property p_aw_stable;
        @(posedge axi.ACLK) disable iff (!axi.ARESETn)
        (axi.AWVALID && !axi.AWREADY) |=>
        (axi.AWVALID && $stable({axi.AWADDR, axi.AWPROT}));
    endproperty

    a_aw_stable: assert property (p_aw_stable)
        else `uvm_error("SVA_AW", "AWVALID, AWADDR or AWPROT changed while waiting for AWREADY")

    //W
    property p_w_stable;
        @(posedge axi.ACLK) disable iff (!axi.ARESETn)
        (axi.WVALID && !axi.WREADY) |=>
        (axi.WVALID && $stable({axi.WDATA, axi.WSTRB}));
    endproperty

    a_w_stable: assert property (p_w_stable)
        else `uvm_error("SVA_W", "WVALID, WDATA or WSTRB changed while waiting for WREADY")

    //B
    property p_b_stable;
        @(posedge axi.ACLK) disable iff (!axi.ARESETn)
        (axi.BVALID && !axi.BREADY) |=>
        (axi.BVALID && $stable(axi.BRESP));
    endproperty

    a_b_stable: assert property (p_b_stable)
        else `uvm_error("SVA_B", "BVALID or BRESP changed while waiting for BREADY")

    //AR
    property p_ar_stable;
        @(posedge axi.ACLK) disable iff (!axi.ARESETn)
        (axi.ARVALID && !axi.ARREADY) |=>
        (axi.ARVALID && $stable({axi.ARADDR, axi.ARPROT}));
    endproperty

    a_ar_stable: assert property (p_ar_stable)
        else `uvm_error("SVA_AR", "ARVALID, ARADDR or ARPROT changed while waiting for ARREADY")

    //R
    property p_r_stable;
        @(posedge axi.ACLK) disable iff (!axi.ARESETn)
        (axi.RVALID && !axi.RREADY) |=>
        (axi.RVALID && $stable({axi.RDATA, axi.RRESP}));
    endproperty

    a_r_stable: assert property (p_r_stable)
        else `uvm_error("SVA_R", "RVALID, RDATA or RRESP changed while waiting for RREADY")

endmodule

module axi_lite_fifo_assertions (
    input logic       ACLK,
    input logic       ARESETn,
    input logic       push,
    input logic       pop,
    input logic [4:0] fifo_count,
    input logic [3:0] wr_ptr,
    input logic [3:0] rd_ptr
);

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    //COUNT RANGE
    a_count_range: assert property (
        @(posedge ACLK) disable iff (!ARESETn)
        (fifo_count <= 5'd16)
    ) else `uvm_error("SVA_FIFO_RANGE", "FIFO count is outside 0 to 16")

    //PUSH ONLY
    a_count_push: assert property (
        @(posedge ACLK) disable iff (!ARESETn)
        (push && !pop) |=> (fifo_count == $past(fifo_count) + 5'd1)
    ) else `uvm_error("SVA_FIFO_PUSH", "FIFO count did not increase by 1")

    //POP ONLY
    a_count_pop: assert property (
        @(posedge ACLK) disable iff (!ARESETn)
        (!push && pop) |=> (fifo_count == $past(fifo_count) - 5'd1)
    ) else `uvm_error("SVA_FIFO_POP", "FIFO count did not decrease by 1")

    //BOTH OR IDLE
    a_count_hold: assert property (
        @(posedge ACLK) disable iff (!ARESETn)
        (push == pop) |=> $stable(fifo_count)
    ) else `uvm_error("SVA_FIFO_HOLD", "FIFO count changed during both or idle")

    //WRITE POINTER WRAP
    a_wr_wrap: assert property (
        @(posedge ACLK) disable iff (!ARESETn)
        (push && (wr_ptr == 4'd15)) |=> (wr_ptr == 4'd0)
    ) else `uvm_error("SVA_FIFO_WR_WRAP", "Write pointer did not wrap from 15 to 0")

    c_wr_wrap: cover property (
        @(posedge ACLK) disable iff (!ARESETn)
        (push && (wr_ptr == 4'd15)) ##1 (wr_ptr == 4'd0)
    ) begin
        `uvm_info("FIFO_WR_WRAP", "Write pointer wrapped from 15 to 0", UVM_LOW)
    end

    //READ POINTER WRAP
    a_rd_wrap: assert property (
        @(posedge ACLK) disable iff (!ARESETn)
        (pop && (rd_ptr == 4'd15)) |=> (rd_ptr == 4'd0)
    ) else `uvm_error("SVA_FIFO_RD_WRAP", "Read pointer did not wrap from 15 to 0")

    c_rd_wrap: cover property (
        @(posedge ACLK) disable iff (!ARESETn)
        (pop && (rd_ptr == 4'd15)) ##1 (rd_ptr == 4'd0)
    ) begin
        `uvm_info("FIFO_RD_WRAP", "Read pointer wrapped from 15 to 0", UVM_LOW)
    end

    //PUSH AND POP TOGETHER
    c_push_pop: cover property (
        @(posedge ACLK) disable iff (!ARESETn)
        push && pop
    );

endmodule

bind axi_lite_slave axi_lite_fifo_assertions fifo_sva (
    .ACLK       (ACLK),
    .ARESETn    (ARESETn),
    .push       (push),
    .pop        (pop),
    .fifo_count (fifo_count),
    .wr_ptr     (wr_ptr),
    .rd_ptr     (rd_ptr)
);