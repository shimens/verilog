`define OP_TYPE_R 7'b0110011 //R-Type opcode 
`define OP_TYPE_IL 7'b0000011 //ILoad-Type opcode 
`define OP_TYPE_I 7'b0010011 //I-Type opcode 
`define OP_TYPE_S 7'b0100011 //S-Type opcode 
`define OP_TYPE_B 7'b1100011 //B-Type opcode 
`define OP_TYPE_U 7'b0110111 //LUI-Type opcode 
`define OP_TYPE_UA 7'b0010111 //AUIPC-Type opcode 
`define OP_TYPE_J 7'b1101111 //J-Type opcode 
`define OP_TYPE_JI 7'b1100111 //JI-Type opcode 

`define ADD  4'b0000
`define SUB  4'b1000
`define SLL  4'b0001
`define SRL  4'b0101
`define SRA  4'b1101
`define SLT  4'b0010
`define SLTU 4'b0011
`define XOR  4'b0100
`define OR   4'b0110
`define AND  4'b0111

`define BEQ 4'b0000
`define BNE 4'b0001
`define BLT 4'b0100
`define BGE 4'b0101
`define BLTU 4'b0110
`define BGEU 4'b0111