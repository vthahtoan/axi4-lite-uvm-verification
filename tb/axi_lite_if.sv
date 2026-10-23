`timescale 1ns/1ps

interface axi_lite_if(
    input logic ACLK,
    input logic ARESETn
);

    //AW
    logic [31:0] AWADDR;
    logic [2:0]  AWPROT;
    logic        AWVALID;
    logic        AWREADY;

    //W
    logic [31:0] WDATA;
    logic [3:0]  WSTRB;
    logic        WVALID;
    logic        WREADY;
    
    //B
    logic [1:0]  BRESP;
    logic        BVALID;
    logic        BREADY;

    //AR
    logic [31:0] ARADDR;
    logic [2:0]  ARPROT;
    logic        ARVALID;
    logic        ARREADY;
    
    //R
    logic [31:0] RDATA;
    logic [1:0]  RRESP;
    logic        RVALID;
    logic        RREADY;

endinterface