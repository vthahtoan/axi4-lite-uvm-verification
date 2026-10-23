`timescale 1ns/1ps

module tb_top;

    import uvm_pkg::*;
    import axi_lite_pkg::*;

    logic ACLK = 1'b0;
    logic ARESETn;

    //INTERFACE
    axi_lite_if axi_if (
        .ACLK    (ACLK),
        .ARESETn (ARESETn)
    );

    //DUT
    axi_lite_slave dut (
        .ACLK    (ACLK),
        .ARESETn (ARESETn),

        //AW
        .AWADDR  (axi_if.AWADDR),
        .AWPROT  (axi_if.AWPROT),
        .AWVALID (axi_if.AWVALID),
        .AWREADY (axi_if.AWREADY),

        //W
        .WDATA   (axi_if.WDATA),
        .WSTRB   (axi_if.WSTRB),
        .WVALID  (axi_if.WVALID),
        .WREADY  (axi_if.WREADY),

        //B
        .BRESP   (axi_if.BRESP),
        .BVALID  (axi_if.BVALID),
        .BREADY  (axi_if.BREADY),

        //AR
        .ARADDR  (axi_if.ARADDR),
        .ARPROT  (axi_if.ARPROT),
        .ARVALID (axi_if.ARVALID),
        .ARREADY (axi_if.ARREADY),

        //R
        .RDATA   (axi_if.RDATA),
        .RRESP   (axi_if.RRESP),
        .RVALID  (axi_if.RVALID),
        .RREADY  (axi_if.RREADY)
    );

    //ASSERTIONS
    axi_lite_assertions sva (
        .axi (axi_if)
    );

    //CLOCK: 10 ns
    always #5 ACLK = ~ACLK;

    //RESET
    initial begin
        ARESETn = 1'b0;

        repeat (4) @(posedge ACLK);
        @(negedge ACLK);
        ARESETn = 1'b1;
    end

    //UVM
    initial begin
        uvm_config_db #(virtual axi_lite_if)::set(
            null, "uvm_test_top.env.agent.*", "vif", axi_if
        );

        run_test();
    end

endmodule
