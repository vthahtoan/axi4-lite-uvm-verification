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
