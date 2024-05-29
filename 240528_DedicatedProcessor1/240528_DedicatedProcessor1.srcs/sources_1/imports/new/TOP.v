`timescale 1ns / 1ps

module TOP (
    input        clk,
    input        reset,
    output [7:0] out,
    output [7:0] fndFont,
    output [3:0] fndCom
);

    DedicatedProcessor U_DP (
        .clk  (clk),
        .reset(reset),
        .out  (out)
    );

    fndController U_FND (
        .clk    (clk),
        .reset  (reset),
        .digit  ({6'b0, out}),
        .fndFont(fndFont),
        .fndCom (fndCom)
    );
endmodule
