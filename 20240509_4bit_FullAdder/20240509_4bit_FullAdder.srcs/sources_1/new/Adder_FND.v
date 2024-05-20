`timescale 1ns / 1ps

module Adder_FND (  // top
    input  [7:0] a,
    input  [7:0] b,
    input  [1:0] fndSel,
    output [3:0] fndCom,
    output [7:0] fndFont,
    output       carry
);

    wire [7:0] w_sum;
    wire [3:0] w_digit_1, w_digit_10, w_digit_100, w_digit_1000;
    wire [3:0] w_digit;

    decoder U_Decoder_2x4 (
        .x(fndSel),
        .y(fndCom)
    );

    Adder U_8bitAdder (
        .a  (a),
        .b  (b),
        .cin(1'b0),
        .sum(w_sum),
        .co (carry)
    );

    digitSplitter U_DigitSplitter (
        .i_digit({5'b0, carry, w_sum}),
        .o_digit_1(w_digit_1),
        .o_digit_10(w_digit_10),
        .o_digit_100(w_digit_100),
        .o_digit_1000(w_digit_1000)
    );

    mux U_Mux_4x1 (
        .sel(fndSel),
        .x0 (w_digit_1),
        .x1 (w_digit_10),
        .x2 (w_digit_100),
        .x3 (w_digit_1000),
        .y  (w_digit)
    );

    BCDtoSEG U_BcdToSeg (
        .bcd(w_digit),
        .seg(fndFont)
    );

endmodule
