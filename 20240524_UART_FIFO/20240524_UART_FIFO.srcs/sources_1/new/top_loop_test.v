`timescale 1ns / 1ps

module top_loop_test (
    input  clk,
    input  reset,
    input  rx,
    output tx
);
    wire       w_rx_empty;
    wire [7:0] w_rx_data;

    uart_fifo U_UART_FIFO (
        .clk     (clk),
        .reset   (reset),
        .tx      (tx),
        .tx_en   (~w_rx_empty),
        .tx_data (w_rx_data),
        .tx_full (),
        .rx      (rx),
        .rx_data (w_rx_data),
        .rx_en   (~w_rx_empty),
        .rx_empty(w_rx_empty)
    );
endmodule
