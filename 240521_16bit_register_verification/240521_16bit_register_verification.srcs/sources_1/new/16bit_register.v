`timescale 1ns / 1ps

module bit_register_16 (
    input         clk,
    input         reset,
    input         valid,
    input  [15:0] in,
    output [15:0] out
);
    reg [15:0] out_reg, out_next;

    assign out = out_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            out_reg <= 0;
        end else begin
            out_reg <= out_next;
        end
    end

    always @(*) begin
        out_next = out_reg;
        if (valid) begin
            out_next = in;
        end
    end

endmodule
