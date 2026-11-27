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
    localparam logic [31:0] DATA_ADDR = 32'h0000_0000;

    logic [31:0] fifo_mem [0:15];
    logic [3:0]  wr_ptr, rd_ptr;
    logic [4:0]  fifo_count;
    logic        write_commit, push, pop;

    logic        aw_pending;
    logic [31:0] awaddr_q;
    logic        w_pending;
    logic [31:0] wdata_q;
    logic [3:0]  wstrb_q;

    assign AWREADY = ARESETn && !aw_pending && !BVALID;
    assign WREADY  = ARESETn && !w_pending  && !BVALID;
    assign ARREADY = ARESETn && !RVALID;

    assign write_commit = aw_pending && w_pending && !BVALID;

    assign push = write_commit
               && (awaddr_q == DATA_ADDR)
               && (wstrb_q == 4'hF)
               && (fifo_count < 5'd16);

    assign pop = ARVALID && ARREADY
              && (ARADDR == DATA_ADDR)
              && (fifo_count != 5'd0);

    //FIFO
    always_ff @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            fifo_count <= 5'd0;
            wr_ptr     <= 4'd0;
            rd_ptr     <= 4'd0;
        end else begin
            if (push) begin
                fifo_mem[wr_ptr] <= wdata_q;
                wr_ptr           <= wr_ptr + 1'b1;
            end

            if (pop) begin
                rd_ptr <= rd_ptr + 1'b1;
            end

            case ({push, pop})
                2'b10: fifo_count <= fifo_count + 1'b1;
                2'b01: fifo_count <= fifo_count - 1'b1;
                default: begin end
            endcase
        end
    end

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
        end else begin
            if (AWVALID && AWREADY) begin
                awaddr_q   <= AWADDR;
                aw_pending <= 1'b1;
            end

            if (WVALID && WREADY) begin
                wdata_q   <= WDATA;
                wstrb_q   <= WSTRB;
                w_pending <= 1'b1;
            end

            if (BVALID && BREADY) begin
                BVALID <= 1'b0;
            end

            if (write_commit) begin
                BRESP      <= push ? RESP_OKAY : RESP_SLVERR;
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
                RDATA  <= pop ? fifo_mem[rd_ptr] : 32'd0;
                RRESP  <= pop ? RESP_OKAY : RESP_SLVERR;
            end
        end
    end

endmodule
