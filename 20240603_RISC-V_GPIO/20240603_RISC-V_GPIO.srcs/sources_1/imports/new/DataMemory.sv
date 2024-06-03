`timescale 1ns / 1ps

module DataMemory (
    input logic       clk,
    we,
    ce,
    input logic [7:0] addr,

    output logic [31:0] wdata,
    rdata
);

    logic [31:0] ram[0:2**8-1];

    initial begin
        int i;
        for (i = 0; i < 64; i++) begin
            ram[i] = 100 + i;   // simul 확인하기 편하도록. 1주소에 101이 들어있음
        end
    end

    assign rdata = ram[addr[7:2]];

    always_ff @(posedge clk) begin : blockName
        if (we) begin
            ram[addr[7:2]] <= wdata;
        end
    end






endmodule
