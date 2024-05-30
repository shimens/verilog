`timescale 1ns / 1ps

module InstructionMemory (
    input  logic [31:0] addr,
    output logic [31:0] data
);
    logic [31:0] rom[0:63];  // 32bit Read Only Memory *64

    initial begin
        rom[0] = 32'h00520333;  // ADD X6, X4, X5
        rom[1] = 32'h401183b3;  // SUB X7, X3, X1
        rom[2] = 32'h0020f433;  // AND X8, X1, X2 => 0
        rom[3] = 32'h0020E4B3;  // OR  X9, X1, X2 => 3
        rom[4] = 32'h00902503;  // LW  X10, X0, 9
        rom[5] = 32'h001145B3;  // XOR X11,X2,X1
        rom[6] = 32'h00300603;  // LB X12, X0, 3
        rom[7] = 32'h00301683;  // LH X13, X0, 3
    end

    assign data = rom[addr[31:2]];  // 4byte
endmodule
