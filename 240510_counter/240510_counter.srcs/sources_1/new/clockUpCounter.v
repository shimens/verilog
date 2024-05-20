`timescale 1ns / 1ps

module clockUpCounter(
    input clk,
    input reset,
    input [1:0] modebtn,
    output [3:0] fndCom,
    output [7:0] fndFont
    );

    UpCounter_clock U_clock (
    .clk(clk),
    .reset(reset),
    .fndCom(fndCom),
    .fndFont(fndFont)
);

    UpCounter_10k U_upCounter(
    .clk(clk),
    .reset(reset),
    .fndCom(fndCom),
    .fndFont(fndFont)
);

mux_2x1 (
    .sel(modebtn),
    .x0(),
    .x1(),
    .y()
);

endmodule

module mux_2x1 (
    input [1:0] sel,
    input [3:0] x0,
    input [3:0] x1,
    output reg [3:0] y
);
    always @(*) begin
        case (sel)
            // 2'b00:   y = x0;
            2'b01:   y = x1;
            2'b10:   y = x0;
            // 2'b11:   y = x3;
            // default: y = x0;
        endcase
    end
endmodule
