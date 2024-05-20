`timescale 1ns / 1ps

module tb_button ();

    reg  clk;
    reg  in;
    wire out;

    button dut (
        .clk(clk),
        .in (in),
        .out(out)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 1'b0;
        in  = 1'b0;
    end

    initial begin
        #60 in = 1'b1;
        #2 in = 1'b0;
        #2 in = 1'b1;
        #2 in = 1'b0;
        #2 in = 1'b1;
        #2 in = 1'b0;
        #2 in = 1'b1;
        #2 in = 1'b0;
        #2 in = 1'b1;
        #2 in = 1'b0;
        #2 in = 1'b1;
        #2 in = 1'b0;
        #2 in = 1'b1;
        #2 in = 1'b0;
        #2 in = 1'b1;
        #2 in = 1'b0;
        #2 in = 1'b1;
        #2 in = 1'b0;
        #2 in = 1'b1;
        #2 in = 1'b0;
        #2 in = 1'b1;
        #60 in = 1'b1;
        #60 in = 1'b1;
        #10 in = 1'b0;
        #2 in = 1'b1;
        #2 in = 1'b0;
        #2 in = 1'b1;
        #2 in = 1'b0;
        #2 in = 1'b1;
        #2 in = 1'b0;
    end

endmodule
