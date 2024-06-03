`timescale 1ns / 1ps

module tb_RV32I ();
    logic clk;
    logic reset;

    RV32I dut (
        .clk  (clk),
        .reset(reset)
    );

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1;
        #40 reset = 0;
    end
endmodule
