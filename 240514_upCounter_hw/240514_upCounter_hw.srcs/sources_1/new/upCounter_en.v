`timescale 1ns / 1ps
module clockDiv #(
    parameter HERZ = 100
) (
    input  clk,
    input  reset,
    output o_clk
);
    reg [$clog2(100_000_000/HERZ)-1:0] counter;
    reg r_clk;

    assign o_clk = r_clk;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter <= 0;
            r_clk   <= 1'b0;
        end else begin
            if (counter == (100_000_000 / HERZ - 1)) begin
                counter <= 0;
                r_clk   <= 1'b1;
            end else begin
                counter <= counter + 1;
                r_clk   <= 1'b0;
            end
        end
    end

endmodule

module upCounter #(
    parameter MAX_NUM = 10_000
) (
    input                        clk,     // system operation clock
    input                        reset,
    input                        tick,    // time clock
    input                        en,
    output [$clog2(MAX_NUM)-1:0] counter
);
    reg [$clog2(MAX_NUM)-1:0] counter_reg, counter_next;

    // State Register
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_reg <= 0;
        end else begin
            counter_reg <= counter_next;
        end
    end

    // Next State Combinational Logic
    always @(*) begin
        if (tick && en) begin
            if (counter_reg == MAX_NUM - 1) begin
                counter_next = 0;
            end else begin
                counter_next = counter_reg + 1;
            end
        end else begin
            counter_next = counter_reg;
        end
    end

    // Output Combinational Logic
    assign counter = counter_reg;
endmodule
