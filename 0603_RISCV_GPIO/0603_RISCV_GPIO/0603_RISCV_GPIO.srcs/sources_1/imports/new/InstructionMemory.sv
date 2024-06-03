`timescale 1ns / 1ps

module InstructionMemory (
    input  logic [31:0] addr,
    output logic [31:0] data
);
    logic [31:0] ROM[0:63];

    initial begin
        ROM[0] = 32'h00520333;  // add x6, x4, x5
        ROM[1] = 32'h401183b3;  // sub x7, x3, x1
        ROM[2] = 32'h0020f433;  // and x8, x1, x2 => 0
        ROM[3] = 32'h0020E4B3;  // or  x9, x1, x2 => 3 // 0x0020E4B3
        ROM[4] = 32'h00A02503;  // lw  x10, x0, 10 
        ROM[5] = 32'h00A08193;  // addi  x3, x1, 10 => 11
        // ROM[6] = 32'h00B08593;  // addi  x11, x1, 11 => 12
        ROM[6] = 32'h00502223;  // sw x0, 4, x5
        ROM[7] = 32'h00108463;  // beq x1, x1, 8    // 8byte 건너
        ROM[9] = 32'h000015b7;  // lui x11, 1 
        ROM[10] = 32'h000011b7;  // lui x3, 1 
        ROM[11] = 32'h00001197;  // auipc x3, 1 

        ROM[12] = 32'h00003217;  // auipc x4, 3
        ROM[13] = 32'h00006297;  // auipc x5, 6

    end

    // 주소 한개(단위)가 여기선 32bit인데 일반적으로는 8bit라서 4단위로 끊어서 보겠다
    assign data = ROM[addr[31:2]];

endmodule


