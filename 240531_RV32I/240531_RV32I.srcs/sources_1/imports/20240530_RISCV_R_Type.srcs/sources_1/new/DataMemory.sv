`timescale 1ns / 1ps

module DataMemory (
    input  logic        clk,
    input  logic        we,
    input  logic        ce,
    input  logic [31:0] addr,
    input  logic [31:0] wdata,
    output logic [31:0] rdata
);
    logic [31:0] ram[0:63];

    initial begin
        int i;
        for (i = 0; i < 64; i++) begin
            ram[i] = i + 100;
        end
    end

    assign rdata = ram[addr[31:2]];

    always_ff @(posedge clk) begin
        if (we) ram[addr[31:2]] <= wdata;
    end
endmodule
