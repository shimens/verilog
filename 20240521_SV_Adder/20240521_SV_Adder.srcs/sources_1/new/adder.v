`timescale 1ns / 1ps

module adder (
    input        clk,
    input        reset,
    input        valid,
    input  [3:0] a,
    input  [3:0] b,
    output [3:0] sum,
    output       carry
);

    reg [3:0] sum_reg, sum_next;
    reg carry_reg, carry_next;

    assign sum   = sum_reg;
    assign carry = carry_reg;

    // Register
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            sum_reg   <= 0;
            carry_reg <= 0;
        end else begin
            sum_reg   <= sum_next;
            carry_reg <= carry_next;
        end
    end

    // Combinational Logic Circuit
    always @(*) begin
        carry_next = carry_reg;
        sum_next   = sum_reg;
        if (valid) begin
            {carry_next, sum_next} = a + b;
        end
    end

endmodule
