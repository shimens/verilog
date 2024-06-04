`define OPCODE_TYPE_R 7'b0110011
`define OPCODE_TYPE_IL 7'b0000011
`define OPCODE_TYPE_I 7'b0010011
`define OPCODE_TYPE_S 7'b0100011
`define OPCODE_TYPE_B 7'b1100011
`define OPCODE_TYPE_LUI 7'b0110111
`define OPCODE_TYPE_AUIPC 7'b0010111
`define OPCODE_TYPE_J 7'b1101111
`define OPCODE_TYPE_JI 7'b1100111

//R-TYPE
`define ADD 5'd0
`define SUB 5'd1
`define SLL 5'd2
`define SRL 5'd3
`define SRA 5'd4
`define SLT 5'd5
`define SLTU 5'd6
`define XOR 5'd7
`define OR 5'd8
`define AND 5'd9

// IL-TYPE
`define LB 5'd9
`define LH 5'd10
`define LBU 5'd11
`define LHU 5'd12

// S-TYPE
`define SB 5'd13
`define SH 5'd14

// B-TYPE
`define BEQ 5'd15
`define BNE 5'd16
`define BLT 5'd17
`define BGE 5'd18
`define BLTU 5'd19
`define BGEU 5'd20

// I-TYPE
`define SLLI 5'd21
`define SRLI 5'd22
`define SRAI 5'd23

// U-TYPE
`define LUI 5'd24
`define AUIPC 5'd25