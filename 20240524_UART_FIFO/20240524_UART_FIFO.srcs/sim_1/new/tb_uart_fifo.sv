`timescale 1ns / 1ps

module tb_uart_fifo ();
    reg        clk;
    reg        reset;
    wire       tx;
    reg        tx_en;
    reg  [7:0] tx_data;
    wire       tx_full;
    reg        rx;
    wire [7:0] rx_data;
    reg        rx_en;
    wire       rx_empty;
    wire       w_tx_rx_loop;

    uart_fifo dut (
        .clk(clk),
        .reset(reset),
        .tx(w_tx_rx_loop),
        .tx_en(tx_en),
        .tx_data(tx_data),
        .tx_full(tx_full),
        .rx(w_tx_rx_loop),
        .rx_data(rx_data),
        .rx_en(rx_en),
        .rx_empty(rx_empty)
    );

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1'b1;
        tx_en = 1'b0;
        rx_en = 1'b0;
    end

    initial begin
        #80 reset = 1'b0;
        #50;
        @(posedge clk);
        tx_data = "0";
        tx_en   = 1'b1;
        @(posedge clk);
        tx_en = 1'b0;
        @(posedge clk);
        tx_data = "1";
        tx_en   = 1'b1;
        @(posedge clk);
        tx_en = 1'b0;
        @(posedge clk);
        tx_data = "2";
        tx_en   = 1'b1;
        @(posedge clk);
        tx_en = 1'b0;

        while (!rx_empty) begin
            rx_en = 1'b1;
            @(posedge clk);
        end
    end

endmodule



// `timescale 1ns / 1ps

// module tb_uart_fifo ();

//     reg        clk;
//     reg        reset;
//     wire       tx;
//     reg        tx_en;
//     reg  [7:0] tx_data;
//     wire       tx_full;
//     reg        rx;
//     reg        rx_en;
//     wire [7:0] rx_data;
//     wire       rx_empty;

//     uart_fifo dut (
//         .clk     (clk),
//         .reset   (reset),
//         .tx      (tx),
//         .tx_en   (tx_en),
//         .tx_data (tx_data),
//         .tx_full (tx_full),
//         .rx      (rx),
//         .rx_en   (rx_en),
//         .rx_data (rx_data),
//         .rx_empty(rx_empty)
//     );

//     always #5 clk = ~clk;

//     initial begin
//         clk   = 0;
//         reset = 1'b1;
//     end

//     initial begin
//         #80 reset = 1'b0;
//         #20 tx_data = "0";
//         tx_en = 1'b1;
//         @(posedge clk) tx_en = 1'b0;
//         #10 tx_data = "1";
//         tx_en = 1'b1;
//         @(posedge clk) tx_en = 1'b0;
//         #10 tx_data = "2";
//         tx_en = 1'b1;
//         @(posedge clk) tx_en = 1'b0;
//         #10 tx_data = "3";
//         tx_en = 1'b1;
//         @(posedge clk) tx_en = 1'b0;
//     end
// endmodule
