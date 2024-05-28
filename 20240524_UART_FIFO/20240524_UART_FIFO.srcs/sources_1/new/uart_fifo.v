`timescale 1ns / 1ps

module uart_fifo (
    input        clk,
    input        reset,
    output       tx,
    input        tx_en,
    input  [7:0] tx_data,
    output       tx_full,
    input        rx,
    output [7:0] rx_data,
    input        rx_en,
    output       rx_empty
);
    wire w_tx_fifo_empty, w_tx_done, w_rx_done;
    wire [7:0] w_tx_fifo_rdata, w_rx_data;

    uart U_UART (
        .clk  (clk),
        .reset(reset),
        .tx(tx),
        .tx_done(w_tx_done),
        .start(~w_tx_fifo_empty),
        .tx_data(w_tx_fifo_rdata),
        .rx_data(w_rx_data),
        .rx_done(w_rx_done),
        .rx(rx)

    );

    FIFO #(
        .ADDR_WIDTH(3),
        .DATA_WIDTH(8)
    ) U_Rx_Fifo (
        .clk(clk),
        .reset(reset),
        .wr_en(w_rx_done),
        .full(),  // output은 wire 되어있음
        .wdata(w_rx_data),
        .rd_en(rx_en),
        .empty(rx_empty),
        .rdata(rx_data)
    );

    FIFO #(
        .ADDR_WIDTH(3),
        .DATA_WIDTH(8)
    ) U_Tx_Fifo (
        .clk(clk),
        .reset(reset),
        .wr_en(tx_en),
        .full(tx_full),  // output은 wire 되어있음
        .wdata(tx_data),
        .rd_en(w_tx_done),
        .empty(w_tx_fifo_empty),
        .rdata(w_tx_fifo_rdata)
    );

endmodule



// `timescale 1ns / 1ps

// module uart_fifo (
//     input        clk,
//     input        reset,
//     // Tx
//     output       tx,
//     input        tx_en,
//     input  [7:0] tx_data,
//     output       tx_full,
//     // Rx
//     input        rx,
//     input        rx_en,
//     output [7:0] rx_data,
//     output       rx_empty
// );
//     wire w_tx_fifo_empty, w_tx_done, w_rx_done;
//     wire [7:0] w_tx_fifo_rdata, w_rx_data;

//     uart U_UART (
//         .clk    (clk),
//         .reset  (reset),
//         // Transmitter
//         .start  (~w_tx_fifo_empty),
//         .tx_data(w_tx_fifo_rdata),
//         .tx     (tx),
//         .tx_done(w_tx_done),
//         // Receiver
//         .rx     (rx),
//         .rx_data(w_rx_data),
//         .rx_done(w_rx_done)
//     );

//     fifo #(
//         .ADDR_WIDTH(3),
//         .DATA_WIDTH(8)
//     ) U_TX_FIFO (
//         .clk  (clk),
//         .reset(reset),
//         .wr_en(tx_en),
//         .full (tx_full),
//         .wdata(tx_data),
//         .rd_en(w_tx_done),
//         .empty(w_tx_fifo_empty),
//         .rdata(w_tx_fifo_rdata)
//     );

//     fifo #(
//         .ADDR_WIDTH(3),
//         .DATA_WIDTH(8)
//     ) U_RX_FIFO (
//         .clk  (clk),
//         .reset(reset),
//         .wr_en(w_rx_done),
//         .full (),
//         .wdata(w_rx_data),
//         .rd_en(rx_en),
//         .empty(rx_empty),
//         .rdata(rx_data)
//     );

// endmodule
