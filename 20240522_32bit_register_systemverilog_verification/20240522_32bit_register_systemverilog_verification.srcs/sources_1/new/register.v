`timescale 1ns / 1ps

module register (
    input         clk,
    input         reset,
    input  [31:0] d,
    output [31:0] q
);

    reg [31:0] q_reg;  // , q_next;
    assign q = q_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            q_reg <= 0;
        end else begin
            q_reg <= d;
        end
    end

    // always @(*) begin
    //     q_next = d;
    // end
endmodule
