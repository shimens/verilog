`timescale 1ns / 1ps

module tb_DP ();
    logic       clk;
    logic       reset;
    logic [7:0] outPort;

    DedicatedProcessor dut (
        .clk    (clk),
        .reset  (reset),
        .outPort(outPort)
    );

    always #5 clk = ~clk;

    initial begin
        clk   <= 1'b0;
        reset <= 1'b1;
        #40 reset <= 1'b0;
    end
endmodule
