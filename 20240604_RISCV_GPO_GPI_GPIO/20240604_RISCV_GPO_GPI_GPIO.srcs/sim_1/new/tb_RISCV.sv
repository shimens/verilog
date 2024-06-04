`timescale 1ns / 1ps

module tb_RISCV ();
    logic       clk;
    logic       reset;
    logic [3:0] OutPortA;
    logic [3:0] OutPortB;
    logic [3:0] InPortC;
    tri [3:0] IOPortD;

    RV32I_MCU dut (
        .clk(clk),
        .reset(reset),
        .OutPortA(OutPortA),
        .OutPortB(OutPortB),
        .InPortC(InPortC),
        .IOPortD(IOPortD)
    );

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1;
        #20 reset = 0;
        #30 InPortC=4'b0001;
        #30 InPortC=4'b0011;
        #30 InPortC=4'b0111;
        #30 InPortC=4'b1111;
    end
endmodule
