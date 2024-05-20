`timescale 1ns / 1ps

module UpCounter_10k (
    input clk,
    input reset,
    output [13:0] man_counter
);
    wire w_clk_10hz;
    wire [13:0] w_count_10k;

    clkDiv #(.MAX_COUNT(10_000_000)) U_ClkDiv_10Hz (
        .clk  (clk),
        .reset(reset),
        .o_clk(w_clk_10hz)
    );

    counter #(.MAX_COUNT(10_000)) U_Counter_10k (
        .clk  (w_clk_10hz),
        .reset(reset),
        .count(man_counter)
    );

    // fndController U_fndController (
    //     .clk(clk),
    //     .reset(reset),
    //     .digit(w_count_10k),
    //     .fndFont(fndFont),
    //     .fndCom(fndCom)
    // );
endmodule
