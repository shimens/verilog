`timescale 1ns / 1ps

module BUS_Interconnector (
    input  logic [31:0] address,
    input  logic [31:0] slave1_rdata,
    input  logic [31:0] slave2_rdata,
    input  logic [31:0] slave3_rdata,
    output logic [31:0] master_rdata,
    output logic [ 2:0] slave_sel
);
    decoder U_Decoder (
        .x(address),
        .y(slave_sel)
    );

    mux U_MUX (
        .sel(address),
        .a  (slave1_rdata),
        .b  (slave2_rdata),
        .c  (slave3_rdata),
        .y  (master_rdata)
    );

endmodule

module decoder (
    input  logic [31:0] x,
    output logic [ 2:0] y
);
    always_comb begin : decoder
        case (x[31:8])
            24'h0000_10: y = 3'b001;  // Data Memory
            24'h0000_20: y = 3'b010;  // GPO
            24'h0000_21: y = 3'b100;  // GPI
            default:     y = 3'b0;
        endcase
    end
endmodule

module mux (
    input  logic [31:0] sel,
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [31:0] c,
    output logic [31:0] y
);
    always_comb begin
        case (sel[31:8])
            24'h0000_10: y = a;
            24'h0000_20: y = b;
            24'h0000_21: y = c;
            default:     y = 32'bx;
        endcase
    end
endmodule
