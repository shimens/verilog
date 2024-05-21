`timescale 1ns / 1ps

module top (
    input clk,
    input reset,
    input rx,
    output tx,
    output led1,
    output led2,
    output led3
);
    wire [7:0] w_rx_data;
    wire       w_rx_done;

    uart U_UART (
        .clk(clk),
        .reset(reset),
        // Transmitter
        .start(w_rx_done),
        .tx_data(w_rx_data),
        .tx(tx),
        .tx_done(),
        // Receiver
        .rx(rx),
        .rx_data(w_rx_data),
        .rx_done(w_rx_done)
    );

    uart_fsm U_FSM (
        .clk  (clk),
        .reset(reset),
        .data (w_rx_data),
        .led1(led1),
        .led2(led2),
        .led3(led3)
    );


endmodule
