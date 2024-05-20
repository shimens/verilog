`timescale 1ns / 1ps

module top(
input clk,
input reset,
input btn_tx_start,
output txd
    );
    wire w_btn_tx_start;

    button U_BTN_TX (
    .clk(clk),
    .in(btn_tx_start),
    .out(w_btn_tx_start)
);

uart U_UART(
    .clk(clk),
    .reset(reset),
    .tx_start(w_btn_tx_start),
    .tx_data(8'h41),
    .tx(txd),
    .tx_done()
);
endmodule
