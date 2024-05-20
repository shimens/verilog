`timescale 1ns / 1ps

module adder_fnd (
    input clk,
    input [7:0] a,
    input [7:0] b,
    output [3:0] fndCom,
    output [7:0] fndFont
);
    wire [7:0] w_sum;
    wire w_carry;

    Adder_8bit U_Adder (
        .a  (a),
        .b  (b),
        .cin(1'b0),
        .sum(w_sum),
        .co (w_carry)
    );

    fndController U_FndController (
        .clk(clk),
        .digit({5'b0, w_carry, w_sum}),
        .fndFont(fndFont),
        .fndCom(fndCom)
    );

endmodule
