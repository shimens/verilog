`timescale 1ns / 1ps

module clock (
    input clk,
    input reset,
    input modeSwitch,
    output [3:0] fndCom,
    output [7:0] fndFont
);



    wire w_clk_1s, w_clk_s;
    wire [13:0] w_count_m_digit;
    wire [5:0] w_clk_60s, w_clk_60m, w_clk_60m_cal;

        wire w_clk_10hz;
    wire [13:0] w_count_10k;

    fndController U_FndController (
        .clk(clk),
        .reset(reset),
        .sel_sw(modeSwitch),
        .digits(w_clk_60s),
        .digitm(w_clk_60m),
        .digitc(w_count_10k),
        .fndFont(fndFont),
        .fndCom(fndCom)
    );

    clkDiv #(
        .MAX_COUNT(100_000_000)
    ) U_ClkDiv_1s (  // #(.MAX_COUNT(100_000)) 이게 없으면 default 값이 들어가고, 넣으면 입력된값 들어감
        .clk  (clk),
        .reset(reset),
        .o_clk(w_clk_1s)
    );

    counter #(
        .MAX_COUNT(60)
    ) U_Counter_s (
        .clk(w_clk_1s),
        .reset(reset),
        .count(w_clk_60s),
        .o_min_clk(w_clk_s)
    );

    counter #(
        .MAX_COUNT(60)
    ) U_Counter_m (
        .clk  (w_clk_s),
        .reset(reset),
        .count(w_clk_60m)
    );

    clkDiv #(
        .MAX_COUNT(10_000_000)
    ) U_ClkDiv_10Hz (
        .clk  (clk),
        .reset(reset),
        .o_clk(w_clk_10hz)
    );

    counter #(
        .MAX_COUNT(10_000)
    ) U_Counter_10k (
        .clk  (w_clk_10hz),
        .reset(reset),
        .count(w_count_10k)
    );

endmodule
