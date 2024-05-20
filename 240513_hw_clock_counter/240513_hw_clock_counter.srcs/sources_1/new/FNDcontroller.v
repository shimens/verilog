`timescale 1ns / 1ps

module fndController (
    //input [1:0] fndSel, 이제 fndSel 없어지고 clk이 들어옴
    input        clk,
    input        reset,
    input        sel_sw,
    input [ 5:0] digits,
    input [ 5:0] digitm,
    input [13:0] digitc,

    output [7:0] fndFont,
    output [3:0] fndCom
);

    wire [3:0] w_digit_1, w_digit_10, w_digit_100, w_digit_1000;
    wire [3:0] w_digit_1c, w_digit_10c, w_digit_100c, w_digit_1000c;
    wire [3:0] w_digit;
    wire [3:0] w_digit_t;
    wire [3:0] w_digit_c;
    wire [1:0] w_count;
    wire w_clk_1khz;

    clkDiv #(
        .MAX_COUNT(100_000)
    ) U_ClkDiv (  // #(.MAX_COUNT(100_000)) 이게 없으면 default 값이 들어가고, 넣으면 입력된값 들어감
        .clk  (clk),
        .reset(reset),
        .o_clk(w_clk_1khz)
    );

    counter #(
        .MAX_COUNT(4)
    ) U_Counter_2bit (
        .clk  (w_clk_1khz),
        .reset(reset),
        .count(w_count)
    );

    FND_Sel_Decoder U_Decoder_2x4 (
        .x(w_count),
        .y(fndCom)
    );

    digitSpilitter U_Digitsplitter (
        .i_digits(digits),
        .i_digitm(digitm),
        .i_digitc(digitc),
        .o_digit_1(w_digit_1),
        .o_digit_10(w_digit_10),
        .o_digit_100(w_digit_100),
        .o_digit_1000(w_digit_1000),
        .o_digit_1c(w_digit_1c),
        .o_digit_10c(w_digit_10c),
        .o_digit_100c(w_digit_100c),
        .o_digit_1000c(w_digit_1000c)
    );

    mux U_Mux_4x1_time (
        .sel(w_count),
        .x0 (w_digit_1),
        .x1 (w_digit_10),
        .x2 (w_digit_100),
        .x3 (w_digit_1000),
        .y  (w_digit_t)
    );

    mux U_Mux_4x1_counter (
        .sel(w_count),
        .x0 (w_digit_1c),
        .x1 (w_digit_10c),
        .x2 (w_digit_100c),
        .x3 (w_digit_1000c),
        .y  (w_digit_c)
    );

    mux_2x1 U_Mux_2x1 (
        .sel_sw(sel_sw),
        .x0 (w_digit_t),
        .x1 (w_digit_c),
        .y  (w_digit)
    );

    BCD_to_Segment U_BcdToSeg (
        .bcd(w_digit),  // 입력 4bit
        .seg(fndFont)   // 출력 8bit
    );

endmodule


module mux (
    input      [1:0] sel,
    input      [7:0] x0,
    input      [7:0] x1,
    input      [7:0] x2,
    input      [7:0] x3,
    output reg [7:0] y
);

    always @(*) begin // 괄호안에 *이면 always문안에 있는 값들을 모두 감시함.
        case (sel)
            2'b00:   y = x0;
            2'b01:   y = x1;
            2'b10:   y = x2;
            2'b11:   y = x3;
            default: y = x0;
        endcase
    end
endmodule

module mux_2x1 (
    input      [1:0] sel_sw,
    input      [7:0] x0,
    input      [7:0] x1,
    output reg [7:0] y
);

    always @(*) begin // 괄호안에 *이면 always문안에 있는 값들을 모두 감시함.
        case (sel_sw)
            1'b0: y = x0;
            1'b1: y = x1;
            default: y = x0;
        endcase
    end
endmodule

module digitSpilitter (
    input  [ 5:0] i_digits,
    input  [ 5:0] i_digitm,
    input  [13:0] i_digitc,
    output [ 7:0] o_digit_1,
    output [ 7:0] o_digit_10,
    output [ 7:0] o_digit_100,
    output [ 7:0] o_digit_1000,
    output [ 7:0] o_digit_1c,
    output [ 7:0] o_digit_10c,
    output [ 7:0] o_digit_100c,
    output [ 7:0] o_digit_1000c
);

    assign o_digit_1    = i_digits % 10;
    assign o_digit_10   = i_digits / 10 % 10;
    assign o_digit_100  = i_digitm % 10;
    assign o_digit_1000 = i_digitm / 10 % 10;
    assign o_digit_1c    = i_digitc % 10;
    assign o_digit_10c   = i_digitc / 10 % 10;
    assign o_digit_100c  = i_digitc /100% 10;
    assign o_digit_1000c = i_digitc / 1000 % 10;

endmodule


module BCD_to_Segment (
    input      [7:0] bcd,  // 입력 4bit
    output reg [7:0] seg   // 출력 8bit
);

    always @(bcd) begin
        case (bcd)
            8'h0: seg = 8'hc0;  // 8비트에 헥사(16진수)로 c0
            8'h1: seg = 8'hf9;
            8'h2: seg = 8'ha4;
            8'h3: seg = 8'hb0;
            8'h4: seg = 8'h99;
            8'h5: seg = 8'h92;
            8'h6: seg = 8'h82;
            8'h7: seg = 8'hf8;
            8'h8: seg = 8'h80;
            8'h9: seg = 8'h90;
            8'ha: seg = 8'h88;
            8'hb: seg = 8'h83;
            8'hc: seg = 8'hc6;
            8'hd: seg = 8'ha1;
            8'he: seg = 8'h86;
            8'hf: seg = 8'h8e;
            default: seg = 8'hff;  // 다 안나오게
        endcase
    end
endmodule

module FND_Sel_Decoder (
    input [1:0] x,
    output reg [3:0] y
);

    always @(x) begin
        case (x)
            2'b00:   y = 4'b1110;
            2'b01:   y = 4'b1101;
            2'b10:   y = 4'b1011;
            2'b11:   y = 4'b0111;
            default: y = 4'b1111;
        endcase
    end
endmodule


module counter #(
    parameter MAX_COUNT = 4
) (  // #(parameter MAX_COUNT = 4) → #define 같은 느낌
    input clk,
    input reset,
    output [$clog2(MAX_COUNT)- 1 : 0] count,
    output o_min_clk
);
    reg [$clog2(MAX_COUNT)- 1 : 0] counter = 0;
    assign count = counter;  // wire type은 assign으로 연결
    reg r_tick_1 = 0;

    assign o_min_clk = r_tick_1;

    always @(posedge clk, posedge reset) begin  // posedge: clk의 엣지를 센다
        if (reset == 1'b1) begin
            counter <= 0;
        end else begin
            if (counter == MAX_COUNT - 1) begin
                counter  <= 0;
                r_tick_1 <= 1'b1;
            end else begin
                counter  <= counter + 1;
                r_tick_1 <= 1'b0;
            end
        end
    end
endmodule



module clkDiv #(
    parameter MAX_COUNT = 100
) (
    input  clk,
    input  reset,
    output o_clk
);

    reg [$clog2(MAX_COUNT) - 1 : 0] counter = 0;
    reg r_tick = 0;

    assign o_clk = r_tick;

    always @(posedge clk, posedge reset) begin
        if (reset == 1'b1) begin
            counter <= 0;
        end else begin
            if (counter == (MAX_COUNT - 1)) begin  //100k번 count 출력 = 1kHz
                counter <= 0;
                r_tick  <= 1'b1;
            end else begin
                counter <= counter + 1;
                r_tick  <= 1'b0;
            end
        end
    end
endmodule
