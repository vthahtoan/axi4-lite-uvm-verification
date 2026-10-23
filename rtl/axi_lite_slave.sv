`timescale 1ns/1ps

module axi_lite_slave (
    input  logic        ACLK,
    input  logic        ARESETn,

    //AW
    input  logic [31:0] AWADDR,
    input  logic [2:0]  AWPROT,
    input  logic        AWVALID,
    output logic        AWREADY,

    //W
    input  logic [31:0] WDATA,
    input  logic [3:0]  WSTRB,
    input  logic        WVALID,
    output logic        WREADY,

    //B
    output logic [1:0]  BRESP,
    output logic        BVALID,
    input  logic        BREADY,

    //AR
    input  logic [31:0] ARADDR,
    input  logic [2:0]  ARPROT,
    input  logic        ARVALID,
    output logic        ARREADY,

    //R
    output logic [31:0] RDATA,
    output logic [1:0]  RRESP,
    output logic        RVALID,
    input  logic        RREADY
);

    localparam logic [1:0] RESP_OKAY   = 2'b00;
    localparam logic [1:0] RESP_SLVERR = 2'b10;

    logic [31:0] regs [0:7];

    logic        aw_pending;
    logic [31:0] awaddr_q;
    logic        w_pending;
    logic [31:0] wdata_q;
    logic [3:0]  wstrb_q;

    assign AWREADY = ARESETn && !aw_pending && !BVALID;
    assign WREADY  = ARESETn && !w_pending  && !BVALID;
    assign ARREADY = ARESETn && !RVALID;

    function automatic bit address_valid(input logic [31:0] addr);
        address_valid = (addr[31:5] == 0) && (addr[1:0] == 0);
    endfunction

    //WRITE
    always_ff @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            aw_pending <= 1'b0;
            awaddr_q   <= 32'b0;
            w_pending  <= 1'b0;
            wdata_q    <= 32'b0;
            wstrb_q    <= 4'b0;
            BVALID     <= 1'b0;
            BRESP      <= RESP_OKAY;

            for (int i = 0; i < 8; i++) begin
                regs[i] <= 32'b0;
            end
        end else begin
            if (AWVALID && AWREADY) begin
                awaddr_q   <= AWADDR;
                aw_pending <= 1'b1;
            end

            if (WVALID && WREADY) begin
                wdata_q  <= WDATA;
                wstrb_q  <= WSTRB;
                w_pending <= 1'b1;
            end

            if (BVALID && BREADY) begin
                BVALID <= 1'b0;
            end

            if (aw_pending && w_pending && !BVALID) begin
                if (address_valid(awaddr_q)) begin
                    for (int byte_idx = 0; byte_idx < 4; byte_idx++) begin
                        if (wstrb_q[byte_idx]) begin
                            regs[awaddr_q[4:2]][8*byte_idx +: 8]
                                <= wdata_q[8*byte_idx +: 8];
                        end
                    end
                    BRESP <= RESP_OKAY;
                end else begin
                    BRESP <= RESP_SLVERR;
                end

                BVALID     <= 1'b1;
                aw_pending <= 1'b0;
                w_pending  <= 1'b0;
            end
        end
    end

    //READ
    always_ff @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            RVALID <= 1'b0;
            RDATA  <= 32'b0;
            RRESP  <= RESP_OKAY;
        end else begin
            if (RVALID && RREADY) begin
                RVALID <= 1'b0;
            end

            if (ARVALID && ARREADY) begin
                RVALID <= 1'b1;

                if (address_valid(ARADDR)) begin
                    RDATA <= regs[ARADDR[4:2]];
                    RRESP <= RESP_OKAY;
                end else begin
                    RDATA <= 32'b0;
                    RRESP <= RESP_SLVERR;
                end
            end
        end
    end

endmodule
