`timescale 1ns / 1ps

module up_counter (
    input clk,
    input reset,
    input tick,
    input run_stop,
    input clear,
    output [13:0] count
);

    reg [13:0] counter_reg, counter_next;
    assign count = counter_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_reg <= 0;
        end else begin
            counter_reg <= counter_next;
        end
    end

    always @(*) begin
        counter_next = counter_reg;
        if (tick && run_stop) begin
            if (counter_reg == 9999) begin
                counter_next = 0;
            end else begin
                counter_next = counter_reg + 1;
            end
        end else if (clear) begin
            counter_next = 0;
        end
    end
endmodule
