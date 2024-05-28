`timescale 1ns / 1ps

module uart_fifo (
    input clk,
    input reset,

    input tx_en,
    input [7:0] tx_data,
    output tx_full,

    input rx_en,
    output [7:0] rx_data,
    output rx_empty,

    input  RX,
    output TX
);

    wire w_tx_empty;
    wire [7:0] w_tx_data;
    wire w_tx_done;

    FIFO #(
        .ADDR_WIDTH(3),
        .DATA_WIDTH(8)
    ) U_txfifo (
        .clk  (clk),
        .reset(reset),
        .wr_en(tx_en),
        .full (tx_full),
        .wdata(tx_data),
        .rd_en(w_tx_done),
        .empty(w_tx_empty),
        .rdata(w_tx_data)
    );

    wire [7:0] w_rx_data;
    wire w_rx_done;


    FIFO #(
        .ADDR_WIDTH(3),
        .DATA_WIDTH(8)
    ) U_rxfifo (
        .clk  (clk),
        .reset(reset),
        .wr_en(w_rx_done),
        .full (),
        .wdata(w_rx_data),
        .rd_en(rx_en),
        .empty(rx_empty),
        .rdata(rx_data)
    );


    uart U_uart (
        .clk(clk),
        .reset(reset),
        .start(~w_tx_empty),
        .tx_data(w_tx_data),
        .tx(TX),
        .tx_done(w_tx_done),
        .rx(RX),
        .rx_data(w_rx_data),
        .rx_done(w_rx_done)
    );

endmodule