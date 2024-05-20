`timescale 1ns / 1ps

module Adder_FND_sel(
    input      [1:0] swsel,
    output reg [3:0] fndsel
    );

        always @(swsel) begin
        case (swsel)
        2'b00: fndsel = 4'b1110;
        2'b01: fndsel = 4'b1101;
        2'b10: fndsel = 4'b1011;
        2'b11: fndsel = 4'b0111;
            default: fndsel = 4'b1111;
        endcase
    end


endmodule
