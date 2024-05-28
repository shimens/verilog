`timescale 1ns / 1ps


module tb_stopwatch ();

    reg        clk;
    reg        reset;
    reg        tick;
    reg        btn1_Tick;  // run_stop
    reg        btn2_Tick;  // clear
    reg        btn_Mode;  //enable
    wire [6:0] count_ms;
    wire [5:0] count_s;

    prjStopWatch dut (
        .clk(clk),
        .reset(reset),
        .tick(tick),
        .btn1_Tick(btn1_Tick),  // run_stop
        .btn2_Tick(btn2_Tick),  // clear
        .btn_Mode(btn_Mode),  //enable
        .count_ms(count_ms),
        .count_s(count_s)
    );

    always #1 clk = ~clk;
    always #20 tick = ~tick;


    initial begin
        clk = 1'b1;
        reset = 1'b1;
        tick = 1'b0;
        btn1_Tick = 1'b0;
        btn2_Tick = 1'b0;
        btn_Mode = 1'b0;
    end

    initial begin
        #100 reset = 1'b0;

        #100 btn_Mode = 1'b1;

        #300 btn1_Tick = 1'b1;
        #2 btn1_Tick = 1'b0;
        #300 btn1_Tick = 1'b1;
        #2 btn1_Tick = 1'b0;
        #100 btn1_Tick = 1'b1;
        #2 btn1_Tick = 1'b0;
        #1000 btn1_Tick = 1'b1;
        #2 btn1_Tick = 1'b0;
        #100 btn2_Tick = 1'b1;
        #2 btn2_Tick = 1'b0;
        #300 btn1_Tick = 1'b1;
        #2 btn1_Tick = 1'b0;
        #1000 btn1_Tick = 1'b1;
        #2 btn1_Tick = 1'b0;
        #100 btn2_Tick = 1'b1;
        #2 btn2_Tick = 1'b0;
        #300 btn1_Tick = 1'b1;
        #2 btn1_Tick = 1'b0;
        #300 btn1_Tick = 1'b1;
        #2 btn1_Tick = 1'b0;
        #100 btn2_Tick = 1'b1;
        #2 btn2_Tick = 1'b0;
        #300 btn1_Tick = 1'b1;
        #2 btn1_Tick = 1'b0;
        // #1000 btn1_Tick = 1'b1;
        // #10 btn1_Tick = 1'b0;

        #100 btn_Mode = 1'b0;

        #300 btn1_Tick = 1'b1;
        #2 btn1_Tick = 1'b0;
        #300 btn1_Tick = 1'b1;
        #2 btn1_Tick = 1'b0;
        #100 btn1_Tick = 1'b1;
        #2 btn1_Tick = 1'b0;
        #1000 btn1_Tick = 1'b1;
        #2 btn1_Tick = 1'b0;
        #100 btn2_Tick = 1'b1;
        #2 btn2_Tick = 1'b0;
        #300 btn1_Tick = 1'b1;
        #2 btn1_Tick = 1'b0;
        #1000 btn1_Tick = 1'b1;
        #2 btn1_Tick = 1'b0;

    end
endmodule
