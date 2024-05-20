`timescale 1ns / 1ps

module decoder (
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
