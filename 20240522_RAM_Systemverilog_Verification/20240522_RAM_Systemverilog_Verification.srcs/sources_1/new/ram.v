`timescale 1ns / 1ps

module ram (
    input        clk,
    input  [9:0] addr,
    input  [7:0] wdata,
    input        wr_en,
    output [7:0] rdata
);
    reg [7:0] mem[0:2**10-1];  // 폭이 8bit, depth는 1024개이다.

    integer i;

    initial begin
        for (i = 0; i < 2 ** 10; i = i + 1) begin
            mem[i] = 0;
        end
    end

    always @(posedge clk) begin
        if (!wr_en) begin
            mem[addr] <= wdata;
        end
    end

    assign rdata = mem[addr];

endmodule
