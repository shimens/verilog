`timescale 1ns / 1ps

module DataPath (
    input        clk,
    input        reset,
    input        ASrcMuxSel,
    input        ALoad,
    input        OutBufSel,
    output       ALt10,
    output [7:0] out
);
    wire [7:0] w_AdderResult, w_MuxOut, w_ARegOut, w_ARegOut_0, w_MuxOut_0, w_AdderResult_0;

    mux_2x1 U_MUX (
        .sel(ASrcMuxSel),
        .a  (0),
        .b  (w_AdderResult),
        .y  (w_MuxOut)
    );

    register U_A_REG (
        .clk  (clk),
        .reset(reset),
        .load (ALoad),
        .d    (w_MuxOut),
        .q    (w_ARegOut)
    );

    comparator U_Comp (
        .a (w_ARegOut),
        .b (8'd11),
        .lt(ALt10)
    );

    adder U_Adder (
        .a(w_ARegOut),
        .b(8'd1),
        .y(w_AdderResult)
    );

    adder U_Adder_0 (
        .a(w_ARegOut),
        .b(w_ARegOut_0),
        .y(w_AdderResult_0)
    );

    mux_2x1 U_MUX_0 (
        .sel(ASrcMuxSel),
        .a  (0),
        .b  (w_AdderResult_0),
        .y  (w_MuxOut_0)
    );

    register U_A_REG_0 (
        .clk  (clk),
        .reset(reset),
        .load (ALoad),
        .d    (w_MuxOut_0),
        .q    (w_ARegOut_0)
    );

    register U_OutReg (
        .clk  (clk),
        .reset(reset),
        .load (OutBufSel),
        .d    (w_AdderResult_0),
        .q    (out)
    );

endmodule

module mux_2x1 (
    input            sel,
    input      [7:0] a,
    input      [7:0] b,
    output reg [7:0] y
);
    always @(*) begin
        case (sel)
            1'b0: y = a;
            1'b1: y = b;
        endcase
    end
endmodule

module register (
    input        clk,
    input        reset,
    input        load,
    input  [7:0] d,
    output [7:0] q
);
    reg [7:0] d_reg, d_next;
    assign q = d_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) d_reg <= 0;
        else d_reg <= d_next;
    end

    always @(*) begin
        if (load) d_next = d;
        else d_next = d_reg;
    end
endmodule

module comparator (
    input  [7:0] a,
    input  [7:0] b,
    output       lt
);
    assign lt = a < b;
endmodule

module adder (
    input  [7:0] a,
    input  [7:0] b,
    output [7:0] y
);
    assign y = a + b;
endmodule

module outBuf (
    input        en,
    input  [7:0] a,
    output [7:0] y
);
    assign y = en ? a : 8'bz;  // en = 1 : a, en != 0 : z
endmodule
