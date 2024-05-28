`timescale 1ns / 1ps

module button (
    input  clk,
    input  in,
    output out
);

    localparam N = 10;   // Shift Register를 길게 하기 위해서는 이 N을 변경해주면 됨.

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

// High가 연속적으로 N-1번 감지되면 High 출력
