`timescale 1ns / 1ps

module upCounter_hw (
    input clk,
    input reset,
    input btn1,
    input btn2,
    output [7:0] fndFont,
    output [3:0] fndCom
);
    wire w_btn1, w_btn2;
    wire w_en;
    wire w_reset;
    wire [13:0] w_counter;
    wire w_tick;

    button U_Btn1 (
        .clk(clk),
        .in (btn1),
        .out(w_btn1)
    );

    button U_Btn2 (
        .clk(clk),
        .in (btn2),
        .out(w_btn2)
    );

    upCounter_FSM U_FSM (
        .clk(clk),
        .reset(reset),
        .btn1(w_btn1),
        .btn2(w_btn2),
        .en(w_en),
        .reset_counter(w_reset)
    );

    clockDiv #(
        .HERZ(10)
    ) U_clockDiv (
        .clk  (clk),
        .reset(w_reset),
        .o_clk(w_tick)
    );

    upCounter #(
        .MAX_NUM(10_000)
    ) U_counter (
        .clk(clk),
        .reset(w_reset),
        .tick(w_tick),
        .en(w_en),
        .counter(w_counter)
    );

    fndController U_FND (
        .clk(clk),
        .reset(reset),
        .digit(w_counter),
        .fndFont(fndFont),
        .fndCom(fndCom)
    );
endmodule
