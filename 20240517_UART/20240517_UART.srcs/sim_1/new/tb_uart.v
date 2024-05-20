`timescale 1ns / 1ps

module tb_uart ();

    reg clk;
    reg reset;
    reg tx_start;
    reg [7:0] tx_data;
    wire tx;
    wire tx_done;

    uart dut (
        .clk(clk),
        .reset(reset),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx),
        .tx_done(tx_done)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 1'b0;
        reset = 1'b1;
        tx_start = 1'b0;
        tx_data = 0;
    end

    initial begin
        #100 reset = 1'b0;
        #100 tx_start = 1'b1;
        tx_data = 8'b11001010;
        #10 tx_start = 1'b0;
    end

endmodule
