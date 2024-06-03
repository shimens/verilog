`timescale 1ns / 1ps

module InstructionMemory (
    input  logic [31:0] addr,
    output logic [31:0] data
);
    logic [31:0] rom[0:63];

    initial begin
        rom[0] = 32'h00520333;  // ADD  X6, X4, X5
        rom[1] = 32'h401183b3;  // SUB  X7, X3, X1
        rom[2] = 32'h0020f433;  // AND  X8, X1, X2 => 0
        rom[3] = 32'h0020E4B3;  // OR   X9, X1, X2 => 3
        rom[4] = 32'h00D02503;  // LW   X10, X0, 13
        rom[5] = 32'h00A08193;  // ADDI X3, X1, 10
        rom[6] = 32'h00502223;  // SW   X0, 4, X5
        rom[7] = 32'h00421593;  // SLLI X11, X4, 4
        rom[8] = 32'h00235613;  // SRLI X12, X6, 2
        rom[9] = 32'h404006B3;  // SUB  X13, X0, X4
        rom[10]= 32'h4016d713;
        // rom[9] = 32'h40355693;
        // rom[7]  = 32'h00108463;  // BEQ  X1, X1, 8                        
        // rom[9]  = 32'h000015b7;  // LUI   X11 1                        36                     
        // rom[10] = 32'h00001617;  // AUIPC X12 1                        0                         
        // rom[11] = 32'h010006ef;  // JAL X13, 8                        0                     
        // // rom[11] = 32'h000106EF;  // JAL X13, 16                     0                         
        // // rom[13] = 32'h02E108E7;  // JALR X17, X2, 46                   0                             
        // rom[12] = 32'h005207B3;     // ADD   X15, X4, X5            0                                 
        // rom[13] = 32'h40118833;     // SUB   X16, X3, X1            0                                 
        // rom[14] = 32'h0080086F;  // JAL X17, 8                      0                         
        // rom[15] = 32'h02E10767;  // JALR X14, X2, 46                 0                             
        // rom[13] = 32'h00A10767;  // JALR X14, X2, 10                0                             
        // rom[11]  = 32'h00A08693;  // ADDI  X13, X1, 10              0                                 
        // rom[12]  = 32'h0072E713;  // ORI  X14, X5, 7                0                             
        // rom[13] =32'h00208767;   //jalr x14, x1, 2                  0                             
        // rom[11] = 32'h005216B3;  // SLL   X13, X4, X5               0                                 
        // rom[12] = 32'h0042D733;  // SRL   X14, X5, X1               0                                 
        // rom[13] = 32'h4012D7B3;  // SRA   X15, X5, X1               0                                 
        // rom[14] = 32'h0012A833;  // SLT   X16, X1, X5               0                                 
        // rom[15] = 32'h0022C8B3;  // XOR   X17, X5, X2               0                                 
    end

    assign data = rom[addr[31:2]];
endmodule
