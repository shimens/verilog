`timescale 1ns / 1ps

`include "defines.sv"

module DataPath ();
endmodule

module RegisterFile (
    input  logic        clk,
    input  logic        WE,
    input  logic [ 4:0] RA1,
    input  logic [ 4:0] RA2,
    input  logic [ 4:0] WA,
    input  logic [31:0] WD,
    output logic [31:0] RD1,
    output logic [31:0] RD2
);
    logic [31:0] RegFile[0:31];

    initial begin
        RegFile[0] = 32'd0;
        RegFile[1] = 32'd1;
        RegFile[2] = 32'd2;
        RegFile[3] = 32'd3;
        RegFile[4] = 32'd4;
        RegFile[5] = 32'd5;
    end

    always_ff @(posedge clk) begin
        if (WE) RegFile[WA] <= WD;
    end

    assign RD1 = (RA1 != 0) ? RegFile[RA1] : 0;
    assign RD2 = (RA2 != 0) ? RegFile[RA2] : 0;
endmodule

module register (
    input clk,
    input reset,
    input d,
    output q
);
    
endmodule