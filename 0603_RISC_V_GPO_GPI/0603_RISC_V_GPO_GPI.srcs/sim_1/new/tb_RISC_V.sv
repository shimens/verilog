`timescale 1ns / 1ps

module tb_RISC_V ();
    logic clk;
    logic reset;
    logic [3:0] outPortA;

    RV32I dut (.*);

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1;
        #40 reset = 0;
    end

endmodule
