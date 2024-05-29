`timescale 1ns / 1ps

module tb_DedicatedProcessor ();
    reg        clk;
    reg        reset;
    wire [7:0] out;

    DedicatedProcessor dut (
        .clk  (clk),
        .reset(reset),
        .out  (out)
    );

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1;
        #30 reset = 0;
    end

endmodule
