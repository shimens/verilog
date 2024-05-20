`timescale 1ns / 1ps

module tb_gates();

    reg x0;
    reg x1;
    wire y0;
    wire y1;
    wire y2;
    wire y3;
    wire y4;
    wire y5;
    wire y6;

gatees test_bench(
    .x0(x0),
    .x1(x1),
   .y0(y0),
   .y1(y1),
   .y2(y2),
   .y3(y3),
   .y4(y4),
   .y5(y5),
   .y6(y6)
    );
    
    initial begin
    #00 x1 = 0; x0 = 0;
    #10 x1 = 0; x0 = 1;
    #10 x1 = 1; x0 = 0;
    #10 x1 = 1; x0 = 1;
    #10 $finish;
    end
    
endmodule
