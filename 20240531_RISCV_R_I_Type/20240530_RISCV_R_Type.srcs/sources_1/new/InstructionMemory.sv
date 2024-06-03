`timescale 1ns / 1ps

module InstructionMemory (
    input  logic [31:0] addr,
    output logic [31:0] data
);
    logic [31:0] rom[0:63];  // 32bit Read Only Memory *64

    initial begin
        rom[0]  = 32'h00520333;  // ADD  X6, X4, X5
        rom[1]  = 32'h401183b3;  // SUB  X7, X3, X1
        rom[2]  = 32'h0020f433;  // AND  X8, X1, X2 => 0
        rom[3]  = 32'h0020E4B3;  // OR   X9, X1, X2 => 3
        rom[4]  = 32'h00D02503;  // LW   X10, X0, 13
        rom[5]  = 32'h00A08193;  // ADDI X3, X1, 10
        rom[6]  = 32'h00502223;  // SW   X0, 4, X5
        rom[7]  = 32'h00108463;  // BEQ  X1, X1, 8
        rom[8]  = 32'h00d02683;
        rom[9]  = 32'h00e02703;
        rom[10] = 32'h00f02783;
        rom[11] = 32'h01002803;
        rom[12] = 32'h01102883;
        rom[13] = 32'h01202903;
    end

    assign data = rom[addr[31:2]];  // 4byte
endmodule
