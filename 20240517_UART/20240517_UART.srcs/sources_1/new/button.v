`timescale 1ns / 1ps

module button (
    input  clk,
    input  in,
    output out
);

    localparam N = 64;  // 64bit Shift Register

    wire w_debounce_out;
    reg [1:0] dff_reg, dff_next;
    reg [N-1:0] Q_reg, Q_next;

    // debounce circuit
    always @(Q_reg, in) begin
        Q_next = {Q_reg[N-2:0], in};  // Left Shift Register
    end

    always @(posedge clk) begin
        Q_reg   <= Q_next;
    end

    assign w_debounce_out = &Q_reg;

    // dff edge-detector

    always @(*) begin
        dff_next[0] = w_debounce_out;
        dff_next[1] = dff_reg[0];
    end

    always @(posedge clk) begin
        dff_reg <= dff_next;
    end

    // Output Logic
    assign out = ~dff_reg[0] & dff_reg[1];

endmodule
