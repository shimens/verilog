`timescale 1ns / 1ps
`include "defines.sv"

module ControlUnit (
    input  logic [6:0] op,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,
    output logic       regFileWe,
    output logic       AluSrcMuxSel,
    output logic [2:0] RFWriteDataSrcMux,
    output logic       dataMemWe,
    output logic [2:0] extType,
    output logic [3:0] aluControl,
    output logic branch,
    output logic [1:0] PCScrMuxSel
);
    logic [11:0] controls;
    //logic [1:0] w_AluOp;
    assign {regFileWe, AluSrcMuxSel, RFWriteDataSrcMux, dataMemWe, extType, branch, PCScrMuxSel} = controls;

    always_comb begin : main_decoder
        case (op)
            // regFileWe, AluSrcMuxSel, RFWriteDataSrcMux, dataMemWe, extType
            `OP_TYPE_R:  controls = 13'b1_0_000_0_xxx_0_00;  //R-Type opcode 
            `OP_TYPE_IL: controls = 13'b1_1_001_0_000_0_00;  //ILoad-Type opcode 
            `OP_TYPE_I:  controls = 13'b1_1_000_0_000_0_00;  //I-Type opcode 
            `OP_TYPE_S:  controls = 13'b0_1_xxx_1_001_0_00;  //S-Type opcode // sxx (rs1), (imm), (rs2) 
            `OP_TYPE_B:  controls = 13'b0_0_xxx_0_010_1_00;  //B-Type opcode // BXX (rs1), (rs2), (imm)
            `OP_TYPE_U:  controls = 13'b1_x_010_0_011_0_00;  //LUI-Type opcode 
            `OP_TYPE_UA: controls = 13'b1_x_011_0_011_0_00;  //AUIPC-Type opcode 
            `OP_TYPE_J:  controls = 13'b1_1_100_0_100_0_01;  //J-Type opcode 
            `OP_TYPE_JI: controls = 13'b1_1_100_0_000_0_10;  //JI-Type opcode 
            default:     controls = 13'b0;
        endcase
    end

    always_comb begin : alu_control_signal
        // case ({funct7[5], funct3}) //funct7은 다 같은데 [5]번자리가 달라서 거기만 포함시켜 준 것
        case (op) //funct7은 다 같은데 [5]번자리가 달라서 거기만 포함시켜 준 것
            `OP_TYPE_R:  aluControl = {funct7[5], funct3};
            `OP_TYPE_IL: aluControl = {1'b0, 3'b000}; // 3'b000 : IL Type은 무조건 더하기로 동작한다
            `OP_TYPE_I:  aluControl = {funct7[5], funct3};  // MNEMONIC 명령어(Function3)가 R,I type이 같아서 이렇게 쓸 수 있다
            `OP_TYPE_S:  aluControl = {1'b0, 3'b000};
            `OP_TYPE_B:  aluControl = {1'b0, funct3};
            //`OP_TYPE_J: aluControl = {1'b0, funct3}; 아래 4개는 function3가 없음 
            //`OP_TYPE_JI: aluControl ={1'b0, funct3}; ==> 계산할게 없다
            //`OP_TYPE_U: aluControl = {1'b0, funct3}; ==> ALU 안쓴다
            //`OP_TYPE_UA: aluControl ={1'b0, funct3}; 
            default: aluControl = 4'bx;
        endcase
    end

endmodule
