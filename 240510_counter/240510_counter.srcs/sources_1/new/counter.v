`timescale 1ns / 1ps

module UpCounter_clock (
    input clk,
    input reset,
    output [3:0] fndCom,
    output [7:0] fndFont
);
    wire w_clk_1hz;
    wire [13:0] w_count_clock;

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
        .timedata(w_count_clock)
    );

    fndController U_fndController (
        .clk(clk),
        .reset(reset),
        .digit(w_count_clock),
        .fndFont(fndFont),
        .fndCom(fndCom)
    );
endmodule

module counter_clock (
    input  clk,
    input  reset,
    output [13:0] timedata
);
    reg [60-1:0] counter_sec = 0;
    reg [60-1:0] counter_min = 0;

    assign timedata = ((counter_min * 100) + counter_sec);

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
