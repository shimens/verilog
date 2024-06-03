`timescale 1ns / 1ps

module DataMemory (
    input  logic        clk,
    input  logic        ce,
    input  logic        we,
    input  logic [ 7:0] addr,
    input  logic [31:0] wdata,
    output logic [31:0] rdata
);
    logic [31:0] ram[0:2**6-1];

    initial begin
        int i;
        for (i = 0; i < 2 ** 8; i++) begin
            ram[i] = i + 100;
        end
    end

    assign rdata = ram[addr[7:2]];

    always_ff @(posedge clk) begin
        if (we & ce) ram[addr[7:2]] <= wdata;
    end
endmodule
