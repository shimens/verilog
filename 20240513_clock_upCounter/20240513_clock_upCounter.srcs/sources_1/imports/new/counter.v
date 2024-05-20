`timescale 1ns / 1ps

module UpCounter_clock (
    input clk,
    input reset,
    output [13:0] clock_sec,
    output [13:0] clock_min
);
    wire w_clk_1hz;

    clkDiv #(
        .MAX_COUNT(100_000_000)
    ) U_ClkDiv_1Hz (
        .clk  (clk),
        .reset(reset),
        .o_clk(w_clk_1hz)
    );

    counter_clock U_counterClock (
        .clk(w_clk_1hz),
        .reset(reset),
        .secdata(clock_sec),
        .mindata(clock_min)
    );

    // fndController U_fndController (
    //     .clk(clk),
    //     .reset(reset),
    //     .digit(w_count_clock),
    //     .fndFont(fndFont),
    //     .fndCom(fndCom)
    // );
endmodule

module counter_clock (
    input clk,
    input reset,
    output [13:0] secdata,
    output [13:0] mindata

);
    reg [60-1:0] counter_sec = 0;
    reg [60-1:0] counter_min = 0;

    assign secdata = counter_sec;
    assign mindata = counter_min;

    always @(posedge clk, posedge reset) begin
        if (reset == 1'b1) begin
            counter_sec <= 0;
            counter_min <= 0;
        end else begin
            if (counter_sec == 60 - 1) begin
                counter_sec <= 0;

                if (counter_min == 60 - 1) begin
                    counter_min <= 0;
                end else begin
                    counter_min <= counter_min + 1;
                end

            end else begin
                counter_sec <= counter_sec + 1;
            end

        end
    end
endmodule
