`timescale 1ns / 1ps

module clockUpCounter(
    input clk,
    input reset,
    input modeSwitch,
    output [3:0] fndCom,
    output [7:0] fndFont
    );
    wire [13:0] w_count_clock0;
    wire [13:0] w_count_10k0;
    wire [3:0] w_digit;

    UpCounter_clock U_clock (
    .clk(clk),
    .reset(reset),
    .fndCom(fndCom),
    .count_clock(w_count_clock0)
);

    UpCounter_10k U_upCounter(
    .clk(clk),
    .reset(reset),
    .fndCom(fndCom),
    .count_10k(w_count_10k0)
);

mux_2x1 U_Mux21(
    .sel(modeSwitch),
    .x0(w_count_clock0),
    .x1(w_count_10k0),
    .y(w_digit)
);

    BCDtoSEG U_BcdToSeg (
        .bcd(w_digit),
        .seg(fndFont)
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
             1'b0:   y = x0;
            1'b1:   y = x1;
             default: y = x0;
        endcase
    end
endmodule

module BCDtoSEG (
    input      [3:0] bcd,
    output reg [7:0] seg
);
    always @(bcd) begin
        case (bcd)
            4'h0: seg = 8'hc0;
            4'h1: seg = 8'hf9;
            4'h2: seg = 8'ha4;
            4'h3: seg = 8'hb0;
            4'h4: seg = 8'h99;
            4'h5: seg = 8'h92;
            4'h6: seg = 8'h82;
            4'h7: seg = 8'hf8;
            4'h8: seg = 8'h80;
            4'h9: seg = 8'h90;
            4'ha: seg = 8'h88;
            4'hb: seg = 8'h83;
            4'hc: seg = 8'hc6;
            4'hd: seg = 8'ha1;
            4'he: seg = 8'h86;
            4'hf: seg = 8'h8e;
            default: seg = 8'hff;
        endcase
    end
endmodule