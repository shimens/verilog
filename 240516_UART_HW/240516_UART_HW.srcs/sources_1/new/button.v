`timescale 1ns / 1ps

module button (
    input  clk,
    input  in,
    output out
);

    localparam N = 10;

    reg [N-1:0] q_reg, q_next;

    always @(posedge clk) begin
        q_reg <= q_next;
    end

    // Next State Logic
    always @(q_reg, in) begin
        q_next = {in, q_reg[N-1:1]};
    end

    // Output Logic
    assign out = (&q_reg[N-1:1] & ~q_reg[0]);
endmodule
